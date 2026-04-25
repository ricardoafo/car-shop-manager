# FEAT-033 · Full Claude Design v2 bundle alignment

**Status:** in progress
**Sprint:** 8 — Design Alignment + UX Polish
**Branch:** `feature/FEAT-033-bundle-full-alignment`
**Bundle source of truth:** `C:/Users/rafon/Downloads/Talleres Ribera Design System-handoff/talleres-ribera-design-system/project/`

## Context

FEAT-028 was a partial alignment: it swapped the logo/favicon and added a Visit section. It did **not** rebuild the customer-facing surfaces against the canonical bundle. User flagged that the chatbot is still old, "Tu taller de confianza, sin sobresaltos." headline is missing, ITV calculator is the old design, stock images are missing, and many surfaces drift from the bundle.

FEAT-033 closes that gap in a single PR.

## Source files (read for ground truth)

- `ui_kits/website/Website.html` — canonical homepage markup + microcopy
- `ui_kits/website/website.css` — canonical CSS classes
- `ui_kits/website/flow-a-booking.jsx` — canonical chatbot UI (greeting, chips, cards, ConfirmCard SVG)
- `ui_kits/website/Motion Playground.html` — canonical motion specs (Tier 1/2/3)
- `colors_and_type.css` — tokens (already aligned in `src/app/globals.css`)

## Scope · 8 surfaces

