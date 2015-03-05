# Description:
#   Retrieve environment information from MQTT server.
#
# Dependencies:
#   None
#
# Configuration:
#
# Commands:
#   hubot env me   - Retrieve environment information.

mqtt = require('mqtt')

client = mqtt.connect(process.env.HUBOT_MQTT_URL,
{ protocolId: 'MQIsdp', protocolVersion: 3 })
topic= process.env.HUBOT_MQTT_TOPIC
msg = ""

client.subscribe(topic)

client.on('message', (topic,message) ->
  ob = JSON.parse(message)
  dt = new Date(Number(ob.date))
  msg = "#{dt.getMonth()+1}月#{dt.getDate()}日, #{dt.getHours()}:#{dt.getMinutes()}:#{dt.getSeconds()} のデータセンターの室内気温は #{ob.temp}℃, 湿度は #{ob.hum} % です"
  # console.log(msg)
)

module.exports = (robot) ->
  robot.respond /env me/i, (message) ->
# x=() ->
        message.send msg
        # console.log msg

# x()
