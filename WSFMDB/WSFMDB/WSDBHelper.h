//
//  JKDataBase.h
//  JKBaseModel
//
//  Created by zx_04 on 15/6/24.
//
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@interface WSDBHelper : NSObject

@property (nonatomic, retain, readonly) FMDatabaseQueue *dbQueue;

+ (WSDBHelper *)shareInstance;

+ (NSString *)dbPath;

@end
