<p align="center"><a href="https://laravel.com" target="_blank"><img src="https://raw.githubusercontent.com/laravel/art/master/logo-lockup/5%20SVG/2%20CMYK/1%20Full%20Color/laravel-logolockup-cmyk-red.svg" width="400" alt="Laravel Logo"></a></p>

<p align="center">
<a href="https://github.com/laravel/framework/actions"><img src="https://github.com/laravel/framework/workflows/tests/badge.svg" alt="Build Status"></a>
<a href="https://packagist.org/packages/laravel/framework"><img src="https://img.shields.io/packagist/dt/laravel/framework" alt="Total Downloads"></a>
<a href="https://packagist.org/packages/laravel/framework"><img src="https://img.shields.io/packagist/v/laravel/framework" alt="Latest Stable Version"></a>
<a href="https://packagist.org/packages/laravel/framework"><img src="https://img.shields.io/packagist/l/laravel/framework" alt="License"></a>
</p>

## About Laravel

Laravel is a web application framework with expressive, elegant syntax. We believe development must be an enjoyable and creative experience to be truly fulfilling. Laravel takes the pain out of development by easing common tasks used in many web projects, such as:

- [Simple, fast routing engine](https://laravel.com/docs/routing).
- [Powerful dependency injection container](https://laravel.com/docs/container).
- Multiple back-ends for [session](https://laravel.com/docs/session) and [cache](https://laravel.com/docs/cache) storage.
- Expressive, intuitive [database ORM](https://laravel.com/docs/eloquent).
- Database agnostic [schema migrations](https://laravel.com/docs/migrations).
- [Robust background job processing](https://laravel.com/docs/queues).
- [Real-time event broadcasting](https://laravel.com/docs/broadcasting).

Laravel is accessible, powerful, and provides tools required for large, robust applications.

## Learning Laravel

Laravel has the most extensive and thorough [documentation](https://laravel.com/docs) and video tutorial library of all modern web application frameworks, making it a breeze to get started with the framework.

You may also try the [Laravel Bootcamp](https://bootcamp.laravel.com), where you will be guided through building a modern Laravel application from scratch.

If you don't feel like reading, [Laracasts](https://laracasts.com) can help. Laracasts contains thousands of video tutorials on a range of topics including Laravel, modern PHP, unit testing, and JavaScript. Boost your skills by digging into our comprehensive video library.

## Laravel Sponsors

We would like to extend our thanks to the following sponsors for funding Laravel development. If you are interested in becoming a sponsor, please visit the [Laravel Partners program](https://partners.laravel.com).

### Premium Partners

- **[Vehikl](https://vehikl.com)**
- **[Tighten Co.](https://tighten.co)**
- **[Kirschbaum Development Group](https://kirschbaumdevelopment.com)**
- **[64 Robots](https://64robots.com)**
- **[Curotec](https://www.curotec.com/services/technologies/laravel)**
- **[DevSquad](https://devsquad.com/hire-laravel-developers)**
- **[Redberry](https://redberry.international/laravel-development)**
- **[Active Logic](https://activelogic.com)**

## Contributing

Thank you for considering contributing to the Laravel framework! The contribution guide can be found in the [Laravel documentation](https://laravel.com/docs/contributions).

## Code of Conduct

In order to ensure that the Laravel community is welcoming to all, please review and abide by the [Code of Conduct](https://laravel.com/docs/contributions#code-of-conduct).

## Security Vulnerabilities

If you discover a security vulnerability within Laravel, please send an e-mail to Taylor Otwell via [taylor@laravel.com](mailto:taylor@laravel.com). All security vulnerabilities will be promptly addressed.

## License

The Laravel framework is open-sourced software licensed under the [MIT license](https://opensource.org/licenses/MIT).
# GenePos Mobile Server API

Laravel API backend for GenePos Point of Sale system. This RESTful API provides comprehensive POS functionality including product management, sales tracking, and user authentication.

## 🚀 Features

- **Product Management**: CRUD operations for inventory management
- **Sales Management**: Complete transaction handling with sale items
- **User Authentication**: Google OAuth integration with Laravel Sanctum
- **Dashboard Analytics**: Sales reports and business insights
- **RESTful API**: JSON responses with proper HTTP status codes
- **Database**: MySQL with comprehensive migrations and seeders

## 🛠 Tech Stack

- **Framework**: Laravel 11.x
- **Database**: MySQL
- **Authentication**: Laravel Sanctum + Google OAuth
- **API**: RESTful with JSON responses
- **Testing**: PHPUnit

## 📋 API Endpoints

### Authentication
- `POST /api/auth/google` - Google OAuth login
- `POST /api/auth/logout` - User logout
- `GET /api/auth/user` - Get authenticated user

### Products (Protected)
- `GET /api/products` - List all products
- `POST /api/products` - Create new product
- `GET /api/products/{id}` - Get specific product
- `PUT /api/products/{id}` - Update product
- `DELETE /api/products/{id}` - Delete product

### Sales (Protected)
- `GET /api/sales` - List all sales
- `POST /api/sales` - Create new sale
- `GET /api/sales/{id}` - Get specific sale
- `PUT /api/sales/{id}` - Update sale
- `DELETE /api/sales/{id}` - Delete sale

### Dashboard (Protected)
- `GET /api/dashboard` - Get dashboard data
- `GET /api/reports/sales` - Get sales reports

## 🚀 Getting Started

### Prerequisites
- PHP 8.1+
- Composer
- MySQL
- Node.js & NPM

### Installation

1. Clone the repository
```bash
git clone https://github.com/dawillygene/genePos_mobile_server_api.git
cd genePos_mobile_server_api
```

2. Install dependencies
```bash
composer install
npm install
```

3. Environment setup
```bash
cp .env.example .env
php artisan key:generate
```

4. Database setup
```bash
# Create MySQL database 'genepos'
php artisan migrate
php artisan db:seed
```

5. Start the server
```bash
php artisan serve --port=8001
```

## 🔧 Configuration

### Database Configuration
Update your `.env` file:
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=genepos
DB_USERNAME=venlit
DB_PASSWORD=your_password
```

### Google OAuth Setup
Add to your `.env`:
```env
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
GOOGLE_REDIRECT_URI=your_redirect_uri
```

## 📱 Mobile App Integration

This API is designed to work with the GenePos Flutter mobile application. All endpoints return JSON responses suitable for mobile consumption.

### Authentication Flow
1. Mobile app initiates Google OAuth
2. API validates and returns Sanctum token
3. Mobile app uses token for subsequent API calls

## 🧪 Testing

Run the test suite:
```bash
php artisan test
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 👨‍💻 Author

**Dawilly Gene**
- GitHub: [@dawillygene](https://github.com/dawillygene)

---

**GenePos** - Modern Point of Sale Solution
