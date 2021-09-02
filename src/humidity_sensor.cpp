#include "humidity_sensor.h"

void HumiditySensor::setup() {
  sensor.begin();

  sensor.setTemperatureOversampling(BME680_OS_8X);
  sensor.setHumidityOversampling(BME680_OS_2X);
  sensor.setPressureOversampling(BME680_OS_4X);
  sensor.setIIRFilterSize(BME680_FILTER_SIZE_3);
}

bool HumiditySensor::performReading() {
  return sensor.performReading();
}

float HumiditySensor::readTemperature() {
  return sensor.temperature;
}

float HumiditySensor::readPressure() {
  return sensor.pressure / 100.0;
}

float HumiditySensor::readHumidity() {
  return sensor.humidity;
}

uint32_t HumiditySensor::readGas() {
  return sensor.gas_resistance;
}

float HumiditySensor::readAltitude() {
  return sensor.readAltitude(STANDARD_SEA_LEVEL_PRESSURE);
}
