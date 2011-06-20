//
//  JKStaticReader.h
//  json_kid
//
//  Created by Noam Etzion-Rosenberg on 19/06/11.
//  Copyright 2011 PleasantLight. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "JKDefs.h"

@interface JKStaticReader : NSObject {
    NSString* _string;
    NSUInteger _maxLen;
    NSUInteger _ptr;
    unichar _currChar;
    NSMutableDictionary* _dictionary;
    NSMutableArray* _array;
    NSMutableArray* _errors;
    NSCharacterSet* _numberStarters;
}

@property (nonatomic, retain) NSString* string;
@property NSUInteger maxLen;
@property NSUInteger ptr;
@property unichar currChar;
@property (nonatomic, retain) NSMutableDictionary* dictionary;
@property (nonatomic, retain) NSMutableArray* array;
@property (nonatomic, retain) NSMutableArray* errors;
@property (nonatomic, retain) NSCharacterSet* numberStarters;

- (id)readString:(NSString*)string;
- (id)readData:(NSData*)data withEncoding:(NSStringEncoding)encoding;

- (id)extractNextObject;
- (id)extractNextArray;
- (id)extractNextValue;
- (NSRange)extractNextString;
- (NSNumber*)extractNextNumber;
- (JKConstant*)extractNextConstant;

- (unichar)nextChar;
- (NSUInteger)fastForwardWhiteSpace;

@end
