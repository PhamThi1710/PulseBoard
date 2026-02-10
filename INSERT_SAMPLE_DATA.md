# How to Insert Sample Data

## Problem
The original SQL script fails because `auth.uid()` returns NULL when running in Supabase SQL Editor (it only works in protected functions/RLS policies).

## Solution - 3 Steps

### Step 1: Find Your User ID

**Option A: Via Frontend (Recommended)**
1. Go to your app at `http://localhost:3000`
2. Click "Register" and create a test account with any email/password
3. You're now logged in (if you see the dashboard, auth worked!)
4. Proceed to Step 2

**Option B: Via Supabase Dashboard**
1. Log in to [supabase.com](https://supabase.com)
2. Go to your PulseBoard project → Authentication → Users
3. Look for your user email in the list
4. Copy the **UUID** in the `id` column (it looks like: `a1b2c3d4-e5f6-7890-abcd-ef1234567890`)
5. Proceed to Step 2

### Step 2: Get Your Project IDs

After inserting projects, you need their IDs for tasks:

1. Go to Supabase Dashboard → SQL Editor
2. Run this query:
```sql
SELECT id, name FROM public.projects;
```
3. Copy the ID(s) for use in task inserts

### Step 3: Insert Sample Data

1. Open [SAMPLE_DATA.sql](./SAMPLE_DATA.sql)
2. Replace `'YOUR_USER_ID_HERE'` with your actual user UUID (from Step 1)
3. For tasks, also replace `'PROJECT_ID_HERE'` with actual project UUIDs (from Step 2)
4. Copy the modified INSERT statements
5. Go to Supabase Dashboard → SQL Editor
6. Paste and run the statements

## Complete Example

**Before:**
```sql
INSERT INTO public.projects (user_id, name, description, status, priority, due_date) 
VALUES 
  ('YOUR_USER_ID_HERE', 'Build Mobile App', ...
```

**After (with real UUIDs):**
```sql
INSERT INTO public.projects (user_id, name, description, status, priority, due_date) 
VALUES 
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'Build Mobile App', ...
```

## Verify It Worked

After inserting, run these in SQL Editor to verify:

```sql
-- Check projects were inserted
SELECT COUNT(*) as project_count FROM public.projects;

-- Check tasks were inserted
SELECT COUNT(*) as task_count FROM public.tasks;

-- View all projects with task counts
SELECT 
  p.name, 
  p.status, 
  COUNT(t.id) as tasks
FROM projects p
LEFT JOIN tasks t ON p.id = t.project_id
GROUP BY p.id, p.name, p.status;
```

## Troubleshooting

**Error: "null value in column user_id"**
- You didn't replace `YOUR_USER_ID_HERE` with your actual user ID
- Make sure it's wrapped in single quotes: `'a1b2c3d4-...'`

**Error: "violates foreign key constraint"**
- The project_id for tasks doesn't exist
- Run `SELECT id FROM public.projects;` to see valid project IDs
- Make sure project exists BEFORE creating tasks for it

**Error: "column user_id does not exist"**
- Table creation failed - re-run the SQL schema from SUPABASE_SETUP.md

**Data not showing in dashboard**
- Try logging out/in to refresh
- Check browser console for errors
- Verify RLS policies are enabled: `SELECT * FROM information_schema.tables WHERE table_name in ('projects', 'tasks');`

## Testing Auth

Once data is inserted:
1. Visit dashboard: http://localhost:3000/dashboard
2. You should see your projects in the Projects list
3. Click on a project to see its tasks
4. Create another test user account
5. Verify they see DIFFERENT projects (data isolation works)
