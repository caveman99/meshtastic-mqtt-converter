# Meshtastic MQTT Protobuf ↔ JSON Converter

Bidirectional converter between Meshtastic Protobuf and JSON formats via MQTT with AES encryption support.

[![Python](https://img.shields.io/badge/python-3.9+-blue.svg)](https://www.python.org/downloads/)
[![License](https://img.shields.io/badge/license-GPLv3-green.svg)](LICENSE)

## Features

- **Bidirectional Conversion**
  - Protobuf → JSON (mesh packets to readable format)
  - JSON → Protobuf (commands to mesh network)
- **Encryption Support**
  - AES-128 and AES-256 encryption/decryption
  - PSK in multiple formats (hex, base64, default)
- **Flexible Deployment**
  - Standalone Python script
  - Docker container
  - Docker Compose with Mosquitto broker
- **Full Protocol Support**
  - TEXT_MESSAGE_APP
  - POSITION_APP
  - NODEINFO_APP
  - TELEMETRY_APP
  - WAYPOINT_APP
  - NEIGHBORINFO_APP

## Quick Start

### Standalone Python

```bash
# Install dependencies
pip install -r requirements.txt

# Run converter
python3 meshtastic_protobuf_to_json.py --region EU_868
```

### Docker

```bash
# Build image
docker build -t meshtastic-converter .

# Run container
docker run -d \
  -e REGION=EU_868 \
  -e BROKER=mqtt.meshtastic.org \
  --name meshtastic-converter \
  meshtastic-converter
```

### Docker Compose (with Mosquitto)

```bash
# Start everything
docker-compose up -d

# View logs
docker-compose logs -f

# Stop everything
docker-compose down
```

## Installation

### Requirements

- Python 3.9+
- pip

### Python Dependencies

```bash
pip install -r requirements.txt
```

## Usage

### Command Line Options

```
--broker      MQTT broker address (default: mqtt.meshtastic.org)
--port        MQTT port (default: 1883)
--username    MQTT username (optional)
--password    MQTT password (optional)
--region      Meshtastic region (default: EU_868)
--root-topic  Root topic (default: msh)
--psk         Channel PSK for encryption (optional)
--debug       Enable debug logging
```

### Examples

**Basic usage:**
```bash
python3 meshtastic_protobuf_to_json.py --region EU_868
```

**With encryption:**
```bash
python3 meshtastic_protobuf_to_json.py \
  --region EU_868 \
  --psk 0x1a1a1a1a2b2b2b2b1a1a1a1a2b2b2b2b1a1a1a1a2b2b2b2b1a1a1a1a2b2b2b2b
```

**Private broker with authentication:**
```bash
python3 meshtastic_protobuf_to_json.py \
  --broker mqtt.example.com \
  --username myuser \
  --password mypass \
  --region EU_868 \
  --psk base64:puavdd7vtYJh8NUVWgxbsoG2u9Sdqc54YvMLs+KNcMA=
```

## Docker Deployment

### Standalone Container

**Build:**
```bash
docker build -t meshtastic-converter .
```

**Run:**
```bash
docker run -d \
  -e BROKER=mqtt.meshtastic.org \
  -e PORT=1883 \
  -e REGION=EU_868 \
  -e PSK=0x1a1a1a1a2b2b2b2b1a1a1a1a2b2b2b2b \
  --name meshtastic-converter \
  --restart unless-stopped \
  meshtastic-converter
```

### Docker Compose Setup

The `docker-compose.yml` provides a complete stack with Mosquitto MQTT broker.

**1. Setup:**
```bash
# Create mosquitto config directory
mkdir -p mosquitto/config mosquitto/data mosquitto/log

# Copy mosquitto configuration
cp mosquitto.conf mosquitto/config/mosquitto.conf
```

**2. Configure (optional):**
```bash
# Copy environment template
cp .env.example .env

# Edit configuration
nano .env
```

**3. Start:**
```bash
docker-compose up -d
```

**4. Access:**
- MQTT: `localhost:1883`
- WebSocket: `localhost:9001`

**5. Monitor:**
```bash
# View all logs
docker-compose logs -f

# View converter logs only
docker-compose logs -f converter

# View mosquitto logs only
docker-compose logs -f mosquitto
```

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `BROKER` | MQTT broker address | `mqtt.meshtastic.org` |
| `PORT` | MQTT port | `1883` |
| `REGION` | Meshtastic region | `EU_868` |
| `ROOT_TOPIC` | MQTT root topic | `msh` |
| `USERNAME` | MQTT username | (none) |
| `PASSWORD` | MQTT password | (none) |
| `PSK` | Channel encryption key | (none) |
| `DEBUG` | Enable debug mode | (none) |

## How It Works

### Protobuf → JSON (Uplink)

1. Subscribes to: `msh/REGION/2/e/CHANNELNAME/#`
2. Receives encrypted/unencrypted Protobuf packets
3. Decrypts if PSK is provided
4. Converts to JSON
5. Publishes to: `msh/REGION/2/json/CHANNELNAME/USERID`

### JSON → Protobuf (Downlink)

1. Subscribes to: `msh/REGION/2/json/#`
2. Detects commands with `type: "send*"`
3. Converts JSON to Protobuf
4. Encrypts if PSK is provided
5. Publishes to: `msh/REGION/2/e/CHANNELNAME/GATEWAYID`

## Encryption

### PSK Formats

**Hex (16 bytes = AES-128, 32 bytes = AES-256):**
```bash
--psk 0x1a1a1a1a2b2b2b2b1a1a1a1a2b2b2b2b
```

**Base64:**
```bash
--psk base64:puavdd7vtYJh8NUVWgxbsoG2u9Sdqc54YvMLs+KNcMA=
```

**Default (testing only, insecure):**
```bash
--psk default
```

### Getting Your PSK

**From Meshtastic CLI:**
```bash
meshtastic --info
# Look for "Channels:" section
```

**From Channel URL:**
The PSK is encoded in Meshtastic channel URLs.

## Sending Messages to Mesh

Send JSON messages to any channel to inject them into the mesh network.

### Text Message (Broadcast)

```bash
mosquitto_pub -h localhost -t "msh/EU_868/2/json/LongFast/" -m '{
  "from": 123456789,
  "type": "sendtext",
  "payload": "Hello Mesh!"
}'
```

### Text Message (Direct)

```bash
mosquitto_pub -h localhost -t "msh/EU_868/2/json/LongFast/" -m '{
  "from": 123456789,
  "to": 987654321,
  "type": "sendtext",
  "payload": "Private message"
}'
```

### Position

```bash
mosquitto_pub -h localhost -t "msh/EU_868/2/json/LongFast/" -m '{
  "from": 123456789,
  "type": "sendposition",
  "payload": {
    "latitude": 50.7753,
    "longitude": 6.0839,
    "altitude": 200
  }
}'
```

## Regions

Common Meshtastic regions:

- `EU_868` - Europe 868MHz
- `US` - North America 915MHz
- `EU_433` - Europe 433MHz
- `CN` - China
- `JP` - Japan
- `ANZ` - Australia/New Zealand
- `KR` - Korea
- `TW` - Taiwan
- `RU` - Russia
- `IN` - India

## Testing

### Subscribe to JSON Output

```bash
mosquitto_sub -h mqtt.meshtastic.org -t "msh/EU_868/2/json/#" -v
```

### Send Test Message

```bash
mosquitto_pub -h mqtt.meshtastic.org -t "msh/EU_868/2/json/LongFast/" -m '{
  "from": 123456789,
  "type": "sendtext",
  "payload": "Test from MQTT!"
}'
```

## Troubleshooting

### Connection Issues

**Check MQTT broker connectivity:**
```bash
mosquitto_sub -h mqtt.meshtastic.org -t "msh/#" -v
```

**Test with mosquitto_pub:**
```bash
mosquitto_pub -h mqtt.meshtastic.org -t "test" -m "hello"
```

### Encryption Issues

**Verify PSK format:**
- Hex: Must start with `0x` and be 32 or 64 hex characters
- Base64: Must start with `base64:`
- Default: Use only for testing

**Check channel configuration:**
- Ensure your Meshtastic node has the correct PSK
- Verify channel names match
- Confirm downlink is enabled for sending

### Docker Issues

**View logs:**
```bash
docker-compose logs -f converter
```

**Restart services:**
```bash
docker-compose restart
```

**Rebuild after changes:**
```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## Project Structure

```
.
├── meshtastic_protobuf_to_json.py  # Main converter script
├── requirements.txt                 # Python dependencies
├── Dockerfile                       # Container image
├── docker-compose.yml               # Docker Compose stack
├── mosquitto.conf                   # Mosquitto configuration
├── .env.example                     # Environment template
├── .gitignore                       # Git ignore rules
├── README.md                        # This file
└── EXAMPLES.md                      # Usage examples
```

## Contributing

Contributions welcome! Please feel free to submit a Pull Request.

## License

This project is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.

## Acknowledgments

- [Meshtastic](https://meshtastic.org/) - Open source mesh networking platform
- [Eclipse Mosquitto](https://mosquitto.org/) - MQTT broker
- [Paho MQTT](https://www.eclipse.org/paho/) - MQTT client library

## Support

- Documentation: See [EXAMPLES.md](EXAMPLES.md)
- Issues: [GitHub Issues](https://github.com/caveman99/meshtastic-mqtt-converter/issues)
- Meshtastic: [Discord](https://discord.gg/meshtastic)
