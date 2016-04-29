//
//  NSObject+FMDB.m
//  WSFMDB
//
//  Created by TYRBL on 15/10/28.
//  Copyright © 2015年 Senro Wang. All rights reserved.
//

#import "NSObject+FMDB.h"

#import "WSDBHelper.h"

#import <objc/runtime.h>
#import <objc/message.h>



//
static const char pkKey;
static const char columeNamesKey;
static const char columeTypesKey;
static const char primaryKeyNameKey;



@implementation NSObject (FMDB)

- (void)initlizedWithNoProperties:(NSArray *)transients{
    NSDictionary *dic = [self.class checkTableColumNameWithNoProperties:transients];
    self.columeNames = [[NSMutableArray alloc] initWithArray:[dic objectForKey:@"name"]];
    self.columeTypes = [[NSMutableArray alloc] initWithArray:[dic objectForKey:@"type"]];
    
}

- (void)initlizedWithProperties:(NSArray *)properties{
    NSDictionary *dic = [self.class checkTableColumNameWithProperties:properties];

    self.columeNames = [[NSMutableArray alloc] initWithArray:[dic objectForKey:@"name"]];
    self.columeTypes = [[NSMutableArray alloc] initWithArray:[dic objectForKey:@"type"]];
}


#pragma mark -- 重写 setter 方法 ---

//重写 set 方法
- (void)setPk:(int)pk{
    
    NSNumber *num = [NSNumber numberWithInt:pk];
    objc_setAssociatedObject(self, &pkKey, num, OBJC_ASSOCIATION_ASSIGN);
      
}


