//
//  DatabaseUtils+ActionLog.m
//  iSearch
//
//  Created by lijunjie on 15/7/9.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DatabaseUtils+ActionLog.h"
#import "FMDB.h"
#import "FileUtils.h"
#import "const.h"
#import "ExtendNSLogFunctionality.h"

@implementation DatabaseUtils (ActionLog)
/**
 *  update #deleted when remove slide
 *
 *  @param FunName NoUse
 *  @param ActObj  slideID
 *  @param ActName Display/Download/Remove
 *  @param ActRet  Favorite or Slide
 */
- (void) insertActionLog:(NSString *)FunName
                 ActName:(NSString *)ActName
                  ActObj:(NSString *)ActObj
                  ActRet:(NSString *)ActRet
                 SlideID:(NSString *)slideID
               SlideType:(NSString *)slideType
             SlideAction:(NSString *)slideAction {
    if([slideAction isEqualToString:ACTION_REMOVE]) {
        [self updateDeletedSlide:slideID SlideType:slideType];
    }
    NSString *insertSQL = [NSString stringWithFormat:@"insert into %@(%@, %@, %@, %@, %@)   \
                           values('%@', '%@', '%@', '%@', '%@');",
                           ACTIONLOG_TABLE_NAME,
                           ACTIONLOG_COLUMN_UID,
                           ACTIONLOG_COLUMN_FUNNAME,
                           ACTIONLOG_COLUMN_ACTNAME,
                           ACTIONLOG_COLUMN_ACTOBJ,
                           ACTIONLOG_COLUMN_ACTRET,
                           self.userID,
                           FunName,
                           ActName,
                           ActObj,
                           ActRet];
    [self executeSQL:insertSQL];
}

/**
 *  update #deleted when remove slide
 *
 *  @param FunName <#FunName description#>
 *  @param ActObj  slideID
 *  @param ActName Display/Download/Remove
 *  @param ActRet  Favorite or Slide
 */
- (void)updateDeletedSlide:(NSString *)slideID
                 SlideType:(NSString *)slideType {
    NSString *sql = [NSString stringWithFormat:@"update %@ set %@ = 1 \
                     where %@ = '%@' and %@ = '%@' and %@ = 0 and     \
                     %@ = '%@' and %@ = '%@';",
                     ACTIONLOG_TABLE_NAME, ACTIONLOG_COLUMN_DELETED,
                     LOCAL_COLUMN_ACTION, ACTION_DISPLAY, ACTIONLOG_COLUMN_UID, self.userID, ACTIONLOG_COLUMN_DELETED,
                     LOCAL_COLUMN_SLIDE_ID, slideID, LOCAL_COLUMN_SLIDE_TYPE, slideType];
    
    [self executeSQL:sql];
}


/**
 *  未同步数据到服务器的数据列表
 *
 *  @return NSMutableArray
 */
- (NSMutableArray *)unSyncRecords {
    NSMutableArray *array = [NSMutableArray array];
    
    NSString *sql = [NSString stringWithFormat:@"select id, %@, %@, %@, %@, %@ from %@ \
                     where %@ = '%@' and %@ = 0 ;",
                     ACTIONLOG_COLUMN_FUNNAME,
                     ACTIONLOG_COLUMN_ACTOBJ,
                     ACTIONLOG_COLUMN_ACTNAME,
                     ACTIONLOG_COLUMN_ACTRET,
                     DB_COLUMN_CREATED,
                     ACTIONLOG_TABLE_NAME,
                     ACTIONLOG_COLUMN_UID,
                     self.userID,
                     ACTIONLOG_COLUMN_ISSYNC];
    int ID;
    NSString *funName, *actObj, *actName, *actRet, *actTime;
    
    FMDatabase *db = [FMDatabase databaseWithPath:self.dbPath];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    if ([db open]) {
        FMResultSet *s = [db executeQuery:sql];
        while([s next]) {
            ID      = [s intForColumnIndex:0];
            funName = [s stringForColumnIndex:1];
            actObj  = [s stringForColumnIndex:2];
            actName = [s stringForColumnIndex:3];
            actRet  = [s stringForColumnIndex:4];
            actTime = [s stringForColumnIndex:5];
            
            dict    = [NSMutableDictionary dictionaryWithCapacity:0];
            dict[@"id"]                   = [NSNumber numberWithInt:ID];
            dict[ACTIONLOG_FIELD_UID]     = self.userID;
            dict[ACTIONLOG_FIELD_FUNNAME] = funName;
            dict[ACTIONLOG_FIELD_ACTOBJ]  = actObj;
            dict[ACTIONLOG_FIELD_ACTNAME] = actName;
            dict[ACTIONLOG_FIELD_ACTRET]  = actRet;
            dict[ACTIONLOG_FIELD_ACTTIME] = actTime;
            
            [array addObject:dict];
        }
        [db close];
    } else {
        NSLog(@"%@", [NSString stringWithFormat:@"DatabaseUtils#executeSQL \n%@", sql]);
    }
    
    return array;
}

- (void)updateSyncedRecords:(NSMutableArray *)IDS {
    if([IDS count] == 0) return;
    
    NSString *updateSQL = [NSString stringWithFormat:@"update %@ set %@ = 1 where %@ = '%@' and %@ = 0 and id in (%@)",
                           ACTIONLOG_TABLE_NAME,
                           ACTIONLOG_COLUMN_ISSYNC,
                           ACTIONLOG_COLUMN_UID,
                           self.userID,
                           ACTIONLOG_COLUMN_ISSYNC,
                           [IDS componentsJoinedByString:@","]];
    [self executeSQL:updateSQL];
    
    //[self clearSyncedRecords];
}

/**
 *  删除已上传数据只留播放文档的最近15方记录
 */
- (void)clearSyncedRecords {
    NSString *deleteSQL = [NSString stringWithFormat:@"delete from action_logs where is_synced = 1"];
    
    [self executeSQL:deleteSQL];
}


- (int)recordCount:(BOOL)isAll {
    NSString *sql = [NSString stringWithFormat:@"select count(id) from %@ ",ACTIONLOG_TABLE_NAME];
    
    if(isAll) {
        sql = [NSString stringWithFormat:@"%@ ;", sql];
    }
    else {
        sql = [NSString stringWithFormat:@"%@ where %@ = '%@' ;", sql, ACTIONLOG_COLUMN_UID, self.userID];
    }
    
    int count = -1;
    FMDatabase *db = [FMDatabase databaseWithPath:self.dbPath];
    if ([db open]) {
        FMResultSet *s = [db executeQuery:sql];
        while([s next]) {
            count = [s intForColumnIndex:0];
        }
        [db close];
    } else {
        NSLog(@"%@", [NSString stringWithFormat:@"DatabaseUtils#executeSQL \n%@", sql]);
    }
    return count;
}

/**
 *  设置界面中用户信息显示，用以调试
 *
 *  @return 最近播放的文档数量/未同步的记录数量/当前个人记录数量/所有记录数量
 */
- (NSString *)localInfo {
    NSInteger count2 = [[self unSyncRecords] count];
    int count3 = [self recordCount:NO];
    int count4 = [self recordCount:YES];
    
    return [NSString stringWithFormat:@"%li/%i/%i", (long)count2, count3, count4];
}
@end