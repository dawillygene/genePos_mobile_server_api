# GenePos API Documentation

## Overview
The GenePos API is a RESTful web service built with Laravel that provides comprehensive Point of Sale functionality. All API responses are in JSON format.

## Base URL
```
http://localhost:8001/api
```

## Authentication
The API uses Laravel Sanctum for authentication. Most endpoints require a valid Bearer token.

### Headers
```
Accept: application/json
Content-Type: application/json
Authorization: Bearer {your-token}
```

## Authentication Endpoints

### Google OAuth Login
```http
POST /auth/google
```

**Request Body:**
```json
{
  "access_token": "google_access_token"
}
```

**Response (200):**
```json
{
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "google_id": "123456789",
    "created_at": "2025-08-03T19:44:13.000000Z"
  },
  "token": "1|laravel_sanctum_token"
}
```

### Logout
```http
POST /auth/logout
```
*Requires authentication*

### Get Authenticated User
```http
GET /auth/user
```
*Requires authentication*

## Product Management

### List All Products
```http
GET /products
```
*Requires authentication*

**Response (200):**
```json
[
  {
    "id": 1,
    "name": "Coca Cola 500ml",
    "description": "Refreshing cola drink",
    "price": "2.50",
    "cost_price": "1.50",
    "stock_quantity": 100,
    "barcode": "1234567890123",
    "sku": "COKE-500ML",
    "category": "Beverages",
    "image_url": null,
    "is_active": true,
    "created_at": "2025-08-03T19:44:13.000000Z",
    "updated_at": "2025-08-03T19:44:13.000000Z"
  }
]
```

### Create Product
```http
POST /products
```
*Requires authentication*

**Request Body:**
```json
{
  "name": "Product Name",
  "description": "Product description",
  "price": 9.99,
  "cost_price": 6.99,
  "stock_quantity": 50,
  "barcode": "1234567890123",
  "sku": "PROD-SKU",
  "category": "Category Name",
  "image_url": "https://example.com/image.jpg",
  "is_active": true
}
```

**Validation Rules:**
- `name`: required, string, max 255 characters
- `price`: required, numeric, minimum 0
- `cost_price`: required, numeric, minimum 0
- `stock_quantity`: required, integer, minimum 0
- `barcode`: optional, string, unique
- `sku`: required, string, unique
- `category`: required, string
- `is_active`: boolean

### Get Single Product
```http
GET /products/{id}
```
*Requires authentication*

### Update Product
```http
PUT /products/{id}
```
*Requires authentication*

### Delete Product
```http
DELETE /products/{id}
```
*Requires authentication*

## Sales Management

### List All Sales
```http
GET /sales
```
*Requires authentication*

**Response (200):**
```json
[
  {
    "id": 1,
    "user_id": 1,
    "total_amount": "15.99",
    "tax_amount": "1.60",
    "discount_amount": "0.00",
    "payment_method": "cash",
    "status": "completed",
    "notes": "Regular sale",
    "created_at": "2025-08-03T19:44:13.000000Z",
    "sale_items": [
      {
        "id": 1,
        "product_id": 1,
        "quantity": 2,
        "unit_price": "2.50",
        "total_price": "5.00",
        "product": {
          "id": 1,
          "name": "Coca Cola 500ml"
        }
      }
    ]
  }
]
```

### Create Sale
```http
POST /sales
```
*Requires authentication*

**Request Body:**
```json
{
  "total_amount": 15.99,
  "tax_amount": 1.60,
  "discount_amount": 0.00,
  "payment_method": "cash",
  "status": "completed",
  "notes": "Regular sale",
  "sale_items": [
    {
      "product_id": 1,
      "quantity": 2,
      "unit_price": 2.50
    }
  ]
}
```

### Get Single Sale
```http
GET /sales/{id}
```
*Requires authentication*

### Update Sale
```http
PUT /sales/{id}
```
*Requires authentication*

### Delete Sale
```http
DELETE /sales/{id}
```
*Requires authentication*

## Dashboard & Reports

### Dashboard Overview
```http
GET /dashboard
```
*Requires authentication*

**Response (200):**
```json
{
  "total_sales": 1250.75,
  "total_products": 45,
  "low_stock_products": 3,
  "recent_sales": 12,
  "top_selling_products": [
    {
      "id": 1,
      "name": "Coca Cola 500ml",
      "total_sold": 150
    }
  ]
}
```

### Sales Report
```http
GET /reports/sales
```
*Requires authentication*

**Query Parameters:**
- `start_date`: Start date (YYYY-MM-DD)
- `end_date`: End date (YYYY-MM-DD)
- `period`: daily|weekly|monthly

## Error Responses

### Validation Error (422)
```json
{
  "message": "The given data was invalid.",
  "errors": {
    "name": ["The name field is required."],
    "price": ["The price must be a number."]
  }
}
```

### Unauthorized (401)
```json
{
  "message": "Unauthenticated."
}
```

### Not Found (404)
```json
{
  "message": "No query results for model [App\\Models\\Product] 999"
}
```

### Server Error (500)
```json
{
  "message": "Server Error"
}
```

## Testing with cURL

### Authenticate and get token
```bash
curl -X POST http://localhost:8001/api/auth/google \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{"access_token": "your_google_token"}'
```

### Get products with authentication
```bash
curl -X GET http://localhost:8001/api/products \
  -H "Accept: application/json" \
  -H "Authorization: Bearer your_sanctum_token"
```

### Create a product
```bash
curl -X POST http://localhost:8001/api/products \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer your_sanctum_token" \
  -d '{
    "name": "Test Product",
    "price": 9.99,
    "cost_price": 5.99,
    "stock_quantity": 20,
    "sku": "TEST-001",
    "category": "Test"
  }'
```

## Rate Limiting
The API implements rate limiting:
- 60 requests per minute for authenticated users
- 6 requests per minute for unauthenticated users

## Status Codes
- `200` - OK
- `201` - Created
- `204` - No Content
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `422` - Unprocessable Entity
- `429` - Too Many Requests
- `500` - Internal Server Error
