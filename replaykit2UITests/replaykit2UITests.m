//
//  replaykit2UITests.m
//  replaykit2UITests
//
//  Created by farhanahmed on 24/08/2022.
//

#import <XCTest/XCTest.h>
@import ObjectiveC.runtime;
#import <sys/utsname.h>

@interface replaykit2UITests : XCTestCase

@end

@implementation replaykit2UITests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testOrientationLeft {
    [[XCUIDevice sharedDevice] setOrientation: UIDeviceOrientationLandscapeLeft];
}

- (void)testOrientationRight {
    [[XCUIDevice sharedDevice] setOrientation: UIDeviceOrientationLandscapeRight];
}

- (void)testOrientationUp {
    [[XCUIDevice sharedDevice] setOrientation: UIDeviceOrientationPortrait];
}

- (void)testOrientationDown {
    [[XCUIDevice sharedDevice] setOrientation: UIDeviceOrientationPortraitUpsideDown];
}
// 1 - testListenForAlertsOnce
// 2 - testExample
// 3 - testListenForAlerts (run in background)
-(void)testListenForAlerts {
    
    while (true) {
        if ([self listenForAlertsOnce]) {
            continue;
        }
        sleep(2);
    }
}
-(void)testListenForAlertsOnce {
    [self listenForAlertsOnce];
}

- (void)testExample {
    
    [self disableWaitForIdle];
    // UI tests must launch the application that they test.
    XCUIApplication *sb = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.springboard"];
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    
    [app launch];
    
    CGSize size = [[[app windows] elementBoundByIndex:0] frame].size;
    
    NSString * startbuttonLabel = @"Start Broadcast";
    NSString * stopbuttonLabel = @"Stop Broadcast";
    
    XCUIElement *startBroadCastButton = [self findButton: startbuttonLabel inApps: @[sb, app]];

    if ([startBroadCastButton exists]) {
        [startBroadCastButton tap];
    } else {
        [app activate];
        XCUIElement *alert = [[sb alerts] objectForKeyedSubscript: @"Screen Broadcasting"];
        if ([alert waitForExistenceWithTimeout:5]) {
            XCUIElement *okButton = [[alert buttons] elementBoundByIndex: 0];
            if ([okButton exists] && [okButton waitForExistenceWithTimeout:5]) {
                [okButton tap];
                
                XCUIElement *replayKitPopup =  [[app buttons] elementBoundByIndex:0];
                
                if ([replayKitPopup waitForExistenceWithTimeout:2]) {
                    [replayKitPopup tap];
                    startBroadCastButton = [self findButton: startbuttonLabel inApps: @[sb, app]];
                    
                    if ([startBroadCastButton exists]) {
                        [startBroadCastButton tap];
                    }
                }
            }
        }
    }
    
    XCUIElement *stopBroadCastButton = [self findButton: stopbuttonLabel inApps: @[sb, app]];
    
    BOOL _ = [stopBroadCastButton waitForExistenceWithTimeout: 5];
    
    [[[app coordinateWithNormalizedOffset:CGVectorMake(0, 0)] coordinateWithOffset:CGVectorMake(size.width/2, 100)] tap];
    
    [app terminate];
}



-(void) setOrientation: (NSString*) orientationStr {
    
    int orientation = [orientationStr intValue];
    
    switch(orientation) {
        case kCGImagePropertyOrientationLeft:
            [[XCUIDevice sharedDevice] setOrientation: UIDeviceOrientationLandscapeLeft];
            break;
            
        case kCGImagePropertyOrientationRight:
            [[XCUIDevice sharedDevice] setOrientation: UIDeviceOrientationLandscapeRight];
            break;
            
        case kCGImagePropertyOrientationUp:
            [[XCUIDevice sharedDevice] setOrientation: UIDeviceOrientationPortrait];
            break;
            
        case kCGImagePropertyOrientationDown:
            [[XCUIDevice sharedDevice] setOrientation: UIDeviceOrientationPortraitUpsideDown];
            break;
    }
}

-(BOOL)listenForAlertsOnce {
    XCUIApplication *sb = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.springboard"];
    int timeout = 2;
    NSArray<NSString*> *buttonList = @[@"Ok", @"Allow", @"Allow While Using App", @"Only While Using the App", @"Allow While in Use"];
    
    if ([sb alerts] != nil && [sb alerts].count > 0) {
        XCUIElement *alert = [[sb alerts] elementBoundByIndex:0];
        
        if (alert && [alert buttons].count > 0) {
            NSLog(@"Alert Found: %@", alert.label);
            for (NSString * label in buttonList) {
                XCUIElement *button = [alert.buttons objectForKeyedSubscript: label];
                
                if ([button waitForExistenceWithTimeout: timeout]) {
                    [button tap];
                    return TRUE;;
                }
            }
        }
    }
    
    return FALSE;
}


-(void) replace {
    return;
}
- (void)disableWaitForIdle {
    
    SEL originalSelector = NSSelectorFromString(@"waitForQuiescenceIncludingAnimationsIdle:");
    SEL swizzledSelector = @selector(replace);
    
    Method originalMethod = class_getInstanceMethod(objc_getClass("XCUIApplicationProcess"), originalSelector);
    Method swizzledMethod = class_getInstanceMethod([self class], swizzledSelector);
    
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

- (XCUIElement*) findButton: (NSString*) label inApps: (NSArray<XCUIApplication*>*) apps {
    
    for (XCUIApplication * app in apps) {
        XCUIElement *ele = [[app buttons] objectForKeyedSubscript: label];
        if ( [ele waitForExistenceWithTimeout: 2]) {
            return  ele;
        }
    }
    
    return nil;
}


@end
