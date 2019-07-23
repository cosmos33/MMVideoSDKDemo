//
//  MDMomentMusicListCell.m
//  MDChat
//
//  Created by wangxuan on 17/2/14.
//  Copyright © 2017年 sdk.com. All rights reserved.
//

#import "MDMomentMusicListCell.h"
#import "MDRecordHeader.h"

static const CGFloat kCellLeftRightMargin = 15;
static const CGFloat kCellElemnetInsetMargin = 7;

#define kGuideText      @"滑动两端截取音乐"

@interface MDMomentMusicListCell ()

@property (nonatomic, strong) MDSMSelectIntervalProgressView            *trimView;
@property (nonatomic, strong) UILabel                                   *descLabel;
@property (nonatomic, strong) UIImageView                               *downloadIcon;
@property (nonatomic, strong) CADisplayLink                             *displayLink;
@property (nonatomic, strong) UIImageView                               *loadingView;
@property (nonatomic, strong) UILabel                                   *guideLabel;

@property (nonatomic, weak) id<MDMomentMusicListCellDelegate>           delegate;
@property (nonatomic, strong) MDMomentMusicListCellModel                *cellModel;

@end

@implementation MDMomentMusicListCell

#pragma mark - life
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])  {
    //    [self addNotification];
    }
    return self;
}

- (void)bindDelegate:(id)target {
    self.delegate = target;
}

- (void)dealloc {
}

#pragma mark - updateCell
- (void)updateCellWithModel:(MDMomentMusicListCellModel *)cellModel musicItem:(MDBeautyMusic *)musicItem {
    
    cellModel.localUrl = [MDBeautyMusicManager getMusicLocalPath:musicItem];
    self.cellModel = cellModel;
    self.cellModel.dataObj = musicItem;
    
    self.titleLabel.text = musicItem.m_title;
    self.titleLabel.textColor = cellModel.isSelected ? RGBCOLOR(0, 192, 255) : [UIColor whiteColor];
    if ([musicItem.m_desc isNotEmpty]) {
        self.descLabel.text = musicItem.m_desc;
    } else {
        self.descLabel.text = @"";
    }
    
    BOOL showTrim = cellModel.isSelected && cellModel.localUrl;
    if (showTrim) {
        self.trimView.hidden = NO;
        self.trimView.beginValue = cellModel.musicStartPercent;
        self.trimView.endValue = cellModel.musicEndPercent;
        self.guideLabel.hidden = NO;
        if(cellModel.musicStartPercent > 0 || cellModel.musicEndPercent < 1.0) {
            CGFloat cutTime = [self cutDuration];
            [self setGideLabelText:[MDRecordContext formatRemainSecondToStardardTime:cutTime]];
        }else{
            [self setGideLabelText:kGuideText];
        }
    }else{
        _trimView.hidden = YES;
        _guideLabel.hidden = YES;
    }

    [self updateAllFrames];
    [self updateDownloadingStatus];
}

- (void)updateAllFrames {
    MDBeautyMusic *musicItem = self.cellModel.dataObj;
    CGFloat guideLabelWidth = self.guideLabel.hidden ? 0 : self.guideLabel.width;
    self.titleLabel.centerY = kMomentMusicListCellHeight / 2.0;
    if ([musicItem.m_desc isNotEmpty]) {
        CGFloat desclabelWith = [self.descLabel sizeThatFits:CGSizeMake(MDScreenWidth, 25)].width;
        self.descLabel.width = desclabelWith;
        CGFloat maxtitleLabelWidth = MDScreenWidth - kCellLeftRightMargin*4 - self.descLabel.width - guideLabelWidth;
        CGFloat realTitleLabelWidth = [self.titleLabel sizeThatFits:CGSizeMake(maxtitleLabelWidth, 25)].width;
        realTitleLabelWidth = MIN(realTitleLabelWidth, maxtitleLabelWidth);
        self.titleLabel.width = realTitleLabelWidth;
        self.descLabel.left = self.titleLabel.right + kCellElemnetInsetMargin;
    } else {
        self.titleLabel.width = MDScreenWidth - kCellLeftRightMargin*4 -self.downloadIcon.width - guideLabelWidth;
    }
}

