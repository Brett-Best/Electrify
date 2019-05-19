//
//  ElectrifyDeviceDelegate.swift
//  BigInt
//
//  Created by Brett Best on 20/5/19.
//

import HAP

class ElectrifyDeviceDelegate: DeviceDelegate {
  
  func didRequestIdentificationOf(_ accessory: Accessory) {
    logger.info("Requested identification of accessory \(String(describing: accessory.info.name.value ?? ""))")
  }
  
  func characteristic<T>(_ characteristic: GenericCharacteristic<T>, ofService service: Service, ofAccessory accessory: Accessory, didChangeValue newValue: T?) {
    logger.info("Characteristic \(characteristic) in service \(service.type) of accessory \(accessory.info.name.value ?? "") did change: \(String(describing: newValue))")
  }
  
  func characteristicListenerDidSubscribe(_ accessory: Accessory, service: Service, characteristic: AnyCharacteristic) {
    logger.info("Characteristic \(characteristic) in service \(service.type) of accessory \(accessory.info.name.value ?? "") got a subscriber")
  }
  
  func characteristicListenerDidUnsubscribe(_ accessory: Accessory, service: Service, characteristic: AnyCharacteristic) {
    logger.info("Characteristic \(characteristic) in service \(service.type) of accessory \(accessory.info.name.value ?? "") lost a subscriber")
  }
  
}
