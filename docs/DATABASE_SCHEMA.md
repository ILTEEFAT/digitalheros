# Database Schema --- Supabase PostgreSQL

## Enums

- `user_role`: USER \| ADMIN
- `subscription_plan`: MONTHLY \| YEARLY
- `subscription_status`: ACTIVE \| CANCELLED \| LAPSED \| INACTIVE
- `draw_mode`: RANDOM \| ALGORITHMIC
- `draw_status`: DRAFT \| SIMULATED \| PUBLISHED
- `winner_status`: PENDING_VERIFICATION \| APPROVED \| REJECTED
- `payout_status`: PENDING \| PAID
- `donation_status`: PENDING \| PAID \| FAILED

## profiles

Purpose: application user profile and role. - id uuid PK, FK
auth.users(id) ON DELETE CASCADE - full_name text - role user_role NOT
NULL DEFAULT USER - created_at timestamptz - updated_at timestamptz
Constraint: role changes restricted to admins/server-side.

## charities

- id uuid PK
- name text NOT NULL
- description text NOT NULL
- image_url text
- is_featured boolean DEFAULT false
- is_active boolean DEFAULT true
- created_at, updated_at timestamptz

## charity_events

- id uuid PK
- charity_id uuid FK charities
- title text NOT NULL
- event_date date
- description text
- image_url text
- created_at Index charity_id, event_date.

## subscriptions

- id uuid PK
- user_id uuid FK profiles
- plan subscription_plan
- status subscription_status
- stripe_customer_id text
- stripe_subscription_id text UNIQUE
- stripe_price_id text
- current_period_start timestamptz
- current_period_end timestamptz
- cancel_at_period_end boolean DEFAULT false
- charity_id uuid FK charities
- charity_percentage numeric(5,2) CHECK 10 \<= value AND value \<= 100
- prize_pool_percentage numeric(5,2) NULL --- snapshot/config
  reference where needed
- created_at, updated_at Indexes user_id, status, current_period_end.

## scores

- id uuid PK
- user_id uuid FK profiles ON DELETE CASCADE
- score smallint CHECK score BETWEEN 1 AND 45
- score_date date NOT NULL
- created_at, updated_at UNIQUE(user_id, score_date) Index user_id,
  score_date DESC. Application service enforces five-score rolling
  retention in a transaction.

## draws

- id uuid PK
- draw_month date NOT NULL --- normalized to first day of month
- mode draw_mode
- status draw_status
- numbers smallint\[\] NOT NULL
- prize_pool_amount numeric(12,2)
- prize_pool_percentage numeric(5,2)
- rollover_amount numeric(12,2) DEFAULT 0
- simulated_at timestamptz
- published_at timestamptz
- created_by uuid FK profiles
- published_by uuid FK profiles
- created_at, updated_at UNIQUE(draw_month) Validation in service:
  exactly five distinct numbers 1--45.

## draw_entries

Frozen snapshot of user scores at draw eligibility time. - id uuid PK -
draw_id uuid FK draws ON DELETE CASCADE - user_id uuid FK profiles -
numbers smallint\[\] NOT NULL - score_ids uuid\[\] NOT NULL -
match_count smallint DEFAULT 0 - created_at UNIQUE(draw_id, user_id)
Index draw_id, match_count DESC.

## prize_tiers

Configurable per draw, but shares are frozen for audit. - id uuid PK -
draw_id uuid FK draws ON DELETE CASCADE - match_count smallint CHECK IN
(3,4,5) - percentage numeric(5,2) - pool_amount numeric(12,2) -
rollover_to_next boolean UNIQUE(draw_id, match_count)

## winners

- id uuid PK
- draw_id uuid FK draws
- entry_id uuid FK draw_entries
- user_id uuid FK profiles
- tier_match_count smallint CHECK IN (3,4,5)
- prize_amount numeric(12,2)
- status winner_status
- rejection_reason text
- created_at, updated_at UNIQUE(entry_id)

## winner_proofs

- id uuid PK
- winner_id uuid UNIQUE FK winners ON DELETE CASCADE
- storage_path text NOT NULL
- mime_type text
- uploaded_at timestamptz
- reviewed_at timestamptz
- reviewed_by uuid FK profiles

## payouts

- id uuid PK
- winner_id uuid UNIQUE FK winners
- status payout_status DEFAULT PENDING
- amount numeric(12,2)
- paid_at timestamptz
- marked_paid_by uuid FK profiles

## donations

- id uuid PK
- user_id uuid FK profiles
- charity_id uuid FK charities
- amount numeric(12,2)
- source text CHECK source IN ('SUBSCRIPTION','INDEPENDENT')
- status donation_status
- stripe_payment_intent_id text
- created_at

## platform_settings

- key text PK
- value_json jsonb NOT NULL
- updated_at timestamptz Use for prize_pool_percentage default and
  featured/homepage settings.

## audit_logs

- id uuid PK
- actor_user_id uuid FK profiles
- action text NOT NULL
- entity_type text
- entity_id uuid
- metadata jsonb
- created_at Index entity_type/entity_id and created_at DESC.

## Relationships

profiles 1---N scores profiles 1---N subscriptions charities 1---N
charity_events charities 1---N subscriptions draws 1---N draw_entries
draws 1---N prize_tiers draw_entries 1---N winners (practically one
winner record per entry) winners 1---1 winner_proofs winners 1---1
payouts profiles 1---N donations
