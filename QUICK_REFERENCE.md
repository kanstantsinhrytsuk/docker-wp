# WordPress Docker Environment - Quick Reference

## 🚀 Quick Start
```bash
make dev                 # Complete setup + WordPress installation
# OR
make setup              # Setup environment only
make install-wp         # Install WordPress separately
```

## 🎯 Daily Commands
```bash
make up                 # Start services
make down               # Stop services
make restart            # Restart services
make status             # Check if everything is running
make monitor            # Full health check
```

## 🌐 Access URLs
- **Main Site (v1):** http://local-wp.com
- **Secondary Site (v2):** http://local-wp.com/v2  
- **phpMyAdmin:** <http://localhost:8080>  

## 🔧 Development
```bash
make logs               # View all logs
make logs-php           # PHP logs only
make shell-php          # Access PHP container
make mysql-cli          # MySQL command line
make phpmyadmin         # Open phpMyAdmin in browser
```

## 💾 Database Info
- **Host:** mysql
- **Database:** wordpress
- **Username:** wordpress
- **Password:** wordpress

## 🛠️ Maintenance
```bash
make backup             # Full backup
make clean              # Remove everything
make update             # Update images
make rebuild            # Rebuild from scratch
```

## 📊 Monitoring
```bash
make monitor            # Health check
make resources          # Resource usage
make status             # Service status
```

## 🆘 Troubleshooting
1. **Services won't start:** `make logs`
2. **Can't access sites:** Check hosts file has `127.0.0.1 local-wp.com`
3. **Database issues:** `make mysql-cli` to check database
4. **Need fresh start:** `make clean && make dev`

## 📁 Important Files
- `docker-compose.yaml` - Main configuration
- `configs/nginx.conf` - Web server config
- `configs/php.ini` - PHP settings
- `configs/my.cnf` - MySQL settings
- `website/v1/` - Main WordPress site
- `website/v2/` - Secondary WordPress site

Run `make help` for complete command list.
