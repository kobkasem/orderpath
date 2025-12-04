# Database Setup Guide - MUST DO THIS FIRST!

## ⚠️ IMPORTANT: Database Must Be Set Up Before Deployment

Your Rails app **requires a PostgreSQL database** to run. If the database isn't set up, your app will fail to start.

## Step-by-Step: Set Up Database on Railway

### Step 1: Create PostgreSQL Database in Railway

1. **Go to Railway Dashboard**
   - Log in at https://railway.app
   - Open your project

2. **Add PostgreSQL Service**
   - Click **"New"** button
   - Select **"Database"** → **"Add PostgreSQL"**
   - Railway will automatically create a PostgreSQL database

3. **Verify Database is Running**
   - You should see a green "Postgres" service card
   - Status should show "Active" or "Running"

### Step 2: Verify Database Connection

Railway automatically sets `DATABASE_URL` environment variable. Check:

1. Go to your **Rails service** (web)
2. Click **"Variables"** tab
3. Look for `DATABASE_URL` - it should be there automatically
4. It should look like: `postgresql://user:password@host:port/database`

### Step 3: Run Database Migrations

After database is created, run migrations:

**Option A: Via Railway Dashboard**
1. Go to your Rails service
2. Click "Deployments" → Latest deployment
3. Check logs - migrations should run automatically (configured in `nixpacks.toml`)

**Option B: Via Railway CLI**
```bash
railway run rails db:migrate
```

**Option C: Via Railway Dashboard Terminal**
1. Go to Rails service → Settings
2. Open terminal/SSH
3. Run: `rails db:migrate`

### Step 4: Seed Database (Optional)

```bash
railway run rails db:seed
```

## Why Database is Required

Your Rails app needs the database because:

1. **Models** - Your app uses ActiveRecord models (Order, Customer, SKU, etc.)
2. **Migrations** - Database tables need to be created
3. **Startup** - Rails tries to connect to database during initialization

## Current Database Requirements

Your app needs these tables:
- `customers`
- `orders`
- `order_items`
- `skus`
- `inventory_locations`
- `picking_slips`
- `picking_slip_items`
- `printers`
- `api_logs`

All these are created by running migrations.

## Troubleshooting

### Database Not Connecting?

1. **Check PostgreSQL Service Status**
   - Go to Railway dashboard
   - Find "Postgres" service
   - Should be green/running

2. **Verify DATABASE_URL**
   - Rails service → Variables tab
   - `DATABASE_URL` should exist
   - Should reference the PostgreSQL service

3. **Check Logs**
   ```bash
   railway logs
   ```
   Look for database connection errors

4. **Test Connection**
   ```bash
   railway run rails db:version
   ```

### Migrations Not Running?

1. **Check Build Logs**
   - Look for: `bundle exec rails db:migrate`
   - Check if it succeeded or failed

2. **Run Manually**
   ```bash
   railway run rails db:migrate
   ```

3. **Check Migration Status**
   ```bash
   railway run rails db:migrate:status
   ```

## Quick Checklist

Before deploying, make sure:

- [ ] PostgreSQL service is created in Railway
- [ ] PostgreSQL service is running (green status)
- [ ] `DATABASE_URL` is set in Rails service variables
- [ ] Migrations have run successfully
- [ ] Database tables exist (check with `rails db:version`)

## After Database is Set Up

Once database is configured:

1. **Redeploy your Rails app**
   - Railway will automatically use the `DATABASE_URL`
   - Migrations will run during build
   - Server should start successfully

2. **Verify Healthcheck**
   - `/health` endpoint should respond
   - Healthcheck should pass

3. **Test API**
   - Try creating an order via API
   - Check if data is saved to database

## Summary

**YES, you MUST set up the database first!**

1. Create PostgreSQL service in Railway
2. Railway automatically sets `DATABASE_URL`
3. Run migrations: `railway run rails db:migrate`
4. Redeploy your Rails app
5. Healthcheck should pass

Without a database, your Rails app cannot start because it needs to connect to PostgreSQL during initialization.

