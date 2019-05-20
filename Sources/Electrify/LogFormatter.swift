//
//  LogFormatter.swift
//  Electrify
//
//  Created by Brett Best on 20/5/19.
//

import Evergreen
import Rainbow

class LogFormatter: Formatter {
  
  override func string<M>(from event: Event<M>) -> String {
    let string = super.string(from: event)
    
    guard let eventLogLevel = event.logLevel else {
      return string
    }
    
    switch eventLogLevel {
    case .verbose:
      return string.applyingColor(.cyan).dim
    case .debug:
      return string.applyingColor(.lightCyan).dim
    case .info:
      return string.applyingColor(.green)
    case .warning:
      return string.applyingColor(.yellow)
    case .error:
      return string.applyingColor(.red).italic
    case .critical:
      return string.applyingColor(.lightRed).bold
    default:
      return string
    }
  }
  
}
