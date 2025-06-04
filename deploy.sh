#!/bin/bash

# Deploy script for MoneyBots App

APP_NAME="moneybotsapp"
APP_USER="ec2-user"
APP_DIR="/opt/$APP_NAME"

echo "Starting deployment of $APP_NAME..."

# Stop the service if it's running
if systemctl is-active --quiet $APP_NAME; then
    echo "Stopping $APP_NAME service..."
    systemctl stop $APP_NAME
fi

# Create app directory if it doesn't exist
mkdir -p $APP_DIR

# Copy binary
echo "Copying application binary..."
cp $APP_NAME $APP_DIR/
chmod +x $APP_DIR/$APP_NAME

# Copy and install systemd service
echo "Installing systemd service..."
cp $APP_NAME.service /etc/systemd/system/
systemctl daemon-reload

# Set ownership
chown -R $APP_USER:$APP_USER $APP_DIR

# Enable and start service
echo "Starting $APP_NAME service..."
systemctl enable $APP_NAME
systemctl start $APP_NAME

# Check status
if systemctl is-active --quiet $APP_NAME; then
    echo "✅ Deployment successful! $APP_NAME is running."
    systemctl status $APP_NAME --no-pager
else
    echo "❌ Deployment failed! Checking logs..."
    journalctl -u $APP_NAME --no-pager -n 10
    exit 1
fi

echo "Deployment completed!"