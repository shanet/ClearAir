#include "particles_sensor.h"

void ParticlesSensor::setup() {
  sensor.begin_I2C();
}

int ParticlesSensor::pm10() {
  read();
  return currentReading.pm10_standard;
}

int ParticlesSensor::pm25() {
  read();
  return currentReading.pm25_standard;
}

int ParticlesSensor::pm100() {
  read();
  return currentReading.pm100_standard;
}

void ParticlesSensor::read() {
  sensor.read(&currentReading);
}
