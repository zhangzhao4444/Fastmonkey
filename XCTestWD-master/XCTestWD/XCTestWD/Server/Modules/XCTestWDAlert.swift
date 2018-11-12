//
//  XCTestWDAlert.swift
//  XCTestWD
//
//  Created by zhaoy on 27/4/17.
//  Copyright © 2017 XCTestWD. All rights reserved.
//

import Foundation

internal class XCTestWDAlert {

    private let application:XCUIApplication!
    
    init(_ application:XCUIApplication) {
        self.application = application
    }
    
    //MARK: Commands
    
    //TODO: works on XPATH and then works on getting text
    internal func text() -> String? {
    
        let alertElement = self.alertElement()
        if alertElement != nil {
            return nil
        }
        
        return nil
    }
    //TODO: works on XPATH and then works on getting this
    internal func keys(input: String) -> Bool {
        
        return false
    }
    
    internal func accept() -> Bool {
        
        let alertElement = self.alertElement()
        let buttons = self.alertElement()?.descendants(matching: XCUIElement.ElementType.button).allElementsBoundByIndex
        var defaultButton:XCUIElement?
        
        if alertElement?.elementType == XCUIElement.ElementType.alert {
            defaultButton = (buttons?.last)
        } else {
            defaultButton = (buttons?.first)
        }
        
        if defaultButton != nil {
            defaultButton?.tap()
            return true
        }
        
        return false
    }
    
    internal func dismiss() -> Bool {
    
        let alertElement = self.alertElement()
        let buttons = self.alertElement()?.descendants(matching: XCUIElement.ElementType.button).allElementsBoundByIndex
        var defaultButton:XCUIElement?
        
        if alertElement?.elementType == XCUIElement.ElementType.alert {
            defaultButton = (buttons?.first)
        } else {
            defaultButton = (buttons?.last)
        }
        
        if defaultButton != nil {
            defaultButton?.tap()
            return true
        }
        
        return false
    }
    
    //MARK: Utils
    private func alertElement() -> XCUIElement? {
        var alert =  self.application.alerts.element
        // Check default alerts exists
        if !(alert.exists) {
            alert = self.application.sheets.element
            // Check actionsheet exists
            if !(alert.exists) {
               let sprintboard = XCUIApplication.init(privateWithPath: nil, bundleID: "com.apple.springboard")
               alert = (sprintboard?.alerts.element) ?? alert
                if !(alert.exists) {
                    return nil
                }
            }
        }
        
        alert.resolve()
        self.application.query()
        self.application.resolve()
        return alert
    }
}
