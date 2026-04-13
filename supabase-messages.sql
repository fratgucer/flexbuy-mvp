create table if not exists public.conversations (
  id uuid primary key default gen_random_uuid(),
  buyer_id uuid not null references auth.users(id) on delete cascade,
  listing_ref text not null,
  seller_name text not null,
  seller_avatar text,
  seller_color text,
  listing_emoji text,
  listing_title text not null,
  listing_price numeric(10,2) not null default 0,
  listing_context text,
  last_message text default '',
  last_message_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  unique (buyer_id, listing_ref)
);

create table if not exists public.messages (
  id bigint generated always as identity primary key,
  conversation_id uuid not null references public.conversations(id) on delete cascade,
  sender_role text not null check (sender_role in ('buyer', 'seller')),
  body text not null default '',
  offer_amount numeric(10,2),
  created_at timestamptz not null default now()
);

create index if not exists conversations_buyer_last_message_idx on public.conversations (buyer_id, last_message_at desc);
create index if not exists messages_conversation_created_idx on public.messages (conversation_id, created_at asc);

alter table public.conversations enable row level security;
alter table public.messages enable row level security;

create policy "buyers can read their conversations"
on public.conversations
for select
to authenticated
using (auth.uid() = buyer_id);

create policy "buyers can create their conversations"
on public.conversations
for insert
to authenticated
with check (auth.uid() = buyer_id);

create policy "buyers can update their conversations"
on public.conversations
for update
to authenticated
using (auth.uid() = buyer_id)
with check (auth.uid() = buyer_id);

create policy "buyers can delete their conversations"
on public.conversations
for delete
to authenticated
using (auth.uid() = buyer_id);

create policy "buyers can read messages in their conversations"
on public.messages
for select
to authenticated
using (
  exists (
    select 1
    from public.conversations
    where conversations.id = messages.conversation_id
      and conversations.buyer_id = auth.uid()
  )
);

create policy "buyers can create messages in their conversations"
on public.messages
for insert
to authenticated
with check (
  exists (
    select 1
    from public.conversations
    where conversations.id = messages.conversation_id
      and conversations.buyer_id = auth.uid()
  )
);