- (CGFloat)cutDuration {
    AVAsset *songAsset = [AVURLAsset assetWithURL:self.cellModel.localUrl];
    CGFloat second = CMTimeGetSeconds(songAsset.duration);
    CGFloat cutTime = (self.cellModel.musicEndPercent - self.cellModel.musicStartPercent) * second;
    return cutTime;
}

- (void)updateDownloadingStatus {
    MDBeautyMusic *musicItem = self.cellModel.dataObj;
    self.downloadIcon.hidden = self.cellModel.localUrl || self.cellModel.isDownloading || !musicItem.m_remoteUrl;
    //进度条
    if (self.cellModel.isDownloading) {
        [self showLoadingView];
    } else {
        [self hideLoadingView];
    }
}

#pragma mark - action
- (void)updateCellDownloadingStatus:(NSNotification *)ntf {
    NSDictionary *userInfo = ntf.userInfo;
    NSString *musicID = [userInfo stringForKey:@"musicID" defaultValue:nil];
    NSString *remoteURL = [userInfo stringForKey:@"musicRemoteURL" defaultValue:nil];
    NSInteger status = [userInfo integerForKey:@"loadStatus" defaultValue:0];
    
    MDBeautyMusic *musicItem = self.cellModel.dataObj;
    if(status != 0 && [musicID isEqualToString:self.cellModel.identifier] && [remoteURL isEqualToString:musicItem.m_remoteUrl]) {
        switch (status) {
            case 1:
            {
                self.cellModel.isDownloading = YES;
                break;
            }
            case 2:
            {
                self.cellModel.isDownloading = NO;
                break;
            }
            default:
                break;
        }
        [self updateDownloadingStatus];
    }
}

#pragma mark - Private

- (void)setGideLabelText:(NSString *)text {
    self.guideLabel.text = text;
    CGFloat realWidth = [self.guideLabel sizeThatFits:CGSizeMake(MDScreenWidth, 20)].width;
    self.guideLabel.width = realWidth;
    self.guideLabel.right = MDScreenWidth - 15;
    self.guideLabel.centerY = self.titleLabel.centerY;
}

- (void)setBegainPoint:(CGFloat)begainPoint {
    AVAsset *songAsset = [AVURLAsset assetWithURL:self.cellModel.localUrl];
    CGFloat second = CMTimeGetSeconds(songAsset.duration);
    CGFloat deta = self.cellModel.musicEndPercent - begainPoint;
    CGFloat vala = kLeastMusicDuration / second;
    if(deta <= vala) {
        begainPoint = self.cellModel.musicEndPercent - vala;
        self.trimView.beginValue = begainPoint;
    }
    self.cellModel.musicStartPercent = begainPoint;
    [self sendMusicPointInfoToHandler:self.cellModel.musicStartPercent endPiont:self.cellModel.musicEndPercent];
}

- (void)setEndPoint:(CGFloat)endPoint {
    AVAsset *songAsset = [AVURLAsset assetWithURL:self.cellModel.localUrl];
    CGFloat second = CMTimeGetSeconds(songAsset.duration);
    CGFloat deta = endPoint - self.cellModel.musicStartPercent;
    CGFloat vala = kLeastMusicDuration / second;
    if(deta <= vala) {
        endPoint = self.cellModel.musicStartPercent + vala;
        self.trimView.endValue = endPoint;
    }
    self.cellModel.musicEndPercent = endPoint;
    [self sendMusicPointInfoToHandler:self.cellModel.musicStartPercent endPiont:self.cellModel.musicEndPercent];
}

- (void)sendMusicPointInfoToHandler:(CGFloat)begain endPiont:(CGFloat)end {
    
    self.cellModel.musicStartPercent = begain;
    self.cellModel.musicEndPercent = end;
    
    CGFloat cutTime = [self cutDuration];
    [self setGideLabelText:[MDRecordContext formatRemainSecondToStardardTime:cutTime]];
    if(self.delegate && [self.delegate respondsToSelector:@selector(currentMusic:begainPoint:endPoint:)]) {
        [self.delegate currentMusic:self.cellModel begainPoint:begain endPoint:end];
    }
}

#pragma mark - lazy
- (UILabel *)descLabel
{
    if (!_descLabel) {
        UIFont *font = [UIFont systemFontOfSize:14];
        NSInteger fontWidth = ceil(font.lineHeight);
        _descLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, fontWidth *4, kMomentMusicListCellHeight)];
        _descLabel.font = font;
        _descLabel.textColor = RGBACOLOR(255, 255, 255, 0.3);
        [self.contentView addSubview:_descLabel];
    }
    return _descLabel;
}

