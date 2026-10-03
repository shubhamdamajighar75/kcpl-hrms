-- KOTHARI HYUNDAI HRMS v2
create extension if not exists pgcrypto;

create table if not exists public.branches(
 id uuid primary key default gen_random_uuid(), name text unique not null, address text, active boolean default true, created_at timestamptz default now());

create table if not exists public.departments(
 id uuid primary key default gen_random_uuid(), name text unique not null, active boolean default true, created_at timestamptz default now());

create table if not exists public.designations(
 id uuid primary key default gen_random_uuid(), name text not null, department_id uuid references public.departments(id) on delete set null, active boolean default true, created_at timestamptz default now(), unique(name,department_id));

create table if not exists public.user_profiles(
 id uuid primary key references auth.users(id) on delete cascade, username text unique, mobile text unique, full_name text not null, role text not null default 'Employee', branch_id uuid references public.branches(id) on delete set null, active boolean default true, created_at timestamptz default now());

create table if not exists public.employees(
 id uuid primary key default gen_random_uuid(), employee_code text unique not null, full_name text not null, mobile text, email text, gender text, department text, designation text, branch text, joining_date date, employment_type text default 'Permanent', bank_account text, ifsc text, emergency_contact text, status text default 'Active', created_at timestamptz default now(), updated_at timestamptz default now());

create table if not exists public.attendance(
 id uuid primary key default gen_random_uuid(), employee_id uuid not null references public.employees(id) on delete cascade, attendance_date date not null, status text not null default 'Present', check_in time, check_out time, remarks text, created_at timestamptz default now(), unique(employee_id,attendance_date));

create table if not exists public.leave_types(
 id uuid primary key default gen_random_uuid(), name text unique not null, annual_limit numeric default 0, active boolean default true);

create table if not exists public.leave_balances(
 id uuid primary key default gen_random_uuid(), employee_id uuid references public.employees(id) on delete cascade, leave_type_id uuid references public.leave_types(id) on delete cascade, year int not null, opening numeric default 0, credited numeric default 0, used numeric default 0, balance numeric generated always as (opening+credited-used) stored, unique(employee_id,leave_type_id,year));

create table if not exists public.leave_requests(
 id uuid primary key default gen_random_uuid(), employee_id uuid references public.employees(id) on delete cascade, leave_type text not null, from_date date not null, to_date date not null, days numeric not null, reason text, status text default 'Pending', approved_by uuid references auth.users(id), created_at timestamptz default now());

create table if not exists public.salary_structures(
 id uuid primary key default gen_random_uuid(), employee_id uuid unique references public.employees(id) on delete cascade, basic numeric default 0, hra numeric default 0, allowances numeric default 0, pf numeric default 0, esic numeric default 0, professional_tax numeric default 0, tds numeric default 0, effective_from date, created_at timestamptz default now());

create table if not exists public.payroll(
 id uuid primary key default gen_random_uuid(), employee_id uuid references public.employees(id) on delete cascade, payroll_month date not null, gross_salary numeric default 0, total_deductions numeric default 0, net_salary numeric default 0, status text default 'Draft', processed_by uuid references auth.users(id), created_at timestamptz default now(), unique(employee_id,payroll_month));

create table if not exists public.employee_documents(
 id uuid primary key default gen_random_uuid(), employee_id uuid references public.employees(id) on delete cascade, document_type text not null, file_path text, file_name text, uploaded_by uuid references auth.users(id), created_at timestamptz default now());

create table if not exists public.performance_goals(
 id uuid primary key default gen_random_uuid(), employee_id uuid references public.employees(id) on delete cascade, title text not null, description text, target numeric, achieved numeric default 0, cycle text, status text default 'Open', created_at timestamptz default now());

create table if not exists public.performance_reviews(
 id uuid primary key default gen_random_uuid(), employee_id uuid references public.employees(id) on delete cascade, reviewer_id uuid references auth.users(id), cycle text, score numeric, comments text, created_at timestamptz default now());

create table if not exists public.audit_logs(
 id uuid primary key default gen_random_uuid(), user_id uuid references auth.users(id), action text not null, table_name text, record_id uuid, details jsonb, created_at timestamptz default now());

-- Security
do $$ declare t text; begin
 for t in select unnest(array['branches','departments','designations','user_profiles','employees','attendance','leave_types','leave_balances','leave_requests','salary_structures','payroll','employee_documents','performance_goals','performance_reviews','audit_logs']) loop
   execute format('alter table public.%I enable row level security',t);
 end loop; end $$;

