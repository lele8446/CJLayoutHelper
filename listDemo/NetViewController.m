//
//  NetViewController.m
//  YCLayoutHelperDemo
//
//  Created by ChiJinLian on 16/11/30.
//  Copyright © 2016年 YiChe. All rights reserved.
//

#import "NetViewController.h"
#import "AutoBaseTableViewCell.h"
#import "ConfigurationTool.h"
#import "ConfigurationModel.h"
#import "CJLayoutHelper.h"
#import "AFHTTPSessionManager.h"
#import "MBProgressHUD.H"

@interface NetViewController ()<UITableViewDelegate,UITableViewDataSource,CJLayoutHelperDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) CJLayoutHelper *layoutHelper;
@end

@implementation NetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"下发配置";
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithTitle:@"刷新" style:UIBarButtonItemStylePlain target:self action:@selector(showView)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:item, nil];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    self.dataArray = [NSMutableArray array];
    self.layoutHelper = [[CJLayoutHelper alloc]init];
    
    [self showView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)showView {
    [self.dataArray removeAllObjects];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    [manager GET:@"https://o44fado6w.qnssl.com/CJLayoutHelperTestdata.json"
                            parameters:nil
                              progress:^(NSProgress * uploadProgress){
                                  
                              }
                               success:^(NSURLSessionDataTask *task, id _Nullable responseObject){
                                   [self handleData:responseObject[@"data"]];
                                   [MBProgressHUD hideHUDForView:self.view animated:YES];
                               }
                               failure:^(NSURLSessionDataTask * _Nullable task, NSError *error){
                                   NSLog(@"ERROR = %@",error);
                                   [MBProgressHUD hideHUDForView:self.view animated:YES];
                               }];
}

- (void)handleData:(NSArray *)data {
    [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        ConfigurationModel *model = [[ConfigurationModel alloc]initConfigurationModelInfo:obj];
        [self.dataArray addObject:model];
    }];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ConfigurationModel *info = self.dataArray[indexPath.row];
    AutoBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[CJLayoutHelper configurationViewStyleIdentifier:info]];
    if (nil == cell) {
        cell = [[AutoBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault withCellInfo:info];
    }else{
        [cell cellInfo:info];
    }
    __weak typeof(self)wSelf = self;
    cell.tapBlock = ^(UIView *view, id info){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"点击了%@",NSStringFromClass([view class])] message:info preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:cancelAction];
        [wSelf presentViewController:alertController animated:YES completion:nil];
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ConfigurationModel *info = self.dataArray[indexPath.row];
    return [AutoBaseTableViewCell cellHeightWithInfo:info];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


#pragma mark - ConfigurationLayoutHelperDelegate
- (void)configureView:(UIView *)view withModelInfo:(NSDictionary *)info {
    if ([view isKindOfClass:[UIButton class]]) {
        if ([view.idDescription rangeOfString:@"UIScrollView_button"].location != NSNotFound) {
            UIButton *button = (UIButton *)view;
            [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    if ([view isKindOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *)view;
        label.numberOfLines = 0;
    }
}

- (void)buttonClick:(UIButton *)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"点击了UIButton"] message:sender.idDescription preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
@end

