//
//  ZFPlotChart.h
//
//  Created by Zerbinati Francesco
//  Copyright (c) 2014-2015
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

//#import "CPItem.h"

@interface ZFPlotChart : UIView
{
    NSMutableOrderedSet *dictDispPoint;
    float chartWidth, chartHeight;
    CGPoint prevPoint, curPoint;
    float min, max;
    BOOL isMovement;    // Default NO
    CGPoint currentLoc;
}

@property (nonatomic, retain) NSMutableOrderedSet *dictDispPoint;

@property (nonatomic, readwrite) float chartWidth, chartHeight;
@property (nonatomic, readwrite) CGFloat leftMargin;

@property (nonatomic, readwrite) CGPoint prevPoint, curPoint, currentLoc;
@property (nonatomic, readwrite) float min, max;

@property (nonatomic, readwrite) float yMax,yMin;

@property (strong) UIActivityIndicatorView *loadingSpinner;

- (void)createChartWith:(NSOrderedSet *)data;

@end
