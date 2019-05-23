//
//  HeaterOutletAppliance.swift
//  BigInt
//
//  Created by Brett Best on 23/5/19.
//

import SwiftyGPIO
import Foundation

class HeaterOutletAppliance: OutletAppliance {
  
  private var turnedOnAt: Date? {
    didSet {
      if let oldDate = oldValue {
        _totalOnTime = _totalOnTime + Float(Date().timeIntervalSince(oldDate))
      }
    }
  }
  
  private var _totalOnTime: Float = 0
  var totalOnTime: Float {
    get {
      guard let turnedOnAt = turnedOnAt else {
        return _totalOnTime
      }
      
      return _totalOnTime + Float(Date().timeIntervalSince(turnedOnAt))
    }
  }
  
  #if os(Linux)
  var on: Bool = false {
    didSet {
      if !oldValue && on {
        turnedOnAt = Date()
      } else if !on {
        turnedOnAt = nil
      }
      
      heaterGPIO.value = on
    }
  }
  
  var heaterGPIO: GPIOInterface
  
  init() {
    let gpios = SwiftyGPIO.GPIOs(for:.RaspberryPi3)
    heaterGPIO = gpios[.pin20]!
    heaterGPIO.direction = .output
  }
  #endif
}
