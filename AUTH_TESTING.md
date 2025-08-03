# Authentication Testing Guide

## Overview
Test the new email/password authentication system alongside the existing Google OAuth.

## Available Authentication Methods

### 1. Email/Password Registration
```bash
curl -X POST http://localhost:8002/api/auth/register \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "password": "password123",
    "password_confirmation": "password123",
    "role": "owner"
  }'
```

### 2. Email/Password Login
```bash
curl -X POST http://localhost:8002/api/auth/login \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

### 3. Test with Seeded Users
You can login with any of the seeded users:

**Owners:**
- Email: `john@example.com`, Password: `password`
- Email: `jane@example.com`, Password: `password`

**Sales Persons:**
- Email: `mike@techstore.com`, Password: `password`
- Email: `sarah@fashionboutique.com`, Password: `password`

### 4. Using the Token
Once you get a token from login/register, use it for authenticated requests:

```bash
curl -X GET http://localhost:8002/api/auth/user \
  -H "Accept: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### 5. Test Shop Creation (Owner Role Required)
```bash
curl -X POST http://localhost:8002/api/shops \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "name": "My New Shop",
    "description": "A test shop",
    "address": "123 Test Street",
    "phone": "+1-555-0123",
    "email": "contact@mynewshop.com"
  }'
```

## API Documentation
Visit the auto-generated API documentation at:
- **Local**: http://localhost:8002/docs
- **Production**: https://genepos.dawillygene.com/docs

The documentation includes:
- Complete endpoint reference
- Request/response examples
- Authentication details
- Interactive testing interface
- Postman collection download
- OpenAPI specification

## Testing Flow
1. Register a new user or login with existing credentials
2. Use the returned token for authenticated requests
3. Test shop creation (owners only)
4. Add team members to shops
5. Test product and sales management with shop isolation

The system now supports both Google OAuth and traditional email/password authentication!
