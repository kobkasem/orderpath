# API Usage Examples

## Authentication

All order creation endpoints require an API key. Get your API key from the customer record after seeding the database.

```bash
# Example API Key header
X-API-Key: <your-api-key-here>
```

## 1. Create an Order

### Example: Small order (will use robot warehouse - quantity < 5)

```bash
curl -X POST http://localhost:3000/api/v1/orders \
  -H "Content-Type: application/json" \
  -H "X-API-Key: <your-api-key>" \
  -d '{
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
  }'
```

**Response:**
```json
{
  "order": {
    "id": 1,
    "order_number": "ORD-2024-001",
    "status": "processing",
    "items": [
      {
        "sku_code": "IPHONE17-128GB",
        "quantity": 3,
        "quantity_from_robot": 3,
        "quantity_from_bin": 0
      }
    ]
  },
  "message": "Order received and processing started"
}
```

### Example: Large order (will use BIN location - quantity >= 5)

```bash
curl -X POST http://localhost:3000/api/v1/orders \
  -H "Content-Type: application/json" \
  -H "X-API-Key: <your-api-key>" \
  -d '{
    "order": {
      "order_number": "ORD-2024-002",
      "airway_bill_number": "AWB-123457",
      "items": [
        {
          "sku_code": "IPHONE17-128GB",
          "quantity": 10
        }
      ]
    }
  }'
```

## 2. Get Order Status

```bash
curl -X GET http://localhost:3000/api/v1/orders/1 \
  -H "X-API-Key: <your-api-key>"
```

## 3. Reprocess Order with Different Strategy

```bash
# Reprocess with robot only
curl -X POST http://localhost:3000/api/v1/orders/1/reprocess \
  -H "Content-Type: application/json" \
  -H "X-API-Key: <your-api-key>" \
  -d '{
    "picking_strategy": "robot_only"
  }'

# Reprocess with BIN only
curl -X POST http://localhost:3000/api/v1/orders/1/reprocess \
  -H "Content-Type: application/json" \
  -H "X-API-Key: <your-api-key>" \
  -d '{
    "picking_strategy": "bin_only"
  }'

# Reprocess with both (auto)
curl -X POST http://localhost:3000/api/v1/orders/1/reprocess \
  -H "Content-Type: application/json" \
  -H "X-API-Key: <your-api-key>" \
  -d '{
    "picking_strategy": "both"
  }'
```

## 4. Reprint Picking Slip

```bash
curl -X POST http://localhost:3000/api/v1/orders/1/reprint \
  -H "X-API-Key: <your-api-key>"
```

## 5. Printer Management

### List all printers
```bash
curl -X GET http://localhost:3000/api/v1/printers
```

### Create a printer
```bash
curl -X POST http://localhost:3000/api/v1/printers \
  -H "Content-Type: application/json" \
  -d '{
    "printer": {
      "name": "Warehouse Printer 1",
      "ip_address": "192.168.1.100",
      "port": 9100,
      "printer_type": "picking_slip",
      "active": true
    }
  }'
```

### Update a printer
```bash
curl -X PUT http://localhost:3000/api/v1/printers/1 \
  -H "Content-Type: application/json" \
  -d '{
    "printer": {
      "active": false
    }
  }'
```

## 6. SKU Management

### List all SKUs
```bash
curl -X GET http://localhost:3000/api/v1/skus
```

### Create a SKU
```bash
curl -X POST http://localhost:3000/api/v1/skus \
  -H "Content-Type: application/json" \
  -d '{
    "sku": {
      "sku_code": "IPHONE17-256GB",
      "name": "iPhone 17 256GB",
      "category": "Smartphone",
      "model": "iPhone 17",
      "robot_threshold": 5,
      "active": true
    }
  }'
```

## 7. Monitoring

### Get system status
```bash
curl -X GET http://localhost:3000/api/v1/monitoring/status
```

**Response:**
```json
{
  "status": {
    "orders": {
      "total": 10,
      "pending": 2,
      "processing": 1,
      "completed": 6,
      "failed": 1
    },
    "picking_slips": {
      "total": 8,
      "pending": 1,
      "printed": 6,
      "failed": 1
    },
    "api_logs": {
      "total": 25,
      "pending": 2,
      "success": 20,
      "failed": 3
    }
  }
}
```

### Get errors
```bash
curl -X GET http://localhost:3000/api/v1/monitoring/errors
```

### Retry failed order
```bash
curl -X POST http://localhost:3000/api/v1/monitoring/retry_failed \
  -H "Content-Type: application/json" \
  -d '{
    "order_id": 1,
    "picking_strategy": "auto"
  }'
```

## 8. Picking Slips

### List all picking slips
```bash
curl -X GET http://localhost:3000/api/v1/picking_slips
```

### Get picking slip details
```bash
curl -X GET http://localhost:3000/api/v1/picking_slips/1
```

### Reprint picking slip
```bash
curl -X POST http://localhost:3000/api/v1/picking_slips/1/reprint
```

## Testing with Postman

1. Import the following collection structure:
   - Base URL: `http://localhost:3000/api/v1`
   - Headers: `X-API-Key: <your-api-key>`
   - Content-Type: `application/json`

2. Create environment variables:
   - `base_url`: `http://localhost:3000/api/v1`
   - `api_key`: `<your-api-key>`

## Error Responses

All endpoints return standard error responses:

```json
{
  "error": "Error message here"
}
```

Or for validation errors:

```json
{
  "errors": [
    "Order number is required",
    "Order must have at least one item"
  ]
}
```


