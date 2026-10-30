-- TRUE BALLERS: security hardening for the Supabase linter findings.
-- Run this whole file in Supabase > SQL Editor. It is safe to run more than once.
--
-- Note: "Leaked Password Protection Disabled" is an Auth setting, not SQL.
-- Turn it on in Supabase Dashboard > Authentication > Providers > Email:
-- enable "Prevent use of leaked passwords" (HaveIBeenPwned check).

-- 1. Staff helper ------------------------------------------------------------
-- SECURITY INVOKER so it can never be used to bypass RLS. Every object is
-- schema-qualified and search_path is locked.
create or replace function public.is_staff()
returns boolean
language sql
stable
security invoker
set search_path = ''
as $$
  select exists (
    select 1
    from public.admin_profiles p
    where p.id = (select auth.uid())
      and p.role in ('admin','editor')
  );
$$;

revoke all on function public.is_staff() from public;
grant execute on function public.is_staff() to anon, authenticated, service_role;
grant select on public.admin_profiles to anon, authenticated;

-- 2. Remove every existing policy on the app tables -------------------------
-- This also clears old/duplicate permissive policies that were not created by
-- the current schema, which is what causes the "Multiple Permissive Policies"
-- warnings.
do $$
declare
  r record;
begin
  for r in
    select schemaname, tablename, policyname
    from pg_policies
    where schemaname = 'public'
      and tablename in (
        'admin_profiles',
        'articles',
        'games',
        'analytics_events',
        'comments',
        'newsletter_subscribers'
      )
  loop
    execute format('drop policy if exists %I on %I.%I', r.policyname, r.schemaname, r.tablename);
  end loop;
end;
$$;

-- 3. admin_profiles ----------------------------------------------------------
-- Staff can only read their own role. Profile changes are done with the
-- service role / SQL editor, never from the browser.
create policy "staff can read own profile" on public.admin_profiles
  for select to authenticated
  using (id = (select auth.uid()));

-- 4. articles ----------------------------------------------------------------
create policy "published articles are public" on public.articles
  for select to anon
  using (status = 'published');

create policy "published or staff can read articles" on public.articles
  for select to authenticated
  using (status = 'published' or (select public.is_staff()));

create policy "staff insert articles" on public.articles
  for insert to authenticated
  with check (
    (select public.is_staff())
    and (author_id is null or author_id = (select auth.uid()))
  );

create policy "staff update articles" on public.articles
  for update to authenticated
  using ((select public.is_staff()))
  with check ((select public.is_staff()));

create policy "staff delete articles" on public.articles
  for delete to authenticated
  using ((select public.is_staff()));

-- 5. games -------------------------------------------------------------------
create policy "games are public" on public.games
  for select to anon, authenticated
  using (true);

create policy "staff insert games" on public.games
  for insert to authenticated
  with check ((select public.is_staff()));

create policy "staff update games" on public.games
  for update to authenticated
  using ((select public.is_staff()))
  with check ((select public.is_staff()));

create policy "staff delete games" on public.games
  for delete to authenticated
  using ((select public.is_staff()));

-- 6. analytics_events --------------------------------------------------------
create policy "anyone can record page views" on public.analytics_events
  for insert to anon, authenticated
  with check (event_type = 'page_view' and char_length(path) < 500);

create policy "staff can read analytics" on public.analytics_events
  for select to authenticated
  using ((select public.is_staff()));

-- 7. comments ----------------------------------------------------------------
create policy "public read approved comments" on public.comments
  for select to anon, authenticated
  using (approved = true or (select public.is_staff()));

create policy "visitors can submit comments for moderation" on public.comments
  for insert to anon, authenticated
  with check (approved = false);

create policy "staff moderate comments" on public.comments
  for update to authenticated
  using ((select public.is_staff()))
  with check ((select public.is_staff()));

create policy "staff delete comments" on public.comments
  for delete to authenticated
  using ((select public.is_staff()));

-- 8. newsletter_subscribers --------------------------------------------------
create policy "visitors can subscribe" on public.newsletter_subscribers
  for insert to anon, authenticated
  with check (char_length(email) < 255);

create policy "staff read subscribers" on public.newsletter_subscribers
  for select to authenticated
  using ((select public.is_staff()));

-- 9. daily_page_views --------------------------------------------------------
-- Security definer views run with the owner's privileges, bypassing RLS.
-- Force this view to run as the caller instead.
create or replace view public.daily_page_views
with (security_invoker = true) as
select date_trunc('day', created_at)::date as day, count(*)::bigint as page_views
from public.analytics_events
where event_type = 'page_view'
group by 1
order by 1;

do $$
begin
  if exists (select 1 from pg_views where schemaname = 'public' and viewname = 'daily_page_views') then
    execute 'alter view public.daily_page_views set (security_invoker = true)';
  end if;
end;
$$;

-- 10. Storage: article-images ------------------------------------------------
-- The bucket stays public so image URLs keep working, but listing is disabled
-- by removing every SELECT policy that mentions this bucket.
do $$
declare
  r record;
begin
  for r in
    select policyname
    from pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and (
        coalesce(qual, '') ilike '%article-images%'
        or coalesce(with_check, '') ilike '%article-images%'
        or policyname ilike '%article image%'
      )
  loop
    execute format('drop policy if exists %I on storage.objects', r.policyname);
  end loop;
end;
$$;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('article-images', 'article-images', true, 5242880, array['image/jpeg','image/png','image/webp'])
on conflict (id) do update
set public = excluded.public,
    file_size_limit = excluded.file_size_limit,
    allowed_mime_types = excluded.allowed_mime_types;

create policy "staff can upload article images" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'article-images' and (select public.is_staff()));

create policy "staff can update article images" on storage.objects
  for update to authenticated
  using (bucket_id = 'article-images' and (select public.is_staff()))
  with check (bucket_id = 'article-images' and (select public.is_staff()));

create policy "staff can delete article images" on storage.objects
  for delete to authenticated
  using (bucket_id = 'article-images' and (select public.is_staff()));

-- 11. Indexes for foreign keys and common queries ----------------------------
create index if not exists articles_author_id_idx on public.articles (author_id);
create index if not exists comments_article_id_idx on public.comments (article_id);
create index if not exists analytics_events_created_at_idx on public.analytics_events (created_at);
create index if not exists articles_status_published_at_idx on public.articles (status, published_at desc);
