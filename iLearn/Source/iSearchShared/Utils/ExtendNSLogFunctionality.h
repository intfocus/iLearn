//
//  ExtendNSLogFunctionality..h
//  iReorganize
//
//  Created by lijunjie on 15/5/20.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//
//  Reference:
//
//  [Quick Tip: Customize NSLog for Easier Debugging](http://code.tutsplus.com/tutorials/quick-tip-customize-nslog-for-easier-debugging--mobile-19066)

#ifndef iSearch_ExtendNSLogFunctionality__h
#define iSearch_ExtendNSLogFunctionality__h
#import <Foundation/Foundation.h>
#import "DateUtils.h"
#import "HttpUtils.h"
#import "const.h"

#ifdef DEBUG
#define NSLog(args...) ExtendNSLog(__FILE__,__LINE__,__PRETTY_FUNCTION__,args);
#else
#define NSLog(x...)
#endif

#ifdef DEBUG_ERROR
#define NSErrorPrint(error, args...) ExtendNSLogPrintError(__FILE__,__LINE__,__PRETTY_FUNCTION__, true, error, args);
#else
#define NSErrorPrint(error, args...) ExtendNSLogPrintError(__FILE__,__LINE__,__PRETTY_FUNCTION__, false, error, args);
#endif


#define psd(pValue, dValue) propertyDefault(pValue, dValue)

void ExtendNSLog(const char *file, int lineNumber, const char *functionName, NSString *format, ...);
BOOL ExtendNSLogPrintError(const char *file, int lineNumber, const char *functionName,BOOL isPrintSuccessfully, NSError *error, NSString *format, ...);
void actionLogPost(const char *sourceFile, int lineNumber, const char *functionName, NSString *actionName, NSString *actionResult);
NSObject* propertyDefault(NSObject *propertyValue, NSObject *defaultVlaue);
BOOL isNil(NSObject *propertyValue);

#pragma mark - ActionLog

NSString* escape(NSString *source);
void RecordLoginWithFunInfo(const char *sourceFile, int lineNumber, const char *functionName, NSString *actName, NSString *actObj, NSDictionary *actRet);
void RecordLogSynced();
#define ActionLogRecordDashboard(module) RecordLoginWithFunInfo(__FILE__, __LINE__, __PRETTY_FUNCTION__, @"主界面Dashboard", module, (@{}));
#define ActionLogRecord(klass, result, dict) RecordLoginWithFunInfo(__FILE__, __LINE__, __PRETTY_FUNCTION__, klass, result, dict);
#define ActionLogRecordSync RecordLogSynced();

#endif
