//
//  ErrorLogManager.swift
//  WalmartTakeHomeAssingment
//
//  Created by Wayne Ohmer on 12/14/18.
//  Copyright © 2018 Wayne Ohmer. All rights reserved.
//

import UIKit

protocol ErrorLogger {
    func log(errorMessage: String)
}

//A logging sytem using Dependency Injection.
//RemoteServiceLogger is for production. It saves to a remote service.
//Use ConsoleLogger for Debug. It prints messages to the console.
//Use UnitTestLogger for unit tests. It saves the last message for processing.

class ErrorLogManager {
    
    let errorLogger: ErrorLogger
    
    init(errorLogger: ErrorLogger) {
        self.errorLogger = errorLogger
    }
    
    func log(errorMessage: String) {
        self.errorLogger.log(errorMessage: errorMessage)
    }
}

class RemoteServiceLogger: ErrorLogger {
    
    func log(errorMessage: String) {
        //send messgae to remote logging serive. Only for production
    }

}

class ConsoleLogger: ErrorLogger {
    
    func log(errorMessage: String) {
        //This will only get used in DEBUG mode
        print(errorMessage)
    }
    
}

class UnitTestLogger: ErrorLogger {
    
    //Save message so it can be checked in unit test.
    var lastMessage = ""
    
    func log(errorMessage: String) {
        self.lastMessage = errorMessage
    }
}
