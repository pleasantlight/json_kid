//
//  NSDictionary+JKJson.m
//  json_kid
//
//  Created by Noam Etzion-Rosenberg on 19/06/11.
//  Copyright 2011 PleasantLight. All rights reserved.
//

#import "NSDictionary+JKJson.h"
#import "JKStaticWriter.h"

@implementation NSDictionary (JKJson)

- (NSString*)toJsonString {
    JKStaticWriter* writer = [[JKStaticWriter alloc] init];
    return [writer createJsonObject:self];
}

@end
