//
//  ExtendNSLogFunctionality.m
//  iReorganize
//
//  Created by lijunjie on 15/5/20.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExtendNSLogFunctionality.h"
#import "DatabaseUtils+ActionLog.h"
#import "DataHelper.h"

void ExtendNSLog(const char *file, int lineNumber, const char *functionName, NSString *format, ...) {
    @try {
        // Type to hold information about variable arguments.
        va_list ap;
        
        // Initialize a variable argument list.
        va_start (ap, format);
        
        // NSLog only adds a newline to the end of the NSLog format if
        // one is not already there.
        // Here we are utilizing this feature of NSLog()
        if (![format hasSuffix: @"\n"])
            format = [format stringByAppendingString: @"\n"];
        
        NSString *body = [[NSString alloc] initWithFormat:format arguments:ap];
        
        // End using variable argument list.
        va_end (ap);
        
        NSString *fileName = [[NSString stringWithUTF8String:file] lastPathComponent];
        fprintf(stderr, "(%s) (%s:%d) %s",
                functionName, [fileName UTF8String],
                lineNumber, [body UTF8String]);
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
}

BOOL ExtendNSLogPrintError(const char *file, int lineNumber, const char *functionName, BOOL isPrintSuccessfully, NSError *error, NSString *format, ...) {
    @try {
        if(!isPrintSuccessfully && error == nil) return YES;
        
        // Type to hold information about variable arguments.
        va_list ap;
        
        // Initialize a variable argument list.
        va_start (ap, format);
        
        NSString *body = [[NSString alloc] initWithFormat:format arguments:ap];
        if(isPrintSuccessfully && !error) {
            body = [NSString stringWithFormat:@"%@ successfully.", body];
        } else {
            body = [NSString stringWithFormat:@"%@ failed for %@", body, [error localizedDescription]];
        }
        
        if (![body hasSuffix: @"\n"])
            body = [body stringByAppendingString: @"\n"];
        
        // End using variable argument list.
        va_end (ap);
        
        NSString *fileName = [[NSString stringWithUTF8String:file] lastPathComponent];
        fprintf(stderr, "(%s) (%s:%d) %s", functionName, [fileName UTF8String], lineNumber, [body UTF8String]);
        return (error == nil);
    }
    @catch (NSException *exception) {
        return NO;
    }
    @finally {
    }
}

BOOL isNil(NSObject *propertyValue) {
    return (!propertyValue || propertyValue == [NSNull null] || propertyValue == NULL);
}
NSObject* propertyDefault(NSObject *propertyValue, NSObject *defaultVlaue) {
    if(isNil(propertyValue)) {
        propertyValue = defaultVlaue;
    }
    return propertyValue;
}
#pragma mark - ActionLog

NSString* escape(NSString *source) {
    NSMutableString *string = [NSMutableString stringWithString:source];
    [string replaceOccurrencesOfString:@"\\" withString:@" " options:1 range:NSMakeRange(0, string.length)];
    [string replaceOccurrencesOfString:@"\'" withString:@" " options:1 range:NSMakeRange(0, string.length)];
    return [NSString stringWithString:string];
}

/**
 * 需要post的数据为：
 * UserId        用户编号
 * FunctionName  功能名称
 * ActionName    动作名称
 * ActionTime    操作时间（2015/06/1 18:18:18）
 * ActionReturn  操作结果（包括错误）
 * ActionObject  操作对象（具体到文件）
 */
void RecordLoginWithFunInfo(const char *sourceFile, int lineNumber, const char *functionName, NSString *actName, NSString *actObj, NSDictionary *actRet) {
    @try {
        NSString *funInfo = [NSString stringWithFormat:@"%@, %s, %i", [[NSString stringWithUTF8String:sourceFile] lastPathComponent], functionName, lineNumber];
        NSMutableArray *actRetArray = [NSMutableArray array];
        for(id key in actRet) {
            [actRetArray addObject:[NSString stringWithFormat:@"%@: %@", key, [actRet objectForKey:key]]];
        }
        [[[DatabaseUtils alloc] init] insertActionLog:escape(funInfo)
                                              ActName:escape(actName)
                                               ActObj:escape(actObj)
                                               ActRet:escape([actRetArray componentsJoinedByString:@", "])];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
}

void RecordLogSynced() {
    DatabaseUtils *databaseUtils = [[DatabaseUtils alloc] init];
    NSMutableArray *unSyncRecords = [databaseUtils records:YES];
    NSMutableArray *IDS = [DataHelper actionLog:unSyncRecords];
    [databaseUtils updateSyncedRecords:IDS];
}
