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
    XCUIApplication *sb = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.springboard"];
    
//    XCUIElement *cancel = [[sb alerts] elementBoundByIndex:0];
//
//    if ([cancel exists]) {
//        [[[cancel buttons] elementBoundByIndex:0] tap];
//    }

    XCUIApplication *app = [[XCUIApplication alloc] init];
    
    [app launch];
    
    
//    sleep(5);
    
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

    //Tap on Start Button
//[[[app coordinateWithNormalizedOffset:CGVectorMake(0, 0)] coordinateWithOffset:CGVectorMake(x, y)] tap];
    
//    sleep(5);
    //Dismiss Model
    [[[app coordinateWithNormalizedOffset:CGVectorMake(0, 0)] coordinateWithOffset:CGVectorMake(size.width/2, 100)] tap];
    
//    sleep(1);
    
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

@end
