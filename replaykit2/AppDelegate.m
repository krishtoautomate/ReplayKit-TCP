//
//  AppDelegate.m
//  replaykit2
//
//  Created by farhanahmed on 24/08/2022.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[[UIApplication sharedApplication] windows] firstObject].layer.speed = 2;
    [UIView setAnimationsEnabled:false];
    // Override point for customization after application launch.
//    UIWindow * window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
//    self.window = window;
//    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    UIViewController* viewController = [storyBoard instantiateInitialViewController];
//    self.window.rootViewController = viewController;
//    [self.window makeKeyAndVisible];
    return YES;
}


#pragma mark - UISceneSession lifecycle


//- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
//    // Called when a new scene session is being created.
//    // Use this method to select a configuration to create the new scene with.
//    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
//}
//
//
//- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
//    // Called when the user discards a scene session.
//    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//}


@end
