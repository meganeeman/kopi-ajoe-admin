create or replace function public.approve_stock_request(p_request_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
    v_request public.stock_requests%rowtype;
    v_cart_stock public.cart_stocks%rowtype;
    v_role text;
    v_user_branch text;
    v_request_branch text;
begin
    select lower(role), branch
    into v_role, v_user_branch
    from public.users
    where id = auth.uid();

    if v_role not in ('admin', 'super_admin') then
        return jsonb_build_object('success', false, 'message', 'Akses ditolak.');
    end if;

    select *
    into v_request
    from public.stock_requests
    where id = p_request_id
    for update;

    if not found then
        return jsonb_build_object('success', false, 'message', 'Permintaan stok tidak ditemukan.');
    end if;

    if v_request.status <> 'pending' then
        return jsonb_build_object('success', false, 'message', 'Permintaan stok sudah diproses.');
    end if;

    if v_request.cart_unit_id is null or v_request.product_id is null or coalesce(v_request.quantity, 0) <= 0 then
        return jsonb_build_object('success', false, 'message', 'Data permintaan stok tidak valid.');
    end if;

    select branch
    into v_request_branch
    from public.cart_units
    where id = v_request.cart_unit_id;

    if v_role <> 'super_admin'
       and coalesce(v_user_branch, '') <> 'ALL'
       and v_user_branch is distinct from v_request_branch then
        raise exception 'Unauthorized branch access';
    end if;

    if v_request_branch is null then
        return jsonb_build_object('success', false, 'message', 'Cabang gerobak tidak ditemukan.');
    end if;

    perform pg_advisory_xact_lock(
        hashtextextended(v_request.cart_unit_id::text || ':' || v_request.product_id::text, 0)
    );

    select *
    into v_cart_stock
    from public.cart_stocks
    where cart_unit_id = v_request.cart_unit_id
      and product_id = v_request.product_id
    for update;

    if found then
        update public.cart_stocks
        set quantity = v_cart_stock.quantity + v_request.quantity
        where id = v_cart_stock.id;
    else
        insert into public.cart_stocks (cart_unit_id, product_id, quantity)
        values (v_request.cart_unit_id, v_request.product_id, v_request.quantity);
    end if;

    update public.stock_requests
    set status = 'approved'
    where id = v_request.id
      and status = 'pending';

    if not found then
        return jsonb_build_object('success', false, 'message', 'Permintaan stok sudah diproses.');
    end if;

    return jsonb_build_object('success', true, 'message', 'Permintaan stok berhasil disetujui.');
end;
$$;

revoke all on function public.approve_stock_request(uuid) from public;
grant execute on function public.approve_stock_request(uuid) to authenticated;
