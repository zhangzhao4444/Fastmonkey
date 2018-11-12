//
//  XCTestWDImplementationFailureHoldingProxy.m
//  XCTestWD
//
//  Created by SamuelZhaoY on 3/10/18.
//  Copyright © 2018 XCTestWD. All rights reserved.
//

#import "XCTestWDImplementationFailureHoldingProxy.h"
#import "_XCTestCaseImplementation.h"

@interface XCTestWDImplementationFailureHoldingProxy()

@property (nonatomic, strong) _XCTestCaseImplementation *internalImplementation;

@end

@implementation XCTestWDImplementationFailureHoldingProxy

+ (_XCTestCaseImplementation *)proxyWithXCTestCaseImplementation:(_XCTestCaseImplementation *)internalImplementation
{
    XCTestWDImplementationFailureHoldingProxy *proxy = [super alloc];
    proxy.internalImplementation = internalImplementation;
    return (_XCTestCaseImplementation *)proxy;
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    return self.internalImplementation;
}

// This will prevent test from quiting on app crash or any other test failure
- (BOOL)shouldHaltWhenReceivesControl
{
    return NO;
}

@end
