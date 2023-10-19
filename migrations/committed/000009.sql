--! Previous: sha1:1ff454dfc18af37d205b77945671f6c80c1f6cdc
--! Hash: sha1:cb0c3add7d0bace9b1ecf0f3d10ceb940bc116da

alter table public.users enable row level security;

drop policy if exists select_users on public.users;
create policy select_users on public.users for select to person
  using (id = nullif(current_setting('jwt.claims.person_id', true), '')::uuid);

drop policy if exists update_users on public.users;
create policy update_users on public.users for update to person
  using (id = nullif(current_setting('jwt.claims.person_id', true), '')::uuid);

drop policy if exists delete_users on public.users;
create policy delete_users on public.users for delete to person
  using (id = nullif(current_setting('jwt.claims.person_id', true), '')::uuid);
