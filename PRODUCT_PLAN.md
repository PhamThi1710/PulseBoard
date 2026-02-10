# PulseBoard - SaaS Dashboard Product Plan

## A. Product & Feature Definition

### Product Idea: **PulseBoard** - Team Analytics & Project Dashboard

**Overview:** PulseBoard is a lightweight project management and team analytics dashboard that helps teams track projects, tasks, and team activity in real-time. It's designed for small to medium teams (5-50 people) who need visibility into project progress and team productivity.

### Main Pages & Features:

1. **Public Landing Page** (`/`)
   - Product overview
   - Features highlight
   - Call-to-action buttons (Sign In / Sign Up)

2. **Authentication Pages**
   - `/auth/login` - Email/password login
   - `/auth/register` - Email/password registration
   - `/auth/logout` - Logout action

3. **Protected Dashboard Area** (requires authentication)
   - `/dashboard` - Main dashboard with overview
   - `/dashboard/projects` - List all projects (CRUD)
   - `/dashboard/projects/[id]` - Project detail page
   - `/dashboard/projects/[id]/edit` - Edit project
   - `/dashboard/team` - Team members overview (read-only for MVP)

4. **Dashboard Features**
   - **Project Management (CRUD)**
     - Create new projects
     - View project list in table format
     - Edit project details
     - Delete projects
   
   - **Analytics & Charts**
     - Project completion status chart (Pie Chart)
     - Tasks created over time (Line Chart)
     - Team workload distribution (Bar Chart)
     - Project timeline (Gantt-like visualization)

5. **Core Entities**
   - **Projects**: Name, description, status (active/completed), priority, due date, created by
   - **Tasks**: Title, description, status (todo/in-progress/done), project_id, assigned_to, due date
   - **Team Members**: Name, email, role, created_at (managed via Auth)

---

## B. Database Design (Supabase)

### Tables Schema:

```sql
-- Users table (managed by Supabase Auth, but we extend with profile)
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text unique not null,
  full_name text,
  avatar_url text,
  role text default 'member',
  created_at timestamp default now(),
  updated_at timestamp default now()
);

-- Projects table
create table public.projects (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  description text,
  status text default 'active' check (status in ('active', 'completed', 'archived')),
  priority text default 'medium' check (priority in ('low', 'medium', 'high')),
  due_date timestamp,
  created_at timestamp default now(),
  updated_at timestamp default now()
);

-- Tasks table
create table public.tasks (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references projects(id) on delete cascade,
  user_id uuid not null references auth.users(id),
  title text not null,
  description text,
  status text default 'todo' check (status in ('todo', 'in_progress', 'done')),
  due_date timestamp,
  created_at timestamp default now(),
  updated_at timestamp default now()
);

-- Create indexes for better query performance
create index idx_projects_user_id on projects(user_id);
create index idx_projects_status on projects(status);
create index idx_tasks_project_id on tasks(project_id);
create index idx_tasks_status on tasks(status);
create index idx_tasks_user_id on tasks(user_id);

-- Enable RLS (Row Level Security)
alter table public.projects enable row level security;
alter table public.tasks enable row level security;
alter table public.profiles enable row level security;

-- RLS Policies for Projects
create policy "Users can view their own projects"
on public.projects for select
using (auth.uid() = user_id);

create policy "Users can insert their own projects"
on public.projects for insert
with check (auth.uid() = user_id);

create policy "Users can update their own projects"
on public.projects for update
using (auth.uid() = user_id);

create policy "Users can delete their own projects"
on public.projects for delete
using (auth.uid() = user_id);

-- RLS Policies for Tasks
create policy "Users can view tasks in their projects"
on public.tasks for select
using (
  exists (
    select 1 from projects 
    where projects.id = tasks.project_id 
    and projects.user_id = auth.uid()
  )
);

create policy "Users can insert tasks in their projects"
on public.tasks for insert
with check (
  exists (
    select 1 from projects 
    where projects.id = project_id 
    and projects.user_id = auth.uid()
  )
);

create policy "Users can update tasks in their projects"
on public.tasks for update
using (
  exists (
    select 1 from projects 
    where projects.id = project_id 
    and projects.user_id = auth.uid()
  )
);

create policy "Users can delete tasks in their projects"
on public.tasks for delete
using (
  exists (
    select 1 from projects 
    where projects.id = project_id 
    and projects.user_id = auth.uid()
  )
);

-- RLS Policies for Profiles
create policy "Users can view all profiles"
on public.profiles for select
using (true);

create policy "Users can update their own profile"
on public.profiles for update
using (auth.uid() = id);
```

