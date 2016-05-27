//
//  HCPromisedViewController.m
//  Project
//
//  Created by 陈福杰 on 15/12/15.
//  Copyright © 2015年 com.xxx. All rights reserved.
//  ———————————————— 呼·应——————————————————————————

#import "HCPromisedViewController.h"
#import "HCPromiseDetailViewController1.h"
#import "HCAddPromiseViewController1.h"
#import "HCNotificationViewController.h"
#import "HCNotificationHeadImageController.h"
#import "HCMyPromisedDetailController.h"
#import "HCOtherPromisedDetailController.h"

#import "Scan_VC.h"

#import "MJRefresh.h"
#import "WKFRadarView.h"

#import "HCPromisedAddCell.h"
#import "HCPromisedListAPI.h"
#import "HCPromisedListInfo.h"
#import "HCObjectListApi.h"

#import "HCTagUserAmostListApi.h"
#import "HCNewTagInfo.h"
#import "HCPromisedTagUserDetailController.h"
#import "HCAddTagUserController.h"


#import "HCPromiedTagWhenMissController.h"
#import "HCLostInfoViewController.h"

@interface HCPromisedViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    BOOL   isShouldWhow;
    BOOL   jump;
}
@property(nonatomic,strong)UITableView     *smallTableView;
@property(nonatomic,strong)NSMutableArray  *dataArr;
@property(nonatomic,strong)UIImageView     *bgImage;
@property(nonatomic,strong)UIButton        *headBtn;
@property(nonatomic,strong)WKFRadarView    *radarView;
@property(nonatomic,strong)NSString        *nextVCTitle;
@property(nonatomic,strong)HCNewTagInfo  *nextVCInfo;

@property (nonatomic,strong) UISegmentedControl  *segmented;

@property (nonatomic,strong) HCNotificationViewController *notiVC; // 应界面

@property (nonatomic, strong)UIView *alertBackground;//弹出提示框时的灰色背景
@property (nonatomic, strong)UIView *customAlertView;//自定义提示框
@property (nonatomic, assign)BOOL isNewObj;//是否是新建对象

@end

@implementation HCPromisedViewController

- (void)viewDidLoad
{
    //  ———————————————— 呼·应——————————————————————————
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.0];
    [self addNavItem];
    
    self.navigationController.navigationItem.backBarButtonItem = nil;
    
    
    [self requestData]; // 请求对象列表
    [self  createUI];
    [self  createTableView];
    [self.view addSubview:self.notiVC.view];
    self.notiVC.view.hidden = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HeadImage:) name:@"显示头像" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ToNextMyDetailController:) name:@"ToNextMyController" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ToNextOtherController:) name:@"ToNextOtherController" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showRadarView) name:@"showRadarView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(show) name:@"show" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestData) name:@"refreshObjectData" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closePromised) name:@"closePromised" object:nil];
    
    //当审核完成之后
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jumpToMyNotificationVC:) name:@"afterReview" object:nil];
    

#warning 备注:此处需要完善,雷达是否显示应该是后台给数据来判断是否关闭了呼,而不是在本地储存呼的状态进行判断
    NSString *str  =  [[NSUserDefaults standardUserDefaults] objectForKey:@"showRadar"];
    
    if ([str isEqualToString:@"1"]) {
        isShouldWhow = YES;
    }
    else
    {
        isShouldWhow = NO;
    }
    
}

-(void)closePromised
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"showRadar"];
    isShouldWhow = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.nextVCInfo = nil;
    jump = NO;
    if (isShouldWhow)
    {
        [_radarView removeFromSuperview];
        CGFloat  headerViewW =  _headBtn.frame.size.width;
        WKFRadarView  *radarView = [[WKFRadarView alloc] initWithFrame: CGRectMake(0, 0, headerViewW*3 , headerViewW*3)andThumbnail:@"yihubaiying_icon_m-talk logo_dis.png"];
        CGFloat  headerViewY = _bgImage.frame.origin.y-15;
        radarView.center = CGPointMake(SCREEN_WIDTH/2, headerViewY);
        _radarView = radarView;
        _radarView.userInteractionEnabled = NO;
        
        _headBtn.hidden = YES;
        [self.view addSubview:_radarView];
        [self.view sendSubviewToBack:_radarView];
        [self.view sendSubviewToBack:_bgImage];
    }
     else
     {
         [_radarView removeFromSuperview];
         _headBtn.hidden = NO;
     }
    
    for (NSInteger i = 0; i<self.dataArr.count; i++)
    {
        HCPromisedListInfo *info = self.dataArr[i];
        info.isBlack = NO;
    }
    
    [self.smallTableView reloadData];
}

