#ifndef NETWORK_H
#define NETWORK_H

#include <WiFi101.h>

#include "air_quality.h"
#include "constants.h"
#include "humidity_sensor.h"
#include "particles_sensor.h"
#include "secrets.h"

extern HumiditySensor humiditySensor;
extern ParticlesSensor particlesSensor;

void wifiSetup();
bool connectToNetwork(IPAddress *ip, IPAddress *dns, IPAddress *gateway, IPAddress *subnet);
void processMessage(Client &client);
void abortClient(Client &client);
void flashLed();

int networkStatus = WL_IDLE_STATUS;

#endif
