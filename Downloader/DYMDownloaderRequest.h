//
//  DYMDownloaderRequest.h
//  Downloader
//
//  Created by John on 2017/5/19.
//  Copyright © 2017年 yoloho.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DYMDownloaderRequest;

@protocol DYMDownloaderRequestDelegate <NSObject>

- (void)downloadWillBeginRequest:(DYMDownloaderRequest *)request;
- (void)downloadDidRequest:(DYMDownloaderRequest *)request reciveLength:(CGFloat)reciveLength;

@end

@interface DYMDownloaderRequest : NSOperation

@property (nonatomic, weak) id<DYMDownloaderRequestDelegate> delegate;

@property (nonatomic, copy) NSString *downloadUrl;
@property (nonatomic, copy) NSString *downloadFilePath;
@property (nonatomic, copy) NSString *tempLoadFilePath;

@end
