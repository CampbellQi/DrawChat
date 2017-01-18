//
//  WQGaugeGraphView.m
//  DataService
//
//  Created by UWINY on 14-6-17.
//  Copyright (c) 2014年 Test. All rights reserved.
//
#define POINTEROFFSET  90.0f

#define MAXOFFSETANGLE 120
//各个边界的距离
#define MARGIN 50
//长刻度和半径比率
#define LINEWIDTHRAGE 0.15
#define CELLMARKNUM 5
#import "WQGaugeGraphView.h"

//后缀
NSString *const gSuffix = @"gSuffix";
//名称
NSString *const gName = @"gName";
//最大值
NSString *const gMaxValue = @"gMaxValue";
//最小值
NSString *const gMinValue = @"gMinValue";
//分割的数字标题数量
NSString *const gLabelNum = @"gLabelNum";

@interface WQGaugeGraphView()
@property (nonatomic,retain)NSDictionary *themAttributs;

@end
@implementation WQGaugeGraphView
{
    float maxAngle;
    float minAngle;
    float maxValue;
    float minValue;
    int labelNum;
    
    float maxRadius;
    float value;
    
    float gaugeValue;
    float angleperValue;
    float gaugeAngle;
    UIImage *gaugeView;
    UIImageView *pointer;
}

@synthesize gaugeView,pointer;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame ThemAttributs:(NSDictionary *)themAttributs Value:(float)aValue
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor grayColor];
        maxAngle = MAXOFFSETANGLE;
        minAngle = -MAXOFFSETANGLE;
        
        gaugeAngle = -MAXOFFSETANGLE;
        value = aValue;
        labelNum = [themAttributs[gLabelNum] intValue];
        maxValue = ((int)ceill([themAttributs[gMaxValue] floatValue])) - (((int)ceill([themAttributs[gMaxValue] floatValue])) % (labelNum-1));
        minValue = 0.0f;
        
        self.themAttributs = themAttributs;
        
        maxRadius = self.frame.size.width > self.frame.size.height ? (self.frame.size.height-2*MARGIN)/2 : (self.frame.size.width-2*MARGIN)/2;
        
        angleperValue = (maxAngle - minAngle)/(maxValue - minValue);
        
        gaugeView= [UIImage imageNamed:@"gaugeback.png"];
        //添加指针
        UIImage *_pointer = [UIImage imageNamed:@"pointer2.png"];
        pointer = [[UIImageView alloc] initWithImage:_pointer];
        pointer.layer.anchorPoint = CGPointMake(0.5, 0.78);
        pointer.center = self.center;
        pointer.transform = CGAffineTransformMakeScale(300/maxRadius, 300/maxRadius);
        [self addSubview:pointer];
        
        //设置指针到0位置
        pointer.layer.transform = CATransform3DMakeRotation([self transToRadian:-MAXOFFSETANGLE], 0, 0, 1);
    }
    return self;
}

-(void)drawRect:(CGRect)rect
{
    //获取上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    //设置背景透明
    CGContextSetFillColorWithColor(context,self.backgroundColor.CGColor);
    CGContextFillRect(context, rect);
    
    float yy = 25;
    //绘制仪表背景
    [[self gaugeView] drawInRect:CGRectMake(self.frame.size.width/2-maxRadius-yy, self.frame.size.height/2-maxRadius-yy, maxRadius*2+2*yy, maxRadius*2+2*yy)];
    
    //绘制数字标题
    [self drawTextLable];
    //绘制刻度
    [self drawLineMark:context];
    
    CGContextStrokePath(context);
    
    [self setGaugeValue:value animation:NO];
}

