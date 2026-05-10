# Suggested Commands

## General Linux utilities
- `ls`, `find`, `grep`, `cd`, `cat`, `sed`, `awk`
- `git status`, `git diff`, `git log`
- `docker ps`, `docker compose ...`, `docker exec ...`
- `ss`, `lsof`, `netstat` (used in install/preflight scripts)
- `curl` for health checks

## Repo root workflows
- `./setup-local.sh` — local stack setup from repo root
- `./rebuild.sh` — rebuild workflow
- `sudo ./install.sh` — production/server installation on Ubuntu/Debian
- `docker compose -f docker-compose.local.yml ...` — local stack orchestration from repo root

## Dashboard app development
Run from `dashboard/` unless noted otherwise.

### Main local dev workflow
- `./dev-local.sh` — start local Docker-backed development environment and Next.js dev server
- `./dev-local.sh --reset` — reset dev database/volumes
- `./dev-local.sh --down` — stop dev containers

### Manual app workflow
- `npm install`
- `cp .env.example .env.local`
- `npx prisma migrate dev`
- `npx prisma generate`
- `npm run dev`

### Validation / quality
- `npm run lint` — run ESLint
- `npm run test` — run Vitest once
- `npm run test:watch` — run Vitest in watch mode
- `npm run build` — production build verification

### Prisma / data tasks
- `npx prisma migrate dev` — create/apply local schema migrations during development
- `npx prisma migrate deploy` — apply existing migrations
- `npx prisma db push --accept-data-loss` — schema bootstrap path used by `dev-local.sh` for fresh DBs
- `npx prisma generate` — regenerate Prisma client
- `npm run migrate:provider-ownership` — run repo-specific TS migration script

## Runtime entrypoints
- Dashboard dev server: `npm run dev` in `dashboard/`
- Dashboard production server: `npm run build && npm run start`
- Local dashboard URL: `http://localhost:3000`
- Local proxy URL used by dev helper: `http://localhost:28317`
- Local PostgreSQL exposed by dev helper: `localhost:5433`
