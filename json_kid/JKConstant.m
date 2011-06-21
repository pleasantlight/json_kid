//
//  JKConstant.c
//  json_kid
//
//  Created by נעם עציון-רוזנברג on 20/06/11.
//  Copyright 2011 PleasantLight. All rights reserved.
//

#include <stdio.h>
#include "JKDefs.h"

@implementation JKConstant

JKConstant* _jkTrue;
JKConstant* _jkFalse;
JKConstant* _jkNull;

+(void) initialize {
    _jkTrue = [[JKConstant alloc] init: 1];
    _jkFalse = [[JKConstant alloc] init: 2];
    _jkNull = [[JKConstant alloc] init: 3];
}

-(id) init:(int)constantId {
    self = [super init];
    if (self) {
        _id = constantId;
    }
    
    return self;
}

+(JKConstant*)jkTrue { 
    return _jkTrue; 
}
+(JKConstant*)jkFalse { 
    return _jkFalse; 
}
+(JKConstant*)jkNull { 
    return _jkNull; 
}

@end