### Sample Data Insert:

```sql
-- Insert sample projects for testing
insert into projects (user_id, name, description, status, priority, due_date) 
select auth.uid(), * from (values
  ('Build Mobile App', 'React Native app for iOS/Android', 'active', 'high', now() + interval '30 days'),
  ('Website Redesign', 'Modernize company website', 'in_progress', 'medium', now() + interval '45 days'),
  ('API Integration', 'Connect to third-party payment API', 'todo', 'high', now() + interval '20 days'),
  ('Database Migration', 'Migrate from MySQL to PostgreSQL', 'completed', 'medium', now() - interval '5 days')
) as data(name, description, status, priority, due_date);

-- Insert sample tasks
insert into tasks (project_id, user_id, title, description, status, due_date)
select p.id, auth.uid(), * from (
  select 'Homepage design' as title, 'Wireframe homepage' as description, 'done' as status, now() - interval '5 days' as due_date
  union all
  select 'Navigation component', 'Build responsive nav', 'in_progress', now() + interval '3 days'
  union all
  select 'Mobile optimization', 'Test on mobile browsers', 'todo', now() + interval '10 days'
) data, (select id from projects limit 1) p;
```

---

## C. Supabase Setup Guide

### Step 1: Create Supabase Project
1. Go to [https://supabase.com](https://supabase.com)
2. Sign up or log in
3. Click "New project"
4. Choose organization (or create new)
5. Project name: `pulseboard`
6. Database password: Save securely
7. Region: Choose closest to you
8. Wait for project to initialize (2-3 minutes)

### Step 2: Get API Keys
1. In Supabase dashboard, go to Settings → API
2. Copy:
   - **NEXT_PUBLIC_SUPABASE_URL** (Project URL)
   - **NEXT_PUBLIC_SUPABASE_ANON_KEY** (Anon key)
   - **SUPABASE_SERVICE_ROLE_KEY** (Service role - keep secret!)

### Step 3: Create Tables
1. Go to SQL Editor in Supabase
2. Run the SQL schema from section B above

### Step 4: Setup Auth
1. Go to Authentication → Providers
2. Enable Email provider:
   - Auth Type: Email (password)
   - Autoconfirm users: OFF (for production)
   - Confirm email: ON
3. Go to Settings → Email Templates
4. Customize confirmation email (or use defaults for MVP)

### Step 5: Security - Enable RLS
Already included in SQL above, but verify:
1. Go to Authentication → Policies
2. Ensure RLS is enabled on all tables
3. Test policies work correctly

### Step 6: Environment Variables
Create `.env.local` in `/frontend`:

```bash
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJh...your_anon_key...
SUPABASE_SERVICE_ROLE_KEY=eyJh...your_service_role_key...
```

---

## D. Frontend Architecture (Next.js App Router)

### Folder Structure:

```
frontend/src/
├── app/
│   ├── (public)/
│   │   ├── page.tsx (Landing page /)
│   │   ├── layout.tsx
│   │   └── globals.css
│   ├── auth/
│   │   ├── login/page.tsx
│   │   ├── register/page.tsx
│   │   └── layout.tsx
│   ├── dashboard/
│   │   ├── layout.tsx (Protected layout)
│   │   ├── page.tsx (Dashboard home)
│   │   ├── projects/
│   │   │   ├── page.tsx (Projects list)
│   │   │   ├── new/page.tsx (Create project)
│   │   │   └── [id]/
│   │   │       ├── page.tsx (Project detail)
│   │   │       └── edit/page.tsx (Edit project)
│   │   └── team/page.tsx
│   └── error.tsx, not-found.tsx
│
├── components/
│   ├── auth/
│   │   ├── LoginForm.tsx
│   │   ├── RegisterForm.tsx
│   │   └── LogoutButton.tsx
│   ├── dashboard/
│   │   ├── DashboardHeader.tsx
│   │   ├── Sidebar.tsx
│   │   └── ProjectList.tsx
│   ├── projects/
│   │   ├── ProjectForm.tsx
│   │   └── ProjectCard.tsx
│   ├── tasks/
│   │   ├── TaskForm.tsx
│   │   └── TaskList.tsx
│   ├── charts/
│   │   ├── ProjectStatusChart.tsx
│   │   ├── TaskTimelineChart.tsx
│   │   └── TeamWorkloadChart.tsx
│   └── ui/
│       └── [shadcn/ui components]
│
├── services/
│   ├── supabase/
│   │   ├── client.ts (Supabase client)
│   │   ├── server.ts (Server-side client)
│   │   └── types.ts (Database types)
│   ├── auth.ts (Auth helpers)
│   ├── projects.ts (Project CRUD)
│   └── tasks.ts (Task CRUD)
│
├── hooks/
│   ├── useAuth.ts
│   ├── useProjects.ts
│   └── useUser.ts
│
├── lib/
│   ├── utils.ts (Utility functions)
│   ├── constants.ts (App constants)
│   └── validation.ts (Input validation)
│
└── types/
    └── index.ts (TypeScript types)
```

### Key Architectural Decisions:

1. **Auth Strategy**: Use Supabase Auth with middleware for protected routes
2. **Data Fetching**: Server Actions for mutations, Server Components for data fetching
3. **State Management**: React hooks + Supabase real-time (no Redux needed for MVP)
4. **API Pattern**: Prefer Server Actions over API routes for simplicity
5. **Component Strategy**: Server Components by default, Client Components only when needed
6. **Type Safety**: Full TypeScript with generated types from Supabase

---

## E. UI & Design System

### Layout System:

**Dashboard Layout:**
```
┌─────────────────────────────────────┐
│         Header                      │
├──────────┬──────────────────────────┤
│          │                          │
│ Sidebar  │   Main Content Area      │
│ (240px)  │   (Fill remaining)       │
│          │                          │
│          │                          │
└──────────┴──────────────────────────┘
```

**Page Sections:**
- Header: Navigation, user menu, breadcrumbs
- Sidebar: Navigation, quick links, user status
- Content: Full width, with padding
- Footer: Optional, for secondary info

### Spacing Scale (Tailwind):

- `xs`: 0.25rem (4px)
- `sm`: 0.5rem (8px)
- `md`: 1rem (16px)
- `lg`: 1.5rem (24px)
- `xl`: 2rem (32px)
- `2xl`: 3rem (48px)

CSS: Use `gap`, `p`, `m` utilities for spacing

### Typography Scale:

- **Page Title (H1)**: `text-3xl md:text-4xl` font-bold leading-tight
- **Section Title (H2)**: `text-2xl` font-semibold
- **Subsection (H3)**: `text-xl` font-semibold
- **Body Text**: `text-base` leading-6 text-gray-700
- **Small Text**: `text-sm` text-gray-600
- **Labels**: `text-sm` font-medium text-gray-600

### Color System:

**Semantic Colors:**
- **Primary**: Indigo 600 (`#4f46e5`) - Main actions, highlights
- **Success**: Emerald 500 (`#10b981`) - Done, completed, positive
- **Warning**: Amber 500 (`#f59e0b`) - In progress, pending
- **Danger**: Red 500 (`#ef4444`) - Errors, delete actions
- **Info**: Blue 500 (`#3b82f6`) - Information, notes

**Neutral Colors:**
- Background: White (`#ffffff`)
- Surface: Gray 50 (`#f9fafb`)
- Border: Gray 200 (`#e5e7eb`)
- Text: Gray 900 (`#111827`)

### Component Design Principles:

1. **Reusability**: Components should work across pages
2. **Composability**: Small components combine into larger ones
3. **Figma-Ready**: Clear naming, consistent props, documented in Storybook format
4. **Accessibility**: Semantic HTML, ARIA labels, keyboard navigation
5. **Responsive**: Mobile-first, breakpoints at sm (640px), md (768px), lg (1024px)

### Reusable Component Structure:

```tsx
// ComponentName.tsx - Export as default, with TypeScript props
export interface ComponentProps {
  // Props are minimal and clear
  variant?: 'primary' | 'secondary';
  size?: 'sm' | 'md' | 'lg';
  disabled?: boolean;
  children: React.ReactNode;
}

export default function Component({ ... }: ComponentProps) {
  return (/* JSX */)
}
```

This structure makes it easy to document in Figma:
- **Component Name**: `Component`
- **Variants**: `variant`, `size`, `disabled`
- **Props**: Documented as variant options

---

## F. Implementation Steps (7-10 Days)

### Day 1-2: Setup & Infrastructure
- [ ] Install dependencies (shadcn/ui, recharts, supabase-js)
- [ ] Configure Supabase project and get API keys
- [ ] Create database schema and RLS policies
- [ ] Setup environment variables
- [ ] Create Supabase client (browser + server)
- [ ] Setup middleware for route protection

### Day 3: Authentication
- [ ] Create auth service layer
- [ ] Build Login page UI
- [ ] Build Register page UI
- [ ] Implement sign in/up logic with Supabase Auth
- [ ] Create Protected layout with auth check
- [ ] Implement logout functionality
- [ ] Test auth flow end-to-end

### Day 4: Landing Page & Navigation
- [ ] Design landing page layout
- [ ] Build public layout (header, hero, footer)
- [ ] Create Dashboard header & sidebar
- [ ] Setup breadcrumb navigation
- [ ] Build user menu in header

### Day 5: Projects CRUD
- [ ] Build Projects list page with table
- [ ] Implement fetch projects from Supabase
- [ ] Create project creation form & page
- [ ] Implement create project action
- [ ] Create edit project form
- [ ] Implement update/delete actions
- [ ] Add UI feedback (loading, errors, success)

### Day 6: Tasks & Detail Pages
- [ ] Build project detail page
- [ ] Display tasks in project detail
- [ ] Create task form (create/edit)
- [ ] Implement task CRUD actions
- [ ] Add task status filtering
- [ ] Build task list component

### Day 7: Charts & Analytics
- [ ] Setup Recharts
- [ ] Create ProjectStatusChart (pie chart)
- [ ] Create TaskTimelineChart (line chart)
- [ ] Create TeamWorkloadChart (bar chart)
- [ ] Fetch real data from Supabase for each chart
- [ ] Add date range filtering (optional)

### Day 8: Polish & UX
- [ ] Style components with Tailwind
- [ ] Ensure consistent spacing/typography
- [ ] Add form validation feedback
- [ ] Improve loading states
- [ ] Add empty states
- [ ] Test responsive design (mobile, tablet, desktop)

### Day 9: Testing & Optimization
- [ ] Test all CRUD operations
- [ ] Verify RLS policies work
- [ ] Check performance (optimize queries)
- [ ] Test auth flow (login, logout, protected routes)
- [ ] Test on different browsers

### Day 10: Deployment & Documentation
- [ ] Deploy to Vercel
- [ ] Setup CI/CD (GitHub Actions)
- [ ] Create README with setup instructions
- [ ] Document API/service layer
- [ ] Create portfolio documentation

---

## G. Code Examples

### 1. Supabase Client Setup

**`src/services/supabase/client.ts`** (Browser-side)
```typescript
import { createBrowserClient } from '@supabase/ssr'

export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )
}
```

**`src/services/supabase/server.ts`** (Server-side)
```typescript
import { createServerClient, parseCookieHeader, serializeCookieHeader } from '@supabase/ssr'
import { cookies } from 'next/headers'

export async function createServerSupabase() {
  const cookieStore = await cookies()
  
  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll()
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value, options }) =>
            cookieStore.set(name, value, options)
          )
        },
      },
    }
  )
}
```

### 2. Authentication Service

**`src/services/auth.ts`**
```typescript
import { createClient } from './supabase/client'

export async function signUp(email: string, password: string) {
  const supabase = createClient()
  
  const { data, error } = await supabase.auth.signUp({
    email,
    password,
    options: {
      emailRedirectTo: `${location.origin}/auth/callback`,
    },
  })
  
  if (error) throw error
  return data
}

export async function signIn(email: string, password: string) {
  const supabase = createClient()
  
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  })
  
  if (error) throw error
  return data
}

export async function signOut() {
  const supabase = createClient()
  const { error } = await supabase.auth.signOut()
  if (error) throw error
}

export async function getCurrentUser() {
  const supabase = createClient()
  const { data: { user }, error } = await supabase.auth.getUser()
  if (error) throw error
  return user
}
```

### 3. Projects Service

**`src/services/projects.ts`**
```typescript
import { createServerSupabase } from './supabase/server'
import { Project } from '@/types'

export async function getProjects(): Promise<Project[]> {
  const supabase = await createServerSupabase()
  
  const { data, error } = await supabase
    .from('projects')
    .select('*')
    .order('created_at', { ascending: false })
  
  if (error) throw error
  return data || []
}

export async function getProject(id: string): Promise<Project> {
  const supabase = await createServerSupabase()
  
  const { data, error } = await supabase
    .from('projects')
    .select('*')
    .eq('id', id)
    .single()
  
  if (error) throw error
  return data
}

export async function createProject(project: Omit<Project, 'id' | 'created_at' | 'updated_at'>) {
  const supabase = await createServerSupabase()
  
  const { data, error } = await supabase
    .from('projects')
    .insert([project])
    .select()
  
  if (error) throw error
  return data?.[0]
}

export async function updateProject(id: string, updates: Partial<Project>) {
  const supabase = await createServerSupabase()
  
  const { data, error } = await supabase
    .from('projects')
    .update(updates)
    .eq('id', id)
    .select()
  
  if (error) throw error
  return data?.[0]
}

export async function deleteProject(id: string) {
  const supabase = await createServerSupabase()
  
  const { error } = await supabase
    .from('projects')
    .delete()
    .eq('id', id)
  
  if (error) throw error
}
```

### 4. Protected Layout with Auth Check

**`src/app/dashboard/layout.tsx`**
```tsx
import { redirect } from 'next/navigation'
import { createServerSupabase } from '@/services/supabase/server'
import Sidebar from '@/components/dashboard/Sidebar'
import Header from '@/components/dashboard/Header'

export default async function DashboardLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const supabase = await createServerSupabase()
  
  const { data: { user }, error } = await supabase.auth.getUser()
  
  if (error || !user) {
    redirect('/auth/login')
  }
  
  return (
    <div className="flex h-screen bg-gray-50">
      <Sidebar />
      <div className="flex-1 flex flex-col">
        <Header user={user} />
        <main className="flex-1 overflow-auto p-8">
          {children}
        </main>
      </div>
    </div>
  )
}
```

### 5. Projects List with CRUD

**`src/app/dashboard/projects/page.tsx`**
```tsx
import Link from 'next/link'
import { getProjects, deleteProject } from '@/services/projects'
import ProjectsTable from '@/components/projects/ProjectsTable'
import DeleteProjectButton from '@/components/projects/DeleteProjectButton'
import Button from '@/components/ui/Button'

export const dynamic = 'force-dynamic'

export default async function ProjectsPage() {
  const projects = await getProjects()
  
  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Projects</h1>
          <p className="mt-2 text-gray-600">Manage and track all your projects</p>
        </div>
        <Link href="/dashboard/projects/new">
          <Button>New Project</Button>
        </Link>
      </div>
      
      {projects.length === 0 ? (
        <div className="text-center py-12">
          <p className="text-gray-500">No projects yet. Create one to get started.</p>
        </div>
      ) : (
        <ProjectsTable projects={projects} />
      )}
    </div>
  )
}
```

### 6. ProjectsTable Component

**`src/components/projects/ProjectsTable.tsx`**
```tsx
'use client'

import Link from 'next/link'
import { Project } from '@/types'
import { formatDate } from '@/lib/utils'
import StatusBadge from '@/components/ui/StatusBadge'
import PriorityBadge from '@/components/ui/PriorityBadge'
import DeleteProjectButton from './DeleteProjectButton'

interface ProjectsTableProps {
  projects: Project[]
}

export default function ProjectsTable({ projects }: ProjectsTableProps) {
  return (
    <div className="overflow-x-auto rounded-lg border border-gray-200 bg-white">
      <table className="min-w-full divide-y divide-gray-200">
        <thead className="bg-gray-50">
          <tr>
            <th className="px-6 py-3 text-left text-sm font-semibold text-gray-900">Name</th>
            <th className="px-6 py-3 text-left text-sm font-semibold text-gray-900">Status</th>
            <th className="px-6 py-3 text-left text-sm font-semibold text-gray-900">Priority</th>
            <th className="px-6 py-3 text-left text-sm font-semibold text-gray-900">Due Date</th>
            <th className="px-6 py-3 text-right text-sm font-semibold text-gray-900">Actions</th>
          </tr>
        </thead>
        <tbody className="divide-y divide-gray-200">
          {projects.map((project) => (
            <tr key={project.id} className="hover:bg-gray-50 transition">
              <td className="px-6 py-4">
                <Link href={`/dashboard/projects/${project.id}`} className="text-indigo-600 hover:text-indigo-800 font-medium">
                  {project.name}
                </Link>
              </td>
              <td className="px-6 py-4">
                <StatusBadge status={project.status} />
              </td>
              <td className="px-6 py-4">
                <PriorityBadge priority={project.priority} />
              </td>
              <td className="px-6 py-4 text-sm text-gray-600">
                {project.due_date ? formatDate(project.due_date) : '-'}
              </td>
              <td className="px-6 py-4 text-right flex gap-2 justify-end">
                <Link href={`/dashboard/projects/${project.id}/edit`} className="text-indigo-600 hover:text-indigo-800 text-sm font-medium">
                  Edit
                </Link>
                <DeleteProjectButton projectId={project.id} />
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
```

### 7. Create Project with Server Action

**`src/app/dashboard/projects/new/page.tsx`**
```tsx
'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import Form from '@/components/ui/Form'
import Input from '@/components/ui/Input'
import Select from '@/components/ui/Select'
import Textarea from '@/components/ui/Textarea'
import Button from '@/components/ui/Button'
import { createProject } from '@/services/projects'

export default function NewProjectPage() {
  const router = useRouter()
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  
  const handleSubmit = async (formData: FormData) => {
    setLoading(true)
    setError(null)
    
    try {
      const project = {
        name: formData.get('name') as string,
        description: formData.get('description') as string,
        status: formData.get('status') as string,
        priority: formData.get('priority') as string,
        due_date: formData.get('due_date') ? new Date(formData.get('due_date') as string).toISOString() : null,
      }
      
      await createProject(project)
      router.push('/dashboard/projects')
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to create project')
    } finally {
      setLoading(false)
    }
  }
  
  return (
    <div className="max-w-2xl">
      <h1 className="text-3xl font-bold text-gray-900 mb-8">Create New Project</h1>
      
      <Form onSubmit={handleSubmit}>
        <Input
          name="name"
          label="Project Name"
          placeholder="e.g., Website Redesign"
          required
        />
        
        <Textarea
          name="description"
          label="Description"
          placeholder="Describe your project..."
          rows={4}
        />
        
        <div className="grid grid-cols-2 gap-6">
          <Select
            name="status"
            label="Status"
            options={[
              { value: 'active', label: 'Active' },
              { value: 'completed', label: 'Completed' },
              { value: 'archived', label: 'Archived' },
            ]}
            defaultValue="active"
          />
          
          <Select
            name="priority"
            label="Priority"
            options={[
              { value: 'low', label: 'Low' },
              { value: 'medium', label: 'Medium' },
              { value: 'high', label: 'High' },
            ]}
            defaultValue="medium"
          />
        </div>
        
        <Input
          name="due_date"
          label="Due Date"
          type="date"
        />
        
        {error && <div className="text-red-600 text-sm">{error}</div>}
        
        <div className="flex gap-4">
          <Button type="submit" disabled={loading}>
            {loading ? 'Creating...' : 'Create Project'}
          </Button>
          <Button type="button" variant="secondary" onClick={() => router.back()}>
            Cancel
          </Button>
        </div>
      </Form>
    </div>
  )
}
```

### 8. Recharts - Project Status Chart

**`src/components/charts/ProjectStatusChart.tsx`**
```tsx
'use client'

import { useEffect, useState } from 'react'
import { PieChart, Pie, Cell, Legend, Tooltip, ResponsiveContainer } from 'recharts'
import { createClient } from '@/services/supabase/client'

const COLORS = {
  active: '#4f46e5',
  completed: '#10b981',
  archived: '#9ca3af',
}

export default function ProjectStatusChart() {
  const [data, setData] = useState<Array<{ name: string; value: number }>>([])
  const [loading, setLoading] = useState(true)
  
  useEffect(() => {
    const fetchData = async () => {
      const supabase = createClient()
      
      const { data: projects, error } = await supabase
        .from('projects')
        .select('status')
      
      if (error) {
        console.error('Error fetching projects:', error)
        return
      }
      
      const statusCounts = {
        active: 0,
        completed: 0,
        archived: 0,
      }
      
      projects?.forEach((project: any) => {
        statusCounts[project.status as keyof typeof statusCounts]++
      })
      
      setData([
        { name: 'Active', value: statusCounts.active },
        { name: 'Completed', value: statusCounts.completed },
        { name: 'Archived', value: statusCounts.archived },
      ])
      setLoading(false)
    }
    
    fetchData()
  }, [])
  
  if (loading) return <div className="h-96 animate-pulse bg-gray-200 rounded-lg" />
  
  return (
    <div className="bg-white p-6 rounded-lg border border-gray-200">
      <h3 className="text-lg font-semibold text-gray-900 mb-4">Project Status</h3>
      <ResponsiveContainer width="100%" height={300}>
        <PieChart>
          <Pie
            data={data}
            cx="50%"
            cy="50%"
            labelLine={false}
            label={({ name, value }) => `${name}: ${value}`}
            outerRadius={100}
            fill="#8884d8"
            dataKey="value"
          >
            {data.map((entry, index) => (
              <Cell key={`cell-${index}`} fill={COLORS[entry.name.toLowerCase() as keyof typeof COLORS] || '#999'} />
            ))}
          </Pie>
          <Tooltip />
          <Legend />
        </PieChart>
      </ResponsiveContainer>
    </div>
  )
}
```

### 9. Recharts - Tasks Timeline (Line Chart)

**`src/components/charts/TaskTimelineChart.tsx`**
```tsx
'use client'

import { useEffect, useState } from 'react'
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts'
import { createClient } from '@/services/supabase/client'

export default function TaskTimelineChart() {
  const [data, setData] = useState<Array<{ date: string; count: number }>>([])
  const [loading, setLoading] = useState(true)
  
  useEffect(() => {
    const fetchData = async () => {
      const supabase = createClient()
      
      const { data: tasks, error } = await supabase
        .from('tasks')
        .select('created_at')
        .order('created_at', { ascending: true })
      
      if (error) {
        console.error('Error fetching tasks:', error)
        return
      }
      
      // Group tasks by date
      const grouped: { [key: string]: number } = {}
      
      tasks?.forEach((task: any) => {
        const date = new Date(task.created_at).toLocaleDateString()
        grouped[date] = (grouped[date] || 0) + 1
      })
      
      const chartData = Object.entries(grouped).map(([date, count]) => ({
        date,
        count,
      }))
      
      setData(chartData)
      setLoading(false)
    }
    
    fetchData()
  }, [])
  
  if (loading) return <div className="h-96 animate-pulse bg-gray-200 rounded-lg" />
  
  return (
    <div className="bg-white p-6 rounded-lg border border-gray-200">
      <h3 className="text-lg font-semibold text-gray-900 mb-4">Tasks Created Over Time</h3>
      <ResponsiveContainer width="100%" height={300}>
        <LineChart data={data}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis dataKey="date" />
          <YAxis />
          <Tooltip />
          <Legend />
          <Line type="monotone" dataKey="count" stroke="#4f46e5" name="Tasks Created" />
        </LineChart>
      </ResponsiveContainer>
    </div>
  )
}
```

---

## H. Best Practices

### 1. Clean Architecture

**Separation of Concerns:**
- **Services**: Handle API calls and data logic
- **Components**: Handle UI rendering only
- **Hooks**: Encapsulate component logic (state, effects)
- **Middleware**: Handle cross-cutting concerns (auth, logging)

**File Naming:**
- Use descriptive names: `ProjectForm.tsx`, not `Form.tsx`
- Lowercase with dashes for folders: `dashboard/`, `auth/`
- PascalCase for components: `ProjectForm.tsx`
- camelCase for utilities: `formatDate.ts`

### 2. Avoiding Hardcoding

**Use Constants:**
```typescript
// lib/constants.ts
export const PROJECT_STATUSES = ['active', 'completed', 'archived'] as const
export const PRIORITY_LEVELS = ['low', 'medium', 'high'] as const

// Then in components
<Select options={PROJECT_STATUSES.map(s => ({ value: s, label: capitalize(s) }))} />
```

**Use Environment Variables:**
```bash
# .env.local
NEXT_PUBLIC_SUPABASE_URL=...
NEXT_PUBLIC_SUPABASE_ANON_KEY=...
```

### 3. Error Handling

**Consistent Error Pattern:**
```typescript
try {
  // action
} catch (error) {
  const message = error instanceof Error ? error.message : 'An error occurred'
  // display to user
  throw new Error(message)
}
```

### 4. Loading States

**Always show feedback:**
- Skeleton loaders for data fetching
- Disabled buttons during submission
- Toast notifications for success/error
- Empty states when no data

### 5. Type Safety

**Never use `any`:**
```typescript
// ❌ Bad
const data: any = await fetch()

// ✅ Good
const data: Project[] = await fetch()
```

**Generate types from Supabase:**
```bash
npx supabase gen types typescript --project-id xxx > src/types/database.ts
```

### 6. Testing

**Test accounts for QA:**
```
test@example.com / password123
```

**Test scenarios:**
1. Sign up → Verify email confirmation flow
2. Login → Verify redirect to dashboard
3. Create project → Verify appears in list
4. Edit project → Verify changes saved
5. Delete project → Verify removed from list
6. Verify RLS → Sign in as different user, can't see other's data

### 7. Performance Optimization

**Image optimization:**
```tsx
import Image from 'next/image'
<Image src="..." alt="..." width={400} height={300} priority />
```

**Code splitting:**
```tsx
import dynamic from 'next/dynamic'
const Chart = dynamic(() => import('@/components/charts/Chart'), { ssr: false })
```

**Database optimization:**
- Add indexes on frequently queried columns
- Use `select()` to only fetch needed columns
- Use `limit()` for pagination

### 8. Portfolio & Upwork Positioning

**What makes this portfolio-worthy:**

1. **Real Technology Stack**
   - Next.js 16 (latest)
   - Real authentication with Supabase
   - Custom UI components (not just shadcn defaults)
   - Real database with RLS

2. **Show Understanding**
   - Clean folder structure
   - TypeScript types for everything
   - Server Components where appropriate
   - Error handling and loading states

3. **Polish**
   - Responsive design (mobile, tablet, desktop)
   - Consistent design system
   - Smooth animations/transitions
   - Professional looking UI

4. **Documentation**
   - README with setup instructions
   - Code comments on complex logic
   - Architecture diagram
   - Deployment guide

5. **For Upwork**
   - Create case study: "How I built PulseBoard in 10 days"
   - Show before/after (landing page → logged in dashboard)
   - Highlight tech choices and why
   - Share GitHub repo link
   - Create short demo video (1-2 min)
   - List all features in description

**Differentiators:**
- End-to-end implementation (not just components)
- Production-ready (not "tutorial quality")
- Proper auth & security (RLS policies)
- Real data visualization (not mock)
- Responsive design proven

---

## Summary Timeline

- **Days 1-2**: Setup infrastructure
- **Days 3-4**: Authentication & navigation
- **Days 5-6**: CRUD operations
- **Days 7-8**: Charts & Polish
- **Days 9-10**: Testing & Deployment

**Total LOC**: ~3,000-4,000 lines (reasonable, not bloated)
**Key Files**: ~50-60 files (maintainable)
**Deployment**: Vercel (free tier)
**Database**: Supabase (free tier)
**Cost**: $0 for MVP

---

Good luck! This is a comprehensive plan to build a real, production-ready SaaS dashboard. Focus on clean code, real data, and a polished UI. When building, follow the architecture strictly—it will pay off in maintainability and portfolio value.
