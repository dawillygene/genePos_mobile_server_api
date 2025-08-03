# GenePos API - Complete Setup & Feature Guide

## 🚀 Quick Start

### Prerequisites
- PHP 8.1+
- MySQL/MariaDB
- Composer
- Laravel 11

### Installation
1. Clone the repository
2. Install dependencies: `composer install`
3. Copy `.env.example` to `.env` and configure
4. Generate app key: `php artisan key:generate`
5. Run migrations: `php artisan migrate:fresh --seed`
6. Start server: `php artisan serve --host=0.0.0.0 --port=8002`

## 📚 Complete Feature Set

### ✅ **Authentication System**
- **Google OAuth Login**: Seamless single sign-on integration
- **Email/Password Registration**: Traditional user registration
- **Email/Password Login**: Standard authentication
- **Laravel Sanctum Tokens**: Secure API token management
- **Role-based Access**: Owner and sales person permissions

### ✅ **Multi-Tenant Shop Management**
- **Shop Creation**: Owners can create and manage shops
- **Team Management**: Add/remove sales persons
- **Data Isolation**: Complete separation between shops
- **Role-based Permissions**: Granular access control
- **Shop Statistics**: Revenue, products, sales metrics

### ✅ **Product Management**
- **CRUD Operations**: Create, read, update, delete products
- **Shop Isolation**: Products filtered by shop ownership
- **Inventory Tracking**: Stock quantities and management
- **Categories**: Product categorization system
- **Barcode/SKU Support**: Product identification

### ✅ **Sales Management**
- **Transaction Processing**: Complete sales workflow
- **Multi-item Sales**: Support for multiple products per sale
- **Payment Methods**: Cash, card, mobile, mixed payments
- **Sales History**: Complete transaction records
- **Shop-based Filtering**: Sales isolated by shop

### ✅ **API Documentation & Testing**
- **Interactive Documentation**: Scribe-powered docs at `/docs`
- **Live API Testing**: Test endpoints directly from docs
- **Postman Collection**: Download ready-to-use collection
- **OpenAPI Specification**: Industry-standard API spec
- **Request/Response Examples**: Real-world usage examples

## 🔧 Configuration

### Google OAuth Setup
```env
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
GOOGLE_PROJECT_ID=your-google-project-id
GOOGLE_AUTH_URI=https://accounts.google.com/o/oauth2/auth
GOOGLE_TOKEN_URI=https://oauth2.googleapis.com/token
GOOGLE_AUTH_PROVIDER_X509_CERT_URL=https://www.googleapis.com/oauth2/v1/certs
GOOGLE_REDIRECT_URIS=https://yourdomain.com/
GOOGLE_JAVASCRIPT_ORIGINS=https://yourdomain.com
```

> **Note**: The actual Google OAuth credentials are configured in the `.env` file for the production environment.

### Database Configuration
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=genepos
DB_USERNAME=venlit
DB_PASSWORD=venlit
```

### CORS Configuration
```env
SANCTUM_STATEFUL_DOMAINS=genepos.dawillygene.com
CORS_ALLOWED_ORIGINS=https://genepos.dawillygene.com
```

## 🧪 Testing & Development

### Test Data
The system includes comprehensive test data:
- **2 Shops**: Tech Store, Fashion Boutique
- **4 Users**: 2 owners, 2 sales persons
- **8 Products**: 4 per shop with different categories
- **All passwords**: `password`

### Quick Testing Commands
```bash
# Register new user
curl -X POST localhost:8002/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","password":"password123","password_confirmation":"password123"}'

# Login with email/password
curl -X POST localhost:8002/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"john@example.com","password":"password"}'

# Test authenticated endpoint
curl -X GET localhost:8002/api/auth/user \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### Available Test Accounts
**Shop Owners:**
- `john@example.com` (Tech Store Owner)
- `jane@example.com` (Fashion Boutique Owner)

**Sales Persons:**
- `mike@techstore.com` (Tech Store)
- `sarah@fashionboutique.com` (Fashion Boutique)

## 📊 API Endpoints Overview

### Authentication (4 endpoints)
- `POST /auth/register` - Register with email/password
- `POST /auth/login` - Login with email/password  
- `POST /auth/google` - Google OAuth login
- `GET /auth/user` - Get current user info

### Shop Management (6 endpoints)
- `GET /shops` - List user's shops
- `POST /shops` - Create new shop (owners only)
- `GET /shops/{id}` - Get shop details
- `PUT /shops/{id}` - Update shop (owners only)
- `DELETE /shops/{id}` - Delete shop (owners only)
- `GET /shops/{id}/statistics` - Get shop statistics

### Team Management (6 endpoints)
- `GET /team` - List team members
- `POST /team` - Add sales person (owners only)
- `GET /team/{id}` - Get team member details
- `PUT /team/{id}` - Update team member (owners only)
- `DELETE /team/{id}` - Remove team member (owners only)
- `PATCH /team/{id}/toggle-status` - Activate/deactivate member

### Product Management (5 endpoints)
- `GET /products` - List shop's products
- `POST /products` - Create product
- `GET /products/{id}` - Get product details
- `PUT /products/{id}` - Update product
- `DELETE /products/{id}` - Deactivate product

### Sales Management (5 endpoints)
- `GET /sales` - List shop's sales
- `POST /sales` - Create new sale
- `GET /sales/{id}` - Get sale details
- `PUT /sales/{id}` - Update sale status
- `DELETE /sales/{id}` - Delete sale

### Dashboard & Reports (2 endpoints)
- `GET /dashboard` - Dashboard summary
- `GET /reports/sales` - Sales reports

## 🔒 Security Features

- **JWT Token Authentication**: Secure API access
- **Role-based Access Control**: Owner vs sales person permissions
- **Data Isolation**: Complete shop-to-shop separation
- **Input Validation**: Comprehensive request validation
- **CORS Protection**: Configured for production domains
- **Rate Limiting**: API abuse prevention

## 🌐 Production Deployment

### URLs
- **Production API**: https://genepos.dawillygene.com/api
- **API Documentation**: https://genepos.dawillygene.com/docs
- **Local Development**: http://localhost:8002

### Key Commands
```bash
# Fresh installation with test data
php artisan migrate:fresh --seed

# Generate API documentation
php artisan scribe:generate

# Start development server
php artisan serve --host=0.0.0.0 --port=8002
```

## 📝 Development Notes

### Recent Major Updates
1. **Multi-tenant Architecture**: Complete shop isolation system
2. **Dual Authentication**: Google OAuth + email/password
3. **Interactive Documentation**: Scribe integration
4. **Role-based Permissions**: Owner/sales person access levels
5. **Data Integrity**: Foreign key constraints and validation
6. **Testing Tools**: Comprehensive test data and examples

### Database Schema
- `users` - User accounts with roles and shop assignments
- `shops` - Shop information and settings
- `products` - Products with shop isolation
- `sales` - Sales transactions with shop filtering
- `sale_items` - Individual sale line items

The API is production-ready with comprehensive documentation, testing tools, and security features!
