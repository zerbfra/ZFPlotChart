//
//  ZFPlotChart.m
//
//  Created by Zerbinati Francesco
//  Copyright (c) 2014-2015
//

#import "ZFPlotChart.h"

@implementation ZFPlotChart

@synthesize dictDispPoint;
@synthesize chartWidth, chartHeight;

@synthesize prevPoint, curPoint, currentLoc;
@synthesize min, max;


#pragma mark - Initialization/LifeCycle Method
- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        @try {
            
            [self setAutoresizingMask: UIViewAutoresizingFlexibleWidth];
            [self setAutoresizesSubviews:YES];
            
            self.backgroundColor = whiteColor;
            
            
            
            self.chartHeight = frame.size.height - vMargin;
            self.chartWidth = frame.size.width - hMargin;
   
            
            isMovement = NO;
            
            self.dictDispPoint = [[NSMutableOrderedSet alloc] initWithCapacity:0];
            
            
            
        }
        @catch (NSException *exception) {
            NSLog(@"%@",[exception debugDescription]);
        }
        @finally {
            
        }
    }
    return self;
}

#pragma mark - Chart Creation Method
- (void)createChartWith:(NSOrderedSet *)data
{
    
    [self.dictDispPoint removeAllObjects];
    
    NSMutableOrderedSet *orderSet = [[NSMutableOrderedSet alloc] initWithCapacity:0];
    
    // Add data to the orderSet
    [data enumerateObjectsUsingBlock:^(id obj, NSUInteger ind, BOOL *stop){
        [orderSet addObject:obj];
        
    }];
    
    // Find Min & Max of Chart
    self.max = [[[orderSet valueForKey:fzValue] valueForKeyPath:@"@max.floatValue"] floatValue];
    self.min = [[[orderSet valueForKey:fzValue] valueForKeyPath:@"@min.floatValue"] floatValue];
    
    
    // Enhance Upper & Lower Limit for Flexible Display, based on average of min and max
    self.max = ceilf((self.max+10 )/ 1000)*1000;
    self.min = floor((self.min-10)/1000)*1000;
    
    // Calculate left space given by the lenght of the string on the axis
    self.leftMargin = [self sizeOfString:[self formatNumberAsCurrency:self.max/100 withFractionDigits:0] withFont:systemFont].width + leftSpace;
    
    self.chartWidth-= self.leftMargin;
    float range = self.max-self.min;
    
    // Calculate deploying points for chart according to values
    float xGapBetweenTwoPoints = self.chartWidth/[orderSet count];
    float x , y;
    

    x = self.leftMargin;
    y = topMargin;
    
    self.yMax = 0;
    
    // assing points to values
    for(NSDictionary *dictionary in orderSet)
    {
        float priceValue = [[dictionary valueForKey:fzValue] floatValue];
        
        float diff = (self.max-priceValue);
        
        y = ((self.chartHeight)*diff)/range + topMargin;
        
        // calculate maximum y
        if(y > self.yMax) self.yMax = y;
        
        CGPoint point = CGPointMake(x,y);
        
        NSDictionary *dictPoint = [NSDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithCGPoint:point], fzPoint,
                                   [dictionary valueForKey:fzValue], fzValue,
                                   [dictionary valueForKey:fzDate], fzDate, nil];
        
        [self.dictDispPoint addObject:dictPoint];
        
        x+= xGapBetweenTwoPoints;
    }
    
    [self setNeedsDisplay];
    
}

