//
//  AFNetSeriviceManager.h
//  Downloader
//
//  Created by John on 2017/5/24.
//  Copyright © 2017年 yoloho.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface AFNetworkServiceManager : NSObject

+ (instancetype)sharedInstanced;

- (NSURLSessionDownloadTask *)dowoloadUrl:(NSString *)url filePath:(NSString *)filePath progress:(void (^) (NSProgress *progress))progress completedBlock:(void(^) (BOOL isFinished, NSError *error))completedBlcok;

@end
