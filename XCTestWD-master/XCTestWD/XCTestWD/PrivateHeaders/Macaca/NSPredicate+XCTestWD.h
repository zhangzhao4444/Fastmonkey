//
//  NSPredicate+XCTestWD.h
//  XCTestWD
//
//  Created by SamuelZhaoY on 18/8/18.
//  Copyright © 2018 XCTestWD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSPredicate (XCTestWD)

// utility method for providing xctestwd predicates
+ (instancetype)xctestWDPredicateWithFormat:(NSString *)predicateFormat;

+ (instancetype)xctestWDformatSearchPredicate:(NSPredicate *)input;

@end
