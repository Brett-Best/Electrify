//
//  SignalHandler.swift
//  BigInt
//
//  Created by Brett Best on 20/5/19.
//

import Foundation

class SignalHandler {
  
  static let shared = SignalHandler()
  private(set) static var shouldKeepRunning = true
  
  weak var electrifySystem: ElectrifySystem?
  
  private init() {}

  static func setup() {
    signal(SIGINT) { _ in SignalHandler.stop() }
    signal(SIGTERM) { _ in SignalHandler.stop() }
  }
  
  static func stop() {
    DispatchQueue.main.async {
      logger.info("Shutting down...")
      shouldKeepRunning = false
      
      do {
        try shared.electrifySystem?.server.stop()
      } catch {
        logger.critical("Failed to stop electrify system server!", error: error)
      }
      
      logger.info("Stopped")
    }
  }
  
}
