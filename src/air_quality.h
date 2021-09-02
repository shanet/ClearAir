#ifndef AIR_QUALITY_H
#define AIR_QUALITY_H

#include <math.h>

int particleCountToAirQualityIndex(float particleCount, float relativeHumidity);
int calculateAirQualityIndex(float particleCount, float concentrationLow, float concentrationHigh, float indexLow, float indexHigh);
float epaCorrection(float particleCount, float relativeHumidity);
char* airQualityCategory(int airQuality);

#endif
