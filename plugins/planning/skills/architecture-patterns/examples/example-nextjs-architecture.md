# Example: Next.js 15 App Router Architecture

> **Example Architecture**: Full-stack Next.js 15 application with App Router
> **Last Updated**: 2025-01-01

## Overview

This example demonstrates a complete architecture for a Next.js 15 application using the App Router, React Server Components (RSC), Server Actions, and modern best practices.

---

## Technology Stack

### Frontend
- **Framework**: Next.js 15 with App Router
- **React**: React 19 with Server Components
- **UI Components**: shadcn/ui + Radix UI
- **Styling**: Tailwind CSS
- **State Management**: Zustand (client state only)
- **Form Handling**: React Hook Form + Zod validation

### Backend (Next.js API)
- **API Routes**: Next.js App Router API routes
- **Server Actions**: For form mutations
- **Database ORM**: Prisma
- **Authentication**: NextAuth.js v5
- **File Upload**: UploadThing

### Infrastructure
- **Hosting**: Vercel
- **Database**: Supabase PostgreSQL
- **File Storage**: Vercel Blob / S3
- **Caching**: Vercel Edge Cache + React Cache

---

## High-Level Architecture

```mermaid
graph TB
    subgraph "Client Layer (Browser)"
        PAGES[App Router Pages]
        CLIENT_COMP[Client Components]
        CLIENT_STATE[Client State - Zustand]
    end

    subgraph "Server Layer (Next.js)"
        SERVER_COMP[Server Components]
        SERVER_ACTIONS[Server Actions]
        API_ROUTES[API Routes]
        MIDDLEWARE[Middleware]
    end

    subgraph "Data Layer"
        PRISMA[Prisma ORM]
        CACHE[React Cache]
        DB[(PostgreSQL)]
    end

    subgraph "External Services"
        AUTH_PROVIDER[Auth Provider]
        BLOB_STORAGE[Blob Storage]
    end

    PAGES --> SERVER_COMP
    PAGES --> CLIENT_COMP
    CLIENT_COMP --> CLIENT_STATE
    CLIENT_COMP --> SERVER_ACTIONS

    SERVER_COMP --> PRISMA
    SERVER_ACTIONS --> PRISMA
    API_ROUTES --> PRISMA

    MIDDLEWARE --> AUTH_PROVIDER

    PRISMA --> CACHE
    CACHE --> DB

    SERVER_ACTIONS --> BLOB_STORAGE
    API_ROUTES --> BLOB_STORAGE

    style PAGES fill:#e1f5ff
    style SERVER_COMP fill:#fff9e1
    style PRISMA fill:#e1ffe1
    style DB fill:#ffe1e1
```

---

## Directory Structure

```
app/
├── (auth)/                    # Auth route group
│   ├── login/
│   │   └── page.tsx          # Server Component
│   └── register/
│       └── page.tsx
├── (dashboard)/              # Dashboard route group
│   ├── layout.tsx            # Shared layout
│   ├── page.tsx              # Dashboard home
│   ├── posts/
│   │   ├── page.tsx          # Posts list (RSC)
│   │   ├── [id]/
│   │   │   └── page.tsx      # Post detail (RSC)
│   │   └── create/
│   │       └── page.tsx
│   └── settings/
│       └── page.tsx
├── api/                      # API Routes
│   ├── auth/
│   │   └── [...nextauth]/
│   │       └── route.ts
│   ├── posts/
│   │   └── route.ts
│   └── upload/
│       └── route.ts
├── actions/                  # Server Actions
│   ├── auth.ts
│   ├── posts.ts
│   └── users.ts
├── components/               # Shared components
│   ├── ui/                   # shadcn components
│   ├── forms/
│   └── layout/
├── lib/                      # Utilities
│   ├── db.ts                 # Prisma client
│   ├── auth.ts               # Auth config
│   ├── utils.ts
│   └── validations.ts
├── middleware.ts             # Next.js middleware
├── layout.tsx                # Root layout
└── page.tsx                  # Home page
```

---

## Component Architecture

### App Router Structure

```mermaid
graph TB
    ROOT[Root Layout] --> AUTH_GROUP["(auth) Route Group"]
    ROOT --> DASH_GROUP["(dashboard) Route Group"]
    ROOT --> PUBLIC[Public Pages]

    AUTH_GROUP --> LOGIN[Login Page - RSC]
    AUTH_GROUP --> REGISTER[Register Page - RSC]

    DASH_GROUP --> DASH_LAYOUT[Dashboard Layout - RSC]
    DASH_LAYOUT --> DASH_HOME[Dashboard Home - RSC]
    DASH_LAYOUT --> POSTS[Posts Page - RSC]
    DASH_LAYOUT --> SETTINGS[Settings Page]

    POSTS --> POST_DETAIL["Post [id] - RSC"]
    POSTS --> POST_CREATE[Create Post - Client Form]

    style ROOT fill:#e1f5ff
    style DASH_LAYOUT fill:#fff9e1
    style POSTS fill:#e1ffe1
```

