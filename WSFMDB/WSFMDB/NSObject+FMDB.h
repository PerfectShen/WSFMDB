//
//  NSObject+FMDB.h
//  WSFMDB
//
//  Created by TYRBL on 15/10/28.
//  Copyright © 2015年 Senro Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

//如果自己设置的主键  是字符串类型 －  则 条件语句中  where = '<value>' //需要加单引号。。
//目前 已经加好了 － 

/** SQLite五种数据类型 */
#define SQLTEXT     @"TEXT"
#define SQLINTEGER  @"INTEGER"
#define SQLREAL     @"REAL"
#define SQLBLOB     @"BLOB"
#define SQLNULL     @"NULL"
#define PrimaryKey  @"primary key"

#define primaryId   @"pk"


@interface NSObject (FMDB)

/** 主键 id */
@property (nonatomic, assign)   int        pk;

@property (nonatomic,copy) NSString *primaryKeyName; //主键名


/** 列名 */
@property (retain, readonly, nonatomic) NSMutableArray         *columeNames;
/** 列类型 */
@property (retain, readonly, nonatomic) NSMutableArray         *columeTypes;



/**
 * 创建表
 * 如果已经创建，返回YES  （transients 不想创建成本地数据库 字段的 属性 - ）
 */
+ (BOOL)createTableWithNoProperties:(NSArray *)transients withPrimaryKey:(NSString *)primarykey;

/**
 *  创建表  指定  列
 */
+ (BOOL)createTableWithProperties:(NSArray *)properties withPrimaryKey:(NSString *)primarykey;


//如果 要使用数据库  那么 在初始化的时候 就调用 一下 这个方法
- (void)initlizedWithProperties:(NSArray *)properties;;

- (void)initlizedWithNoProperties:(NSArray *)transients;




/**
 *  获取该类的所有属性
 */
+ (NSDictionary *)getPropertys;

/** 获取所有属性，包括主键 (自定义 一个 主键  不使用存储 数据库时自动生成的主键) */
+ (NSDictionary *)getAllProperties;


/** 表中的字段*/
+ (NSArray *)getColumns;




#pragma mark -- 数据操作 ---



/**
 *  保存 或者 更新 （如果 已经存在 则更新 如果没有 存在 则保存）
 *
 *  @return 保存或者更新成功 返回 YES
 */
- (BOOL)saveOrUpdate;



/**
 *  保存单条 数据
 *
 *  @return 成功 返回 YES
 */
- (BOOL)save;

/**
 *  保存 一个数组
 *
 *  @param array 模型数组
 *
 *  @return 成功 返回 YES
 */
+ (BOOL)saveObjects:(NSArray *)array;



/**
 *  更新单条数据
 *
 *  @return 成功 返回 YES
 */
- (BOOL)update;

/**
 *  批量更新数据
 *
 *  @param array 模型数组
 *
 *  @return 成功返回 YES
 */
+ (BOOL)updateObjects:(NSArray *)array;

/**
 *  删除 单条 数据
 *
 *  @return 成功返回 YES
 */
- (BOOL)deleteObject;


/**
 *  删除  一组数据
 *
 *  @param array 模型数据
 *
 *  @return 成功 返回YES
 */
+ (BOOL)deleteObjects:(NSArray *)array;


/**
 *  通过条件删除 数据
 *
 *  @param criteria 条件
 *
 *  @return 成功返回 YES
 */
+ (BOOL)deleteObjectsByCriteria:(NSString *)criteria;


/**
 *  清空表
 *
 *  @return 成功返回YES
 */
+ (BOOL)clearTable;


/**
 *  查询所有数据
 *
 *  @return 数据模型
 */
+ (NSArray *)findAll;

/** 通过主键查询 */ //(已经去掉)
+ (instancetype)findByPK:(int)inPk;


/**
 *  通过 某条件查找 数据
 *
 *  @param criteria 条件语句
 *
 *  @return
 */
+ (instancetype)findFirstByCriteria:(NSString *)criteria;



//通过 条件查找  － 返回数组中的第一个
+ (instancetype)findWhereColoum:(NSString *)coloum equleToValue:(NSString *)value;





/** 通过条件查找数据
 * 这样可以进行分页查询 @" WHERE pk > 5 limit 10"
 */
+ (NSArray *)findByCriteria:(NSString *)criteria;






@end
