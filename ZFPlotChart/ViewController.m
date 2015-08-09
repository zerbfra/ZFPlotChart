//
//  ViewController.m
//  ZFPlotChart
//
//  Created by Francesco Zerbinati on 21/06/15.
//  Copyright (c) 2015 Francesco Zerbinati. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /********** Creating an area for the graph ***********/
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    CGRect frame = CGRectMake(0, 100, screenWidth, 190);
    
    // initialization
    self.plotChart = [[ZFPlotChart alloc] initWithFrame:frame];
    [self.view addSubview:self.plotChart];
    
    
    // get the data from the json file
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
    // string creation
    NSString *jsonString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    // json parsing
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];

    if (!json) {
        NSLog(@"Error parsing JSON");
    } else {
        NSLog(@"%@",json);
    }
    
    // values are contained inside "values" in the JSON file
    NSArray *values = [json valueForKeyPath:@"values"];
    // create the nsorderedset from the array
    NSOrderedSet *result = [NSOrderedSet orderedSetWithArray:values];
    
    self.plotChart.alpha = 0;
    // draw data
    [self.plotChart createChartWith:result];
    [UIView animateWithDuration:0.5 animations:^{
        self.plotChart.alpha = 1.0;
    }];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
