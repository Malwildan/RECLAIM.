-- 1. ENABLE EXTENSIONS
-- We need this for UUID generation
create extension if not exists "uuid-ossp";

-- 2. CREATE PUBLIC PROFILES TABLE
-- This links to the Supabase built-in auth.users table
create table public.profiles (
  id uuid references auth.users not null primary key,
  username text unique,
  avatar_url text,
  current_streak_start timestamptz default now(), -- The baseline for calculating current streak
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- 3. CREATE RELAPSES TABLE
-- Stores data when a user resets their streak
create table public.relapses (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  occurred_at timestamptz default now() not null,
  trigger_source text, -- e.g., "Social Media", "Stress", "Boredom"
  location text, -- e.g., "Home", "Bathroom", "Work"
  notes text, -- User's reflection on why it happened
  created_at timestamptz default now()
);

-- 4. CREATE JOURNAL ENTRIES TABLE
-- For daily reflections or urged surfing writing
create table public.journals (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  title text,
  content text, -- NOTE: For max privacy, encrypt this Client-Side before sending!
  mood_rating int check (mood_rating between 1 and 10),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- 5. CREATE PANIC BUTTON LOGS
-- Tracks when the panic button was used and if it worked
create table public.panic_logs (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  triggered_at timestamptz default now(),
  was_successful boolean default false -- True if they didn't relapse immediately after
);

-- 6. SET UP ROW LEVEL SECURITY (RLS)
-- CRITICAL: This ensures users can ONLY see their own data.

-- Enable RLS on all tables
alter table public.profiles enable row level security;
alter table public.relapses enable row level security;
alter table public.journals enable row level security;
alter table public.panic_logs enable row level security;

-- Policies for Profiles
create policy "Public profiles are viewable by everyone" 
  on profiles for select using ( true ); -- (Optional: Change to auth.uid() = id if you want total privacy)

create policy "Users can insert their own profile" 
  on profiles for insert with check ( auth.uid() = id );

create policy "Users can update own profile" 
  on profiles for update using ( auth.uid() = id );

-- Policies for Relapses
create policy "Users can see own relapses" 
  on relapses for select using ( auth.uid() = user_id );

create policy "Users can insert own relapses" 
  on relapses for insert with check ( auth.uid() = user_id );

-- Policies for Journals
create policy "Users can see own journals" 
  on journals for select using ( auth.uid() = user_id );

create policy "Users can insert own journals" 
  on journals for insert with check ( auth.uid() = user_id );

create policy "Users can update own journals" 
  on journals for update using ( auth.uid() = user_id );

create policy "Users can delete own journals" 
  on journals for delete using ( auth.uid() = user_id );

-- Policies for Panic Logs
create policy "Users can see own panic logs" 
  on panic_logs for select using ( auth.uid() = user_id );

create policy "Users can insert own panic logs" 
  on panic_logs for insert with check ( auth.uid() = user_id );

-- 7. AUTOMATION (TRIGGERS)

-- Trigger A: Handle New User Signup
-- Automatically creates a profile entry when a user signs up via Supabase Auth
create function public.handle_new_user() 
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

-- Trigger B: Auto-Reset Streak
-- When a new Relapse is added, automatically update the Profile's "current_streak_start"
create function public.reset_streak_counter()
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