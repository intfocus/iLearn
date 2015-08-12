//
//  AppDelegate.m
//  iLearn
//
//  Created by Charlie Hung on 2015/5/13.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import "AppDelegate.h"
#import "Constants.h"
#import "LoginViewController.h"
#import <PgySDK/PgyManager.h>
#import "Version.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

void UncaughtExceptionHandler(NSException * exception) {
    NSArray *arr     = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name   = [exception name];
    Version *version = [[Version alloc] init];
    NSString *mailContent = [NSString stringWithFormat:@"mailto:jay_li@intfocus.com \
                             ?subject=%@客户端bug报告                                 \
                             &body=很抱歉%@应用出现故障,感谢您的配合!发送这封邮件可协助我们改善此应用<br><br> \
                             应用详情:<br>                                            \
                             %@<br>                                                  \
                             错误详情:<br>                                            \
                             %@<br>                                                  \
                             --------------------------<br>                          \
                             %@<br>                                                  \
                             --------------------------<br>                          \
                             %@",
                             version.appName, version.appName,
                             [version simpleDescription],
                             name,reason,[arr componentsJoinedByString:@"<br>"]];
    
    NSURL *url = [NSURL URLWithString:[mailContent stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[UIApplication sharedApplication] openURL:url];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    @try {
        [[PgyManager sharedPgyManager] setEnableFeedback:NO];
        [[PgyManager sharedPgyManager] startManagerWithAppId:[Version pgy_app_id]];
        NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
    }
    @catch (NSException *exception) {
        NSLog(@"NSSetUncaughtExceptionHandler - %@", exception.name);
    } @finally {}
    
    LoginViewController *loginViewController = [[LoginViewController alloc] init];
    [self.window setRootViewController:loginViewController];

//    [[UINavigationBar appearance] setBarTintColor:RGBCOLOR(220.0, 220.0, 220.0)];
//    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
//    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName: [UIFont boldSystemFontOfSize:22.0]}];
//    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName: [UIFont boldSystemFontOfSize:22.0]}];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    return UIInterfaceOrientationMaskAll;
}

@end
