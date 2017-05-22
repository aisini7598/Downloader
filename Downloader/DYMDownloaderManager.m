//
//  DYMDownloaderManager.m
//  Downloader
//
//  Created by John on 2017/5/19.
//  Copyright © 2017年 yoloho.com. All rights reserved.
//

#import "DYMDownloaderManager.h"
#import "DYMDownloaderRequest.h"

@interface DYMDownloaderManager ()<DYMDownloaderRequestDelegate>

@property (nonatomic) NSOperationQueue *downloadQueue;

@property (nonatomic) NSMutableDictionary *tasks;

@end

@implementation DYMDownloaderManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _downloadQueue = [[NSOperationQueue alloc] init];
        _downloadQueue.maxConcurrentOperationCount = 5;
        
        _tasks = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)downloadUrl:(NSString *)url completedBlock:(completedBlock)completedBlock {
    DYMDownloaderRequest *request = [[DYMDownloaderRequest alloc] init];
    request.downloadUrl = url;
    request.downloadFilePath = [self filePath:url];
    request.tempLoadFilePath = [self tempPath:url];
    request.delegate = self;
    if (![_tasks valueForKey:url]) {
        [_tasks setValue:request forKey:url];
    }
    [self.downloadQueue addOperation:request];
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

- (void)downloadWillBeginRequest:(DYMDownloaderRequest *)request {

}

- (void)downloadDidRequest:(DYMDownloaderRequest *)request reciveLength:(CGFloat)reciveLength {
    
}

@end
