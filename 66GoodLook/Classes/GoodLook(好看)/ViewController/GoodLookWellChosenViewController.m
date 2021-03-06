//
//  GoodLookWellChosenViewController.m
//  66GoodLook
//
//  Created by Yanci on 17/4/11.
//  Copyright © 2017年 Yanci. All rights reserved.
//

#import "GoodLookWellChosenViewController.h"
#import "GLWellChosenCollectionViewCell.h"
#import "GLRefreshHeader.h"
#import "GLRefreshFooter.h"
#import "GoodLookIndexViewController.h"
 
#define kCollectionViewBackgroundColor [UIColor colorWithRed:248.0 / 255.0 green:248.0 / 255.0 blue:248.0 / 255.0 alpha:1.0]
static  NSString* const glWellChosenCollectionViewCellIdentifier  = @"glWellChosenCollectionViewCellIdentifier";

@interface GoodLookWellChosenViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic,strong)UICollectionView *collectionView;
@property (nonatomic,strong)UICollectionViewLayout *collectionViewLayout;
@property (nonatomic,strong)NSMutableArray *dynamicList;       /** list data */
@property (nonatomic,assign)NSUInteger pageIndex;       /** current page index */
@property (nonatomic,assign)NSUInteger countPerPage;    /** list count per page */
@end

@implementation GoodLookWellChosenViewController {
    BOOL _needsReload;
    struct {
    }_datasourceHas;
    
    struct{
    }_delegateHas;
    
    /** Request need params */
    NSString *_last_adSort;
    NSNumber *_last_attentionTimestamp;
    NSNumber *_last_timestamp;
    GoodLookScrollDirection _scrollDirection;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self commonInit];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self headerRefresh];
    });
  
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    

}

- (void)viewWillLayoutSubviews {
    
    [self _reloadDataIfNeed];
    [self _layoutSubviews];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dynamicList.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GLGetFineSelectionListResDynamicModel *listItemModel = [self.dynamicList objectAtIndex:indexPath.row];
    GLWellChosenCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:glWellChosenCollectionViewCellIdentifier forIndexPath:indexPath];
    
    
    
    NSString *imageUrl =  [GLQiniuImageHelper imageView2:GL_MEDIAURL_PREFIX
                                               imagePath:listItemModel.coverUrl
                                                  format:@"webp"
                                                 quality:@"60"
                                                   width:@"345"
                                                  height:@"332"];
    [cell.coverImageView setImageWithURL:[NSURL URLWithString:imageUrl]
                           placeholder:nil];
    
    NSString *avatarImageUrl =  [GLQiniuImageHelper imageView2:GL_MEDIAURL_PREFIX
                                                     imagePath:listItemModel.coverUrl
                                                        format:@"webp"
                                                       quality:@"60"
                                                         width:@"70"
                                                        height:@"70"];
    [cell.avatarImageView setImageWithURL:[NSURL URLWithString:avatarImageUrl]
                              placeholder:[UIImage imageNamed:@"gj_img_logo"]];
    
    cell.nicknameLabel.text = listItemModel.memberName;
    cell.recommendDescLabel.text = listItemModel.caption;
    return cell;
}
#pragma mark - delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self autoHideNav:scrollView];
    [self autoRefresh:scrollView];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [self showHintHudWithMessage:@"Tap!"];
}

#pragma mark - funcs


- (void)headerRefresh {
    
    [MXNetworkConnection sendGetRequestWithMethod:@"getFineSelectionList" requestModel:nil responseClass:[GLGetFineSelectionListResponse class] beforeSendCallback:^{
        
    } SuccessCallBack:^(GLGetFineSelectionListResponse *result) {
        [self.dynamicList removeAllObjects];
        [self.dynamicList addObjectsFromArray:result.result.dynamic];
        
        _last_adSort = result.result.adSort;
        _last_attentionTimestamp = result.result.attentionTimestamp;
        _last_timestamp = result.result.timestamp;
        self.collectionView.mj_footer = [GLRefreshFooter footerWithRefreshingBlock:^{
            [self footerRefresh];
        }];
    } ErrorCallback:^(NSError *error) {
        [self showHintHudWithMessage:error.localizedDescription];
    } CompleteCallback:^(NSError *error, id result) {
        [self.collectionView.mj_header endRefreshing];
        [self.collectionView reloadData];
    }];

}

