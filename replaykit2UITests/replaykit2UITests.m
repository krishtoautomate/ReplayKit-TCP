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

- (void)testExample {
    [self disableWaitForIdle];
    // UI tests must launch the application that they test.
    XCUIApplication *app = [[XCUIApplication alloc] init];

    [app launch];
    
//    sleep(5);
    
    CGSize size = [[[app windows] elementBoundByIndex:0] frame].size;
    
    NSString * model = deviceName();
    float x = 0;
    float y = 0;
    
    
//    if([model isEqualToString: @"iPhoneX,8"]) {
//        x = size.width/2;
//        y = 546;
//    } else {
//        // works iphone se, X, XS, iphone 7,8,SE 2nd and 3rd Gen, iphone xr, 14.
//        x = size.width/2;
//        y = size.height * 0.60;
//    }
    
    NSLog(@"Model=%@ X= %f, Y= %f",model, x, y);
    //[app waitForState:XCUIApplicationStateRunningForeground timeout: 0.5];
    
    XCUIApplication *sb = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.springboard"];
            
    XCUIElement *ele = [[sb buttons] elementBoundByIndex:0];
    
    if(![ele exists]) {
        ele = [[app staticTexts] objectForKeyedSubscript: @"Start Broadcast"];
    }
    //sleep(1);
    
    [ele tap];
    
    sleep(5);

    //Tap on Start Button
//[[[app coordinateWithNormalizedOffset:CGVectorMake(0, 0)] coordinateWithOffset:CGVectorMake(x, y)] tap];
    
    //sleep(5);
    //Dismiss Model
    [[[app coordinateWithNormalizedOffset:CGVectorMake(0, 0)] coordinateWithOffset:CGVectorMake(size.width/2, 100)] tap];
    
//    sleep(1);
    
//    [app terminate];

    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
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

@end
