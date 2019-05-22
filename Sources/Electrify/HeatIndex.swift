//
//  HeatIndex.swift
//  BigInt
//
//  Created by Brett Best on 22/5/19.
//

import Foundation

struct HeatIndex {
  
  private init() {}
  
  static func from(temperature: Float, relativeHumidity: Float) {
    let temperatureCelsius = Measurement(value: Double(temperature), unit: UnitTemperature.celsius)
  }
  
}
