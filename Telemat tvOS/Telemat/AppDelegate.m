//
//  AppDelegate.m
//  Telemat
//
//  Created by Oliver Michalak on 03.01.16.
//  Copyright © 2016 Oliver Michalak. All rights reserved.
//

#import "AppDelegate.h"
#import "VideoPlayerViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	if (launchOptions[UIApplicationLaunchOptionsURLKey]) {
		[self openURL:launchOptions[UIApplicationLaunchOptionsURLKey]];
	}
	return YES;
}

- (BOOL) application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
	[self openURL:url];
	return YES;
}

- (void) openURL:(NSURL*) url {
	NSURLComponents *comp = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
	NSURLQueryItem *queryItem = comp.queryItems.firstObject;
	if (queryItem.value.length) {
		VideoPlayerViewController *videoPlayer = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"VideoPlayerViewController"];
		videoPlayer.index = [queryItem.value integerValue];
		[self.window.rootViewController presentViewController:videoPlayer animated:YES completion:nil];
	}
}

@end
