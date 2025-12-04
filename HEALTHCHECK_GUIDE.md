# Healthcheck Guide - Understanding and Fixing Healthcheck Failures

## What is a Healthcheck?

A **healthcheck** is a mechanism that Railway uses to verify your application is running correctly. It works like this:

1. **Railway sends HTTP requests** to a specific endpoint (like `/` or `/api/v1/monitoring/status`)
2. **Your app responds** with HTTP status codes (200 = healthy, 500 = unhealthy)
3. **Railway monitors** these responses to determine if your service is working
4. **If healthcheck fails**, Railway considers your service unhealthy and may restart it

## Why Healthcheck Fails

Common reasons:

### 1. **Server Not Started Yet**
- Rails takes time to boot up (10-30 seconds)
- Healthcheck runs too early before server is ready

### 2. **Database Connection Issues**
- Database not connected yet
- Database credentials wrong
- Database service not running

### 3. **Application Errors**
- Code errors causing crashes
- Missing environment variables
- Configuration issues

### 4. **Wrong Healthcheck Path**
- Endpoint doesn't exist
- Route not configured correctly
- Authentication blocking the request

### 5. **Timeout Too Short**
- Healthcheck timeout is shorter than server startup time
- Server needs more time to respond

## How to Fix Healthcheck Failures

### Solution 1: Check Your Healthcheck Endpoint

Make sure your healthcheck endpoint exists and works:

```bash
# Test locally
curl http://localhost:3000/
# or
curl http://localhost:3000/api/v1/monitoring/status
```

### Solution 2: Make Healthcheck Endpoint Simple

The healthcheck should be fast and not depend on database:

```ruby
# Good: Simple, fast response
def status
  render json: { status: 'ok' }
end

# Bad: Slow, depends on database
def status
  stats = {
    orders: Order.count,  # This might fail if DB not connected
    # ...
  }
end
```

### Solution 3: Increase Healthcheck Timeout

In `railway.json`:

```json
{
  "deploy": {
    "healthcheckTimeout": 300  // Increase from 100 to 300 seconds
  }
}
```

### Solution 4: Handle Database Connection Gracefully

```ruby
def status
  begin
    ActiveRecord::Base.connection.execute("SELECT 1")
    render json: { status: 'ok', database: 'connected' }
  rescue => e
    # Still return OK even if DB not connected yet
    render json: { status: 'ok', database: 'connecting' }
  end
end
```

### Solution 5: Check Railway Logs

1. Go to Railway dashboard
2. Click on your service
3. Click "Logs" tab
4. Look for errors during startup
5. Check if server is actually starting

### Solution 6: Verify Environment Variables

Make sure all required environment variables are set:
- `DATABASE_URL` (should be auto-set by Railway)
- `RAILS_ENV=production`
- `SECRET_KEY_BASE`
- `PORT` (auto-set by Railway)

### Solution 7: Disable Healthcheck Temporarily

If you need to debug, you can disable healthcheck:

```json
{
  "deploy": {
    "healthcheckPath": null
  }
}
```

**Note:** This is not recommended for production, but useful for debugging.

## Current Configuration

Your current setup:

- **Healthcheck Path**: `/` (root route)
- **Healthcheck Timeout**: 300 seconds
- **Endpoint**: Points to `monitoring#status` controller
- **Response**: Returns JSON with status, handles DB connection failures

## Troubleshooting Steps

1. **Check if server is starting:**
   ```bash
   # In Railway logs, look for:
   "Listening on tcp://0.0.0.0:3000"
   ```

2. **Test the endpoint manually:**
   ```bash
   # Get your Railway URL
   curl https://your-app.up.railway.app/
   ```

3. **Check database connection:**
   ```bash
   # In Railway, run:
   railway run rails db:version
   ```

4. **Check for errors in logs:**
   - Look for "Error", "Exception", "Failed" in Railway logs
   - Check if migrations ran successfully
   - Verify all gems installed correctly

5. **Verify routes:**
   ```bash
   railway run rails routes | grep monitoring
   ```

## Best Practices

1. **Keep healthcheck simple** - Don't query database if not necessary
2. **Return 200 OK quickly** - Healthcheck should respond in < 1 second
3. **Handle failures gracefully** - Don't crash if DB not connected
4. **Use appropriate timeout** - Give enough time for server to start
5. **Monitor logs** - Check Railway logs regularly

## Quick Fix Checklist

- [ ] Healthcheck endpoint exists and responds
- [ ] Healthcheck returns 200 OK status
- [ ] Timeout is long enough (300+ seconds)
- [ ] Database connection is handled gracefully
- [ ] Server is actually starting (check logs)
- [ ] No errors in Railway logs
- [ ] Environment variables are set correctly

## Still Having Issues?

If healthcheck still fails:

1. **Check Railway logs** - Look for startup errors
2. **Test endpoint manually** - Use curl or browser
3. **Simplify healthcheck** - Make it return just `{ status: 'ok' }`
4. **Increase timeout** - Try 600 seconds
5. **Check database** - Ensure PostgreSQL service is running
6. **Verify routes** - Make sure root route exists

