#ifndef MAIN_H
#define MAIN_H

#include <SPI.h>
#include <WiFi101.h>

#include "air_quality.h"
#include "constants.h"
#include "humidity_sensor.h"
#include "particles_sensor.h"
#include "secrets.h"

// IMPORTANT: The network settings MUST BE CHANGED to something unique for each server
IPAddress ip(10, 10, 12, 41);
IPAddress dns(10, 10, 12, 1);
IPAddress gateway(10, 10, 12, 1);
IPAddress subnet(255, 255, 255, 0);

WiFiServer server(PORT);
HumiditySensor humiditySensor;
ParticlesSensor particlesSensor;

extern void processMessage(Client &client);
extern void wifiSetup();
extern bool connectToNetwork(IPAddress *ip, IPAddress *dns, IPAddress *gateway, IPAddress *subnet);
extern void flashLed();

#endif
