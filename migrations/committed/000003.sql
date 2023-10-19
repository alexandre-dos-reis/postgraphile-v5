--! Previous: sha1:198f83e415658742f49babba6a04bc03be53359d
--! Hash: sha1:9a90ccab6a750b88d0fbe1938c800641043c7f3f

drop type if exists public.jwt_token;
create type public.jwt_token as (
  role text,
  exp integer,
  person_id uuid,
  email varchar
);
