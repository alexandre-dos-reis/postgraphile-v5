--! Previous: -
--! Hash: sha1:a7ff854d7e94188c50291eaea8be0bd3e399cf42

drop table if exists public.users;
create table public.users (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  first_name text not null,
  last_name text not null,
  email text not null unique check (email ~* '^.+@.+\..+$'),
  password_hash text not null
);
