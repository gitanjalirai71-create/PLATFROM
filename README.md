# Restaurant Website Platform

A production-ready, multi-tenant restaurant website platform built with Next.js 16, TypeScript, Prisma, and Tailwind CSS. Each deployment serves one restaurant with a complete website, admin panel, reservation system, and email notifications.

## Features

- **One-time registration** — Fill the form once, restaurant is live forever
- **Admin dashboard** — 16 sections (Menu, Reservations, Orders, Messages, Content/CMS, Settings, etc.)
- **Real email notifications** — Gmail SMTP for reservations, messages, orders
- **Mobile-responsive** — Works on all screen sizes
- **Real subdomains** — Each restaurant gets `myrestaurant.yourdomain.com`
- **Secure** — NextAuth JWT authentication, tenant isolation, IDOR prevention
- **PostgreSQL-ready** — Swap from SQLite to PostgreSQL for production

## Tech Stack

- **Framework:** Next.js 16 (App Router, Turbopack)
- **Language:** TypeScript 5
- **Database:** Prisma ORM (SQLite dev / PostgreSQL prod)
- **Auth:** NextAuth.js v4 (JWT, credentials provider)
- **Styling:** Tailwind CSS 4 + shadcn/ui
- **Icons:** Lucide React
- **Email:** Nodemailer (Gmail SMTP)

## Quick Start

```bash
# 1. Install dependencies
bun install

# 2. Copy environment variables
cp .env.example .env
# Edit .env and fill in your values

# 3. Set up database
bun run db:push

# 4. Start the server
bash start.sh

# 5. Open http://localhost:3000
```

## Environment Setup

Copy `.env.example` to `.env` and fill in:

```env
DATABASE_URL="file:./db/custom.db"          # or postgresql://...
NEXTAUTH_SECRET="your-random-secret"         # openssl rand -base64 32
NEXTAUTH_URL="http://localhost:3000"         # or https://yourdomain.com
NEXT_PUBLIC_BASE_DOMAIN="yourdomain.com"     # for real subdomains
OWNER_EMAIL="your@gmail.com"                 # receives notifications
SMTP_HOST="smtp.gmail.com"
SMTP_PORT="587"
SMTP_USER="your@gmail.com"
SMTP_PASS="your-gmail-app-password"
SUPER_ADMIN_TOKEN="your-secret-token"
```

## Database Setup

### Development (SQLite — default)
```bash
bun run db:push
```

### Production (PostgreSQL)
1. Create a free database at [Supabase](https://supabase.com) or [Neon](https://neon.tech)
2. Edit `prisma/schema.prisma`:
   ```prisma
   datasource db {
     provider = "postgresql"
     url      = env("DATABASE_URL")
   }
   ```
3. Set `DATABASE_URL` in `.env` to your PostgreSQL connection string
4. Run: `bun run db:push`

## Authentication

- Uses NextAuth.js with JWT-based credentials provider
- Admin logs in at `/login` with email + password from registration
- Session token stored in HTTP-only cookie
- Tenant isolation: each user only sees their own restaurant's data
- IDOR prevention: all mutations verify resource ownership

## Deployment

### Deploy to Vercel

1. **Push to GitHub:**
   ```bash
   git init && git add . && git commit -m "Initial commit"
   git remote add origin https://github.com/YOURUSERNAME/restaurant-platform.git
   git push -u origin main
   ```

2. **Import to Vercel:**
   - Go to [vercel.com](https://vercel.com) → New Project → Import repo
   - Build command: `prisma generate && next build`
   - Add all environment variables in Vercel Settings

3. **Set up custom domain (for real subdomains):**
   - Buy domain (e.g., `yourdomain.com`)
   - Vercel → Settings → Domains → Add `*.yourdomain.com` (wildcard)
   - Configure DNS:
     ```
     A Record:    *.yourdomain.com  →  76.76.21.21
     CNAME:       yourdomain.com    →  cname.vercel-dns.com
     ```
   - Set `NEXT_PUBLIC_BASE_DOMAIN=yourdomain.com`

4. **Configure Gmail SMTP:**
   - Enable 2FA on your Gmail
   - Go to [Google Security](https://myaccount.google.com/security) → App Passwords
   - Create password for "Mail"
   - Set `SMTP_USER` and `SMTP_PASS` in Vercel env vars

## URLs

| URL | Purpose |
|-----|---------|
| `/` | Opens registration form (first time) or restaurant (after) |
| `/setup` | One-time registration form |
| `/login` | Login page (admin → dashboard, customer → restaurant) |
| `/r/your-slug` | Public restaurant website |
| `/r/your-slug/admin` | Admin dashboard |
| `/super-admin` | Platform management (token auth) |
| `/domain-config` | DNS/domain setup guide |

## Admin Panel Sections

Overview, Menu, Reservations, Orders, Messages, Inventory, Content/CMS, Gift Cards, Coupons, Staff, Locations, Subscribers, Notifications, Outbox, Activity Log, Settings

## Commands

| Command | Purpose |
|---------|---------|
| `bash start.sh` | Start server + keep-alive + cache warming |
| `bun run dev` | Start dev server only |
| `bun run db:push` | Push database schema |
| `bun run lint` | Check code quality |

## Gmail SMTP Setup

1. Enable 2-Step Verification on your Google Account
2. Go to [App Passwords](https://myaccount.google.com/apppasswords)
3. Create a new app password for "Mail"
4. Set in `.env`:
   ```env
   SMTP_USER="your@gmail.com"
   SMTP_PASS="your-16-char-app-password"
   OWNER_EMAIL="your@gmail.com"
   ```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Preview not loading | Run `bash start.sh` or wait 15s for auto-restart |
| Login not working | Check `NEXTAUTH_SECRET` is set in `.env` |
| Emails not sending | Check `SMTP_USER` and `SMTP_PASS` in `.env` |
| Database errors | Run `bun run db:push` |
| Build fails on Vercel | Set build command to `prisma generate && next build` |
| Subdomain not working | Configure wildcard DNS `*.yourdomain.com` |
| `.env` wiped | Keep-alive restores from `.env.backup` automatically |

## Security

- No secrets in source code (all in `.env`)
- `.env` and `.env.backup` are gitignored
- `.env.example` contains empty values only (safe to commit)
- NextAuth JWT with HTTP-only cookies
- Tenant isolation on every database query
- IDOR prevention via ownership verification
- Admin routes protected with `requireAdmin`
- Super-admin routes protected with token auth
- Restaurants are permanent (cannot be deleted)
- Registration is one-time only (locks after first tenant)

## License

This project is proprietary. All rights reserved.
