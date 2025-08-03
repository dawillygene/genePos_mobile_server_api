# 🚨 403 Forbidden Error - Troubleshooting Guide

## Issue: https://genepos.dawillygene.com/ returns 403 Forbidden

This is a common Laravel deployment issue. Here are the solutions in order of likelihood:

## 🔧 **Solution 1: Document Root Configuration (Most Common)**

### Problem: Web server pointing to wrong directory
Your domain should point to the `public/` directory, not the root Laravel directory.

### Fix:
**In your hosting control panel (cPanel/Plesk):**
1. Go to **Domains** or **Subdomains**
2. Find `genepos.dawillygene.com`
3. Change **Document Root** from:
   ```
   /public_html/genepos/
   ```
   To:
   ```
   /public_html/genepos/public/
   ```

**Alternative: Move files to correct structure**
```bash
# If you can't change document root, restructure like this:
# Move all Laravel files one level up and keep only public/ contents in web root
```

## 🔧 **Solution 2: .htaccess File Missing**

### Check if .htaccess exists in public/ directory:

**Create/Update public/.htaccess:**
```apache
<IfModule mod_rewrite.c>
    <IfModule mod_negotiation.c>
        Options -MultiViews -Indexes
    </IfModule>

    RewriteEngine On

    # Handle Authorization Header
    RewriteCond %{HTTP:Authorization} .
    RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]

    # Redirect Trailing Slashes If Not A Folder...
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_URI} (.+)/$
    RewriteRule ^ %1 [L,R=301]

    # Send Requests To Front Controller...
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteRule ^ index.php [L]
</IfModule>
```

## 🔧 **Solution 3: File Permissions**

### Set correct permissions:
```bash
# Set directory permissions
find /path/to/your/laravel/project -type d -exec chmod 755 {} \;

# Set file permissions  
find /path/to/your/laravel/project -type f -exec chmod 644 {} \;

# Set storage and cache permissions
chmod -R 777 storage/
chmod -R 777 bootstrap/cache/

# Make artisan executable
chmod +x artisan
```

## 🔧 **Solution 4: Index File Configuration**

### Create/Update public/index.php (if missing):
```php
<?php

use Illuminate\Contracts\Http\Kernel;
use Illuminate\Http\Request;

define('LARAVEL_START', microtime(true));

/*
|--------------------------------------------------------------------------
| Check If The Application Is Under Maintenance
|--------------------------------------------------------------------------
*/

if (file_exists($maintenance = __DIR__.'/../storage/framework/maintenance.php')) {
    require $maintenance;
}

/*
|--------------------------------------------------------------------------
| Register The Auto Loader
|--------------------------------------------------------------------------
*/

require __DIR__.'/../vendor/autoload.php';

/*
|--------------------------------------------------------------------------
| Run The Application
|--------------------------------------------------------------------------
*/

$app = require_once __DIR__.'/../bootstrap/app.php';

$kernel = $app->make(Kernel::class);

$response = $kernel->handle(
    $request = Request::capture()
)->send();

$kernel->terminate($request, $response);
```

## 🔧 **Solution 5: Apache/Server Configuration**

### For Apache servers, ensure mod_rewrite is enabled

**Check server requirements:**
```bash
# Check PHP version
php -v

# Check required extensions
php -m | grep -i "pdo\|mbstring\|tokenizer\|xml\|ctype\|json\|bcmath"
```

## 🔧 **Solution 6: Environment Configuration**

### Update .env for production:
```env
APP_NAME="GenePos API"
APP_ENV=production
APP_KEY=base64:your_generated_key_here
APP_DEBUG=false
APP_URL=https://genepos.dawillygene.com

# Database configuration
DB_CONNECTION=mysql
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=your_production_database
DB_USERNAME=your_db_user
DB_PASSWORD=your_db_password

# Google OAuth (production credentials)
GOOGLE_CLIENT_ID=your_production_google_client_id
GOOGLE_CLIENT_SECRET=your_production_google_client_secret

# CORS Configuration
SANCTUM_STATEFUL_DOMAINS=genepos.dawillygene.com
CORS_ALLOWED_ORIGINS=https://genepos.dawillygene.com

# Cache drivers for production
CACHE_DRIVER=file
SESSION_DRIVER=file
QUEUE_CONNECTION=sync

# Mail configuration
MAIL_MAILER=smtp
MAIL_HOST=your_smtp_host
MAIL_PORT=587
MAIL_USERNAME=your_email
MAIL_PASSWORD=your_email_password
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=noreply@dawillygene.com
MAIL_FROM_NAME="${APP_NAME}"
```

## 🔧 **Solution 7: Clear All Caches**

```bash
# Clear application cache
php artisan cache:clear

# Clear configuration cache
php artisan config:clear

# Clear route cache
php artisan route:clear

# Clear view cache
php artisan view:clear

# Clear compiled services
php artisan clear-compiled

# Regenerate autoload files
composer dump-autoload --optimize
```

## 🔧 **Solution 8: Debug Mode (Temporary)**

### Enable debug temporarily to see detailed error:
```env
APP_DEBUG=true
APP_ENV=local
```

**Then check the actual error message and disable it again:**
```env
APP_DEBUG=false
APP_ENV=production
```

## 🛠️ **Quick Deployment Checklist**

1. ✅ **Document root** points to `public/` directory
2. ✅ **File permissions** are correct (755 for directories, 644 for files)
3. ✅ **Storage permissions** are writable (777)
4. ✅ **.htaccess** file exists in public/ directory
5. ✅ **index.php** exists in public/ directory
6. ✅ **vendor/** directory exists (run `composer install`)
7. ✅ **.env** file configured for production
8. ✅ **APP_KEY** is generated (`php artisan key:generate`)
9. ✅ **Database** connection works
10. ✅ **Migrations** are run (`php artisan migrate --force`)

## 🔍 **Debugging Commands**

```bash
# Check if Laravel is properly installed
php artisan --version

# Check routes
php artisan route:list

# Test database connection
php artisan tinker
>>> DB::connection()->getPdo();

# Check file permissions
ls -la storage/
ls -la bootstrap/cache/
ls -la public/
```

## 📞 **Most Likely Solution**

Based on the 403 error, the most common cause is **incorrect document root**. Your hosting provider needs to point your domain to the `public/` folder, not the root Laravel directory.

**Contact your hosting provider** or check your control panel to change the document root to:
```
/public_html/genepos/public/
```

## 🆘 **If Nothing Works**

1. **Check server error logs** in cPanel or hosting control panel
2. **Contact hosting provider** for server configuration help
3. **Verify PHP version** is 8.1 or higher
4. **Ensure all Laravel requirements** are met on the server
