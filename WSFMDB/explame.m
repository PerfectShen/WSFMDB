//
//  explame.m
//  WSFMDB
//
//  Created by TYRBL on 15/10/28.
//  Copyright © 2015年 Senro Wang. All rights reserved.
//

#import "explame.h"

@implementation explame

+ (void)initialize
{
    
        [self createTable];
   
}


- (instancetype)init{
    
    if (self = [super init]) {
    
        [self initlizedPropertyNames];
        
    }
    return self;
}
 

@end