// 从后台进入活跃状态的时候 判断是否显示雷达显示
-(void)showRadarView
{
    if (isShouldWhow)
    {
        [_radarView removeFromSuperview];
        CGFloat  headerViewW =  _headBtn.frame.size.width;
        WKFRadarView  *radarView = [[WKFRadarView alloc] initWithFrame: CGRectMake(0, 0, headerViewW*3 , headerViewW*3)andThumbnail:@"yihubaiying_icon_m-talk logo_dis.png"];
        CGFloat  headerViewY = _bgImage.frame.origin.y-15;
        radarView.center = CGPointMake(SCREEN_WIDTH/2, headerViewY);
        _radarView = radarView;
        _radarView.userInteractionEnabled = NO;
        
        _headBtn.hidden = YES;
        [self.view addSubview:_radarView];
        [self.view sendSubviewToBack:_radarView];
        [self.view sendSubviewToBack:_bgImage];
        
    }
    else
    {
        [_radarView removeFromSuperview];
        _headBtn.hidden = NO;
    }
    
    
    for (NSInteger i = 0; i<self.dataArr.count; i++)
    {
        HCPromisedListInfo *info = self.dataArr[i];
        info.isBlack = NO;
    }
    
    [self.smallTableView reloadData];

}

// 呼 发送成功后  显示雷达效果
-(void)show
{
    
    [_radarView removeFromSuperview];
    CGFloat  headerViewW =  _headBtn.frame.size.width;
    WKFRadarView  *radarView = [[WKFRadarView alloc] initWithFrame: CGRectMake(0, 0, headerViewW*3 , headerViewW*3)andThumbnail:@"yihubaiying_icon_m-talk logo_dis.png"];
    CGFloat  headerViewY = _bgImage.frame.origin.y-15;
    radarView.center = CGPointMake(SCREEN_WIDTH/2, headerViewY);
    _radarView = radarView;
    _radarView.userInteractionEnabled = NO;
    
    _headBtn.hidden = YES;
    [self.view addSubview:_radarView];
    [self.view sendSubviewToBack:_radarView];
    [self.view sendSubviewToBack:_bgImage];
    
    isShouldWhow = YES;
}

-(void)HeadImage:(NSNotification *)info
{
    HCNotificationHeadImageController  *imageVC = [[HCNotificationHeadImageController alloc]init];
    imageVC.data = @{@"image":info.userInfo[@"image"]};
    imageVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:imageVC animated:YES];
}

-(void)ToNextMyDetailController:(NSNotification *)info
{

    HCMyPromisedDetailController *detailVC = [[HCMyPromisedDetailController alloc]init];
    detailVC.data = info.userInfo;
    detailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailVC animated:YES];

}

-(void)ToNextOtherController:(NSNotification  *)noti
{
    HCOtherPromisedDetailController * OtherVC = [[HCOtherPromisedDetailController alloc]init];
    OtherVC.data = noti.userInfo;
    OtherVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:OtherVC animated:YES];
}

#pragma mark--UITableViewDelegate

-(UITableViewCell  *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HCPromisedAddCell  *cell = [HCPromisedAddCell customCellWithTable:tableView];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    HCNewTagInfo *info =self.dataArr[indexPath.row];
    cell.info = info;
    cell.buttonW = self.smallTableView.frame.size.width;
    cell.buttonH = (36/668.0)*SCREEN_HEIGHT;
    cell.block = ^(NSString  *buttonTitle,HCNewTagInfo *info)
    {
        if ([buttonTitle isEqualToString:@"+ 新增录入"]) {
            
            //点击cell弹出提示框
            self.isNewObj = YES;
            [self.tabBarController.view addSubview:self.alertBackground];
            
        }
        else
        {
            for (HCNewTagInfo *info1 in self.dataArr) {
                info1.isBlack = NO;
            }
            info.isBlack = YES;
            self.nextVCInfo = info;
            [self.smallTableView reloadData];
            
            self.isNewObj = NO;
            //点击cell弹出提示框
            [self.tabBarController.view addSubview:self.alertBackground];
            
        }
        
        
    };
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (52/668.0)*SCREEN_HEIGHT;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}

