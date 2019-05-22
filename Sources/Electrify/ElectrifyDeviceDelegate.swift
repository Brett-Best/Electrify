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
    
    let canCool = .some(.auto) == thermostat?.targetHeatingCoolingState.value || .some(.cool) == thermostat?.targetHeatingCoolingState.value
    let shouldCool = currentTemperature > targetTemperature + threshold
    
    if canCool && shouldCool {
      coolerOutletAppliance?.on = true
      heaterOutletAppliance?.on = false
      thermostat?.currentHeatingCoolingState.value = .cool
    }
    
    let canHeat = .some(.auto) == thermostat?.targetHeatingCoolingState.value || .some(.heat) == thermostat?.targetHeatingCoolingState.value
    let shouldHeat = currentTemperature < targetTemperature - threshold
    
    if canHeat && shouldHeat  {
      coolerOutletAppliance?.on = false
      heaterOutletAppliance?.on = true
      thermostat?.currentHeatingCoolingState.value = .heat
    }
    
    let isCooling = .some(.cool) == thermostat?.currentHeatingCoolingState.value
    let shouldStopCooling = currentTemperature <= targetTemperature
    
    if isCooling && shouldStopCooling {
      coolerOutletAppliance?.on = false
      thermostat?.currentHeatingCoolingState.value = .off
    }
    
    let isHeating = .some(.heat) == thermostat?.currentHeatingCoolingState.value
    let shouldStopHeating = currentTemperature >= targetTemperature
    
    if isHeating && shouldStopHeating {
      heaterOutletAppliance?.on = false
      thermostat?.currentHeatingCoolingState.value = .off
    }
    
  }
  
}
