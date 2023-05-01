//
//  ViewController.m
//  replaykit2
//
//  Created by farhanahmed on 24/08/2022.
//

#import "ViewController.h"
@import ReplayKit;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    RPSystemBroadcastPickerView* pickerView = [[RPSystemBroadcastPickerView alloc] initWithFrame: self.view.frame];
    [pickerView setShowsMicrophoneButton:false];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *extension = [NSString stringWithFormat: @"%@%@", bundleIdentifier, @".extension"];
    [pickerView setPreferredExtension:  extension];
    
    for(UIView * view in [pickerView subviews])
    {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton*)view;
            [button sendActionsForControlEvents:UIControlEventAllTouchEvents];
        }
    }
    [self.view addSubview:pickerView];
    
    
}


@end
