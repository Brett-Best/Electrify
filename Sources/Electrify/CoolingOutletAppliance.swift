//
//  CoolingOutletAppliance.swift
//  BigInt
//
//  Created by Brett Best on 23/5/19.
//

import SwiftyGPIO

class CoolerOutletAppliance: OutletAppliance {
  
  var on: Bool = false {
    didSet {
      coolerGPIO.value = on
    }
  }
  
  var coolerGPIO: GPIOInterface
  
  init() {
    let gpios = SwiftyGPIO.GPIOs(for:.RaspberryPi3)
    coolerGPIO = gpios[.pin21]!
    coolerGPIO.direction = .output
  }
  
}

