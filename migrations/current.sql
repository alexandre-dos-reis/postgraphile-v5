
drop extension if exists pgcrypto cascade;
create extension pgcrypto;

drop extension if exists "uuid-ossp" cascade;
create extension "uuid-ossp";

drop table if exists public.users cascade;
create table public.users (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  first_name text not null,
  last_name text not null,
  email text not null unique check (email ~* '^.+@.+\..+$'),
  password_hash text not null
);

comment on table public.users is E'@behavior +sortBy -insert';
comment on column public.users.password_hash is E'@behavior -select';

drop type if exists public.jwt_token cascade;
create type public.jwt_token as (
  role text,
  exp integer,
  person_id uuid,
  email varchar
);

create or replace function public.register(
  first_name text,
  last_name text,
  email text,
  password text
) returns public.users as $$
declare
  person public.users;
begin
  insert into public.users(first_name, last_name, email, password_hash) values
    (first_name, last_name, email, crypt(password, gen_salt('bf')))
    returning * into person;

  return person;
end;
$$ language plpgsql strict security definer;


create or replace function public.authenticate(
  email text,
  password text
)
returns public.jwt_token
as $$
declare
  account public.users;
begin
  select a.* into account
    from public.users as a
    where a.email = authenticate.email;

  if account.password_hash = crypt(password, account.password_hash) then
    return (
      'person',
      extract(epoch from now() + interval '7 days'),
      account.id,
      account.email
    )::public.jwt_token;
  else
    return null;
  end if;
end;
$$ language plpgsql strict security definer;


drop role if exists anon;
create role anon;
grant anon to :DATABASE_OWNER;

drop role if exists person;
create role person;
grant person to :DATABASE_OWNER;

create or replace function public.current_person() returns public.users as $$
  select *
  from public.users
  where id = nullif(current_setting('jwt.claims.person_id', true), '')::uuid
$$ language sql stable;


grant select on table public.users to anon, person;
grant update, delete on table public.users to person;

alter table public.users enable row level security;

create policy select_users on public.users for select to person
  using (id = nullif(current_setting('jwt.claims.person_id', true), '')::uuid);

create policy update_users on public.users for update to person
  using (id = nullif(current_setting('jwt.claims.person_id', true), '')::uuid);

create policy delete_users on public.users for delete to person
  using (id = nullif(current_setting('jwt.claims.person_id', true), '')::uuid);




