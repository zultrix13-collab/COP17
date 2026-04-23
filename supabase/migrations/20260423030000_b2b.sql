-- Exhibitor profile extension (1:1 with profiles where tier='exhibitor').
create table public.exhibitor_profiles (
  user_id     uuid primary key references public.profiles(id) on delete cascade,
  company     text not null,
  sector      text,
  country     text,
  booth       text,
  website     text,
  logo_url    text,
  description_mn text,
  description_en text,
  created_at  timestamptz not null default now()
);

alter table public.exhibitor_profiles enable row level security;
create policy "exhibitor_read" on public.exhibitor_profiles for select
  using (auth.uid() is not null);
create policy "exhibitor_self_write" on public.exhibitor_profiles for all
  using (user_id = auth.uid() or public.is_admin())
  with check (user_id = auth.uid() or public.is_admin());

-- Convenience view: exhibitor + base profile, only for active exhibitor tier.
create or replace view public.exhibitors_view as
  select p.id as user_id, p.name as contact_name, p.email,
         e.company, e.sector, e.country, e.booth, e.website, e.logo_url,
         e.description_mn, e.description_en
  from public.profiles p
  join public.exhibitor_profiles e on e.user_id = p.id
  where p.tier = 'exhibitor';