-(void)drawTextLable
{
    //标题数字间距
    CGFloat textDis = (maxValue - minValue)/(labelNum-1);
    //标题之间占有的角度
    CGFloat angelDis = (maxAngle - minAngle)/(labelNum-1);
    CGFloat radius = maxRadius*(1-LINEWIDTHRAGE)-20;
    CGFloat currentAngle;
    CGFloat currentText = 0.0f;
    CGPoint centerPoint = self.center;
    
    for (int i=0; i< labelNum; i++) {
        currentAngle = minAngle + i * angelDis - POINTEROFFSET;
        currentText = minValue + i * textDis;
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0 , 0 , 30, 50)];
        label.autoresizesSubviews = YES;
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        //设置刻度的文字的格式
        if(i<(labelNum-1)/2){
            label.textAlignment = NSTextAlignmentLeft;
        }else if (i==(labelNum-1)/2){
            label.textAlignment = NSTextAlignmentCenter;
        }else{
            label.textAlignment = NSTextAlignmentRight;
        }
        label.text = [NSString stringWithFormat:@"%d",(int)currentText];
        label.center = CGPointMake(centerPoint.x+[self parseToX:radius Angle:currentAngle],centerPoint.y+[self parseToY:radius Angle:currentAngle]);
        
        //[labelArray addObject:label];
        [self addSubview:label];
        
    }
    // 设置刻度表的名称
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0 , 0 ,100, 40)];
    label.autoresizesSubviews = YES;
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [NSString stringWithFormat:@"单位：%@",_themAttributs[gSuffix]];
    label.center = CGPointMake(centerPoint.x,centerPoint.y*3/2);
    label.font = [UIFont systemFontOfSize:12.0f];
    [self addSubview:label];
    
    
    // 设置刻度表的名称
    NSString *name = [NSString stringWithFormat:@"%@：%.1f %@",_themAttributs[gName],value,_themAttributs[gSuffix]];
    //CGSize size = [name sizeWithFont:[UIFont boldSystemFontOfSize:14.0f] constrainedToSize:CGSizeMake(1024, 760) lineBreakMode:NSLineBreakByWordWrapping];
    //NSLog(@"size.width = %f",size.width);
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0 , 0 ,self.frame.size.width-2*MARGIN, 40)];
    nameLabel.autoresizesSubviews = YES;
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.text = name;
    nameLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    nameLabel.center = CGPointMake(centerPoint.x,self.frame.size.height-10);
    [self addSubview:nameLabel];
    
}

-(void)drawLineMark:(CGContextRef)context
{
    CGFloat angelDis = (maxAngle - minAngle)/((labelNum-1)*CELLMARKNUM);
    CGFloat radius = maxRadius;
    CGFloat currentAngle;
    CGPoint centerPoint = self.center;
    
    for(int i=0;i<=(labelNum-1)*CELLMARKNUM;i++)
    {
        currentAngle = minAngle + i * angelDis - POINTEROFFSET;
        //给刻度标记绘制不同的颜色
        if(i>((labelNum-1)*CELLMARKNUM)*2/3)
        {
            CGContextSetStrokeColorWithColor(context, [[UIColor colorWithRed:1 green:0 blue:0 alpha:0.8] CGColor]);
        }else if(i>((labelNum-1)*CELLMARKNUM)*1/3){
            CGContextSetStrokeColorWithColor(context, [[UIColor colorWithRed:1 green:1 blue:0 alpha:0.8] CGColor]);
        }else{
            CGContextSetStrokeColorWithColor(context, [[UIColor colorWithRed:0 green:1 blue:0 alpha:0.8] CGColor]);
        }
        //绘制不同的长短的刻度
        if(i%CELLMARKNUM!=0)
        {
            float shortLineWidth = 0.25*LINEWIDTHRAGE;
            CGContextSetLineCap(context, kCGLineCapSquare);
            CGContextSetLineWidth(context, 3);
            CGContextStrokePath(context);
            CGContextMoveToPoint(context,centerPoint.x+[self parseToX:radius Angle:currentAngle], centerPoint.y+[self parseToY:radius Angle:currentAngle]);
            CGContextAddLineToPoint(context,centerPoint.x+[self parseToX:radius*(1-shortLineWidth) Angle:currentAngle], centerPoint.y+[self parseToY:radius*(1-shortLineWidth) Angle:currentAngle]);
        }else{
            CGContextSetLineWidth(context, 2);
            CGContextSetLineCap(context, kCGLineCapSquare);
            CGContextStrokePath(context);
            CGContextMoveToPoint(context,centerPoint.x+[self parseToX:radius Angle:currentAngle], centerPoint.y+[self parseToY:radius Angle:currentAngle]);
            CGContextAddLineToPoint(context,centerPoint.x+[self parseToX:radius*(1-LINEWIDTHRAGE) Angle:currentAngle], centerPoint.y+[self parseToY:radius*(1-LINEWIDTHRAGE) Angle:currentAngle]);
        }
    }
    //
    //    //绘制渐变
    //	CGFloat componets [] = {0.0,0.0,0.0,1,0.6, 0.6, 0.6, 1};
    //
    //	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    //
    //	CGGradientRef gradient = CGGradientCreateWithColorComponents(colorspace, componets, nil, 2);
    //	//绘制一个沿着由所提供的开始和结束的圆限定的区域变化的渐变填充。
    //	CGContextDrawRadialGradient(context, gradient, self.center, maxRadius*0.6, self.center, maxRadius*1.01, 0 );
    //
    //	CFRelease(colorspace);
    //	CGGradientRelease(gradient);
    
    //    CGFloat componets1 [] = {0.0,0.0,0.0,0.0,1.0,1.0,1.0,0.0};
    //
    //	CGColorSpaceRef colorspace1 = CGColorSpaceCreateDeviceRGB();
    //
    //	CGGradientRef gradient1 = CGGradientCreateWithColorComponents(colorspace1, componets1, nil, 2);
    //	//绘制一个沿着由所提供的开始和结束的圆限定的区域变化的渐变填充。
    //	CGContextDrawRadialGradient(context, gradient1, self.center, maxRadius, self.center, maxRadius+20, 0 );
    //
    //	CFRelease(colorspace1);
    //	CGGradientRelease(gradient1);
}
/*
 * parseToX 角度转弧度
 * @angel CGFloat 角度
 */
