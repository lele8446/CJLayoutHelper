//
//  ListViewController.m
//  listDemo
//
//  Created by ChiJinLian on 16/9/9.
//  Copyright © 2016年 BitAuto. All rights reserved.
//

#import "ListViewController.h"
#import "AutoBaseTableViewCell.h"
#import "AFNetworking.h"
#import "ConfigurationTool.h"
#import "ConfigurationModel.h"
#import "MBProgressHUD.h"

@interface ListViewController ()<UITableViewDelegate,UITableViewDataSource,CLayoutHelperDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIView *backView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.navigationItem.title = @"配置UI";
    [self creatRightItemWithShare:NO];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    self.dataArray = [NSMutableArray array];
    [self showView1];

}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)creatRightItemWithShare:(BOOL)shareItem {
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.rightBarButtonItems = nil;
    if (shareItem) {
        UIBarButtonItem *Item2 = [[UIBarButtonItem alloc]initWithTitle:@"页面2" style:UIBarButtonItemStylePlain target:self action:@selector(ItemClick:)];
        Item2.tag = 200;
        self.navigationItem.rightBarButtonItem = Item2;
    }else{
        UIBarButtonItem *Item1 = [[UIBarButtonItem alloc]initWithTitle:@"页面1" style:UIBarButtonItemStylePlain target:self action:@selector(ItemClick:)];
        Item1.tag = 100;
        UIBarButtonItem *finishItem = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(finishClick)];
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:Item1,finishItem, nil];
    }
}

- (void)ItemClick:(UIBarButtonItem *)item {
    if (item.tag == 100) {
        [self creatRightItemWithShare:YES];
        self.tableView.hidden = YES;
        self.backView.hidden = NO;
        [self.dataArray removeAllObjects];
        [self showView2];
    }else if (item.tag == 200) {
        [self creatRightItemWithShare:NO];
        self.tableView.hidden = NO;
        self.backView.hidden = YES;
        for (UIView *view in self.backView.subviews) {
            [view removeFromSuperview];
        }
        [self showView1];
    }
}

- (void)showView1 {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[AFHTTPSessionManager manager]POST:@"http://7xnrwl.com1.z0.glb.clouddn.com/Testdata.json"
                             parameters:nil
                               progress:^(NSProgress * uploadProgress){
                                   
                               }
                                success:^(NSURLSessionDataTask *task, id _Nullable responseObject){
                                    [self handleData:responseObject];
                                }
                                failure:^(NSURLSessionDataTask * _Nullable task, NSError *error){
                                    NSLog(@"ERROR = %@",error);
                                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                                }];
}

- (void)showView2 {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[AFHTTPSessionManager manager]POST:@"http://7xnrwl.com1.z0.glb.clouddn.com/mydata.json"
                             parameters:nil
                               progress:^(NSProgress * uploadProgress){
                                   
                               }
                                success:^(NSURLSessionDataTask *task, id _Nullable responseObject){
                                    [self handleData2:responseObject];
                                }
                                failure:^(NSURLSessionDataTask * _Nullable task, NSError *error){
                                    NSLog(@"ERROR = %@",error);
                                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                                }];
}

- (void)handleData:(id)object {
    NSArray *data = [(NSDictionary*)object objectForKey:@"data"];
    
    [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        ConfigurationModel *model = [[ConfigurationModel alloc]initConfigurationModelInfo:obj];
        [self.dataArray addObject:model];
    }];
    
    [self.tableView reloadData];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)handleData2:(id)object {
    NSDictionary *data = [(NSDictionary*)object objectForKey:@"data"];
    
    ConfigurationModel *model = [[ConfigurationModel alloc]initConfigurationModelInfo:data];
    [CLayoutHelper initializeViewWithInfo:model layoutContentView:self.backView contentViewWidth:ScreenWidth contentViewHeight:ScreenWidth delegate:self];
    
    CGFloat height = [CLayoutHelper viewHeightWithInfo:model contentViewWidth:ScreenWidth contentViewHeight:ScreenWidth];
    
    [self.tableView reloadData];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)finishClick {
    UITextField *xydmField = [self.view viewWithIdDescription:@"TextField_xydm"];
    UITextField *zczbField = [self.view viewWithIdDescription:@"TextField_zczb"];
    UITextView *addressTextView = [self.view viewWithIdDescription:@"CJUITextView_dz"];
    NSString *description = [NSString stringWithFormat:@"信用代码:%@\n注册资本:%@\n地址:%@",xydmField.text,zczbField.text,addressTextView.text];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"点击完成" message:description preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
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
    AutoBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[CLayoutHelper configurationViewStyleIdentifier:info]];
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
    
    UIFont *titleFont = [CLayoutHelper sharedManager].titleFont;
    NSString *title = [CLayoutHelper sharedManager].titleString;
    UIColor *titleColor = [CLayoutHelper sharedManager].titleColor;

    if ([view isMemberOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *)view;
        label.numberOfLines = 0;
        label.text = title;
        label.font = titleFont;
        label.textColor = titleColor;
    }
    if ([view isMemberOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)view;
        
        if (title && title.length >0) {
            button.titleLabel.font = titleFont;
            [button setTitleColor:titleColor forState:UIControlStateNormal];
            [button setTitleColor:titleColor forState:UIControlStateHighlighted];
            [button setTitle:title forState:UIControlStateNormal];
            [button setTitle:title forState:UIControlStateHighlighted];
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        }
        
        NSString *placeholder = info[@"placeholder"]?info[@"placeholder"]:@"";
        if (placeholder && placeholder.length > 0) {
            button.titleLabel.font = titleFont;
            [button setTitleColor:PlaceholderColor forState:UIControlStateNormal];
            [button setTitleColor:PlaceholderColor forState:UIControlStateHighlighted];
            [button setTitle:placeholder forState:UIControlStateNormal];
            [button setTitle:placeholder forState:UIControlStateHighlighted];
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        }
    }
    
    if ([view isKindOfClass:[UIButton class]]) {
        if ([view.idDescription rangeOfString:@"UIScrollView_button"].location != NSNotFound) {
            UIButton *button = (UIButton *)view;
            [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}

- (void)buttonClick:(UIButton *)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"点击了UIButton"] message:sender.idDescription preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
@end

