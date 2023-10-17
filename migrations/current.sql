
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

comment on table public.users is E'@behavior +sortBy -insert -update';
comment on column public.users.password_hash is E'@behavior -select';

drop type if exists public.jwt_token cascade;
create type public.jwt_token as (
  role text,
  exp integer,
  person_id integer,
  email varchar
);

drop function if exists public.register_person cascade;
create function public.register_person(
  first_name text,
  last_name text,
  email text,
  password text
) returns public.users as $$
declare
  person public.users;
begin
  insert into public.users(first_name, last_name, email, password_hash) values
    (first_name, last_name, email, crypt(password, gen_salt('bf')));

  return person;
end;
$$ language plpgsql strict security definer;



drop function if exists public.authenticate cascade;
create function public.authenticate(
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
      'person_role',
      extract(epoch from now() + interval '7 days'),
      1,
      account.email
    )::public.jwt_token;
  else
    return null;
  end if;
end;
$$ language plpgsql strict security definer;