-(CGFloat)transToRadian:(CGFloat)angel
{
    return angel*M_PI/180;
}


/*
 * parseToX 根据角度，半径计算X坐标
 * @radius CGFloat 半径
 * @angle  CGFloat 角度
 */
- (CGFloat) parseToX:(CGFloat) radius Angle:(CGFloat)angle
{
    CGFloat tempRadian = [self transToRadian:angle];
    return radius*cos(tempRadian);
}

/*
 * parseToY 根据角度，半径计算Y坐标
 * @radius CGFloat 半径
 * @angle  CGFloat 角度
 */
- (CGFloat) parseToY:(CGFloat) radius Angle:(CGFloat)angle
{
    CGFloat tempRadian = [self transToRadian:angle];
    return radius*sin(tempRadian);
}

-(void)setGaugeValue:(CGFloat)aValue animation:(BOOL)isAnim
{
    CGFloat tempAngle = [self parseToAngle:aValue];
    gaugeValue = value;
    //设置转动时间和转动动画
    if(isAnim){
        [self pointToAngle:tempAngle Duration:0.6f];
    }else
    {
        [self pointToAngle:tempAngle Duration:0.0f];
    }
}

/*
 * parseToAngle 根据数据计算需要转动的角度
 * @val CGFloat 要移动到的数值
 */
-(CGFloat) parseToAngle:(CGFloat) val
{
    //	//异常的数据
    //	if(val<maxValue){
    //		return minValue;
    //	}else if(val>maxValue){
    //		return maxValue;
    //	}
    CGFloat temp =(val-gaugeValue)*angleperValue;
    return temp;
}

/*
 * pointToAngle 按角度旋转
 * @angel CGFloat 角度
 * @duration CGFloat 动画执行时间
 */
- (void) pointToAngle:(CGFloat) angle Duration:(CGFloat) duration
{
    CAKeyframeAnimation *anim=[CAKeyframeAnimation animationWithKeyPath:@"transform"];
    NSMutableArray *values=[NSMutableArray array];
    anim.duration = duration;
    anim.autoreverses = NO;
    anim.fillMode = kCAFillModeForwards;
    anim.removedOnCompletion= NO;
    
    CGFloat distance = angle/10;
    //设置转动路径，不能直接用 CABaseAnimation 的toValue，那样是按最短路径的，转动超过180度时无法控制方向
    int i = 1;
    for(;i<=10;i++){
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DRotate(CATransform3DIdentity, [self transToRadian:(gaugeAngle+distance*i)], 0, 0, 1)]];
    }
    //添加缓动效果
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DRotate(CATransform3DIdentity, [self transToRadian:(gaugeAngle+distance*(i))], 0, 0, 1)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DRotate(CATransform3DIdentity, [self transToRadian:(gaugeAngle+distance*(i-2))], 0, 0, 1)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DRotate(CATransform3DIdentity, [self transToRadian:(gaugeAngle+distance*(i-1))], 0, 0, 1)]];
    
    anim.values=values; ;
    [pointer.layer addAnimation:anim forKey:@"cubeIn"];
    
    gaugeAngle = gaugeAngle+angle;
    
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
