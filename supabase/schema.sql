-- TRUE BALLERS initial Supabase schema
create extension if not exists pgcrypto;

create table if not exists public.admin_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  role text not null default 'editor' check (role in ('admin','editor')),
  display_name text,
  created_at timestamptz not null default now()
);

create table if not exists public.articles (
  id uuid primary key default gen_random_uuid(),
  author_id uuid references auth.users(id) on delete set null,
  title text not null,
  excerpt text not null,
  content text not null,
  category text not null,
  language text not null default 'rw' check (language in ('rw','en','fr')),
  image_url text,
  views integer not null default 0,
  status text not null default 'draft' check (status in ('draft','published')),
  tags text[] not null default '{}',
  translation_group_id uuid,
  published_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

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

create unique index if not exists games_source_external_id_key on public.games (source, external_id);

create table if not exists public.analytics_events (
  id bigint generated always as identity primary key,
  event_type text not null default 'page_view',
  path text not null,
  referrer text,
  created_at timestamptz not null default now()
);

create table if not exists public.comments (
  id uuid primary key default gen_random_uuid(),
  article_id uuid not null references public.articles(id) on delete cascade,
  display_name text not null check (char_length(display_name) between 1 and 80),
  body text not null check (char_length(body) between 1 and 1500),
  approved boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.newsletter_subscribers (
  id uuid primary key default gen_random_uuid(),
  email text not null unique,
  created_at timestamptz not null default now()
);

alter table public.admin_profiles enable row level security;
alter table public.articles enable row level security;
alter table public.games enable row level security;
alter table public.analytics_events enable row level security;
alter table public.comments enable row level security;
alter table public.newsletter_subscribers enable row level security;

-- Helper used only by policies. A user is an admin/editor only if their profile exists.
-- SECURITY INVOKER keeps it from bypassing RLS; search_path is locked.
create or replace function public.is_staff()
returns boolean language sql stable security invoker set search_path = ''
as $$ select exists(select 1 from public.admin_profiles p where p.id = (select auth.uid()) and p.role in ('admin','editor')); $$;

revoke all on function public.is_staff() from public;
grant execute on function public.is_staff() to anon, authenticated, service_role;
grant select on public.admin_profiles to anon, authenticated;

drop policy if exists "staff can read own profile" on public.admin_profiles;
drop policy if exists "admins manage profiles" on public.admin_profiles;
drop policy if exists "admins insert profiles" on public.admin_profiles;
drop policy if exists "admins update profiles" on public.admin_profiles;
drop policy if exists "admins delete profiles" on public.admin_profiles;
create policy "staff can read own profile" on public.admin_profiles for select to authenticated using (id = (select auth.uid()));
drop policy if exists "published articles are public" on public.articles;
drop policy if exists "published or staff can read articles" on public.articles;
drop policy if exists "staff insert articles" on public.articles;
drop policy if exists "staff update articles" on public.articles;
drop policy if exists "staff delete articles" on public.articles;
create policy "published articles are public" on public.articles for select to anon using (status = 'published');
create policy "published or staff can read articles" on public.articles for select to authenticated using (status = 'published' or (select public.is_staff()));
create policy "staff insert articles" on public.articles for insert to authenticated with check ((select public.is_staff()) and (author_id is null or author_id = (select auth.uid())));
create policy "staff update articles" on public.articles for update to authenticated using ((select public.is_staff())) with check ((select public.is_staff()));
create policy "staff delete articles" on public.articles for delete to authenticated using ((select public.is_staff()));
drop policy if exists "games are public" on public.games;
create policy "games are public" on public.games for select to anon, authenticated using (true);
drop policy if exists "staff manage games" on public.games;
create policy "staff insert games" on public.games for insert to authenticated with check ((select public.is_staff()));
create policy "staff update games" on public.games for update to authenticated using ((select public.is_staff())) with check ((select public.is_staff()));
create policy "staff delete games" on public.games for delete to authenticated using ((select public.is_staff()));
create policy "anyone can record page views" on public.analytics_events for insert to anon, authenticated with check (event_type = 'page_view' and char_length(path) < 500);
create policy "staff can read analytics" on public.analytics_events for select to authenticated using ((select public.is_staff()));
create policy "public read approved comments" on public.comments for select to anon, authenticated using (approved = true or (select public.is_staff()));
create policy "visitors can submit comments for moderation" on public.comments for insert to anon, authenticated with check (approved = false);
create policy "staff moderate comments" on public.comments for update to authenticated using ((select public.is_staff())) with check ((select public.is_staff()));
create policy "staff delete comments" on public.comments for delete to authenticated using ((select public.is_staff()));
create policy "visitors can subscribe" on public.newsletter_subscribers for insert to anon, authenticated with check (char_length(email) < 255);
create policy "staff read subscribers" on public.newsletter_subscribers for select to authenticated using ((select public.is_staff()));

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('article-images', 'article-images', true, 5242880, array['image/jpeg','image/png','image/webp'])
on conflict (id) do nothing;
drop policy if exists "public can view article images" on storage.objects;
create policy "staff can upload article images" on storage.objects for insert to authenticated with check (bucket_id = 'article-images' and (select public.is_staff()));
create policy "staff can update article images" on storage.objects for update to authenticated using (bucket_id = 'article-images' and (select public.is_staff())) with check (bucket_id = 'article-images' and (select public.is_staff()));
create policy "staff can delete article images" on storage.objects for delete to authenticated using (bucket_id = 'article-images' and (select public.is_staff()));

-- Optional daily page-view report for dashboard/reporting queries.
create or replace view public.daily_page_views
with (security_invoker = true) as
select date_trunc('day', created_at)::date as day, count(*)::bigint as page_views
from public.analytics_events where event_type = 'page_view'
group by 1 order by 1;

create index if not exists articles_author_id_idx on public.articles (author_id);
create index if not exists comments_article_id_idx on public.comments (article_id);
create index if not exists analytics_events_created_at_idx on public.analytics_events (created_at);
create index if not exists articles_status_published_at_idx on public.articles (status, published_at desc);
