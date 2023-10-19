--! Previous: sha1:b77013a55be879ce49f630471020dfed4d45102e
--! Hash: sha1:7df3c6078f3271cb885f86f1601a7bc651ff62e8

create or replace function public.current_person() returns public.users as $$
  select *
  from public.users
  where id = nullif(current_setting('jwt.claims.person_id', true), '')::uuid
$$ language sql stable;
