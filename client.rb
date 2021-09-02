#!/usr/bin/env ruby

require 'json'
require 'socket'
require 'time'

def main
  unless ARGV.count == 1
    puts 'Usage: %s [host]' % __FILE__
    exit 1
  end

  socket = TCPSocket.open(ARGV.first, 2424)

  message = ''

  loop do
    data = socket.gets
    break unless data
    message += data
  end

  datapoint = JSON.parse message

  if $stdout.isatty
    human datapoint
  else
    log datapoint
  end

  socket.close
end

def human(datapoint)
  puts 'Air Quality: %s' % datapoint['air_quality_category']
  puts 'Air Quality Index: %d' % datapoint['air_quality_index']
  puts 'Humidity: %.2f%%' % datapoint['humidity']
  puts 'Temperature: %.2fc (%.2ff)' % [datapoint['temperature'], to_fahrenheit(datapoint['temperature'])]
  puts 'Pressure: %.2fhPa' % [datapoint['pressure']]
end

def log(datapoint)
  puts '%s, %s, %d, %.2f, %.2f, %.2f, %.2f' % [
    Time.now.iso8601,
    datapoint['air_quality_category'],
    datapoint['air_quality_index'],
    datapoint['humidity'],
    datapoint['temperature'], to_fahrenheit(datapoint['temperature']),
    datapoint['pressure'],
  ]
end

def to_fahrenheit(value)
  return value * 9/5 + 32
end

main
