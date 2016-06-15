//
//  HCHomeDetailTableViewCell.m
//  Project
//
//  Created by 陈福杰 on 15/12/17.
//  Copyright © 2015年 com.xxx. All rights reserved.
//

#import "HCHomeDetailTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"
#import "HCHomeInfo.h"
#import "HCHomeDetailUserInfo.h"
#import "HCHomeDetailInfo.h"
#import "HCHomeMoreImgView.h"
#import "HCPraiseTagListView.h"
//删除时光
#import "NHCHomeTimeDeleteApi.h"
@interface HCHomeDetailTableViewCell()<HCHomeMoreImgViewDelegate, HCPraiseTagListViewDelegate>

@property (nonatomic, strong) UIButton *headButton;
@property (nonatomic, strong) UILabel *nickName;
@property (nonatomic, strong) UILabel *deveceModel;
@property (nonatomic, strong) UILabel *times;
@property (nonatomic, strong) UILabel *contents;
@property (nonatomic, strong) UIButton *deleteBtn;
//多图片
@property (nonatomic, strong) HCHomeMoreImgView *moreImgView;
@property (nonatomic, strong) HCPraiseTagListView *praiseTag;

@end

@implementation HCHomeDetailTableViewCell
//时光详情
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self.contentView addSubview:self.headButton];
        [self.contentView addSubview:self.nickName];
        [self.contentView addSubview:self.deveceModel];
        [self.contentView addSubview:self.times];
        [self.contentView addSubview:self.contents];
        [self.contentView addSubview:self.deleteBtn];
        [self.contentView addSubview:self.moreImgView];
        [self.contentView addSubview:self.praiseTag];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.headButton.frame = CGRectMake(10, 10, WIDTH(self)*0.15, WIDTH(self)*0.15);
    ViewRadius(self.headButton, WIDTH(self.headButton)*0.5);
    
    self.nickName.frame = CGRectMake(MaxX(self.headButton)+10, HEIGHT(self.headButton)*0.3, 100, 20);
    self.deveceModel.frame = CGRectMake(MaxX(self.headButton)+10, MaxY(self.nickName), 200, 20);
    
    self.times.frame = CGRectMake(WIDTH(self)-130, MinY(self.nickName), 120, 20);
    CGFloat contentsHeight = [Utils detailTextHeight:_info.FTContent lineSpage:4 width:WIDTH(self)-20 font:14];
    self.contents.frame = CGRectMake(10, MaxY(self.headButton)+5, WIDTH(self)-20, contentsHeight);
    if (_isDelete)
    {
        
        if (!IsEmpty(_info.FTImages))
        {
            self.deleteBtn.frame = CGRectMake(WIDTH(self)-50, MaxY(self.moreImgView) + 5, 40, 20);
            
        }else
        {
            
            
            self.deleteBtn.frame = CGRectMake(WIDTH(self)-50, MaxY(self.contents) + 5, 40, 20);
            
        }
        
        //self.deleteBtn.frame =CGRectMake(WIDTH(self)-50, MaxY(self.moreImgView) + 5, 40, 20);
        [self.deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        [self.deleteBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.deleteBtn addTarget:self action:@selector(deleteTime) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    // 图片
    if (!IsEmpty(_info.FTImages))
    {
        CGFloat height = (WIDTH(self)-30) / 3;
        self.moreImgView.frame = CGRectMake(0, MaxY(self.contents)+10, WIDTH(self), height);
    }
    
    if (!IsEmpty(_info.FTImages))
    {
        if (!IsEmpty(_praiseArr))
        {
            self.praiseTag.frame = CGRectMake(10, MaxY(self.moreImgView)+5, WIDTH(self)-70, _praiseHeight);
        }
    }else
    {
        if (!IsEmpty(_praiseArr))
        {
            self.praiseTag.frame = CGRectMake(10, MaxY(self.contents)+5, WIDTH(self)-70, _praiseHeight);
        }
    }
}
//下次用代理  代理出去 操作
- (void)deleteTime{
    NHCHomeTimeDeleteApi *api = [[NHCHomeTimeDeleteApi alloc]init];
    api.timeID = _info.TimeID;
    [api startRequest:^(HCRequestStatus resquestStatus, NSString *message, NSArray *array) {
        if (resquestStatus == HCRequestStatusSuccess) {
            //删除成功后的操作
            [_delegates delete];
            
        }
    }];
    
}
#pragma mark - HCHomeMoreImgViewDelegate

- (void)hchomeMoreImgView:(NSInteger)index
{
    if ([self.delegates respondsToSelector:@selector(hchomeDetailTableViewCellSelectedImage:)])
    {
        [self.delegates hchomeDetailTableViewCellSelectedImage:index];
    }
}

#pragma mark - HCPraiseTagListViewDelegate

- (void)hcpraiseTagListViewSelectedTag:(NSInteger)index
{
    if ([self.delegates respondsToSelector:@selector(hchomeDetailTableViewCellSelectedTagWithUserid:)])
    {
        [self.delegates hchomeDetailTableViewCellSelectedTagWithUserid:index];
    }
}

#pragma mark - setter or getter

- (void)setInfo:(HCHomeInfo *)info
{
    _info = info;
    
    if (!IsEmpty(info.HeadImg))
    {
        [self.headButton sd_setImageWithURL:[readUserInfo url:info.HeadImg :kkUser] forState:UIControlStateNormal placeholderImage:OrigIMG(@"Head-Portraits")];
    }else
    {
        [self.headButton setImage:OrigIMG(@"Head-Portraits") forState:UIControlStateNormal];
    }
    
    self.nickName.text = info.NickName;
    NSString *time = [info.CreateTime substringToIndex:16];
    self.times.text = time;
    //self.times.text = [Utils transformServerDate:[info.CreateTime integerValue]];
    // 设备型号
    //self.deveceModel.text = [NSString stringWithFormat:@"来至:%@", info.deviceModel];
    
    // 内容设置行间距
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:info.FTContent];;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    [paragraphStyle setLineSpacing:4];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, info.FTContent.length)];
    self.contents.attributedText = attributedString;
    
    // 图片
    if (!IsEmpty(info.FTImages))
    {
        self.moreImgView.hidden = NO;
        [self.moreImgView hchomeMoreImgViewWithUrlStringArray:info.FTImages];
    }else
    {
        self.moreImgView.hidden = YES;
    }
    if (!IsEmpty(_praiseArr) && !self.praiseTag.subviews.count)
    {
        //暂时不写
        [self.praiseTag setPraiseTagListWithTagArray:_praiseArr];
    }
}

