//
//  GoodLookTrendingViewController.m
//  66GoodLook
//
//  Created by Yanci on 17/4/11.
//  Copyright © 2017年 Yanci. All rights reserved.
//

#import "GoodLookDynamicViewController.h"
#import "GLRefreshHeader.h"
#import "GLRefreshFooter.h"
#import "GLDynamicTableViewCell.h"

static NSString *const CellDynamicIdentifier = @"CellDynamicIdentifier";

@interface GoodLookDynamicViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSMutableArray *dynamicList;       /** list data */
@end

@implementation GoodLookDynamicViewController {
    BOOL _needsReload;
    struct {
    }_datasourceHas;
    
    struct{
    }_delegateHas;
    
    NSString *_last_adSort;
    NSNumber *_last_attentionTimestamp;
    NSNumber *_last_timestamp;
}


#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self commonInit];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self headerRefresh];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews {
    [self _reloadDataIfNeed];
    [self _layoutSubviews];
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dynamicList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GLGetAttentionDynamicListResDynamicModel *listItemModel = [self.dynamicList objectAtIndex:indexPath.row];
    GLDynamicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellDynamicIdentifier];
    NSString *avatarImageUrl = [NSString stringWithFormat:@"%@?imageView2/1/format/jpg/quality/60/w/70/h/70/",listItemModel.headerUrl ];
    [cell.avatarImageView setImageWithURL:[NSURL URLWithString:avatarImageUrl]
                              placeholder:[UIImage imageNamed:@"gj_img_logo"]];
    cell.titleLabel.text = listItemModel.memberName;
    cell.detailTitleLabel.text = listItemModel.caption;
    return cell;
}

#pragma mark - delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 660.0 / 2.0;
}

#pragma mark - user events
#pragma mark - functions

- (void)commonInit {
    self.tableView.frame = self.view.bounds;
    [self.view addSubview:self.tableView];
}


- (void)headerRefresh {
   GLGetDynamicListRequest *request = [[GLGetDynamicListRequest alloc]init];
    if (self.model) {
        request.topicId = self.model.ID.stringValue;
    }
    
    [MXNetworkConnection sendGetRequestWithMethod:self.model ? @"getDynamicList" : @"getAttentionDynamicList"
                                     requestModel:request
                                    responseClass:[GLGetDynamicListResponse class] beforeSendCallback:^{
                                        
    } SuccessCallBack:^(GLGetDynamicListResponse *result) {
        [self.dynamicList removeAllObjects];
        [self.dynamicList addObjectsFromArray:result.result.dynamic];
        
        self.tableView.mj_footer = [GLRefreshFooter footerWithRefreshingBlock:^{
            [self footerRefresh];
        }];
        
        GLGetAttentionDynamicListResDynamicModel *dynamic = self.dynamicList.lastObject;
        _last_adSort = result.result.adSort;
        _last_timestamp = dynamic.createDate;
        
    } ErrorCallback:^(NSError *error) {
        [self showHintHudWithMessage:error.localizedDescription];
    } CompleteCallback:^(NSError *error, id result) {
        [self.tableView.mj_header endRefreshing];
        [self.tableView reloadData];
        
    }];
}

- (void)footerRefresh {
 
    GLGetDynamicListRequest *request = [[GLGetDynamicListRequest alloc]init];
    if (!self.model) {
        request.timestamp = _last_timestamp;
    }
    else {
        request.timestamp = _last_timestamp;
        request.adSort = _last_adSort;
        request.topicId = self.model.ID.stringValue;
    }
    
    [MXNetworkConnection sendGetRequestWithMethod:self.model ? @"getDynamicList" : @"getAttentionDynamicList"
                                     requestModel:request
                                    responseClass:[GLGetDynamicListResponse class] beforeSendCallback:^{
                                        
    } SuccessCallBack:^(GLGetDynamicListResponse *result) {
        NSMutableArray *insertIndexPathes = [NSMutableArray array];
        NSUInteger beginIndexPath = self.dynamicList.count;
        NSUInteger endIndexPath = self.dynamicList.count + result.result.dynamic.count;
        
        for (NSUInteger i = beginIndexPath; i < endIndexPath; i++) {
            [insertIndexPathes addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        
        [self.dynamicList addObjectsFromArray:result.result.dynamic];
        
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:insertIndexPathes withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
        
    } ErrorCallback:^(NSError *error) {
        [self showHintHudWithMessage:error.localizedDescription];
        
    } CompleteCallback:^(NSError *error, id result) {
        [self.tableView.mj_footer endRefreshing];
    }];
}


- (void)reloadData {
    
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
    self.tableView.frame = self.view.bounds;
}

- (void)setDataSource:(id<GoodLookDynamicViewControllerDataSource>)dataSource {
    
}

- (void)setDelegate:(id<GoodLookDynamicViewControllerDelegate>)delegate {
    
}

#pragma mark - notification
#pragma mark - getter and setter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.tableFooterView = [[UIView alloc]init];
        _tableView.mj_header = [GLRefreshHeader headerWithRefreshingBlock:^{
            [self headerRefresh];
        }];
        [_tableView registerClass:[GLDynamicTableViewCell class] forCellReuseIdentifier:CellDynamicIdentifier];
    }
    return _tableView;
}

- (NSMutableArray *)dynamicList {
    if (!_dynamicList) {
        _dynamicList = [NSMutableArray array];
    }
    return _dynamicList;
}


@end
