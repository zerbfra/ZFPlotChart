//
//  ZFPlotChart.h
//
//  Created by Zerbinati Francesco
//  Copyright (c) 2014-2015
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define COLOR_WITH_RGB(r,g,b)   [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f] // Macro for colors

// Dimension costants
#define topMargin               20.0f   // top margin
#define vMargin                 40.0f   // vertical margin
#define hMargin                 10.0f   // horizontal margin
#define leftSpace               10.0f   // left space

// Graph grid color
#define linesColor              [UIColor lightGrayColor]

// Colors for lines and background
#define orangeColor             COLOR_WITH_RGB(255, 150, 10)
#define whiteColor              [UIColor whiteColor]

// Fonts
#define systemFont              [UIFont systemFontOfSize:10]
#define boldFont                [UIFont boldSystemFontOfSize:10]

// definitions (as JSON)
#define fzPoint                  @"Point"
#define fzValue                  @"value"
#define fzDate                   @"time"
#define fzDateFormat             @"yyyyMMdd"

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
