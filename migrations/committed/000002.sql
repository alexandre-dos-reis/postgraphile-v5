--! Previous: sha1:a7ff854d7e94188c50291eaea8be0bd3e399cf42
--! Hash: sha1:198f83e415658742f49babba6a04bc03be53359d

-- Enter migration here


comment on table public.users is E'@behavior +sortBy -insert';
comment on column public.users.password_hash is E'@behavior -select';
