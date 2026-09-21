# Feature Checklist / Traceability

---

PRD requirement Feature API DB UI Test

---

Signup/login Auth Supabase Auth + /auth/me auth.users/profiles Login/Signup signup/login

Monthly/yearly Checkout + /subscriptions/\* + subscriptions Pricing/Subscription both plans
subscription lifecycle Stripe webhook

Restricted subscription protected routes subscriptions gated screens inactive user
non-subscriber middleware  
 access

Five latest rolling score /scores scores Scores add 6th
scores service

One score/date unique POST/PATCH /scores unique(user,date) date validation duplicate
constraint +  
 service

Monthly draws draw lifecycle /admin/draws draws Admin draw screen simulation/publish

Random draw random engine simulate/publish draws Admin range/distinctness

Algorithmic draw weighted engine simulate/publish draws Admin frequency weighting

3/4/5 matches matcher publish draw_entries/winners Results match cases

Prize shares calculator publish prize_tiers Admin/results 40/35/25

Jackpot rollover rollover publish draws/prize_tiers Admin/results unclaimed 5-match
calculator

Equal split prize calculator publish winners Winners multiple winners

Charity charity /users/me/charity subscriptions Signup/Charity min 10%
selection preference

Charity search/filter /charities charities/events Charities filters
directory

Featured charity homepage /charities?featured charities Home featured
spotlight

Independent separate /donations/checkout donations Charity detail independent flow
donation donation

Winner proof upload/review /winners/\* winner_proofs Winnings/Admin approve/reject

Payout tracking Pending→Paid admin winner endpoints payouts Admin/User state transition

Admin control protected admin /admin/\* profiles/audit Admin non-admin 403

Reports required metrics /admin/reports/overview aggregate tables Reports totals

Responsive UX mobile/desktop --- --- all screens viewport checks

---

## Priority

P0 = signup/login, subscription, scores, charity selection, draw
simulation/publish, matching/prizes/rollover, winner
verification/payout, user dashboard, admin core, DB integrity,
responsive/error handling, deployment.
