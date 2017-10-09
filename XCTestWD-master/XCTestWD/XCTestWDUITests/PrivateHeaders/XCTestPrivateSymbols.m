/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "XCTestPrivateSymbols.h"

#import "XCRuntimeUtils.h"

NSNumber *XCAXAIsVisibleAttribute;
NSNumber *XCAXAIsElementAttribute;

void (*XCSetDebugLogger)(id <XCDebugLogDelegate>);
id<XCDebugLogDelegate> (*XCDebugLogger)(void);

__attribute__((constructor)) void LoadXCTestSymbols(void)
{
  NSString *XC_kAXXCAttributeIsVisible = *(NSString*__autoreleasing*)RetrieveXCTestSymbol("XC_kAXXCAttributeIsVisible");
  NSString *XC_kAXXCAttributeIsElement = *(NSString*__autoreleasing*)RetrieveXCTestSymbol("XC_kAXXCAttributeIsElement");

  NSArray *(*XCAXAccessibilityAttributesForStringAttributes)(NSArray *list) =
  (NSArray<NSNumber *> *(*)(NSArray *))RetrieveXCTestSymbol("XCAXAccessibilityAttributesForStringAttributes");

  XCSetDebugLogger = (void (*)(id <XCDebugLogDelegate>))RetrieveXCTestSymbol("XCSetDebugLogger");
  XCDebugLogger = (id<XCDebugLogDelegate>(*)(void))RetrieveXCTestSymbol("XCDebugLogger");

  NSArray<NSNumber *> *accessibilityAttributes = XCAXAccessibilityAttributesForStringAttributes(@[XC_kAXXCAttributeIsVisible, XC_kAXXCAttributeIsElement]);
  XCAXAIsVisibleAttribute = accessibilityAttributes[0];
  XCAXAIsElementAttribute = accessibilityAttributes[1];

  NSCAssert(XCAXAIsVisibleAttribute != nil , @"Failed to retrieve FB_XCAXAIsVisibleAttribute", XCAXAIsVisibleAttribute);
  NSCAssert(XCAXAIsElementAttribute != nil , @"Failed to retrieve FB_XCAXAIsElementAttribute", XCAXAIsElementAttribute);
}

void *RetrieveXCTestSymbol(const char *name)
{
  Class XCTestClass = NSClassFromString(@"XCTestCase");
  NSCAssert(XCTestClass != nil, @"XCTest should be already linked", XCTestClass);
  NSString *XCTestBinary = [NSBundle bundleForClass:XCTestClass].executablePath;
  const char *binaryPath = XCTestBinary.UTF8String;
  NSCAssert(binaryPath != nil, @"XCTest binary path should not be nil", binaryPath);
  return FBRetrieveSymbolFromBinary(binaryPath, name);
}

int portNumber()
{
    return XCTESTWD_PORT;
}
