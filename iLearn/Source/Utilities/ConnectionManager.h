//
//  ConnectionManager.h
//  iLearn
//
//  Created by Charlie Hung on 2015/6/15.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ConnectionManagerDelegate <NSObject>

- (void)connectionManagerDidDownloadExamsForUser:(NSString*)userId withError:(NSError*)error;
- (void)connectionManagerDidDownloadExam:(NSString*)examId withError:(NSError*)error;
- (void)connectionManagerDidUploadExamResult:(NSString*)examId withError:(NSError*)error;
- (void)connectionManagerDidUploadExamScannedResult:(NSString*)result withError:(NSError*)error;

- (void)connectionManagerDidDownloadCourse:(NSString*)courseID Ext:(NSString *)extName withError:(NSError*)error;

@end

@interface ConnectionManager : NSObject

@property (weak, nonatomic) id<ConnectionManagerDelegate> delegate;

//+ (ConnectionManager*)sharedManager;
- (void)downloadExamsForUser:(NSString*)userId;
- (void)downloadExamWithId:(NSString*)examId;
- (void)uploadExamResultWithPath:(NSString*)resultPath;
- (void)uploadExamScannedResult:(NSString*)result;

- (void)downloadCourse:(NSString*)courseID Ext:(NSString *)extName;

@end
