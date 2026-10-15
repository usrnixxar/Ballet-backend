# Ballet Backend — Independent Polling Platform

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
6. Admin interface is served from `/admin` on the same API origin. Log in with the private ADMIN_EMAIL/ADMIN_PASSWORD environment values.
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
