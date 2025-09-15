# GenePos API Development Guide

## Quick Start Commands

```bash
# Start development server
php artisan serve --port=8001

# Run migrations
php artisan migrate

# Seed database with sample data
php artisan db:seed

# Clear caches
php artisan cache:clear
php artisan config:clear
php artisan view:clear

# Generate new application key
php artisan key:generate

# Create new migration
php artisan make:migration create_table_name

# Create new model
php artisan make:model ModelName -m

# Create new controller
php artisan make:controller Api/ControllerName --api

# Run tests
php artisan test

# Generate API documentation
php artisan route:list --path=api

# Monitor logs
tail -f storage/logs/laravel.log
```

## Database Commands

```bash
# Fresh migration (drops all tables)
php artisan migrate:fresh

# Migration with seeding
php artisan migrate:fresh --seed

# Rollback migration
php artisan migrate:rollback

# Reset database
php artisan migrate:reset

# Check migration status
php artisan migrate:status

# Create seeder
php artisan make:seeder SeederName
```

## API Testing

### Using cURL
```bash
# Test products endpoint (requires auth)
curl -X GET http://127.0.0.1:8001/api/products \
  -H "Accept: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Create product
curl -X POST http://127.0.0.1:8001/api/products \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"name": "Test Product", "price": 9.99, "sku": "TEST-001"}'
```

### Using Postman
1. Import the API collection
2. Set environment variables:
   - `base_url`: http://127.0.0.1:8001/api
   - `token`: Your Sanctum token

## Development Workflow

1. **Setup Environment**
   ```bash
   cp .env.development .env
   php artisan key:generate
   ```

2. **Database Setup**
   ```bash
   # Create MySQL database 'genepos'
   php artisan migrate:fresh --seed
   ```

3. **Start Development**
   ```bash
   php artisan serve --port=8001
   ```

4. **Test API**
   - Use API_DOCUMENTATION.md for endpoint reference
   - Test authentication flow first
   - Verify CRUD operations

## Troubleshooting

### Common Issues

1. **"Class not found" errors**
   ```bash
   composer dump-autoload
   ```

2. **Migration errors**
   ```bash
   php artisan migrate:fresh
   ```

3. **Permission errors**
   ```bash
   sudo chown -R $USER:www-data storage
   sudo chmod -R 755 storage
   ```

4. **Cache issues**
   ```bash
   php artisan config:clear
   php artisan cache:clear
   php artisan view:clear
   ```

### Debug Mode
Enable debug mode in `.env`:
```env
APP_DEBUG=true
LOG_LEVEL=debug
```

### Database Issues
Check database connection:
```bash
php artisan tinker
>>> DB::connection()->getPdo();
```

## Code Standards

- Follow PSR-12 coding standards
- Use meaningful variable and method names
- Write tests for new features
- Document API changes
- Use Laravel best practices

## Git Workflow

```bash
# Create feature branch
git checkout -b feature/new-feature

# Commit changes
git add .
git commit -m "feat: add new feature"

# Push to GitHub
git push origin feature/new-feature

# Create pull request on GitHub
```

## Deployment Checklist

- [ ] Set `APP_ENV=production`
- [ ] Set `APP_DEBUG=false`
- [ ] Configure production database
- [ ] Set up HTTPS
- [ ] Configure CORS for production domains
- [ ] Set up monitoring and logging
- [ ] Configure backup strategy
- [ ] Set up CI/CD pipeline
