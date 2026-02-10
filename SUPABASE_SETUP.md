# Supabase Setup Guide for PulseBoard

This guide will walk you through setting up Supabase for PulseBoard, including authentication and database configuration.

## Prerequisites

- A Supabase account (free at https://supabase.com)
- Node.js 18+ installed
- The PulseBoard repository cloned

## Step-by-Step Setup

### 1. Create a Supabase Project

1. Go to [https://supabase.com](https://supabase.com)
2. Sign in with GitHub or email
3. Click "New project"
4. Fill in the form:
   - **Organization**: Select existing or create new
   - **Project name**: `pulseboard` (or your preferred name)
   - **Database Password**: Create a strong password and save it securely
   - **Region**: Choose the region closest to you
   - **Pricing Plan**: Select "Free" for development

5. Click "Create new project" and wait 2-3 minutes for initialization

### 2. Get API Keys

Once your project is ready:

1. In the Supabase dashboard, go to **Settings → API**
2. Copy these values:
   - **Project URL** (under "API URL"): Paste into `NEXT_PUBLIC_SUPABASE_URL`
   - **Anon/Public key**: Paste into `NEXT_PUBLIC_SUPABASE_ANON_KEY`
   - **Service Role Key** (under "Service Role Key"): Paste into `SUPABASE_SERVICE_ROLE_KEY`

### 3. Create Database Tables

1. In Supabase dashboard, go to the **SQL Editor**
2. Click "New Query"
3. Copy and paste the entire SQL schema from [PRODUCT_PLAN.md](../PRODUCT_PLAN.md) section B (Database Design)
4. Click "Run" to execute

**What this creates:**
- `profiles` table - Extended user info
- `projects` table - Project records
- `tasks` table - Task records
- Row Level Security (RLS) policies - Automatic data isolation per user
- Indexes - Query performance optimization

### 4. Enable and Configure Auth

1. Go to **Authentication → Providers**
2. Ensure **Email** provider is enabled with:
   - **Email/Password**: Enabled
   - **Autoconfirm users**: OFF (requires email confirmation)
   - **Confirm email**: ON
   
3. (Optional) Customize email templates in **Authentication → Email Templates**
   - Default templates work fine for MVP

### 5. Set Environment Variables in Next.js

1. Copy `.env.local.example` to `.env.local`:
   ```bash
   cp frontend/.env.local.example frontend/.env.local
   ```

2. Edit `frontend/.env.local` and paste your API keys:
   ```
   NEXT_PUBLIC_SUPABASE_URL=https://your-project-id.supabase.co
   NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJh...
   SUPABASE_SERVICE_ROLE_KEY=eyJh...
   ```

3. **Important**: Never commit `.env.local` to GitHub (it's already in `.gitignore`)

### 6. Insert Sample Data (Optional)

For testing, you can add sample data:

1. Go to **SQL Editor** in Supabase
2. Create a new query with this sample data SQL:

```sql
-- Insert sample projects for testing
-- Note: Replace auth.uid() with your actual user ID after signing up
insert into projects (user_id, name, description, status, priority, due_date) 
values
  (auth.uid(), 'Build Mobile App', 'React Native app for iOS/Android', 'active', 'high', now() + interval '30 days'),
  (auth.uid(), 'Website Redesign', 'Modernize company website', 'in_progress', 'medium', now() + interval '45 days'),
  (auth.uid(), 'API Integration', 'Connect to third-party payment API', 'todo', 'high', now() + interval '20 days'),
  (auth.uid(), 'Database Migration', 'Migrate from MySQL to PostgreSQL', 'completed', 'medium', now() - interval '5 days');

-- Insert sample tasks
-- Note: Run this after projects are created
insert into tasks (project_id, user_id, title, description, status, due_date)
select p.id, auth.uid(), 'Homepage design', 'Wireframe homepage', 'done', now() - interval '5 days'
from projects p where p.name = 'Website Redesign' limit 1
union all
select p.id, auth.uid(), 'Navigation component', 'Build responsive nav', 'in_progress', now() + interval '3 days'
from projects p where p.name = 'Website Redesign' limit 1
union all
select p.id, auth.uid(), 'Mobile optimization', 'Test on mobile browsers', 'todo', now() + interval '10 days'
from projects p where p.name = 'Website Redesign' limit 1;
```

**Note**: After you sign up in the app, you can find your user ID in:
- Supabase → Authentication → Users → Copy your user ID
- Then replace `auth.uid()` with your actual ID in the above SQL

### 7. Test the Setup

1. Install dependencies:
   ```bash
   cd frontend
   npm install
   ```

2. Start the development server:
   ```bash
   npm run dev
   ```

3. Open http://localhost:3000
4. Click "Get Started" or "Sign Up"
5. Create an account with your email
6. Check your email for confirmation link (or use the link in Supabase dashboard for testing)
7. After confirming, you should be able to create projects and tasks

## Troubleshooting

### "Invalid API key" or 401 errors
- Check that your `NEXT_PUBLIC_SUPABASE_ANON_KEY` is correctly set in `.env.local`
- Verify the key is from the "Anon/Public" section, not "Service Role"
- Restart the dev server after changing `.env` files

### Can't sign up or authentication errors
- Check that Email provider is enabled in **Authentication → Providers**
- Make sure "Confirm email" is enabled if you want email confirmations
- Check the Supabase dashboard logs: **Logs → Auth**

### "Relation does not exist" errors
- Make sure you ran all the SQL from section B (Database Design)
- Verify in **Database → Tables** that `projects`, `tasks`, and `profiles` exist
- Check table column names match the SQL exactly

### RLS Policy errors
- If you can't view your own projects, RLS policies may be wrong
- Go to **Authentication → Policies** and verify they exist
- Re-run the RLS creation SQL from section B

### Email confirmation not working
- In development, you can use Supabase's email link directly:
  - Go to **Authentication → Users**
  - Find your user
  - Copy the confirmation link from the user details
  - Paste in browser to confirm
- Or disable "Confirm email" for development (not recommended for production)

## Security Best Practices

✅ **DO:**
- Keep `SUPABASE_SERVICE_ROLE_KEY` secret (server-side only)
- Use `NEXT_PUBLIC_SUPABASE_ANON_KEY` for client-side ("public" is safe)
- Enable RLS on all tables (schema includes this)
- Regularly rotate your API keys
- Review access logs in Supabase dashboard

❌ **DON'T:**
- Commit `.env.local` to GitHub
- Expose `SUPABASE_SERVICE_ROLE_KEY` in client-side code
- Disable RLS for convenience
- Use weak database passwords

## Next Steps

1. Start the app: `npm run dev`
2. Sign up for an account
3. Create your first project
4. Add tasks to the project
5. View the dashboard with charts

For more information, see [PRODUCT_PLAN.md](../PRODUCT_PLAN.md)

## Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Auth Guide](https://supabase.com/docs/guides/auth)
- [PulseBoard Product Plan](../PRODUCT_PLAN.md)
- [Next.js Documentation](https://nextjs.org/docs)
