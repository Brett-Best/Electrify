//
//  Accessory+Electrify.swift
//  BigInt
//
//  Created by Brett Best on 22/5/19.
//

import HAP

extension Accessory {
  
  class ElectrifyThermostat: Accessory {
    
    public let thermostat = Service.Thermostat(characteristics: [
      AnyCharacteristic(PredefinedCharacteristic.currentRelativeHumidity())
    ])
    
    public init(info: Service.Info, additionalServices: [Service] = []) {
      super.init(info: info, type: .thermostat, services: [thermostat] + additionalServices)
    }
    
  }
  
  class ElectrifyLightSensor: Accessory {
    public let lightSensor = Service.LightSensor(characteristics: [
      AnyCharacteristic(PredefinedCharacteristic.statusFault())
    ])
    
    public init(info: Service.Info, additionalServices: [Service] = []) {
      super.init(info: info, type: .sensor, services: [lightSensor] + additionalServices)
    }
  }
  
}