### Server vs Client Components

```mermaid
graph LR
    subgraph "Server Components (RSC)"
        LAYOUT[Layouts]
        PAGE[Pages]
        DATA_FETCH[Data Fetching]
        DB_ACCESS[Direct DB Access]
    end

    subgraph "Client Components"
        INTERACTIVE[Interactive UI]
        STATE[State Management]
        EFFECTS[useEffect Hooks]
        BROWSER_API[Browser APIs]
    end

    LAYOUT --> INTERACTIVE
    PAGE --> INTERACTIVE
    DATA_FETCH --> STATE

    style LAYOUT fill:#e1f5ff
    style INTERACTIVE fill:#fff9e1
```

---

## Data Flow

### Server Component Data Fetching

```mermaid
sequenceDiagram
    participant Browser
    participant NextServer
    participant ServerComp
    participant Prisma
    participant Database

    Browser->>NextServer: Request /dashboard
    NextServer->>ServerComp: Render Page (RSC)
    ServerComp->>Prisma: db.post.findMany()
    Prisma->>Database: SELECT * FROM posts
    Database-->>Prisma: Results
    Prisma-->>ServerComp: Posts Array
    ServerComp->>ServerComp: Render with Data
    ServerComp-->>NextServer: HTML + RSC Payload
    NextServer-->>Browser: Streamed HTML
```

### Server Action Flow

```mermaid
sequenceDiagram
    participant Client
    participant Form
    participant ServerAction
    participant Validation
    participant Prisma
    participant Database

    Client->>Form: Submit Form
    Form->>ServerAction: Call Server Action
    ServerAction->>Validation: Validate with Zod
    Validation-->>ServerAction: Valid

    ServerAction->>Prisma: db.post.create()
    Prisma->>Database: INSERT INTO posts
    Database-->>Prisma: Created Record
    Prisma-->>ServerAction: Post Object

    ServerAction->>ServerAction: revalidatePath('/posts')
    ServerAction-->>Form: Success Response
    Form-->>Client: Update UI
```

### API Route Flow

```mermaid
sequenceDiagram
    participant Client
    participant API
    participant Auth
    participant Prisma
    participant Database

    Client->>API: POST /api/posts
    API->>Auth: Verify Session
    Auth-->>API: Session Valid

    API->>API: Validate Request Body
    API->>Prisma: db.post.create()
    Prisma->>Database: INSERT
    Database-->>Prisma: Result
    Prisma-->>API: Post Object
    API-->>Client: 201 Created (JSON)
```

---

## Authentication Flow

### NextAuth.js with Credentials

```mermaid
sequenceDiagram
    participant User
    participant LoginForm
    participant ServerAction
    participant NextAuth
    participant Database

    User->>LoginForm: Enter Credentials
    LoginForm->>ServerAction: Submit Form
    ServerAction->>NextAuth: signIn('credentials')
    NextAuth->>NextAuth: Authorize Callback
    NextAuth->>Database: Find User
    Database-->>NextAuth: User Record
    NextAuth->>NextAuth: Verify Password
    NextAuth->>NextAuth: Create Session
    NextAuth-->>ServerAction: Session Created
    ServerAction->>ServerAction: redirect('/dashboard')
    ServerAction-->>User: Redirect
```

### Protected Routes with Middleware

```typescript
// middleware.ts
import { NextResponse } from 'next/server';
import { getToken } from 'next-auth/jwt';

export async function middleware(request) {
  const token = await getToken({ req: request });
  const isAuthPage = request.nextUrl.pathname.startsWith('/login');

  if (!token && !isAuthPage) {
    return NextResponse.redirect(new URL('/login', request.url));
  }

  if (token && isAuthPage) {
    return NextResponse.redirect(new URL('/dashboard', request.url));
  }

  return NextResponse.next();
}

export const config = {
  matcher: ['/((?!api|_next/static|_next/image|favicon.ico).*)'],
};
```

---

## Caching Strategy

### Multi-Layer Caching

```mermaid
graph TB
    REQUEST[Page Request] --> EDGE_CACHE{Edge Cache}

    EDGE_CACHE -->|Hit| SERVE_EDGE[Serve from Edge]
    EDGE_CACHE -->|Miss| FULL_ROUTE_CACHE{Full Route Cache}

    FULL_ROUTE_CACHE -->|Hit| SERVE_ROUTE[Serve Cached Route]
    FULL_ROUTE_CACHE -->|Miss| REACT_CACHE{React Cache}

    REACT_CACHE -->|Hit| SERVE_REACT[Use Cached Data]
    REACT_CACHE -->|Miss| DATABASE[Query Database]

    DATABASE --> STORE_REACT[Store in React Cache]
    STORE_REACT --> RENDER[Render RSC]
    RENDER --> STORE_ROUTE[Store Full Route]
    STORE_ROUTE --> SERVE_ROUTE

    SERVE_REACT --> RENDER

    style REQUEST fill:#e1f5ff
    style EDGE_CACHE fill:#fff9e1
    style REACT_CACHE fill:#e1ffe1
    style DATABASE fill:#ffe1e1
```

