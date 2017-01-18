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

#import "WQBarGraphView.h"

@interface WQBarGraphView()
{
    //x轴间距，y轴间距，最大值，y轴值间距
    float _xIntervalInPx,_yIntervalInPx,_maxValue,_yAxisSaleValue,_heigh;
    NSTimer *timer;
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
//柱颜色
@property (nonatomic,retain)NSArray *barColorArray;

@property (nonatomic,retain)NSMutableArray *muArray;
@property (nonatomic,retain)NSMutableArray *maxColumnHiighArray;

@end

@implementation WQBarGraphView

NSString *const bXAxisLabelColorKey = @"bXAxisLabelColorKey";
NSString *const bXAxisLabelFontKey = @"bXAxisLabelFontKey";
NSString *const bYAxisLabelColorKey = @"bYAxisLabelColorKey";
NSString *const bYAxisLabelFontKey = @"bYAxisLabelFontKey";
//柱标题
NSString *const bBarTitleLabelFontKey = @"bBarTitleLabelFontKey";
//分割线颜色
NSString *const bYAxisCatLineColorKey = @"bYAxisCatLineColorKey";
//柱颜色
NSString *const bBarColorArrayKey = @"bBarColorArrayKey";
//Y轴后缀
NSString *const bYAxisSuffix = @"bYAxisSuffix";

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame ThemAttributs:(NSDictionary *)tADict ValuesDict:(NSDictionary *)valueDict
{
    self = [super initWithFrame:frame];
    if (self) {
        self.xAxisTitleArray = [NSMutableArray arrayWithCapacity:0];
        self.themAttributs = tADict;
        self.valuesArray = [valueDict allValues];
        self.valuesDict = valueDict;
        self.yAxisSuffix = _themAttributs[bYAxisSuffix];
        self.barColorArray = _themAttributs[bBarColorArrayKey];
        
        if (self.barColorArray.count != self.valuesArray.count) {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"ColorRatio" ofType:@"plist"];
            self.barColorArray = [NSArray arrayWithContentsOfFile:path];
        }
        
        self.muArray = [NSMutableArray arrayWithCapacity:0];
        self.maxColumnHiighArray = [NSMutableArray arrayWithCapacity:0];
        for (NSArray *arr in self.valuesArray) {
            NSMutableArray *amaxColumnHiighArray = [NSMutableArray arrayWithCapacity:0];
            NSMutableArray *amuArray = [NSMutableArray arrayWithCapacity:0];
            for (int i=0; i<arr.count; i++) {
                
                [amuArray addObject: [NSNumber numberWithFloat:0]];
                [amaxColumnHiighArray addObject: [NSNumber numberWithFloat:0]];
            }
            [self.muArray addObject:amuArray];
            [self.maxColumnHiighArray addObject:amaxColumnHiighArray];
        }
        
        timer=[NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(animationTurn) userInfo:nil repeats:YES];
        [timer fire];
    }
    
    return self;
}

-(void)animationTurn{
    _heigh=_heigh+10;
    for (int j=0; j<self.valuesArray.count; j++) {
        NSMutableArray *amuArray = [self.muArray objectAtIndex:j];
        NSMutableArray *amaxColumnHiighArray = [self.maxColumnHiighArray objectAtIndex:j];
        for (int i=0; i<[[self.valuesArray objectAtIndex:j] count]; i++) {
            [amuArray insertObject:[NSNumber numberWithFloat:_heigh] atIndex:i];
            
            if ([[amuArray objectAtIndex:i] floatValue]>=[[amaxColumnHiighArray objectAtIndex:i] floatValue]) {
                //             [[muArray objectAtIndex:i] floatValue]=[[maxColumnHiighArray objectAtIndex:i] floatValue];
                [amuArray insertObject:[amaxColumnHiighArray objectAtIndex:i] atIndex:i];
            }
        }
        //[muArray insertObject:amuArray atIndex:j];
    }
    
    [self setNeedsDisplay];
    
}

