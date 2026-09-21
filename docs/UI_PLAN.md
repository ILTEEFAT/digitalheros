# UI / UX Plan

## Visual direction

Modern, charity-first, emotionally engaging. Avoid fairway/plaid/club
clichés. Use strong typography, generous spacing, editorial imagery,
impact metrics, cards, restrained motion and accessible contrast. The
homepage must explain what users do, how they win, charity impact, and
the primary subscription CTA.

## Public

1.  Home --- hero, how it works, prize/draw explanation, charity impact,
    featured charity, CTA.
2.  How It Works --- subscribe → add scores → draw → verify winnings →
    impact.
3.  Charities --- search/filter cards.
4.  Charity Detail --- description, image, events, contribution CTA.
5.  Pricing --- monthly/yearly comparison and charity percentage
    selector.
6.  Login / Signup --- short, clear forms.

## User

1.  Dashboard --- subscription status/renewal, score summary, charity
    impact, draw participation, winnings/payment status.
2.  Scores --- five-score editor, dates, validation, rolling behavior.
3.  Charity --- selected charity, percentage, change flow.
4.  Draws/Winnings --- published draws, personal participation,
    winner/proof status.
5.  Subscription --- plan, renewal/cancellation state.
6.  Profile --- account details.

## Admin

1.  Overview --- required report metrics.
2.  Users --- search/edit users, scores, subscription state.
3.  Draw Management --- create, choose mode, simulate, inspect preview,
    publish.
4.  Charities --- CRUD + media/events.
5.  Winners --- proof review, approve/reject, mark paid.
6.  Reports --- required aggregate metrics.

## Interaction rules

- Loading, empty, success and error states on every data screen.
- Confirm destructive actions.
- Disable publish while simulation is incomplete/invalid.
- Show subscription gating clearly rather than silently hiding
  features.
- Use subtle transitions only; no animation that delays core flows.
- Responsive from mobile upward.

## 20-hour UI strategy

Use one coherent component system: Button, Input, Card, Badge, Modal,
Table, EmptyState, Toast, StatCard. Avoid a large design system.
