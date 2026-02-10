-- ===================================================
-- PulseBoard - Sample Data Insert Script
-- ===================================================

-- IMPORTANT: Before running this script:
-- 1. Create a test user via the frontend signup, OR
-- 2. Create a test user via Supabase Auth Console
-- 3. Replace '2a64bc16-0a29-496f-bc0b-255cfd901696' below with the actual user UUID

-- ===================================================
-- METHOD 1: If you know your user ID
-- ===================================================

-- First, verify your user exists:
-- SELECT id, email FROM auth.users LIMIT 1;

-- Then replace the user_id value below with your actual user ID
-- Format: 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx' (UUID in single quotes)

INSERT INTO public.projects (user_id, name, description, status, priority, due_date) 
VALUES 
  ('2a64bc16-0a29-496f-bc0b-255cfd901696', 'Build Mobile App', 'React Native app for iOS/Android', 'active', 'high', now() + interval '30 days'),
  ('2a64bc16-0a29-496f-bc0b-255cfd901696', 'Website Redesign', 'Modernize company website', 'active', 'medium', now() + interval '45 days'),
  ('2a64bc16-0a29-496f-bc0b-255cfd901696', 'API Integration', 'Connect to third-party payment API', 'active', 'high', now() + interval '20 days'),
  ('2a64bc16-0a29-496f-bc0b-255cfd901696', 'Database Migration', 'Migrate from MySQL to PostgreSQL', 'completed', 'medium', now() - interval '5 days');

-- Insert sample tasks (update project_id as needed)
-- IMPORTANT: You must get your project IDs first!
-- Step 1: Run this query to get the project IDs:
-- SELECT id, name FROM public.projects;
-- Step 2: Copy each project uuid and replace '3a0c2cd3-7bc5-4bb3-b554-01a46efef478', 'b695cbcf-997e-48c9-ad94-89cf5d94b92f' etc below
-- Step 3: Then uncomment and run the INSERT statements

-- Example - replace these UUIDs with your actual project IDs:
-- INSERT INTO public.tasks (project_id, user_id, title, description, status, due_date)
-- VALUES
--   ('3a0c2cd3-7bc5-4bb3-b554-01a46efef478', '2a64bc16-0a29-496f-bc0b-255cfd901696', 'Homepage design', 'Wireframe homepage', 'done', now() - interval '5 days'),
--   ('3a0c2cd3-7bc5-4bb3-b554-01a46efef478', '2a64bc16-0a29-496f-bc0b-255cfd901696', 'Navigation component', 'Build responsive nav', 'in_progress', now() + interval '3 days'),
--   ('3a0c2cd3-7bc5-4bb3-b554-01a46efef478', '2a64bc16-0a29-496f-bc0b-255cfd901696', 'Mobile optimization', 'Test on mobile browsers', 'todo', now() + interval '10 days'),
--   ('b695cbcf-997e-48c9-ad94-89cf5d94b92f', '2a64bc16-0a29-496f-bc0b-255cfd901696', 'Task management system', 'Add task CRUD features', 'in_progress', now() + interval '7 days'),
--   ('b695cbcf-997e-48c9-ad94-89cf5d94b92f', '2a64bc16-0a29-496f-bc0b-255cfd901696', 'API testing', 'Write unit tests for API', 'todo', now() + interval '14 days');

-- ===================================================
-- METHOD 2: Automated - Get user by email
-- ===================================================
-- If you signed up with test@example.com, you can use this approach:
-- Uncomment and run these commands ONE BY ONE:

-- Step 1: Find your user ID by email
-- SELECT id FROM auth.users WHERE email = 'test@example.com';
-- (Copy the ID that appears, then paste it into the INSERT statements above)

-- ===================================================
-- METHOD 3: For Testing/Development
-- ===================================================
-- If you need to create a test user programmatically via Supabase CLI:
-- supabase sql --project-id YOUR_PROJECT_ID -f seed.sql

-- The seed file would contain:
/*
-- Create test user (requires service_role key)
insert into auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at
) values (
  '00000000-0000-0000-0000-000000000000',
  'a1234567-1234-1234-1234-123456789abc',
  'authenticated',
  'authenticated',
  'demo@pulseboard.com',
  crypt('demo123456', gen_salt('bf')),
  now(),
  now(),
  now()
);

-- Create profile for test user
insert into public.profiles (id, email, full_name, role) values (
  'a1234567-1234-1234-1234-123456789abc',
  'demo@pulseboard.com',
  'Demo User',
  'admin'
);

-- Then insert projects/tasks using the test user ID
insert into public.projects (user_id, name, description, status, priority, due_date) 
values 
  ('a1234567-1234-1234-1234-123456789abc', 'Build Mobile App', 'React Native app', 'active', 'high', now() + interval '30 days'),
  ('a1234567-1234-1234-1234-123456789abc', 'Website Redesign', 'Modernize website', 'in_progress', 'medium', now() + interval '45 days'),
  ('a1234567-1234-1234-1234-123456789abc', 'API Integration', 'Third-party API', 'todo', 'high', now() + interval '20 days'),
  ('a1234567-1234-1234-1234-123456789abc', 'Database Migration', 'MySQL to PostgreSQL', 'completed', 'medium', now() - interval '5 days');
*/

-- ===================================================
-- RECOMMENDED APPROACH FOR YOU
-- ===================================================
-- 1. Go to Supabase dashboard → Authentication → Users
-- 2. Find your user email and copy the UUID (id column)
-- 3. Replace '2a64bc16-0a29-496f-bc0b-255cfd901696' with that UUID in the INSERT statements above
-- 4. Go to SQL Editor
-- 5. Run the INSERT statements (not the SELECT ones)
-- 6. Verify in the Table Editor that data was inserted

-- ===================================================
-- QUICK LOOKUP QUERIES
-- ===================================================
-- Uncomment any of these to verify your setup:

-- Find your user ID:
-- SELECT id, email, created_at FROM auth.users;

-- Get all your projects:
-- SELECT * FROM public.projects;

-- Get all your tasks:
-- SELECT * FROM public.tasks;

-- Get project with task count:
-- SELECT 
--   p.id,
--   p.name, 
--   p.status,
--   COUNT(t.id) as task_count
-- FROM projects p
-- LEFT JOIN tasks t ON p.id = t.project_id
-- GROUP BY p.id
-- ORDER BY p.created_at DESC;
