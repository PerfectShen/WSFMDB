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
    
//        [self createTableWithNoProperties:@[@"job"] withPrimaryKey:@""];
   
    [self createTableWithProperties:@[@"number",@"name"] withPrimaryKey:@""];
}


- (instancetype)init{
    
    if (self = [super init]) {
    
        [self initlizedWithProperties:@[@"number",@"name"]];
        self.primaryKeyName = @"number";
        
    }
    return self;
}
 

@end
