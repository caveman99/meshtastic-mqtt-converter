#!/bin/bash

set -e

echo "Meshtastic MQTT Converter - Docker Compose Setup"
echo "================================================"
echo

# Create mosquitto directories
echo "Creating mosquitto directories..."
mkdir -p mosquitto/config mosquitto/data mosquitto/log

# Copy mosquitto configuration
echo "Setting up mosquitto configuration..."
cp mosquitto.conf mosquitto/config/mosquitto.conf

# Set correct permissions
echo "Setting permissions..."
chmod -R 755 mosquitto
chmod 644 mosquitto/config/mosquitto.conf

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    cp .env.example .env
    echo "Created .env file - please edit it with your settings"
else
    echo ".env file already exists"
fi

echo
echo "Setup complete!"
echo
echo "Next steps:"
echo "1. Edit .env file with your configuration"
echo "2. Run: docker-compose up -d"
echo "3. View logs: docker-compose logs -f"
echo
echo "MQTT Endpoints:"
echo "  - TCP:       localhost:1883"
echo "  - WebSocket: localhost:9001"
echo
