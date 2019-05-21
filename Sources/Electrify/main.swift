import Foundation
import Evergreen
import HAP
import SwiftyGPIO
import PythonKit
import Rainbow

let simpleFormatter = LogFormatter(style: .default)
let consoleHandler = ConsoleHandler(formatter: simpleFormatter)
Evergreen.defaultLogger.handlers = [ consoleHandler ]

let logger = getLogger("electrify")

#if os(macOS)
import Darwin
#elseif os(Linux)
import Dispatch
import Glibc
#endif

getLogger("hap").logLevel = .debug
getLogger("hap.encryption").logLevel = .warning

do {
  let electrifySystem = try ElectrifySystem()
  
  if CommandLine.arguments.contains("--recreate") {
    logger.info("Dropping all pairings, keys")
    try electrifySystem.recreate()
  }
  
  SignalHandler.setup()
  
  withExtendedLifetime(electrifySystem) {
    if CommandLine.arguments.contains("--test") {
      print("Running runloop for 10 seconds...")
      RunLoop.main.run(until: Date(timeIntervalSinceNow: 10))
    } else {
      while SignalHandler.shouldKeepRunning {
        _ = RunLoop.current.run(mode: .default, before: Date.distantFuture)
      }
    }
  }
} catch {
  print(error)
}
