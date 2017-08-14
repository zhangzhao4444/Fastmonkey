
#import "XCTestDaemonsProxy.h"
#import "XCTestDriver.h"
#import "XCTRunnerDaemonSession.h"
#import <objc/runtime.h>

@implementation XCTestDaemonsProxy

+ (id<XCTestManager_ManagerInterface>)testRunnerProxy
{
  static id<XCTestManager_ManagerInterface> proxy = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    if ([[XCTestDriver sharedTestDriver] respondsToSelector:@selector(managerProxy)]) {
      proxy = [XCTestDriver sharedTestDriver].managerProxy;
      return;
    }
    Class runnerClass = objc_lookUpClass("XCTRunnerDaemonSession");
    proxy = ((XCTRunnerDaemonSession *)[runnerClass sharedSession]).daemonProxy;
  });
  NSAssert(proxy != NULL, @"Could not determin testRunnerProxy", proxy);
  return proxy;
}

@end
