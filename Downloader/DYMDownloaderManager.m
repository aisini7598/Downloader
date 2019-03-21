//
//  DYMDownloaderManager.m
//  Downloader
//
//  Created by John on 2017/5/19.
//  Copyright © 2017年 yoloho.com. All rights reserved.
//

#import "DYMDownloaderManager.h"
#import "DYMDownloaderRequest.h"
#import "DownloadInfoMessage.h"
#import "DownloadUnitTool.h"

NSString *const DownloadFinishedNotification = @"DownloadFinishedNotification";
NSString *const DownloadChangedNotification = @"DownloadChangedNotification";
NSString *const DownloadAddNewTaskNotification = @"DownloadAddNewTaskNotification";

NSString *const DownloadIdentifire = @"DownloadIdentifire";
NSString *const DownloadTotalProgress = @"DownloadTotalProgress";
NSString *const DownloadCurrentProgress = @"DownloadCurrentProgress";


NSString *const plistFileName = @"downloadConguration.plist";

@interface DYMDownloaderManager ()<DYMDownloaderRequestDelegate>

@property (nonatomic) NSOperationQueue *downloadQueue;
@property (nonatomic) NSMutableArray *taskList;
@property (nonatomic) NSMutableDictionary *completionBlocks;
@property (nonatomic) NSMutableArray *requestList;
@property (nonatomic) NSInteger maxCount;
@property (nonatomic) NSMutableDictionary *taskMap;

@end

@implementation DYMDownloaderManager

+ (instancetype)sharedInstance {
    static DYMDownloaderManager *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[DYMDownloaderManager alloc] init];
        
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _downloadQueue = [[NSOperationQueue alloc] init];
        _downloadQueue.name = @"downloadQueue";
        _downloadQueue.maxConcurrentOperationCount = 5;
        
        _taskList = [NSMutableArray array];
        _completionBlocks = [NSMutableDictionary dictionary];
        _taskMap = [NSMutableDictionary dictionary];
        _requestList = [NSMutableArray array];
        
        NSArray *cacheList = [self downloadTasks].copy;
        
        if (cacheList) {
            [_taskList addObjectsFromArray:cacheList];
        }
        
        _maxCount = 5;
        
    }
    return self;
}

- (void)downloadTaskUrl:(NSString *)url {
    if (![NSURL URLWithString:url]) {
        return;
    }
    
    [self downloadTaskUrl:url completedBlcok:nil];

}

- (void)downloadTaskUrl:(NSString *)url completedBlcok:(completedBlock)completedBlock {
    if (![NSURL URLWithString:url]) {
        return;
    }
    
    DownloadInfoMessage *info = [[DownloadInfoMessage alloc] init];
    info.downloadUrl = url;
    info.isFinished = NO;
    
    
    [self downloadTask:info completedBlock:completedBlock];
}

- (void)downloadTask:(DownloadInfoMessage *)task completedBlock:(completedBlock)completedBlcok {
    if ([self downloadMessage:task.indentifire]) {
        if (self.downloadDelegate && [self.downloadDelegate respondsToSelector:@selector(downloadExistTask:)]) {
            [self.downloadDelegate downloadExistTask:self];
        }
        return;
    }
    
    task.downloadState = DownloadStateDownloading;
    [self.completionBlocks setValue:completedBlcok forKey:task.indentifire];
    [self addDownloadList:task];
    
    [self startDownoad];
}

- (void)beginDownloadInfo:(DownloadInfoMessage *)task {

    DYMDownloaderRequest *request = [[DYMDownloaderRequest alloc] init];
    request.downloadUrl = task.downloadUrl;
    request.downloadFilePath = [self filePath:task.downloadUrl];
    request.indentifire = task.indentifire;
    request.delegate = self;
    
    [self.requestList addObject:request];
    [self.downloadQueue addOperation:request];
    
}

- (void)startDownoad {
    NSInteger max = _maxCount;
    
    NSInteger num = 0;

    for (DownloadInfoMessage *info in self.taskList.copy) {
        if (info.downloadState == DownloadStateDownloading) {
            num++;
            
            if (num >= max) {
                
                info.downloadState = DownloadStateWait;
            }
        }
    }
    
    if (num < max) {
        for (DownloadInfoMessage *info in self.taskList.copy) {
            if (info.downloadState == DownloadStateWait) {
                num++;
                if (num >= max) {
                    break;
                }
                info.downloadState = DownloadStateDownloading;
            }
        }
    }
    
    for (DownloadInfoMessage *info in self.taskList.copy) {
        if (info.downloadState == DownloadStateDownloading) {
            [self beginDownloadInfo:info];
        } else {
        
        }
    }
    
}

- (void)addDownloadList:(DownloadInfoMessage *)messageInfo {
    @synchronized (self) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DownloadAddNewTaskNotification object:@{@"downloadInfo":messageInfo}];
        [self.taskList addObject:messageInfo];
        self.taskMap[messageInfo.indentifire] = messageInfo;
        [self saveDownloadTask];
    }
}

