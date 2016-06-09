# Description:
#   Subscribe/Publish to an MQTT server with client-side certificate auth over TLS
#
# Dependencies:
#   mqtt,fs
#
# Configuration:
#
# Commands:
#   hubot mqtt publish <topic> <message>   - Publish a message on a topic
#   hubot mqtt subscribe <topic>           - Subscribe to a topic
#   hubot mqtt unsubscribe <topic>         - Unsubscribe to a topic
#

fs = require('fs')
mqtt = require('mqtt')

HOST             = process.env.HUBOT_MQTT_HOST
PORT             = process.env.HUBOT_MQTT_PORT
# block comment out the rest of this block if no tls
ca_file          = process.env.HUBOT_MQTT_CA_CERT
# block comment out the rest of these varibles if no client_cert auth
client_key_file  = process.env.HUBOT_MQTT_CLIENT_KEY
client_cert_file = process.env.HUBOT_MQTT_CLIENT_CERT
TRUSTED_CA_LIST  = fs.readFileSync("#{ca_file}")
KEY              = fs.readFileSync("#{client_key_file}")
CERT             = fs.readFileSync("#{client_cert_file}")




options =
  port: PORT
  host: HOST
  protocolId: 'MQIsdp'
  protocolVersion: 3
# block comment out the rest of thes if no tls
  ca: TRUSTED_CA_LIST
  rejectUnauthorized: true
# block comment out the rest of these if no client_cert auth
  protocol: 'mqtts'
  secureProtocol: 'TLSv1_method'
  key: KEY
  cert: CERT
  ciphers: 'ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-RSA-RC4-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES128-SHA:AES256-SHA256:AES256-SHA:RC4-SHA:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS:!EDH'




client = mqtt.connect(process.env.HUBOT_MQTT_URL, options)
topic= process.env.HUBOT_MQTT_TOPIC
msg = ""

client.on 'connect', ->
  console.log "Connected to #{process.env.HUBOT_MQTT_URL}"

client.subscribe(topic)

module.exports = (robot) ->
  client.on('message', (topic,message) ->
    for room, topics of subscriptions
      for itopic of topics
        reg = new RegExp(topics[itopic].replace('+', '[^\/]+').replace('#', '.+') + '$');
        matches = topic.match(reg);
        if(matches)
          robot.messageRoom(room, "[#{topic}] #{message}")
  )

  subscriptions = robot.brain.get('mqtt-subscriptions')
  if subscriptions?
    for room, topics of subscriptions
      for itopic of topics
        client.subscribe(topics[itopic])
  if ! subscriptions?
    subscriptions = {}
    subscriptions['#mqtt'] = []
  if topic?
    subscriptions['#mqtt'].push(topic) # subscribe to the initial env topic in #mqtt if given

  robot.respond /mqtt subscribe (.*)/i, (message) ->
    room = message.message.room
    client.subscribe(message.match[1])
    if ! subscriptions[room]?
      subscriptions[room] = []
    subscriptions[room].push (message.match[1])
    robot.brain.set('mqtt-subscriptions',subscriptions)
    robot.brain.save

  robot.respond /mqtt unsubscribe (.*)/i, (message) ->
    topic = message.match[1]
    room = message.message.room
    client.unsubscribe(topic)
    if ! subscriptions[room]?
      subscriptions[room] = []
    index = subscriptions[room].indexOf(topic)
    subscriptions[room].splice(index,1) unless index == -1
    robot.brain.set('mqtt-subscriptions',subscriptions)
    robot.brain.save

  robot.respond /mqtt\s+publish\s+(\S+)\s+(.*)/i, (message) ->
    client.publish( message.match[1], message.match[2] )

  robot.respond /mqtt reconnect/i, (message) ->
    client = mqtt.connect(process.env.HUBOT_MQTT_URL, options)

  robot.respond /mqtt (subscriptions|subscribed|topics)/i, (message) ->
    room = message.message.room
    if subscriptions[room]?
      message.send("#{room} is subscribed to [ " + subscriptions[room].join(', ') + " ]")
    else
      message.send("#{room} is not subscribed to any topics")

