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

//Dependency Injection.
//Use RemoteServiceLogger for production.
//Use ConsoleLogger for Debug.
//Use UnitTestLogger for unit tests.

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
        //This will only get used in DEBG mode
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
