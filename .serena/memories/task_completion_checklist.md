# Task Completion Checklist

Before considering a code task done in this repo, use the relevant subset of checks below.

## For most dashboard code changes
Run from `dashboard/`:
- `npm run lint`
- `npm run test`
- `npm run build` for changes that could affect production bundling, routing, or typing across the app

## For Prisma / database changes
Also run:
- `npx prisma generate`
- appropriate migration command (`npx prisma migrate dev` for local dev work, or verify existing migrations with `npx prisma migrate deploy`)
- ensure any bootstrap/migration assumptions used by `dev-local.sh` still make sense

## For local environment/dev workflow changes
Also verify:
- `./dev-local.sh` still starts correctly
- `./dev-local.sh --down` / `--reset` behavior is still coherent if affected
- any changed environment variables or scripts are reflected in docs/examples when necessary

## For infrastructure/install script changes
Also verify as applicable:
- shell syntax and flag behavior
- referenced commands exist on supported Linux targets
- related docs in `docs/` or `infrastructure/` stay accurate

## Process expectations
- Follow existing file placement and naming conventions
- Keep API logic reusable by moving shared logic into `src/lib/**` where appropriate
- Use conventional commit style for commit messages
