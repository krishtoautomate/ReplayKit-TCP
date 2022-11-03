//
//  replaykit2UITests.m
//  replaykit2UITests
//
//  Created by farhanahmed on 24/08/2022.
//

#import <XCTest/XCTest.h>
@import ObjectiveC.runtime;
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
    XCUIApplication *app = [[XCUIApplication alloc] initWithBundleIdentifier: @"com.rdp.-replaykit2.replaykit2"];

    [app launch];
    
    CGSize size = [[[app windows] elementBoundByIndex:0] frame].size;
    
    //[app waitForState:XCUIApplicationStateRunningForeground timeout: 0.5];
    
    [[[app coordinateWithNormalizedOffset:CGVectorMake(0, 0)] coordinateWithOffset:CGVectorMake(size.width/2, (size.height * 0.60))] tap];

    [[[app coordinateWithNormalizedOffset:CGVectorMake(0, 0)] coordinateWithOffset:CGVectorMake(size.width/2, 100)] tap];
    
    [app terminate];

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
