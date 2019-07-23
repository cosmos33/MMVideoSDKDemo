//
//  MDBeautyMusicVolumeView.m
//  MDChat
//
//  Created by Fu.Chen on 2018/5/9.
//  Copyright © 2018年 sdk.com. All rights reserved.
//

#import "MDBeautyMusicVolumeView.h"
#import "MDVolumeBarView.h"
#import "MDRecordHeader.h"

@interface MDBeautyMusicVolumeView()<MDVolumeBarViewDelegate>

@property (nonatomic,strong) UIImageView        *voiceImageView;
@property (nonatomic,strong) UIImageView        *musicImageView;
@property (nonatomic,strong) UILabel            *voiceLabel;
@property (nonatomic,strong) UILabel            *musicLabel;
@property (nonatomic,strong) UILabel            *musicNameLabel;
@property (nonatomic,strong) MDVolumeBarView    *volumeBarView;
@end
@implementation MDBeautyMusicVolumeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%s",__func__);
#endif
}

- (void)setupUI{
    [self addSubview:self.voiceImageView];
    [self addSubview:self.musicImageView];
    [self addSubview:self.voiceLabel];
    [self addSubview:self.musicLabel];
    [self addSubview:self.volumeBarView];
    [self addSubview:self.musicNameLabel];
}

- (CGFloat)progress {
    return self.volumeBarView.progress;
}

- (void)updateVolumeProgress:(CGFloat)progress {
    self.volumeBarView.progress = progress;
    [self updateWithProgress:progress];
}

- (void)setMusicNameText:(NSString *)name {
    name = [name isNotEmpty] ? name : @"音乐：无音乐";
    self.musicNameLabel.text = name;
}

#pragma mark - VolumeBarViewDelegate
-(void)progressDidChange:(CGFloat)aProgress{
    [self updateWithProgress:aProgress];
    if([self.delegate respondsToSelector:@selector(progressDidChange:)]){
        [self.delegate progressDidChange:aProgress];
    }
}

- (void)updateWithProgress:(CGFloat)aProgress {
    int progress = (int)(aProgress * 100);
    self.musicLabel.text= [NSString stringWithFormat:@"%d%%",progress];
    self.voiceLabel.text = [NSString stringWithFormat:@"%d%%",100 - progress];
    if(aProgress <= 0) {
        self.musicImageView.image = [UIImage imageNamed:@"recordsdk-mute_iconVideoMusic"];
        self.voiceImageView.image = [UIImage imageNamed:@"recordsdk-origin"];
    }else if (aProgress >= 1.0) {
        self.musicImageView.image = [UIImage imageNamed:@"recordsdk-iconVideoMusic"];
        self.voiceImageView.image = [UIImage imageNamed:@"recordsdk-originMute"];
    }else{
        self.musicImageView.image = [UIImage imageNamed:@"recordsdk-iconVideoMusic"];
        self.voiceImageView.image = [UIImage imageNamed:@"recordsdk-origin"];
    }
}

#pragma mark - lazy
- (UIImageView *)voiceImageView{
    if(!_voiceImageView){
        _voiceImageView = [[UIImageView alloc]initWithFrame:CGRectMake(15, 19, 25, 25)];
        _voiceImageView.image = [UIImage imageNamed:@"recordsdk-origin"];
    }
    return _voiceImageView;
}
- (UIImageView *)musicImageView{
    if(!_musicImageView){
        _musicImageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.bounds.size.width - 40, 19, 25, 25)];
        _musicImageView.image = [UIImage imageNamed:@"recordsdk-iconVideoMusic"];
    }
    return _musicImageView;
}
- (UILabel *)voiceLabel{
    if(!_voiceLabel){
        _voiceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.voiceImageView.bottom + 4,31 ,14.5)];
        _voiceLabel.font = [UIFont systemFontOfSize:10];
        _voiceLabel.textColor = RGBACOLOR(255, 255, 255, 0.4);
        _voiceLabel.centerX = self.voiceImageView.centerX;
        _voiceLabel.numberOfLines = 1;
        _voiceLabel.text = @"50%";
        _voiceLabel.textAlignment = NSTextAlignmentCenter;
    }
    return  _voiceLabel;
}
- (UILabel *)musicLabel{
    if(!_musicLabel){
        _musicLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.musicImageView.bottom + 4,31, 14.5)];
        _musicLabel.font = [UIFont systemFontOfSize:10];
        _musicLabel.textColor = RGBACOLOR(255, 255, 255, 0.4);
        _musicLabel.centerX = self.musicImageView.centerX;
        _musicLabel.numberOfLines = 1;
        _musicLabel.text = @"50%";
        _musicLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _musicLabel;
}
- (MDVolumeBarView *)volumeBarView{
    if(!_volumeBarView){
        _volumeBarView = [[MDVolumeBarView alloc]initWithFrame:CGRectMake(0, 0, self.width - 110, 18)];
        _volumeBarView.centerY = self.musicImageView.centerY;
        _volumeBarView.centerX = self.bounds.size.width / 2;
        _volumeBarView.delegate = self;
    }
    return _volumeBarView;
}
- (UILabel *)musicNameLabel{
    if(!_musicNameLabel){
        _musicNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.width - self.voiceLabel.right * 2 - 10, 12)];
        _musicNameLabel.centerX = self.volumeBarView.centerX;
        _musicNameLabel.centerY = self.musicLabel.centerY;
        _musicNameLabel.font = [UIFont systemFontOfSize:10];
        _musicNameLabel.textColor = RGBCOLOR(255, 255, 255);
        _musicNameLabel.alpha = 0.4;
        _musicNameLabel.textAlignment = NSTextAlignmentCenter;
        _musicNameLabel.text = @"音乐：无音乐";
    }
    return _musicNameLabel;
}
@end
