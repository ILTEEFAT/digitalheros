# Business Rules

## Scores

1.  Stableford score is an integer 1--45 inclusive.
2.  Each score requires a score date.
3.  A user may have only one score for a given date.
4.  A duplicate date is an update/delete case, not a second score.
5.  Keep at most the five most recent scores per user.
6.  When a sixth/newer score is added, remove the oldest stored score.
7.  Return scores newest first.
8.  Scores are the source of a user's monthly draw entry: the five
    retained score values, in chronological order, form the entry. This
    is an explicit implementation decision because the PRD does not
    define the transformation.
9.  Duplicate Stableford values across different dates are allowed.
    Matching is count-based against the drawn distinct numbers, so a
    repeated value cannot match the same drawn number twice.

## Draw

1.  Draws run monthly.
2.  A draw contains five distinct integers from 1--45.
3.  Modes: RANDOM and ALGORITHMIC.
4.  Random mode samples five distinct numbers uniformly from 1--45.
5.  Algorithmic mode weights candidate numbers by their frequency across
    eligible users' five retained score values, then samples five
    distinct numbers without replacement. A small uniform floor is
    applied so a number with zero frequency remains possible.
6.  Admin can simulate before publishing.
7.  Simulation does not create a published result, winners, or payout
    obligations.
8.  Only an administrator can publish a draw.
9.  Eligibility is evaluated at publication time: subscriber must have
    an active application subscription and five retained scores. This
    five-score requirement is a project decision because the PRD says
    users enter their last five scores but does not specify
    partial-entry eligibility.
10. A published draw is immutable except through an explicit admin
    correction path recorded in audit data.

## Matching

For each eligible entry, compare its five score values with the five
distinct drawn numbers. Each drawn number can match at most once. Match
count is 0--5. - 5 matches → jackpot tier - 4 matches → second tier - 3
matches → third tier Winners are determined from the published draw and
frozen entries.

## Prize pool

The PRD says a fixed portion of each subscription contributes to the
prize pool, but does not specify the portion. Decision: use an
admin-configurable `prize_pool_percentage` setting, default 50%, clearly
displayed in admin settings. It can be changed only for future draws; a
published draw stores the actual pool amount used. Tier shares are
fixed: - 5-match: 40% - 4-match: 35% - 3-match: 25% If multiple winners
exist in a tier, split that tier equally. Unclaimed 5-match amount rolls
into the next draw's 5-match jackpot. Unclaimed 4/3 tiers do not roll
over.

## Subscription

- Plans: monthly and yearly.
- Stripe test mode handles checkout and lifecycle events.
- Application access is based on synchronized application status.
- Active = access allowed.
- Cancelled remains active until the paid period ends, then becomes
  lapsed/inactive.
- Lapsed/inactive users cannot enter new draws or use subscriber-only
  features.
- Renewal extends the current period based on Stripe webhook data.
- Backend checks current application subscription state on protected
  subscriber requests; Stripe webhooks are the authoritative
  synchronization mechanism.

## Charity

1.  User selects one charity at signup/subscription setup.
2.  Minimum contribution is 10% of the subscription fee.
3.  User may choose a higher percentage, capped at 100%.
4.  Store the percentage with the subscription so historical
    subscriptions remain auditable.
5.  Independent donations are represented as separate donation records
    and are not tied to draw participation.
6.  Charity directory supports search/filter.
7.  Charity profile includes description, image(s), and upcoming events.

## Winners

1.  Verification applies only to winners.
2.  Winner uploads screenshot/proof of scores from the golf platform.
3.  Admin approves or rejects.
4.  Payout state starts Pending and moves to Paid only after admin marks
    it paid.
5.  Rejection must include a reason.
6.  Proof files are private and accessed through signed URLs.

## Authorization

- Public endpoints are open.
- Authenticated user endpoints require a valid Supabase JWT.
- Admin endpoints require role=ADMIN, enforced server-side.
- Subscriber-only endpoints require authenticated user + active
  subscription where the operation needs it.
