FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY meshtastic_protobuf_to_json.py .

ENV BROKER=mqtt.meshtastic.org \
    PORT=1883 \
    REGION=EU_868 \
    ROOT_TOPIC=msh

CMD python3 meshtastic_protobuf_to_json.py \
    --broker ${BROKER} \
    --port ${PORT} \
    --region ${REGION} \
    --root-topic ${ROOT_TOPIC} \
    ${USERNAME:+--username} ${USERNAME} \
    ${PASSWORD:+--password} ${PASSWORD} \
    ${PSK:+--psk} ${PSK} \
    ${DEBUG:+--debug}