- (MDSMSelectIntervalProgressView *)trimView
{
    if (!_trimView) {
        _trimView = [[MDSMSelectIntervalProgressView alloc] initWithFrame:CGRectMake(7, kMomentMusicListCellHeight, MDScreenWidth - 14, kMusicCellTrimmerViewHeight)];
        _trimView.backgroundColor = RGBACOLOR(0, 0, 0, 0.2);
        _trimView.marginLineHightColor = [UIColor whiteColor];
        _trimView.marginLineColor = RGBCOLOR(92, 92, 92);
        _trimView.progressColor = RGBCOLOR(0, 156, 255);
        _trimView.trackColor = RGBCOLOR(0, 253, 211);
        _trimView.inactiveColor = RGBACOLOR(255, 255, 255, 0.2);
        _trimView.selectAreaBgColor = RGBACOLOR(255, 255, 255, 0.05);
        _trimView.beginValue = 0;
        _trimView.endValue = 1.0;
        _trimView.currentValue = 0;
        [self.contentView addSubview:_trimView];
        _trimView.hidden = YES;
        __weak __typeof(self) weakSelf = self;
        [_trimView setValueHandleBlock:^(CGFloat vaule, ChangeValueType valueType, TouchStatus status) {
            if(status != TouchStatusMove) {
                if(valueType == ChangeValueTypeBegin) {
                    [weakSelf setBegainPoint:vaule];
                }else{
                    [weakSelf setEndPoint:vaule];
                }
            }
        }];
    }
    return _trimView;
}

- (void)setProgress:(float)progress {
    if(_progress != progress) {
        _progress = progress;
        if (!_trimView.hidden) {
            _trimView.currentValue = _progress;
        }
    }
}

- (UIImageView *)downloadIcon
{
    if (!_downloadIcon) {
        UIImage *img = [UIImage imageNamed:@"icon_moment_download"];
        _downloadIcon = [[UIImageView alloc] initWithFrame:CGRectMake(MDScreenWidth -img.size.width- 15, 0, img.size.width, img.size.height)];
        _downloadIcon.image = img;
        _downloadIcon.centerY = self.titleLabel.centerY;
        [self.contentView addSubview:_downloadIcon];
    }
    
    return _downloadIcon;
}

- (UIImageView *)loadingView
{
    if (!_loadingView) {
        UIImage *img = [UIImage imageNamed:@"background_music_loading"];
        _loadingView = [[UIImageView alloc] initWithFrame:self.downloadIcon.bounds];
        _loadingView.contentMode = UIViewContentModeScaleAspectFit;
        _loadingView.center = self.downloadIcon.center;
        _loadingView.image = img;
        [self.contentView addSubview:_loadingView];
    }
    
    return _loadingView;
}

- (UILabel *)guideLabel {
    if(!_guideLabel) {
        _guideLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        _guideLabel.backgroundColor = [UIColor clearColor];
        _guideLabel.textColor = [UIColor whiteColor];
        _guideLabel.font = [UIFont systemFontOfSize:10];
        _guideLabel.textAlignment = NSTextAlignmentRight;
        _guideLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _guideLabel.numberOfLines = 1;
        [self.contentView addSubview:_guideLabel];
    }
    return _guideLabel;
}

-(CADisplayLink *)displayLink {
    
    if (!_displayLink) {
        MDWeakProxy *weakProxy = [MDWeakProxy weakProxyForObject:self];
        _displayLink = [CADisplayLink displayLinkWithTarget:weakProxy selector:@selector(displayDidRefresh:)];
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    
    return _displayLink;
}

- (void)displayDidRefresh:(CADisplayLink *)displayLink {
    
    CGAffineTransform transform = self.loadingView.transform;
    
    NSTimeInterval duration = 1;
    CGFloat rotationAnglePerRefresh = (2*M_PI)/(duration*60.0);
    self.loadingView.transform = CGAffineTransformRotate(transform, rotationAnglePerRefresh);
}

- (void)showLoadingView
{
    self.loadingView.hidden = NO;
    self.displayLink.paused = NO;
}

- (void)hideLoadingView
{
    self.loadingView.hidden = YES;
    self.displayLink.paused = YES;
}

@end
