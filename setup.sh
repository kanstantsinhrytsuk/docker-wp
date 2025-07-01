#!/bin/bash

# WordPress Docker Environment Setup Script

echo "🚀 Setting up WordPress Docker Environment..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if local-wp.com is in hosts file
if ! grep -q "local-wp.com" /etc/hosts; then
    echo "📝 Adding local-wp.com to hosts file..."
    echo "127.0.0.1 local-wp.com" | sudo tee -a /etc/hosts
    echo "✅ Added local-wp.com to hosts file"
else
    echo "✅ local-wp.com already exists in hosts file"
fi

# Build and start containers
echo "🐳 Building and starting Docker containers..."
docker-compose down 2>/dev/null || true
docker-compose build --no-cache
docker-compose up -d

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 30

# Check if services are running
if docker-compose ps | grep -q "Up"; then
    echo "✅ Services are running!"
    echo ""
    echo "🎉 Setup complete! You can now access:"
    echo "   Main WordPress site: http://local-wp.com"
    echo "   Secondary site: http://local-wp.com/v2"
    echo ""
    echo "📋 Database credentials:"
    echo "   Host: mysql"
    echo "   Database: wordpress"
    echo "   Username: wordpress"
    echo "   Password: wordpress"
    echo ""
    echo "📝 Next steps:"
    echo "   1. Install WordPress on both sites"
    echo "   2. Configure wp-config.php with the database credentials above"
    echo "   3. Start building your sites!"
else
    echo "❌ Some services failed to start. Check logs with: docker-compose logs"
    exit 1
fi
