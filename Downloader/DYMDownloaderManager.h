//
//  DYMDownloaderManager.h
//  Downloader
//
//  Created by John on 2017/5/19.
//  Copyright © 2017年 yoloho.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^completedBlock) (CGFloat progress, BOOL finished);

@interface DYMDownloaderManager : NSObject

- (void)downloadUrl:(NSString *)url completedBlock:(completedBlock)completedBlock;

@end
