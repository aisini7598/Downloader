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

@class DYMDownloaderManager;

@protocol DYMDownloadManagerDelegate <NSObject>

- (void)downloadUpdateProgress:(DYMDownloaderManager *)downloadManager identifire:(NSString *)indentifire;
- (void)downloadFinished:(DYMDownloaderManager *)downloadManager;
- (void)downloadExistTask:(DYMDownloaderManager *)downloadManager;

@end

@interface DYMDownloaderManager : NSObject

- (NSArray *)unFinishedList;
- (NSArray *)finishedList;

+ (instancetype)sharedInstance;

@property (nonatomic, weak) id <DYMDownloadManagerDelegate> downloadDelegate;

- (void)setMaxCount:(NSInteger)maxCount;

- (void)downloadTask:(DownloadInfoMessage *)task completedBlock:(completedBlock)completedBlock;
- (void)downloadTaskUrl:(NSString *)url completedBlcok:(completedBlock)completedBlock;


- (void)downloadTaskUrl:(NSString *)url;

- (void)cancelDownloadUrl:(NSString *)url;
- (void)startDownloadUrl:(NSString *)url;

@end
