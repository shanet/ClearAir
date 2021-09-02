ClearAir
========

#### Shane Tully (shanetully.com)

A minimalist, DIY PurpleAir clone.

Note: This project may go long periods of time without being updated, however it is actively used and maintained. Bug reports and pull requests are welcome.

## About

ClearAir is DIY PurpleAir clone built to be a minimalist replacement. It uses the same sensors and calculations, but for a third of the cost. A Ruby script is provided for reading the current values from the sensor over the network. Other frontends/clients can be written tailored to your needs.

## Hardware

ClearAir was built and tested on an Adafruit Feather M0 WiFi.

* [Adafruit Feather M0 WiFi](https://www.adafruit.com/products/3010)
* [Adafruit BME688](https://www.adafruit.com/product/5046)
* [Adafruit PMSA003I](https://www.adafruit.com/product/4632)
* [5V 1A (1000mA) USB port power supply](https://www.adafruit.com/products/501)
* A micro-usb cable

## Usage

### Setting up the hardware

|BME688    |PMSA003I  |
|----------|----------|
|3V -> 3V  |3V -> 3V  |
|GND -> GND|GND -> GND|
|SCL -> SCK|SCL -> SCL|
|SDA -> SDI|SDA -> SDA|

A Fritzing file is located at `docs/ClearAir.fzz`.

Wiring diagram: ![](/docs/wiring_diagram.png?raw=true)

### Setting up the software dependencies

These instructions are for Linux (x86_64).

* Download and extract the [Adafruit SAMD library](https://github.com/adafruit/arduino-board-index/raw/gh-pages/boards/adafruit-samd-1.0.9.tar.bz2) to `~/.arduino15/packages/adafruit/hardware/samd/1.0.9`
* Download and extract the [ARM compiler](http://downloads.arduino.cc/gcc-arm-none-eabi-4.8.3-2014q1-linux64.tar.gz) to `~/.arduino15/packages/adafruit/tools/arm-none-eabi-gcc/4.8.3-2014q1`
* Download and extract [Bossac](http://downloads.arduino.cc/bossac-1.6.1-arduino-x86_64-linux-gnu.tar.gz) to `~/.arduino15/packages/adafruit/tools/bossac/1.6.1-arduino`.
* Download and extract [CMSIS](http://downloads.arduino.cc/CMSIS-4.0.0.tar.bz2) to `~/.arduino15/packages/adafruit/tools/CMSIS/4.0.0-atmel`.

Note: The archives above can be extracted whenever you'd like, but the paths at the top of the Makefile must be adjusted accordingly.

### Compiling & Uploading

1. Create `src/secrets.h` with the following content:
    ```
    #define _SSID "your_ssid"
    #define _PASSPHRASE "passphrase"
    ```
1. Edit `src/main.h` with appropriate IP & network settings
1. Then:
    ```
    $ make
    $ make upload
    ```

### Reading Air Quality

To read values from the device, run `./client.rb [HOST]`. Ruby is needed to run this script.

From here other frontends/clients can be written tailored for your needs. Reading from the sensor is as simple as opening a TCP socket and reading the JSON value that is returned.

An example response is as such:

```json
{
  "air_quality_index": 9,
  "air_quality_category": "Good",
  "pm25": 2.00,
  "temperature": 23.07,
  "humidity": 53.14,
  "pressure": 1001.74
}

```

### Networking

The default port is 2424. Don't forget to add rules to allow communication on this port on any firewalls or gateways between the client and the server.

## License

Copyright (C) 2021 Shane Tully

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
