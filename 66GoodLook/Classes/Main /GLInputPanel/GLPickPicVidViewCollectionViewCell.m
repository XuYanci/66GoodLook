//
//  GLPickPictureViewCollectionView.m
//  66GoodLook
//
//  Created by Yanci on 17/4/28.
//  Copyright © 2017年 Yanci. All rights reserved.
//

#import "GLPickPicVidViewCollectionViewCell.h"

@interface GLPickPicVidViewCollectionViewCell()
@property (nonatomic,strong) UIImageView *pictureImageView;
@property (nonatomic,strong) UIButton *tickBtn;
@end

@implementation GLPickPicVidViewCollectionViewCell {
    BOOL _needsReload;  /*! 需要重载 */
    struct {
    }_datasourceHas;    /*! 数据源存在标识 */
    struct {
    }_delegateHas;      /*! 数据委托存在标识 */
}

#pragma mark - life cycle
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)layoutSubviews {
    self.pictureImageView.frame = self.contentView.bounds;
    [self.tickBtn sizeWith:CGSizeMake(30, 30)];
    [self.tickBtn alignParentRightWithMargin:10.0];
    [self.tickBtn alignParentTopWithMargin:10.0];
}

#pragma mark - datasource
#pragma mark - delegate
#pragma mark - user events
- (void)tick:(id)sender {
    self.tickBtn.selected = !self.tickBtn.selected;
}

#pragma mark - functions
- (void)commonInit {
    [self.contentView addSubview:self.pictureImageView];
    [self.contentView addSubview:self.tickBtn];
  
 
    [self.tickBtn setImage:[UIImage imageNamed:@"qz_btn_select_d"] forState:UIControlStateNormal];
    [self.tickBtn setImage:[UIImage imageNamed:@"qz_btn_select_s"] forState:UIControlStateSelected];
    
    [self.tickBtn addTarget:self action:@selector(tick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.pictureImageView sd_setImageWithURL:[NSURL URLWithString:@"https://imgsa.baidu.com/baike/c0%3Dbaike116%2C5%2C5%2C116%2C38/sign=957c1f4eae86c9171c0e5a6ba8541baa/0ff41bd5ad6eddc4516c4f4d30dbb6fd536633f8.jpg"]];
    [self setNeedsReload];
}


- (void)setDataSource {}

- (void)setDelegate {}

- (void)setNeedsReload {
    _needsReload = YES;
    [self setNeedsLayout];
}
- (void)_reloadDataIfNeeded {
    if (_needsReload) {
        [self reloadData];
    }
}
- (void)reloadData {}
- (void)setFrame:(CGRect)frame { [super setFrame:frame];}

- (void)setImage:(UIImage *)image {
    _image = image;
    [self.pictureImageView setImage:_image];
}

#pragma mark - notification
#pragma mark - getter and setter


- (UIImageView *)pictureImageView {
    if (!_pictureImageView) {
        _pictureImageView = [[UIImageView alloc]init];
        _pictureImageView.backgroundColor = [UIColor whiteColor];
    }
    return _pictureImageView;
}

- (UIButton *)tickBtn {
    if (!_tickBtn) {
        _tickBtn = [[UIButton alloc]init];
    }
    return _tickBtn;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
