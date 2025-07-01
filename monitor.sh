#!/bin/bash

# WordPress Docker Environment Monitor
# This script monitors the health of your WordPress Docker services

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Docker Compose command detection (support both docker-compose and docker compose)
if command -v docker-compose >/dev/null 2>&1; then
    COMPOSE_CMD="docker-compose"
else
    COMPOSE_CMD="docker compose"
fi

# Function to check if a service is healthy
check_service() {
    local service=$1
    local container_name=$2
    
    if $COMPOSE_CMD ps | grep -q "$container_name.*Up"; then
        echo -e "${GREEN}✅ $service is running${NC}"
        return 0
    else
        echo -e "${RED}❌ $service is not running${NC}"
        return 1
    fi
}

# Function to check if a URL is accessible
check_url() {
    local url=$1
    local name=$2
    
    if curl -s -o /dev/null -w "%{http_code}" "$url" | grep -q "200\|302\|301"; then
        echo -e "${GREEN}✅ $name is accessible${NC}"
        return 0
    else
        echo -e "${RED}❌ $name is not accessible${NC}"
        return 1
    fi
}

# Main monitoring function
monitor() {
    echo -e "${BLUE}🔍 WordPress Docker Environment Health Check${NC}"
    echo "=============================================="
    
    local all_healthy=true
    
    # Check Docker services
    echo -e "\n${BLUE}📦 Docker Services:${NC}"
    check_service "MySQL Database" "mysql_wp" || all_healthy=false
    check_service "PHP-FPM" "php_wp" || all_healthy=false
    check_service "Nginx Web Server" "nginx_wp" || all_healthy=false
    
    # Check URLs
    echo -e "\n${BLUE}🌐 Website Accessibility:${NC}"
    check_url "http://local-wp.com" "Main WordPress Site (v1)" || all_healthy=false
    check_url "http://local-wp.com/v2" "Secondary WordPress Site (v2)" || all_healthy=false
    
    # Check database connectivity
    echo -e "\n${BLUE}💾 Database Connectivity:${NC}"
    if $COMPOSE_CMD exec -T mysql mysql -u wordpress -pwordpress -e "SELECT 1" wordpress >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Database connection successful${NC}"
    else
        echo -e "${RED}❌ Database connection failed${NC}"
        all_healthy=false
    fi
    
    # Check disk usage
    echo -e "\n${BLUE}💽 Disk Usage:${NC}"
    local website_size=$(du -sh website 2>/dev/null | cut -f1 || echo "N/A")
    local mysql_volume_size=$(docker volume inspect wordpress-docker_mysql_data --format '{{.Mountpoint}}' 2>/dev/null | xargs du -sh 2>/dev/null | cut -f1 || echo "N/A")
    echo -e "Website files: ${YELLOW}$website_size${NC}"
    echo -e "MySQL data: ${YELLOW}$mysql_volume_size${NC}"
    
    # Summary
    echo -e "\n${BLUE}📊 Summary:${NC}"
    if [ "$all_healthy" = true ]; then
        echo -e "${GREEN}🎉 All systems are healthy!${NC}"
        exit 0
    else
        echo -e "${RED}⚠️  Some issues detected. Run 'make logs' for more details.${NC}"
        exit 1
    fi
}

# Function to show resource usage
resources() {
    echo -e "${BLUE}📊 Resource Usage:${NC}"
    echo "=================="
    
    echo -e "\n${BLUE}Docker Container Stats:${NC}"
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}" $($COMPOSE_CMD ps -q) 2>/dev/null || echo "No containers running"
    
    echo -e "\n${BLUE}Docker Volume Usage:${NC}"
    docker system df -v | grep -A 20 "VOLUME NAME"
}

# Main script logic
case "${1:-monitor}" in
    "monitor")
        monitor
        ;;
    "resources")
        resources
        ;;
    "help")
        echo "WordPress Docker Environment Monitor"
        echo "Usage: $0 [monitor|resources|help]"
        echo ""
        echo "Commands:"
        echo "  monitor    - Check health of all services (default)"
        echo "  resources  - Show resource usage statistics"
        echo "  help       - Show this help message"
        ;;
    *)
        echo "Unknown command: $1"
        echo "Use '$0 help' for available commands"
        exit 1
        ;;
esac