- (void)setColumeNames:(NSMutableArray *)columeNames{
    
    objc_setAssociatedObject(self, &columeNamesKey, columeNames, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (void)setColumeTypes:(NSMutableArray *)columeTypes{
    
    objc_setAssociatedObject(self, &columeTypesKey , columeTypes, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setPrimaryKeyName:(NSString *)primaryKeyName{
    
    objc_setAssociatedObject(self, &primaryKeyNameKey, primaryKeyName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

#pragma mark -- 重写  getter 方法 ---

//重写  getter 方法

- (int)pk{
    
    NSNumber *num = objc_getAssociatedObject(self, &pkKey);
    return [num intValue];
}

- (NSMutableArray *)columeNames{
    
   return  objc_getAssociatedObject(self, &columeNamesKey);
}


- (NSMutableArray *)columeTypes{
    
    return  objc_getAssociatedObject(self, &columeTypesKey);
}

- (NSString *)primaryKeyName{
    
    return objc_getAssociatedObject(self, &primaryKeyNameKey);
}



#pragma mark -- 创建 表 ---
/**
 * 创建表
 * 如果已经创建，返回YES
 */

+ (BOOL)createTableWithNoProperties:(NSArray *)transients withPrimaryKey:(NSString *)primarykey
{
    

    FMDatabase *db = [[self class] isOpenDataBase];
   if (!db) return NO; //如果打不开数据库 返回  NO
    
    NSString *tableName = NSStringFromClass(self.class);
    NSString *columeAndType = [self.class tableColumeAndTyeStringWithNoProperties:transients];
    
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(%@);",tableName,columeAndType];
    if (![db executeUpdate:sql]) {
        return NO;
    }
    
    NSMutableArray *columns = [NSMutableArray array];
    FMResultSet *resultSet = [db getTableSchema:tableName];
    while ([resultSet next]) {
        NSString *column = [resultSet stringForColumn:@"name"];
        [columns addObject:column];
    }
    NSDictionary *dict = [self.class checkTableColumNameWithNoProperties:transients];
    NSArray *aPros = [dict objectForKey:@"name"];
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",columns];
    //过滤数组
    NSArray *resultArray = [aPros filteredArrayUsingPredicate:filterPredicate];
    
    for (NSString *column in resultArray) {
        NSUInteger index = [aPros indexOfObject:column];
        NSString *proType = [[dict objectForKey:@"type"] objectAtIndex:index];
        NSString *fieldSql = [NSString stringWithFormat:@"%@ %@",column,proType];
        NSString *sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ ",NSStringFromClass(self.class),fieldSql];
        if (![db executeUpdate:sql]) {
            return NO;
        }
    }
    [db close];
    return YES;
}


+ (BOOL )createTableWithProperties:(NSArray *)properties withPrimaryKey:(NSString *)primarykey{
    
    FMDatabase *db = [[self class] isOpenDataBase];
    if (!db) return NO; //如果打不开数据库 返回  NO
    
    NSString *tableName = NSStringFromClass(self.class);
    NSString *columeAndType = [self.class tableColumeAndTyeStringWithProperties:properties];
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(%@);",tableName,columeAndType];
    if (![db executeUpdate:sql]) {
        return NO;
    }
    
    NSMutableArray *columns = [NSMutableArray array];
    FMResultSet *resultSet = [db getTableSchema:tableName];
    while ([resultSet next]) {
        NSString *column = [resultSet stringForColumn:@"name"];
        [columns addObject:column];
    }
    NSDictionary *dict = [self.class checkTableColumNameWithProperties:properties];
    NSArray *aPros = [dict objectForKey:@"name"];
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",columns];
    //过滤数组
    NSArray *resultArray = [aPros filteredArrayUsingPredicate:filterPredicate];
    
    for (NSString *column in resultArray) {
        NSUInteger index = [aPros indexOfObject:column];
        NSString *proType = [[dict objectForKey:@"type"] objectAtIndex:index];
        NSString *fieldSql = [NSString stringWithFormat:@"%@ %@",column,proType];
        NSString *sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ ",NSStringFromClass(self.class),fieldSql];
        if (![db executeUpdate:sql]) {
            return NO;
        }
    }
    [db close];
    return YES;
}



#pragma mark -- private ---
+ (FMDatabase *)isOpenDataBase{
    
    FMDatabase *db = [FMDatabase databaseWithPath:[WSDBHelper dbPath]];
    if (![db open]) {
        NSLog(@"数据库打开失败!");
        return nil;
    }
    return db;
}


#pragma mark -- 构造 表 字段  ---
// 根据指定的 属性名 创建表
+ (NSString *)tableColumeAndTyeStringWithProperties:(NSArray *)properties{
    
    NSMutableString* pars = [NSMutableString string];
    NSDictionary *dict = [self.class getAllProperties];
    NSMutableArray *proNames = [dict objectForKey:@"name"];
    NSMutableArray *proTypes = [dict objectForKey:@"type"];
    
    for (int i=0; i< proNames.count; i++) {
        NSString *aName = [proNames objectAtIndex:i];
        if([properties containsObject:aName]){
            [pars appendFormat:@"%@ %@",[proNames objectAtIndex:i],[proTypes objectAtIndex:i]];
            if(i+1 != proNames.count)
            {
                [pars appendString:@","];
            }
        }else{
            
            continue ;
        }
       
    }
    if ([[pars substringWithRange:NSMakeRange(pars.length - 1, 1)] isEqualToString:@","]) {
        
        [pars deleteCharactersInRange:NSMakeRange(pars.length - 1, 1)];
    }
    return pars;
}

//所有的属性名 除去  transients 列表中的 属性 为  表的 字段
+ (NSString *)tableColumeAndTyeStringWithNoProperties:(NSArray *)transients{
    
    NSMutableString* pars = [NSMutableString string];
    NSDictionary *dict = [self.class getAllProperties];
    
    NSMutableArray *proNames = [dict objectForKey:@"name"];
    NSMutableArray *proTypes = [dict objectForKey:@"type"];
    
    for (int i=0; i< proNames.count; i++) {
        
        NSString *aName = [proNames objectAtIndex:i];

        if ([transients containsObject:aName]) {
            
            continue ;
        }
        [pars appendFormat:@"%@ %@",aName,[proTypes objectAtIndex:i]];
        if(i+1 != proNames.count)
        {
            [pars appendString:@","];
        }
    }
    
    if ([[pars substringWithRange:NSMakeRange(pars.length - 1, 1)] isEqualToString:@","]) {
        
         [pars deleteCharactersInRange:NSMakeRange(pars.length - 1, 1)];
    }
    return pars;
}



//检查数据库中的  字段
+ (NSDictionary *)checkTableColumNameWithNoProperties:(NSArray *)transients{
    
//        NSDictionary *dic = [self.class getAllProperties];
    NSDictionary *dict = [self.class getPropertys];
    NSMutableArray *proNames = [NSMutableArray array];
    NSMutableArray *proTypes = [NSMutableArray array];
    [proNames addObjectsFromArray:[dict objectForKey:@"name"]];
    [proTypes addObjectsFromArray:[dict objectForKey:@"type"]];
    
    NSInteger count = proNames.count;
    for (NSInteger i = count -1; i >= 0; i --) {
        NSString *aName = [proNames objectAtIndex:i];
        if ([transients containsObject:aName]) {
            
            [proNames removeObjectAtIndex:i];
            [proTypes removeObjectAtIndex:i];
        }else{
            
            continue ;
        }
    }
  return [NSDictionary dictionaryWithObjectsAndKeys:proNames,@"name",proTypes,@"type",nil];
    
}


+ (NSDictionary *)checkTableColumNameWithProperties:(NSArray *)properties{
    
    NSDictionary *dict = [self.class getPropertys];
    NSMutableArray *proNames = [NSMutableArray array];
    NSMutableArray *proTypes = [NSMutableArray array];
    [proNames addObjectsFromArray:[dict objectForKey:@"name"]];
    [proTypes addObjectsFromArray:[dict objectForKey:@"type"]];
    
    NSInteger count = proNames.count;
    for (NSInteger i = count -1; i >= 0; i--) {
        NSString *aName = [proNames objectAtIndex:i];
        if (![properties containsObject:aName]) {
            [proNames removeObjectAtIndex:i];
            [proTypes removeObjectAtIndex:i];
        }else{
            
            continue ;
        }
    }
    return [NSDictionary dictionaryWithObjectsAndKeys:proNames,@"name",proTypes,@"type",nil];

}

#pragma mark - base method
/**
 *  获取该类的所有属性
 */
+ (NSDictionary *)getPropertys
{
    NSMutableArray *proNames = [NSMutableArray array];
    NSMutableArray *proTypes = [NSMutableArray array];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        //获取属性名
        NSString *propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        [proNames addObject:propertyName];
        //获取属性类型等参数
        NSString *propertyType = [NSString stringWithCString: property_getAttributes(property) encoding:NSUTF8StringEncoding];
        /*
         c char         C unsigned char
         i int          I unsigned int
         l long         L unsigned long
         s short        S unsigned short
         d double       D unsigned double
         f float        F unsigned float
         q long long    Q unsigned long long
         B BOOL
         @ 对象类型 //指针 对象类型 如NSString 是@“NSString”
         
         
         64位下long 和long long 都是Tq
         SQLite 默认支持五种数据类型TEXT、INTEGER、REAL、BLOB、NULL
         */
        
        
        if ([propertyType hasPrefix:@"T@"]) {
            [proTypes addObject:SQLTEXT];
        } else if ([propertyType hasPrefix:@"Ti"]||[propertyType hasPrefix:@"TI"]||[propertyType hasPrefix:@"Ts"]||[propertyType hasPrefix:@"TS"]||[propertyType hasPrefix:@"TB"]) {
            [proTypes addObject:SQLINTEGER];
        } else {
            [proTypes addObject:SQLREAL];
        }
        
    }
    free(properties);
    
    return [NSDictionary dictionaryWithObjectsAndKeys:proNames,@"name",proTypes,@"type",nil];
}

//构造 数据库字段
+ (NSDictionary *)getAllProperties
{
    NSDictionary *dict = [self.class getPropertys];
    
    NSMutableArray *proNames = [NSMutableArray array];
    NSMutableArray *proTypes = [NSMutableArray array];
//    [proNames addObject:primaryId];
//    [proTypes addObject:[NSString stringWithFormat:@"%@ %@",SQLINTEGER,PrimaryKey]];
    [proNames addObjectsFromArray:[dict objectForKey:@"name"]];
    [proTypes addObjectsFromArray:[dict objectForKey:@"type"]];
    
    
    
    return [NSDictionary dictionaryWithObjectsAndKeys:proNames,@"name",proTypes,@"type",nil];
}

/** 数据库中是否存在表 */
+ (BOOL)isExistInTable
{
    __block BOOL res = NO;
    WSDBHelper *jkDB = [WSDBHelper shareInstance];
    [jkDB.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = NSStringFromClass(self.class);
        res = [db tableExists:tableName];
    }];
    return res;
}

+ (NSArray *)getColumns
{
    WSDBHelper *jkDB = [WSDBHelper shareInstance];
    NSMutableArray *columns = [NSMutableArray array];
    [jkDB.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = NSStringFromClass(self.class);
        FMResultSet *resultSet = [db getTableSchema:tableName];
        while ([resultSet next]) {
            NSString *column = [resultSet stringForColumn:@"name"];
            [columns addObject:column];
        }
    }];
    return [columns copy];
}




#pragma mark -- private ---
- (BOOL )isExsistObj{
    
    id otherPaimaryValue = [self valueForKey:self.primaryKeyName];
    
    WSDBHelper *jkDB = [WSDBHelper shareInstance];
    
    __block BOOL isExist = NO;
    
    
    [jkDB.dbQueue inDatabase:^(FMDatabase *db) {
        
        NSString *tableName = NSStringFromClass(self.class);
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@'",tableName,self.primaryKeyName,otherPaimaryValue];
        
        FMResultSet *aResult = [db executeQuery:sql];
        
        if([aResult next]){
            
            isExist = YES;
            
        }else{
            
            isExist = NO;
        }
        
    }];
    
    return isExist;
}

- (BOOL)saveOrUpdate
{
//    id primaryValue = [self valueForKey:primaryId];
   
    BOOL isExsist = [self isExsistObj];
    
    if (isExsist ) {
        
       return  [self update];
        
    }else{
        
        return [self save];

    }
    
}

- (BOOL)save
{
    NSString *tableName = NSStringFromClass(self.class);
    NSMutableString *keyString = [NSMutableString string];
    NSMutableString *valueString = [NSMutableString string];
    NSMutableArray *insertValues = [NSMutableArray  array];
    NSLog(@"%@ , %@",self.columeTypes,self.columeNames);
    for (int i = 0; i < self.columeNames.count; i++) {
        NSString *proname = [self.columeNames objectAtIndex:i];
        if ([proname isEqualToString:primaryId]) {
            continue;
        }
        [keyString appendFormat:@"%@,", proname];
        [valueString appendString:@"?,"];
        id value = [self valueForKey:proname];
        if (!value) {
            value = @"";
        }
        [insertValues addObject:value];
    }
    
    [keyString deleteCharactersInRange:NSMakeRange(keyString.length - 1, 1)];
    [valueString deleteCharactersInRange:NSMakeRange(valueString.length - 1, 1)];
    
    WSDBHelper *jkDB = [WSDBHelper shareInstance];
    __block BOOL res = NO;
    [jkDB.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@(%@) VALUES (%@);", tableName, keyString, valueString];
        res = [db executeUpdate:sql withArgumentsInArray:insertValues];
        self.pk = res?[NSNumber numberWithLongLong:db.lastInsertRowId].intValue:0;
        NSLog(res?@"插入成功":@"插入失败");
    }];
    return res;
}

/** 批量保存用户对象 */
+ (BOOL)saveObjects:(NSArray *)array
{
    //判断是否是JKBaseModel的子类
    for (id obj in array) {
        if (![obj isKindOfClass:[self class]]) {
            return NO;
        }
    }
    
    __block BOOL res = YES;
    WSDBHelper *jkDB = [WSDBHelper shareInstance];
    // 如果要支持事务
    [jkDB.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (NSObject *obj in array) {
            NSString *tableName = NSStringFromClass(obj.class);
            NSMutableString *keyString = [NSMutableString string];
            NSMutableString *valueString = [NSMutableString string];
            NSMutableArray *insertValues = [NSMutableArray  array];
            for (int i = 0; i < obj.columeNames.count; i++) {
                NSString *proname = [obj.columeNames objectAtIndex:i];
                if ([proname isEqualToString:primaryId]) {
                    continue;
                }
                [keyString appendFormat:@"%@,", proname];
                [valueString appendString:@"?,"];
                id value = [obj valueForKey:proname];
                if (!value) {
                    value = @"";
                }
                [insertValues addObject:value];
            }
            [keyString deleteCharactersInRange:NSMakeRange(keyString.length - 1, 1)];
            [valueString deleteCharactersInRange:NSMakeRange(valueString.length - 1, 1)];
            
            NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@(%@) VALUES (%@);", tableName, keyString, valueString];
            BOOL flag = [db executeUpdate:sql withArgumentsInArray:insertValues];
            obj.pk = flag?[NSNumber numberWithLongLong:db.lastInsertRowId].intValue:0;
            NSLog(flag?@"插入成功":@"插入失败");
            if (!flag) {
                res = NO;
                *rollback = YES;
                return;
            }
        }
    }];
    return res;
}

/** 更新单个对象 */
- (BOOL)update
{
    WSDBHelper *jkDB = [WSDBHelper shareInstance];
    __block BOOL res = NO;
    [jkDB.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = NSStringFromClass(self.class);
        id primaryValue = [self valueForKey:self.primaryKeyName];
//        if (!primaryValue || primaryValue <= 0) {
//            return ;
//        }
        
//        if (![self isExsistObj]) {
//            
//            return ;
//        }
        
        NSMutableString *keyString = [NSMutableString string];
        NSMutableArray *updateValues = [NSMutableArray  array];
        for (int i = 0; i < self.columeNames.count; i++) {
            NSString *proname = [self.columeNames objectAtIndex:i];
            if ([proname isEqualToString:self.primaryKeyName]) {
                continue;
            }
            if([proname isEqualToString:primaryId]){
                
                continue;
            }
            [keyString appendFormat:@" %@=?,", proname];
            id value = [self valueForKey:proname];
            if (!value) {
                value = @"";
            }
            [updateValues addObject:value];
        }
        
        //删除最后那个逗号
        [keyString deleteCharactersInRange:NSMakeRange(keyString.length - 1, 1)];
        NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@ = ?;", tableName, keyString, self.primaryKeyName];
        [updateValues addObject:primaryValue];
        res = [db executeUpdate:sql withArgumentsInArray:updateValues];
        NSLog(res?@"更新成功":@"更新失败");
    }];
    return res;
}

