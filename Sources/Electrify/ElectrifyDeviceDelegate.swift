//
//  ElectrifyDeviceDelegate.swift
//  BigInt
//
//  Created by Brett Best on 20/5/19.
//

import HAP

class ElectrifyDeviceDelegate: DeviceDelegate {
  
  weak var thermostat: Service.Thermostat?
  weak var heaterOutletAppliance: OutletAppliance?
  weak var coolerOutletAppliance: OutletAppliance?
  
  func didRequestIdentificationOf(_ accessory: Accessory) {
    logger.verbose("Requested identification of accessory \(String(describing: accessory.info.name.value ?? ""))")
  }
  
  func characteristic<T>(_ characteristic: GenericCharacteristic<T>, ofService service: Service, ofAccessory accessory: Accessory, didChangeValue newValue: T?) {
    logger.verbose("Characteristic \(characteristic) in service \(service.type) of accessory \(accessory.info.name.value ?? "") did change: \(String(describing: newValue))")
    
    if let thermostat = thermostat {
      if service != thermostat {
        return
      }
      
      if characteristic.type == thermostat.targetHeatingCoolingState.type {
        logger.debug("Handle thermostat target heating cooling state change.")
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
        
        updateOutlets()
      } else if thermostat.currentTemperature.type == characteristic.type {
        logger.debug("Handle current temperature change.")
        updateOutlets()
      } else if thermostat.targetTemperature.type == characteristic.type {
        logger.debug("Handle target temperature change.")
        updateOutlets()
      }
    }
  }
  
  func characteristicListenerDidSubscribe(_ accessory: Accessory, service: Service, characteristic: AnyCharacteristic) {
    logger.verbose("Characteristic \(characteristic) in service \(service.type) of accessory \(accessory.info.name.value ?? "") got a subscriber")
  }
  
  func characteristicListenerDidUnsubscribe(_ accessory: Accessory, service: Service, characteristic: AnyCharacteristic) {
    logger.verbose("Characteristic \(characteristic) in service \(service.type) of accessory \(accessory.info.name.value ?? "") lost a subscriber")
  }
  
  func updateOutlets() {
    if case .some(.off) = thermostat?.targetHeatingCoolingState.value {
      thermostat?.currentHeatingCoolingState.value = .off
      heaterOutletAppliance?.on = false
      coolerOutletAppliance?.on = false
    }
    
    guard let currentTemperature = thermostat?.currentTemperature.value, let targetTemperature = thermostat?.targetTemperature.value else {
      logger.error("Thermostat current temperature or target temperatur not set.")
      return
    }
    
    let threshold: Float = 0.5
    
    if case .some(.cool) = thermostat?.targetHeatingCoolingState.value {
      heaterOutletAppliance?.on = false
      
      // Current Temp: 20c
      // Target Temp: 20c
      // Cooling Threshold: 19.5c
      // 19.5c -> 20c
      
      if currentTemperature > targetTemperature {
        coolerOutletAppliance?.on = true
        thermostat?.currentHeatingCoolingState.value = .cool
      } else if currentTemperature <= targetTemperature - threshold {
        coolerOutletAppliance?.on = false
        thermostat?.currentHeatingCoolingState.value = .off
      }
    }
    
    if case .some(.heat) = thermostat?.targetHeatingCoolingState.value {
      coolerOutletAppliance?.on = false
      
      // Current Temp: 20c
      // Target Temp: 20c
      // Heating Threshold: 20.5c
      // 20c -> 20.5c
      
      if currentTemperature < targetTemperature {
        heaterOutletAppliance?.on = true
        thermostat?.currentHeatingCoolingState.value = .heat
      } else if currentTemperature >= targetTemperature + threshold {
        heaterOutletAppliance?.on = false
        thermostat?.currentHeatingCoolingState.value = .off
      }
    }
    
    if case .some(.auto) = thermostat?.targetHeatingCoolingState.value {
      
      // Current Temp: 20c
      // Target Temp: 20c
      // Cooling Threshold: 19.5c
      // Heating Threshold: 20.5c
      
      // Cool: 19.5c -> 20c
      // Heat: 20c -> 20.5c
      
    }
  }
  
}
