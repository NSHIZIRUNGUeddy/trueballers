# True Ballers — Basketball News Website

A responsive Next.js starter for a Rwanda-first basketball news platform with a Supabase-backed admin area.

## What's included
- Orange/black/white responsive news homepage and True Ballers logo
- Rwanda basketball and international categories
- Kinyarwanda / English / French language selector foundation
- Eight demo stories with sample images (replace demo copy with verified reporting)
- Article detail pages, search, most-read list, share links, comments form and newsletter signup
- Supabase admin sign-in, article create/edit/delete, image upload, draft/publish status
- Basic page-view event collection and admin activity table
- SQL schema with row-level security policies

## Requirements
- Node.js 20 or newer
- A free Supabase project
- A free Vercel account

## Run locally
1. Install Node.js LTS from https://nodejs.org/.
2. In this folder run `npm install`.
3. Copy `.env.example` to `.env.local` and fill in your Supabase project URL and anon/publishable key.
4. In Supabase Dashboard → SQL Editor, run all of `supabase/schema.sql`.
5. In Supabase Dashboard → Authentication → Users, create your client/admin user.
6. Copy that user's UUID. In SQL Editor run:
   ```sql
   insert into public.admin_profiles (id, role, display_name)
   values ('PASTE-AUTH-USER-UUID-HERE', 'admin', 'True Ballers Admin');
   ```
7. Run `npm run dev` and open http://localhost:3000.

The Supabase anon/publishable key is intended to be used in the browser with RLS enabled. NEVER put a Supabase service-role key in a `NEXT_PUBLIC_` variable or commit it to GitHub.

## Deploy to Vercel
1. Push this folder to a new GitHub repository.
2. In Vercel, import the repository.
3. Add `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY` in Project Settings → Environment Variables.
4. Deploy. Add the same variables to Preview and Production if needed.
5. In Vercel Domains, connect your custom domain and follow its DNS instructions.

## Before production
- The eight stories are design/test examples, not verified current news. Replace them with fact-checked articles and properly licensed photos.
- Live scores are a placeholder. Select a data provider whose terms allow display, then implement its API/embedding and refresh policy. Do not scrape protected score sites.
- Add rate limiting / CAPTCHA to comments and newsletter signups, and configure email confirmation/double opt-in for the newsletter.
- Add a cookie/privacy notice and a privacy policy. Analytics currently counts page-view events, not unique people; users can generate multiple events. Do not treat this as a unique-visitor metric.
- Configure Supabase Auth redirect URLs for localhost and your deployed domain.
- Add admin UI for comment moderation and newsletter export before handing it to your client; moderation policies are present in SQL, but the dashboard is intentionally a starter.
- Current article pages are a lightweight starter. For a production newsroom, add metadata/SEO, sitemap, social preview cards, pagination, image optimization, accessible language-specific content, and robust error handling.

## Free-plan notes
Supabase and Vercel have free tiers with usage limits and terms that can change. Free plans are suitable for prototyping and a small launch, but monitor bandwidth, storage, database usage, build minutes and inactivity/pause rules. A custom domain is typically a separate paid purchase/renewal. A free scoreboard API may have quotas or attribution requirements.

## Contact details included
- Phone: +250 788 569 147
- Email: moseyhabu@yahoo.com
- YouTube: https://www.youtube.com/@trueballers26true-s8f

## UI updates (October 2026)
- Public header uses a circular-cropped True Ballers logo (`public/logo-circle.png`) without a square tile.
- Removed the public top strip and changed navigation to a clean white/orange style.
- Removed public-facing admin login links. The admin route remains `/admin`.
- Search submits a keyword query and filters article title, excerpt, content and category.
- Language selector remembers Kinyarwanda (KIN), English (ENG) or French (FRA) using a browser cookie. Navigation and key homepage labels switch language. Article text itself must be entered/translated by the newsroom; this selector does not automatically translate reporting.
