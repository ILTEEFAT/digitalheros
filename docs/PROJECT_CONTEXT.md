# Digital Heroes --- Project Context

## Source of truth

1.  Digital Heroes PRD v1.0, March 2026.
2.  Approved architecture decisions in this project.
3.  These documents.
4.  Existing code.
5.  General engineering knowledge.

The PRD is the product source of truth. The uploaded PDF is 13 physical
pages but its printed pagination jumps from 10/14 to 12/14; the content
for sections 13--14 (Technical Requirements and Scalability
Considerations) is not present in the supplied file. The architecture
therefore uses the user's approved stack direction as the implementation
baseline and does not claim those missing PRD sections specified
details.

## Product

Subscription-driven web application combining golf Stableford
performance tracking, monthly prize draws, and charity giving. The
experience should be modern and emotionally driven by charitable impact,
not resemble a traditional golf website.

## Roles

- Public visitor: browse concept, charities, draw mechanics, initiate
  subscription.
- Registered subscriber: profile/settings, scores, charity,
  participation/winnings, winner proof.
- Administrator: users/subscriptions, draw
  configuration/simulation/publishing, charities, winner
  verification/payouts, reports.

## Approved implementation baseline

- Frontend: React + Vite + React Router + modern CSS/Tailwind as
  appropriate.
- Backend: Node.js + Express REST API.
- Database: new Supabase PostgreSQL project.
- Authentication: Supabase Auth with JWT verification in Express.
- Storage: Supabase Storage for winner proof.
- Payments: Stripe test mode.
- Deployment: new Vercel account for frontend; backend on Render or
  equivalent.

## Core flow

Visitor → signup/login → subscription → charity selection → enter up to
five latest Stableford scores → monthly draw entry → admin simulation →
admin publish → match/prize calculation → winner proof → admin
verification → payout state.

## Delivery target

Approximately 20 effective working hours. P0 functionality and
correctness take precedence over polish and extras.
