//
//  JKDefs.h
//  json_kid
//
//  Created by Noam Etzion-Rosenberg on 19/06/11.
//  Copyright 2011 PleasantLight. All rights reserved.
//

#ifndef json_kid_JKDefs_h
#define json_kid_JKDefs_h

@interface JKConstant : NSObject {
    int _id;
}

- (id)init:(int)constantId;

+(JKConstant*)jkTrue;
+(JKConstant*)jkFalse;
+(JKConstant*)jkNull;

@end 

extern JKConstant* _jkTrue;
extern JKConstant* _jkFalse;
extern JKConstant* _jkNull;

#endif
