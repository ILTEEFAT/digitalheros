-- Digital Heroes
-- Initial PostgreSQL schema
-- Source of truth: docs/DATABASE_SCHEMA.md

create extension if not exists "pgcrypto";

-- =========================================================
-- ENUMS
-- =========================================================

create type user_role as enum (
  'USER',
  'ADMIN'
);

create type subscription_plan as enum (
  'MONTHLY',
  'YEARLY'
);

create type subscription_status as enum (
  'ACTIVE',
  'CANCELLED',
  'LAPSED',
  'INACTIVE'
);

create type draw_mode as enum (
  'RANDOM',
  'ALGORITHMIC'
);

create type draw_status as enum (
  'DRAFT',
  'SIMULATED',
  'PUBLISHED'
);

create type winner_status as enum (
  'PENDING_VERIFICATION',
  'APPROVED',
  'REJECTED'
);

create type payout_status as enum (
  'PENDING',
  'PAID'
);

create type donation_status as enum (
  'PENDING',
  'PAID',
  'FAILED'
);

-- =========================================================
-- PROFILES
-- =========================================================

create table profiles (
  id uuid primary key
    references auth.users(id)
    on delete cascade,

  full_name text,

  role user_role not null default 'USER',

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- =========================================================
-- CHARITIES
-- =========================================================

create table charities (
  id uuid primary key default gen_random_uuid(),

  name text not null,
  description text not null,
  image_url text,

  is_featured boolean not null default false,
  is_active boolean not null default true,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- =========================================================
-- CHARITY EVENTS
-- =========================================================

create table charity_events (
  id uuid primary key default gen_random_uuid(),

  charity_id uuid not null
    references charities(id),

  title text not null,
  event_date date,
  description text,
  image_url text,

  created_at timestamptz not null default now()
);

create index idx_charity_events_charity_date
  on charity_events(charity_id, event_date);

-- =========================================================
-- SUBSCRIPTIONS
-- =========================================================

create table subscriptions (
  id uuid primary key default gen_random_uuid(),

  user_id uuid not null
    references profiles(id),

  plan subscription_plan not null,
  status subscription_status not null,

  stripe_customer_id text,
  stripe_subscription_id text unique,
  stripe_price_id text,

  current_period_start timestamptz,
  current_period_end timestamptz,

  cancel_at_period_end boolean not null default false,

  charity_id uuid
    references charities(id),

  charity_percentage numeric(5,2)
    check (
      charity_percentage >= 10
      and charity_percentage <= 100
    ),

  prize_pool_percentage numeric(5,2),

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_subscriptions_user_id
  on subscriptions(user_id);

create index idx_subscriptions_status
  on subscriptions(status);

create index idx_subscriptions_period_end
  on subscriptions(current_period_end);

-- =========================================================
-- SCORES
-- =========================================================

create table scores (
  id uuid primary key default gen_random_uuid(),

  user_id uuid not null
    references profiles(id)
    on delete cascade,

  score smallint not null
    check (score between 1 and 45),

  score_date date not null,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  unique(user_id, score_date)
);

create index idx_scores_user_date
  on scores(user_id, score_date desc);

-- =========================================================
-- DRAWS
-- =========================================================

create table draws (
  id uuid primary key default gen_random_uuid(),

  draw_month date not null,

  mode draw_mode not null,
  status draw_status not null,

  numbers smallint[] not null,

  prize_pool_amount numeric(12,2),
  prize_pool_percentage numeric(5,2),

  rollover_amount numeric(12,2) not null default 0,

  simulated_at timestamptz,
  published_at timestamptz,

  created_by uuid
    references profiles(id),

  published_by uuid
    references profiles(id),

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  unique(draw_month)
);

-- Draw numbers must contain exactly five values.
-- Values must be between 1 and 45.
alter table draws
add constraint draws_numbers_length_check
check (
  cardinality(numbers) = 5
);

alter table draws
add constraint draws_numbers_range_check
check (
  numbers <@ array[
    1,2,3,4,5,6,7,8,9,10,
    11,12,13,14,15,16,17,18,19,20,
    21,22,23,24,25,26,27,28,29,30,
    31,32,33,34,35,36,37,38,39,40,
    41,42,43,44,45
  ]::smallint[]
);

-- =========================================================
-- DRAW ENTRIES
-- =========================================================

create table draw_entries (
  id uuid primary key default gen_random_uuid(),

  draw_id uuid not null
    references draws(id)
    on delete cascade,

  user_id uuid not null
    references profiles(id),

  numbers smallint[] not null,
  score_ids uuid[] not null,

  match_count smallint not null default 0,

  created_at timestamptz not null default now(),

  unique(draw_id, user_id)
);

create index idx_draw_entries_draw_match
  on draw_entries(draw_id, match_count desc);

-- =========================================================
-- PRIZE TIERS
-- =========================================================

create table prize_tiers (
  id uuid primary key default gen_random_uuid(),

  draw_id uuid not null
    references draws(id)
    on delete cascade,

  match_count smallint not null
    check (match_count in (3,4,5)),

  percentage numeric(5,2) not null,

  pool_amount numeric(12,2),

  rollover_to_next boolean not null default false,

  unique(draw_id, match_count)
);

-- =========================================================
-- WINNERS
-- =========================================================

create table winners (
  id uuid primary key default gen_random_uuid(),

  draw_id uuid not null
    references draws(id),

  entry_id uuid not null
    references draw_entries(id),

  user_id uuid not null
    references profiles(id),

  tier_match_count smallint not null
    check (tier_match_count in (3,4,5)),

  prize_amount numeric(12,2) not null,

  status winner_status not null,

  rejection_reason text,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  unique(entry_id)
);

-- =========================================================
-- WINNER PROOFS
-- =========================================================

create table winner_proofs (
  id uuid primary key default gen_random_uuid(),

  winner_id uuid not null unique
    references winners(id)
    on delete cascade,

  storage_path text not null,

  mime_type text,

  uploaded_at timestamptz not null default now(),
  reviewed_at timestamptz,

  reviewed_by uuid
    references profiles(id)
);

-- =========================================================
-- PAYOUTS
-- =========================================================

create table payouts (
  id uuid primary key default gen_random_uuid(),

  winner_id uuid not null unique
    references winners(id),

  status payout_status not null default 'PENDING',

  amount numeric(12,2) not null,

  paid_at timestamptz,

  marked_paid_by uuid
    references profiles(id)
);

-- =========================================================
-- DONATIONS
-- =========================================================

create table donations (
  id uuid primary key default gen_random_uuid(),

  user_id uuid not null
    references profiles(id),

  charity_id uuid not null
    references charities(id),

  amount numeric(12,2) not null,

  source text not null
    check (source in ('SUBSCRIPTION', 'INDEPENDENT')),

  status donation_status not null,

  stripe_payment_intent_id text,

  created_at timestamptz not null default now()
);

-- =========================================================
-- PLATFORM SETTINGS
-- =========================================================

create table platform_settings (
  key text primary key,

  value_json jsonb not null,

  updated_at timestamptz not null default now()
);

-- =========================================================
-- AUDIT LOGS
-- =========================================================

create table audit_logs (
  id uuid primary key default gen_random_uuid(),

  actor_user_id uuid
    references profiles(id),

  action text not null,

  entity_type text,
  entity_id uuid,

  metadata jsonb,

  created_at timestamptz not null default now()
);

create index idx_audit_logs_entity
  on audit_logs(entity_type, entity_id);

create index idx_audit_logs_created_at
  on audit_logs(created_at desc);

-- =========================================================
-- ROW LEVEL SECURITY
-- =========================================================

-- RLS is enabled from the beginning.
-- Backend privileged operations will use the Supabase secret key.
-- Direct client access will require explicit policies later.

alter table profiles enable row level security;
alter table charities enable row level security;
alter table charity_events enable row level security;
alter table subscriptions enable row level security;
alter table scores enable row level security;
alter table draws enable row level security;
alter table draw_entries enable row level security;
alter table prize_tiers enable row level security;
alter table winners enable row level security;
alter table winner_proofs enable row level security;
alter table payouts enable row level security;
alter table donations enable row level security;
alter table platform_settings enable row level security;
alter table audit_logs enable row level security;