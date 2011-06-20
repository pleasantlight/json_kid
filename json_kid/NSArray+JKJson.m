//
//  NSArray+JKJson.m
//  json_kid
//
//  Created by Noam Etzion-Rosenberg on 19/06/11.
//  Copyright 2011 PleasantLight. All rights reserved.
//

#import "NSArray+JKJson.h"
#import "JKStaticWriter.h"

@implementation NSArray (JKJson)

- (NSString*)toJsonString {
    JKStaticWriter* writer = [[JKStaticWriter alloc] init];
    return [writer createJsonArray:self];
}

@end
