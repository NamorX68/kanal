#!/bin/bash

# Kanal Application Deployment Script
# Deploys FastAPI applications from Development VM to Web Services VM

set -e

echo "🚀 Starting application deployment..."

# Configuration
DEV_VM="10.0.100.106"
WEB_VM="10.0.100.102"
GIT_REPO="https://github.com/youruser/kanal-api.git"
APP_USER="api"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to run commands on remote VM
run_remote() {
    local vm_ip=$1
    local command=$2
    ssh -o StrictHostKeyChecking=no root@$vm_ip "$command"
}

# Deploy REST API
deploy_rest_api() {
    print_status "Deploying REST API..."

    run_remote $WEB_VM "
        # Stop service
        systemctl stop api || true

        # Update code
        cd /opt/api
        git pull origin main

        # Update dependencies
        source venv/bin/activate
        pip install -r requirements.txt

        # Run tests
        python -m pytest tests/ -v

        # Restart service
        systemctl start api
        systemctl enable api

        # Verify service is running
        sleep 5
        systemctl is-active api
    "

    print_success "REST API deployed successfully"
}

# Deploy MCP Server
deploy_mcp_server() {
    print_status "Deploying MCP Server..."

    run_remote $WEB_VM "
        # Stop service
        systemctl stop mcp || true

        # Update code
        cd /opt/mcp
        git pull origin main

        # Update dependencies
        source venv/bin/activate
        pip install -r requirements.txt

        # Run tests
        python -m pytest tests/ -v

        # Restart service
        systemctl start mcp
        systemctl enable mcp

        # Verify service is running
        sleep 5
        systemctl is-active mcp
    "

    print_success "MCP Server deployed successfully"
}

# Update Nginx configuration
update_nginx() {
    print_status "Updating Nginx configuration..."

    run_remote $WEB_VM "
        # Test nginx configuration
        nginx -t

        # Reload nginx
        systemctl reload nginx

        # Verify nginx is running
        systemctl is-active nginx
    "

    print_success "Nginx configuration updated"
}

# Health checks
run_health_checks() {
    print_status "Running health checks..."

    # Check REST API
    if curl -f -s http://$WEB_VM:8000/health > /dev/null; then
        print_success "REST API health check passed"
    else
        print_error "REST API health check failed"
        exit 1
    fi

    # Check MCP Server
    if curl -f -s http://$WEB_VM:8001/health > /dev/null; then
        print_success "MCP Server health check passed"
    else
        print_error "MCP Server health check failed"
        exit 1
    fi

    # Check Nginx
    if curl -f -s http://$WEB_VM/health > /dev/null; then
        print_success "Nginx health check passed"
    else
        print_error "Nginx health check failed"
        exit 1
    fi
}

# Update monitoring dashboards
update_monitoring() {
    print_status "Updating monitoring configuration..."

    # Trigger Prometheus configuration reload
    run_remote "10.0.100.105" "
        # Reload Prometheus
        curl -X POST http://localhost:9090/-/reload

        # Restart Grafana to pick up new dashboards
        systemctl restart grafana-server
    "

    print_success "Monitoring updated"
}

# Send notification (placeholder for N8N webhook)
send_notification() {
    local status=$1
    local message=$2

    print_status "Sending notification..."

    # This would typically call N8N webhook or Slack
    curl -X POST "http://10.0.100.104:5678/webhook/deployment" \
        -H "Content-Type: application/json" \
        -d "{
            \"status\": \"$status\",
            \"message\": \"$message\",
            \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",
            \"deployed_by\": \"$(whoami)\",
            \"git_commit\": \"$(git rev-parse --short HEAD)\"
        }" || true
}

# Rollback function
rollback() {
    print_warning "Rolling back deployment..."

    run_remote $WEB_VM "
        # Stop current services
        systemctl stop api mcp

        # Checkout previous commit
        cd /opt/api && git checkout HEAD~1
        cd /opt/mcp && git checkout HEAD~1

        # Restart services
        systemctl start api mcp
    "

    print_warning "Rollback completed"
}

# Main deployment function
main() {
    local start_time=$(date +%s)

    print_status "Starting deployment at $(date)"

    # Trap errors for rollback
    trap 'print_error "Deployment failed, rolling back..."; rollback; send_notification "failed" "Deployment failed and was rolled back"; exit 1' ERR

    # Pre-deployment checks
    print_status "Running pre-deployment checks..."

    # Check if Web Services VM is reachable
    if ! ping -c 1 $WEB_VM > /dev/null 2>&1; then
        print_error "Web Services VM ($WEB_VM) is not reachable"
        exit 1
    fi

    # Check if services are running
    if ! run_remote $WEB_VM "systemctl is-active api" > /dev/null 2>&1; then
        print_warning "API service is not running, will start after deployment"
    fi

    # Deployment steps
    deploy_rest_api
    deploy_mcp_server
    update_nginx
    run_health_checks
    update_monitoring

    # Calculate deployment time
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    print_success "Deployment completed successfully in ${duration} seconds"
    send_notification "success" "Deployment completed successfully in ${duration} seconds"
}

# Script options
case "${1:-deploy}" in
    "deploy")
        main
        ;;
    "rollback")
        rollback
        send_notification "rollback" "Manual rollback executed"
        ;;
    "health-check")
        run_health_checks
        ;;
    "help")
        echo "Usage: $0 [deploy|rollback|health-check|help]"
        echo "  deploy      - Deploy applications (default)"
        echo "  rollback    - Rollback to previous version"
        echo "  health-check - Run health checks only"
        echo "  help        - Show this help message"
        ;;
    *)
        print_error "Unknown option: $1"
        echo "Use '$0 help' for usage information"
        exit 1
        ;;
esac