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

#define OtherPrimaryKeyId @"number"


@interface NSObject (FMDB)

/** 主键 id */
@property (nonatomic, assign)   int        pk;
/** 列名 */
@property (retain, readonly, nonatomic) NSMutableArray         *columeNames;
/** 列类型 */
@property (retain, readonly, nonatomic) NSMutableArray         *columeTypes;



//如果 要使用数据库  那么 在初始化的时候 就调用 一下 这个方法
- (void)initlizedPropertyNames;

/**
 *  获取该类的所有属性
 */
+ (NSDictionary *)getPropertys;

/** 获取所有属性，包括主键 (自定义 一个 主键  不使用存储 数据库时自动生成的主键) */
+ (NSDictionary *)getAllProperties;


/** 表中的字段*/
+ (NSArray *)getColumns;

/** 保存或更新
 * 如果不存在主键，保存，
 * 有主键，则更新
 */
- (BOOL)saveOrUpdate;
/** 保存单个数据 */
- (BOOL)save;
/** 批量保存数据 */
+ (BOOL)saveObjects:(NSArray *)array;
/** 更新单个数据 */
- (BOOL)update;
/** 批量更新数据*/
+ (BOOL)updateObjects:(NSArray *)array;
/** 删除单个数据 */
- (BOOL)deleteObject;
/** 批量删除数据 */
+ (BOOL)deleteObjects:(NSArray *)array;
/** 通过条件删除数据 */
+ (BOOL)deleteObjectsByCriteria:(NSString *)criteria;
/** 清空表 */
+ (BOOL)clearTable;

/** 查询全部数据 */
+ (NSArray *)findAll;

/** 通过主键查询 */
+ (instancetype)findByPK:(int)inPk;

/** 查找某条数据 */
+ (instancetype)findFirstByCriteria:(NSString *)criteria;



//通过 条件查找  － 返回数组中的第一个
+ (instancetype)findWhereColoum:(NSString *)coloum equleToValue:(NSString *)value;

/** 通过条件查找数据
 * 这样可以进行分页查询 @" WHERE pk > 5 limit 10"
 */
+ (NSArray *)findByCriteria:(NSString *)criteria;

#pragma mark - must be override method
/**
 * 创建表
 * 如果已经创建，返回YES  （transients 不想创建成本地数据库 字段的 属性 - ）
 */
+ (BOOL)createTableWithNoProperties:(NSArray *)transients;



@end
