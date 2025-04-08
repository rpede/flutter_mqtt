# Smart Light ESP32

Tested on FireBeetle 2 ESP32-E.

## Required libraries

- ArduinoJson
- PubSubClient

## Setup

Install the libraries.
In Arduino IDE go "Tools" -> "Manage libraries..." then search for the
libraries and install one by one.

Change the following in `smart_light.ino`:

- wifi_ssid
- wifi_password
- mqtt_server

Depending on your board or setup, you might want to change `pin` to something
else.

Upload the sketch to you ESP32 board.

Start the `light_controller` Flutter app.

You can now control a LED on your ESP32 from your phone.
