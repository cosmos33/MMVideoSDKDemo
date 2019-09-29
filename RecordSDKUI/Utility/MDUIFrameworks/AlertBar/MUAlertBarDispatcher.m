//
//  MUAlertBarDispatcher.m
//  RecordSDKUIFoundation
//
//  Created by Aaron on 16/6/12.
//  Copyright © 2016年 RecordSDK. All rights reserved.
//

#import "MUAlertBarDispatcher.h"
//#import "SDWebImage.h"
#import "UIPublic.h"
#import "SDWebImage/UIImageView+WebCache.h"

@implementation MUAlertBarDispatcher

+(MUAlertBar *)alertBarWithModel:(MUAlertBarModel *)model {
    MUAlertBar *bar = nil;
    switch (model.type) {
        case MUAlertBarTypeAt1:
        {
            MUAt1AlertBarModel *model1 = (MUAt1AlertBarModel *)model;
            MUAt1AlertBar *bar1 = [MUAt1AlertBar new];
            bar1.model = model1;
            bar1.width = kAt1AlertWidth;
            bar1.height = kAt1AlertHeight;
            //icon位置
            bar1.iconView.left = kAt1AlertIconOffset;
            //label位置
            bar1.infoLabel.left = bar1.iconView.right+kAt1AlertTitleOffset;
            bar1.infoLabel.font = kAt1AlertFont;
            bar1.infoLabel.textColor = kAt1AlertFontColor;
            bar1.infoLabel.width = bar1.width-bar1.infoLabel.left;
            bar1.infoLabel.text = model1.title;
            //点击回调
            bar1.clickBlock = model1.clickBlock;
            
            bar = bar1;
        }
            break;
            
        case MUAlertBarTypeAt2:
        {
            MUAt2AlertBarModel *model2 = (MUAt2AlertBarModel *)model;
            MUAt1AlertBar *bar2 = [MUAt1AlertBar new];
            bar2.model = model2;
            bar2.width = kAt2AlertWidth;
            bar2.height = kAt2AlertHeight;
            //icon位置
            bar2.iconView.left = kAt2AlertIconOffset;
            //箭头位置
            bar2.arrorView.right = bar2.width-kAt2AlertAccessoryOffset;
            //label位置
            bar2.infoLabel.left = bar2.iconView.right+kAt2AlertTitleOffset;
            bar2.infoLabel.font = kAt2AlertFont;
            bar2.infoLabel.textColor = kAt2AlertFontColor;
            bar2.infoLabel.width = bar2.arrorView.left-bar2.infoLabel.left;
            bar2.infoLabel.text = model2.title;
            bar2.clickBlock = model2.clickBlock;

            bar = bar2;
        }
            break;
            
        case MUAlertBarTypeAt3:
        {
            MUAt3AlertBarModel *model3 = (MUAt3AlertBarModel *)model;
            MUAt1AlertBar *bar3 = [MUAt1AlertBar new];
            bar3.model = model3;
            bar3.width = kAt3AlertWidth;
            bar3.height = kAt3AlertHeight;
            //icon位置
            bar3.iconView.left = kAt3AlertIconOffset;
            //箭头位置
            bar3.arrorView.right = bar3.lineView.left-kAt3AlertAccessoryOffset1;
            //label位置
            bar3.infoLabel.left = bar3.iconView.right+kAt3AlertTitleOffset;
            bar3.infoLabel.font = kAt3AlertFont;
            bar3.infoLabel.textColor = kAt3AlertFontColor;
            bar3.infoLabel.width = bar3.arrorView.left-bar3.infoLabel.left;
            bar3.infoLabel.text = model3.title;
            //回调
            bar3.clickBlock = model3.clickBlock;
            bar3.closeBlock = model3.closeBlock;
            
            bar = bar3;
        }
            break;
            
        case MUAlertBarTypeAt4:
        {
            MUAt4AlertBarModel *model4 = (MUAt4AlertBarModel *)model;
            MUAt4AlertBar *bar4 = [MUAt4AlertBar new];
            bar4.model = model4;
            bar4.width = kAt4AlertWidth;
            bar4.height = kAt4AlertHeight;
            //箭头位置
            bar4.arrorView.right = bar4.width-kAt4AlertAccessoryOffset;
            //label、subtitleLabel位置
            bar4.titleLabel.font = kAt4AlertFont;
            bar4.titleLabel.textColor = kAt4AlertFontColor;
            bar4.titleLabel.text = model4.title;
            CGSize size = [bar4.titleLabel sizeThatFits:CGSizeMake(1000, 20)];
            bar4.titleLabel.left = kAt4AlertTitleOffset;
            bar4.titleLabel.width = bar4.arrorView.left-kAt4AlertTitleOffset;
            bar4.titleLabel.height = size.height;
            
            bar4.subtitleLabel.font = kAt4AlertSubtitleFont;
            bar4.subtitleLabel.textColor = kAt4AlertSubtitleFontColor;
            bar4.subtitleLabel.text = model4.subtitle;
            CGSize subSize = [bar4.subtitleLabel sizeThatFits:CGSizeMake(1000, 20)];
            bar4.subtitleLabel.left = kAt4AlertTitleOffset;
            bar4.subtitleLabel.width = bar4.arrorView.left-kAt4AlertTitleOffset;
            bar4.subtitleLabel.height = subSize.height;
            
            bar4.titleLabel.top = (bar4.height-size.height-subSize.height-kAt4AlertTitleSpace)/2.0;
            bar4.subtitleLabel.top = bar4.titleLabel.bottom+kAt4AlertTitleSpace;
            //回调
            bar4.clickBlock = model4.clickBlock;
            
            bar = bar4;
        }
            break;
            
        case MUAlertBarTypeAt5:
        {
            MUAt5AlertBarModel *model5 = (MUAt5AlertBarModel *)model;
            MUAt4AlertBar *bar5 = [MUAt4AlertBar new];
            bar5.model = model5;
            bar5.width = kAt5AlertWidth;
            bar5.height = kAt5AlertHeight;
            //箭头位置
            bar5.arrorView.right = bar5.width-kAt5AlertAccessoryOffset;
            //头像位置
            bar5.headerView.right = kAt5AlertIconOffset;
            bar5.headerView.height = 35;
            bar5.headerView.width = 35;
            bar5.headerView.centerY = bar5.height/2.0;
            bar5.headerView.backgroundColor = [UIColor blackColor];
            [bar5.headerView sd_setImageWithURL:[NSURL URLWithString: model5.headerURL]];
            //label、subtitleLabel位置
            bar5.titleLabel.font = kAt5AlertFont;
            bar5.titleLabel.textColor = kAt5AlertFontColor;
            bar5.titleLabel.text = model5.title;
            CGSize size = [bar5.titleLabel sizeThatFits:CGSizeMake(1000, 20)];
            bar5.titleLabel.left = bar5.headerView.right+kAt5AlertTitleOffset;
            bar5.titleLabel.width = bar5.arrorView.left-bar5.titleLabel.left;
            bar5.titleLabel.height = size.height;
            
            bar5.subtitleLabel.font = kAt5AlertSubtitleFont;
            bar5.subtitleLabel.textColor = kAt5AlertSubtitleFontColor;
            bar5.subtitleLabel.text = model5.subtitle;
            CGSize subSize = [bar5.subtitleLabel sizeThatFits:CGSizeMake(1000, 20)];
            bar5.subtitleLabel.left = bar5.headerView.right+kAt5AlertTitleOffset;
            bar5.subtitleLabel.width = bar5.arrorView.left-bar5.headerView.right;
            bar5.subtitleLabel.height = subSize.height;
            
            bar5.titleLabel.top = (bar5.height-size.height-subSize.height-kAt5AlertTitleSpace)/2.0;
            bar5.subtitleLabel.top = bar5.titleLabel.bottom+kAt5AlertTitleSpace;
            
            bar5.clickBlock = model5.clickBlock;
            bar = bar5;
        }
            break;
            
        case MUAlertBarTypeAt6:
        {
            MUAt6AlertBarModel *model6 = (MUAt6AlertBarModel *)model;
            MUAt4AlertBar *bar6 = [MUAt4AlertBar new];
            bar6.model = model6;
            bar6.width = kAt6AlertWidth;
            bar6.height = kAt6AlertHeight;
            //label、subtitleLabel位置
            bar6.titleLabel.font = kAt6AlertFont;
            bar6.titleLabel.textColor = kAt6AlertFontColor;
            bar6.titleLabel.text = model6.title;
            CGSize size = [bar6.titleLabel sizeThatFits:CGSizeMake(1000, 20)];
            bar6.titleLabel.left = kAt6AlertTitleOffset;
            bar6.titleLabel.width = bar6.funcButton.left-kAt6AlertTitleOffset;
            bar6.titleLabel.height = size.height;
            
            bar6.subtitleLabel.font = kAt6AlertSubtitleFont;
            bar6.subtitleLabel.textColor = kAt6AlertSubtitleFontColor;
            bar6.subtitleLabel.text = model6.subtitle;
            CGSize subSize = [bar6.subtitleLabel sizeThatFits:CGSizeMake(1000, 20)];
            bar6.subtitleLabel.left = kAt6AlertTitleOffset;
            bar6.subtitleLabel.width = bar6.funcButton.left-kAt6AlertTitleOffset;
            bar6.subtitleLabel.height = subSize.height;
            
            bar6.titleLabel.top = (bar6.height-size.height-subSize.height-kAt6AlertTitleSpace)/2.0;
            bar6.subtitleLabel.top = bar6.titleLabel.bottom+kAt4AlertTitleSpace;
            
            [bar6.funcButton setTitle:model6.btnTitle forState:UIControlStateNormal];
            bar6.closeBlock = model6.closeBlock;
            bar6.funcBlock = model6.buttonBlock;
            bar = bar6;
        }
            break;

        case MUAlertBarTypeAt7:
        {
            MUAt7AlertBarModel *model7 = (MUAt7AlertBarModel *)model;
            MUAt7AlertBar *bar7 = [MUAt7AlertBar new];
            bar7.model = model7;
            bar7.width = kAt7AlertWidth;
            bar7.height = kAt7AlertHeight;
            //label、subtitleLabel位置
            bar7.titleLabel.font = kAt7AlertFont;
            bar7.titleLabel.textColor = kAt7AlertFontColor;
            bar7.titleLabel.text = model7.title;
            CGSize size = [bar7.titleLabel sizeThatFits:CGSizeMake(1000, 20)];
            bar7.titleLabel.left = kAt7AlertTitleOffset;
            bar7.titleLabel.width = bar7.lineView.left-kAt7AlertTitleOffset-kAt7AlertAccessoryOffset1;
            bar7.titleLabel.height = size.height;
            
            bar7.subtitleLabel.font = kAt7AlertSubtitleFont;
            bar7.subtitleLabel.textColor = kAt7AlertSubtitleFontColor;
            bar7.subtitleLabel.text = model7.subtitle;
            CGSize subSize = [bar7.subtitleLabel sizeThatFits:CGSizeMake(1000, 20)];
            bar7.subtitleLabel.left = kAt7AlertTitleOffset;
            bar7.subtitleLabel.width = bar7.lineView.left-kAt7AlertTitleOffset-kAt7AlertAccessoryOffset1;
            bar7.subtitleLabel.height = subSize.height;
            
            bar7.titleLabel.top = (bar7.height-size.height-subSize.height-kAt7AlertTitleSpace)/2.0;
            bar7.subtitleLabel.top = bar7.titleLabel.bottom+kAt7AlertTitleSpace;
            
            bar7.closeBlock = model7.closeBlock;
            bar7.clickBlock = model7.clickBlock;
            bar = bar7;
        }
            break;
            
        case MUAlertBarTypeAt8:
        {
            MUAt8AlertBarModel *model8 = (MUAt8AlertBarModel *)model;
            MUAt8AlertBar *bar8 = [[MUAt8AlertBar alloc]initWithModel:model8];
            
            bar8.closeBlock = model8.closeBlock;
            bar = bar8;
        }
            break;
        default:
            break;
    }
    return bar;
}


