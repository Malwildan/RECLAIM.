/*
  RECLAIM DATABASE SCHEMA
  -----------------------
  This schema defines the structure for the Reclaim app, including user profiles,
  relapse tracking, journaling, panic mode logs, and motivational content.
*/

-- ============================================================================
-- 1. EXTENSIONS
-- ============================================================================

-- Enable UUID generation for primary keys
create extension if not exists "uuid-ossp";


-- ============================================================================
-- 2. TABLES
-- ============================================================================

-- 2.1 PROFILES
-- Links to Supabase Auth and stores user-specific app data
create table public.profiles (
  id uuid references auth.users not null primary key,
  username text unique,
  avatar_url text,
  current_streak_start timestamptz default now(), -- Baseline for streak calculation
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- 2.2 RELAPSES
-- Stores history of streak resets
create table public.relapses (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  occurred_at timestamptz default now() not null,
  trigger_source text, -- e.g., "Social Media", "Stress"
  location text,       -- e.g., "Home", "Work"
  notes text,          -- User reflections
  created_at timestamptz default now()
);

-- 2.3 JOURNALS
-- Daily check-ins and reflections
create table public.journals (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  title text,
  content text,        -- Consider client-side encryption for privacy
  mood_rating int check (mood_rating between 1 and 10),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- 2.4 PANIC LOGS
-- Tracks usage of the Panic Button feature
create table public.panic_logs (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  triggered_at timestamptz default now(),
  was_successful boolean default false -- True if relapse was prevented
);

-- 2.5 MOTIVATIONAL VIDEOS
-- Curated list of videos for Panic Mode
create table public.motivational_videos (
  id uuid default uuid_generate_v4() primary key,
  youtube_id text not null, -- The ID part after "v="
  title text,
  created_at timestamptz default now()
);


-- ============================================================================
-- 3. ROW LEVEL SECURITY (RLS)
-- ============================================================================

-- Enable RLS on all tables
alter table public.profiles enable row level security;
alter table public.relapses enable row level security;
alter table public.journals enable row level security;
alter table public.panic_logs enable row level security;
alter table public.motivational_videos enable row level security;

-- 3.1 PROFILES POLICIES
create policy "Public profiles are viewable by everyone" 
  on profiles for select using ( true );

create policy "Users can insert their own profile" 
  on profiles for insert with check ( auth.uid() = id );

create policy "Users can update own profile" 
  on profiles for update using ( auth.uid() = id );

-- 3.2 RELAPSES POLICIES
create policy "Users can see own relapses" 
  on relapses for select using ( auth.uid() = user_id );

create policy "Users can insert own relapses" 
  on relapses for insert with check ( auth.uid() = user_id );

-- 3.3 JOURNALS POLICIES
create policy "Users can see own journals" 
  on journals for select using ( auth.uid() = user_id );

create policy "Users can insert own journals" 
  on journals for insert with check ( auth.uid() = user_id );

create policy "Users can update own journals" 
  on journals for update using ( auth.uid() = user_id );

create policy "Users can delete own journals" 
  on journals for delete using ( auth.uid() = user_id );

-- 3.4 PANIC LOGS POLICIES
create policy "Users can see own panic logs" 
  on panic_logs for select using ( auth.uid() = user_id );

create policy "Users can insert own panic logs" 
  on panic_logs for insert with check ( auth.uid() = user_id );

-- 3.5 VIDEOS POLICIES
create policy "Videos are viewable by everyone" 
  on motivational_videos for select using ( true );


-- ============================================================================
-- 4. FUNCTIONS & TRIGGERS
-- ============================================================================

-- 4.1 HANDLE NEW USER
-- Automatically creates a profile when a user signs up
create or replace function public.handle_new_user() 
returns trigger as $$
begin
  insert into public.profiles (id, username, current_streak_start)
  values (new.id, new.raw_user_meta_data->>'username', now());
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- 4.2 AUTO-RESET STREAK
-- Updates profile streak start time when a relapse is logged
create or replace function public.reset_streak_counter()
returns trigger as $$
begin
  update public.profiles
  set current_streak_start = new.occurred_at
  where id = new.user_id;
  return new;
end;
$$ language plpgsql security definer;

create trigger on_relapse_logged
  after insert on public.relapses
  for each row execute procedure public.reset_streak_counter();


-- ============================================================================
-- 5. SEED DATA
-- ============================================================================

insert into public.motivational_videos (youtube_id, title)
values 
  ('Lp7E973zozc', 'Why do we fall'),
  ('mgmVOuLgFB0', 'Dream - Motivational'),
  ('ZtMm0swu5i8', 'Determination');
