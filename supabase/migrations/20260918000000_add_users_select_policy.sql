-- Fixes 403 on the admin panel's `users` queries (e.g. role = 'sales' lookups).
-- Uses a SECURITY DEFINER helper to avoid recursive RLS evaluation on public.users.

alter table public.users enable row level security;

create or replace function public.is_admin_or_staff(uid uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1
    from public.users u
    where u.id = uid
      and u.role in ('admin', 'super_admin', 'staff')
  );
$$;

grant execute on function public.is_admin_or_staff(uuid) to authenticated;

drop policy if exists "Admins and staff can read all users" on public.users;

create policy "Admins and staff can read all users"
on public.users
for select
to authenticated
using (
  auth.uid() = id
  or public.is_admin_or_staff(auth.uid())
);
