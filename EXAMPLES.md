# Example JSON Messages for Meshtastic Downlink

## Send to LongFast Channel (Default)
```bash
mosquitto_pub -h mqtt.meshtastic.org -t "msh/EU_868/2/json/LongFast/" -m '{
  "from": 123456789,
  "type": "sendtext",
  "payload": "Hello from MQTT!"
}'
```

## Send to Custom Channel
```bash
mosquitto_pub -h mqtt.meshtastic.org -t "msh/EU_868/2/json/MyPrivateChannel/" -m '{
  "from": 123456789,
  "type": "sendtext",
  "payload": "Message to private channel"
}'
```

## Send Text Message (Direct Message)
```bash
mosquitto_pub -h mqtt.meshtastic.org -t "msh/EU_868/2/json/LongFast/" -m '{
  "from": 123456789,
  "to": 987654321,
  "type": "sendtext",
  "payload": "Private message"
}'
```

## Send Position
```bash
mosquitto_pub -h mqtt.meshtastic.org -t "msh/EU_868/2/json/LongFast/" -m '{
  "from": 123456789,
  "type": "sendposition",
  "payload": {
    "latitude": 50.7753,
    "longitude": 6.0839,
    "altitude": 200
  }
}'
```

## With Python paho-mqtt
```python
import paho.mqtt.client as mqtt
import json

client = mqtt.Client()
client.connect("mqtt.meshtastic.org", 1883)

# Send text message to LongFast channel
message = {
    "from": 123456789,
    "type": "sendtext",
    "payload": "Hello Meshtastic!"
}
client.publish("msh/EU_868/2/json/LongFast/", json.dumps(message))

# Send to custom channel
client.publish("msh/EU_868/2/json/MyChannel/", json.dumps(message))
```

## Notes
- Replace `123456789` with your actual node ID
- Replace `LongFast` with any channel name configured on your node
- For direct messages, use the recipient's node ID in the `to` field
- Omit `to` field for broadcast messages
- The channel must have downlink enabled on your Meshtastic node
