# GenePos API Documentation

## Overview
The GenePos API is a comprehensive RESTful web service built with Laravel that provides complete Point of Sale functionality with multi-tenant shop management, role-based access control, and multiple authentication methods. All API responses are in JSON format.

## Interactive Documentation
🚀 **Visit the interactive API documentation at:**
- **Local Development**: http://localhost:8002/docs
- **Production**: https://genepos.dawillygene.com/docs

The interactive docs include:
- Complete endpoint reference with examples
- Authentication testing interface
- Request/response schemas
- Postman collection download
- OpenAPI specification

## Base URLs
```
Local Development: http://localhost:8002/api
Production: https://genepos.dawillygene.com/api
```

## Key Features
- ✅ **Multi-tenant Architecture**: Complete shop isolation with role-based access control
- ✅ **Dual Authentication**: Google OAuth and traditional email/password login
- ✅ **Shop Management**: Create and manage shops, team members, and settings
- ✅ **Product Management**: CRUD operations for products with shop isolation
- ✅ **Sales Management**: Process sales, manage transactions, and generate reports
- ✅ **Team Management**: Add sales persons, manage permissions, and track activity
- ✅ **API Documentation**: Auto-generated interactive documentation with Scribe
- ✅ **Data Isolation**: Complete separation of data between shops
- ✅ **Role-based Permissions**: Owner and sales person access levels

## Multi-Tenant Architecture
The API supports complete multi-tenant shop management:
- **Owner**: Can create shops, manage team members, access all shop data and statistics
- **Sales Person**: Can manage products and sales within their assigned shop only
- **Data Isolation**: Users only see data from their assigned shop
- **Security**: Cross-shop data access is completely prevented

## Authentication Methods
The API supports two authentication methods using Laravel Sanctum tokens:

### 1. Google OAuth Authentication
For seamless single sign-on integration

### 2. Email/Password Authentication  
For traditional registration and login workflows

### Headers
```
Accept: application/json
Content-Type: application/json
Authorization: Bearer {your-token}
```

## Authentication Endpoints

### 1. User Registration (Email/Password)
```http
POST /auth/register
```

**Request Body:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "password_confirmation": "password123",
  "role": "owner"
}
```

**Response (201):**
```json
{
  "message": "User registered successfully",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "role": "owner",
    "shop_id": null,
    "is_active": true,
    "created_at": "2025-08-03T19:44:13.000000Z"
  },
  "token": "1|laravel_sanctum_token"
}
```

### 2. Email/Password Login
```http
POST /auth/login
```

**Request Body:**
```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

**Response (200):**
```json
{
  "message": "Login successful",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "role": "owner",
    "shop_id": 1,
    "is_active": true,
    "last_login_at": "2025-08-03T22:30:15.000000Z"
  },
  "token": "1|laravel_sanctum_token"
}
```

### 3. Google OAuth Login
```http
POST /auth/google
```

**Request Body:**
```json
{
  "id_token": "google_id_token_here"
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
    "role": "owner",
    "created_at": "2025-08-03T19:44:13.000000Z"
  },
  "token": "1|laravel_sanctum_token"
}
```

### 4. Get Current User
```http
GET /auth/user
```
*Requires authentication*

**Response (200):**
```json
{
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "role": "owner",
    "shop_id": 1,
    "is_active": true
  }
}
```
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

## Shop Management Endpoints

### List Shops
```http
GET /shops
```
**Response (200):**
```json
[
  {
    "id": 1,
    "name": "Tech Store",
    "slug": "tech-store",
    "description": "Electronics and gadgets store",
    "address": "123 Tech Street, Silicon Valley",
    "phone": "+1-555-0101",
    "email": "tech@store.com",
    "currency": "USD",
    "timezone": "America/Los_Angeles",
    "is_active": true,
    "owner_id": 1,
    "created_at": "2025-08-03T19:44:13.000000Z",
    "updated_at": "2025-08-03T19:44:13.000000Z"
  }
]
```

### Create Shop (Owner only)
```http
POST /shops
```
**Request Body:**
```json
{
  "name": "My Shop",
  "description": "Description of my shop",
  "address": "123 Main Street",
  "phone": "+1-555-0123",
  "email": "contact@myshop.com",
  "currency": "USD",
  "timezone": "America/New_York"
}
```

### Get Shop Statistics
```http
GET /shops/{id}/statistics
```
**Response (200):**
```json
{
  "total_products": 25,
  "active_products": 23,
  "low_stock_products": 3,
  "total_sales": 150,
  "total_revenue": 15750.50,
  "total_team_members": 5,
  "active_team_members": 4
}
```

## Team Management Endpoints

### List Team Members
```http
GET /team
```
**Response (200):**
```json
[
  {
    "id": 2,
    "name": "Mike Johnson",
    "email": "mike@techstore.com",
    "role": "sales_person",
    "is_active": true,
    "created_at": "2025-08-03T19:44:13.000000Z",
    "updated_at": "2025-08-03T19:44:13.000000Z"
  }
]
```

### Add Sales Person (Owner only)
```http
POST /team
```
**Request Body:**
```json
{
  "name": "New Sales Person",
  "email": "sales@myshop.com",
  "password": "secure_password",
  "role": "sales_person"
}
```

### Toggle Team Member Status (Owner only)
```http
PATCH /team/{id}/toggle-status
```
**Response (200):**
```json
{
  "message": "Team member activated successfully",
  "user": {
    "id": 2,
    "name": "Mike Johnson",
    "email": "mike@techstore.com",
    "role": "sales_person",
    "is_active": true,
    "updated_at": "2025-08-03T19:44:13.000000Z"
  }
}
```

## Testing & Development

### Test Data Available
The API comes with seeded test data for immediate testing:

**Shop Owners:**
- Email: `john@example.com`, Password: `password` (Tech Store Owner)
- Email: `jane@example.com`, Password: `password` (Fashion Boutique Owner)

**Sales Persons:**
- Email: `mike@techstore.com`, Password: `password` (Tech Store)
- Email: `sarah@fashionboutique.com`, Password: `password` (Fashion Boutique)

### Quick Start Testing
1. **Register a new user:**
```bash
curl -X POST localhost:8002/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","password":"password123","password_confirmation":"password123"}'
```

2. **Login with email/password:**
```bash
curl -X POST localhost:8002/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

3. **Use the returned token for authenticated requests:**
```bash
curl -X GET localhost:8002/api/auth/user \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### Development Tools
- **Interactive API Documentation**: `/docs` endpoint with live testing
- **Postman Collection**: Download from the documentation page
- **OpenAPI Specification**: Auto-generated for integration
- **Database Seeding**: `php artisan migrate:fresh --seed` for fresh test data

### Multi-Tenant Testing Flow
1. Register/login as an owner
2. Create a shop using `POST /shops`
3. Add team members using `POST /team`
4. Test data isolation by switching between users
5. Verify role-based permissions work correctly

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
