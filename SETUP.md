# 🚀 Restaurant Website Platform — Setup Guide

## Project Location

The entire project is at: **`/home/z/my-project/`**

### How to Download

**Method 1: ZIP Download**
1. Open the file browser on the right side
2. Navigate to `/home/z/my-project/`
3. Select all files → Right-click → "Download as ZIP"

**Method 2: Git Push**
```bash
cd /home/z/my-project
git init
git add .
git commit -m "Restaurant Website Platform — production ready"
git remote add origin https://github.com/YOURUSERNAME/restaurant-platform.git
git push -u origin main
```
Then clone on your machine:
```bash
git clone https://github.com/YOURUSERNAME/restaurant-platform.git
```

---

## Project Structure

```
/home/z/my-project/
├── src/
│   ├── app/
│   │   ├── page.tsx              # Home → redirects to /setup or restaurant
│   │   ├── login/               # Login page (admin + customer)
│   │   ├── setup/                # One-time registration form
│   │   ├── r/[slug]/             # Public restaurant page
│   │   │   └── admin/           # Admin login + dashboard
│   │   ├── super-admin/         # Super-admin portal
│   │   ├── domain-config/       # DNS/domain setup guide
│   │   └── api/                  # All API routes
│   ├── components/
│   │   ├── admin/               # Admin dashboard (16 sections)
│   │   └── saffron/             # Restaurant frontend
│   ├── lib/                     # Backend (auth, db, tenant, email)
│   └── hooks/                   # React hooks
├── prisma/                      # Database schema
├── public/                      # Static images
├── package.json
├── .env                         # Environment variables
├── .env.backup                  # Backup of env vars
├── start.sh                     # Startup script
├── keep-alive.sh                # Auto-restart daemon
└── SETUP.md                     # This guide
```

---

## How the System Works

### Flow

```
1. Visit / → No restaurant? → Opens /setup (registration form)
2. Fill the form → Restaurant name, subdomain, Gmail, password
3. Registration locks permanently (one-time only)
4. Visit / → Restaurant exists? → Opens restaurant directly
5. Visit /login → Enter Gmail + password → Admin panel opens
6. Visit /login with any other email → Opens restaurant as customer
```

### URLs

| URL | Purpose | Who |
|-----|---------|-----|
| `/` | Opens form (first time) or restaurant (after) | Everyone |
| `/setup` | One-time registration form | Restaurant owner |
| `/login` | Login page (admin → dashboard, customer → restaurant) | Everyone |
| `/r/your-slug` | Public restaurant website | Customers |
| `/r/your-slug/admin` | Admin dashboard (16 sections) | Restaurant owner |
| `/super-admin` | Platform management | You |
| `/domain-config` | DNS setup instructions | You |

---

## How to Deploy to Vercel

### Step 1: Set Up Database (PostgreSQL)

1. Go to [Supabase](https://supabase.com) → New Project (free)
2. Copy your connection string:
   ```
   postgresql://user:password@host:port/database
   ```
3. Edit `prisma/schema.prisma`:
   ```prisma
   datasource db {
     provider = "postgresql"   # change from "sqlite"
     url      = env("DATABASE_URL")
   }
   ```

### Step 2: Configure Environment

Create `.env` with your production values:

```env
DATABASE_URL="your-postgresql-connection-string"
NEXTAUTH_SECRET="run: openssl rand -base64 32"
NEXTAUTH_URL="https://your-domain.com"
ADMIN_EMAIL="your@gmail.com"
ADMIN_PASSWORD="your-secure-password"
NEXT_PUBLIC_SITE_NAME="Your Platform"
NEXT_PUBLIC_SITE_URL="https://your-domain.com"
OWNER_EMAIL="your@gmail.com"
SMTP_HOST="smtp.gmail.com"
SMTP_PORT="587"
SMTP_USER="your@gmail.com"
SMTP_PASS="your-16-char-gmail-app-password"
SUPER_ADMIN_TOKEN="your-secret-token"
NEXT_PUBLIC_BASE_DOMAIN="your-domain.com"
```

### Step 3: Push Database Schema

```bash
bun run db:push
```

### Step 4: Deploy

1. Push code to GitHub
2. Go to [vercel.com](https://vercel.com) → New Project → Import repo
3. Add ALL environment variables in Vercel Settings
4. Build command: `prisma generate && next build`
5. Deploy → Live!

### Step 5: Custom Domain (for real subdomains)

1. Buy domain (e.g., `yourplatform.com`)
2. Vercel → Settings → Domains → Add `*.yourplatform.com` (wildcard)
3. Set DNS:
   ```
   A Record:    *.yourplatform.com  →  76.76.21.21
   CNAME:       yourplatform.com    →  cname.vercel-dns.com
   ```
4. Update `NEXT_PUBLIC_BASE_DOMAIN=yourplatform.com`

Each tenant gets a real subdomain: `myrestaurant.yourplatform.com`

---

## Gmail SMTP (for real email notifications)

1. Enable 2FA on your Gmail
2. Go to [Google Security](https://myaccount.google.com/security) → App Passwords
3. Create password for "Mail" → copy the 16-character password
4. Set in `.env`:
   ```env
   SMTP_USER="your@gmail.com"
   SMTP_PASS="your-16-char-app-password"
   OWNER_EMAIL="your@gmail.com"
   ```

---

## Quick Commands

```bash
bash start.sh        # Start everything (server + keep-alive)
bun run dev          # Start dev server only
bun run db:push      # Push database schema
bun run lint         # Check code quality
```

---

## Production Checklist

- [ ] `.env` has all variables (copy from `.env.backup`)
- [ ] `NEXTAUTH_SECRET` is random 32+ chars (`openssl rand -base64 32`)
- [ ] Database changed from SQLite to PostgreSQL
- [ ] `bun run db:push` ran successfully
- [ ] Code pushed to GitHub
- [ ] Imported to Vercel
- [ ] All env vars added in Vercel
- [ ] `NEXTAUTH_URL` matches your domain
- [ ] `NEXT_PUBLIC_BASE_DOMAIN` matches your domain
- [ ] Wildcard DNS configured (optional, for subdomains)
- [ ] Gmail App Password generated for SMTP
- [ ] First tenant registered at `/setup`
- [ ] Login works at `/login`