### A. Hero (`src/core/components/Hero.tsx`)
- Headline: **"Tu taller de confianza, sin sobresaltos."** with `.under` red underline draw on "taller" (Motion #05, 520ms outExpo)
- Eyebrow: **"Cartagena · Desde 1987"** with tri-stripe reveal (Motion #06, 260ms · 80ms stagger)
- Lead copy: full 38-year passage from bundle line 41–46
- Right column: `.hero-photo` (4:5 aspect) with Unsplash mechanic image, `.hero-photo-badge` rotate(4deg) **DESDE 1987**, `.hero-photo-caption` blur backdrop with pulsing dot **"3 mecánicos trabajando ahora"**
- 3-icon meta row replacing pill stamps (open hours, calle, garantía)
- Header nav update: add **"El taller"** link + phone CTA

### B. TrustStrip (`src/core/components/TrustStrip.tsx`)
- 4-column grid (`grid-template-columns: repeat(4, 1fr)`)
- Brand-tinted icons rotating by `nth-child` (lightblue / darkblue / amber / red-muted)
- Big numerals (font 700 20px): **38 años**, **12 400**, **4,9 / 5**, **3 meses**
- Counters animate in viewport (Motion #01, 720ms outExpo)

### C. ServiceGrid (`src/core/components/ServiceGrid.tsx`)
- Eyebrow **"Nuestros servicios"**
- Headline: **"Precios claros. Garantía clara. Trabajo claro."**
- "Ver todos →" link top-right
- `.svc-card::before` tri-stripe (lightblue/darkblue/red gradient, top accent, scaleX(0)→scaleX(1) on hover)
- `.svc-card:hover .svc-icon` background flip to `var(--primary)`
- `svc-price` font-mono
- Stagger-in (Motion #04, 220ms · 60ms · `viewport once`)

### D. ItvCountdown (`src/core/components/ItvCountdown.tsx`)
- Full-bleed `.itv-wrap` red (`background: var(--primary)`, `color: var(--primary-fg)`, `border-radius-xl`, dotted radial `::after` overlay)
- 2-col grid:
  - **Left:** eyebrow **"ITV a la vista"**, h2 **"¿Te toca la ITV? La pasamos nosotros."**, 2 CTAs (Calcular cuándo / Reservar pre-ITV)
  - **Right:** `.itv-calc` white card, padding 28px, shadow-dialog: Matrícula + Última ITV + Tipo de vehículo fields → `.itv-result` warning-muted box with 36px big number
- "Avísame cuando queden 30 días" CTA
- Fire chatbot pre-fill on click via `rbr:open-chat` event with `serviceId: 'pre-itv'` + plate
- Tween (Motion #02, 320ms outExpo) — number crosses to red below 30 days

### E. VisitSection (`src/core/components/VisitSection.tsx`)
- 2-col grid `1.2fr 1fr`
- Left: `.visit-photo` (min-height 360px) Unsplash workshop photo
- Right info column with hairline rows:
  - Headline **"Calle Mayor 42 · a dos pasos del Ayuntamiento."**
  - Subtext **"respondemos en 15 min en horario laboral"**
  - Hours / phone / direcciones rows separated by `.rule`

### F. Testimonials (`src/core/components/Testimonials.tsx`)
- **REPLACE** carousel with 3-card grid (`testi-grid`)
- Eyebrow **"Lo que dicen los vecinos"**, headline **"38 años en el barrio no se inventan."**
- 3 cards (María González/Golf V, Javier Sánchez/Transit, Carmen Martín/Clio IV) — full bundle copy
- `.testi-avatar` 36×36 with rotated brand tints by `nth-child`

### G. Footer (`src/core/components/Footer.tsx`)
- 4-column grid `1.4fr 1fr 1fr 1fr`: brand+description, Servicios, Taller, Legal
- Background `var(--brand-ink)` with tri-stripe `::before` top
- Bottom bar: **"© 2026 Talleres Ribera S.L. · CIF B30123456 · Reg. Taller 30/456"** + **"Hecho con cariño en Cartagena"**
- Remove `CommitSha` from public footer

### H. Chatbot UI overhaul
Files:
- `src/core/components/ChatWidget.tsx` (header + shell)
- `src/core/chatbot/ChatEngine.tsx` (existing, preserve `initialService` prop wiring from FEAT-029)
- New: `src/core/chatbot/components/VehicleCard.tsx`, `SummaryCard.tsx`, `ConfirmCard.tsx`, `BookingStepper.tsx`

Shell:
- AM avatar circle 38×38 `var(--primary)` white text
- "Andrés · Talleres Ribera" header, subtitle **"Respondemos en < 15 min"** with green pulse dot
- `chat-body` background `var(--muted)`
- Bubble shape `border-radius: 16px 16px 16px 4px` / reversed corners for user
- Privacy footer **"Seguro · RGPD · no compartimos tus datos"** in mono

5-step BookingStepper:
1. **Vehículo** — VehicleCard (plate confirmation Sí/No)
2. **Servicios** — chips
3. **Hueco** — 3 slot chips + "Ver más huecos…"
4. **Datos** — name + email + LOPDGDD checkbox
5. **Revisar** — SummaryCard + Confirmar cita

ConfirmCard: SVG circle + polyline tick with WAAPI strokeDasharray animation (Motion #10, 600ms 2-stage). Use `MOTION.checkDraw.circle` then `MOTION.checkDraw.tick`.

Greeting: **"¡Hola! Soy Andrés 👋 ¿Qué le pasa a tu coche?"** — chips: Cambio de aceite / Ruido al frenar / Pre-ITV / Otra cosa…

Chip stagger Motion #08 (180ms · 50ms). Use `MOTION.chip` + `MOTION.chipStagger`.

## Globals.css additions (orchestrator handles inline before agents dispatch)

New utility classes (lifted from `website.css`):
- `.hero-photo`, `.hero-photo-badge`, `.hero-photo-caption`
- `.itv-wrap`, `.itv-calc`, `.itv-result`, `.itv-field`
- `.testi-grid`, `.testi-avatar`
- `.visit`, `.visit-photo`
- `.ftr`, `.ftr-inner`, `.ftr a` styling
- `.chat-avatar`, `.chat-body`, `.bub` (+ `.bub.user`), `.chat-chip`
- `.svc-card::before` tri-stripe accent + hover scaleX
- `.trust-inner`, `.trust-cell`, `.trust-num`, `.trust-icon` nth-child rotation

All use existing tokens (`--primary`, `--muted`, `--border-strong`, `--shadow-lg`, `--brand-ink`, `--brand-m-lightblue`, `--brand-m-darkblue`, `--brand-amber`, `--dur-*`, `--ease-*`).

## Motion preset usage (already in `src/lib/motion.ts`)

| Surface | Preset |
|---|---|
| Hero underline | `MOTION.underlineDraw` |
| Hero eyebrow stripes | `MOTION.stripesReveal` + `stripesRevealStagger` |
| TrustStrip counters | `MOTION.counter` |
| ServiceGrid cards | `MOTION.serviceCard` + `serviceGridStagger` |
| ItvCountdown number | `MOTION.itvTween` |
| Chat bubble | `MOTION.chatMessage` |
| Chat chips | `MOTION.chip` + `chipStagger` |
| Booking step | `MOTION.flowStep` |
| ConfirmCard | `MOTION.checkDraw.circle` + `MOTION.checkDraw.tick` |
| Pulse dots | `MOTION.pulseDot` |

## Acceptance

- All 8 surfaces match `Website.html` markup + microcopy + motion
- `npm run type-check` zero errors
- `npm test` all green (TrustStrip + motion preset tests update if needed)
- compliance-reviewer: zero violations (no hardcoded HSL/hex, all tokens semantic)
- E2E: existing chatbot-preselect spec still passes
- Manual: golden path booking flow → ConfirmCard SVG draw fires
- Reduced-motion respected on all new motions

## Dispatch plan

4 parallel implementer agents (sonnet model):
- **Agent A** — Hero.tsx + TrustStrip.tsx (top of page, share header nav update)
- **Agent B** — ItvCountdown.tsx (red wrap rewrite + chatbot pre-fill handoff)
- **Agent C** — Testimonials.tsx + VisitSection.tsx + Footer.tsx + ServiceGrid.tsx
- **Agent D** — ChatWidget.tsx + ChatEngine.tsx + new VehicleCard / SummaryCard / ConfirmCard / BookingStepper

Orchestrator handles globals.css addition before dispatch to prevent merge conflicts.

## Out of scope

- FEAT-031 customer post-booking registration (separate PR)
- FEAT-032 E2E retrofit (separate PR)
- Tier 3 motions (button ripple, optimistic chat, scroll progress) — defer
