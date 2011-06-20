//
//  JKStaticWriter.m
//  json_kid
//
//  Created by Noam Etzion-Rosenberg on 19/06/11.
//  Copyright 2011 PleasantLight. All rights reserved.
//

#import "JKStaticWriter.h"

@implementation JKStaticWriter

- (id)init
{
    self = [super init];
    if (self) {
    }
    
    return self;
}

- (NSString*)createJsonObject:(NSDictionary*)dict {
    return [self createJsonObject:dict withDepth:0];
}

// Convert an NSDictionary to a string that represents a JSON object.
// dict -   The NSDictionary object that will be used to create the JSON object string.
// depth -  Internal.
- (NSString*)createJsonObject:(NSDictionary*)dict withDepth:(int)depth {
    // Create the indentation string:
    NSMutableString* indent = [NSString stringWithString:@""];
    for (int i=0; i<depth; ++i)
        [indent appendString:@"    "];
    
    NSMutableString* jsonObject = [NSString stringWithFormat:@"%@{ ", indent];
    
    BOOL firstKey = YES;
    for(id key in dict) {
        NSString* keyClassName = [NSString stringWithUTF8String:class_getName([key class])];
        if ([keyClassName isEqualToString:@"NSString"] == false) {
            // Not a valid class for a key..
            continue;
        }
        
        NSString* objString = [self getJsonStringForObject:[dict objectForKey:key] withDepth:depth];        
        if ([objString isEqualToString:@""] == NO) {
            NSString* prefix = @"\n";
            if (firstKey == YES) {
                firstKey = NO;
            }
            else {
                prefix = @",\n";
            }

            NSString* keyObjString = [NSString stringWithFormat:@"%@%@    %@: %@", prefix, indent, (NSString*)(key), objString];
            [jsonObject appendString:keyObjString];
        }
    }

    [jsonObject appendFormat:@"\n%@}", indent];
        
    return jsonObject;
}

// Convert an NSArray to a string that represents a JSON array.
- (NSString*)createJsonArray:(NSArray*)arr {
    return [self createJsonArray:arr withDepth:0];
}

// Convert an NSArray to a string that represents a JSON array.
// arr -    The NSArray object that will be used to create the JSON array string.
// depth -  Internal.
- (NSString*)createJsonArray:(NSArray*)arr withDepth:(int)depth {
    // Create the indentation string:
    NSMutableString* indent = [NSString stringWithString:@""];
    for (int i=0; i<depth; ++i)
        [indent appendString:@"    "];
    
    NSMutableString* jsonObject = [NSString stringWithFormat:@"%@[ ", indent];
    
    BOOL firstKey = YES;
    for(id obj in arr) {
        NSString* objString = [self getJsonStringForObject:obj withDepth:depth];
        if ([objString isEqualToString:@""] == NO) {
            NSString* prefix = @"\n";
            if (firstKey == YES) {
                firstKey = NO;
            }
            else {
                prefix = @",\n";
            }
            
            NSString* keyObjString = [NSString stringWithFormat:@"%@%@    %@", prefix, indent, objString];
            [jsonObject appendString:keyObjString];
        }
    }
    
    [jsonObject appendFormat:@"\n%@]", indent];
    
    return jsonObject;
}

- (NSString*)getJsonStringForObject:(id)obj withDepth:(int)depth {
    NSString* objString = @"";
    
    // The object is allowed to be one of the following:
    // 1. An NSDictionary (will be interpreted as an embedded JSON object).
    // 2. An NSArray (will be interpreted as an embedded JSON array).
    // 3. A string (NSString).
    // 4. A number (NSNumber).
    // 5. A constant (true, false or null) (JKConstant).
    NSString* objClassName = [NSString stringWithUTF8String:class_getName([obj class])];
    if ([objClassName isEqualToString:@"NSDictionary"] || [objClassName isEqualToString:@"NSMutableDictionary"]) {
        // Get the JSON string that represents this dictionary.
        objString = [NSString stringWithFormat:@"\n%@", [self createJsonObject:(NSDictionary*)(obj) withDepth:depth + 1]];
    } else if ([objClassName isEqualToString:@"NSArray"] || [objClassName isEqualToString:@"NSMutableArray"]) {
        // Get the JSON string that represents this array.
        objString = [NSString stringWithFormat:@"\n%@", [self createJsonArray:(NSArray*)(obj) withDepth:depth + 1]];
    } else if ([objClassName isEqualToString:@"NSString"]) {
        objString = [NSString stringWithFormat:@"\"%@\"", (NSString*)(obj)];
    } else if ([objClassName isEqualToString:@"NSNumber"]) {
        objString = [NSString stringWithFormat:@"%@", [(NSNumber*)(obj) stringValue]];
    } else if ([objClassName isEqualToString:@"JKConstant"]) {
        if ((JKConstant*)(obj) == jkTrue) {
            objString = @"true";
        } else if ((JKConstant*)(obj) == jkFalse) {
            objString = @"false";
        } else if ((JKConstant*)(obj) == jkNull) {
            objString = @"null";
        }
    }
    
    return objString;
}

@end
