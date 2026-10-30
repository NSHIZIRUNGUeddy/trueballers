-- TrueBallers update 2: run once in Supabase > SQL Editor

-- Daily visit counts (Rwanda time) for the Analytics chart; only logged-in admins can read page_views
create or replace function daily_views(days int default 30)
returns table(day date, views bigint) language sql security invoker set search_path = public as $$
  select (created_at at time zone 'Africa/Kigali')::date as day, count(*) as views
  from page_views
  where created_at >= now() - make_interval(days => days)
  group by 1 order by 1
$$;
grant execute on function daily_views(int) to authenticated;

-- Allow admin to remove subscribers if ever needed
drop policy if exists "admin subs delete" on subscribers;
create policy "admin subs delete" on subscribers for delete to authenticated using(true);

-- Harden the view counter
alter function add_view(uuid) set search_path = public;
