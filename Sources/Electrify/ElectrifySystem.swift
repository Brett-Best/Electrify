//
//  ElectrifySystem.swift
//  BigInt
//
//  Created by Brett Best on 20/5/19.
//

import Foundation
import HAP

class ElectrifySystem {
  
  let server: Server
  let storage = FileStorage(filename: "configuration.json")
  
  let electrifyDevice: Device
  let thermostat: Accessory.ElectrifyThermostat
  let lightSensor: Accessory.LightSensor
  let heatIndexSwitch: Accessory.Switch
  
  let heater = HeaterOutletAppliance()
  let cooler = CoolerOutletAppliance()
  
  let environmentMonitor = EnvironmentMonitor()
  let powerConsumptionMonitor = PowerConsumptionMonitor()
  
  let delegate = ElectrifyDeviceDelegate()
  
  init() throws {
    let lightSensorInfo = Service.Info(name: "Light Sensor", serialNumber: "9C0D5355-F83A-4202-A590-D383EA42E5EC", manufacturer: ElectrifyInfo.manufacturer, model: ElectrifyInfo.model, firmwareRevision: ElectrifyInfo.firmwareRevision)
    lightSensor = Accessory.LightSensor(info: lightSensorInfo)
    
    let thermostatInfo = Service.Info(name: "Thermostat", serialNumber: "134940CB-046A-4AEE-8363-B45E644C1D1F", manufacturer: ElectrifyInfo.manufacturer, model: ElectrifyInfo.model, firmwareRevision: ElectrifyInfo.firmwareRevision)
    thermostat = Accessory.ElectrifyThermostat(info: thermostatInfo)
    delegate.thermostat = thermostat.thermostat
    
    let heatIndexSwitchInfo = Service.Info(name: "Heat Index", serialNumber: "6481A258-518A-4C8C-8811-C6D431FD18FF", manufacturer: ElectrifyInfo.manufacturer, model: ElectrifyInfo.model, firmwareRevision: ElectrifyInfo.firmwareRevision)
    heatIndexSwitch = Accessory.Switch(info: heatIndexSwitchInfo)
    heatIndexSwitch.switch.powerState.value = false
    
    let electrifyDeviceInfo = Service.Info(name: "Electrify", serialNumber: "EA4F9D37-FD45-4C9A-B033-53FC74A1642C", manufacturer: ElectrifyInfo.manufacturer, model: ElectrifyInfo.model, firmwareRevision: ElectrifyInfo.firmwareRevision)
    electrifyDevice = Device(bridgeInfo: electrifyDeviceInfo, setupCode: "123-44-321", storage: storage, accessories: [thermostat, lightSensor, heatIndexSwitch])
    electrifyDevice.delegate = delegate
    
    delegate.coolerOutletAppliance = cooler
    delegate.heaterOutletAppliance = heater
    delegate.lightSensor = lightSensor.lightSensor
    
    powerConsumptionMonitor.coolerOutletAppliance = cooler
    powerConsumptionMonitor.heaterOutletAppliance = heater
    powerConsumptionMonitor.thermostat = thermostat
    
    logger.info("Initialising server...")
    
    lightSensor.lightSensor.currentLightLevel.value = 1
    
    thermostat.thermostat.currentHeatingCoolingState.value = .off
    thermostat.thermostat.targetHeatingCoolingState.value = .off
    thermostat.thermostat.currentTemperature.value = 0
    thermostat.thermostat.targetTemperature.value = 0
    thermostat.thermostat.temperatureDisplayUnits.value = .celcius
    thermostat.thermostat.currentRelativeHumidity?.value = 0
    
    server = try Server(device: electrifyDevice, listenPort: 8000, numberOfThreads: 1)
    
    environmentMonitor.delegate = self
  }
  
  func recreate() throws {
    try storage.write(Data())
  }
  
}

extension ElectrifySystem: EnvironmentMonitorDelegate {
  
  func environmentMonitor(_ monitor: EnvironmentMonitor, updatedTemperature temperature: Float) {
    if let useHeatIndex = heatIndexSwitch.switch.powerState.value, useHeatIndex, let relativeHumidity = thermostat.thermostat.currentRelativeHumidity?.value, let heatIndex = HeatIndex.from(temperature: temperature, relativeHumidity: relativeHumidity) {
      thermostat.thermostat.currentTemperature.value = heatIndex
      logger.verbose("Temperature updated to heat index: \(heatIndex)")
    } else {
      thermostat.thermostat.currentTemperature.value = temperature
      logger.verbose("Temperature updated: \(temperature)")
    }
  }
  
  func environmentMonitor(_ monitor: EnvironmentMonitor, updatedRelativeHumidity relativeHumidity: Float) {
    guard let currentRelativeHumidity = thermostat.thermostat.currentRelativeHumidity else {
      logger.error("Current Relative Humidity is nil")
      return
    }
    
    currentRelativeHumidity.value = relativeHumidity
    logger.verbose("Current Relative Humidity updated: \(relativeHumidity)")
  }
  
  func environmentMonitor(_ monitor: EnvironmentMonitor, updatedLumens lumens: Float?) {
    guard let lumens = lumens else {
      lightSensor.lightSensor.currentLightLevel.value = 1.0
      logger.verbose("Current Light Level set to 1.0 as sensor isn't reporting correct values")
      return
    }
    
    lightSensor.lightSensor.currentLightLevel.value = lumens
    logger.verbose("Current Light Level updated: \(lumens)")
  }
  
}
