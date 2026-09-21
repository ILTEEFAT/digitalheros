# REST API Contract --- Frozen v1

Base: `/api` Auth: Supabase JWT in `Authorization: Bearer <token>`. All
protected endpoints return 401 when unauthenticated and 403 when
role/access is insufficient. JSON responses use `{ data, error }`.

## AUTH

Supabase Auth handles signup/login/logout. Express verifies JWTs. - POST
/auth/profile --- USER --- create/update application profile after
signup. - GET /auth/me --- AUTH --- current user, role, subscription
summary.

## USERS

- GET /users/me --- AUTH --- profile + current charity preference.
- PATCH /users/me --- AUTH --- update allowed profile fields.
- PATCH /users/me/charity --- ACTIVE SUBSCRIBER --- charity_id,
  percentage (10--100).

## SUBSCRIPTIONS

- GET /subscriptions/me --- AUTH --- current app subscription state.
- POST /subscriptions/checkout --- AUTH ---
  `{ plan, charityId, charityPercentage }`; returns Stripe Checkout
  URL.
- POST /subscriptions/cancel --- AUTH --- requests cancellation at
  period end.
- POST /webhooks/stripe --- PUBLIC STRIPE SIGNATURE --- synchronize
  Stripe events; no JWT.
- POST /donations/checkout --- AUTH --- independent donation
  `{ charityId, amount }`; test-mode flow.

## SCORES

- GET /scores --- ACTIVE SUBSCRIBER --- latest five, newest first.
- POST /scores --- ACTIVE SUBSCRIBER --- `{ score, scoreDate }`;
  validates 1--45, unique date, rolling five.
- PATCH /scores/:scoreId --- ACTIVE SUBSCRIBER ---
  `{ score, scoreDate }`; preserves one-date uniqueness.
- DELETE /scores/:scoreId --- ACTIVE SUBSCRIBER --- delete. Business
  errors: duplicate date, invalid score, score not owned by user.

## CHARITIES

- GET /charities --- PUBLIC --- search/filter/featured query params.
- GET /charities/:charityId --- PUBLIC --- profile + events.
- POST /charities --- ADMIN --- create.
- PATCH /charities/:charityId --- ADMIN --- edit.
- DELETE /charities/:charityId --- ADMIN --- soft-delete.
- POST /charities/:charityId/events --- ADMIN --- add event.
- PATCH /charities/:charityId/events/:eventId --- ADMIN.
- DELETE /charities/:charityId/events/:eventId --- ADMIN.

## DRAWS

- GET /draws --- PUBLIC --- published draw history.
- GET /draws/:drawId --- PUBLIC --- published result; admin may view
  draft/simulation.
- POST /admin/draws --- ADMIN --- `{ drawMonth, mode }`; create draft.
- POST /admin/draws/:drawId/simulate --- ADMIN --- optional
  seed/config; returns numbers, entry count, prize calculation,
  winners preview without persistence of payout obligations.
- POST /admin/draws/:drawId/publish --- ADMIN --- freezes eligible
  entries, calculates winners/prizes, persists result, applies jackpot
  rollover.
- GET /admin/draws/:drawId --- ADMIN --- full simulation/publish data.
- GET /admin/draws --- ADMIN --- management list.

## WINNERS

- GET /winners/me --- AUTH --- own winning records only.
- POST /winners/:winnerId/proof-upload --- WINNER OWNER --- returns
  signed upload target.
- POST /winners/:winnerId/proof-confirm --- WINNER OWNER --- confirm
  uploaded file.
- GET /admin/winners --- ADMIN --- all winners/filter status.
- POST /admin/winners/:winnerId/approve --- ADMIN --- approve verified
  proof.
- POST /admin/winners/:winnerId/reject --- ADMIN --- `{ reason }`.
- POST /admin/winners/:winnerId/mark-paid --- ADMIN --- mark payout
  Paid.

## ADMIN USERS

- GET /admin/users --- ADMIN --- list/search.
- GET /admin/users/:userId --- ADMIN --- user details.
- PATCH /admin/users/:userId --- ADMIN --- permitted profile edits.
- PATCH /admin/users/:userId/subscription --- ADMIN --- controlled
  application-state correction with audit log.

## REPORTS

- GET /admin/reports/overview --- ADMIN --- total users, total prize
  pool, charity contribution totals, draw statistics.

## Error shape

`{ data: null, error: { code, message, fields? } }`. Never expose Stripe
secrets, storage service-role credentials, or internal stack traces.

## Frozen endpoint rule

Other implementation chats must not rename/add domain endpoints without
updating this contract first.
