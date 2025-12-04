# Deployment Guide - Railway

This guide will help you deploy OrderPath to Railway.

## Prerequisites

1. Railway account (sign up at https://railway.app)
2. GitHub account
3. Your code pushed to a GitHub repository

## Step 1: Connect GitHub Repository

1. Log in to Railway
2. Click "New Project"
3. Select "Deploy from GitHub repo"
4. Select your repository
5. Railway will automatically detect it's a Rails application

## Step 2: Configure Environment Variables

In Railway dashboard, go to your project → Variables tab and add:

### Required Variables

```bash
# Rails
RAILS_ENV=production
SECRET_KEY_BASE=<generate-with-rails-secret>
RAILS_MAX_THREADS=5

# Database (Railway will auto-provision PostgreSQL)
# DATABASE_URL is automatically set by Railway

# Redis (if using Sidekiq)
REDIS_URL=<your-redis-url>
# Or add Redis service in Railway

# Robot API
ROBOT_API_ENDPOINT=http://your-robot-api:8080/api/pick

# Port (Railway sets this automatically)
PORT=3000
```

### Generate SECRET_KEY_BASE

Run locally:
```bash
rails secret
```

Copy the generated secret and paste it as `SECRET_KEY_BASE` in Railway.

## Step 3: Database Setup

Railway automatically provisions PostgreSQL. The `DATABASE_URL` is automatically set.

To run migrations:
1. Go to your service in Railway
2. Click on "Deployments"
3. Click on the latest deployment
4. Open the "Deploy Logs"
5. Migrations run automatically during build (configured in `nixpacks.toml`)

Or manually run migrations:
1. Go to your service → "Settings" → "Generate Domain"
2. Use Railway CLI:
```bash
railway run rails db:migrate
```

## Step 4: Seed Database (Optional)

```bash
railway run rails db:seed
```

## Step 5: Configure Services

### Web Service
- Uses the `web` process from `Procfile`
- Automatically detected by Railway

### Worker Service (Sidekiq)
1. Add a new service in Railway
2. Connect to the same GitHub repo
3. Set the start command: `bundle exec sidekiq -C config/sidekiq.yml`
4. Use the same environment variables

## Step 6: Add Redis (for Sidekiq)

1. In Railway dashboard, click "New" → "Database" → "Add Redis"
2. Railway will automatically set `REDIS_URL`
3. Make sure both web and worker services have access to Redis

## Step 7: Custom Domain (Optional)

1. Go to your service → "Settings"
2. Click "Generate Domain" for a Railway domain
3. Or add a custom domain in "Custom Domain"

## Step 8: Monitor Deployment

1. Check deployment logs in Railway dashboard
2. Monitor logs: `railway logs`
3. Check application status: Visit your Railway domain

## Troubleshooting

### Database Connection Issues
- Verify `DATABASE_URL` is set correctly
- Check PostgreSQL service is running
- Run `railway run rails db:create` if needed

### Migration Errors
- Check migration files are correct
- Run `railway run rails db:migrate:status`
- Rollback if needed: `railway run rails db:rollback`

### Sidekiq Not Working
- Verify Redis is connected
- Check `REDIS_URL` is set
- Verify worker service is running
- Check Sidekiq logs: `railway logs -s worker`

### API Not Responding
- Check web service is running
- Verify PORT is set correctly (Railway sets this automatically)
- Check application logs: `railway logs`

## Railway CLI Commands

Install Railway CLI:
```bash
npm i -g @railway/cli
```

Login:
```bash
railway login
```

Link project:
```bash
railway link
```

View logs:
```bash
railway logs
```

Run commands:
```bash
railway run rails console
railway run rails db:migrate
railway run bundle exec sidekiq
```

## Continuous Deployment

Railway automatically deploys when you push to your connected branch (usually `main` or `master`).

To deploy manually:
1. Push to your repository
2. Railway will detect changes and deploy automatically

## Health Checks

Railway automatically health checks your application. Make sure your app responds to:
- `GET /` or `GET /api/v1/monitoring/status`

## Scaling

In Railway dashboard:
1. Go to your service
2. Adjust resources (CPU, Memory)
3. Railway handles scaling automatically

## Backup

Railway PostgreSQL includes automatic backups. To create manual backup:
```bash
railway run pg_dump $DATABASE_URL > backup.sql
```

## Monitoring

Use Railway's built-in metrics:
- CPU usage
- Memory usage
- Network traffic
- Request logs

Or integrate with external monitoring:
- Add monitoring endpoint: `GET /api/v1/monitoring/status`
- Set up alerts in Railway dashboard


