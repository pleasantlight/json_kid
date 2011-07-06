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
    NSMutableString* indent = [NSMutableString stringWithString:@""];
    for (int i=0; i<depth; ++i)
        [indent appendString:@"    "];
    
    NSMutableString* jsonObject = [NSMutableString stringWithFormat:@"%@{ ", indent];
    
    BOOL firstKey = YES;
    for(id key in dict) {
        if ([key isKindOfClass:[NSString class]] == false && [key isKindOfClass:[NSMutableString class]] == false) {
            // Not a valid class for a key..
            continue;
        }
        
        NSString* escapedKey = [self escapeJsonString:(NSString*)(key)];
        
        NSString* objString = [self getJsonStringForObject:[dict objectForKey:key] withDepth:depth];        
        if ([objString isEqualToString:@""] == NO) {
            NSString* prefix = @"\n";
            if (firstKey == YES) {
                firstKey = NO;
            }
            else {
                prefix = @",\n";
            }

            NSString* keyObjString = [NSString stringWithFormat:@"%@%@    %@: %@", prefix, indent, escapedKey, objString];
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
    NSMutableString* indent = [NSMutableString stringWithString:@""];
    for (int i=0; i<depth; ++i)
        [indent appendString:@"    "];
    
    NSMutableString* jsonObject = [NSMutableString stringWithFormat:@"%@[ ", indent];
    
    BOOL firstKey = YES;
    for(id obj in arr) {
        NSString* objString = [self getJsonStringForObject:obj withDepth:depth];
        if ([objString isEqualToString:@""] == NO) {
            NSString* prefix = @" ";
            if (firstKey == YES) {
                firstKey = NO;
            }
            else {
                prefix = @", ";
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
    if ([obj isKindOfClass:[NSDictionary class]] || [obj isKindOfClass:[NSMutableDictionary class]]) {
        // Get the JSON string that represents this dictionary.
        objString = [NSString stringWithFormat:@"\n%@", [self createJsonObject:(NSDictionary*)(obj) withDepth:depth + 1]];
    } else if ([obj isKindOfClass:[NSArray class]] || [obj isKindOfClass:[NSMutableArray class]]) {
        // Get the JSON string that represents this array.
        objString = [NSString stringWithFormat:@"\n%@", [self createJsonArray:(NSArray*)(obj) withDepth:depth + 1]];
    } else if ([obj isKindOfClass:[NSString class]]) {
        objString = [self escapeJsonString:(NSString*)(obj)];
    } else if ([obj isKindOfClass:[NSNumber class]]) {
        objString = [NSString stringWithFormat:@"%@", [(NSNumber*)(obj) stringValue]];
    } else if ([obj isKindOfClass:[JKConstant class]]) {
        if ((JKConstant*)(obj) == JKConstant.jkTrue) {
            objString = @"true";
        } else if ((JKConstant*)(obj) == JKConstant.jkFalse) {
            objString = @"false";
        } else if ((JKConstant*)(obj) == JKConstant.jkNull) {
            objString = @"null";
        }
    }
    
    return objString;
}

// escape all reverse slashes (solidus), all double quotes and all control characters. Everything else that's unicode is allowed.
- (NSString*)escapeJsonString:(NSString*)str {
    int len = str.length;
    char* escapedStr = (char*)malloc((len + 1) * 2);
    memset(escapedStr, 0, (len + 1) * 2);
    int ptr = 0;
    
    for (int i=0; i<len; ++i) {
        unichar c = [str characterAtIndex:i];
        switch (c) {
            case '"':  escapedStr[ptr] = '\\'; escapedStr[ptr+1] = '"'; ptr += 2; break;
            case '\\': escapedStr[ptr] = '\\'; escapedStr[ptr+1] = '\\'; ptr += 2; break;
            case '/': escapedStr[ptr] = '\\'; escapedStr[ptr+1] = '/'; ptr += 2; break;
            case '\b': escapedStr[ptr] = '\\'; escapedStr[ptr+1] = 'b'; ptr += 2; break;
            case '\f': escapedStr[ptr] = '\\'; escapedStr[ptr+1] = 'f'; ptr += 2; break;
            case '\n': escapedStr[ptr] = '\\'; escapedStr[ptr+1] = 'n'; ptr += 2; break;
            case '\r': escapedStr[ptr] = '\\'; escapedStr[ptr+1] = 'r'; ptr += 2; break;
            case '\t': escapedStr[ptr] = '\\'; escapedStr[ptr+1] = 't'; ptr += 2; break;
            default: escapedStr[ptr] = c; ++ptr; break;
        }
    }
    
    return [NSString stringWithFormat:@"\"%@\"", [NSString stringWithCString:escapedStr encoding:NSUTF8StringEncoding]];
}

@end
