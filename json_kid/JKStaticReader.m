//
//  JKStaticReader.m
//  json_kid
//
//  Created by Noam Etzion-Rosenberg on 19/06/11.
//  Copyright 2011 PleasantLight. All rights reserved.
//

#import "JKStaticReader.h"

@implementation JKStaticReader

@synthesize string = _string;
@synthesize maxLen = _maxLen;
@synthesize ptr = _ptr;
@synthesize currChar = _currChar;
@synthesize dictionary = _dictionary;
@synthesize array = _array;
@synthesize errors = _errors;
@synthesize numberStarters = _numberStarters;

- (id)init {
    self = [super init];
    if (self) {
        _string = nil;
        _maxLen = 0;
        _ptr = 0;
        _currChar = '\0';
        _dictionary = nil;
        _array = nil;
        _errors = [[NSMutableArray alloc] init];
        _numberStarters = [NSCharacterSet characterSetWithCharactersInString:@"-0123456789"];
    }
    
    return self;
}

- (id)readString:(NSString*)inString {
    // Defensive programming..
    if (inString == nil) {
        [self.errors addObject:@"String is nil"];
        return nil;
    }
    
    self.string = inString;
    self.ptr = 0;
    
    self.maxLen = [self.string length];
    if (self.maxLen == 0) {
        [self.errors addObject:@"String is empty"];
        return nil;
    }
    

    // Find the first character that's not a whitespace.
    [self fastForwardWhiteSpace];

    // Check for an empty string:
    if (self.ptr >= self.maxLen) {
        [self.errors addObject:@"String contains only whitespace"];
        return nil;
    }
    
    // The first character must me { or [.
    if (self.currChar == '{')
        return [self extractNextObject];
    
    if (self.currChar == '[')
        return [self extractNextArray];
    
    // Invalid String.
    [self.errors addObject:@"String is invalid (must start with '[' or '{')"];
    return nil;
}

- (id)readData:(NSData*)data withEncoding:(NSStringEncoding)encoding {
    NSString* string = [[NSString alloc] initWithData:data encoding:encoding];
    return [self readString:string];
}

- (id)extractNextObject {
    // Make sure that first character is indeed '{'.
    if (self.currChar != '{') {
        [self.errors addObject:@"While parsing object: the first char isn't '{'."];
        return nil;
    }
    
    // Create the mutable dictionary we'll use to store the contents of the JSON data.
    self.dictionary = [[NSMutableDictionary alloc] init];
    
    // Collect key/value pairs.
    while (self.ptr < self.maxLen) {
        [self fastForwardWhiteSpace];
        
        NSRange keyRange = [self extractNextString];
        if (keyRange.length <= 0) {
            [self.errors addObject:[NSString stringWithFormat:@"Invalid JSON Syntax: Expected a string at position %d, but couldn't find one.", self.ptr]];
            return nil;
        }
        
        [self fastForwardWhiteSpace];
        
        // The separator must be ':'.
        if (self.currChar != ':') {
            [self.errors addObject:[NSString stringWithFormat:@"Invalid JSON Syntax: Expected a ':' separator at position %d, but found '%c'.", self.ptr, self.currChar]];
            return nil;
        }
        
        [self fastForwardWhiteSpace];
        
        id value = [self extractNextValue];
        if (value == nil) {
            [self.errors addObject:[NSString stringWithFormat:@"Invalid JSON Syntax: Expected a value starting at position %d, but couldn't find one.", self.ptr]];
            return nil;
        }
        
        // Add the new key/value pair to the dictionary.
        [self.dictionary setObject:value forKey:[self.string substringWithRange:keyRange]];
        [self fastForwardWhiteSpace];
        
        // The next character can be either a comma (',') or a closing bracket ('}').
        if (self.currChar == ',')
            continue;
        
        if (self.currChar == '}')
            break;
        
        [self.errors addObject:[NSString stringWithFormat:@"Invalid JSON Syntax: Expected either a comma or a closing bracket ('}') at position %d, but couldn't find it.", self.ptr]];
        return nil;
    }
    
    // It's all good.
    return self.dictionary;
}

- (id)extractNextArray {
    // Make sure that first character is indeed '{'.
    if (self.currChar != '[') {
        [self.errors addObject:@"While parsing array: the first char isn't ']'."];
        return nil;
    }
    
    // Create the mutable array we'll use to store the contents of the JSON data.
    self.array = [[NSMutableArray alloc] init];
    
    // Collect key/value pairs.
    while (self.ptr < self.maxLen) {
        [self fastForwardWhiteSpace];
        
        id value = [self extractNextValue];
        if (value == nil) {
            [self.errors addObject:[NSString stringWithFormat:@"Invalid JSON Syntax: Expected a value starting at position %d, but couldn't find one.", self.ptr]];
            return nil;
        }
        
        // Add the new value to the array.
        [self.array addObject:value];
        
        [self fastForwardWhiteSpace];
        
        // The next character can be either a comma (',') or a closing bracket (']').
        if (self.currChar == ',')
            continue;
        
        if (self.currChar == ']')
            break;
        
        [self.errors addObject:[NSString stringWithFormat:@"Invalid JSON Syntax: Expected either a comma or a closing bracket (']') at position %d, but couldn't find it.", self.ptr]];
        return nil;
    }
    
    // It's all good.
    return self.array;
}

