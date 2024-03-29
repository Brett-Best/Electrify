import Foundation
import Evergreen
import HAP
import SwiftyGPIO
import PythonKit
import Rainbow

#if os(Linux)
Rainbow.outputTarget = .console
#endif

let simpleFormatter = LogFormatter(style: .default)
let fullFormatter = LogFormatter(style: .full)
let consoleHandler = ConsoleHandler(formatter: simpleFormatter)
let fileHandler = FileHandler(fileURL: URL(fileURLWithPath: "electrify-logs.log"), formatter: fullFormatter)
Evergreen.defaultLogger.handlers = [ consoleHandler, fileHandler! ]

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
