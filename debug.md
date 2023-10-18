```sql
begin;
set role to person;
set local jwt.claims.person_id to '71292feb-5dd4-40b1-a98e-86c3e17c0e7d';
  select *
  from public.users
  where id = nullif(current_setting('jwt.claims.person_id', true), '')::uuid;
commit;
```

```sql
SELECT * FROM pg_roles where "rolname" not like 'pg%'
```
