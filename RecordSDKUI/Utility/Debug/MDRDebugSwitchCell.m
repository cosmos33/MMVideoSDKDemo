//
//  MDRDebugSwitchCell.m
//  MMVideoSDK
//
//  Created by 符吉胜 on 2019/11/6.
//

#import "MDRDebugSwitchCell.h"
#import "MDRDebugCellModel.h"

@interface MDRDebugSwitchCell()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UISwitch *gtSwitch;

@end


@implementation MDRDebugSwitchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor= [UIColor blackColor];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:_titleLabel];
        
        _gtSwitch = [[UISwitch alloc] init];
        [_gtSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_gtSwitch];
        _gtSwitch.userInteractionEnabled = NO;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _titleLabel.frame = CGRectMake(20, 0, self.bounds.size.width - 70, self.bounds.size.height);
    _gtSwitch.frame = CGRectMake(self.bounds.size.width - 90, (self.bounds.size.height - 30)/2, 50, 30);
}

- (void)switchAction:(UISwitch *)gtSwitch {
    
}

- (void)bindModel:(MDRDebugCellModel *)model {
    self.titleLabel.text = model.title;
    self.gtSwitch.on = model.isOn;
}

@end