/** 批量更新用户对象*/
+ (BOOL)updateObjects:(NSArray *)array
{
    for (NSObject *obj in array) {
        if (![obj isKindOfClass:[self class]]) {
            return NO;
        }
    }
    __block BOOL res = YES;
    WSDBHelper *jkDB = [WSDBHelper shareInstance];
    // 如果要支持事务
    [jkDB.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (NSObject *model in array) {
            NSString *tableName = NSStringFromClass(model.class);
            id primaryValue = [model valueForKey:primaryId];
            if (!primaryValue || primaryValue <= 0) {
                res = NO;
                *rollback = YES;
                return;
            }
            
            NSMutableString *keyString = [NSMutableString string];
            NSMutableArray *updateValues = [NSMutableArray  array];
            for (int i = 0; i < model.columeNames.count; i++) {
                NSString *proname = [model.columeNames objectAtIndex:i];
                if ([proname isEqualToString:primaryId]) {
                    continue;
                }
                [keyString appendFormat:@" %@=?,", proname];
                id value = [model valueForKey:proname];
                if (!value) {
                    value = @"";
                }
                [updateValues addObject:value];
            }
            
            //删除最后那个逗号
            [keyString deleteCharactersInRange:NSMakeRange(keyString.length - 1, 1)];
            NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@=?;", tableName, keyString, primaryId];
            [updateValues addObject:primaryValue];
            BOOL flag = [db executeUpdate:sql withArgumentsInArray:updateValues];
            NSLog(flag?@"更新成功":@"更新失败");
            if (!flag) {
                res = NO;
                *rollback = YES;
                return;
            }
        }
    }];
    
    return res;
}

