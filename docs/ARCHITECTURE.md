# Architecture

## System diagram

```text
React + Vite
  ├─ Supabase Auth client ───────→ Supabase Auth
  │
  └─ REST/JSON ──────────────────→ Express API
                                      ├─ Auth middleware (JWT)
                                      ├─ Role/subscription middleware
                                      ├─ Controllers
                                      ├─ Services
                                      │    ├─ Score service
                                      │    ├─ Subscription service
                                      │    ├─ Charity service
                                      │    ├─ Draw service
                                      │    │    └─ Draw Engine
                                      │    ├─ Winner service
                                      │    └─ Report service
                                      ├─ Repositories
                                      └─ Validators
                                           │
                                           ├────────→ Supabase PostgreSQL
                                           ├────────→ Supabase Storage
                                           └────────→ Stripe TEST MODE
```

## Backend structure

```text
backend/
  src/
    routes/
    controllers/
    services/
    repositories/
    middleware/
    validators/
    drawEngine/
      randomDraw.ts
      weightedDraw.ts
      matchCalculator.ts
      prizeCalculator.ts
      winnerCalculator.ts
      rolloverCalculator.ts
    config/
    utils/
    app.ts
```

Controllers translate HTTP ↔ application calls. Services own business
rules. Repositories own persistence. Draw-engine functions are
pure/testable where possible.

## Authentication

Supabase Auth creates sessions/JWTs. Express validates the JWT and loads
the application profile. Admin authorization is enforced in backend
middleware. Frontend route guards are convenience only.

## Subscription access

Protected subscriber endpoints perform an application subscription
check. Stripe webhooks synchronize lifecycle changes. This avoids
trusting a frontend flag.

## Payment flow

Signup → charity + plan selection → create Stripe Checkout Session →
Stripe test checkout → webhook → update subscription → user returns to
app and sees synchronized status.

## Winner proof flow

Winner → request signed upload target → upload private file to Supabase
Storage → confirm metadata → admin gets signed view URL → approve/reject
→ payout remains Pending until marked Paid.

## Deployment

Frontend: new Vercel account. Backend: Render/equivalent.
Database/Auth/Storage: new Supabase project. Secrets only in deployment
environment variables.

## Scalability thinking

For this assignment, scale by clean boundaries rather than
infrastructure: - stateless Express API - indexed user/draw queries -
frozen draw-entry snapshots - database constraints for uniqueness - pure
draw engine - storage outside the API - webhook-driven subscription
synchronization
