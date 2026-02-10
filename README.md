# PulseBoard - Team Analytics Dashboard

A production-ready SaaS dashboard for project management and team analytics built with **Next.js 16**, **TypeScript**, **Tailwind CSS**, **Supabase**, and **Recharts**.

## Overview

**PulseBoard** is a lightweight, real-time project management dashboard that helps teams track projects, manage tasks, and visualize progress. It's designed as a simple but realistic internal dashboard suitable for portfolios and production use.

### Key Features

✅ **Real-Time Authentication** - Email/password auth with Supabase Auth  
✅ **Project Management (CRUD)** - Create, read, update, delete projects  
✅ **Task Management** - Organize tasks within projects with status tracking  
✅ **Analytics Dashboard** - Real-time charts with project metrics  
✅ **Data Visualization** - Pie charts, line charts with Recharts  
✅ **Protected Routes** - Authentication-based access control  
✅ **Row-Level Security** - Database-level data isolation per user  
✅ **Responsive Design** - Mobile, tablet, and desktop friendly  
✅ **Clean Architecture** - Server Components, Server Actions, no mock data  

## Tech Stack

### Frontend
- **Next.js 16** (App Router)
- **TypeScript** - Full type safety
- **Tailwind CSS v4** - Utility-first styling
- **Recharts** - Data visualization
- **Lucide React** - Icon system

### Backend & Database
- **Supabase** - PostgreSQL + Auth + Real-time
- **Row Level Security (RLS)** - Automatic data isolation
- **Server Actions** - Simplified API layer

### Dev Tools
- **Turbopack** - Ultra-fast bundler
- **ESLint** - Code quality
- **TypeScript** - Type checking

## Quick Start

### 1. Clone the Repository

```bash
git clone <repo-url>
cd PulseBoard
cd frontend
npm install
```

### 2. Set Up Supabase

Follow the [Supabase Setup Guide](./SUPABASE_SETUP.md) to:
- Create a Supabase project
- Configure authentication
- Create database tables
- Get API keys

### 3. Configure Environment Variables

```bash
cp .env.local.example .env.local
```

Add your Supabase credentials:
```
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJh...
SUPABASE_SERVICE_ROLE_KEY=eyJh...
```

### 4. Run Development Server

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000)

### 5. Create an Account

- Click "Get Started"
- Sign up with email/password
- Create your first project
- Add tasks and watch the dashboard update in real-time

## Project Structure

```
frontend/src/
├── app/                    # Next.js App Router pages
│   ├── (public)/          # Public pages with header/footer
│   ├── auth/              # Authentication pages (login/register)
│   ├── dashboard/         # Protected dashboard area
│   │   ├── projects/      # Project CRUD pages
│   │   └── team/          # Team overview
│   └── globals.css        # Global styles
│
├── components/            # React components
│   ├── ui/               # Reusable UI components (Button, Input, etc.)
│   ├── auth/             # Authentication forms
│   ├── dashboard/        # Dashboard layout components
│   ├── projects/         # Project components
│   ├── tasks/            # Task components
│   └── charts/           # Recharts visualizations
│
├── services/             # Business logic layer
│   ├── supabase/        # Supabase client setup
│   ├── auth.ts          # Authentication functions
│   ├── projects.ts      # Project CRUD operations
│   └── tasks.ts         # Task CRUD operations
│
├── lib/                 # Utilities
│   ├── utils.ts         # Helper functions
│   ├── constants.ts     # App constants
│   └── validation.ts    # Input validation
│
└── types/               # TypeScript type definitions
    └── index.ts         # Database models & types
```

## Core Pages

### Public Pages
- **`/`** - Landing page with features & CTA
- **`/auth/login`** - Sign in page
- **`/auth/register`** - Create account page

### Protected Pages (Require Auth)
- **`/dashboard`** - Main dashboard with analytics
- **`/dashboard/projects`** - Projects list with CRUD
- **`/dashboard/projects/[id]`** - Project detail page
- **`/dashboard/projects/[id]/edit`** - Edit project
- **`/dashboard/projects/[id]/tasks/new`** - Create task
- **`/dashboard/projects/[id]/tasks/[taskId]/edit`** - Edit task
- **`/dashboard/team`** - Team overview (expandable)

## Features in Detail

### 1. Authentication
- Email/password signup and login
- Email confirmation flow (configurable)
- Automatic session management
- Protected routes with redirect to login

### 2. Projects Management
- **Create**: New projects with name, description, priority, due date
- **Read**: List all projects with filtering
- **Update**: Edit project details
- **Delete**: Remove projects (with confirmation)
- **Status**: Active, Completed, Archived
- **Priority**: Low, Medium, High

### 3. Tasks Management
- Task-per-project organization
- Status tracking: To Do → In Progress → Done
- Edit and delete tasks
- Due date tracking
- Task count per project

### 4. Analytics Dashboard
- **Project Status Chart** (Pie Chart)
  - Distribution of active/completed/archived projects
  - Real-time data from Supabase

- **Task Timeline Chart** (Line Chart)
  - Tasks created over time
  - Trends visualization

- **Stats Cards**
  - Total projects, active, completed, archived counts

### 5. Data Security
- **Row Level Security (RLS)** - Users only see their own data
- **Auth-based Access Control** - All routes protected
- **Server-side Operations** - No sensitive data in client code

## Deployment

### Deploy to Vercel (Recommended)

1. Push code to GitHub
2. Go to [Vercel Dashboard](https://vercel.com)
3. Import project from GitHub
4. Add environment variables
5. Deploy (automatic on push)

## Documentation

- [PRODUCT_PLAN.md](./PRODUCT_PLAN.md) - Complete product specification
- [SUPABASE_SETUP.md](./SUPABASE_SETUP.md) - Database setup guide

## License

MIT - Free to use for personal and commercial projects

---

**Built with ❤️ using Next.js, Supabase, and Tailwind CSS**