/** 删除单个对象 */
- (BOOL)deleteObject
{
    WSDBHelper *jkDB = [WSDBHelper shareInstance];
    __block BOOL res = NO;
    [jkDB.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = NSStringFromClass(self.class);
        id primaryValue = [self valueForKey:primaryId];
        if (!primaryValue || primaryValue <= 0) {
            return ;
        }
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = ?",tableName,primaryId];
        res = [db executeUpdate:sql withArgumentsInArray:@[primaryValue]];
        NSLog(res?@"删除成功":@"删除失败");
    }];
    return res;
}

/** 批量删除用户对象 */
+ (BOOL)deleteObjects:(NSArray *)array
{
    for (NSObject *model in array) {
        if (![model isKindOfClass:[self class]]) {
            return NO;
        }
    }
    
    
    
    
    __block BOOL res = YES;
    WSDBHelper *jkDB = [WSDBHelper shareInstance];
    // 如果要支持事务
    [jkDB.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (NSObject *model in array) {
            NSString *tableName = NSStringFromClass(model.class);
            id primaryValue = [model valueForKey:primaryId];
            if (!primaryValue || primaryValue <= 0) {
                return ;
            }
            
            NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = ?",tableName,primaryId];
            BOOL flag = [db executeUpdate:sql withArgumentsInArray:@[primaryValue]];
            NSLog(flag?@"删除成功":@"删除失败");
            if (!flag) {
                res = NO;
                *rollback = YES;
                return;
            }
        }
    }];
    return res;
}

