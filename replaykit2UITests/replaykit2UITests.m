//
//  replaykit2UITests.m
//  replaykit2UITests
//
//  Created by farhanahmed on 24/08/2022.
//

#import <XCTest/XCTest.h>
@import ObjectiveC.runtime;
#import <sys/utsname.h>
NSString* deviceName()
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}
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


- (void)testExample {
    
    [self automateReplayKit];
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

- (XCUIElement*) findButton: (NSString*) label withSB: (XCUIApplication*) sbApp and:(XCUIApplication*) mainApp {
    
    XCUIElement *ele = [[sbApp buttons] objectForKeyedSubscript: label];
    
    if ( [ele waitForExistenceWithTimeout: 2]) {
        return  ele;
    }
    
    ele = [[mainApp buttons] objectForKeyedSubscript: label];
    
    if ( [ele waitForExistenceWithTimeout: 2]) {
        return  ele;
    }
    
    return nil;
    
}

-(void) automateReplayKit {
    [self disableWaitForIdle];
    // UI tests must launch the application that they test.
    XCUIApplication *sb = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.springboard"];
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    
    [app launch];
    
    CGSize size = [[[app windows] elementBoundByIndex:0] frame].size;
    
    XCUIElement *startBroadCastButton = [self findButton: @"Start Broadcast" withSB:sb and:app];
    
    if ([startBroadCastButton exists]) {
        [startBroadCastButton tap];
    } else {
        [app activate];
        XCUIElement *alert = [[sb alerts] objectForKeyedSubscript: @"Screen Broadcasting"];
        if ([alert waitForExistenceWithTimeout:5]) {
            XCUIElement *okButton = [[alert buttons] elementBoundByIndex: 0];
            if ([okButton exists]) {
                [okButton tap];
                
                //sleep(1);
                
                XCUIElement *replayKitPopup =  [[app buttons] elementBoundByIndex:0];
                
                if ([replayKitPopup waitForExistenceWithTimeout:2]) {
                    [replayKitPopup tap];
                    startBroadCastButton = [self findButton: @"Start Broadcast" withSB:sb and:app];
                    
                    if ([startBroadCastButton exists]) {
                        [startBroadCastButton tap];
                    }
                }
            }
        }
    }
    
    sleep(5);
    
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


@end
