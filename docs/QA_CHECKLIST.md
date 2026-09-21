# QA Checklist

## P0 functional

- [ ] Signup creates profile.
- [ ] Login/logout works.
- [ ] Monthly checkout works in Stripe TEST MODE.
- [ ] Yearly checkout works.
- [ ] Stripe webhook creates/updates application subscription.
- [ ] Cancel-at-period-end and lapsed state behave correctly.
- [ ] Non-subscriber cannot access subscriber-only APIs.
- [ ] Score 1 and 45 accepted; 0 and 46 rejected.
- [ ] Same user/date cannot create duplicate score.
- [ ] Edit/delete score works.
- [ ] Adding sixth score removes oldest.
- [ ] Scores are newest first.
- [ ] Charity at least 10%; invalid percentages rejected.
- [ ] Charity selection persists with subscription.
- [ ] Directory search/filter works.
- [ ] Random draw produces 5 distinct numbers in 1--45.
- [ ] Algorithmic draw uses score frequencies and still returns 5
      distinct numbers.
- [ ] Simulation does not publish or create payout obligations.
- [ ] Only admin can publish.
- [ ] Match counts 3/4/5 correctly.
- [ ] Prize shares are exactly 40/35/25.
- [ ] Multiple winners split a tier equally.
- [ ] Unclaimed 5-match amount rolls into next jackpot.
- [ ] 3/4 tier unclaimed money does not roll.
- [ ] Winner can upload proof.
- [ ] Non-winner cannot upload proof for another winner.
- [ ] Admin can approve/reject with reason.
- [ ] Payout moves Pending→Paid only by admin.
- [ ] Admin endpoints return 403 for USER.
- [ ] Dashboard shows required five modules.
- [ ] Admin shows required five control surfaces.
- [ ] Reports show total users, prize pool, charity totals, draw
      stats.

## Data/security

- [ ] Ownership checks on user resources.
- [ ] Role checks server-side.
- [ ] Stripe webhook signature verified.
- [ ] Private proof files are not publicly exposed.
- [ ] Secrets are environment variables.
- [ ] DB unique constraints are active.
- [ ] Draw publish is transactional/idempotent.
- [ ] Published draw data is frozen/auditable.

## UI

- [ ] Mobile layout.
- [ ] Desktop layout.
- [ ] Keyboard/focus basics.
- [ ] Loading states.
- [ ] Empty states.
- [ ] Validation messages.
- [ ] API error states.
- [ ] Destructive action confirmations.
- [ ] No golf cliché visual treatment.
- [ ] Primary subscribe CTA is obvious.

## Final smoke test

Use fresh USER and ADMIN test accounts and complete one end-to-end path:
signup → subscription test checkout → charity → five scores → simulate →
publish → winner proof (if test data produces winner) → approve → paid.
