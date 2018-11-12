//
//  XCTestWD.h
//  XCTestWD
//
//  Created by zhaoy on 22/02/2018.
//  Copyright © 2018 XCTestWD. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for XCTestWD.
FOUNDATION_EXPORT double XCTestWDVersionNumber;

//! Project version string for XCTestWD.
FOUNDATION_EXPORT const unsigned char XCTestWDVersionString[];

//! Export debug level
#define LOG_LEVEL_DEF ddLogLevel

// In this header, you should import all the public headers of your framework using statements like #import <XCTestWD/PublicHeader.h>

#import <XCTestWD/CDStructures.h>
#import <XCTestWD/XCUIElementQuery.h>
#import <XCTestWD/XCUIElement.h>
#import <XCTestWD/XCElementSnapshot.h>
#import <XCTestWD/XCAXClient_iOS.h>
#import <XCTestWD/XCUIApplication.h>
#import <XCTestWD/XCTestWDApplication.h>
#import <XCTestWD/XCTestPrivateSymbols.h>
#import <XCTestWD/XCUICoordinate.h>
#import <XCTestWD/XCTestDriver.h>
#import <XCTestWD/XCTestDaemonsProxy.h>
#import <XCTestWD/XCTRunnerDaemonSession.h>
#import <XCTestWD/XCRuntimeUtils.h>
#import <XCTestWD/NSPredicate+XCTestWD.h>
#import <XCTestWD/_XCTestCaseImplementation.h>
#import <XCTestWD/XCTestCase.h>
#import <XCTestWD/XCTestWDImplementationFailureHoldingProxy.h>
