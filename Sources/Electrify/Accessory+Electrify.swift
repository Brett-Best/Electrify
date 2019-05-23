//
//  Accessory+Electrify.swift
//  BigInt
//
//  Created by Brett Best on 22/5/19.
//

import Foundation
import HAP

extension Accessory {
  
  class ElectrifyThermostat: Accessory {
    let heaterOnTimeCharateristic = GenericCharacteristic<UInt32>.init(type: .custom(UUID(uuidString: "D57299ED-0172-4AA0-93B5-CEBB990CEB38")!), value: 0, permissions: [.read, .events], description: "Heating Duration", format: CharacteristicFormat.uint32, unit: .seconds, maxLength: nil, maxValue: nil, minValue: nil, minStep: nil)
    let coolerOnTimeCharateristic = GenericCharacteristic<UInt32>.init(type: .custom(UUID(uuidString: "87EA4B89-5CA1-402A-A230-BE22768F14D5")!), value: 0, permissions: [.read, .events], description: "Cooling Duration", format: CharacteristicFormat.uint32, unit: .seconds, maxLength: nil, maxValue: nil, minValue: nil, minStep: nil)
    
    public let thermostat: Service.Thermostat
    
    public init(info: Service.Info, additionalServices: [Service] = []) {
      thermostat = Service.Thermostat(characteristics: [
        AnyCharacteristic(PredefinedCharacteristic.currentRelativeHumidity()),
        AnyCharacteristic(heaterOnTimeCharateristic),
        AnyCharacteristic(coolerOnTimeCharateristic)
      ])
      
      super.init(info: info, type: .thermostat, services: [thermostat] + additionalServices)
    }
    
  }
  
}
