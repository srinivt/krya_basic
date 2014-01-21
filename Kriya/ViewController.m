//
//  ViewController.m
//  Kriya
//
//  Created by Srinivasan Thirunarayanan on 1/20/14.
//  Copyright (c) 2014 Srinivasan Thirunarayanan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

typedef enum {
    Started, Stopped, Reset
} TimerState;

@property (weak, nonatomic) IBOutlet UIButton *startRestButton;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property TimerState timerState;

@property (strong, atomic) NSMutableArray *timeIntervals;

@property (strong, atomic) NSDate *lastTouchDate;

@property (weak, nonatomic) IBOutlet UILabel *currentTimeInterval;

@end

@implementation ViewController

- (IBAction)doStartOrReset:(id)sender {
    if (self.timerState == Reset) {
        self.timerState = Started;
        [self.startRestButton setTitle:@"Stop" forState:UIControlStateNormal];
        self.lastTouchDate = [[NSDate alloc]init];
        
        [self updateTimerLabel];
     } else if (self.timerState == Started) {
         self.timerState = Stopped;
         [self stop];
     } else if (self.timerState == Stopped) {
         [self reset];
     }
}

-(void) stop {
    self.timerState = Stopped;
    
    [self recordTimeInteral];
    
    [self.startRestButton setTitle:@"Reset" forState:UIControlStateNormal];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

-(void) reset {
    self.timerState = Reset;
    [self.startRestButton setTitle:@"Start" forState:UIControlStateNormal];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [self setTimeLabel:0:0];

    [[self timeIntervals] removeAllObjects];
    [self.tableView reloadData];
}

- (IBAction)doDone:(id)sender {
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Number of rows is the number of time zones in the region for the specified section.
    return self.timeIntervals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"MyReuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:MyIdentifier];
    }
    int stepNum = indexPath.row;
    NSString *rowLabel = [NSString stringWithFormat:@"%d: %d", stepNum + 1, [self.timeIntervals[stepNum] integerValue]];
    cell.textLabel.text = rowLabel;
    return cell;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.timerState != Started) {
        return;
    }
    [self recordTimeInteral];
}

- (void) recordTimeInteral {
    NSDate *now = [[NSDate alloc]init];
    NSNumber *timeInterval = [NSNumber numberWithDouble:[now timeIntervalSinceDate:self.lastTouchDate]];
    self.lastTouchDate = now;
    
    [self.timeIntervals addObject:timeInterval];
    [self.tableView reloadData];
}

- (void) updateTimerLabel {
    NSDate *now = [[NSDate alloc]init];
    NSTimeInterval timeInterval = [now timeIntervalSinceDate:self.lastTouchDate];
    
    int minutes = timeInterval / 60;
    int seconds = ((int) timeInterval) % 60;
    
    [self setTimeLabel:minutes :seconds];
    [self performSelector:@selector(updateTimerLabel) withObject:self afterDelay:1.0];
}

- (void) setTimeLabel:(int) minutes :(int) seconds {
    self.currentTimeInterval.text = [NSString stringWithFormat:@"%d:%d", minutes, seconds];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.timerState = Reset;
    self.timeIntervals = [[NSMutableArray alloc]init];
    [self setTimeLabel:0:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
