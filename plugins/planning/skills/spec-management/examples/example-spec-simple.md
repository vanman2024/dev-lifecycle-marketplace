# Example: Simple Feature Specification

This example shows a simple feature specification for a basic user profile feature.

---

```markdown
---
spec-id: 015
title: User Profile Page
status: draft
priority: medium
owner: frontend-team
created: 2025-01-15
updated: 2025-01-15
tags: [feature, frontend, user-management]
---

# User Profile Page

## Overview

Add a user profile page where users can view and edit their account information.

## Problem Statement

Currently, users cannot view or update their profile information after registration. This creates friction when users need to:
- Update their email address
- Change their display name
- Add a profile picture
- Update their bio

User feedback indicates that 40% of support tickets are related to profile updates.

## Proposed Solution

Create a dedicated profile page (`/profile`) where users can:
- View their current profile information
- Edit their display name and bio
- Upload a profile picture
- Change their email (with verification)
- Save changes with validation

## Requirements

### Functional Requirements

1. **Profile Display**: Show user's current profile information
   - Display name
   - Email address
   - Profile picture (or default avatar)
   - Bio text
   - Account creation date

2. **Profile Editing**: Allow users to edit profile fields
   - Inline editing with save/cancel buttons
   - Real-time validation
   - Success/error messages
   - Prevent editing while save in progress

3. **Profile Picture Upload**: Allow users to upload profile pictures
   - Support JPG, PNG formats
   - Maximum file size: 2MB
   - Automatic image resizing to 200x200px
   - Preview before saving

### Non-Functional Requirements

1. **Performance**: Profile page loads in <1 second
2. **Security**: Only authenticated users can access their own profile
3. **Validation**: Email format validation, name length limits (3-50 chars)
4. **Accessibility**: WCAG 2.1 Level AA compliant

### Constraints

- Must use existing authentication system
- Must store images in existing S3 bucket
- Must work on mobile browsers

## Technical Design

### Components

- `ProfilePage.tsx`: Main profile page container
- `ProfileForm.tsx`: Editable form component
- `AvatarUpload.tsx`: Image upload component
- `ProfileAPI.ts`: API client for profile operations

### API Endpoints

```
GET /api/profile
  Response: { name, email, avatar, bio, createdAt }

PUT /api/profile
  Request: { name, email, bio }
  Response: { success, profile }

POST /api/profile/avatar
  Request: FormData with image file
  Response: { success, avatarUrl }
```

### Data Model

```typescript
interface Profile {
  id: string;
  name: string;
  email: string;
  avatar: string | null;
  bio: string | null;
  createdAt: Date;
  updatedAt: Date;
}
```

## Task Breakdown

1. [ ] **Backend API** (estimate: 4 hours)
   - 1.1 [ ] GET /api/profile endpoint (1 hour)
   - 1.2 [ ] PUT /api/profile endpoint (2 hours)
   - 1.3 [ ] POST /api/profile/avatar endpoint (1 hour)

2. [ ] **Frontend Components** (estimate: 6 hours)
   - 2.1 [ ] ProfilePage container (1 hour)
   - 2.2 [ ] ProfileForm with validation (2 hours)
   - 2.3 [ ] AvatarUpload component (2 hours)
   - 2.4 [ ] Integration and styling (1 hour)

3. [ ] **Testing** (estimate: 3 hours)
   - 3.1 [ ] Backend unit tests (1 hour)
   - 3.2 [ ] Frontend component tests (1.5 hours)
   - 3.3 [ ] E2E test for profile update (0.5 hours)

4. [ ] **Documentation** (estimate: 1 hour)
   - 4.1 [ ] API documentation (0.5 hours)
   - 4.2 [ ] User guide (0.5 hours)

**Total Estimate**: 14 hours

## Success Criteria

- [ ] Users can view their profile information
- [ ] Users can edit name, email, and bio fields
- [ ] Users can upload profile pictures (<2MB)
- [ ] Form validation works correctly
- [ ] Profile updates persist to database
- [ ] Page loads in <1 second
- [ ] Mobile responsive
- [ ] Test coverage >80%
- [ ] Zero P0/P1 bugs after 1 week in production

## Dependencies

- Authentication system must be functional
- S3 bucket for image storage must be configured
- User database table exists

## Timeline

- Start: 2025-01-20
- Backend complete: 2025-01-21
- Frontend complete: 2025-01-23
- Testing complete: 2025-01-24
- Production deploy: 2025-01-25

## Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| Image upload failures | Medium | Add retry logic, show clear error messages |
| Email change conflicts | Low | Validate email uniqueness before allowing change |
| Large file uploads | Low | Enforce 2MB limit, compress on client side |
```

---

## Key Features of This Simple Spec

1. **Concise**: Covers all essential sections without overwhelming detail
2. **Clear requirements**: Functional requirements are specific and testable
3. **Realistic estimates**: Task breakdown with reasonable time estimates
4. **Measurable success criteria**: Clear definition of done
5. **Complete but focused**: All sections present but kept brief

## When to Use This Format

Use this simple format for:
- Small to medium features (<2 weeks work)
- Well-understood problems
- Features with clear scope
- Internal tools or minor enhancements
- Features with minimal technical complexity

## What Makes It Work

- **Problem clearly stated**: User pain points and evidence
- **Solution is straightforward**: No ambiguity about what to build
- **Tasks are actionable**: Developer can start immediately
- **Success is measurable**: Clear checkboxes for completion
- **Timeline is realistic**: Accounts for development, testing, deployment
