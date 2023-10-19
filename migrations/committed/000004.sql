--! Previous: sha1:9a90ccab6a750b88d0fbe1938c800641043c7f3f
--! Hash: sha1:924133155acd90f553160f528c0568f67af7ff85

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
