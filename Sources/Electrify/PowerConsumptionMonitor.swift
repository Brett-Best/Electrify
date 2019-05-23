//
//  PowerConsumptionMonitor.swift
//  Electrify
//
//  Created by Brett Best on 24/5/19.
//

import Foundation
import HAP

class PowerConsumptionMonitor {
  
  weak var thermostat: Accessory.ElectrifyThermostat?
  weak var heaterOutletAppliance: OutletAppliance?
  weak var coolerOutletAppliance: OutletAppliance?
  
  let timer = DispatchSource.makeTimerSource()
  
  init() {
    timer.schedule(deadline: .now(), repeating: .seconds(10), leeway: .seconds(1))
    timer.setEventHandler(handler: refreshData)
    timer.resume()
  }
  
  func refreshData() {
    if let heaterOutletAppliance = heaterOutletAppliance {
      thermostat?.heaterOnTimeCharateristic.value = uint32(heaterOutletAppliance.totalOnTime)
    }
    
    if let coolerOutletAppliance = coolerOutletAppliance {
      thermostat?.coolerOnTimeCharateristic.value = uint32(coolerOutletAppliance.totalOnTime)
    }
  }
  
}
