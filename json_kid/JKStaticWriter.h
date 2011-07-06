//
//  JKStaticWriter.h
//  json_kid
//
//  Created by Noam Etzion-Rosenberg on 19/06/11.
//  Copyright 2011 PleasantLight. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "JKDefs.h"

@interface JKStaticWriter : NSObject

- (NSString*)createJsonObject:(NSDictionary*)dict;
- (NSString*)createJsonObject:(NSDictionary*)dict withDepth:(int)depth;

- (NSString*)createJsonArray:(NSArray*)arr;
- (NSString*)createJsonArray:(NSArray*)arr withDepth:(int)depth;

- (NSString*)getJsonStringForObject:(id)obj withDepth:(int)depth;

- (NSString*)escapeJsonString:(NSString*)str;

@end
