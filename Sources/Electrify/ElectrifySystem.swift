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
  
  let environmentMonitor = EnvironmentMonitor()
  
  let delegate = ElectrifyDeviceDelegate()
  
  init() throws {
    let lightSensorInfo = Service.Info(name: "Living Room", serialNumber: "9C0D5355-F83A-4202-A590-D383EA42E5EC", manufacturer: ElectrifyInfo.manufacturer, model: ElectrifyInfo.model, firmwareRevision: ElectrifyInfo.firmwareRevision)
    lightSensor = Accessory.LightSensor(info: lightSensorInfo)
    
    let thermostatInfo = Service.Info(name: "Living Room", serialNumber: "134940CB-046A-4AEE-8363-B45E644C1D1F", manufacturer: ElectrifyInfo.manufacturer, model: ElectrifyInfo.model, firmwareRevision: ElectrifyInfo.firmwareRevision)
    thermostat = Accessory.ElectrifyThermostat(info: thermostatInfo)
    delegate.thermostat = thermostat.thermostat
    
    thermostat.thermostat.currentHeatingCoolingState.value = .heat
    thermostat.thermostat.targetHeatingCoolingState.value = .heat
    thermostat.thermostat.currentTemperature.value = 20
    
    let electrifyDeviceInfo = Service.Info(name: "Electrify Bridge", serialNumber: "EA4F9D37-FD45-4C9A-B033-53FC74A1642C", manufacturer: ElectrifyInfo.manufacturer, model: ElectrifyInfo.model, firmwareRevision: ElectrifyInfo.firmwareRevision)
    electrifyDevice = Device(bridgeInfo: electrifyDeviceInfo, setupCode: "123-44-321", storage: storage, accessories: [thermostat, lightSensor])
    electrifyDevice.delegate = delegate
    
    logger.info("Initialising server...")
    
    server = try Server(device: electrifyDevice, listenPort: 8000, numberOfThreads: 1)
    
    environmentMonitor.delegate = self
  }
  
  func recreate() throws {
    try storage.write(Data())
  }
  
}

extension ElectrifySystem: EnvironmentMonitorDelegate {
  
  func environmentMonitor(_ monitor: EnvironmentMonitor, updatedTemperature temperature: Float) {
    thermostat.thermostat.currentTemperature.value = temperature
    logger.verbose("Temperature updated: \(temperature)")
  }
  
  func environmentMonitor(_ monitor: EnvironmentMonitor, updatedRelativeHumidity relativeHumidity: Float) {
    guard let currentRelativeHumidity = thermostat.thermostat.currentRelativeHumidity else {
      logger.error("Current Relative Humidity is nil")
      return
    }
    
    currentRelativeHumidity.value = relativeHumidity
    logger.verbose("Current Relative Humidity updated: \(currentRelativeHumidity)")
  }
  
  func environmentMonitor(_ monitor: EnvironmentMonitor, updatedLumens lumens: Float) {
    lightSensor.lightSensor.currentLightLevel.value = lumens
    logger.verbose("Current Light Level updated: \(lumens)")
  }
  
}
