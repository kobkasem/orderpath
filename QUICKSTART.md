# Quick Start Guide

Get OrderPath up and running in 5 minutes!

## Prerequisites Check

```bash
# Check Ruby version (need 3.2.0+)
ruby -v

# Check PostgreSQL
psql --version

# Check Redis (for Sidekiq)
redis-cli ping
```

## Installation Steps

### 1. Install Dependencies

```bash
bundle install
```

### 2. Setup Database

```bash
# Create database
rails db:create

# Run migrations
rails db:migrate

# Seed sample data
rails db:seed
```

The seed script will create:
- A sample customer with API key
- Sample SKUs (iPhone 17 models)
- Inventory locations (robot and BIN)
- A sample printer

**Important:** Save the API key displayed after seeding - you'll need it for API calls!

### 3. Start Services

**Terminal 1 - Rails Server:**
```bash
rails server
```

**Terminal 2 - Sidekiq (Background Jobs):**
```bash
bundle exec sidekiq
```

**Terminal 3 - Redis (if not running as service):**
```bash
redis-server
```

### 4. Test the API

Get your API key from the seed output, then:

```bash
# Test order creation (small order - will use robot)
curl -X POST http://localhost:3000/api/v1/orders \
  -H "Content-Type: application/json" \
  -H "X-API-Key: YOUR_API_KEY_HERE" \
  -d '{
    "order": {
      "order_number": "ORD-TEST-001",
      "airway_bill_number": "AWB-TEST-001",
      "items": [
        {
          "sku_code": "IPHONE17-128GB",
          "quantity": 3
        }
      ]
    }
  }'
```

### 5. Check Order Status

```bash
# Replace 1 with your order ID
curl -X GET http://localhost:3000/api/v1/orders/1 \
  -H "X-API-Key: YOUR_API_KEY_HERE"
```

### 6. View Monitoring Dashboard

```bash
curl -X GET http://localhost:3000/api/v1/monitoring/status
```

## Common Issues

### Database Connection Error
```bash
# Check PostgreSQL is running
sudo service postgresql status

# Create user if needed
sudo -u postgres createuser -s $USER
```

### Redis Connection Error
```bash
# Start Redis
redis-server

# Or install Redis
# macOS: brew install redis
# Ubuntu: sudo apt-get install redis-server
```

### Port Already in Use
```bash
# Kill process on port 3000
lsof -ti:3000 | xargs kill -9

# Or use different port
PORT=3001 rails server
```

## Next Steps

1. **Configure Printer**: Update printer IP in database or via API
2. **Add More SKUs**: Use the SKU API to add products
3. **Set Robot API**: Configure `ROBOT_API_ENDPOINT` environment variable
4. **Read Documentation**: Check `API_EXAMPLES.md` for detailed API usage

## Development Tips

- Check logs: `tail -f log/development.log`
- Rails console: `rails console`
- Database console: `rails dbconsole`
- View Sidekiq web UI: Add `require 'sidekiq/web'` and mount in routes

## Production Deployment

See `DEPLOYMENT.md` for Railway deployment instructions.

## Need Help?

- Check `README.md` for full documentation
- Review `API_EXAMPLES.md` for API usage
- See `DEPLOYMENT.md` for deployment guide


