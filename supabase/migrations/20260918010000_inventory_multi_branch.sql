-- Makes inventory stock tracked per branch instead of globally per product.

alter table public.inventory
  add column if not exists branch character varying(50);

-- Backfill: prefer the first non-null branch seen on cart_units, else 'PYK'.
do $$
declare
  fallback_branch character varying(50);
begin
  select cu.branch into fallback_branch
  from public.cart_units cu
  where cu.branch is not null
  order by cu.branch
  limit 1;

  update public.inventory
  set branch = coalesce(fallback_branch, 'PYK')
  where branch is null;
end $$;

alter table public.inventory
  alter column branch set default 'PYK'::character varying,
  alter column branch set not null;

alter table public.inventory
  drop constraint if exists inventory_product_id_key;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conrelid = 'public.inventory'::regclass
      and conname = 'inventory_product_id_branch_key'
  ) then
    alter table public.inventory
      add constraint inventory_product_id_branch_key unique (product_id, branch);
  end if;
end $$;
