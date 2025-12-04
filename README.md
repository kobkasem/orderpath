# OrderPath - Fulfillment Service Software

A comprehensive fulfillment service system that handles order processing, inventory management, robotic picking, and automated printing.

## Features

- **Order Management**: Receive and process sale orders (Airway bills) via API
- **Smart Picking Logic**: Automatically determines whether to use robotic warehouse or BIN locations based on quantity thresholds
- **Inventory Management**: Track inventory across robot and BIN locations
- **Printer Management**: IP-based printer configuration for automated picking slip printing
- **Monitoring & Retry**: Comprehensive monitoring dashboard and automatic retry mechanisms
- **Flexible Picking Strategies**: Support for robot-only, BIN-only, or automatic picking

## Technology Stack

- **Framework**: Ruby on Rails 7.1 (API mode)
- **Database**: PostgreSQL
- **Background Jobs**: Sidekiq
- **Hosting**: Railway
- **Version Control**: GitHub

## Setup

### Prerequisites

- Ruby 3.2.0 or higher
- PostgreSQL 12 or higher
- Redis (for Sidekiq)

### Installation

1. Clone the repository:
```bash
git clone <your-repo-url>
cd orderpath
```

2. Install dependencies:
```bash
bundle install
```

3. Set up the database:
```bash
rails db:create
rails db:migrate
rails db:seed
```

4. Start Redis (required for Sidekiq):
```bash
redis-server
```

5. Start the Rails server:
```bash
rails server
```

6. Start Sidekiq (in a separate terminal):
```bash
bundle exec sidekiq
```

## API Documentation

### Authentication

All order creation endpoints require an API key in the header:
```
X-API-Key: <customer_api_key>
```

### Endpoints

#### Create Order
```
POST /api/v1/orders
Content-Type: application/json
X-API-Key: <api_key>

{
  "order": {
    "order_number": "ORD-2024-001",
    "airway_bill_number": "AWB-123456",
    "items": [
      {
        "sku_code": "IPHONE17-128GB",
        "quantity": 3
      }
    ]
  }
}
```

#### Get Order Status
```
GET /api/v1/orders/:id
```

#### Reprocess Order
```
POST /api/v1/orders/:id/reprocess
{
  "picking_strategy": "auto" // Options: "auto", "robot_only", "bin_only", "both"
}
```

#### Reprint Picking Slip
```
POST /api/v1/orders/:id/reprint
```

#### Printer Management
```
GET    /api/v1/printers
POST   /api/v1/printers
PUT    /api/v1/printers/:id
DELETE /api/v1/printers/:id
```

#### Monitoring
```
GET /api/v1/monitoring/status
GET /api/v1/monitoring/errors
POST /api/v1/monitoring/retry_failed
```

## Picking Logic

The system uses intelligent picking logic based on SKU configuration:

1. **Quantity Threshold**: If quantity < `robot_threshold` (default: 5), use robot warehouse
2. **Quantity >= Threshold**: If quantity >= `robot_threshold`, use BIN location
3. **Insufficient Inventory**: If one location doesn't have enough, automatically picks from both
4. **Robot Shortage**: If robot warehouse is insufficient, falls back to BIN location

### Picking Slip Format

Picking slips are organized with:
- BIN location items listed first
- Robot warehouse items listed second
- All items include SKU code, quantity, and location code

## Environment Variables

**⚠️ SECURITY WARNING: Never commit `.env` files with real secrets!**

Create a `.env` file from the `env.example` template:

```bash
cp env.example .env
# Then edit .env with your actual values
```

**Important:** The `.env` file is already in `.gitignore` and will NOT be committed. Only commit the `env.example` template file.

Required environment variables:

```bash
# Database
DATABASE_URL=postgresql://user:password@host:port/database
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=password
DATABASE_HOST=localhost
DATABASE_PORT=5432

# Robot API
ROBOT_API_ENDPOINT=http://robot-system:8080/api/pick

# Redis (for Sidekiq)
REDIS_URL=redis://localhost:6379/0

# Rails
RAILS_ENV=production
SECRET_KEY_BASE=<generate-with-rails-secret>
```

**Generate SECRET_KEY_BASE:**
```bash
rails secret
```

See `SECURITY.md` for detailed security guidelines.

## Railway Deployment

1. Connect your GitHub repository to Railway
2. Railway will automatically detect the Rails application
3. Set environment variables in Railway dashboard
4. Railway will handle database provisioning automatically

### Railway-Specific Configuration

The `railway.json` file configures:
- Build process (Nixpacks)
- Start command
- Restart policy

## Database Schema

### Key Tables

- **customers**: Customer information and API configuration
- **orders**: Order records with status tracking
- **order_items**: Individual line items in orders
- **skus**: Product/SKU master data
- **inventory_locations**: Inventory tracking (robot and BIN)
- **picking_slips**: Generated picking slips
- **picking_slip_items**: Items on picking slips
- **printers**: Printer configuration
- **api_logs**: API call logging and retry tracking

## Seed Data

Run `rails db:seed` to create sample data:
- Sample customers with API keys
- Sample SKUs (including iPhone 17)
- Sample inventory locations
- Sample printers

## Monitoring

Access monitoring endpoints to:
- View system status and statistics
- Check for failed orders, picking slips, and API calls
- Retry failed operations with different picking strategies

## Error Handling

The system includes comprehensive error handling:
- Automatic retry for failed API calls (3 attempts)
- Error logging in `api_logs` table
- Manual retry via monitoring endpoints
- Status tracking for all operations

## License

Proprietary - All rights reserved


