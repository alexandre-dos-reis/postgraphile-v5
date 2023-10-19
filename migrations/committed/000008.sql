--! Previous: sha1:7c0261569f85fd763b350a0dee5a691db5aae68f
--! Hash: sha1:1ff454dfc18af37d205b77945671f6c80c1f6cdc

revoke update, delete on table public.users from person;
grant update, delete on table public.users to person;