- (NSArray *)unFinishedList {
    @synchronized (self) {
        NSMutableArray *unFinishedList = [NSMutableArray array];
        for (DownloadInfoMessage *info in self.taskList) {
            if (!info.isFinished) {
                [unFinishedList addObject:info];
            }
        }
        return unFinishedList.copy;
    }
}

- (NSArray *)finishedList {
    @synchronized (self) {
        NSMutableArray *finishedList = [NSMutableArray array];
        for (DownloadInfoMessage *info in self.taskList) {
            if (info.isFinished) {
                [finishedList addObject:info];
            }
        }
        return finishedList.copy;
    }
}

- (NSString *)mainPath {
    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [cachePaths objectAtIndex:0];
    
    cachePath = [cachePath stringByAppendingPathComponent:@"DYMDownload"];
    BOOL isDir = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return cachePath;
}

- (NSString *)filePath:(NSString *)url {
    return [[self mainPath] stringByAppendingPathComponent:[url lastPathComponent]];
}

- (NSString *)tempPath:(NSString *)url {
    NSString *mainPath = [self mainPath];
    mainPath = [mainPath stringByAppendingPathComponent:@"temp"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:mainPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:mainPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return [mainPath stringByAppendingPathComponent:url.lastPathComponent];
}

- (void)downloadDidFinished:(DYMDownloaderRequest *)request {
    
    DownloadInfoMessage *info = [self downloadMessage:request.indentifire];
    info.isFinished = YES;
    info.downloadState = DownloadStateFinished;
    completedBlock completedBlock = [self.completionBlocks valueForKey:request.indentifire];
    
    if (completedBlock) {
        completedBlock ([NSProgress new], YES);
    }
    
    if (self.downloadDelegate && [self.downloadDelegate respondsToSelector:@selector(downloadFinished:)]) {
        [self.downloadDelegate downloadFinished:self];
    }
    
    [self startDownoad];
    
}

- (DownloadInfoMessage *)downloadMessage:(NSString *)identifire {
    DownloadInfoMessage *foundInfo = nil;
    for (DownloadInfoMessage *infoMessage in self.taskList) {
        if ([identifire isEqualToString:infoMessage.indentifire]) {
            foundInfo = infoMessage;
            break;
        }
    }
    return foundInfo;
}

- (void)downloadDidRequest:(DYMDownloaderRequest *)request progress:(NSProgress *)progress {
    @synchronized (self) {
        DownloadInfoMessage *infoMessage = self.taskMap[request.indentifire];
        infoMessage.currentSize = progress.completedUnitCount;
        infoMessage.fileSize = progress.totalUnitCount;
        [[NSNotificationCenter defaultCenter] postNotificationName:DownloadChangedNotification object:request.indentifire];
    }
}

- (void)cancelDownloadUrl:(NSString *)url {
    if (url.length == 0) {
        return;
    }
    
    NSString *identifire = [self md5String:url];
    
    [self.requestList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([[obj downloadUrl] isEqualToString:url]) {
            
            [obj cancel];
            
            *stop = YES;
        }
    }];
    
    for (DownloadInfoMessage *message in self.taskList) {
        if ([message.indentifire isEqualToString:identifire]) {
            message.downloadState = DownloadStateWait;
        }
    }
    [self saveDownloadTask];
    
    
}

- (NSString *)md5String:(NSString *)md5 {
    return [DownloadUnitTool stringFromMD5:md5];
}

- (void)startDownloadUrl:(NSString *)url {
    if (url.length == 0) {
        return;
    }
    
    [self.requestList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([[obj downloadUrl] isEqualToString:url]) {
            
            [obj resume];
            
            *stop = YES;
        }
        
    }];
}

- (void)saveDownloadTask {
    NSMutableArray *cacheList = [NSMutableArray array];
    for (DownloadInfoMessage *info in self.taskList) {
        [cacheList addObject:[info revertToDictionary]];
    }
    if (cacheList.count > 0) {
        [cacheList writeToFile:[self plistFilePath] atomically:YES];
    }
}

- (NSArray *)downloadTasks {
    NSArray *tasks = [NSArray arrayWithContentsOfFile:[self plistFilePath]];
    
    NSMutableArray *downloadMessageInfos = [NSMutableArray array];
    if (tasks.count > 0) {
        for (NSDictionary *dictionary in tasks) {
            DownloadInfoMessage *infoMessage = [DownloadInfoMessage initWithDictionay:dictionary];
            [downloadMessageInfos addObject:infoMessage];
        }
    }
    
    return downloadMessageInfos;
}

- (NSString *)plistFilePath {
    NSString *mainPath = [self mainPath];
    return [mainPath stringByAppendingPathComponent:plistFileName];
}

- (void)setMaxCount:(NSInteger)maxCount {
    _maxCount = maxCount;
}

@end
