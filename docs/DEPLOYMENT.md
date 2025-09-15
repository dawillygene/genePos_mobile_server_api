# GenePos API Deployment Guide

## 🚨 Composer Version Issue Fix

### Problem
The error occurs because you're trying to install Laravel 12 (which doesn't exist) with Composer 1.x, but modern Laravel versions require Composer 2.x.

### Solutions

#### Option 1: Update composer.json (✅ DONE)
We've updated your `composer.json` to use:
- Laravel 11 instead of Laravel 12
- PHP 8.1+ instead of PHP 8.2+
- Compatible package versions

#### Option 2: Upgrade Composer (Recommended for Production)

**On your production server (cPanel/shared hosting):**

```bash
# Download Composer 2.x installer
curl -sS https://getcomposer.org/installer | php

# Move to global location
mv composer.phar /usr/local/bin/composer

# Make executable
chmod +x /usr/local/bin/composer

# Verify installation
composer --version
```

**Alternative (if you don't have admin access):**
```bash
# Download Composer 2.x to project directory
curl -sS https://getcomposer.org/installer | php

# Use local composer
php composer.phar --version
php composer.phar install
```

## 🚀 Production Deployment Steps

### 1. Upload Files
Upload your project files to your server (excluding vendor/ and node_modules/)

### 2. Install Dependencies
```bash
# If you have Composer 2.x globally
composer install --optimize-autoloader --no-dev

# If using local composer.phar
php composer.phar install --optimize-autoloader --no-dev
```

### 3. Environment Setup
```bash
# Copy environment file
cp .env.example .env

# Generate application key
php artisan key:generate

# Set production environment
# Edit .env file:
APP_ENV=production
APP_DEBUG=false
```

### 4. Database Setup
```bash
# Run migrations
php artisan migrate --force

# Seed database (optional)
php artisan db:seed --force
```

### 5. Cache Optimization
```bash
# Cache configuration
php artisan config:cache

# Cache routes
php artisan route:cache

# Cache views
php artisan view:cache
```

### 6. Set Permissions
```bash
# Storage permissions
chmod -R 755 storage/
chmod -R 755 bootstrap/cache/

# Or if needed
chmod -R 777 storage/
chmod -R 777 bootstrap/cache/
```

## 🔧 Troubleshooting

### Composer 1.x Compatibility Issues

If you must use Composer 1.x, ensure these package versions:

```json
{
  "require": {
    "php": "^8.1",
    "laravel/framework": "^11.0",
    "laravel/sanctum": "^4.0"
  },
  "require-dev": {
    "phpunit/phpunit": "^10.0"
  }
}
```

### Common Production Errors

1. **Class not found errors:**
   ```bash
   composer dump-autoload --optimize
   ```

2. **Permission errors:**
   ```bash
   chmod -R 755 storage bootstrap/cache
   ```

3. **Database connection errors:**
   - Check .env database credentials
   - Ensure database exists
   - Test connection: `php artisan tinker` then `DB::connection()->getPdo();`

4. **Key not set errors:**
   ```bash
   php artisan key:generate
   ```

## 📝 Environment Variables (.env)

```env
APP_NAME="GenePos API"
APP_ENV=production
APP_KEY=base64:your_generated_key
APP_DEBUG=false
APP_URL=https://yourdomain.com

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=your_database_name
DB_USERNAME=your_database_user
DB_PASSWORD=your_database_password

# Google OAuth
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret

# Session/Cache
CACHE_DRIVER=file
SESSION_DRIVER=file
QUEUE_CONNECTION=sync

# Mail
MAIL_MAILER=smtp
MAIL_HOST=your_smtp_host
MAIL_PORT=587
MAIL_USERNAME=your_email
MAIL_PASSWORD=your_password
MAIL_ENCRYPTION=tls
```

## 🌐 Production URLs

After deployment, your API will be available at:
- Base URL: `https://yourdomain.com/api`
- Health check: `https://yourdomain.com/api/health` (if implemented)

## 📊 Monitoring

Set up monitoring for:
- Application logs: `storage/logs/laravel.log`
- Error tracking (Sentry, Bugsnag)
- Performance monitoring
- Database backups

## 🔄 Update Process

1. Pull latest code
2. Run `composer install --no-dev`
3. Run `php artisan migrate --force`
4. Clear caches: `php artisan cache:clear`
5. Rebuild caches: `php artisan config:cache`

## 🆘 Emergency Rollback

If deployment fails:
1. Restore previous code version
2. Restore database backup
3. Clear all caches
4. Check error logs
