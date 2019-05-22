//
//  HeatIndex.swift
//  BigInt
//
//  Created by Brett Best on 22/5/19.
//

import Foundation

struct HeatIndex {
  
  private init() {}
  
  static func from(temperature: Float, relativeHumidity rhFloat: Float) -> Float? {
    if !(21...46).contains(temperature) || !(0...80).contains(rhFloat) {
      return nil // Formula only works between 21c -> 46c and relative humidity 0% -> 80%
    }
    
    let temperatureCelsius = Measurement(value: Double(temperature), unit: UnitTemperature.celsius)
    let temperatureFarenheit = temperatureCelsius.converted(to: .fahrenheit).value
    
    let relativeHumidity = Double(rhFloat)
    
    let c1: Double = 0.363_445_176
    let c2: Double = 0.988_622_465
    let c3: Double = 4.777_114_035
    let c4: Double = -0.114_037_667
    let c5: Double = -8.502_08 * pow(10.0, -4.0)
    let c6: Double = -2.071_6198 * pow(10.0, -2.0)
    let c7: Double = 6.876_78 * pow(10.0, -4.0)
    let c8: Double = 2.749_54 * pow(10.0, -4.0)
    let c9: Double = 0.0
  
    // Formula is from https://en.wikipedia.org/wiki/Heat_index.
    
    let heatIndexFarenheit: Double = c1 +
      c2*temperatureFarenheit +
      c3*relativeHumidity +
      c4*temperatureFarenheit*relativeHumidity +
      c5*pow(temperatureFarenheit, 2) +
      c6*pow(relativeHumidity, 2) +
      c7*pow(temperatureFarenheit, 2)*relativeHumidity +
      c8*temperatureFarenheit*pow(relativeHumidity, 2) +
      c9*pow(temperatureFarenheit, 2)*pow(relativeHumidity, 2)
    
    return Float(Measurement(value: heatIndexFarenheit, unit: UnitTemperature.fahrenheit).converted(to: .celsius).value)
  }
  
}
