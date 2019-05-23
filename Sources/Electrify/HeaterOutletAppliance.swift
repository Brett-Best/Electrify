//
//  HeaterOutletAppliance.swift
//  BigInt
//
//  Created by Brett Best on 23/5/19.
//

import SwiftyGPIO

class HeaterOutletAppliance: OutletAppliance {
  #if os(Linux)
  var on: Bool = false {
    didSet {
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
