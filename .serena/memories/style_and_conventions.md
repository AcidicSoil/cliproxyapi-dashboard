# Style and Conventions

## Language and typing
- TypeScript is configured with `strict: true`.
- Path alias `@/*` maps to `dashboard/src/*`.
- The codebase uses explicit TypeScript types for props, return structures, and state where helpful.
- React prop objects are often typed inline; example pattern: `Readonly<{ children: React.ReactNode; }>`.

## Framework conventions
- Next.js App Router structure under `src/app/`.
- API endpoints live in `src/app/api/**/route.ts` and export HTTP verb functions like `GET`, `POST`, etc.
- Shared/server logic is factored into `src/lib/**` instead of bloating route handlers.
- Components live in `src/components/**`; hooks live in `src/hooks/**`.

## Formatting and code style
- ESM imports with double quotes.
- Semicolons are used consistently.
- Naming is clear and descriptive; filenames often use kebab-case, while React component/function names use PascalCase.
- Utility/helper functions use camelCase.
- Prisma models use PascalCase singular model names.
- Tailwind utility classes are used directly in JSX.
- Code tends toward small helper functions, early returns, and explicit status objects rather than clever abstractions.

## Linting/test conventions
- ESLint uses Next `core-web-vitals` and TypeScript recommended config.
- Vitest is configured with `globals: true` and `environment: "node"`.

## Repo/process conventions
- Conventional Commits are expected (`feat:`, `fix:`, `chore:`, etc.).
- Prefer following existing app/lib/component placement rather than creating new top-level patterns.
- When touching Prisma schema or DB-related code, expect to regenerate the client and verify migrations.

## Practical editing guidance
- For UI work, inspect existing components in `src/components/**` and keep naming/prop patterns aligned.
- For API work, keep route handlers thin and push reusable logic into `src/lib/**`.
- For data model changes, update `prisma/schema.prisma`, handle migrations, and keep generated client expectations in sync.
