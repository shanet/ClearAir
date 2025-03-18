ClearAir
========

#### Kira Tully (ephemeral.cx)

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

### Compiling & Uploading

These instructions are for Linux.

1. Run `scripts/download_dependencies.sh` to download tooling dependencies.
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

GPLv3
