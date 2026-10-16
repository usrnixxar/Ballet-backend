# Ballet Backend — Independent Polling Platform

## Live admin deployment (October 2026)
The production admin panel is at https://ballet-backend.vercel.app/admin.
Admin email/password and JWT signing key must be stored only as private Vercel environment variables.
The production deployment can read and edit the **Ballot Paper** Supabase database using a
private, server-to-server Supabase Edge Function named `ballot-admin-bridge`.

When `BALLOT_ADMIN_BRIDGE_URL`, `BALLOT_ADMIN_BRIDGE_KEY` and `SUPABASE_ANON_JWT` are set,
the admin panel works **without** `DATABASE_URL`; the Edge Function uses its server-side
Supabase credentials to read protected tables. Neither the signing key nor bridge token is
ever included in the browser or committed to GitHub.

Use `/api/health` to inspect nonsecret setup and connectivity flags (`bridgeConnected`).
The `/api/admin/*` dashboard data routes require the HTTP-only admin session.

**Important:** The current `ballet-paper-live` public frontend uses its own direct
Supabase polling RPCs, not this backend's email-OTP endpoints. The direct frontend mode
uses self-reported DOB and an unverified email. Treat it as an **unofficial public
opinion demo**, not identity-verified or official election voting.

Separate Express/PostgreSQL backend and responsive admin panel for [Ballot-Paper](https://github.com/usrnixxar/Ballot-Paper).

## Security and scope
This is an independent, unofficial public-opinion poll — **not** an official election portal. Never advertise it as an Election Commission website.

* Admin login is server-side with a bcrypt-hashed password, HTTP-only session cookie and JWT expiry. Set admin username (email) and password in private environment settings. Never commit credentials.
* Public votes require verified email OTP, age >=18 and one successful vote per email. Identity verification is not provided: someone can still control multiple emails, so this is not secure for regulated elections.
* Public APIs expose only aggregate results and candidate symbols, never voter names/emails or DOB.
* The dashboard exposes private data only to authenticated admins. Handle personal information transparently with a privacy notice, retention limits and an appropriate legal basis.
* Visitors are approximate anonymous browser-session counts. Do not treat them as verified unique humans.

## Deployment prerequisites
1. Provision a NEW PostgreSQL database, not the unrelated SkillType production database.
2. Run `schema.sql` against it.
3. Configure all environment variables from `.env.example` on your API host; use a separate strong `JWT_SECRET`.
4. Configure SMTP for OTP verification. Without SMTP, real voting returns a configuration error and does not accept unverified votes.
5. Run `npm install && npm start` on a persistent Node host.
6. Admin interface is served from `/admin` on the same API origin. Log in with the private ADMIN_USERNAME/ADMIN_PASSWORD environment values.
7. Configure frontend `VITE_API_URL` to the HTTPS API origin to switch from demo data to this backend (frontend integration in the Ballot-Paper repo).
8. Keep HTTPS enabled. No service-role/database secrets in client-side code.

Local `npm install && npm run dev` works after configuring `.env` and database.

### API routes
GET /api/health
GET /api/public/candidates
GET /api/public/results
POST /api/visit
POST /api/vote/request-code
POST /api/vote/confirm
POST /api/admin/login
POST /api/admin/logout
GET /api/admin/me
GET /api/admin/stats
GET /api/admin/votes (private)
PUT /api/admin/candidates/:id
POST /api/admin/candidates/:id/image (base64-encoded PNG/JPEG/WebP, capped)
DELETE /api/admin/candidates/:id/image

The candidate image endpoint returns a public image resource, keeping public data independent from internal database rows.

## Admin ID / password configuration
Use a private environment variable `ADMIN_USERNAME=bjp` and set `ADMIN_PASSWORD` as a **sensitive** environment variable in the backend host. Do not commit the actual password or store it in frontend code. `ADMIN_EMAIL` can be used instead for an email login identifier if `ADMIN_USERNAME` is not supplied. Admin sign-in is mandatory for private dashboard APIs.

## Music Manager
The authenticated `/admin` dashboard includes a background music volume slider (0–100%), a player preview and a private audio upload form. The volume is stored in the Supabase `poll_audio_settings` table through the protected `ballot-admin-bridge` function. The public frontend polls `poll_audio_config()` every 30 seconds and adjusts playback volume without affecting the stamp sound.

To activate uploading from the panel straight into the **ballet-paper-live** GitHub repository, create a fine-grained GitHub personal access token (not a classic all-repos token) with **Contents: Read and write** limited to `usrnixxar/ballet-paper-live`. Add it as `BALLOT_GITHUB_CONTENTS_TOKEN` to the **backend** Vercel project's encrypted Production environment variables and redeploy. Never paste this token in chat, commit it, or expose it to frontend JS. The server verifies admin login and validates file size (max 2 MB) and MP3/M4A/OGG/WAV magic bytes before it calls GitHub Contents API to publish `public/audio/background.<extension>`. The GitHub main-branch commit starts Vercel's frontend Git deployment if its integration is enabled, and audio is live after deployment finishes. The settings API updates the selected track for visitors.

Music playback still follows browser autoplay rules: browsers can require a visitor to tap before sound plays. The upload action returns an explicit configuration error until the private token is supplied.