### Cache Configuration

```typescript
// app/posts/page.tsx - Static with revalidation
export const revalidate = 3600; // Revalidate every hour

export default async function PostsPage() {
  const posts = await db.post.findMany();
  return <PostsList posts={posts} />;
}

// app/posts/[id]/page.tsx - Static with on-demand revalidation
export default async function PostDetail({ params }) {
  const post = await db.post.findUnique({ where: { id: params.id } });
  return <PostDetail post={post} />;
}

// In Server Action - Revalidate after mutation
'use server';
import { revalidatePath } from 'next/cache';

export async function createPost(data) {
  await db.post.create({ data });
  revalidatePath('/posts');
  revalidatePath('/dashboard');
}
```

---

## Server Actions Example

### Form with Server Action

```typescript
// app/actions/posts.ts
'use server';

import { z } from 'zod';
import { db } from '@/lib/db';
import { revalidatePath } from 'next/cache';
import { redirect } from 'next/navigation';

const createPostSchema = z.object({
  title: z.string().min(1).max(200),
  content: z.string().min(1),
  published: z.boolean().default(false),
});

export async function createPost(formData: FormData) {
  const validatedFields = createPostSchema.safeParse({
    title: formData.get('title'),
    content: formData.get('content'),
    published: formData.get('published') === 'true',
  });

  if (!validatedFields.success) {
    return {
      errors: validatedFields.error.flatten().fieldErrors,
    };
  }

  const post = await db.post.create({
    data: validatedFields.data,
  });

  revalidatePath('/posts');
  redirect(`/posts/${post.id}`);
}
```

```typescript
// app/posts/create/page.tsx
import { createPost } from '@/app/actions/posts';

export default function CreatePostPage() {
  return (
    <form action={createPost}>
      <input name="title" required />
      <textarea name="content" required />
      <button type="submit">Create Post</button>
    </form>
  );
}
```

---

## Deployment Architecture

### Vercel Deployment

```mermaid
graph TB
    subgraph "Vercel Edge Network"
        EDGE[Edge Functions]
        CDN[CDN Cache]
        MIDDLEWARE[Middleware]
    end

    subgraph "Vercel Serverless"
        SSR[SSR Functions]
        API[API Functions]
        ACTIONS[Server Actions]
    end

    subgraph "External Services"
        SUPABASE[(Supabase PostgreSQL)]
        BLOB[Vercel Blob Storage]
    end

    USER[Users] --> EDGE
    EDGE --> CDN
    CDN --> MIDDLEWARE
    MIDDLEWARE --> SSR
    MIDDLEWARE --> API
    MIDDLEWARE --> ACTIONS

    SSR --> SUPABASE
    API --> SUPABASE
    ACTIONS --> SUPABASE
    ACTIONS --> BLOB

    style USER fill:#e1f5ff
    style EDGE fill:#fff9e1
    style SSR fill:#e1ffe1
    style SUPABASE fill:#ffe1e1
```

---

## Performance Optimizations

### Image Optimization

```typescript
import Image from 'next/image';

<Image
  src="/hero.jpg"
  alt="Hero"
  width={1920}
  height={1080}
  priority // Above fold
  placeholder="blur"
  blurDataURL="..."
/>
```

### Streaming with Suspense

```typescript
import { Suspense } from 'react';

export default function DashboardPage() {
  return (
    <div>
      <h1>Dashboard</h1>
      <Suspense fallback={<PostsSkeleton />}>
        <Posts />
      </Suspense>
      <Suspense fallback={<StatsSkeleton />}>
        <Stats />
      </Suspense>
    </div>
  );
}
```

### Parallel Data Fetching

```typescript
async function getPosts() {
  return db.post.findMany();
}

async function getUsers() {
  return db.user.findMany();
}

export default async function DashboardPage() {
  // Parallel fetching
  const [posts, users] = await Promise.all([
    getPosts(),
    getUsers(),
  ]);

  return <Dashboard posts={posts} users={users} />;
}
```

---

## Key Takeaways

1. **Maximize Server Components**: Fetch data in RSC for better performance
2. **Use Server Actions**: Simplify form handling without API routes
3. **Cache Strategically**: Leverage Edge, Full Route, and React caching
4. **Stream with Suspense**: Improve perceived performance
5. **Minimize Client JavaScript**: Only use 'use client' when necessary
6. **Optimize Images**: Always use next/image for automatic optimization

---

## References

- [Next.js 15 Documentation](https://nextjs.org/docs)
- [React Server Components](https://react.dev/reference/rsc/server-components)
- [Vercel Deployment](https://vercel.com/docs)
