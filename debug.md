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

```gql
mutation register {
  register(
    input: {
      firstName: "Alex"
      lastName: "Dos Reis"
      email: "alex@mail.com"
      password: "my-password"
    }
  ) {
    result {
      firstName
      lastName
      email
    }
  }
}

mutation auth {
  authenticate(input: { email: "alex@mail.com", password: "my-password" }) {
    result
  }
}

query me {
  currentPerson {
    firstName
    lastName
    email
  }
}

mutation changeMe {
  updateUser(
    input: {
      rowId: "71292feb-5dd4-40b1-a98e-86c3e17c0e7d"
      patch: { firstName: "new firstname", lastName: "new lastname" }
    }
  ) {
    user {
      firstName
      lastName
    }
  }
}
```
