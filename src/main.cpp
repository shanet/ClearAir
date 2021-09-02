#include "main.h"

void setup() {
  humiditySensor.setup();
  particlesSensor.setup();
  wifiSetup();

  connectToNetwork(&ip, &dns, &gateway, &subnet);
  server.begin();
}

void loop() {
  // Ensure we're still connected to the network
  if(connectToNetwork(&ip, &dns, &gateway, &subnet)) server.begin();

  // Get a client from the server
  WiFiClient client = server.available();

  // Check if a client is available
  if(!client || !client.connected()) {
    return;
  }

  processMessage(client);
  flashLed();

  // We're done with this client. Disconnect it.
  client.stop();
}
