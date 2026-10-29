-- Ejecutar en Supabase SQL Editor. Crear usuarios en Authentication.
create table if not exists public.profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 full_name text not null default '', role text not null default 'supervisor' check(role in ('admin','supervisor'))
);
create table if not exists public.projects (
 id uuid primary key default gen_random_uuid(), name text not null, responsible text not null default '',
 start_date date, end_date date, planned_progress integer not null default 0 check(planned_progress between 0 and 100),
 created_at timestamptz not null default now()
);
create table if not exists public.reports (
 id uuid primary key default gen_random_uuid(), project_id uuid not null references public.projects(id) on delete cascade,
 user_id uuid not null references auth.users(id), report_date date not null,
 responsible text not null, entry_time time, meal_time time, exit_time time,
 progress integer not null check(progress between 0 and 100), activities text not null default '',
 missing_materials text not null default '', pending_activities text not null default '',
 created_at timestamptz not null default now(), unique(project_id, user_id, report_date)
);
create table if not exists public.report_photos (
 id uuid primary key default gen_random_uuid(), report_id uuid not null references public.reports(id) on delete cascade,
 storage_path text not null, created_at timestamptz not null default now()
);
create or replace function public.is_admin() returns boolean language sql stable security definer set search_path=public as $$
 select exists(select 1 from public.profiles where id=(select auth.uid()) and role='admin');
$$;
create or replace function public.is_member() returns boolean language sql stable security definer set search_path=public as $$
 select exists(select 1 from public.profiles where id=(select auth.uid()));
$$;
alter table public.profiles enable row level security;
alter table public.projects enable row level security;
alter table public.reports enable row level security;
alter table public.report_photos enable row level security;
create policy "profiles read self or admin" on public.profiles for select to authenticated using(id=(select auth.uid()) or public.is_admin());
create policy "projects read members" on public.projects for select to authenticated using(public.is_member());
create policy "projects admin insert" on public.projects for insert to authenticated with check(public.is_admin());
create policy "projects admin update" on public.projects for update to authenticated using(public.is_admin()) with check(public.is_admin());
create policy "reports read members" on public.reports for select to authenticated using(public.is_member());
create policy "reports insert own" on public.reports for insert to authenticated with check(public.is_member() and user_id=(select auth.uid()));
create policy "reports update own or admin" on public.reports for update to authenticated using(user_id=(select auth.uid()) or public.is_admin()) with check(user_id=(select auth.uid()) or public.is_admin());
create policy "photos read members" on public.report_photos for select to authenticated using(public.is_member());
create policy "photos insert report owner" on public.report_photos for insert to authenticated with check(exists(select 1 from public.reports r where r.id=report_id and r.user_id=(select auth.uid())));
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types) values ('evidencias','evidencias',false,10485760,array['image/jpeg','image/png','image/webp']) on conflict(id) do nothing;
create policy "evidencias read members" on storage.objects for select to authenticated using(bucket_id='evidencias' and public.is_member());
create policy "evidencias upload own folder" on storage.objects for insert to authenticated with check(bucket_id='evidencias' and public.is_member() and (storage.foldername(name))[1]=(select auth.uid())::text);
-- Tras crear el primer usuario en Authentication, asignarle rol administrador:
-- insert into public.profiles(id,full_name,role) values ('UUID_DEL_USUARIO','Administración ACESA','admin');
-- Los demás usuarios deben registrarse en profiles con rol supervisor.
