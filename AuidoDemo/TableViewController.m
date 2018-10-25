//
//  TableViewController.m
//  AuidoDemo
//
//  Created by Lee on 2018/10/24.
//  Copyright © 2018 Lee. All rights reserved.
//

#import "TableViewController.h"
#import "TableViewCell.h"
#import <AVFoundation/AVFoundation.h>
#import <KTVHTTPCache/KTVHTTPCache.h>

@interface TableViewController ()

@property (nonatomic, strong) NSArray * medaiItems;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@property (nonatomic, copy) NSString *nowUrl;
@property (nonatomic, strong) TableViewCell *nowCell;
@property (nonatomic, assign) CGFloat nowTime;
@property (nonatomic, assign) NSInteger nowIndex;
@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setupHTTPCache];
    });
    
    _medaiItems = @[@"https://aliuwmp3.changba.com/userdata/video/45F6BD5E445E4C029C33DC5901307461.mp4",
                    @"https://aliuwmp3.changba.com/userdata/video/3B1DDE764577E0529C33DC5901307461.mp4",
                    @"https://qiniuuwmp3.changba.com/941946870.mp4",
                    @"https://lzaiuw.changba.com/userdata/video/940071102.mp4",
                    @"https://aliuwmp3.changba.com/userdata/video/45F6BD5E445E4C029C33DC5901307461.mp4",
                    @"https://aliuwmp3.changba.com/userdata/video/3B1DDE764577E0529C33DC5901307461.mp4",
                    @"https://qiniuuwmp3.changba.com/941946870.mp4",
                    @"https://lzaiuw.changba.com/userdata/video/940071102.mp4",
                    @"https://aliuwmp3.changba.com/userdata/video/45F6BD5E445E4C029C33DC5901307461.mp4",
                    @"https://aliuwmp3.changba.com/userdata/video/3B1DDE764577E0529C33DC5901307461.mp4",
                    @"https://qiniuuwmp3.changba.com/941946870.mp4",
                    @"https://lzaiuw.changba.com/userdata/video/940071102.mp4",
                    @"https://aliuwmp3.changba.com/userdata/video/45F6BD5E445E4C029C33DC5901307461.mp4",
                    @"https://aliuwmp3.changba.com/userdata/video/3B1DDE764577E0529C33DC5901307461.mp4",
                    @"https://qiniuuwmp3.changba.com/941946870.mp4",
                    @"https://lzaiuw.changba.com/userdata/video/940071102.mp4"];
    
    
    self.player = [AVPlayer playerWithURL:[NSURL URLWithString:@""]];
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    NSLog(@"%@", NSHomeDirectory());
}

- (void)setupHTTPCache
{
    [KTVHTTPCache logSetConsoleLogEnable:YES];
    NSError * error;
    [KTVHTTPCache proxyStart:&error];
    if (error) {
        NSLog(@"Proxy Start Failure, %@", error);
    } else {
        NSLog(@"Proxy Start Success");
    }
    [KTVHTTPCache tokenSetURLFilter:^NSURL * (NSURL * URL) {
        NSLog(@"URL Filter reviced URL : %@", URL);
        return URL;
    }];
    [KTVHTTPCache downloadSetUnsupportContentTypeFilter:^BOOL(NSURL * URL, NSString * contentType) {
        NSLog(@"Unsupport Content-Type Filter reviced URL : %@, %@", URL, contentType);
        return NO;
    }];
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _medaiItems.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    cell.url = _medaiItems[indexPath.row];
    __weak typeof(self) weakSelf = self;
    cell.clickBlock = ^(TableViewCell *cell, NSString *url) {
        weakSelf.nowIndex = indexPath.row;
        [weakSelf playWithCell:cell url:url];
    };
    return cell;
}

- (void)playWithCell:(TableViewCell *)cell url:(NSString *)urlStr {
    if ([urlStr isEqualToString:_nowUrl]) {
        NSLog(@"点击同一个cell");
        return;
    }
    [self.nowCell.activityIndicator stopAnimating];
    _nowUrl = urlStr;
    _nowCell = cell;
    [_playerLayer removeFromSuperlayer];
    [self.player pause];
    NSString * URLString = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString * proxyURLString = [KTVHTTPCache proxyURLStringWithOriginalURLString:URLString];
    [self.player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:[NSURL URLWithString:proxyURLString]]];
    [self addStatusObserver];
    [self addProgressObserver];
}

- (void)addStatusObserver {
    [self.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [self.player.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.nowCell isEqual:cell]) {
        [self.player pause];
        [self.playerLayer removeFromSuperlayer];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(AVPlayerItem *)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        switch (self.player.status) {
            case AVPlayerStatusUnknown:
                NSLog(@"KVO：未知状态，此时不能播放");
                break;
            case AVPlayerStatusReadyToPlay:
                NSLog(@"KVO：准备完毕，可以播放");
                [self.nowCell.activityIndicator stopAnimating];
                [self.player play];
                _playerLayer.frame = self.nowCell.bounds;
                [self.nowCell.bgView.layer addSublayer:_playerLayer];
                break;
            case AVPlayerStatusFailed:
                NSLog(@"KVO：加载失败，网络或者服务器出现问题");
                break;
            default:
                break;
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSArray *array = object.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;;
        NSLog(@"缓存总时长：%0.2f, 总时长: %0.2f, 已播放时间: %0.2f", totalBuffer, CMTimeGetSeconds(object.duration), self.nowTime);
        if (totalBuffer > self.nowTime + 20) {
            //缓存下面3个视频
            [self cacheNextVideo:self.nowIndex];
        }
    }
}

- (void)addProgressObserver {
    __weak typeof(self) weakSelf = self;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        weakSelf.nowTime = CMTimeGetSeconds(time);
    }];
}


- (void)cacheNextVideo:(NSInteger)index {
    
    NSMutableArray *urlArr = [NSMutableArray array];
    for (int i = 1; i < 4; i ++) {
        if (index + i < self.medaiItems.count) {
            [urlArr addObject:self.medaiItems[index + i]];
        }
    }
    
    for (NSString *url in urlArr) {
        NSString * URLString = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        
        NSString * proxyURLString = [KTVHTTPCache proxyURLStringWithOriginalURLString:URLString];
        
//        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        NSURLSession *session = [NSURLSession sharedSession];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:proxyURLString]];
        //设置请求头range
        [request setValue:@"bytes" forHTTPHeaderField:@"Accept-Ranges"];
        [request setValue:@"bytes=0-3000000" forHTTPHeaderField:@"Range"];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
            [task resume];
        });
    }
    
}

@end