#pragma mark---private method

-(void)createUI
{
   //背景图片
    _bgImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 0.8*SCREEN_WIDTH,(382/668.0)*SCREEN_HEIGHT)];
    _bgImage.userInteractionEnabled = YES;
    _bgImage.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2+30);
    _bgImage.image = [UIImage imageNamed:@"yihubaiying_Background.png"];
    _bgImage.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_bgImage];
    
    //顶部图片
    CGFloat  headerViewW =  115/383.0*_bgImage.frame.size.height;
    UIButton *headerView = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, headerViewW , headerViewW)];
    CGFloat  headerViewY = _bgImage.frame.origin.y-15;
    headerView.center = CGPointMake(SCREEN_WIDTH/2, headerViewY);
    [headerView addTarget:self action:@selector(headButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [headerView setBackgroundImage:IMG(@"yihubaiying_icon_m-talk logo_dis.png") forState:UIControlStateNormal];
    _headBtn = headerView;
    [self.view addSubview:_headBtn];
    
    // 两个图片
    UIImageView  *leftIV = [[UIImageView alloc]initWithFrame:CGRectMake(10, -15, 30, 30)];
    leftIV.image = [UIImage imageNamed:@"yihubaiying_nail.png"];
//    [_bgImage addSubview:leftIV];
    _bgImage.userInteractionEnabled = YES;
    
    CGFloat  rightIVX = _bgImage.frame.size.width - 10-30;
    UIImageView   *rightIV = [[UIImageView alloc]initWithFrame:CGRectMake(rightIVX, -15, 30, 30)];
    rightIV.image = [UIImage imageNamed:@"yihubaiying_nail.png"];
//    [_bgImage addSubview:rightIV];
}



-(void)pushVC
{
        //跳转到信息界面
        HCPromisedTagUserDetailController *detailVC = [[HCPromisedTagUserDetailController alloc]init];
        detailVC.data = @{@"info":self.nextVCInfo};
        detailVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:detailVC animated:YES];
    
}
-(void)createTableView
{
    self.smallTableView.backgroundColor = [UIColor clearColor];
    self.smallTableView.rowHeight = 50;
    self.smallTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_bgImage addSubview:self.smallTableView];
}


-(void)addNavItem
{

    self.navigationItem.titleView = self.segmented;
    UIBarButtonItem *right = [[UIBarButtonItem alloc]initWithImage:IMG(@"ThinkChange_sel") style:UIBarButtonItemStylePlain target:self action:@selector(ToQrcodeController:)];
    self.navigationItem.rightBarButtonItem = right;
    
}

#pragma Mark --- click

-(void)ToQrcodeController:(UIBarButtonItem *)right
{
    Scan_VC *scanVC = [[Scan_VC alloc]init];
    scanVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:scanVC animated:YES];
}

-(void)headButtonClick:(UIButton *)button
{
  
    if (self.nextVCInfo) {
        CGFloat  headerViewW = 115/383.0*_bgImage.frame.size.height;
        WKFRadarView  *radarView = [[WKFRadarView alloc] initWithFrame: CGRectMake(0, 0, headerViewW*3 , headerViewW*3)andThumbnail:@"yihubaiying_icon_m-talk logo_dis.png"];
        CGFloat  headerViewY = _bgImage.frame.origin.y-15;
        radarView.center = CGPointMake(SCREEN_WIDTH/2, headerViewY);
        _radarView = radarView;
        
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(radarTap:)];
//        [_radarView addGestureRecognizer:tap];
        
        _headBtn.hidden = YES;
        [self.view addSubview:_radarView];
        [self.view sendSubviewToBack:_radarView];
        [self.view sendSubviewToBack:_bgImage];
        
        [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(pushVC) userInfo:nil repeats:NO];
    }
}