+(void)updateAlertBar:(MUAlertBar *)bar WithModel:(MUAlertBarModel *)model {
    if (bar.model.type != model.type) {//新model的type必须保持一致
        return;
    }
    switch (model.type) {
        case MUAlertBarTypeAt1:
        {
            MUAt1AlertBarModel *model1 = (MUAt1AlertBarModel *)model;
            MUAt1AlertBar *bar1 = (MUAt1AlertBar *)bar;
            bar1.model = model1;

            bar1.infoLabel.text = model1.title;
            //点击回调
            bar1.clickBlock = model1.clickBlock;
        }
            break;
            
        case MUAlertBarTypeAt2:
        {
            MUAt2AlertBarModel *model2 = (MUAt2AlertBarModel *)model;
            MUAt1AlertBar *bar2 = (MUAt1AlertBar *)bar;
            bar2.model = model2;

            bar2.infoLabel.text = model2.title;
            bar2.clickBlock = model2.clickBlock;
        }
            break;
            
        case MUAlertBarTypeAt3:
        {
            MUAt3AlertBarModel *model3 = (MUAt3AlertBarModel *)model;
            MUAt1AlertBar *bar3 = (MUAt1AlertBar *)bar;
            bar3.model = model3;
            bar3.infoLabel.text = model3.title;
            //回调
            bar3.clickBlock = model3.clickBlock;
            bar3.closeBlock = model3.closeBlock;
        }
            break;
            
        case MUAlertBarTypeAt4:
        {
            MUAt4AlertBarModel *model4 = (MUAt4AlertBarModel *)model;
            MUAt4AlertBar *bar4 = (MUAt4AlertBar*)bar;
            bar4.model = model4;
            bar4.titleLabel.text = model4.title;
            CGSize size = [bar4.titleLabel sizeThatFits:CGSizeMake(1000, 20)];
            bar4.titleLabel.height = size.height;
            
            bar4.subtitleLabel.text = model4.subtitle;
            CGSize subSize = [bar4.subtitleLabel sizeThatFits:CGSizeMake(1000, 20)];
            bar4.subtitleLabel.height = subSize.height;
            
            bar4.titleLabel.top = (bar4.height-size.height-subSize.height-kAt4AlertTitleSpace)/2.0;
            bar4.subtitleLabel.top = bar4.titleLabel.bottom+kAt4AlertTitleSpace;
            //回调
            bar4.clickBlock = model4.clickBlock;
        }
            break;
            
        case MUAlertBarTypeAt5:
        {
            MUAt5AlertBarModel *model5 = (MUAt5AlertBarModel *)model;
            MUAt4AlertBar *bar5 = (MUAt4AlertBar*)bar;
            bar5.model = model5;
          
            [bar5.headerView sd_setImageWithURL:[NSURL URLWithString: model5.headerURL]];

            bar5.titleLabel.text = model5.title;
            CGSize size = [bar5.titleLabel sizeThatFits:CGSizeMake(1000, 20)];
            bar5.titleLabel.height = size.height;
            
            bar5.subtitleLabel.text = model5.subtitle;
            CGSize subSize = [bar5.subtitleLabel sizeThatFits:CGSizeMake(1000, 20)];
            bar5.subtitleLabel.height = subSize.height;
            
            bar5.titleLabel.top = (bar5.height-size.height-subSize.height-kAt5AlertTitleSpace)/2.0;
            bar5.subtitleLabel.top = bar5.titleLabel.bottom+kAt5AlertTitleSpace;
            
            bar5.clickBlock = model5.clickBlock;
        }
            break;
            
        case MUAlertBarTypeAt6:
        {
            MUAt6AlertBarModel *model6 = (MUAt6AlertBarModel *)model;
            MUAt4AlertBar *bar6 = (MUAt4AlertBar*)bar;
            bar6.model = model6;
            
            bar6.titleLabel.text = model6.title;
            CGSize size = [bar6.titleLabel sizeThatFits:CGSizeMake(1000, 20)];
            bar6.titleLabel.height = size.height;
            
            bar6.subtitleLabel.text = model6.subtitle;
            CGSize subSize = [bar6.subtitleLabel sizeThatFits:CGSizeMake(1000, 20)];
            bar6.subtitleLabel.height = subSize.height;
            
            bar6.titleLabel.top = (bar6.height-size.height-subSize.height-kAt6AlertTitleSpace)/2.0;
            bar6.subtitleLabel.top = bar6.titleLabel.bottom+kAt4AlertTitleSpace;
            
            
            [bar6.funcButton setTitle:model6.btnTitle forState:UIControlStateNormal];
            bar6.closeBlock = model6.closeBlock;
            bar6.funcBlock = model6.buttonBlock;
        }
            break;
            
        case MUAlertBarTypeAt7:
        {
            MUAt7AlertBarModel *model7 = (MUAt7AlertBarModel *)model;
            MUAt7AlertBar *bar7 = (MUAt7AlertBar*)bar;
            bar7.model = model7;
           
            bar7.titleLabel.text = model7.title;
            CGSize size = [bar7.titleLabel sizeThatFits:CGSizeMake(1000, 20)];
            bar7.titleLabel.height = size.height;
            
            bar7.subtitleLabel.text = model7.subtitle;
            CGSize subSize = [bar7.subtitleLabel sizeThatFits:CGSizeMake(1000, 20)];
            bar7.subtitleLabel.height = subSize.height;
            
            bar7.titleLabel.top = (bar7.height-size.height-subSize.height-kAt7AlertTitleSpace)/2.0;
            bar7.subtitleLabel.top = bar7.titleLabel.bottom+kAt7AlertTitleSpace;
            
            bar7.closeBlock = model7.closeBlock;
            bar7.clickBlock = model7.clickBlock;
        }
            break;
        default:
            break;
    }
}

@end