/** 通过条件删除数据 */
+ (BOOL)deleteObjectsByCriteria:(NSString *)criteria
{
    WSDBHelper *jkDB = [WSDBHelper shareInstance];
    __block BOOL res = NO;
    [jkDB.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = NSStringFromClass(self.class);
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ %@ ",tableName,criteria];
        res = [db executeUpdate:sql];
        NSLog(res?@"删除成功":@"删除失败");
    }];
    return res;
}

/** 清空表 */
+ (BOOL)clearTable
{
    WSDBHelper *jkDB = [WSDBHelper shareInstance];
    __block BOOL res = NO;
    [jkDB.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = NSStringFromClass(self.class);
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@",tableName];
        res = [db executeUpdate:sql];
        NSLog(res?@"清空成功":@"清空失败");
    }];
    return res;
}

/** 查询全部数据 */
+ (NSArray *)findAll
{
    NSLog(@"jkdb---%s",__func__);
    WSDBHelper *jkDB = [WSDBHelper shareInstance];
    NSMutableArray *users = [NSMutableArray array];
    [jkDB.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = NSStringFromClass(self.class);
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@",tableName];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next]) {
            NSObject *model = [[self.class alloc] init];
            for (int i=0; i< model.columeNames.count; i++) {
                NSString *columeName = [model.columeNames objectAtIndex:i];
                NSString *columeType = [model.columeTypes objectAtIndex:i];
                if ([columeType isEqualToString:SQLTEXT]) {
                    [model setValue:[resultSet stringForColumn:columeName] forKey:columeName];
                } else {
                    [model setValue:[NSNumber numberWithLongLong:[resultSet longLongIntForColumn:columeName]] forKey:columeName];
                }
            }
            [users addObject:model];
            FMDBRelease(model);
        }
    }];
    
    return users;
}

