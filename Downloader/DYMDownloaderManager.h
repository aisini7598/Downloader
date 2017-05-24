//
//  DYMDownloaderManager.h
//  Downloader
//
//  Created by John on 2017/5/19.
//  Copyright © 2017年 yoloho.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString *const DownloadFinishedNotification;
extern NSString *const DownloadChangedNotification;
extern NSString *const DownloadAddNewTaskNotification;

extern NSString *const DownloadIdentifire;
extern NSString *const DownloadTotalProgress;
extern NSString *const DownloadCurrentProgress;

@class DownloadInfoMessage;

typedef void (^completedBlock) (NSProgress *progress, BOOL finished);

@interface DYMDownloaderManager : NSObject

- (NSArray *)unFinishedList;
- (NSArray *)finishedList;

+ (instancetype)sharedInstance;

- (void)downloadTask:(DownloadInfoMessage *)task completedBlock:(completedBlock)completedBlock;
- (void)downloadTaskUrl:(NSString *)url completedBlcok:(completedBlock)completedBlock;

- (void)cancelDownloadUrl:(NSString *)url;
- (void)startDownloadUrl:(NSString *)url;

@end
