//
//  MDRDebugViewWindow.m
//  MMVideoSDK
//
//  Created by 符吉胜 on 2019/11/6.
//

#import "MDRDebugViewWindow.h"
#import "MDRDebugHandler.h"
#import "MDRDebugSwitchCell.h"

static MDRDebugViewWindow *debugWindow = nil;

@interface MDRDebugViewWindow ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) MDRDebugHandler *handler;

@property (nonatomic, strong) UIButton  *closeBtn;

@end

@implementation MDRDebugViewWindow

+ (void)showDebugViewController {
    BOOL isShow = NO;
#if defined(DEBUG) || defined(INHOUSE)
    isShow = YES;
#endif
    if (isShow) {
        CGFloat left = 30;
        CGFloat top =  50;
        debugWindow = [[MDRDebugViewWindow alloc] initWithFrame:CGRectMake(left, top, [UIScreen mainScreen].bounds.size.width - 2*left, [UIScreen mainScreen].bounds.size.height - 2*top)];
        debugWindow.hidden = NO;
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.windowLevel = UIWindowLevelStatusBar - 1;
        [self configViews];
        [self.tableView reloadData];
    }
    return self;
}

- (void)configViews {
    self.backgroundColor = [UIColor whiteColor];
    _tableView = [[UITableView alloc] initWithFrame:self.bounds];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[MDRDebugSwitchCell class] forCellReuseIdentifier:@"MDDebugSwitchCell"];
    [self addSubview:self.tableView];
    
    CGFloat btnH = 40;
    _closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - btnH - 10, 100, btnH)];
    _closeBtn.center = CGPointMake(CGRectGetWidth(self.frame) / 2.0, _closeBtn.center.y);
    _closeBtn.backgroundColor = [UIColor redColor];
    [_closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
    [_closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_closeBtn addTarget:self action:@selector(didClickCloseBtn) forControlEvents:UIControlEventTouchUpInside];
    _closeBtn.layer.cornerRadius = CGRectGetHeight(_closeBtn.frame) / 2.0;
    _closeBtn.layer.masksToBounds = YES;
    [self addSubview:_closeBtn];
}

- (void)didClickCloseBtn {
    debugWindow.hidden = YES;
    [debugWindow removeFromSuperview];
    debugWindow = nil;
}

#pragma mark -

- (MDRDebugHandler *)handler {
    return [MDRDebugHandler shareInstance];
}

#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.handler.debugArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MDRDebugCellModel *model = self.handler.debugArray[indexPath.row];
    model.isOn = !model.isOn;
    MDRDebugSwitchCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell) {
        [cell bindModel:model];
    }
    [self.handler changeState:model.isOn type:model.type];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MDRDebugSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MDDebugSwitchCell" forIndexPath:indexPath];
    NSArray *array = self.handler.debugArray;
    [cell bindModel:array[indexPath.row]];
    return cell;
}

@end
