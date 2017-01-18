//
//  WQLineGraphView.m
//  DataService
//
//  Created by UWINY on 14-6-11.
//  Copyright (c) 2014年 Test. All rights reserved.
//
static int INTERVAL_COUNT = 9;
static float MARGIN_TOP = 40;
static float MARGIN_BOTTOM = 100;
static float MARGIN_LEFT = 60;

#import "WQLineGraphView.h"

@interface WQLineGraphView()
{
    //x轴间距，y轴间距，最大值，y轴值间距
    float _xIntervalInPx,_yIntervalInPx,_maxValue,_yAxisSaleValue;
    
}
//x轴标题
@property (nonatomic,retain) NSMutableArray *xAxisTitleArray;
//Y轴后缀
@property (nonatomic,copy)NSString *yAxisSuffix;
//点值
@property (nonatomic,retain)NSArray *valuesArray;
//点值
@property (nonatomic,retain)NSDictionary *valuesDict;

//属性
@property (nonatomic,retain)NSDictionary *themAttributs;
//折线颜色
@property (nonatomic,retain)NSArray *ployLineColorArray;
@end

@implementation WQLineGraphView

NSString *const wXAxisLabelColorKey = @"wXAxisLabelColorKey";
NSString *const wXAxisLabelFontKey = @"wXAxisLabelFontKey";
NSString *const wYAxisLabelColorKey = @"wYAxisLabelColorKey";
NSString *const wYAxisLabelFontKey = @"wYAxisLabelFontKey";
//分割线颜色
NSString *const wYAxisCatLineColorKey = @"wYAxisCatLineColorKey";
//折线颜色
NSString *const wPloyLineColorArrayKey = @"wPloyLineColorArrayKey";
//Y轴后缀
NSString *const wYAxisSuffix = @"wYAxisSuffix";

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame ThemAttributs:(NSDictionary *)aDic ValuesDict:(NSDictionary *)adict
{
    self = [super initWithFrame:frame];
    if (self) {
        self.xAxisTitleArray = [NSMutableArray arrayWithCapacity:0];
        self.themAttributs = aDic;
        
        self.valuesArray = [adict allValues];
        self.valuesDict = adict;
        self.yAxisSuffix = _themAttributs[wYAxisSuffix];
        self.ployLineColorArray = _themAttributs[wPloyLineColorArrayKey];
        
        if (self.ployLineColorArray.count != self.valuesArray.count) {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"ColorRatio" ofType:@"plist"];
            self.ployLineColorArray = [NSArray arrayWithContentsOfFile:path];
            
            NSMutableArray *colorArray = [NSMutableArray arrayWithCapacity:0];
            for (int i=0; i<self.ployLineColorArray.count; i++) {
                NSDictionary *colorDic = [self.ployLineColorArray objectAtIndex:i];
                float red = [[colorDic objectForKey:@"RED"] floatValue]/255.0f;
                float green = [[colorDic objectForKey:@"GREEN"] floatValue]/255.0f;
                float blue = [[colorDic objectForKey:@"BLUE"] floatValue]/255.0f;
                float alpha = [[colorDic objectForKey:@"ALPHA"] floatValue];
                
                UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
                [colorArray addObject:color];
            }
            
            self.ployLineColorArray = colorArray;
        }
        
        [self setUpTheView];
    }
    
    return self;
}
-(void)setUpTheView
{
    //计算刻度
    [self calcScales];
    //绘制x轴标题
    [self drawXLabels];
    //绘制y轴标题
    [self drawYLables];
    //绘制刻度横线
    [self drawLines];
    //绘制折线
    [self drawPloyline];
}
//计算刻度
-(void)calcScales
{
    _maxValue = 0.0f;
    __block float scaleValue = 0.0f;
    //    [self.valuesArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    //
    //
    //        NSArray *arr = (NSArray *)obj;
    //        [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    //            NSDictionary *dict = (NSDictionary *)obj;
    //            [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    //                NSString *them = (NSString *)key;
    //                NSNumber *num = (NSNumber *)obj;
    //                if (![self.xAxisTitleArray containsObject:them]) {
    //                    [self.xAxisTitleArray addObject:them];
    //                }
    //                if ([num floatValue] >= scaleValue) {
    //                    scaleValue = [num floatValue];
    //                    //NSLog(@"scaleValue = %.f",scaleValue);
    //                }
    //            }];
    //        }];
    //    }];
    //NSLog(@"self.valuesArray = %@",self.valuesArray);
    [self.valuesArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *dict = (NSDictionary *)obj;
        [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSString *them = (NSString *)key;
            NSNumber *num = (NSNumber *)obj;
            if (![self.xAxisTitleArray containsObject:them]) {
                [self.xAxisTitleArray addObject:them];
            }
            if ([num floatValue] >= scaleValue) {
                scaleValue = [num floatValue];
                //NSLog(@"scaleValue = %.f",scaleValue);
            }
        }];
    }];
    _xIntervalInPx = (self.frame.size.width-2*MARGIN_LEFT)/(self.xAxisTitleArray.count+1);
    _yIntervalInPx = (self.frame.size.height-MARGIN_BOTTOM-MARGIN_TOP)/(INTERVAL_COUNT+1);
    //_maxValue = (int)ceil(scaleValue) + INTERVAL_COUNT - (int)ceil(scaleValue) % INTERVAL_COUNT;
    _yAxisSaleValue = scaleValue/INTERVAL_COUNT;
    _maxValue = _yAxisSaleValue*(INTERVAL_COUNT+1);
    //NSLog(@"_yAxisSaleValue = %.f",_yAxisSaleValue);
}
//绘制x轴标题
-(void)drawXLabels
{
    [_xAxisTitleArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        float height = 10.0f;
        float topMargin = 10.0f;
        
        NSString *title = [NSString stringWithFormat:@"%@",obj];
        CGSize size = [title sizeWithFont:_themAttributs[wXAxisLabelFontKey] constrainedToSize:CGSizeMake(1024, 768) lineBreakMode:NSLineBreakByWordWrapping];
        
        float width = size.width;
        idx += 1;
        UILabel *xAxisLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN_LEFT+idx*_xIntervalInPx-width/2, self.frame.size.height-MARGIN_BOTTOM+topMargin, width, height)];
        xAxisLabel.textAlignment = NSTextAlignmentCenter;
        xAxisLabel.font = _themAttributs[wXAxisLabelFontKey];
        xAxisLabel.textColor = _themAttributs[wXAxisLabelColorKey];
        xAxisLabel.text = [NSString stringWithFormat:@"%@",obj];
        [self addSubview:xAxisLabel];
        
    }];
    
    //绘制项目标题
    NSArray *arr = [self.valuesDict allKeys];
    //NSLog(@"arr = %@",arr)
    for (int i=0; i<arr.count; i++) {
        //NSLog(@"ployLineColorArray=%@",self.ployLineColorArray);
        UIColor *color = [self.ployLineColorArray objectAtIndex:i];
        
        float width = 100;
        float margin = 30;
        
        if (width * arr.count + margin * (arr.count - 1) >= self.frame.size.width) {
            margin = 10;
            width = (self.frame.size.width-(arr.count-1)*margin)/arr.count;
        }
        float origiony = self.frame.size.height-MARGIN_BOTTOM+60;
        float origionx = (self.frame.size.width-arr.count*width-(arr.count-1)*margin)/2+(width+margin)*i;
        
        //NSLog(@"colorDic = %@",colorDic);
        
        //[[colorArr objectAtIndex:i %  [valueArr count]] setFill];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(origionx, origiony, 20, 20)];
        view.backgroundColor = color;
        [self addSubview:view];
        
        
        
        if(i< [arr count])
        {
            NSString *title = [arr objectAtIndex:i];
            CGSize size = [title sizeWithFont:[UIFont boldSystemFontOfSize:14] constrainedToSize:CGSizeMake(1024, 720) lineBreakMode:NSLineBreakByWordWrapping];
            //[title drawAtPoint:CGPointMake(origionx + 22, origiony) withFont:[UIFont boldSystemFontOfSize:14]];
            UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(origionx+22, origiony, size.width, size.height)];
            lbl.font = [UIFont boldSystemFontOfSize:14];
            lbl.textColor = color;
            lbl.text = title;
            [self addSubview:lbl];
            
        }
    }
}
//绘制y轴标题
-(void)drawYLables
{
    for (int i=0; i<=INTERVAL_COUNT+2; i++) {
        
        float height = 10.0f;
        float width = 60.0f;
        float rightMargin = 10.0f;
        UILabel *yAxisLabel = [[UILabel alloc] initWithFrame:CGRectMake((MARGIN_LEFT-width)-rightMargin, self.frame.size.height-(MARGIN_BOTTOM+_yIntervalInPx*i)-height/2, width, height)];
        yAxisLabel.textAlignment = NSTextAlignmentRight;
        yAxisLabel.textColor = _themAttributs[wYAxisLabelColorKey];
        yAxisLabel.font = _themAttributs[wYAxisLabelFontKey];
        
        NSString *title = [NSString stringWithFormat:@"%.1f",_yAxisSaleValue*i];
        if (i == (INTERVAL_COUNT+2)) {
            title = [NSString stringWithFormat:@"单位：%@",_yAxisSuffix];
            
            CGSize size = [title sizeWithFont:_themAttributs[wYAxisLabelFontKey] constrainedToSize:CGSizeMake(500, 1024) lineBreakMode:NSLineBreakByWordWrapping];
            width = size.width;
            yAxisLabel.frame = CGRectMake(MARGIN_LEFT, MARGIN_TOP-height*1.5, width, height);
            
        }
        
        yAxisLabel.text = title;
        [self addSubview:yAxisLabel];
        
    }
}
//绘制刻度横线
-(void)drawLines
{
    CAShapeLayer *linesLayer = [[CAShapeLayer alloc] init];
    linesLayer.frame = self.bounds;
    linesLayer.fillColor = [UIColor clearColor].CGColor;
    linesLayer.backgroundColor = [UIColor clearColor].CGColor;
    linesLayer.lineWidth = 1.0f;
    linesLayer.strokeColor = ((UIColor *)_themAttributs[wYAxisCatLineColorKey]).CGColor;
    
    CGMutablePathRef linesPath = CGPathCreateMutable();
    
    for (int i=1; i<INTERVAL_COUNT+1; i++) {
        CGPathMoveToPoint(linesPath, NULL, MARGIN_LEFT, self.frame.size.height-(MARGIN_BOTTOM+i * _yIntervalInPx));
        CGPathAddLineToPoint(linesPath, NULL, self.frame.size.width-MARGIN_LEFT, self.frame.size.height-(MARGIN_BOTTOM+i * _yIntervalInPx));
    }
    
    //绘制X,Y轴
    CGPoint points[4];
    points[0] = CGPointMake(MARGIN_LEFT, MARGIN_TOP);
    points[1] = CGPointMake(MARGIN_LEFT, self.frame.size.height-MARGIN_BOTTOM);
    points[2] = CGPointMake(self.frame.size.width-MARGIN_LEFT, self.frame.size.height-MARGIN_BOTTOM);
    points[3] = CGPointMake(self.frame.size.width-MARGIN_LEFT, MARGIN_TOP);
    
    CGPathAddLines(linesPath, NULL, points, 4);
    CGPathCloseSubpath(linesPath);
    linesLayer.path = linesPath;
    [self.layer addSublayer:linesLayer];
    
}
//绘制折线
-(void)drawPloyline
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration = 1;
    animation.fromValue = @(0.0);
    animation.toValue = @(1.0);
    
    for (int j=0; j<self.valuesArray.count; j++) {
        
        CAShapeLayer *ployLineLayer = [[CAShapeLayer alloc] init];
        ployLineLayer.frame = self.bounds;
        ployLineLayer.fillColor = [UIColor clearColor].CGColor;
        ployLineLayer.backgroundColor = [UIColor clearColor].CGColor;
        
        UIColor *color = [self.ployLineColorArray objectAtIndex:j];
        //UIColor *color = [UIColor blackColor];
        
        ployLineLayer.strokeColor = color.CGColor;
        [ployLineLayer setLineWidth:1.0f];
        
        [ployLineLayer addAnimation:animation forKey:@"strokeEnd"];
        ployLineLayer.zPosition = 1;
        
        CGMutablePathRef ployLinePath = CGPathCreateMutable();
        
        CAShapeLayer *circleLayer = [[CAShapeLayer alloc] init];
        circleLayer.frame = self.bounds;
        circleLayer.fillColor = [UIColor clearColor].CGColor;
        circleLayer.backgroundColor = [UIColor clearColor].CGColor;
        circleLayer.strokeColor = color.CGColor;
        circleLayer.fillColor = color.CGColor;
        [circleLayer setLineWidth:1.0f];
        
        CGMutablePathRef circlePath = CGPathCreateMutable();
        NSDictionary *dict = [self.valuesArray objectAtIndex:j];
        
        CGPoint points[_xAxisTitleArray.count+2];
        for (int i=1; i<=   _xAxisTitleArray.count; i++) {
            
            float f = [[dict objectForKey:[_xAxisTitleArray objectAtIndex:i-1]] floatValue];
            //float f = [[dic objectForKey:[[dic allKeys] objectAtIndex:0]] floatValue];
            //NSLog(@"f = %f",f);
            
            float y = self.frame.size.height - (f*((self.frame.size.height-MARGIN_BOTTOM-MARGIN_TOP)/_maxValue)+MARGIN_BOTTOM);
            //NSLog(@"f = %f",f);
            points[i] = CGPointMake(i * _xIntervalInPx+MARGIN_LEFT, y);
            //画点
            float plotWidth = 5.0f;
            CGPathAddEllipseInRect(circlePath, NULL, CGRectMake(points[i].x-plotWidth/2, points[i].y-plotWidth/2, plotWidth, plotWidth));
            //画label
            float width = 60;
            float height = 30;
            
            UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(points[i].x-width/2, points[i].y-height, width, height)];
            lbl.textAlignment = NSTextAlignmentCenter;
            lbl.text = [NSString stringWithFormat:@"%.1f",f];
            lbl.textColor = color;
            lbl.font = _themAttributs[wXAxisLabelFontKey];
            [self addSubview:lbl];
            
        }
        
        points[0] = CGPointMake(MARGIN_LEFT, points[1].y);
        points[_xAxisTitleArray.count+1] = CGPointMake((_xAxisTitleArray.count+1) * _xIntervalInPx+MARGIN_LEFT, points[_xAxisTitleArray.count].y);
        CGPathAddLines(ployLinePath, NULL, points, _xAxisTitleArray.count+2);
        
        ployLineLayer.path = ployLinePath;
        [self.layer addSublayer:ployLineLayer];
        
        
        circleLayer.path = circlePath;
        [self.layer addSublayer:circleLayer];
        
    }
    
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