- (void)footerRefresh {
    GLGetFineSelectionListRequest *request = [[GLGetFineSelectionListRequest alloc]init];
    request.adSort = _last_adSort;
    request.attentionTimestamp = _last_attentionTimestamp.stringValue;
    request.timestamp = _last_timestamp.stringValue;
    
    [MXNetworkConnection sendGetRequestWithMethod:@"getFineSelectionList" requestModel:request  responseClass:[GLGetFineSelectionListResponse class] beforeSendCallback:^{
        
    } SuccessCallBack:^(GLGetFineSelectionListResponse* result) {
        
        NSMutableArray *insertIndexPathes = [NSMutableArray array];
        NSUInteger beginIndexPath = self.dynamicList.count;
        NSUInteger endIndexPath = self.dynamicList.count + result.result.dynamic.count;
        
        
        for (NSUInteger i = beginIndexPath; i < endIndexPath; i++) {
            [insertIndexPathes addObject:[NSIndexPath indexPathForRow:beginIndexPath inSection:0]];
        }
        
        
        _last_adSort = result.result.adSort;
        _last_attentionTimestamp = result.result.attentionTimestamp;
        _last_timestamp = result.result.timestamp;
        [self.dynamicList addObjectsFromArray:result.result.dynamic];
        [self.collectionView insertItemsAtIndexPaths:insertIndexPathes];
    

    } ErrorCallback:^(NSError *error) {
        [self showHintHudWithMessage:error.localizedDescription];
    } CompleteCallback:^(NSError *error, id result) {
        [self.collectionView.mj_footer endRefreshing];
    }];
    
}

- (void)autoHideNav:(UIScrollView *)scrollView  {
    if ([scrollView.panGestureRecognizer translationInView:scrollView].y > 0) {
        if (_scrollDirection == GoodLookScrollDirection_Down) {
        }
        else {
            _scrollDirection = GoodLookScrollDirection_Down;
            [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationShowNaviBar object:nil];
        }
    }
    else {
        if (_scrollDirection == GoodLookScrollDirection_Up) {
            
        }
        else {
            _scrollDirection = GoodLookScrollDirection_Up;
            [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationHideNaviBar object:nil];
        }
    }
    
}

- (void)autoRefresh:(UIScrollView *)scrollView {
    float scrollViewHeight = scrollView.frame.size.height;
    float scrollContentSizeHeight = scrollView.contentSize.height;
    float scrollOffset = scrollView.contentOffset.y;
    
    if (scrollOffset == 0)
    {
        // then we are at the top
    }
    else if (scrollOffset + scrollViewHeight > scrollContentSizeHeight / 1.5)
    {
        // then we are at the end
        [self.collectionView.mj_footer beginRefreshing];
    }
}

- (void)commonInit {
    self.collectionView.frame = self.view.bounds;
    [self.view addSubview:self.collectionView];
    [self _setNeedsReload];
    _scrollDirection = GoodLookScrollDirection_None;
}

- (void)reloadData {
    [self.collectionView reloadData];
}


- (void)resetScrollDirection:(GoodLookScrollDirection)direction {
    _scrollDirection = direction;
}


- (void)_setNeedsReload {
    _needsReload = YES;
    [self.view setNeedsLayout];
}

- (void)_reloadDataIfNeed {
    if (_needsReload) {
        [self reloadData];
    }
}

- (void)_layoutSubviews {
    self.collectionView.frame = self.view.bounds;
}

#pragma mark - getter and setter
- (NSMutableArray *)dynamicList {
    if (!_dynamicList) {
        _dynamicList = [NSMutableArray array];
    }
    return _dynamicList;
}

- (UICollectionViewFlowLayout *)flowLayout:(CGFloat)left
                              paddingRight:(CGFloat)right
                                paddingTop:(CGFloat)top
                             paddingBottom:(CGFloat)bottom
                                cellHeight:(CGFloat)height
                               cellSpacing:(CGFloat)cellSpacing cellCount:(NSUInteger)cellCount{
    UICollectionViewFlowLayout *_flowLayout = nil;
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc]init];
        CGFloat itemwidth = floor((([UIScreen mainScreen].bounds.size.width - right - left - ((cellSpacing ) * (cellCount - 1) )) / cellCount)) ;
        CGFloat itemheight = height;
        _flowLayout.itemSize = CGSizeMake(itemwidth, itemheight);
        _flowLayout.sectionInset = UIEdgeInsetsMake(top,
                                                    left,
                                                    bottom,
                                                    right);
        _flowLayout.minimumLineSpacing = (cellSpacing);
        _flowLayout.minimumInteritemSpacing = (cellSpacing);
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    return _flowLayout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:
                           [self flowLayout:10
                               paddingRight:10
                                 paddingTop:10
                              paddingBottom:10
                                 cellHeight:240.0
                                cellSpacing:10.0
                                  cellCount:2]];
        [_collectionView registerClass:[GLWellChosenCollectionViewCell class] forCellWithReuseIdentifier:glWellChosenCollectionViewCellIdentifier];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = kCollectionViewBackgroundColor;
        
        _collectionView.mj_header = [GLRefreshHeader headerWithRefreshingBlock:^{
            [self headerRefresh];
        }];

//        _collectionView.mj_footer = [GLRefreshFooter footerWithRefreshingBlock:^{
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [_collectionView.mj_footer endRefreshingWithNoMoreData];
//            });
//        }];
    }
    return _collectionView;
}

@end