-(void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, rect);
    
    //计算刻度
    [self calcScales];
    //绘制x轴标题
    [self drawXLabels:context];
    //绘制y轴标题
    [self drawYLables:context];
    //绘制刻度横线
    [self drawLines:context];
    //绘制柱
    [self drawBar:context];
}

//计算刻度
-(void)calcScales
{
    _maxValue = 0.0f;
    __block float scaleValue = 0.0f;
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
-(void)drawXLabels:(CGContextRef)context
{
    
    [_xAxisTitleArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        //        float height = 10.0f;
        //        float width = 60.0f;
        float topMargin = 10.0f;
        idx += 1;
        //        UILabel *xAxisLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN_LEFT+idx*_xIntervalInPx-width/2, self.frame.size.height-MARGIN_BOTTOM+topMargin, width, height)];
        //        xAxisLabel.textAlignment = NSTextAlignmentCenter;
        //        xAxisLabel.font = _themAttributs[bXAxisLabelFontKey];
        //        xAxisLabel.textColor = _themAttributs[bXAxisLabelColorKey];
        //        xAxisLabel.text = [NSString stringWithFormat:@"%@",obj];
        //        [self addSubview:xAxisLabel];
        //        [xAxisLabel release];
        
        NSString *scaleStr = [NSString stringWithFormat:@"%@",obj];
        CGSize size = [scaleStr sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:_themAttributs[bXAxisLabelFontKey],NSFontAttributeName, nil]];
        [scaleStr drawAtPoint:CGPointMake(MARGIN_LEFT+idx*_xIntervalInPx-size.width/2, self.frame.size.height-MARGIN_BOTTOM+topMargin) withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:_themAttributs[bXAxisLabelFontKey],NSFontAttributeName, nil]];
    }];
    
    //绘制项目标题
    NSArray *arr = [self.valuesDict allKeys];
    //NSLog(@"arr = %@",arr)
    for (int i=0; i<arr.count; i++) {
        //NSLog(@"self.barColorArray=%@",self.barColorArray);
        NSDictionary *colorDic = [self.barColorArray objectAtIndex:i];
        
        float width = 100;
        float margin = 30;
        
        if (width * arr.count + margin * (arr.count - 1) >= self.frame.size.width) {
            margin = 10;
            width = (self.frame.size.width-(arr.count-1)*margin)/arr.count;
        }
        float origiony = self.frame.size.height-MARGIN_BOTTOM+60;
        float origionx = (self.frame.size.width-arr.count*width-(arr.count-1)*margin)/2+(width+margin)*i;
        
        //NSLog(@"colorDic = %@",colorDic);
        UIColor *fillColor = [UIColor colorWithRed:[[colorDic objectForKey:@"RED"] floatValue]/255.0f green:[[colorDic objectForKey:@"GREEN"] floatValue]/255.0f blue:[[colorDic objectForKey:@"BLUE"] floatValue]/255.0f alpha:[[colorDic objectForKey:@"ALPHA"] floatValue]];
        [fillColor setFill];
        //[[colorArr objectAtIndex:i %  [valueArr count]] setFill];
        
        CGContextFillRect(context, CGRectMake(origionx, origiony, 20, 20));
        CGContextDrawPath(context, kCGPathFill);
        
        
        if(i< [arr count])
        {
            NSString *title = [arr objectAtIndex:i];
            [title drawAtPoint:CGPointMake(origionx + 22, origiony) withFont:[UIFont boldSystemFontOfSize:14]];
        }
    }
}
//绘制y轴标题
-(void)drawYLables:(CGContextRef)context
{
    for (int i=0; i<=INTERVAL_COUNT+2; i++) {
        
        float rightMargin = 10.0f;
        
        if (i == INTERVAL_COUNT + 2) {
            NSString *scaleStr = [NSString stringWithFormat:@"单位：%@",_yAxisSuffix];
            CGSize size = [scaleStr sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:_themAttributs[bYAxisLabelFontKey],NSFontAttributeName, nil]];
            [scaleStr drawAtPoint:CGPointMake(MARGIN_LEFT, MARGIN_TOP-size.height*1.5) withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:_themAttributs[bYAxisLabelFontKey],NSFontAttributeName, nil]];
        }
        else
        {
            NSString *scaleStr = [NSString stringWithFormat:@"%.1f",_yAxisSaleValue*i];
            CGSize size = [scaleStr sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:_themAttributs[bYAxisLabelFontKey],NSFontAttributeName, nil]];
            [scaleStr drawAtPoint:CGPointMake((MARGIN_LEFT-size.width)-rightMargin, self.frame.size.height-(MARGIN_BOTTOM+_yIntervalInPx*i)-size.height/2) withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:_themAttributs[bYAxisLabelFontKey],NSFontAttributeName, nil]];
        }
    }
}
//绘制刻度横线
-(void)drawLines:(CGContextRef)context
{
    
    for (int i=1; i<INTERVAL_COUNT+1; i++) {
        CGPoint points[2];
        points[0] = CGPointMake(MARGIN_LEFT, self.frame.size.height-(MARGIN_BOTTOM+i * _yIntervalInPx));
        points[1] = CGPointMake(self.frame.size.width-MARGIN_LEFT, self.frame.size.height-(MARGIN_BOTTOM+i * _yIntervalInPx));
        //绘制长刻度线
        CGContextAddLines(context, points, 2);
        const CGFloat partren[] = {2,3};
        CGContextSetLineDash(context, 0, partren, 2);
        CGContextSetStrokeColorWithColor(context, ((UIColor *)_themAttributs[bYAxisCatLineColorKey]).CGColor);
        CGContextDrawPath(context, kCGPathStroke);
        
        //绘制短刻度线
        points[0] = CGPointMake(MARGIN_LEFT-3, self.frame.size.height-(MARGIN_BOTTOM+i * _yIntervalInPx));
        points[1] = CGPointMake(MARGIN_LEFT, self.frame.size.height-(MARGIN_BOTTOM+i * _yIntervalInPx));
        CGContextSetStrokeColorWithColor(context, ((UIColor *)_themAttributs[bYAxisLabelColorKey]).CGColor);
        CGContextSetLineDash(context, 0, nil, 0);
        CGContextAddLines(context, points, 2);
        CGContextDrawPath(context, kCGPathStroke);
    }
    
    //绘制X,Y轴
    CGPoint points[5];
    points[0] = CGPointMake(MARGIN_LEFT, MARGIN_TOP);
    points[1] = CGPointMake(MARGIN_LEFT, self.frame.size.height-MARGIN_BOTTOM);
    points[2] = CGPointMake(self.frame.size.width-MARGIN_LEFT, self.frame.size.height-MARGIN_BOTTOM);
    points[3] = CGPointMake(self.frame.size.width-MARGIN_LEFT, MARGIN_TOP);
    points[4] = CGPointMake(MARGIN_LEFT, MARGIN_TOP);
    
    CGContextSetAllowsAntialiasing(context, NO);
    CGContextAddLines(context, points, 5);
    CGContextSetFillColorWithColor(context, ((UIColor *)_themAttributs[bXAxisLabelColorKey]).CGColor);
    CGContextDrawPath(context, kCGPathStroke);
}
//绘制柱
-(void)drawBar:(CGContextRef)context
{
    CGPoint points[4];
    
    
    //NSLog(@"margin = %f",margin);
    //每个柱正面的宽度
    float eWidth = _xIntervalInPx/(self.valuesArray.count+1);
    //每组之间的距离
    float margin = eWidth;
    
    float sideWidth = 0.5*eWidth;
    for (int i=0; i<_xAxisTitleArray.count; i++) {
        for (int j=0; j<self.valuesArray.count; j++) {
            NSDictionary *dic = [self.valuesArray objectAtIndex:j];
            float v = [[dic objectForKey:[self.xAxisTitleArray objectAtIndex:i]] floatValue];
            float 	columnHeight = v*((self.frame.size.height-MARGIN_BOTTOM-MARGIN_TOP)/_maxValue);
            //每个柱正面的x坐标
            float eX = ((0.5*_xIntervalInPx+0.5*margin) + eWidth * j) + eWidth * self.valuesArray.count * i + i * margin + MARGIN_LEFT;
            //每个柱正面的y坐标
            float eY = self.frame.size.height - MARGIN_BOTTOM - [[[_muArray objectAtIndex:j] objectAtIndex:i] floatValue];
            //每个柱正面的高度
            float eHeight = [[[_muArray objectAtIndex:j] objectAtIndex:i] floatValue];
            
            [[_maxColumnHiighArray objectAtIndex:j] insertObject:[NSNumber numberWithFloat:columnHeight] atIndex:i];
            
            NSDictionary *colorDic = [self.barColorArray objectAtIndex:j];
            
            float red = [[colorDic objectForKey:@"RED"] floatValue];
            float green = [[colorDic objectForKey:@"GREEN"] floatValue];
            float blue = [[colorDic objectForKey:@"BLUE"] floatValue];
            float alpha = [[colorDic objectForKey:@"ALPHA"] floatValue];
            
            
            //侧面色差
            float sideMeter = 20.0f;
            //上面色差
            float topMeter = 40.0f;
            
            //画正面
            CGContextSetFillColorWithColor(context, ([UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha]).CGColor);
            CGContextAddRect(context, CGRectMake(eX, eY, eWidth, eHeight));
            CGContextDrawPath(context, kCGPathFill);
            
            //绘制柱标题
            NSString *scaleStr = [NSString stringWithFormat:@"%.1f",v];
            //NSLog(@"scaleStr = %@",scaleStr);
            CGSize size = [scaleStr sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:_themAttributs[bYAxisLabelFontKey],NSFontAttributeName, nil]];
            [[UIColor whiteColor] setFill];
            
            UIColor *stringColor = [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha];  //设置文本的颜色
            NSDictionary* attrs =@{NSForegroundColorAttributeName:stringColor,
                                   NSFontAttributeName:[UIFont boldSystemFontOfSize:12.0f]
                                   }; //在词典中加入文本的颜色 字体 大小
            [scaleStr drawAtPoint:CGPointMake(eX+eWidth*0.5, eY-size.height-10) withAttributes:attrs];
            //[stringColor setFill];
            //[scaleStr drawInRect:CGRectMake(eX, eY-size.height-10, eWidth, 20) withFont:[UIFont boldSystemFontOfSize:12.0f] lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft];
            
            
            if(eHeight < 10){
                //vNumber++;
                continue;
            }
            
            //画右侧面
            CGContextSetFillColorWithColor(context, ([UIColor colorWithRed:(red-sideMeter>0?(red-sideMeter):0)/255.0f green:(green-sideMeter>0?(green-sideMeter):0)/255.0f blue:(blue-sideMeter>0?(blue-sideMeter):0)/255.0f alpha:alpha]).CGColor);
            points[0] = CGPointMake(eX+eWidth, eY -10);
            points[1] = CGPointMake(eX+eWidth + sideWidth, eY -10 );
            points[2] = CGPointMake(eX+eWidth + sideWidth, self.frame.size.height-MARGIN_BOTTOM );
            points[3] = CGPointMake(eX+eWidth, self.frame.size.height-MARGIN_BOTTOM);
            
            CGContextAddLines(context, points, 4);
            CGContextDrawPath(context, kCGPathFill);
            
            //画上面
            CGContextSetFillColorWithColor(context, ([UIColor colorWithRed:(red+topMeter<255?(red+topMeter):255)/255.0f green:(green+topMeter<255?(green+topMeter):255)/255.0f blue:(blue+topMeter<255?(blue+topMeter):255)/255.0f alpha:alpha]).CGColor);
            points[0] = CGPointMake(eX , eY );
            points[1] = CGPointMake(eX + sideWidth, eY -10 );
            points[2] = CGPointMake(eX+eWidth + sideWidth , eY -10 );
            points[3] = CGPointMake(eX+eWidth, eY );
            
            CGContextAddLines(context, points, 4);
            CGContextDrawPath(context, kCGPathFill);
            
        }
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
