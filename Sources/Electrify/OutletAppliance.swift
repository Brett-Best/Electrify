//
//  OutletAppliance.swift
//  BigInt
//
//  Created by Brett Best on 23/5/19.
//

protocol OutletAppliance: class {
  var on: Bool { get set }
  var totalOnTime: Float { get }
}

#if os(macOS)

extension OutletAppliance {
  
  var on: Bool {
    get {
      return true
    }
    
    set {
      
    }
  }
  
}

#endif
