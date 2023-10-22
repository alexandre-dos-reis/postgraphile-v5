--! Previous: -
--! Hash: sha1:1a468a6968c60ef41293780d490c330043f4e265

-- Enter migration here

create table if not exists public.users (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  first_name text not null,
  last_name text not null,
  email text not null unique check (email ~* '^.+@.+\..+$'),
  password_hash text not null
);

comment on table public.users is $$
  @behavior +sortBy -insert
$$;

comment on column public.users.password_hash is $$
  @behavior -select
$$;

drop type if exists public.jwt_token cascade;
create type public.jwt_token as (
  role text,
  exp integer,
  user_id uuid,
  email varchar
);

create or replace function public.register(
  first_name text,
  last_name text,
  email text,
  password text
) returns public.users as $$
declare
  user public.users;
begin
  insert into public.users(first_name, last_name, email, password_hash) values
    (first_name, last_name, email, crypt(password, gen_salt('bf')))
    returning * into user;

  return user;
end;
$$ language plpgsql strict security definer;

create or replace function public.authenticate(
  email text,
  password text
)
returns public.jwt_token
as $$
declare
  user public.users;
begin
  select a.* into user
    from public.users as a
    where a.email = authenticate.email;

  if "user".password_hash = crypt(authenticate.password, "user".password_hash) then
    return (
      ':POSTGRAPHILE_USER_ROLE',
      extract(epoch from now() + interval '7 days'),
      "user".id,
      "user".email
    )::public.jwt_token;
  else
    return null;
  end if;
end;
$$ language plpgsql strict security definer;

create or replace function public.current_user() returns public.users as $$
  select *
  from public.users
  where id = nullif(current_setting('jwt.claims.user_id', true), '')::uuid
$$ language sql stable;

revoke select on table public.users from :POSTGRAPHILE_ANON_ROLE, ":POSTGRAPHILE_USER_ROLE";
grant select on table public.users to :POSTGRAPHILE_ANON_ROLE, ":POSTGRAPHILE_USER_ROLE";

revoke update, delete on table public.users from ":POSTGRAPHILE_USER_ROLE";
grant update, delete on table public.users to ":POSTGRAPHILE_USER_ROLE";

alter table public.users enable row level security;

drop policy if exists select_users on public.users;
create policy select_users on public.users for select to ":POSTGRAPHILE_USER_ROLE"
  using (id = nullif(current_setting('jwt.claims.user_id', true), '')::uuid);

drop policy if exists update_users on public.users;
create policy update_users on public.users for update to ":POSTGRAPHILE_USER_ROLE"
  using (id = nullif(current_setting('jwt.claims.user_id', true), '')::uuid);

drop policy if exists delete_users on public.users;
create policy delete_users on public.users for delete to ":POSTGRAPHILE_USER_ROLE"
  using (id = nullif(current_setting('jwt.claims.user_id', true), '')::uuid);