#pragma mark - Drawing
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    @try
    {
        if([self.dictDispPoint count] > 0)
        {
            // remove loading animation
            [self stopLoading];
            
            float range = self.max-self.min;
            float intervalHlines = (self.chartHeight)/5.0f;
            float intervalValues = range/5.0f;
            
            // horizontal lines
            for(int i=5;i>0;i--)
            {
                [self setContextWidth:0.5f andColor:linesColor];
                
                CGPoint start = CGPointMake(self.leftMargin, self.chartHeight+topMargin-i*intervalHlines);
                CGPoint end = CGPointMake(self.chartWidth+self.leftMargin, self.chartHeight+topMargin-i*intervalHlines);
                
                // draw the line
                [self drawLineFrom:start to:end];
                
                // draw prices on the axis
                NSString *prezzoAsse = [self formatNumberAsCurrency:(self.min+i*intervalValues)/100 withFractionDigits:0];
                CGPoint prezzoAssePoint = CGPointMake(self.leftMargin - [self sizeOfString:prezzoAsse withFont:systemFont].width - 5,(self.chartHeight+topMargin-i*intervalHlines-6));
                
                [self drawString:prezzoAsse at:prezzoAssePoint withFont:systemFont andColor:linesColor];
                
                [self endContext];
                
            }
            
            /*** Draw points ***/
            [self.dictDispPoint enumerateObjectsUsingBlock:^(id obj, NSUInteger ind, BOOL *stop){
                if(ind > 0)
                {
                    self.prevPoint = [[[self.dictDispPoint objectAtIndex:ind-1] valueForKey:fzPoint] CGPointValue];
                    self.curPoint = [[[self.dictDispPoint objectAtIndex:ind] valueForKey:fzPoint] CGPointValue];
                }
                else
                {
                    // first point
                    self.prevPoint = [[[self.dictDispPoint objectAtIndex:ind] valueForKey:fzPoint] CGPointValue];
                    self.curPoint = self.prevPoint;
                }
                
                // line style
                [self setContextWidth:1.5f andColor:orangeColor];
                
                // draw the curve
                [self drawCurveFrom:self.prevPoint to:self.curPoint];

                [self endContext];
                
                
                long linesRatio;
                
                if([self.dictDispPoint count] < 4)
                    linesRatio = [self.dictDispPoint count]/([self.dictDispPoint count]-1);
                else    linesRatio  = [self.dictDispPoint count]/4 ;
                
                
                if(ind%linesRatio == 0) {
                    
                    [self setContextWidth:0.5f andColor:linesColor];
                    
                    // Vertical Lines
                    if(ind!=0) {
                        CGPoint lower = CGPointMake(self.curPoint.x, topMargin+self.chartHeight);
                        CGPoint higher = CGPointMake(self.curPoint.x, topMargin);
                        [self drawLineFrom:lower to: higher];
                        
                    }
                    
                    [self endContext];
                    
                    // draw dates on the x axys
                    NSString* date = [self dateFromString: [[self.dictDispPoint objectAtIndex:ind] valueForKey:fzDate]];
                    CGPoint datePoint = CGPointMake(self.curPoint.x-15, topMargin + self.chartHeight + 2);
                    [self drawString:date at:datePoint withFont:systemFont andColor:linesColor];
                    
                    [self endContext];
                    
                    
                }
                
            }];
            
            // gradient's path
            CGMutablePathRef path = CGPathCreateMutable();
            
            CGPoint origin = CGPointMake(self.leftMargin, topMargin+self.chartHeight);
            if (self.dictDispPoint && self.dictDispPoint.count > 0) {
                
                //origin
                CGPathMoveToPoint(path, nil, origin.x, origin.y);
                CGPoint p;
                for (int i = 0; i < self.dictDispPoint.count; i++) {
                    p = [[[self.dictDispPoint objectAtIndex:i] valueForKey:fzPoint] CGPointValue];
                    CGPathAddLineToPoint(path, nil, p.x, p.y);
                }
            }
            CGPathAddLineToPoint(path, nil, self.curPoint.x, topMargin+self.chartHeight);
            CGPathAddLineToPoint(path, nil, origin.x,origin.y);
            
            // gradient
            [self gradientizefromPoint:CGPointMake(0, self.yMax) toPoint:CGPointMake(0, topMargin+self.chartWidth) forPath:path];
            
            CGPathRelease(path);
            
            
            //  X and Y axys
            
            [self setContextWidth:1.0f andColor:linesColor];
            
            //  y
            [self drawLineFrom:CGPointMake(self.leftMargin, topMargin) to:CGPointMake(self.leftMargin, self.chartHeight+topMargin)];
            //  x
            [self drawLineFrom:CGPointMake(self.leftMargin, topMargin+self.chartHeight) to:CGPointMake(self.leftMargin+self.chartWidth, self.chartHeight+topMargin)];
            
            // vertical closure
            CGPoint startLine = CGPointMake(self.leftMargin+self.chartWidth, topMargin);
            CGPoint endLine = CGPointMake(self.leftMargin+self.chartWidth, topMargin+self.chartHeight);
            [self drawLineFrom:startLine to:endLine];
            
            // horizontal closure
            [self drawLineFrom:CGPointMake(self.leftMargin, topMargin) to:CGPointMake(self.chartWidth+self.leftMargin, topMargin)];
            
            
            [self endContext];
            
            
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            
            // popup when moving
            if(isMovement)
            {
                float xGapBetweenTwoPoints = self.chartWidth/[self.dictDispPoint count];
                int pointSlot = currentLoc.x/xGapBetweenTwoPoints;
                
                if(pointSlot >= 0 && pointSlot < [self.dictDispPoint count])
                {
                    NSDictionary *dict = [self.dictDispPoint objectAtIndex:pointSlot];
                    
                    // Calculate Point to draw Circle
                    CGPoint point = CGPointMake([[dict valueForKey:fzPoint] CGPointValue].x,[[dict valueForKey:fzPoint] CGPointValue].y);
                    
                    
                    [self setContextWidth:1.0f andColor:orangeColor];
                    
                    // Line at current Point
                    [self drawLineFrom:CGPointMake(point.x, topMargin-10) to:CGPointMake(point.x, self.chartHeight+topMargin)];
                    [self endContext];
                    
                    // Circle at point
                    [self setContextWidth:1.0f andColor:orangeColor];
                    [self drawCircleAt:point ofRadius:8];
                    
                    [self endContext];
                    
                    
                    // draw the dynamic value
                    
                    float value = [[dict objectForKey:fzValue] floatValue]/100;
                    NSString *price = [self formatNumberAsCurrency:value withFractionDigits:2];
                    
                    CGSize priceSize = [self sizeOfString:price withFont:boldFont];
                    
                    CGRect priceRect = {point.x-priceSize.width/2, 2, priceSize.width + 10, priceSize.height +3};
                    
                    // if goes out on right
                    if(point.x+-priceSize.width/2+priceSize.width+12 > self.chartWidth+self.leftMargin)
                        priceRect.origin.x = self.chartWidth+self.leftMargin-priceSize.width-2;
                    // if goes out on left
                    if(priceRect.origin.x < self.leftMargin)
                        priceRect.origin.x = self.leftMargin-(self.leftMargin/2);
                    
                    // rectangle for the label
                    [self drawRoundedRect:context rect:priceRect radius:5 color:orangeColor];
                    // value string
                    [self drawString:price at:CGPointMake(priceRect.origin.x+(priceRect.size.width-priceSize.width)/2,priceRect.origin.y+1.0f) withFont:boldFont andColor:whiteColor];
                    
                    
                    
                }
            }
        }
        else
        {
            // draw a loding spinner while loading the data
            [self drawLoading];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception debugDescription]);
    }
    @finally {
        
    }
}




