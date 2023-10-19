--! Previous: sha1:924133155acd90f553160f528c0568f67af7ff85
--! Hash: sha1:b77013a55be879ce49f630471020dfed4d45102e

create or replace function public.authenticate(
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
      'person',
      extract(epoch from now() + interval '7 days'),
      account.id,
      account.email
    )::public.jwt_token;
  else
    return null;
  end if;
end;
$$ language plpgsql strict security definer;
