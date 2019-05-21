//
//  ElectrifyDeviceDelegate.swift
//  BigInt
//
//  Created by Brett Best on 20/5/19.
//

import HAP

class ElectrifyDeviceDelegate: DeviceDelegate {
  
  weak var thermostat: Service.Thermostat?
  
  func didRequestIdentificationOf(_ accessory: Accessory) {
    logger.verbose("Requested identification of accessory \(String(describing: accessory.info.name.value ?? ""))")
  }
  
  func characteristic<T>(_ characteristic: GenericCharacteristic<T>, ofService service: Service, ofAccessory accessory: Accessory, didChangeValue newValue: T?) {
    logger.verbose("Characteristic \(characteristic) in service \(service.type) of accessory \(accessory.info.name.value ?? "") did change: \(String(describing: newValue))")
    
    if let thermostat = thermostat {
      if service != thermostat {
        return
      }
      
      switch thermostat.targetHeatingCoolingState.value {
      case .some(.off):
        thermostat.currentHeatingCoolingState.value = .off
      case .some(.cool):
        thermostat.currentHeatingCoolingState.value = .cool
      case .some(.heat):
        thermostat.currentHeatingCoolingState.value = .heat
      case .some(.auto):
        thermostat.currentHeatingCoolingState.value = .off
        logger.critical("Unhandled auto heating/cooling state! Turning off!")
      default:
        break
      }
    }
  }
  
  func characteristicListenerDidSubscribe(_ accessory: Accessory, service: Service, characteristic: AnyCharacteristic) {
    logger.verbose("Characteristic \(characteristic) in service \(service.type) of accessory \(accessory.info.name.value ?? "") got a subscriber")
  }
  
  func characteristicListenerDidUnsubscribe(_ accessory: Accessory, service: Service, characteristic: AnyCharacteristic) {
    logger.verbose("Characteristic \(characteristic) in service \(service.type) of accessory \(accessory.info.name.value ?? "") lost a subscriber")
  }
  
}