-(void)handleSegmentedControl:(UISegmentedControl *)segmented
{
    if (segmented.selectedSegmentIndex == 0) {
        self.notiVC.view.hidden = YES;
    }
    else
    {
        self.notiVC.view.hidden = NO;
        self.notiVC.view.bounds = CGRectMake(0, -50, SCREEN_WIDTH, SCREEN_HEIGHT);
    }
    
}

-(void)radarTap:(UITapGestureRecognizer *)tap
{

    [self pushVC];
    
}

#pragma mark - deal Observer Action

- (void)jumpToMyNotificationVC:(NSNotification *)noti
{
    if (self.segmented.selectedSegmentIndex == 0)
    {
        self.segmented.selectedSegmentIndex = 1;
        self.notiVC.view.hidden = NO;
        self.notiVC.view.bounds = CGRectMake(0, -50, SCREEN_WIDTH, SCREEN_HEIGHT);
    }
}

#pragma mark - alert sureClick/cancelClick
//提示框"是"按钮
- (void)sureButtonAction:(UIButton *)sender
{
    [sender.superview.superview removeFromSuperview];
    
    //跳转判断是新建对象还是已有对象
    //1.新建对象跳转
    if (self.isNewObj)
    {
        HCLostInfoViewController *lostInfo = [[HCLostInfoViewController alloc]init];
        lostInfo.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:lostInfo animated:YES];
    }
    //2.已有对象跳转
    else
    {
        HCPromiedTagWhenMissController *promiedVC = [[HCPromiedTagWhenMissController alloc] init];
        promiedVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:promiedVC animated:YES];
    }
    
}

//提示框"否"按钮
- (void)cancelButtonAction:(UIButton *)sender
{
    [sender.superview.superview removeFromSuperview];
}


#pragma mark ---Setter Or Getter

-(NSMutableArray *)dataArr
{
    if (!_dataArr)
    {
        _dataArr = [NSMutableArray array];
        HCNewTagInfo *info = [[HCNewTagInfo alloc]init];
        info.trueName = @"+ 新增录入";
        [_dataArr addObject:info];
    }
    return _dataArr;
}

-(UITableView *)smallTableView
{
    if (!_smallTableView)
    {
        CGFloat  StabX = self.bgImage.frame.size.width-(40/375.0)*SCREEN_WIDTH;
        CGFloat  StabH = self.bgImage.frame.size.height - (125/668.0)*SCREEN_HEIGHT;
        _smallTableView = [[UITableView alloc]initWithFrame:CGRectMake((20/375.0)*SCREEN_WIDTH, (70/668.0)*SCREEN_HEIGHT, StabX, StabH) style:UITableViewStylePlain];
        _smallTableView.delegate = self;
        _smallTableView.dataSource = self;
    
    }
    _smallTableView.showsVerticalScrollIndicator = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    return _smallTableView;
}


- (UISegmentedControl *)segmented
{
    if(!_segmented){
        _segmented = [[UISegmentedControl alloc]initWithItems:@[@"呼",@"应"]];
        _segmented.frame = CGRectMake(0, 0, 120, 30);
        _segmented.selectedSegmentIndex = 0;
        _segmented.backgroundColor = COLOR(222, 35, 46, 1);
        _segmented.tintColor = [UIColor whiteColor];
        [_segmented addTarget:self action:@selector(handleSegmentedControl:) forControlEvents:UIControlEventValueChanged];
    }
    return _segmented;
}


- (HCNotificationViewController *)notiVC
{
    if(!_notiVC){
        _notiVC = [[HCNotificationViewController alloc]initWithStyle:UITableViewStyleGrouped];
        _notiVC.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64);
        [self addChildViewController:_notiVC];
    }
    return _notiVC;
}


- (UIView *)alertBackground
{
    if (_alertBackground == nil)
    {
        _alertBackground = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _alertBackground.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        [_alertBackground addSubview:self.customAlertView];
    }
    return _alertBackground;
}


