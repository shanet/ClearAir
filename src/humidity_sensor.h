#ifndef HUMIDITY_SENSOR_H
#define HUMIDITY_SENSOR_H

#include <Adafruit_BME680.h>
#include <Wire.h>
#include "constants.h"

#define STANDARD_SEA_LEVEL_PRESSURE 1013.25 // hPa

class HumiditySensor {
public:
  void setup();
  bool performReading();
  float readTemperature();
  float readPressure();
  float readHumidity();
  uint32_t readGas();
  float readAltitude();

private:
  Adafruit_BME680 sensor;
};

#endif
