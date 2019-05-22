//
//  EnvironmentMonitor.swift
//  BigInt
//
//  Created by Brett Best on 20/5/19.
//

import Foundation
import PythonKit
import SwiftyGPIO
import dhtxx

protocol EnvironmentMonitorDelegate: class {
  func environmentMonitor(_ monitor: EnvironmentMonitor, updatedTemperature temperature: Float)
  func environmentMonitor(_ monitor: EnvironmentMonitor, updatedRelativeHumidity relativeHumidity: Float)
  func environmentMonitor(_ monitor: EnvironmentMonitor, updatedLumens lumens: Float?)
}

class EnvironmentMonitor {
  
  enum ReadError: Error {
    case i2c(underlying: Error)
    case dataToNumberConversion(data: PythonObject)
    case sensorNotReady
  }
  
  weak var delegate: EnvironmentMonitorDelegate?
  
  #if os(Linux)
  let timer = DispatchSource.makeTimerSource()
  
  let smbus: PythonObject
  let bus: PythonObject
  
  let am2302Sensor: DHT
  
  init() {
    let gpios = SwiftyGPIO.GPIOs(for:.RaspberryPi3)
    let pin26 = gpios[.pin26]!
    
    am2302Sensor = DHT(pin: pin26, for: .dht22) // AM2302 behaves in the same way as DHT22 but doesn't need a pullup resistor
    
    do {
      smbus = try Python.attemptImport("smbus")
    } catch {
      fatalError("Failed to import python smbus with error: \(error)")
    }
    
    bus = smbus.SMBus(1)
    
    timer.schedule(deadline: .now(), repeating: .seconds(5), leeway: .milliseconds(100))
    timer.setEventHandler(handler: refreshData)
    timer.resume()
  }
  
  func refreshData() {
    refreshTemperature()
    refreshHumidity()
    refreshLumens()
  }
  
  func refreshHumidity() {
    do {
      let relativeHumidity = try am2302Sensor.read().humidity
      
      delegate?.environmentMonitor(self, updatedRelativeHumidity: Float(relativeHumidity))
    } catch {
      logger.error("Humidity error", error: error)
    }
  }
  
  func refreshTemperature() {
    do {
      let tmp102BlockData = try bus.read_i2c_block_data.throwing.dynamicallyCall(withArguments: 0x48, 0)
      
      guard let msb = Int(tmp102BlockData[0]), let lsb = Int(tmp102BlockData[1]) else {
        throw ReadError.dataToNumberConversion(data: tmp102BlockData)
      }
      
      let temperature = Float(((msb << 8) | lsb) >> 4) * 0.0625
      
      delegate?.environmentMonitor(self, updatedTemperature: temperature)
    } catch {
      logger.error("Temperature I2C error", error: ReadError.i2c(underlying: error))
    }
  }
  
  func refreshLumens() {
    do {
      let temt6000WordData = try bus.read_word_data.throwing.dynamicallyCall(withArguments: 0x04, 0)
      
      guard let lumens = Float(temt6000WordData) else {
        throw ReadError.dataToNumberConversion(data: temt6000WordData)
      }
      
      if 0 == lumens {
        delegate?.environmentMonitor(self, updatedLumens: nil)
        throw ReadError.sensorNotReady
      }
      
      delegate?.environmentMonitor(self, updatedLumens: lumens)
    } catch {
      delegate?.environmentMonitor(self, updatedLumens: nil)
      logger.error("Lumens I2C error", error: ReadError.i2c(underlying: error))
    }
  }
  
  #endif

}
