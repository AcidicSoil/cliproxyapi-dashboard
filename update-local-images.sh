#!/usr/bin/env bash
set -euo pipefail

# Repo-root helper for the localhost stack created by ./setup-local.sh
# Default: update both cliproxyapi and dashboard images/containers
# Usage:
#   ./update-local-images.sh
#   ./update-local-images.sh --proxy-only
#   ./update-local-images.sh --dashboard-only
#   ./update-local-images.sh --with-sidecar
#   ./update-local-images.sh --pull-only
#   ./update-local-images.sh --status

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="${SCRIPT_DIR}/docker-compose.local.yml"
SETUP_SCRIPT="${SCRIPT_DIR}/setup-local.sh"
ENV_FILE="${SCRIPT_DIR}/.env"
CONFIG_FILE="${SCRIPT_DIR}/config.local.yaml"

MODE="both"
WITH_SIDECAR=0
PULL_ONLY=0
SHOW_STATUS=0

usage() {
  cat <<USAGE
Usage: ./update-local-images.sh [options]

Options:
  --proxy-only       Update only the cliproxyapi container
  --dashboard-only   Update only the dashboard container
  --with-sidecar     Also update perplexity-sidecar when enabled locally
  --pull-only        Pull images only; do not recreate containers
  --status           Show compose status and exit
  -h, --help         Show this help
USAGE
}

for arg in "$@"; do
  case "$arg" in
    --proxy-only)
      MODE="proxy"
      ;;
    --dashboard-only)
      MODE="dashboard"
      ;;
    --with-sidecar)
      WITH_SIDECAR=1
      ;;
    --pull-only)
      PULL_ONLY=1
      ;;
    --status)
      SHOW_STATUS=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      log_error "Unknown argument: $arg"
      usage
      exit 1
      ;;
  esac
done

ensure_docker() {
  if ! command -v docker >/dev/null 2>&1; then
    log_error "docker not found"
    exit 1
  fi

  if ! docker info >/dev/null 2>&1; then
    log_error "docker is not running"
    exit 1
  fi

  if ! docker compose version >/dev/null 2>&1; then
    log_error "docker compose plugin not available"
    exit 1
  fi
}

ensure_repo_root() {
  if [[ ! -f "$COMPOSE_FILE" ]]; then
    log_error "docker-compose.local.yml not found next to this script"
    log_error "Place this file in the cliproxyapi-dashboard repo root"
    exit 1
  fi

  if [[ ! -f "$SETUP_SCRIPT" ]]; then
    log_error "setup-local.sh not found next to this script"
    log_error "Place this file in the cliproxyapi-dashboard repo root"
    exit 1
  fi
  
  if ! command -v git >/dev/null 2>&1; then
    log_error "git not found"
    exit 1
  fi

  if ! git -C "$SCRIPT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    log_error "$SCRIPT_DIR is not a Git repository"
    exit 1
  fi
}

bootstrap_if_needed() {
  if [[ -f "$ENV_FILE" && -f "$CONFIG_FILE" ]]; then
    return 0
  fi

  log_warning "Missing .env or config.local.yaml"
  log_info "Running ./setup-local.sh to bootstrap the local stack first"
  exec "$SETUP_SCRIPT"
}

sidecar_enabled() {
  [[ -f "$ENV_FILE" ]] && grep -Eq '^COMPOSE_PROFILES=.*(^|,)perplexity(,|$)|^COMPOSE_PROFILES=perplexity$' "$ENV_FILE"
}

compose_has_service() {
  docker compose -f "$COMPOSE_FILE" config --services |
    grep -Fxq "$1"
}

build_services() {
  local services=()

  case "$MODE" in
    both)
      services+=(cliproxyapi dashboard)
      ;;
    proxy)
      services+=(cliproxyapi)
      ;;
    dashboard)
      services+=(dashboard)
      ;;
  esac

  if [[ "$MODE" != "proxy" ]] && compose_has_service usage-collector; then
    services+=(usage-collector)
  fi

  if [[ "$WITH_SIDECAR" -eq 1 ]]; then
    services+=(perplexity-sidecar)
  fi

  printf '%s\n' "${services[@]}"
}

compose_pull() {
  local requested=("$@")
  local pullable=()
  local service

  for service in "${requested[@]}"; do
    case "$service" in
      cliproxyapi|usage-collector)
        pullable+=("$service")
        ;;
      dashboard|perplexity-sidecar)
        log_info "$service is built from local source; skipping image pull"
        ;;
    esac
  done

  if [[ "${#pullable[@]}" -gt 0 ]]; then
    log_info "Pulling images: ${pullable[*]}"
    docker compose -f "$COMPOSE_FILE" pull "${pullable[@]}"
  fi
}

compose_up() {
  local services=("$@")

  log_info "Building and recreating containers: ${services[*]}"

  docker compose -f "$COMPOSE_FILE" up -d \
    --build \
    --force-recreate \
    --no-deps \
    "${services[@]}"
}

show_status() {
  docker compose -f "$COMPOSE_FILE" ps
}

main() {
  ensure_docker
  ensure_repo_root

  if [[ "$SHOW_STATUS" -eq 1 ]]; then
    show_status
    exit 0
  fi

  bootstrap_if_needed

  log_info "Updating repository source"
  git -C "$SCRIPT_DIR" pull --ff-only

  mapfile -t services < <(build_services)

  if [[ "$WITH_SIDECAR" -eq 1 ]] && ! sidecar_enabled; then
    log_warning "--with-sidecar was requested, but COMPOSE_PROFILES=perplexity is not enabled in .env"
    log_warning "Continuing anyway; compose will skip the sidecar if the profile is disabled"
  fi

  compose_pull "${services[@]}"

  if [[ "$PULL_ONLY" -eq 0 ]]; then
    compose_up "${services[@]}"
  fi

  log_success "Update complete"
  show_status
}

main