//
//  PredefinedCharacterisitic+Elecrtify.swift
//  Electrify
//
//  Created by Brett Best on 22/5/19.
//

import HAP

extension PredefinedCharacteristic {
  
  // Copied from `HAP/HAP/Base/Generated.swift`, forking the library and making these methods public is probably a better solution.
  static func currentRelativeHumidity(
    _ value: Float = 0,
    permissions: [CharacteristicPermission] = [.read, .events],
    description: String? = "Current Relative Humidity",
    format: CharacteristicFormat? = .float,
    unit: CharacteristicUnit? = .percentage,
    maxLength: Int? = nil,
    maxValue: Double? = 100,
    minValue: Double? = 0,
    minStep: Double? = 1
    ) -> GenericCharacteristic<Float> {
    return GenericCharacteristic<Float>(
      type: .currentRelativeHumidity,
      value: value,
      permissions: permissions,
      description: description,
      format: format,
      unit: unit,
      maxLength: maxLength,
      maxValue: maxValue,
      minValue: minValue,
      minStep: minStep)
  }
  
  static func statusFault(
    _ value: UInt8 = 0,
    permissions: [CharacteristicPermission] = [.read, .events],
    description: String? = "Status Fault",
    format: CharacteristicFormat? = .uint8,
    unit: CharacteristicUnit? = nil,
    maxLength: Int? = nil,
    maxValue: Double? = 1,
    minValue: Double? = 0,
    minStep: Double? = 1
    ) -> GenericCharacteristic<UInt8> {
    return GenericCharacteristic<UInt8>(
      type: .statusFault,
      value: value,
      permissions: permissions,
      description: description,
      format: format,
      unit: unit,
      maxLength: maxLength,
      maxValue: maxValue,
      minValue: minValue,
      minStep: minStep)
  }
  
  static func statusActive(
    _ value: Bool = false,
    permissions: [CharacteristicPermission] = [.read, .events],
    description: String? = "Status Active",
    format: CharacteristicFormat? = .bool,
    unit: CharacteristicUnit? = nil,
    maxLength: Int? = nil,
    maxValue: Double? = nil,
    minValue: Double? = nil,
    minStep: Double? = nil
    ) -> GenericCharacteristic<Bool> {
    return GenericCharacteristic<Bool>(
      type: .statusActive,
      value: value,
      permissions: permissions,
      description: description,
      format: format,
      unit: unit,
      maxLength: maxLength,
      maxValue: maxValue,
      minValue: minValue,
      minStep: minStep)
  }
  
}