#pragma mark - Graphic Utilities

-(void)drawLoading {
    self.loadingSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.loadingSpinner startAnimating];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    self.loadingSpinner.center = CGPointMake(screenWidth/2, self.frame.size.height/2);
    self.loadingSpinner.hidesWhenStopped = YES;
    [self addSubview:self.loadingSpinner];
}

-(void)stopLoading {
    [self.loadingSpinner stopAnimating];
}

-(void)gradientizefromPoint:(CGPoint) startPoint toPoint:(CGPoint) endPoint forPath:(CGMutablePathRef) path{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat colors [] = {
        245.0/255.0, 150.0/255.0, 10.0/255, 0.9, // orange
        255.0/255.0,255.0/255.0,255.0/255.0, 0.0  // white clear
    };
    
   
    
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB(); // gray colors want gray color space
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    
    CGContextSaveGState(context);
    CGContextAddPath(context, path);
    CGContextClip(context);
    
    CGRect boundingBox = CGPathGetBoundingBox(path);
    CGPoint gradientStart = CGPointMake(0, CGRectGetMinY(boundingBox));
    CGPoint gradientEnd   = CGPointMake(0, CGRectGetMaxY(boundingBox));
    
    CGContextDrawLinearGradient(context, gradient, gradientStart, gradientEnd, 0);
    CGGradientRelease(gradient), gradient = NULL;
    CGContextRestoreGState(context);
    
    

   
}

-(void)drawMessage:(NSString*)string {
    
    float stringWidth = [self sizeOfString:string withFont:boldFont].width;
    [self drawString:string at:CGPointMake(self.center.x-stringWidth/2, self.center.y) withFont:boldFont andColor:linesColor];
}


