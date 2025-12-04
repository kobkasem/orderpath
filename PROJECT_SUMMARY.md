# OrderPath - Project Summary

## Overview

OrderPath is a comprehensive fulfillment service software built with Ruby on Rails that handles the complete order fulfillment process from receiving sale orders to generating picking slips and coordinating with robotic picking systems.

## Key Features Implemented

### 1. Order Receiving & API Validation ✅
- RESTful API endpoint for receiving sale orders (Airway bills)
- Customer API key authentication
- Comprehensive order validation (structure, SKU existence, quantities)
- API endpoint validation for customers

### 2. Intelligent Picking Decision Logic ✅
- **Quantity-based routing**: 
  - If quantity < `robot_threshold` (default: 5) → Use robot warehouse
  - If quantity >= `robot_threshold` → Use BIN location
- **Automatic fallback**:
  - If robot doesn't have enough → Automatically use BIN
  - If BIN doesn't have enough → Automatically use robot
  - If neither has enough → Use both locations
- **Manual strategy selection**:
  - `robot_only`: Force robot warehouse only
  - `bin_only`: Force BIN location only
  - `both`/`auto`: Automatic selection with fallback

### 3. Inventory Management ✅
- Track inventory across robot and BIN locations
- Real-time availability calculation
- Reservation and allocation system
- Support for multiple BIN locations per SKU

### 4. Picking Slip Generation ✅
- Automatic picking slip creation
- **Organized format**:
  - BIN location items listed first
  - Robot warehouse items listed second
- Includes SKU codes, quantities, and location codes
- Sequential ordering for efficient picking

### 5. Printer Management ✅
- IP-based printer configuration
- Support for multiple printers
- Automated printing via HTTP POST to printer IP
- Printer status tracking (active/inactive)
- Configurable printer types (picking_slip, label)

### 6. Robot Integration ✅
- API integration with Hairobotic system
- Sends pick commands via HTTP POST
- Tracks robot API calls and responses
- Automatic retry on failure

### 7. Monitoring & Retry System ✅
- Comprehensive monitoring dashboard
- Track order status, picking slips, and API calls
- View failed operations
- Manual retry with strategy selection
- Automatic retry for failed API calls (3 attempts)
- Reprint functionality for picking slips

### 8. Background Job Processing ✅
- Sidekiq integration for async processing
- Order processing jobs
- Print jobs
- Retry jobs for failed operations

## Technology Stack

- **Framework**: Ruby on Rails 7.1 (API mode)
- **Database**: PostgreSQL
- **Background Jobs**: Sidekiq
- **HTTP Client**: HTTParty
- **Hosting**: Railway (configured)
- **Version Control**: GitHub ready

## Database Schema

### Core Tables
- `customers`: Customer info and API configuration
- `orders`: Order records with status tracking
- `order_items`: Line items with allocation details
- `skus`: Product master data with robot thresholds
- `inventory_locations`: Inventory tracking (robot/BIN)
- `picking_slips`: Generated picking slips
- `picking_slip_items`: Items on picking slips with sequence
- `printers`: Printer configuration
- `api_logs`: API call logging and retry tracking

## API Endpoints

### Order Management
- `POST /api/v1/orders` - Create order
- `GET /api/v1/orders/:id` - Get order status
- `POST /api/v1/orders/:id/reprocess` - Reprocess with strategy
- `POST /api/v1/orders/:id/reprint` - Reprint picking slip

### Printer Management
- `GET /api/v1/printers` - List printers
- `POST /api/v1/printers` - Create printer
- `PUT /api/v1/printers/:id` - Update printer
- `DELETE /api/v1/printers/:id` - Delete printer

### SKU Management
- `GET /api/v1/skus` - List SKUs
- `POST /api/v1/skus` - Create SKU
- `GET /api/v1/skus/:id` - Get SKU details

### Monitoring
- `GET /api/v1/monitoring/status` - System status
- `GET /api/v1/monitoring/errors` - View errors
- `POST /api/v1/monitoring/retry_failed` - Retry failed operations

## Business Logic Flow

1. **Order Receipt**
   - Customer sends order via API with API key
   - System validates order structure and SKUs
   - Order created with status "pending"

2. **Order Processing** (Background Job)
   - Determine picking strategy based on quantity and availability
   - Allocate inventory from appropriate locations
   - Create picking slip with items in correct order (BIN first, then robot)
   - Send robot commands if robot picking is needed
   - Mark order as completed

3. **Picking Slip Printing** (Background Job)
   - Format picking slip content
   - Send to configured printer via IP
   - Track print status and retry on failure

4. **Monitoring & Retry**
   - Monitor all operations via dashboard
   - Retry failed operations manually or automatically
   - Reprint picking slips as needed

## Configuration

### Environment Variables
- `DATABASE_URL` - PostgreSQL connection
- `REDIS_URL` - Redis connection for Sidekiq
- `ROBOT_API_ENDPOINT` - Hairobotic API endpoint
- `SECRET_KEY_BASE` - Rails secret key

### SKU Configuration
- `robot_threshold`: Quantity threshold for robot vs BIN decision (default: 5)
- Per-SKU configuration allows different thresholds

### Printer Configuration
- IP address and port
- Printer type
- Active/inactive status

## Deployment

### Railway Deployment
- Configured with `railway.json` and `nixpacks.toml`
- Automatic database provisioning
- Environment variable configuration
- Separate web and worker services

### Local Development
- PostgreSQL required
- Redis required for Sidekiq
- Run migrations and seed data
- Start Rails server and Sidekiq worker

## Testing

See `API_EXAMPLES.md` for comprehensive API usage examples and curl commands.

## Documentation

- `README.md` - Main documentation
- `QUICKSTART.md` - Quick setup guide
- `API_EXAMPLES.md` - API usage examples
- `DEPLOYMENT.md` - Railway deployment guide
- `CONTRIBUTING.md` - Contribution guidelines

## Next Steps

1. **Testing**: Add RSpec tests for services and controllers
2. **UI**: Consider adding a web dashboard for monitoring
3. **Notifications**: Add email/SMS notifications for failures
4. **Analytics**: Add reporting and analytics endpoints
5. **Webhooks**: Add webhook support for order status updates
6. **Barcode Support**: Add barcode generation for picking slips

## Support

For issues or questions:
- Check documentation files
- Review API examples
- Check monitoring endpoints for system status