- (UIView *)customAlertView
{
    if (_customAlertView == nil)
    {
        _customAlertView = [[UIView alloc] initWithFrame:CGRectMake(30/375.0*SCREEN_WIDTH, 230/668.0*SCREEN_HEIGHT, SCREEN_WIDTH-60/375.0*SCREEN_WIDTH, 190/668.0*SCREEN_HEIGHT)];
        ViewRadius(_customAlertView, 5);
        _customAlertView.backgroundColor = [UIColor whiteColor];
        
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 55/668.0*SCREEN_HEIGHT, WIDTH(_customAlertView), 20/668.0*SCREEN_HEIGHT)];
        titleLabel.text = @"确认发布一呼百应";
        titleLabel.textAlignment = 1;
        [_customAlertView addSubview:titleLabel];
        
        UIButton *sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        sureButton.frame = CGRectMake(30/375.0*SCREEN_WIDTH, MaxY(titleLabel)+45/668.0*SCREEN_HEIGHT, 120/375.0*SCREEN_WIDTH, 40/668.0*SCREEN_HEIGHT);
        ViewRadius(sureButton, 5);
        sureButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
        sureButton.layer.borderWidth = 1;
        [sureButton setTitle:@"是" forState:UIControlStateNormal];
        [sureButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [sureButton addTarget:self action:@selector(sureButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_customAlertView addSubview:sureButton];
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.frame = CGRectMake(MaxX(sureButton)+15/375.0*SCREEN_WIDTH, MaxY(titleLabel)+45/668.0*SCREEN_HEIGHT, 120/375.0*SCREEN_WIDTH, 40/668.0*SCREEN_HEIGHT);
        ViewRadius(cancelButton, 5);
        cancelButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
        cancelButton.layer.borderWidth = 1;
        [cancelButton setTitle:@"否" forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_customAlertView addSubview:cancelButton];
    }
    return _customAlertView;
}



#pragma mark --- network

-(void)requestData
{
    [self showHUDView:nil];
    
     HCTagUserAmostListApi *api = [[HCTagUserAmostListApi alloc]init];
    
    [api startRequest:^(HCRequestStatus requestStatus, NSString *message, id respone) {
       
        
        if (requestStatus == HCRequestStatusSuccess) {
            [self.dataArr removeAllObjects];
            
            NSArray *array = respone[@"Data"][@"rows"];
            for (NSDictionary *dic in array) {
                
                HCNewTagInfo *info = [HCNewTagInfo mj_objectWithKeyValues:dic];
                [self.dataArr addObject:info];
            }
            
            HCNewTagInfo *info = [[HCNewTagInfo alloc]init];
            info.trueName = @"+ 新增录入";
            [self.dataArr addObject:info];
            
            [self hideHUDView];
            
            [self.smallTableView reloadData];
 
        }
        if(self.dataArr.count == 0)
        {
            HCNewTagInfo *info = [[HCNewTagInfo alloc]init];
            info.trueName = @"+ 新增录入";
            [self.dataArr addObject:info];
            
            [self hideHUDView];
            
            [self.smallTableView reloadData];
        }
        
    }];
}

//上拉加载更多数据
-(void)requestMoreData
{
    if (self.dataArr.count>1)
    {
        HCPromisedListAPI  *api = [[HCPromisedListAPI alloc]init];
        [self.dataArr removeLastObject];
        HCPromisedListInfo *info = self.dataArr[self.dataArr.count-1];
        api.Start = [info.ObjectId intValue];
        [api startRequest:^(HCRequestStatus requestStatus, NSString *message, NSMutableArray *array) {
            
            if (requestStatus == HCRequestStatusSuccess)
            {
                    [self.dataArr addObjectsFromArray:array];
                    HCPromisedListInfo *info = [[HCPromisedListInfo alloc]init];
                    info.name=@"+ 新增录入";
                    [self.dataArr addObject:info];
                    [self.smallTableView reloadData];
                
                [self.smallTableView.mj_footer endRefreshing];
            }
            else
            {
                [self.smallTableView.mj_footer endRefreshing];
                [self showHUDError:message];
            }
            
        }];
    }
    else
    {
        [self.smallTableView.mj_footer endRefreshing];
    }
    

}

@end
