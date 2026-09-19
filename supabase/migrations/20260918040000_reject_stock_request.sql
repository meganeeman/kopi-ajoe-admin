create or replace function public.reject_stock_request(p_request_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
    v_request public.stock_requests%rowtype;
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

    if v_request.status <> 'pending' then
        return jsonb_build_object('success', false, 'message', 'Permintaan stok sudah diproses.');
    end if;

    update public.stock_requests
    set status = 'rejected'
    where id = v_request.id
      and status = 'pending';

    if not found then
        return jsonb_build_object('success', false, 'message', 'Permintaan stok sudah diproses.');
    end if;

    return jsonb_build_object('success', true, 'message', 'Permintaan stok berhasil ditolak.');
end;
$$;

revoke all on function public.reject_stock_request(uuid) from public;
grant execute on function public.reject_stock_request(uuid) to authenticated;