- (id)extractNextValue {
    // If the current character is a double quote, it's the start of a new string.
    if (self.currChar == '"') {
        NSRange nextStringRange = [self extractNextString];
        if (nextStringRange.length <= 0) {
            [self.errors addObject:[NSString stringWithFormat:@"Invalid JSON Syntax: Was hoping to extract a string at position %d, but failed.", self.ptr]];
            return nil;
        }
        
        return [self.string substringWithRange:nextStringRange];
    }
    
    // If the current character is a digit (or a minus sign), it's the start of a new number.
    if ([self.numberStarters characterIsMember:self.currChar])
        return [self extractNextNumber];
    
    // If the current character is '{', it's the start of a new object.
    if (self.currChar == '{')
         return [self extractNextObject];
    
    // If the current character is '[', it's the start of a new array.
    if (self.currChar == '{')
        return [self extractNextArray];
    
    // If we got so far, it could only be one of the constants.
    return [self extractNextConstant];
}

- (NSRange)extractNextString {
    // Defensive: check that the first character is a double quote.
    if (self.currChar != '"')
        return NSMakeRange(0, -1); 
    
    int start = self.ptr;
    int len = 0;
    BOOL escapeSequenceOn = NO;
    for ([self nextChar]; self.currChar != '\0'; [self nextChar], ++len) {
        // NOTE: We don't parse the escape sequences, nor do we ascertain that the content 
        //       of the string is made of valid Unicode characters. Tough.
        if (self.currChar == '"' && escapeSequenceOn == NO)
            break;
        
        if (self.currChar == '\\' && escapeSequenceOn == NO)
            escapeSequenceOn = YES;
        else
            escapeSequenceOn = NO;
    }
    
    return NSMakeRange(start, len);
}

- (NSNumber*)extractNextNumber {
    // Defensive: check that the current character is a digit or the minus sign.
    if ([self.numberStarters characterIsMember:self.currChar] == NO)
        return nil;
    
    double number = 0.0;

    double numberSign = 1.0;
    if (self.currChar == '-')
        numberSign = -1.0;
    
    [self nextChar];
    if (self.currChar == '0') {
    }
    else if (self.currChar >= '1' && self.currChar <= '9') {
        while (self.currChar >= '0' && self.currChar <= '9') {
            int digit = self.currChar - '0';
            number = (number * 10.0) + (double)(digit);
            [self nextChar];
        }                
    }
    else {
        [self.errors addObject:@"While parsing number: the number didn't start with a digit (after an optional minus sign)."];
        return nil;
    }
    
    // Now we're looking either for a decimal point, or an exponent symbol - otherwise it's the end of the number.
    if (self.currChar == '.') {
        double magnitude = 0.1;
        while (self.currChar >= '0' && self.currChar <= '9') {
            int digit = self.currChar - '0';
            number += (double)(digit) * magnitude;
            magnitude *= 0.1;
            [self nextChar];
        }                
    }
    else if (self.currChar == 'e' || self.currChar == 'E') {
        // The next char must be '+' or '-'.
        [self nextChar];
        double exponentSign = 0.0;
        if (self.currChar == '+') {
            exponentSign = 1.0;
        }
        else if (self.currChar == '-') {
            exponentSign = -1.0;
        }
        
        int exponent = 0;
        if (exponentSign != 0.0) {
            while (self.currChar >= '0' && self.currChar <= '9') {
                int digit = self.currChar - '0';
                exponent = (exponent * 10) + digit;
                [self nextChar];
            }                
        }
        
        number *= pow(10.0, exponentSign * exponent);
    }
    
    number *= numberSign;
    
    return [NSNumber numberWithDouble:number];
}

- (JKConstant*)extractNextConstant {
    // A constant is either 'true', 'false' or 'null'.
    if (self.currChar == 't' || self.currChar == 'T') {
        // We're looking for 'true'.
        [self nextChar];
        if (self.currChar != 'r' && self.currChar != 'R')
            return nil;

        [self nextChar];
        if (self.currChar != 'u' && self.currChar != 'U')
            return nil;
        
        [self nextChar];
        if (self.currChar != 'e' && self.currChar != 'E')
            return nil;
        
        return jkTrue;
    }
    else if (self.currChar == 'f' || self.currChar == 'F') {
        // We're looking for 'false'.
        [self nextChar];
        if (self.currChar != 'a' && self.currChar != 'A')
            return nil;

        [self nextChar];
        if (self.currChar != 'l' && self.currChar != 'L')
            return nil;

        [self nextChar];
        if (self.currChar != 's' && self.currChar != 'S')
            return nil;

        [self nextChar];
        if (self.currChar != 'e' && self.currChar != 'E')
            return nil;
        
        return jkFalse;
    }
    else if (self.currChar == 'n' || self.currChar == 'N') {
        // We're looking for 'null'.
        [self nextChar];
        if (self.currChar != 'u' && self.currChar != 'U')
            return nil;

        [self nextChar];
        if (self.currChar != 'l' && self.currChar != 'L')
            return nil;

        [self nextChar];
        if (self.currChar != 'l' && self.currChar != 'L')
            return nil;
        
        return jkNull;

    }

    return nil;
}

- (unichar)nextChar {
    if (self.ptr >= self.maxLen - 1)
        return '\0';
    
    ++self.ptr;
    self.currChar = [self.string characterAtIndex:self.ptr];
    return self.currChar;
}

- (NSUInteger)fastForwardWhiteSpace {
    while(self.currChar != '\0' && [[NSCharacterSet whitespaceCharacterSet] characterIsMember:self.currChar])
        [self nextChar];
    
    return self.currChar;        
}

@end
