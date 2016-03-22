//
//  
//
//  Created by TYRBL on 15/10/28.
//  Copyright © 2015年 Senro Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@interface WSDBHelper : NSObject

@property (nonatomic, retain, readonly) FMDatabaseQueue *dbQueue;

+ (WSDBHelper *)shareInstance;

+ (NSString *)dbPath;

@end
