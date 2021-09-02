#include "network.h"

void wifiSetup() {
  WiFi.setPins(8, 7, 4, 2);
}

bool connectToNetwork(IPAddress *ip=NULL, IPAddress *dns=NULL, IPAddress *gateway=NULL, IPAddress *subnet=NULL) {
  // Do nothing if already connected
  if(WiFi.status() == WL_CONNECTED) return false;

  while(networkStatus != WL_CONNECTED) {
    networkStatus = WiFi.begin(_SSID, _PASSPHRASE);
    delay(10000);
  }

  // Flash the LED twice when connected to the network
  flashLed();
  flashLed();

  // Set a static IP if one was given
  if(ip != NULL && dns !=NULL && gateway != NULL && subnet != NULL) {
    WiFi.config(*ip, *dns, *gateway, *subnet);
  }

  return true;
}

void processMessage(Client &client) {
  if(!humiditySensor.performReading()) {
    client.println("{\"error\": \"failed to perform humidity reading\"}");
    return;
  }

  float pm25 = particlesSensor.pm25();
  float humidity = humiditySensor.readHumidity();
  int airQuality = particleCountToAirQualityIndex(particlesSensor.pm25(), humidity);

  client.print("{\"air_quality_index\": ");
  client.print(airQuality);

  client.print(", \"air_quality_category\": \"");
  client.print(airQualityCategory(airQuality));
  client.print("\"");

  client.print(", \"pm25\": ");
  client.print(pm25);

  client.print(", \"temperature\": ");
  client.print(humiditySensor.readTemperature());

  client.print(", \"humidity\": ");
  client.print(humidity);

  client.print(", \"pressure\": ");
  client.print(humiditySensor.readPressure());

  client.println("}");
}

void flashLed() {
  digitalWrite(LED_PIN, LOW);
  delay(LED_FLASH_DELAY);
  digitalWrite(LED_PIN, HIGH);
  delay(LED_FLASH_DELAY);
}