// set the context with a specified widht and color
-(void) setContextWidth:(float)width andColor:(UIColor*)color {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, width);
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
}
// end context
-(void)endContext {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextStrokePath(context);
}
// line between two points
-(void) drawLineFrom:(CGPoint) start to: (CGPoint)end {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context, start.x, start.y);
    CGContextAddLineToPoint(context,end.x,end.y);
    
}
// curve between two points
-(void) drawCurveFrom:(CGPoint)start to:(CGPoint)end {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context, start.x, start.y);
    CGContextAddQuadCurveToPoint(context, start.x, start.y, end.x, end.y);
    CGContextSetLineCap(context, kCGLineCapRound);
}
// draws a string given a point, font and color
-(void) drawString:(NSString*)string at:(CGPoint)point withFont:(UIFont*)font andColor:(UIColor*)color{
    
    NSDictionary *attributes = @{NSFontAttributeName: font, NSForegroundColorAttributeName: color};
    
    [string drawAtPoint:point withAttributes:attributes];
}
// draw a circle given center and radius
-(void) drawCircleAt:(CGPoint)point ofRadius:(int)radius {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect myOval = {point.x-radius/2, point.y-radius/2, radius, radius};
    CGContextAddEllipseInRect(context, myOval);
    CGContextFillPath(context);
}
// rounded corners rectangle
- (void) drawRoundedRect:(CGContextRef)c rect:(CGRect)rect radius:(int)corner_radius color:(UIColor *)color
{
    int x_left = rect.origin.x;
    int x_left_center = rect.origin.x + corner_radius;
    int x_right_center = rect.origin.x + rect.size.width - corner_radius;
    int x_right = rect.origin.x + rect.size.width;
    
    int y_top = rect.origin.y;
    int y_top_center = rect.origin.y + corner_radius;
    int y_bottom_center = rect.origin.y + rect.size.height - corner_radius;
    int y_bottom = rect.origin.y + rect.size.height;
    
    /* Begin! */
    CGContextBeginPath(c);
    CGContextMoveToPoint(c, x_left, y_top_center);
    
    /* First corner */
    CGContextAddArcToPoint(c, x_left, y_top, x_left_center, y_top, corner_radius);
    CGContextAddLineToPoint(c, x_right_center, y_top);
    
    /* Second corner */
    CGContextAddArcToPoint(c, x_right, y_top, x_right, y_top_center, corner_radius);
    CGContextAddLineToPoint(c, x_right, y_bottom_center);
    
    /* Third corner */
    CGContextAddArcToPoint(c, x_right, y_bottom, x_right_center, y_bottom, corner_radius);
    CGContextAddLineToPoint(c, x_left_center, y_bottom);
    
    /* Fourth corner */
    CGContextAddArcToPoint(c, x_left, y_bottom, x_left, y_bottom_center, corner_radius);
    CGContextAddLineToPoint(c, x_left, y_top_center);
    
    /* Done */
    CGContextClosePath(c);
    
    CGContextSetFillColorWithColor(c, color.CGColor);
    
    CGContextFillPath(c);
}
// size of a string given a specific font
-(CGSize) sizeOfString:(NSString *)string withFont:(UIFont *)font {
    NSDictionary *attributes = @{ NSFontAttributeName: font};
    return [string sizeWithAttributes:attributes];
}

#pragma mark - String utilities

// format a string as a date (italian convention)
-(NSString*) dateFromString:(NSString*) string {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:fzDateFormat];
    NSDate *dateFromString = [dateFormatter dateFromString:string];
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    [formatter setLocale:[NSLocale currentLocale]];
    NSString *format = [formatter dateFormat];
    format = [format stringByReplacingOccurrencesOfString:@"/y" withString:@""];
    format = [format stringByReplacingOccurrencesOfString:@"y/" withString:@""];
    format = [format stringByReplacingOccurrencesOfString:@"y" withString:@""];
    
    [formatter setDateFormat:format];
    
    NSString *printDate = [formatter stringFromDate:dateFromString];
    
    return printDate;
}


#pragma mark - Handle Touch Events

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"disableScrolling" object:nil];
    
    UITouch *touch = [touches anyObject];
    currentLoc = [touch locationInView:self];
    currentLoc.x -= self.leftMargin;
    isMovement = YES;
    
    [self setNeedsDisplay];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    currentLoc = [touch locationInView:self];
    currentLoc.x -= self.leftMargin;
    [self setNeedsDisplay];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"enableScrolling" object:nil];
    
    UITouch *touch = [touches anyObject];
    currentLoc = [touch locationInView:self];
    currentLoc.x -= self.leftMargin;
    
    isMovement = NO;
    [self setNeedsDisplay];
}


-(NSString*)formatNumberAsCurrency:(float)number withFractionDigits: (int)digits {
    
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
    [currencyFormatter setCurrencyCode:@"EUR"];
    [currencyFormatter setLocale: [[NSLocale alloc] initWithLocaleIdentifier:@"EUR"]];
    [currencyFormatter setMaximumFractionDigits:digits];
    [currencyFormatter setMinimumFractionDigits:digits];
    //[currencyFormatter setAlwaysShowsDecimalSeparator:YES];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSString *numberAsString = [currencyFormatter stringFromNumber:[NSNumber numberWithFloat:number]];
    
    return numberAsString;
}


@end