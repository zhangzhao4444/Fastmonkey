//
//  XCTestWDStatus.swift
//  XCTestWD
//
//  Created by zhaoy on 24/4/17.
//  Copyright © 2017 XCTestWD. All rights reserved.
//

import Foundation

enum WDStatus: Int {
    case
    Success    = 0,
    NoSuchElement   = 7,
    NoSuchFrame     = 8,
    UnknownCommand  = 9,
    StaleElementReference = 10,
    ElementNotVisible = 11,
    InvalidElementState = 12,
    UnknownError = 13,
    ElementIsNotSelectable = 15,
    JavaScriptError = 17,
    XPathLookupError = 19,
    Timeout = 21,
    NoSuchWindow = 23,
    InvalidCookieDomain = 24,
    UnableToSetCookie = 25,
    UnexpectedAlertOpen = 26,
    NoAlertOpenError = 27,
    ScriptTimeout = 28,
    InvalidElementCoordinates = 29,
    IMENotAvailable = 30,
    IMEEngineActivationFailed = 31,
    InvalidSelector = 32,
    SessionNotCreatedException = 33,
    MoveTargetOutOfBounds = 34
    
    static func evaluate(_ status:WDStatus) -> String {
        switch status {
        
        case .Success:
            return "The command executed successfully"
        
        case .NoSuchElement:
            return "An element could not be located on the page using the given search parameters."
        
        case .NoSuchFrame:
            return "A request to switch to a frame could not be satisfied because the frame could not be found."
        
        case .UnknownCommand:
            return "The requested resource could not be found, or a request was received using an HTTP method that is not supported by the mapped resource."
        
        case .StaleElementReference:
            return "An element command failed because the referenced element is no longer attached to the DOM."
        
        case .ElementNotVisible:
            return "An element command could not be completed because the element is not visible on the page."
            
        case .InvalidElementState:
            return "An element command could not be completed because the element is in an invalid state (e.g. attempting to click a disabled element)."
            
        case .UnknownError:
            return "An unknown server-side error occurred while processing the command."
            
        case .ElementIsNotSelectable:
            return "An attempt was made to select an element that cannot be selected."
            
        case .JavaScriptError:
            return "An error occurred while executing user supplied JavaScript."
            
        case .XPathLookupError:
            return "An error occurred while searching for an element by XPath."
            
        case .Timeout:
            return "An operation did not complete before its timeout expired."
            
        case .NoSuchWindow:
            return "A request to switch to a different window could not be satisfied because the window could not be found."
            
        case .InvalidCookieDomain:
            return "An illegal attempt was made to set a cookie under a different domain than the current page."
            
        case .UnableToSetCookie:
            return "A request to set a cookie's value could not be satisfied."
            
        case .UnexpectedAlertOpen:
            return "A modal dialog was open, blocking this operation."
            
        case .NoAlertOpenError:
            return "An attempt was made to operate on a modal dialog when one was not open."
            
        case .ScriptTimeout:
            return "A script did not complete before its timeout expired."
            
        case .InvalidElementCoordinates:
            return "The coordinates provided to an interactions operation are invalid."
            
        case .IMENotAvailable:
            return "IME was not available."
            
        case .IMEEngineActivationFailed:
            return "An IME engine could not be started."
        
        case .InvalidSelector:
            return "Argument was an invalid selector (e.g. XPath/CSS)."
            
        case .SessionNotCreatedException:
            return "Session Not Created Exception"
            
        case .MoveTargetOutOfBounds:
            return "Move Target Out Of Bounds"
        }
    }
}
