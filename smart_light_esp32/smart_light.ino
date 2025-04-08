#include <WiFi.h>
#include <PubSubClient.h>
#include <Wire.h>
#include <ArduinoJson.h>

// Replace the next variables with your SSID/Password combination
const char* wifi_ssid = "<SSID of your WiFi network>";
const char* wifi_password = "<WiFi password>";

// Add your MQTT Broker IP address, example:
const char* mqtt_server = "<IP address>";

const char* controller_topic = "light-controller";
const char* device_topic = "light-bulb";

const uint8_t pin = BUILTIN_LED;

WiFiClient espClient;
PubSubClient client(espClient);
long lastMsg = 0;
char msg[50];
bool powerOn = false;

struct Command {
  String action;
};

struct Status {
  String power;
};

void setup() {
  Serial.begin(115200);
  setup_wifi();
  client.setServer(mqtt_server, 1883);
  client.setCallback(callback);

  pinMode(pin, OUTPUT);
}

void setup_wifi() {
  delay(10);
  // We start by connecting to a WiFi network
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(wifi_ssid);

  WiFi.begin(wifi_ssid, wifi_password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
}

void callback(char* topic, byte* message, unsigned int length) {
  Serial.print("Message arrived on topic: ");
  Serial.print(topic);
  Serial.print(". Message: ");
  String messageTemp;

  for (int i = 0; i < length; i++) {
    Serial.print((char)message[i]);
    messageTemp += (char)message[i];
  }
  Serial.println();

  if (String(topic) == "light-bulb") {
    Serial.print("Received command: ");
    Serial.println(messageTemp);

    processCommand(messageTemp);
    publishStatus();
  }
}

void reconnect() {
  // Loop until we're reconnected
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    // Attempt to connect
    if (client.connect("ESP32Client")) {
      Serial.println("connected");
      // Subscribe
      client.subscribe(device_topic);
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      // Wait 5 seconds before retrying
      delay(5000);
    }
  }
}

void processCommand(String message) {
  Command command = deserializeCommand(message);
  Serial.print("Action: ");
  Serial.println(command.action);
  if (command.action == (String) "turnOn") {
    Serial.println("on");
    powerOn = true;
  } else if (command.action == (String) "turnOff") {
    Serial.println("off");
    powerOn = false;
  } else {
    Serial.println("Unknown command");
  }
  digitalWrite(pin, powerOn ? HIGH : LOW);
}

Command deserializeCommand(const String& message) {
  JsonDocument root;
  deserializeJson(root, message);
  Command command;
  command.action = root["action"] | "";
  return command;
}

void publishStatus() {
  Serial.print("Satus: ");
  Serial.println(powerOn);
  String tempString = serializeStatus(powerOn);
  Serial.print("Sending status:");
  Serial.println(tempString);
  client.publish(controller_topic, tempString.c_str());
}

String serializeStatus(bool on) {
  JsonDocument doc;
  doc["power"] = on ? "on" : "off";
  String output;
  serializeJson(doc, output);
  return output;
}

void loop() {
  if (!client.connected()) {
    reconnect();
  }
  client.loop();

  long now = millis();
  if (now - lastMsg > 5000) {
    lastMsg = now;
    publishStatus();
  }
}
