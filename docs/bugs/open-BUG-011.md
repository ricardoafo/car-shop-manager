---
id: BUG-011
title: Some footer links/buttons do not navigate
severity: medium
status: open
filed: 2026-04-25
filed-by: manual
branch: fix/BUG-011-footer-dead-links
---

## Summary

Footer links across two columns ("Servicios" and "Taller") point to anchors that either no longer exist or were never wired. Specifically:

- **Servicios column** (`Footer.tsx:22–27`) — every link is `href="#servicios"`. This anchors to the ServiceGrid section but loses the user's intent (clicking "Aire acondicionado" should land them with that service highlighted or pre-selected; today it just scrolls to the grid). Several of these labels also alias to missing catalog IDs — see BUG-013.
- **Taller column** (`Footer.tsx:33–35`) — `Sobre nosotros`, `Cómo trabajamos`, `Visítanos` all use `href="#nosotros"` / `#visitanos` anchors. Those sections **do not exist** on the homepage. Click does nothing.
- **Legal column** (`Footer.tsx:41–44`) — these likely resolve (`/aviso-legal`, `/politica-de-privacidad`, `/politica-de-cookies`, `/reclamaciones`). Verify in fix.

User impact: dead links break trust. Legal pages MUST be reachable for LOPDGDD/LSSI-CE compliance.

## Proposed fix — placeholder pages following design v2

User-approved approach: create real pages for the three Taller links with placeholder copy + final design treatment, so the IA stays consistent and the pages can be filled in iteratively. Routes:

- `/sobre-nosotros` — story since 1987, Andrés as founder, Cartagena heritage. Hero + TrustStrip + CTA → chat
- `/como-trabajamos` — process: diagnóstico → presupuesto transparente → reparación → garantía 3 meses / 2.000 km. Step cards + IVA-transparency callout
- `/visitanos` — address card, Google Maps embed, hours table, WhatsApp CTA, parking note

All three pages use the same design system: glass-strong sticky header, hero pattern (grid-bg + noise + blob), section eyebrows in mono, sentence case, `tú` voice, middle-dot separators, lucide icons only, no emoji in chrome. See `tmp/design-spec/project/README.md` and `src/app/globals.css` for tokens.

For the Servicios column — change anchors to deep-link the chatbot via `rbr:open-chat` CustomEvent with `serviceId`, so clicking "Frenos" opens the chat pre-filtered. This requires BUG-013 fix landed first (catalog alignment).

## Steps to Reproduce

1. Open tst homepage
2. Scroll to footer
3. Click each footer link/button in turn
4. Note which ones do nothing or 404

## Expected Behaviour

Every footer link navigates to a real page. Legal pages (privacidad, cookies, aviso legal, condiciones) MUST exist and load.

## Actual Behaviour

Some links are dead — exact list to be filled in by QA pass.

## Files affected (likely)

- `src/core/components/Footer.tsx` (or equivalent)
- Missing `src/app/(legal)/*/page.tsx` routes
- Possibly anchor-only links to sections that no longer exist after the v2 redesign

## Root Cause Analysis

_Filled by implementer after audit._ Hypothesis: footer was migrated during v2 redesign but routes / anchor targets were not updated.

## Fix

_Filled by implementer after fix._

## Verification

- [ ] Every footer href resolves to 200 (Playwright `global-ctas.spec.ts` extended to assert this)
- [ ] All 4 legal pages exist and render
- [ ] `/sobre-nosotros`, `/como-trabajamos`, `/visitanos` exist with design-v2 layout
- [ ] No `href="#"` or anchor-to-missing-section links in footer
- [ ] Servicios links open chat with correct `serviceId` payload (depends on BUG-013)
- [ ] FEAT-032 `global-ctas.spec.ts` extended to cover all footer links by `data-testid`
- [ ] Manual click-through passes
- [ ] Lighthouse accessibility on each new page ≥ 95
