-- ==============================================================================
-- BASE DE DATOS SUPABASE - SISTEMA COPIADORA CON QR FÍSICOS & SEGUIMIENTO DE TRABAJOS
-- Copiadora Grafiplot
-- ==============================================================================

-- Habilitar extensión pgcrypto para UUID y funciones criptográficas
create extension if not exists "pgcrypto";

-- ------------------------------------------------------------------------------
-- 1. TABLA: customers (Clientes)
-- ------------------------------------------------------------------------------
create table if not exists public.customers (
    id uuid primary key default gen_random_uuid(),
    name text not null,
    phone text,
    notes text,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- ------------------------------------------------------------------------------
-- 2. TABLA: jobs (Trabajos de Copiadora / Impresión)
-- ------------------------------------------------------------------------------
create table if not exists public.jobs (
    id uuid primary key default gen_random_uuid(),
    customer_id uuid references public.customers(id) on delete set null,
    customer_name_snapshot text not null,
    customer_phone_snapshot text,
    description text,
    status text not null check (status in ('received', 'in_progress', 'ready', 'delivered', 'cancelled')) default 'received',
    total numeric(10,2) not null default 0.00 check (total >= 0),
    notes text,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    ready_at timestamptz,
    delivered_at timestamptz,
    created_by uuid references auth.users(id) on delete set null
);

-- ------------------------------------------------------------------------------
-- 3. TABLA: job_items (Ítems / Bloques del Trabajo)
-- ------------------------------------------------------------------------------
create table if not exists public.job_items (
    id uuid primary key default gen_random_uuid(),
    job_id uuid not null references public.jobs(id) on delete cascade,
    label text not null,
    quantity integer not null default 1 check (quantity > 0),
    unit_price numeric(10,2) not null default 0.00 check (unit_price >= 0),
    subtotal numeric(10,2) not null default 0.00 check (subtotal >= 0),
    created_at timestamptz not null default now()
);

-- ------------------------------------------------------------------------------
-- 4. TABLA: qr_tokens (Códigos QR Físicos Preimpresos)
-- ------------------------------------------------------------------------------
create table if not exists public.qr_tokens (
    id uuid primary key default gen_random_uuid(),
    token text not null unique,
    status text not null check (status in ('unused', 'assigned', 'disabled')) default 'unused',
    job_id uuid references public.jobs(id) on delete set null,
    created_at timestamptz not null default now(),
    assigned_at timestamptz,
    released_at timestamptz
);

-- ------------------------------------------------------------------------------
-- ÍNDICES DE RENDIMIENTO
-- ------------------------------------------------------------------------------
create index if not exists idx_qr_tokens_token on public.qr_tokens(token);
create index if not exists idx_qr_tokens_status on public.qr_tokens(status);
create index if not exists idx_qr_tokens_job_id on public.qr_tokens(job_id);

create index if not exists idx_jobs_status on public.jobs(status);
create index if not exists idx_jobs_created_at on public.jobs(created_at desc);
create index if not exists idx_jobs_customer_id on public.jobs(customer_id);

create index if not exists idx_job_items_job_id on public.job_items(job_id);

-- ------------------------------------------------------------------------------
-- FUNCION: Generación de Tokens Únicos Sin Caracteres Ambiguos (8 Caracteres)
-- Excluye: 0, O, 1, I, L
-- Caracteres válidos (31): 23456789ABCDEFGHJKMNPQRSTUVWXYZ
-- ------------------------------------------------------------------------------
create or replace function generate_random_token()
returns text
language plpgsql
as $$
declare
    chars text := '23456789ABCDEFGHJKMNPQRSTUVWXYZ';
    result text := '';
    i integer := 0;
    rand_index integer;
begin
    for i in 1..8 loop
        rand_index := floor(random() * length(chars) + 1)::integer;
        result := result || substr(chars, rand_index, 1);
    end loop;
    return result;
end;
$$;

-- ------------------------------------------------------------------------------
-- FUNCION: Generación Masiva de Tokens QR (Lotes de preimpresión)
-- Ej: select batch_generate_qr_tokens(100);
-- ------------------------------------------------------------------------------
create or replace function batch_generate_qr_tokens(p_count integer)
returns setof public.qr_tokens
language plpgsql
as $$
declare
    v_inserted_count integer := 0;
    v_token text;
    v_rec public.qr_tokens;
begin
    if p_count is null or p_count <= 0 then
        raise exception 'El número de tokens a generar debe ser mayor a cero.';
    end if;

    while v_inserted_count < p_count loop
        v_token := generate_random_token();
        
        -- Intentar insertar omitiendo duplicados
        begin
            insert into public.qr_tokens (token, status, job_id)
            values (v_token, 'unused', null)
            returning * into v_rec;
            
            v_inserted_count := v_inserted_count + 1;
            return next v_rec;
        exception when unique_violation then
            -- Si colisiona el token aleatorio, reintenta automáticamente
            null;
        end;
    end loop;
    return;
end;
$$;

-- ------------------------------------------------------------------------------
-- TRIGGER: Actualización Automática de updated_at
-- ------------------------------------------------------------------------------
create or replace function update_timestamp()
returns trigger as $$
begin
    new.updated_at = now();
    return new;
end;
$$ language plpgsql;

create or replace trigger trg_customers_updated_at
    before update on public.customers
    for each row execute function update_timestamp();

create or replace trigger trg_jobs_updated_at
    before update on public.jobs
    for each row execute function update_timestamp();

-- ------------------------------------------------------------------------------
-- POLÍTICAS DE SEGURIDAD ROW LEVEL SECURITY (RLS)
-- ------------------------------------------------------------------------------

-- Habilitar RLS en todas las tablas
alter table public.customers enable row level security;
alter table public.jobs enable row level security;
alter table public.job_items enable row level security;
alter table public.qr_tokens enable row level security;

-- 1. Políticas de Lectura Pública (Permite escanear y ver trabajos/tokens públicamente)
create policy "Lectura pública de tokens QR"
    on public.qr_tokens for select
    using (true);

create policy "Lectura pública de trabajos"
    on public.jobs for select
    using (true);

create policy "Lectura pública de ítems de trabajo"
    on public.job_items for select
    using (true);

create policy "Lectura pública de clientes"
    on public.customers for select
    using (true);

-- 2. Políticas para Usuarios / Empleados (Permiten INSERT, UPDATE, DELETE para anon + authenticated o según auth)
-- Nota: Para facilitar la operación en el local, permitimos inserción y modificación libre en anon/authenticated,
-- pudiendo restringirse estrictamente a auth.role() = 'authenticated' si se desea.

create policy "Permitir crear y modificar tokens"
    on public.qr_tokens for all
    using (true)
    with check (true);

create policy "Permitir crear y modificar trabajos"
    on public.jobs for all
    using (true)
    with check (true);

create policy "Permitir crear y modificar ítems"
    on public.job_items for all
    using (true)
    with check (true);

create policy "Permitir crear y modificar clientes"
    on public.customers for all
    using (true)
    with check (true);
