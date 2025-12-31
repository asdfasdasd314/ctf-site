# CTF-SITE

### Overview

This is a web-based Capture The Flag (CTF) site designed to teach people concepts in cybersecurity. I learned these concepts and the skills to build this full-stack web app throughout a *Learning Module* as a part of my school's computer science class.

I then revisited the project months later to clean things up.

### Features

- 3 custom exercises based on concepts I've run into in my daily life
- User stat tracking across challenges

### Tech Stack

**Languages**:
- TypeScript
- SQL

**Frontend**:
- v0 AI (UI scaffolding)
- SvelteKit
- Tailwind CSS

**Backend (Serverless)**:
- Supabase (PostgreSQL, Auth)

**DevOps & Deployment**:
- Vercel (CI/CD, hosting)
- Git (version control)

### Architecture

The application is serverless and written in TypeScript + SvelteKit. The frontend communicates with the backend and Supabase via a REST API. Despite SvelteKit being used as the framework, no SSR occurs. User authentication and the database are handled by Supabase.

Each exercise is loaded from an entry in the database using a public Supabase JS client, and flags for the exercises are verified server-side by a client with `service_role` privileges.

***A user does not have to sign up for an account to attempt the exercises, but to actually submit flags and track their progress they must log in.***

The app is deployed to Vercel and uses the `main` branch for production.

### Usage

Visit www.asdfctf.dev to attempt the challenges. Create an account to save progress, track your streak, and record solved exercises. Hints are available if you get stuck.