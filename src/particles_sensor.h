#ifndef PARTICLES_SENSOR_H
#define PARTICLES_SENSOR_H

#include <Adafruit_PM25AQI.h>
#include <Wire.h>
#include "constants.h"

class ParticlesSensor {
public:
  void setup();
  int pm10();
  int pm25();
  int pm100();

private:
  void read();

  PM25_AQI_Data currentReading;
  Adafruit_PM25AQI sensor;
};

#endif