/** 查找某条数据 */ //直接通过   sql 语句 进行查找 －
+ (instancetype)findFirstByCriteria:(NSString *)criteria
{
    NSArray *results = [self.class findByCriteria:criteria];
    if (results.count < 1) {
        return nil;
    }
    
    return [results firstObject];
}

+ (instancetype)findByPK:(int)inPk
{
    NSString *condition = [NSString stringWithFormat:@" WHERE %@=%d",primaryId,inPk];
    return [self findFirstByCriteria:condition];
}



// 值 为 通过 条件查找  － 返回数组中的第一个
+ (instancetype)findWhereColoum:(NSString *)coloum equleToValue:(NSString *)value{
 
    return [[self class] findFirstByCriteria:[NSString stringWithFormat:@" WHERE %@ = %@",coloum,value]];
}

/** 通过条件查找数据 */
+ (NSArray *)findByCriteria:(NSString *)criteria
{
    WSDBHelper *jkDB = [WSDBHelper shareInstance];
    NSMutableArray *users = [NSMutableArray array];
    [jkDB.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = NSStringFromClass(self.class);
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ %@",tableName,criteria];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next]) {
            NSObject *model = [[self.class alloc] init];
            for (int i=0; i< model.columeNames.count; i++) {
                NSString *columeName = [model.columeNames objectAtIndex:i];
                NSString *columeType = [model.columeTypes objectAtIndex:i];
                if ([columeType isEqualToString:SQLTEXT]) {
                    [model setValue:[resultSet stringForColumn:columeName] forKey:columeName];
                } else {
                    [model setValue:[NSNumber numberWithLongLong:[resultSet longLongIntForColumn:columeName]] forKey:columeName];
                }
            }
            [users addObject:model];
            FMDBRelease(model);
        }
    }];
    
    return users;
}

#pragma mark - util method
+ (NSString *)getColumeAndTypeString
{
    NSMutableString* pars = [NSMutableString string];
    NSDictionary *dict = [self.class getAllProperties];
    
    NSMutableArray *proNames = [dict objectForKey:@"name"];
    NSMutableArray *proTypes = [dict objectForKey:@"type"];
    
    for (int i=0; i< proNames.count; i++) {
        [pars appendFormat:@"%@ %@",[proNames objectAtIndex:i],[proTypes objectAtIndex:i]];
        if(i+1 != proNames.count)
        {
            [pars appendString:@","];
        }
    }
    return pars;
}

- (NSString *)description
{
    NSString *result = @"";
    NSDictionary *dict = [self.class getAllProperties];
    NSMutableArray *proNames = [dict objectForKey:@"name"];
    for (int i = 0; i < proNames.count; i++) {
        NSString *proName = [proNames objectAtIndex:i];
        id  proValue = [self valueForKey:proName];
        result = [result stringByAppendingFormat:@"%@:%@\n",proName,proValue];
    }
    return result;
}


//+ (NSArray *)transients{
//    
//    return @[];
//}

@end
