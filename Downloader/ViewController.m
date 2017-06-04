//
//  ViewController.m
//  Downloader
//
//  Created by John on 2017/5/19.
//  Copyright © 2017年 yoloho.com. All rights reserved.
//

#import "ViewController.h"

#import "DYMDownloaderManager.h"
#import "DownloadInfoMessage.h"

NSString *const prepareDownload = @"prepareDownload";
NSString *const downloading = @"downloading";
NSString *const downloadFinished = @"finished";



@class DownloadTabelViewCell;

@protocol DownloadTabelViewCellDelegate <NSObject>

- (void)downloadDidSeletedCell:(DownloadTabelViewCell *)cell;

@end


@interface DownloadTabelViewCell : UITableViewCell

@property (nonatomic, weak) UILabel *downloadNameLabel;

@property (nonatomic, weak) UIButton *downloadButton;

@property (nonatomic, weak) UIProgressView *progressView;

@property (nonatomic, weak) id<DownloadTabelViewCellDelegate> delegate;

@property (nonatomic) DownloadInfoMessage *info;

@end

@implementation DownloadTabelViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        UILabel *downloadNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        downloadNameLabel.numberOfLines = 1;
        downloadNameLabel.font = [UIFont systemFontOfSize:14.0f];
        downloadNameLabel.backgroundColor = [UIColor clearColor];
        downloadNameLabel.textColor = [UIColor blackColor];
        
        [self.contentView addSubview:downloadNameLabel];
        
        _downloadNameLabel = downloadNameLabel;
        
        
        UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [downloadButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [downloadButton addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
        downloadButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [self.contentView addSubview:downloadButton];
        _downloadButton = downloadButton;
        
        
        UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectZero];
        progressView.progress = 0;
        [self.contentView addSubview:progressView];
        _progressView = progressView;
        
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = [self.downloadNameLabel sizeThatFits:CGSizeMake(self.frame.size.width - 100, MAXFLOAT)];
    
    self.downloadNameLabel.frame = CGRectMake(10, 10, self.frame.size.width - 100, size.height);
    
    self.downloadButton.frame = CGRectMake(self.downloadNameLabel.frame.origin.x + self.downloadNameLabel.frame.size.width + 10, 0, 50, 50);
    
    self.progressView.frame = CGRectMake(10, self.downloadNameLabel.frame.origin.y + self.downloadNameLabel.frame.size.height + 20, self.frame.size.width - 20, 10);
}

- (void)buttonPress:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(downloadDidSeletedCell:)]) {
        [self.delegate downloadDidSeletedCell:self];
    }
}

- (void)setData:(DownloadInfoMessage *)data {
    _info = data;
    self.downloadNameLabel.text = data.downloadUrl.lastPathComponent;
    [self.downloadButton setTitle:data.isFinished ? @"完成":@"下载中" forState:UIControlStateNormal];
    self.progressView.progress = data.currentSize == 0 ? 0 : data.currentSize * 1.0 / data.fileSize;
    [self setNeedsLayout];
}

- (NSString *)stringOfState:(DownloadState)state {
    
    NSString *str = @"";
    return str;
    
}

@end


@interface ViewController () <UITableViewDelegate, UITableViewDataSource,DownloadTabelViewCellDelegate, NSURLSessionDataDelegate, DYMDownloadManagerDelegate>

@property (nonatomic, weak) UITableView *downloadList;

@property (nonatomic, copy) NSArray *sectionArray;
@property (nonatomic, copy) NSDictionary *dataSource;

@end

@implementation ViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView {
    [super loadView];

    UITableView *downloadList = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    downloadList.delegate = self;
    downloadList.dataSource = self;
    [self.view addSubview:downloadList];
    _downloadList = downloadList;
 
    [downloadList registerClass:[DownloadTabelViewCell class] forCellReuseIdentifier:@"downloadCellIdentifire"];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sectionArray = @[@"正在下载",@"已完成"];

    
    [DYMDownloaderManager sharedInstance].downloadDelegate = self;
    
    // Do any additional setup after loading the view, typically from a nib.
}


//#pragma notification
//
//- (void)downloadFinished:(NSNotification *)nf {
//    [self reloadData];
//}
//
//- (void)downloadProgressChanged:(NSNotification *)nf {
//    NSDictionary *progressInfo = [nf object];
//    for (DownloadInfoMessage *info in [self.dataSource[self.sectionArray[0]] copy]) {
//        if ([info.indentifire isEqualToString:progressInfo[DownloadIdentifire]]) {
//            info.fileSize = [progressInfo[DownloadTotalProgress] longLongValue];
//            info.currentSize = [progressInfo[DownloadCurrentProgress] longLongValue];
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.downloadList reloadData];
//            });
//            
//            break;
//        }
//    }
//}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadData];
}

- (void)reloadData {
    NSArray *unFinished = [DYMDownloaderManager sharedInstance].unFinishedList.copy;
    
    NSMutableDictionary *dataSource = [NSMutableDictionary dictionaryWithDictionary:self.dataSource];
    
    [dataSource setValue:unFinished forKey:self.sectionArray[0]];
    
    NSArray *finished = [DYMDownloaderManager sharedInstance].finishedList.copy;
    
    [dataSource setValue:finished forKey:self.sectionArray[1]];
    
    self.dataSource = dataSource.copy;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.downloadList reloadData];
    });

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource[self.sectionArray[section]] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.dataSource[self.sectionArray[indexPath.section]] count] > 0) {
        return 60;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sectionArray[section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DownloadTabelViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"downloadCellIdentifire" forIndexPath:indexPath];
    DownloadInfoMessage *info = self.dataSource[self.sectionArray[indexPath.section]][indexPath.row];
    if (info) {
        [cell setData:info];
        cell.delegate = self;
    }
    return cell;

}


- (void)downloadDidSeletedCell:(DownloadTabelViewCell *)cell  {
    NSIndexPath *indexPath = [self.downloadList indexPathForCell:cell];
    if (indexPath) {
        DownloadInfoMessage *info = self.dataSource[self.sectionArray[indexPath.section]][indexPath.row];
        info.isPause = !info.isPause;
        if (info.isPause) {
            [[DYMDownloaderManager sharedInstance] startDownloadUrl:info.downloadUrl];
        } else {
            [[DYMDownloaderManager sharedInstance] cancelDownloadUrl:info.downloadUrl];
        }
    }
}

- (void)downloadFinished:(DYMDownloaderManager *)downloadManager {
    [self reloadData];
}

- (void)downloadExistTask:(DYMDownloaderManager *)downloadManager {

}

- (void)downloadUpdateProgress:(DYMDownloaderManager *)downloadManager identifire:(NSString *)indentifire {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"indentifire = %@",indentifire];
    NSArray *downloading = self.dataSource[self.sectionArray[0]];
    
    NSArray *filtArray = [downloading filteredArrayUsingPredicate:predicate];
    
    if (filtArray.count > 0) {
        DownloadInfoMessage *info = downloading.lastObject;
        
        for (DownloadTabelViewCell *cell in self.downloadList.visibleCells) {
            if ([cell.info.indentifire isEqualToString:info.indentifire]) {
                [cell setData:info];
            }
            
        }
    }
    
}

@end
