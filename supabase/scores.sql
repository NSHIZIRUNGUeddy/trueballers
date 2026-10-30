create extension if not exists pgcrypto;

create table if not exists public.games (
  id uuid primary key default gen_random_uuid(),
  source text not null,
  external_id text,
  competition text,
  home_team text not null,
  away_team text not null,
  home_score integer,
  away_score integer,
  status text not null default 'scheduled',
  period text,
  scheduled_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.games add column if not exists external_id text;
alter table public.games add column if not exists status text not null default 'scheduled';
alter table public.games add column if not exists created_at timestamptz not null default now();
alter table public.games add column if not exists updated_at timestamptz not null default now();

create unique index if not exists games_source_external_id_key on public.games (source, external_id);

alter table public.games enable row level security;

create or replace function public.is_staff()
returns boolean language sql stable security definer set search_path = public
as $$ select exists(select 1 from public.admin_profiles p where p.id = auth.uid() and p.role in ('admin','editor')); $$;

drop policy if exists "games are public" on public.games;
create policy "games are public" on public.games for select to anon, authenticated using (true);

drop policy if exists "staff manage games" on public.games;
create policy "staff manage games" on public.games for all to authenticated using (public.is_staff()) with check (public.is_staff());
