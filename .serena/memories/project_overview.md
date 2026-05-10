# CLIProxyAPI Dashboard — Project Overview

## Purpose
CLIProxyAPI Dashboard is a web UI for managing CLIProxyAPIPlus, which exposes several OAuth-based CLI tools (Claude Code, Gemini CLI, Codex, Copilot, Kiro, Kimi, Qwen, etc.) as OpenAI-compatible APIs. The dashboard handles provider setup, API keys, config management, monitoring, usage analytics, updates, and container operations.

## High-level architecture
The repo contains a full Dockerized stack built around six services:
- Caddy reverse proxy with automatic TLS
- Dashboard web app
- CLIProxyAPIPlus proxy server
- Perplexity sidecar
- Docker socket proxy
- PostgreSQL

## Tech stack
- Frontend/app framework: Next.js 16 App Router
- UI: React 19
- Language: TypeScript 5.9 (strict mode enabled)
- Styling: Tailwind CSS v4
- Database: PostgreSQL 16
- ORM: Prisma 7
- Auth: JWT with `jose`, password hashing with `bcrypt`
- Charts/data viz: `recharts`
- Validation: `zod`
- Logging: `pino`, `pino-pretty`
- Testing: Vitest 4
- Linting: ESLint 10 with Next core-web-vitals + TypeScript config

## Rough codebase structure
- `dashboard/` — main Next.js application
  - `src/app/` — App Router pages and API routes
  - `src/components/` — UI and feature components
  - `src/lib/` — server/shared utilities (auth, db, containers, logging, validation, config sync, API keys, providers)
  - `src/hooks/` — React hooks
  - `src/scripts/` — project scripts in TS
  - `prisma/` — Prisma schema and migrations
- `docs/` — installation, configuration, troubleshooting, security, backups, service management, runbooks
- `infrastructure/` — deployment scripts, compose files, webhook config, helper scripts
- `scripts/` — additional repo-level scripts
- `perplexity-sidecar/` — Perplexity wrapper service

## Operational model
Local development primarily happens in `dashboard/` with a Docker-based helper script (`dev-local.sh`) that starts PostgreSQL + API dependencies, runs Prisma bootstrapping/migrations, generates the Prisma client, writes `.env.local`, and then launches Next dev server.

Production/server setup is managed from the repo root with shell scripts such as `install.sh`, `setup-local.sh`, `rebuild.sh`, and infrastructure scripts under `infrastructure/`.
