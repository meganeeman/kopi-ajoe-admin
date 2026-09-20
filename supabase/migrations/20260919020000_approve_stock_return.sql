-- Atomically approves one stock return: restores cart stock and factory inventory for the cart unit's branch.
create or replace function public.approve_stock_return(p_return_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
    v_return public.stock_returns%rowtype;
    v_cart_stock public.cart_stocks%rowtype;
    v_inventory public.inventory%rowtype;
    v_role text;
    v_user_branch text;
    v_return_branch text;
begin
    select lower(role), branch
    into v_role, v_user_branch
    from public.users
    where id = auth.uid();

    if v_role not in ('admin', 'super_admin') then
        return jsonb_build_object('success', false, 'message', 'Akses ditolak.');
    end if;

    select *
    into v_return
    from public.stock_returns
    where id = p_return_id
    for update;

    if not found then
        return jsonb_build_object('success', false, 'message', 'Pengembalian stok tidak ditemukan.');
    end if;

    if v_return.status <> 'pending' then
        return jsonb_build_object('success', false, 'message', 'Pengembalian stok sudah diproses.');
    end if;

    if v_return.cart_unit_id is null or v_return.product_id is null or coalesce(v_return.quantity, 0) <= 0 then
        return jsonb_build_object('success', false, 'message', 'Data pengembalian stok tidak valid.');
    end if;

    select branch
    into v_return_branch
    from public.cart_units
    where id = v_return.cart_unit_id;

    if v_return_branch is null then
        return jsonb_build_object('success', false, 'message', 'Cabang gerobak tidak ditemukan.');
    end if;

    if v_role <> 'super_admin'
       and coalesce(v_user_branch, '') <> 'ALL'
       and v_user_branch is distinct from v_return_branch then
        raise exception 'Unauthorized branch access';
    end if;

    -- Serializes cart_stocks and inventory updates for this cart/product/branch triple.
    perform pg_advisory_xact_lock(
        hashtextextended(v_return.cart_unit_id::text || ':' || v_return.product_id::text, 0)
    );

    select *
    into v_cart_stock
    from public.cart_stocks
    where cart_unit_id = v_return.cart_unit_id
      and product_id = v_return.product_id
    for update;

    if found then
        update public.cart_stocks
        set quantity = greatest(0, v_cart_stock.quantity - v_return.quantity)
        where id = v_cart_stock.id;
    end if;

    select *
    into v_inventory
    from public.inventory
    where product_id = v_return.product_id
      and branch = v_return_branch
    for update;

    if found then
        update public.inventory
        set stock = v_inventory.stock + v_return.quantity
        where id = v_inventory.id;
    else
        insert into public.inventory (product_id, branch, stock)
        values (v_return.product_id, v_return_branch, v_return.quantity);
    end if;

    update public.stock_returns
    set status = 'approved'
    where id = v_return.id
      and status = 'pending';

    if not found then
        return jsonb_build_object('success', false, 'message', 'Pengembalian stok sudah diproses.');
    end if;

    return jsonb_build_object('success', true, 'message', 'Pengembalian stok berhasil disetujui.');
end;
$$;

revoke all on function public.approve_stock_return(uuid) from public;
grant execute on function public.approve_stock_return(uuid) to authenticated;
