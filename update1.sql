-- TrueBallers update 1: run once in Supabase > SQL Editor
alter table articles add column if not exists images text[] default '{}';
update articles set images=array[image_url] where image_url is not null and (images is null or images='{}');
-- make sure the picture storage exists, is public, and the rules are right
insert into storage.buckets(id,name,public) values('images','images',true) on conflict(id) do update set public=true;
drop policy if exists "public images" on storage.objects;
drop policy if exists "admin upload" on storage.objects;
drop policy if exists "admin delete img" on storage.objects;
create policy "public images" on storage.objects for select using(bucket_id='images');
create policy "admin upload" on storage.objects for insert to authenticated with check(bucket_id='images');
create policy "admin delete img" on storage.objects for delete to authenticated using(bucket_id='images');