create or replace function public.current_user_role()
returns text language sql stable security definer set search_path=public
as $$ select role from public.user_profiles where id=auth.uid() limit 1 $$;

create or replace function public.current_user_branch()
returns uuid language sql stable security definer set search_path=public
as $$ select branch_id from public.user_profiles where id=auth.uid() limit 1 $$;

-- Read access for authenticated HRMS users
drop policy if exists auth_read_branches on public.branches;
create policy auth_read_branches on public.branches for select to authenticated using (true);
drop policy if exists auth_read_departments on public.departments;
create policy auth_read_departments on public.departments for select to authenticated using (true);
drop policy if exists auth_read_designations on public.designations;
create policy auth_read_designations on public.designations for select to authenticated using (true);
drop policy if exists auth_read_profiles on public.user_profiles;
create policy auth_read_profiles on public.user_profiles for select to authenticated using (id=auth.uid());

-- Employees: HR can manage; branch managers can read their branch
drop policy if exists employee_read on public.employees;
create policy employee_read on public.employees for select to authenticated using (
 public.current_user_role() in ('Super Admin','HR Admin','HR Executive','Accounts','Viewer') or
 (public.current_user_role()='Branch Manager' and branch=coalesce((select name from public.branches where id=public.current_user_branch()),''))
 or (email=(select email from auth.users where id=auth.uid()))
);
drop policy if exists employee_write on public.employees;
create policy employee_write on public.employees for all to authenticated using (
 public.current_user_role() in ('Super Admin','HR Admin','HR Executive'))
with check (public.current_user_role() in ('Super Admin','HR Admin','HR Executive'));

-- Attendance
drop policy if exists attendance_read on public.attendance;
create policy attendance_read on public.attendance for select to authenticated using (true);
drop policy if exists attendance_write on public.attendance;
create policy attendance_write on public.attendance for all to authenticated using (
 public.current_user_role() in ('Super Admin','HR Admin','HR Executive','Branch Manager'))
with check (public.current_user_role() in ('Super Admin','HR Admin','HR Executive','Branch Manager'));

-- Leave
drop policy if exists leave_read on public.leave_requests;
create policy leave_read on public.leave_requests for select to authenticated using (true);
drop policy if exists leave_insert on public.leave_requests;
create policy leave_insert on public.leave_requests for insert to authenticated with check (true);
drop policy if exists leave_update on public.leave_requests;
create policy leave_update on public.leave_requests for update to authenticated using (
 public.current_user_role() in ('Super Admin','HR Admin','HR Executive','Branch Manager'))
with check (public.current_user_role() in ('Super Admin','HR Admin','HR Executive','Branch Manager'));

-- Payroll/documents/performance restricted to HR/Accounts where applicable
drop policy if exists payroll_read on public.payroll;
create policy payroll_read on public.payroll for select to authenticated using (
 public.current_user_role() in ('Super Admin','HR Admin','Accounts') or employee_id in (select id from public.employees where email=(select email from auth.users where id=auth.uid()))
);
drop policy if exists payroll_write on public.payroll;
create policy payroll_write on public.payroll for all to authenticated using (
 public.current_user_role() in ('Super Admin','HR Admin','Accounts'))
with check (public.current_user_role() in ('Super Admin','HR Admin','Accounts'));

-- Storage bucket for HR documents
insert into storage.buckets(id,name,public) values ('hr-documents','hr-documents',false)
on conflict(id) do nothing;

-- Seed branches
insert into public.branches(name) values
('Kothari Hyundai'),('Bhilarwadi'),('SSR Road'),('Kondhwa'),('Khedshivapur'),('Kharadi'),('Fatimanagar'),('Aundh'),('Shirur'),('Bhosori'),('Hadapsar')
on conflict(name) do nothing;

insert into public.departments(name) values
('HR'),('Accounts'),('Sales'),('Service'),('Parts'),('Administration')
on conflict(name) do nothing;

insert into public.leave_types(name,annual_limit) values
('Casual Leave',12),('Sick Leave',12),('Privilege Leave',15),('Unpaid Leave',0)
on conflict(name) do nothing;

-- Create an Auth user first, then link it:
-- insert into public.user_profiles(id,username,mobile,full_name,role,branch_id)
-- values ('AUTH_USER_UUID','admin','9999999999','HR Admin','Super Admin',
-- (select id from public.branches where name='Kothari Hyundai'));
