# WordPress Docker Environment Makefile
# Author: Generated for WordPress Docker Setup
# Usage: make [target]

.PHONY: help setup up down build rebuild logs clean status monitor resources install-wp backup restore phpmyadmin

# Default target
.DEFAULT_GOAL := help

# Colors for output
RED=\033[0;31m
GREEN=\033[0;32m
YELLOW=\033[1;33m
BLUE=\033[0;34m
NC=\033[0m # No Color

# Project configuration
PROJECT_NAME=wordpress-docker
COMPOSE_FILE=docker-compose.yaml
BACKUP_DIR=backups

# Docker Compose command detection (support both docker-compose and docker compose)
DOCKER_COMPOSE := $(shell command -v docker-compose 2> /dev/null)
ifdef DOCKER_COMPOSE
    COMPOSE_CMD = docker-compose
else
    COMPOSE_CMD = docker compose
endif

help: ## Show this help message
	@echo "$(GREEN)WordPress Docker Environment$(NC)"
	@echo "$(BLUE)Available commands:$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(YELLOW)%-15s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

setup: ## Initial setup with hosts file configuration
	@echo "$(GREEN)🚀 Setting up WordPress Docker Environment...$(NC)"
	@if ! docker info > /dev/null 2>&1; then \
		echo "$(RED)❌ Docker is not running. Please start Docker and try again.$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)📝 Checking hosts file configuration...$(NC)"
	@if ! grep -q "local-wp.com" /etc/hosts; then \
		echo "$(YELLOW)Adding local-wp.com to hosts file...$(NC)"; \
		echo "127.0.0.1 local-wp.com" | sudo tee -a /etc/hosts; \
		echo "$(GREEN)✅ Added local-wp.com to hosts file$(NC)"; \
	else \
		echo "$(GREEN)✅ local-wp.com already exists in hosts file$(NC)"; \
	fi
	@echo "$(BLUE)📁 Creating website directories...$(NC)"
	@mkdir -p website/v1 website/v2
	@echo "$(GREEN)✅ Website directories created$(NC)"
	@$(MAKE) build
	@$(MAKE) up
	@echo "$(GREEN)🎉 Setup complete!$(NC)"
	@$(MAKE) info

build: ## Build Docker containers
	@echo "$(BLUE)🔨 Building Docker containers...$(NC)"
	@$(COMPOSE_CMD) build --no-cache

up: ## Start all services
	@echo "$(BLUE)🚀 Starting services...$(NC)"
	@$(COMPOSE_CMD) up -d
	@echo "$(YELLOW)⏳ Waiting for services to be ready...$(NC)"
	@sleep 30
	@$(MAKE) status

down: ## Stop all services
	@echo "$(YELLOW)🛑 Stopping services...$(NC)"
	@$(COMPOSE_CMD) down
	@echo "$(GREEN)✅ Services stopped$(NC)"

rebuild: ## Rebuild and restart all services
	@echo "$(BLUE)🔄 Rebuilding and restarting services...$(NC)"
	@$(MAKE) down
	@$(MAKE) build
	@$(MAKE) up

restart: ## Restart all services without rebuilding
	@echo "$(BLUE)🔄 Restarting services...$(NC)"
	@$(COMPOSE_CMD) restart
	@sleep 15
	@$(MAKE) status

logs: ## Show logs for all services
	@echo "$(BLUE)📋 Showing logs...$(NC)"
	@$(COMPOSE_CMD) logs -f

logs-nginx: ## Show Nginx logs
	@echo "$(BLUE)📋 Showing Nginx logs...$(NC)"
	@$(COMPOSE_CMD) logs -f nginx

logs-php: ## Show PHP logs
	@echo "$(BLUE)📋 Showing PHP logs...$(NC)"
	@$(COMPOSE_CMD) logs -f php

logs-mysql: ## Show MySQL logs
	@echo "$(BLUE)📋 Showing MySQL logs...$(NC)"
	@$(COMPOSE_CMD) logs -f mysql

logs-phpmyadmin: ## Show phpMyAdmin logs
	@echo "$(BLUE)📋 Showing phpMyAdmin logs...$(NC)"
	@$(COMPOSE_CMD) logs -f phpmyadmin

status: ## Check status of all services
	@echo "$(BLUE)📊 Service Status:$(NC)"
	@$(COMPOSE_CMD) ps
	@echo ""
	@if $(COMPOSE_CMD) ps | grep -q "Up"; then \
		echo "$(GREEN)✅ Services are running!$(NC)"; \
		$(MAKE) info; \
	else \
		echo "$(RED)❌ Some services are not running$(NC)"; \
		echo "$(YELLOW)Run 'make logs' to check for errors$(NC)"; \
	fi

monitor: ## Run comprehensive health check
	@./monitor.sh monitor

resources: ## Show resource usage statistics
	@./monitor.sh resources

info: ## Show connection information
	@echo "$(GREEN)🌐 Access Information:$(NC)"
	@echo "  $(BLUE)Main WordPress site:$(NC)     http://local-wp.com"
	@echo "  $(BLUE)Secondary WordPress site:$(NC) http://local-wp.com/v2"
	@echo "  $(BLUE)phpMyAdmin:$(NC)               http://localhost:8080"
	@echo ""
	@echo "$(GREEN)📋 Database Credentials:$(NC)"
	@echo "  $(BLUE)Host:$(NC)     mysql"
	@echo "  $(BLUE)Database:$(NC) wordpress"
	@echo "  $(BLUE)Username:$(NC) wordpress"
	@echo "  $(BLUE)Password:$(NC) wordpress"

clean: ## Remove all containers, volumes, and images
	@echo "$(YELLOW)🧹 Cleaning up Docker resources...$(NC)"
	@read -p "This will remove all containers, volumes, and images. Are you sure? (y/N): " confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		$(COMPOSE_CMD) down -v --remove-orphans; \
		docker system prune -f; \
		docker volume prune -f; \
		echo "$(GREEN)✅ Cleanup complete$(NC)"; \
	else \
		echo "$(YELLOW)Cleanup cancelled$(NC)"; \
	fi

shell-nginx: ## Access Nginx container shell
	@echo "$(BLUE)🐚 Accessing Nginx container...$(NC)"
	@$(COMPOSE_CMD) exec nginx sh

shell-php: ## Access PHP container shell
	@echo "$(BLUE)🐚 Accessing PHP container...$(NC)"
	@$(COMPOSE_CMD) exec php bash

shell-mysql: ## Access MySQL container shell
	@echo "$(BLUE)🐚 Accessing MySQL container...$(NC)"
	@$(COMPOSE_CMD) exec mysql bash

shell-phpmyadmin: ## Access phpMyAdmin container shell
	@echo "$(BLUE)🐚 Accessing phpMyAdmin container...$(NC)"
	@$(COMPOSE_CMD) exec phpmyadmin sh

mysql-cli: ## Access MySQL command line
	@echo "$(BLUE)💾 Connecting to MySQL...$(NC)"
	@$(COMPOSE_CMD) exec mysql mysql -u wordpress -p

phpmyadmin: ## Open phpMyAdmin in browser
	@echo "$(BLUE)🌐 Opening phpMyAdmin...$(NC)"
	@echo "$(GREEN)📋 phpMyAdmin Access:$(NC)"
	@echo "  $(BLUE)URL:$(NC)      http://localhost:8080"
	@echo "  $(BLUE)Username:$(NC) wordpress (or root for full access)"
	@echo "  $(BLUE)Password:$(NC) wordpress (or rootpassword for root)"
	@if command -v open >/dev/null 2>&1; then \
		open http://localhost:8080; \
	elif command -v xdg-open >/dev/null 2>&1; then \
		xdg-open http://localhost:8080; \
	else \
		echo "$(YELLOW)Please open http://localhost:8080 in your browser$(NC)"; \
	fi

backup-db: ## Backup MySQL database
	@echo "$(BLUE)💾 Creating database backup...$(NC)"
	@mkdir -p $(BACKUP_DIR)
	@$(COMPOSE_CMD) exec mysql mysqldump -u wordpress -pwordpress wordpress > $(BACKUP_DIR)/wordpress_$(shell date +%Y%m%d_%H%M%S).sql
	@echo "$(GREEN)✅ Database backup created in $(BACKUP_DIR)/$(NC)"

backup-files: ## Backup website files
	@echo "$(BLUE)📁 Creating files backup...$(NC)"
	@mkdir -p $(BACKUP_DIR)
	@tar -czf $(BACKUP_DIR)/website_files_$(shell date +%Y%m%d_%H%M%S).tar.gz website/
	@echo "$(GREEN)✅ Files backup created in $(BACKUP_DIR)/$(NC)"

backup: ## Create full backup (database + files)
	@echo "$(BLUE)💾 Creating full backup...$(NC)"
	@$(MAKE) backup-db
	@$(MAKE) backup-files
	@echo "$(GREEN)🎉 Full backup completed!$(NC)"

install-wp-v1: ## Download and install WordPress for v1 site
	@echo "$(BLUE)📥 Installing WordPress for v1 site...$(NC)"
	@if [ ! -f "website/v1/wp-config.php" ]; then \
		cd website/v1 && \
		curl -O https://wordpress.org/latest.tar.gz && \
		tar -xzf latest.tar.gz --strip-components=1 && \
		rm latest.tar.gz && \
		echo "$(GREEN)✅ WordPress v1 installed$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  WordPress v1 already exists$(NC)"; \
	fi

install-wp-v2: ## Download and install WordPress for v2 site
	@echo "$(BLUE)📥 Installing WordPress for v2 site...$(NC)"
	@if [ ! -f "website/v2/wp-config.php" ]; then \
		cd website/v2 && \
		curl -O https://wordpress.org/latest.tar.gz && \
		tar -xzf latest.tar.gz --strip-components=1 && \
		rm latest.tar.gz && \
		echo "$(GREEN)✅ WordPress v2 installed$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  WordPress v2 already exists$(NC)"; \
	fi

install-wp: ## Install WordPress on both sites
	@$(MAKE) install-wp-v1
	@$(MAKE) install-wp-v2
	@echo "$(GREEN)🎉 WordPress installed on both sites!$(NC)"
	@echo "$(YELLOW)📝 Don't forget to configure wp-config.php files$(NC)"

dev: ## Start development environment (setup + install WordPress)
	@echo "$(GREEN)🔧 Setting up development environment...$(NC)"
	@$(MAKE) setup
	@$(MAKE) install-wp
	@echo "$(GREEN)🎉 Development environment ready!$(NC)"

prod-check: ## Check if environment is ready for production
	@echo "$(BLUE)🔍 Checking production readiness...$(NC)"
	@echo "$(YELLOW)⚠️  This is a development configuration$(NC)"
	@echo "$(YELLOW)For production, consider:$(NC)"
	@echo "  - Change default passwords"
	@echo "  - Enable HTTPS/SSL"
	@echo "  - Use environment variables"
	@echo "  - Set up proper backups"
	@echo "  - Review security settings"

update: ## Update all Docker images
	@echo "$(BLUE)🆙 Updating Docker images...$(NC)"
	@$(COMPOSE_CMD) pull
	@$(MAKE) rebuild
	@echo "$(GREEN)✅ Images updated and services restarted$(NC)"

debug-compose: ## Show which Docker Compose command is being used
	@echo "$(BLUE)🔍 Docker Compose Command Detection:$(NC)"
	@echo "  $(YELLOW)Using:$(NC) $(COMPOSE_CMD)"
	@$(COMPOSE_CMD) version || echo "$(RED)❌ Command not available$(NC)"

# Development shortcuts
start: up ## Alias for 'up'
stop: down ## Alias for 'down'
