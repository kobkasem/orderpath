# Verify Database Connection

Your PostgreSQL connection URL:
```
postgresql://postgres:NkTKzIbaNvmGnUoesMZAhLPcMGHUxGWX@gondola.proxy.rlwy.net:38905/railway
```

## Step 1: Verify DATABASE_URL is Set in Railway

1. Go to Railway Dashboard
2. Click on your **Rails service** (web)
3. Click **"Variables"** tab
4. Look for `DATABASE_URL`
5. It should match the URL above

**If DATABASE_URL is NOT set:**
- Go to PostgreSQL service
- Click "Variables" tab
- Copy the `DATABASE_URL` value
- Go to Rails service → Variables
- Add new variable: `DATABASE_URL` = (paste the value)

## Step 2: Test Database Connection

Run this command to test the connection:

```bash
railway run rails db:version
```

If it works, you'll see the current schema version.

## Step 3: Run Migrations

Create all database tables:

```bash
railway run rails db:migrate
```

This will create:
- customers
- orders
- order_items
- skus
- inventory_locations
- picking_slips
- picking_slip_items
- printers
- api_logs

## Step 4: Verify Tables Created

```bash
railway run rails console
```

Then in console:
```ruby
ActiveRecord::Base.connection.tables
# Should show all your tables
```

## Step 5: Seed Database (Optional)

```bash
railway run rails db:seed
```

This creates sample data:
- Sample customer with API key
- Sample SKUs (iPhone 17)
- Sample inventory locations
- Sample printer

## Step 6: Redeploy Rails App

After migrations are done:
1. Go to Railway Dashboard
2. Click on Rails service
3. Click "Redeploy" or trigger a new deployment
4. Healthcheck should pass now!

## Troubleshooting

### Connection Refused?
- Check PostgreSQL service is running (green status)
- Verify DATABASE_URL is correct
- Make sure both services are in same Railway project

### Migrations Fail?
- Check logs: `railway logs`
- Verify DATABASE_URL format is correct
- Try: `railway run rails db:migrate:status`

### Still Getting Errors?
- Check Railway logs for specific error messages
- Verify all environment variables are set
- Make sure PostgreSQL service is active

