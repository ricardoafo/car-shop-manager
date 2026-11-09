# Car Shop Manager

A multi-tenant website and back office for small car repair workshops in Spain.
Each workshop (tenant) gets a public site with services, prices and online booking,
a guided chatbot for quotes and appointments, and an admin area for the day's work,
calendar, customers, vehicles and quotes. It follows Spanish consumer and privacy
rules (cookie consent, legal pages, IVA-inclusive prices).

**Who it is for:** independent workshop owners who want online booking and a simple
back office without a big monthly bill. It is a personal project, built and run by
the repository owner.

**Status:** working prototype with one demo tenant in `clients/`. Planned work is in
[ROADMAP.md](ROADMAP.md) and the specs under [`docs/specs/`](docs/specs/).

## Stack

- **Next.js 16** (App Router, Server Components) · **React 19**
- **PocketBase** (self-hosted backend + real-time DB)
- **Tailwind v4** (CSS-first design tokens)
- **TypeScript strict** · **Zod** · **Vitest** · **Playwright**

## Local development

Requires Node 24 (see `.nvmrc`) and the PocketBase binary in the repo root
(`scripts/setup-pocketbase.sh` downloads it).

```bash
cp .env.example .env.local   # demo tenant: talleres-ribera
npm install
npm run hooks:install # Activate .githooks (pre-commit + pre-push)
npm run pb:serve      # PocketBase at :8090
npm run dev           # Next.js at :3000
```

## Commands

```bash
npm run type-check    # TypeScript — must exit 0 before commit
npm test              # Vitest unit tests
npm run lint          # ESLint
npm run flows:validate # Validate chatbot_flow.json files
npm run e2e           # Playwright E2E (requires dev server)
npm run build         # schemas:sync + next build (local)
npm run build:docker  # next build only (used in Dockerfile)
```

## Deployment

- See [`docs/infra/runbook.md`](docs/infra/runbook.md) for first-deploy, secret rotation, rollback, and disaster recovery.
- See [`docs/infra/github-setup.md`](docs/infra/github-setup.md) for required GitHub Actions secrets and branch protection rules.
- Push to `main` → auto-deploy to `tst.<your-domain>` via GitHub Actions.

## Multi-tenant architecture

Every PocketBase collection includes a `tenant_id` field. All queries are scoped to the tenant context — no cross-tenant data access is possible at the application layer. PocketBase collection rules enforce the same isolation at the DB layer as a second line of defense.

## License

MIT, see [LICENSE](LICENSE).
