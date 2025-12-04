# Railway Database Setup Guide

## Step-by-Step: Creating PostgreSQL Database on Railway

### Method 1: Using Railway Dashboard (Recommended)

1. **Log in to Railway**
   - Go to https://railway.app
   - Sign in with your GitHub account

2. **Create a New Project** (if you don't have one)
   - Click "New Project"
   - Select "Deploy from GitHub repo"
   - Choose your `orderpath` repository

3. **Add PostgreSQL Database**
   - In your project dashboard, click **"New"** button
   - Select **"Database"** → **"Add PostgreSQL"**
   - Railway will automatically provision a PostgreSQL database

4. **Get Database Connection Details**
   - Click on the PostgreSQL service you just created
   - Go to the **"Variables"** tab
   - You'll see `DATABASE_URL` automatically created
   - Railway automatically sets this for your Rails app!

5. **Connect Your Rails App**
   - Railway automatically detects the `DATABASE_URL` from the PostgreSQL service
   - Your Rails app will automatically connect to it
   - No manual configuration needed!

### Method 2: Using Railway CLI

```bash
# Install Railway CLI (if not already installed)
npm i -g @railway/cli

# Login to Railway
railway login

# Link to your project
railway link

# Add PostgreSQL database
railway add postgresql

# View database URL
railway variables
```

## Automatic Connection

Railway automatically:
- ✅ Creates `DATABASE_URL` environment variable
- ✅ Connects your Rails app to the database
- ✅ Runs migrations during deployment (if configured)

## Running Migrations

### Option 1: Automatic (Recommended)
Railway can run migrations automatically. Add this to your `nixpacks.toml`:

```toml
[phases.build]
cmds = ["bundle exec rails db:migrate"]
```

### Option 2: Manual via Railway Dashboard
1. Go to your Rails service
2. Click on "Deployments"
3. Click on the latest deployment
4. Open "Deploy Logs"
5. Migrations should run automatically

### Option 3: Manual via CLI
```bash
railway run rails db:migrate
```

### Option 4: Manual via Railway Dashboard Shell
1. Go to your Rails service
2. Click "Settings" → "Generate Domain" (if not already done)
3. Use the web terminal or SSH to run:
```bash
rails db:migrate
```

## Seeding the Database

After migrations, seed your database:

```bash
railway run rails db:seed
```

Or via Railway dashboard shell:
```bash
rails db:seed
```

## Verifying Database Connection

### Check Connection Status
```bash
railway run rails db:version
```

### Access Rails Console
```bash
railway run rails console
```

Then in console:
```ruby
# Test connection
ActiveRecord::Base.connection.execute("SELECT version();")

# Check tables
ActiveRecord::Base.connection.tables
```

## Database Management

### View Database Info
- Go to PostgreSQL service in Railway dashboard
- Click "Data" tab to see database stats
- Click "Connect" tab for connection details

### Backup Database
```bash
railway run pg_dump $DATABASE_URL > backup.sql
```

### Restore Database
```bash
railway run psql $DATABASE_URL < backup.sql
```

## Environment Variables

Railway automatically provides:
- `DATABASE_URL` - Full connection string
- `PGHOST` - Database host
- `PGPORT` - Database port
- `PGUSER` - Database user
- `PGPASSWORD` - Database password
- `PGDATABASE` - Database name

**You don't need to set these manually!** Railway handles it automatically.

## Troubleshooting

### Database Not Connecting?

1. **Check Service Status**
   - Ensure PostgreSQL service is running (green status)
   - Check if it's in the same project as your Rails app

2. **Verify Environment Variables**
   - Go to Rails service → Variables tab
   - Ensure `DATABASE_URL` is present
   - It should reference the PostgreSQL service

3. **Check Rails Logs**
   ```bash
   railway logs
   ```
   Look for database connection errors

4. **Test Connection Manually**
   ```bash
   railway run rails db:version
   ```

### Migration Errors?

1. **Check Migration Status**
   ```bash
   railway run rails db:migrate:status
   ```

2. **Reset Database** (⚠️ WARNING: Deletes all data!)
   ```bash
   railway run rails db:reset
   ```

3. **Rollback Last Migration**
   ```bash
   railway run rails db:rollback
   ```

## Best Practices

1. **Use Railway's Managed PostgreSQL** - It's automatically backed up
2. **Never commit database credentials** - Railway handles this
3. **Use migrations** - Don't modify schema manually
4. **Backup regularly** - Use Railway's built-in backups or manual dumps
5. **Monitor database size** - Check Railway dashboard regularly

## Quick Reference

```bash
# Create database (via Railway dashboard - recommended)
# Just click "New" → "Database" → "Add PostgreSQL"

# Run migrations
railway run rails db:migrate

# Seed database
railway run rails db:seed

# Access console
railway run rails console

# View logs
railway logs

# Check database version
railway run rails db:version
```

## Next Steps

After setting up the database:
1. ✅ Run migrations: `railway run rails db:migrate`
2. ✅ Seed data: `railway run rails db:seed`
3. ✅ Verify connection: `railway run rails db:version`
4. ✅ Deploy your app and test!

Your Rails app will automatically connect to the PostgreSQL database once both services are in the same Railway project!

