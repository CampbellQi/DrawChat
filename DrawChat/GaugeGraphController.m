//
//  GaugeGraphController.m
//  DrawChat
//  
//  Created by 冯万琦 on 2017/1/18.
//  Copyright © 2017年 yidian. All rights reserved.
//

#import "GaugeGraphController.h"
#import "WQGaugeGraphView.h"

@interface GaugeGraphController ()

@end

@implementation GaugeGraphController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSDictionary *dictionary = [self resourcePlistWithSourceName:@"WQGaugeGraphData"];
    [self initWQGaugeGraphWithDataDict:[NSMutableDictionary dictionaryWithDictionary:dictionary]];
}
//初始化仪表盘
-(void)initWQGaugeGraphWithDataDict:(NSMutableDictionary*)dataDict
{
    WQGaugeGraphView *view = [[WQGaugeGraphView alloc] initWithFrame:self.view.bounds ThemAttributs:@{gSuffix:@"亿元",gName:@"当月新签合同额",gMaxValue:@120,gMinValue:@0,gLabelNum:@13} Value:44.0f];
    
    self.contentSV.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) + 50);
    [self.contentSV addSubview:view];
    
    //view.center = self.graphView.center;
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

@end
