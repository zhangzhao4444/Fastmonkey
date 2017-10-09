//
//  XCTestWDApplication.h
//  XCTestWDUITests
//
//

#import "XCTestWDApplication.h"
#import "XCUIApplication.h"
#import "XCAXClient_iOS.h"

@implementation XCTestWDApplication

+(XCUIApplication*)activeApplication
{
    id activeApplicationElement = ((NSArray*)[[XCAXClient_iOS sharedClient] activeApplications]).lastObject;
    if(!activeApplicationElement){
        activeApplicationElement = ((XCAXClient_iOS*)[XCAXClient_iOS sharedClient]).systemApplication;
    }
    XCUIApplication* application = [XCTestWDApplication createByPID:[[activeApplicationElement valueForKey:@"processIdentifier"] intValue]];
    [application query];
    return application;
}

+(XCUIApplication*)createByPID:(pid_t)pid
{
    if([XCUIApplication respondsToSelector:@selector(appWithPID:)]){
        return [XCUIApplication appWithPID:pid];
    }
    return [XCUIApplication applicationWithPID:pid];
}

@end

