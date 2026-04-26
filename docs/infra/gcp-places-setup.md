# Runbook · Google Places (New) API setup for live reviews

This is the one-time setup the workshop owner (or admin) does before FEAT-040 can ship. It costs **0 €** as long as we stay inside the $200/month free credit (≈11,700 Place Details calls per month — we'll use ~900). A budget alarm protects us from accidental overage.

**Estimated time:** 20 minutes.
**Who runs it:** the user (`ricardoafo`). Bot account does not have GCP scopes.

---

## 1 · Create the GCP project

1. Go to <https://console.cloud.google.com/projectcreate>.
2. Project name: `rbr-talleres-reviews` (or any short slug; this is internal).
3. Organization: leave default (no org needed).
4. Billing account: link an existing one or create a new one (you must enter a card, but you will not be charged unless you exceed the $200 credit).
5. Click **Create**. Wait ~30 seconds.

## 2 · Enable the API

1. With the new project selected, go to <https://console.cloud.google.com/apis/library/places-backend.googleapis.com>.
2. Click **Enable**. Wait for the spinner.
3. **Important:** enable **Places API (New)**, not the legacy "Places API". The new one is what `fetchPlaceReviews` uses.

## 3 · Create a restricted API key

1. Navigate to <https://console.cloud.google.com/apis/credentials>.
2. Click **+ Create credentials → API key**.
3. Copy the generated key. This is what becomes `GOOGLE_PLACES_API_KEY` in our env.
4. Click the new key to open the restriction panel:
   - **Application restrictions:** *None* (we call from a server, not from a browser; IP restriction can be added later when we know the VPS egress IP).
   - **API restrictions:** *Restrict key* → enable only **Places API (New)**.
5. Click **Save**.

## 4 · Set the budget alarm

1. Go to <https://console.cloud.google.com/billing>.
2. Select the billing account linked to the project.
3. **Budgets & alerts → Create budget**.
4. Configure:
   - Name: `rbr-talleres-reviews-budget`
   - Project scope: only the new project.
   - Budget type: *Specified amount*.
   - Amount: **50 €** (intentionally below the $200 free credit so we get warned long before hitting the limit).
   - Threshold rules: alert at **50 %**, **90 %**, **100 %** of actual spend.
   - Email recipients: the workshop owner's email + `owner@example.com`.
5. **Save**.

## 5 · Get the workshop's Place ID

1. Open <https://developers.google.com/maps/documentation/places/web-service/place-id>.
2. In the page's "Find ID for a place" tool, search for the workshop name + city: `Talleres Ribera Murcia` (adjust per tenant).
3. Confirm the result on the map matches the actual workshop.
4. Copy the **Place ID** (looks like `ChIJN1t_tDeuEmsRUsoyG83frY4`).
5. Save it — you'll paste it into the tenant config in step 6.

## 6 · Wire it into the project

This step happens **after** the FEAT-040 PR is opened. The PR modifies these files; you only need to provide the values.

### 6a · Add the place ID to the tenant config

In `clients/talleres-ribera/config.json`, the FEAT-040 PR will add:

```json
{
  "business": {
    "googlePlaceId": "PASTE_PLACE_ID_HERE"
  }
}
```

Replace the placeholder with the Place ID you copied in step 5.

### 6b · Store the API key as a GitHub secret

```sh
gh secret set GOOGLE_PLACES_API_KEY --repo ricardoafo/car-shop-manager
# Paste the API key when prompted.
```

This makes it available to the deploy workflow (`deploy-tst.yml`) and any future pro-deploy.

### 6c · Set the API key on the VPS

SSH into the VPS:

```sh
ssh deploy@<vps-host>
echo 'GOOGLE_PLACES_API_KEY=<paste-key-here>' >> /home/deploy/car-shop-manager.env
docker compose --env-file /home/deploy/car-shop-manager.env up -d
```

The compose file already passes `GOOGLE_PLACES_API_KEY` through to the container as an env var (the FEAT-040 PR will add this).

## 7 · Smoke-test before merging the PR

After the FEAT-040 PR is opened but before merge:

1. Pull the branch locally.
2. `cp .env.example .env.local` and fill in `GOOGLE_PLACES_API_KEY` with the real key.
3. `npm run dev`.
4. Visit `http://localhost:3000/`.
5. Confirm the testimonials section shows real Google reviews (rating, review count, review cards).
6. Open DevTools → Network. Refresh the page. Confirm **no** call to `places.googleapis.com` from the browser (server-side only).
7. Server log should show one fetch on first load and zero on subsequent reloads within 24 h (cache hit).

## 8 · Post-merge verification

Once the FEAT-040 PR merges and tst deploys:

1. Open `https://tst.203-0-113-10.sslip.io/`.
2. Reviews render with current data.
3. In the GCP Maps Platform metrics dashboard, confirm one Place Details call was made.
4. Wait 24 hours and re-check — there should be one new call (cache expired, refetch). No more.

## 9 · Reverting / disabling

If something goes wrong:

1. **Disable the key**: GCP Console → APIs & Services → Credentials → click the key → **Disable**.
2. The site falls back to the static testimonials block automatically (per FEAT-040 spec acceptance criterion 4).
3. No data loss — the cache is server-side and ephemeral.

---

## What you don't have to do

- **Domain verification.** Not required for server-side Place Details calls.
- **OAuth.** Not required — API key auth is sufficient for this read-only public-data endpoint.
- **Quota requests.** We're far inside default quotas.

## When this runbook stops being free

If the workshop scales to 100 tenants on the same GCP project, monthly cost would be ~30 calls × 100 tenants × 30 days × $0.017 = ~$1,530 — well over the $200 credit. At that point: split per tenant, raise the budget alarm, or move to a paid plan with bulk pricing.
