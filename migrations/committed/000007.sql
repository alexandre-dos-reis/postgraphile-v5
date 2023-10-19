--! Previous: sha1:7df3c6078f3271cb885f86f1601a7bc651ff62e8
--! Hash: sha1:7c0261569f85fd763b350a0dee5a691db5aae68f

revoke select on table public.users from anon, person;
grant select on table public.users to anon, person;
