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
}

class EnvironmentMonitor {
  
  weak var delegate: EnvironmentMonitorDelegate?
  
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
      do {
        let data = try bus.read_i2c_block_data.throwing.dynamicallyCall(withArguments: 0x48, 0)
        
        let msb = Int(data[0])!
        let lsb = Int(data[1])!
        
        let temperature = Float(((msb << 8) | lsb) >> 4) * 0.0625
        
        delegate?.environmentMonitor(self, updatedTemperature: temperature)
        
        print("Temperature: \(temperature)ºC")
      } catch {
        print("I2C Error: \(error)")
      }
  }
  
}
