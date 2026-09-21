# Architecture Decisions

## D1 --- Monolith

**Decision:** One Express API with clear
route/controller/service/repository layers. **Reason:** Fits the 20-hour
constraint and is easy to explain/deploy. **Alternative:**
Microservices. **Impact:** Lower operational complexity; business
modules remain separable in code.

## D2 --- Score-to-entry mapping

**Decision:** A user's five retained Stableford values are the five
draw-entry numbers. **Reason:** It uses the only explicit 1--45 numeric
data in the PRD and makes the draw personally connected to performance.
**Alternative:** Generate a separate ticket number per user. **Impact:**
Duplicate score values are possible; matching therefore uses each drawn
number at most once.

## D3 --- Five-score eligibility

**Decision:** A subscriber needs five retained scores to enter a draw.
**Reason:** The PRD requires users to enter their last five scores but
does not define partial entries. **Alternative:** Allow 3--4 score
entries. **Impact:** UI must make the five-score requirement obvious.

## D4 --- Algorithmic draw

**Decision:** Weight 1--45 candidates by frequency among eligible users'
retained score values, sample five distinct values without replacement,
with a small uniform floor. **Reason:** Directly operationalizes
"weighted by score frequency" without inventing a predictive model.
**Alternative:** ML/predictive scoring. **Impact:** Deterministic
inputs, testable probabilities, no ML dependency.

## D5 --- Prize-pool contribution

**Decision:** Admin-configurable percentage, default 50%, stored on each
published draw. **Reason:** PRD says a fixed portion but gives no
percentage. **Alternative:** Hard-code a percentage. **Impact:** Admin
can configure the assignment without code changes; published draws
remain auditable.

## D6 --- Independent donations

**Decision:** Separate donation record and checkout flow, using Stripe
test mode if implemented; not connected to draw eligibility. **Reason:**
PRD explicitly says donation is independent of gameplay.
**Alternative:** Omit the flow. **Impact:** P0 includes a simple
donation form/checkout only if time remains after core subscription
flow.

## D7 --- Yearly pricing

**Decision:** Store Stripe price IDs and display amounts from
configuration; yearly is a separate Stripe price with the PRD-required
discounted rate, exact amount left configurable. **Reason:** PRD
specifies a discounted yearly plan but no amount. **Alternative:**
Invent a price. **Impact:** No fabricated product pricing.

## D8 --- Subscription state

**Decision:** Keep Stripe status and application status as separate
fields. **Reason:** Stripe is an external lifecycle source; application
access needs a simple local state. **Impact:** Webhook synchronization
is explicit and auditable.

## D9 --- Proof uploads

**Decision:** Store private proof files in Supabase Storage; generate
signed upload/download URLs. **Reason:** Avoid large multipart handling
in the Express API. **Impact:** Backend controls authorization while
storage handles files.

## D10 --- Auditability

**Decision:** Add a compact audit_logs table for admin actions and
published draw snapshots. **Reason:** Draw publishing, winner
verification, and payout changes are business-critical. **Alternative:**
No audit layer. **Impact:** Slight schema complexity, much better
interview defensibility.

## D11 --- Missing PRD pages

**Decision:** Do not invent the missing Technical Requirements and
Scalability Considerations content. **Reason:** Supplied PDF jumps from
printed page 10/14 to 12/14. **Impact:** Use the user-approved
technology direction as the implementation baseline and flag this as a
source limitation.
