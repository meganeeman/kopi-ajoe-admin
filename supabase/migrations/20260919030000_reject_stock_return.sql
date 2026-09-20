-- Rejects one stock return. p_reason has no dedicated column; it is only echoed back in the response.
create or replace function public.reject_stock_return(p_return_id uuid, p_reason text default null)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
    v_return public.stock_returns%rowtype;
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

    select branch
    into v_return_branch
    from public.cart_units
    where id = v_return.cart_unit_id;

    if v_role <> 'super_admin'
       and coalesce(v_user_branch, '') <> 'ALL'
       and v_user_branch is distinct from v_return_branch then
        raise exception 'Unauthorized branch access';
    end if;

    if v_return_branch is null then
        return jsonb_build_object('success', false, 'message', 'Cabang gerobak tidak ditemukan.');
    end if;

    if v_return.status <> 'pending' then
        return jsonb_build_object('success', false, 'message', 'Pengembalian stok sudah diproses.');
    end if;

    update public.stock_returns
    set status = 'rejected'
    where id = v_return.id
      and status = 'pending';

    if not found then
        return jsonb_build_object('success', false, 'message', 'Pengembalian stok sudah diproses.');
    end if;

    return jsonb_build_object(
        'success', true,
        'message', coalesce(nullif(trim(p_reason), ''), 'Pengembalian stok berhasil ditolak.')
    );
end;
$$;

revoke all on function public.reject_stock_return(uuid, text) from public;
grant execute on function public.reject_stock_return(uuid, text) to authenticated;
