# WordPress Docker Environment

This Docker Compose setup provides a complete environment for running two WordPress sites on the same domain with different paths.

## Services Included

- **MySQL 8.0** - Database server
- **PHP 8.1-FPM** - PHP processor with WordPress extensions
- **Nginx** - Web server and reverse proxy
- **phpMyAdmin** - Web-based MySQL administration tool

## Site Structure

- **Main site (v1)**: `http://local-wp.com` → `/website/v1/`
- **Secondary site (v2)**: `http://local-wp.com/v2` → `/website/v2/`

## Prerequisites

1. Docker and Docker Compose installed
   - The Makefile automatically detects and supports both `docker-compose` (v1) and `docker compose` (v2) commands
2. Add `local-wp.com` to your hosts file:

   ```bash
   echo "127.0.0.1 local-wp.com" | sudo tee -a /etc/hosts
   ```

## Getting Started

### Quick Start with Makefile (Recommended)

1. **Set up everything automatically:**

   ```bash
   make setup
   ```

2. **Install WordPress on both sites:**

   ```bash
   make install-wp
   ```

3. **Or set up complete development environment:**

   ```bash
   make dev
   ```

### Manual Setup

1. **Start the environment:**

   ```bash
   docker-compose up -d
   ```

2. **Or run the setup script:**

   ```bash
   ./setup.sh
   ```

### Access Your Sites

- Main WordPress site: <http://local-wp.com>
- Secondary WordPress site: <http://local-wp.com/v2>
- phpMyAdmin: <http://localhost:8080>

## Available Make Commands

Run `make help` to see all available commands:

```bash
make help                # Show all available commands
make setup              # Initial setup with hosts configuration
make up                 # Start all services
make down               # Stop all services
make build              # Build Docker containers
make rebuild            # Rebuild and restart all services
make logs               # Show logs for all services
make status             # Check status of all services
make monitor            # Run comprehensive health check
make resources          # Show resource usage statistics
make clean              # Remove all containers and volumes
make backup             # Create full backup (database + files)
make install-wp         # Install WordPress on both sites
make dev                # Complete development environment setup
make phpmyadmin         # Open phpMyAdmin in browser
```

## Monitoring and Maintenance

The setup includes comprehensive monitoring tools:

### Health Monitoring

```bash
make monitor            # Full health check of all services
make status             # Quick status check
make resources          # Resource usage statistics
```

### Logs and Troubleshooting

```bash
make logs               # All service logs
make logs-nginx         # Nginx-specific logs
make logs-php           # PHP-specific logs
make logs-mysql         # MySQL-specific logs
make logs-phpmyadmin    # phpMyAdmin-specific logs
```

### Backup and Maintenance

```bash
make backup             # Full backup (database + files)
make backup-db          # Database backup only
make backup-files       # Files backup only
make clean              # Clean up all Docker resources
```

## Database Connection Details

- Host: `mysql`
- Database: `wordpress`
- Username: `wordpress`
- Password: `wordpress`
- Root Password: `rootpassword`

### phpMyAdmin Access

- URL: <http://localhost:8080>
- Username: `wordpress` (or `root` for full admin access)
- Password: `wordpress` (or `rootpassword` for root access)
- Quick access: `make phpmyadmin`

## WordPress Configuration

For each WordPress installation, you'll need to configure the database connection in `wp-config.php`:

```php
define('DB_NAME', 'wordpress');
define('DB_USER', 'wordpress');
define('DB_PASSWORD', 'wordpress');
define('DB_HOST', 'mysql');
define('DB_CHARSET', 'utf8mb4');
define('DB_COLLATE', '');
```

## File Structure

```text
├── docker-compose.yaml
├── Dockerfile.php
├── configs/
│   ├── nginx.conf       # Nginx configuration with proxy rules
│   ├── php.ini          # PHP configuration
│   └── my.cnf           # MySQL configuration
└── website/
    ├── v1/              # Main WordPress site
    └── v2/              # Secondary WordPress site
```

## Useful Commands

- **Start services:** `docker-compose up -d`
- **Stop services:** `docker-compose down`
- **View logs:** `docker-compose logs [service_name]`
- **Rebuild PHP container:** `docker-compose build php`
- **Access MySQL CLI:** `docker-compose exec mysql mysql -u wordpress -p`
- **Access phpMyAdmin:** `make phpmyadmin` or visit <http://localhost:8080>

## Port Mappings

- **80** - Nginx (HTTP)
- **443** - Nginx (HTTPS, if configured)
- **3306** - MySQL
- **8080** - phpMyAdmin

## Security Notes

- Change default passwords in production
- Consider using environment variables for sensitive data
- Enable HTTPS for production use
- Review and adjust PHP and MySQL configurations as needed

## Troubleshooting

1. **Permission issues:** Ensure the website directory has proper permissions
2. **Database connection:** Check if MySQL service is running and accessible
3. **PHP errors:** Check PHP logs with `docker-compose logs php`
4. **Nginx errors:** Check Nginx logs with `docker-compose logs nginx`
5. **Docker Compose version:** Run `make debug-compose` to check which Docker Compose command is being used

## Development vs Production

This configuration is optimized for development. For production:

- Use environment variables for passwords
- Enable SSL/HTTPS
- Adjust resource limits
- Set up proper backup strategies
- Review security settings
