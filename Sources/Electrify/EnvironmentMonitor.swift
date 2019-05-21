//
//  EnvironmentMonitor.swift
//  BigInt
//
//  Created by Brett Best on 20/5/19.
//

import Foundation
import PythonKit

protocol EnvironmentMonitorDelegate: class {
  func environmentMonitor(_ monitor: EnvironmentMonitor, updatedTemperature temperature: Float)
  func environmentMonitor(_ monitor: EnvironmentMonitor, updatedLumens lumens: Float)
}

class EnvironmentMonitor {
  
  enum ReadError: Error {
    case i2c(underlying: Error)
    case dataToNumberConversion(data: PythonObject)
  }
  
  weak var delegate: EnvironmentMonitorDelegate?
  #if os(Linux)
  let timer = DispatchSource.makeTimerSource()
  
  let smbus: PythonObject
  let bus: PythonObject
  
  init() {
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
    refreshLumens()
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
      
      delegate?.environmentMonitor(self, updatedLumens: lumens)
    } catch {
      logger.error("Temperature I2C error", error: ReadError.i2c(underlying: error))
    }
  }
  
  #endif
  
}