- (UIButton *)headButton
{
    if (!_headButton)
    {
        _headButton = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return _headButton;
}

- (UILabel *)nickName
{
    if (!_nickName)
    {
        _nickName = [[UILabel alloc] init];
        _nickName.font = [UIFont systemFontOfSize:16];
        _nickName.textColor = DarkGrayColor;
    }
    return _nickName;
}

- (UILabel *)deveceModel
{
    if (!_deveceModel)
    {
        _deveceModel = [[UILabel alloc] init];
        _deveceModel.textColor = LightGraryColor;
        _deveceModel.font = [UIFont systemFontOfSize:12];
    }
    return _deveceModel;
}

- (UILabel *)times
{
    if (!_times)
    {
        _times = [[UILabel alloc] init];
        _times.textColor = LightGraryColor;
        _times.textAlignment = NSTextAlignmentRight;
        _times.font = [UIFont systemFontOfSize:13];
    }
    return _times;
}
- (UIButton *)deleteBtn
{
    if (!_deleteBtn)
    {
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteBtn.titleLabel.textAlignment = NSTextAlignmentRight;
        _deleteBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        _deleteBtn.tintColor = [UIColor blueColor];
        
    }
    return _deleteBtn;
}
- (UILabel *)contents
{
    if (!_contents)
    {
        _contents = [[UILabel alloc] init];
        _contents.textColor = DarkGrayColor;
        _contents.lineBreakMode = NSLineBreakByCharWrapping;
        _contents.font = [UIFont systemFontOfSize:14];
        _contents.numberOfLines = 0;
    }
    return _contents;
}

- (HCHomeMoreImgView *)moreImgView
{
    if (!_moreImgView)
    {
        CGFloat width = (SCREEN_WIDTH - 40) / 3;
        _moreImgView = [[HCHomeMoreImgView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
        _moreImgView.delegates = self;
        
    }
    return _moreImgView;
}

- (HCPraiseTagListView *)praiseTag
{
    if (!_praiseTag)
    {
        _praiseTag = [[HCPraiseTagListView alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH, 20)];
        _praiseTag.delegate = self;
        //        _praiseTag.backgroundColor = [UIColor lightGrayColor];
    }
    return _praiseTag;
}


@end
