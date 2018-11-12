
#import <Foundation/Foundation.h>

@protocol XCTestManager_ManagerInterface;

/**
 Temporary class used to abstract interactions with TestManager daemon between Xcode 8.2.1 and Xcode 8.3-beta
 */
@interface XCTestDaemonsProxy : NSObject

+ (id<XCTestManager_ManagerInterface>)testRunnerProxy;

@end
