For just plaintext you'll want the following in your environmnet, and to block comment out the options involving SSL
```
export HUBOT_MQTT_URL='mqtts://test.mosquitto.org'
export HUBOT_MQTT_PORT='1883'
```

For TLS against the mqtt server:
```
# export HUBOT_MQTT_HOST='test.mosquitto.org'
# export HUBOT_MQTT_URL='mqtt://test.mosquitto.org'
# export HUBOT_MQTT_PORT='8883'
# export HUBOT_MQTT_CA_CERT='/etc/ssl/certs/mosquitto.org.crt'
```

For a custom mosquitto server with client cert authentication you'll want (and obviously change them to your mqtt server)
```
export HUBOT_MQTT_HOST='mqtt.hq.thebikeshed.io'
export HUBOT_MQTT_URL='mqtts://mqtt.hq.thebikeshed.io'
export HUBOT_MQTT_PORT='8883'
export HUBOT_MQTT_CA_CERT='/etc/ssl/certs/ca.crt'
export HUBOT_MQTT_CLIENT_KEY='/etc/ssl/private/localhost.ckey'
export HUBOT_MQTT_CLIENT_CERT='/etc/ssl/certs/localhost.crt'
```
