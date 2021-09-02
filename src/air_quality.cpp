#include "air_quality.h"

/*
Air Quality Index conversion formulas are taken from https://en.wikipedia.org/wiki/Air_quality_index#Computing_the_AQI

                      IndexHigh - IndexLow
Air Quality = ------------------------------------ * (ParticleCount - ConcentrationLow) + IndexLow
              ConcentrationHigh - ConcentrationLow

+------------------------------+-----------------+-------------------+
|Air Quality Category          |Air Quality Index|PM2.5 Concentration|
+------------------------------+-----------------+-------------------+
|Good                          |      0 - 50     |     0.0 – 12.0    |
|Moderate                      |     51 - 100    |    12.1 – 35.4    |
|Unhealthy for Sensitive Groups|    101 – 150    |    35.5 – 55.4    |
|Unhealthy                     |    151 – 200    |    55.5 – 150.4   |
|Very Unhealthy                |    201 – 300    |   150.5 – 250.4   |
|Hazardous                     |    301 – 400    |   250.5 – 350.4   |
|Hazardous                     |    401 – 500    |   350.5 – 500     |
+------------------------------+-----------------+-------------------+

The EPA correction is taken from https://cfpub.epa.gov/si/si_public_record_report.cfm?Lab=CEMM&dirEntryId=349513.
Specifically the final page in the PDF (also checked in to this repo): https://cfpub.epa.gov/si/si_public_file_download.cfm?p_download_id=540979&Lab=CEMM

This formula uses the experimentally derived values from the EPA studies to correct the Plantower sensors for actual readings during smoke events.
This is using a one hour average but since we're only using instantaneous values here we ignore that part.
*/

int particleCountToAirQualityIndex(float particleCount, float relativeHumidity) {
  float correctedParticleCount = epaCorrection(particleCount, relativeHumidity);

  // It sure would be nice to put all of these values in a map, but that would involve bringing in a bunch of extra libraries just to save a few lines here
  if(correctedParticleCount > 350.5) {
    return calculateAirQualityIndex(correctedParticleCount, 350.5, 500.4, 401, 500);
  } else if(correctedParticleCount > 250.5) {
    return calculateAirQualityIndex(correctedParticleCount, 250.5, 350.4, 301, 400);
  } else if(correctedParticleCount > 150.5) {
    return calculateAirQualityIndex(correctedParticleCount, 150.5, 250.4, 201, 300);
  } else if(correctedParticleCount > 55.5) {
    return calculateAirQualityIndex(correctedParticleCount, 55.5, 150.4, 151, 200);
  } else if(correctedParticleCount > 35.5) {
    return calculateAirQualityIndex(correctedParticleCount, 35.5, 55.4, 101, 150);
  } else if(correctedParticleCount > 12.1) {
    return calculateAirQualityIndex(correctedParticleCount, 12.1, 35.4, 51, 100);
  } else if(correctedParticleCount >= 0) {
    return calculateAirQualityIndex(correctedParticleCount, 0, 12, 0, 50);
  } else {
    return -1;
  }
}

int calculateAirQualityIndex(float particleCount, float concentrationLow, float concentrationHigh, float indexLow, float indexHigh) {
  float index_difference = indexHigh - indexLow;
  float concentration_difference = concentrationHigh - concentrationLow;

  return round(index_difference / concentration_difference * (particleCount - concentrationLow) + indexLow);
}

float epaCorrection(float particleCount, float relativeHumidity) {
  return 0.534 * particleCount - 0.0844 * relativeHumidity + 5.604;
}

char* airQualityCategory(int airQuality) {
  if(airQuality >= 301) {
    return "Hazardous";
  } else if(airQuality >= 201) {
    return "Very Unhealthy";
  } else if(airQuality >= 151) {
    return "Unhealthy";
  } else if(airQuality >= 101) {
    return "Unhealthy for Sensitive Groups";
  } else if(airQuality >= 51) {
    return "Moderate";
  } else if(airQuality >= 0) {
    return "Good";
  } else {
    return "";
  }
}
