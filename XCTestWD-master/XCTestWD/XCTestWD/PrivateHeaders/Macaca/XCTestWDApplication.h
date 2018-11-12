//
//  XCTestWDApplication.h
//  XCTestWDUITests
//
//  Created by zhaoy on 24/9/17.
//  Copyright © 2017 XCTestWD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XCUIApplication.h"

@interface XCTestWDApplication : NSObject

+ (XCUIApplication*)activeApplication;

+ (XCUIApplication*)createByPID:(pid_t)pid;

@end
