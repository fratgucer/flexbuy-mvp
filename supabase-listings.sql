create table if not exists public.listings (
  id bigint generated always as identity primary key,
  owner_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  price numeric(10,2) not null check (price > 0),
  category text not null,
  condition text not null,
  location_label text not null,
  full_address text,
  street_label text,
  area_label text,
  description text default '',
  lat double precision,
  lng double precision,
  photos jsonb not null default '[]'::jsonb,
  emoji text,
  seller_name text not null,
  seller_rating text default '5.0 (new seller)',
  seller_listing_count integer not null default 0,
  status text not null default 'active',
  created_at timestamptz not null default now()
);

create index if not exists listings_created_at_idx on public.listings (created_at desc);
create index if not exists listings_owner_id_idx on public.listings (owner_id);
create index if not exists listings_category_idx on public.listings (category);

alter table public.listings enable row level security;

create policy "public can read active listings"
on public.listings
for select
using (status = 'active' or auth.uid() = owner_id);

create policy "authenticated users can create their listings"
on public.listings
for insert
to authenticated
with check (auth.uid() = owner_id);

create policy "owners can update their listings"
on public.listings
for update
to authenticated
using (auth.uid() = owner_id)
with check (auth.uid() = owner_id);

create policy "owners can delete their listings"
on public.listings
for delete
to authenticated
using (auth.uid() = owner_id);
