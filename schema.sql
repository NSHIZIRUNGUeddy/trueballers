-- TrueBallers: run this whole file once in Supabase > SQL Editor
create table articles(id uuid primary key default gen_random_uuid(),title text not null,summary text,body text,
 category text not null,lang text not null default 'rw',tags text,image_url text,video_url text,
 views int default 0,published boolean default true,created_at timestamptz default now());
create table comments(id uuid primary key default gen_random_uuid(),article_id uuid references articles on delete cascade,
 name text,body text,created_at timestamptz default now());
create table subscribers(id uuid primary key default gen_random_uuid(),email text unique,created_at timestamptz default now());
create table page_views(id bigint generated always as identity primary key,path text,created_at timestamptz default now());
create table scores(id uuid primary key default gen_random_uuid(),league text,home text,away text,hs int,"as" int,
 status text,created_at timestamptz default now());

alter table articles enable row level security;alter table comments enable row level security;
alter table subscribers enable row level security;alter table page_views enable row level security;alter table scores enable row level security;

create policy "read published" on articles for select using(published or auth.role()='authenticated');
create policy "admin articles" on articles for all to authenticated using(true) with check(true);
create policy "read comments" on comments for select using(true);
create policy "add comment" on comments for insert with check(true);
create policy "admin comments" on comments for delete to authenticated using(true);
create policy "subscribe" on subscribers for insert with check(true);
create policy "admin subs" on subscribers for select to authenticated using(true);
create policy "track" on page_views for insert with check(true);
create policy "admin views" on page_views for select to authenticated using(true);
create policy "read scores" on scores for select using(true);
create policy "admin scores" on scores for all to authenticated using(true) with check(true);

create function add_view(aid uuid) returns void language sql security definer as
$$ update articles set views=views+1 where id=aid $$;

insert into storage.buckets(id,name,public) values('images','images',true);
create policy "public images" on storage.objects for select using(bucket_id='images');
create policy "admin upload" on storage.objects for insert to authenticated with check(bucket_id='images');
create policy "admin delete img" on storage.objects for delete to authenticated using(bucket_id='images');

-- No sample articles are inserted. Add real stories from the admin panel.
