#!/bin/bash

# GenePos API Server Management Script

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PORT=8001
APP_NAME="GenePos API"

# Functions
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}   $APP_NAME Server Manager${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Check if Laravel is installed
check_laravel() {
    if [ ! -f "artisan" ]; then
        print_error "Laravel not found! Make sure you're in the project root directory."
        exit 1
    fi
}

# Start the server
start_server() {
    print_info "Starting $APP_NAME server on port $PORT..."
    
    # Check if port is already in use
    if lsof -i :$PORT > /dev/null 2>&1; then
        print_warning "Port $PORT is already in use!"
        echo "Would you like to kill the existing process? (y/n)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            kill_server
        else
            print_error "Server start cancelled."
            exit 1
        fi
    fi
    
    # Clear caches
    print_info "Clearing application caches..."
    php artisan config:clear
    php artisan cache:clear
    php artisan view:clear
    
    # Start server
    print_success "Starting server at http://127.0.0.1:$PORT"
    php artisan serve --port=$PORT
}

# Stop the server
kill_server() {
    print_info "Stopping server on port $PORT..."
    
    # Find and kill process on port
    PID=$(lsof -t -i :$PORT)
    if [ ! -z "$PID" ]; then
        kill -9 $PID
        print_success "Server stopped (PID: $PID)"
    else
        print_warning "No server running on port $PORT"
    fi
}

# Setup development environment
setup_dev() {
    print_info "Setting up development environment..."
    
    # Copy environment file
    if [ ! -f ".env" ]; then
        if [ -f ".env.development" ]; then
            cp .env.development .env
            print_success "Copied .env.development to .env"
        else
            cp .env.example .env
            print_success "Copied .env.example to .env"
        fi
        
        # Generate application key
        php artisan key:generate
        print_success "Generated application key"
    else
        print_warning ".env file already exists"
    fi
    
    # Install dependencies
    print_info "Installing Composer dependencies..."
    composer install
    
    # Setup database
    print_info "Setting up database..."
    php artisan migrate:fresh --seed
    print_success "Database setup complete"
    
    print_success "Development environment ready!"
}

# Reset database
reset_db() {
    print_warning "This will delete all data in the database!"
    echo "Are you sure you want to continue? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        print_info "Resetting database..."
        php artisan migrate:fresh --seed
        print_success "Database reset complete"
    else
        print_info "Database reset cancelled"
    fi
}

# Run tests
run_tests() {
    print_info "Running tests..."
    php artisan test
}

# Show server status
server_status() {
    if lsof -i :$PORT > /dev/null 2>&1; then
        PID=$(lsof -t -i :$PORT)
        print_success "Server is running on port $PORT (PID: $PID)"
        print_info "URL: http://127.0.0.1:$PORT"
    else
        print_warning "Server is not running on port $PORT"
    fi
}

# Show help
show_help() {
    echo "Usage: ./server.sh [command]"
    echo ""
    echo "Commands:"
    echo "  start     Start the development server"
    echo "  stop      Stop the development server"
    echo "  restart   Restart the development server"
    echo "  status    Show server status"
    echo "  setup     Setup development environment"
    echo "  reset     Reset database with fresh data"
    echo "  test      Run tests"
    echo "  logs      Show application logs"
    echo "  help      Show this help message"
    echo ""
}

# Show logs
show_logs() {
    print_info "Showing application logs (Press Ctrl+C to exit)..."
    tail -f storage/logs/laravel.log
}

# Main script logic
print_header
check_laravel

case "${1:-start}" in
    "start")
        start_server
        ;;
    "stop")
        kill_server
        ;;
    "restart")
        kill_server
        sleep 2
        start_server
        ;;
    "status")
        server_status
        ;;
    "setup")
        setup_dev
        ;;
    "reset")
        reset_db
        ;;
    "test")
        run_tests
        ;;
    "logs")
        show_logs
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
