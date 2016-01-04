//
//  VideoPlayerViewController.m
//  Telemat
//
//  Created by Oliver Michalak on 04.01.16.
//  Copyright © 2016 Oliver Michalak. All rights reserved.
//

#import "VideoPlayerViewController.h"

@interface VideoPlayerViewController ()

@end

@implementation VideoPlayerViewController

+ (instancetype) videoPlayerWithURL:(NSURL*)url {
	VideoPlayerViewController *videoPlayerViewController = [[VideoPlayerViewController alloc] init];
	videoPlayerViewController.url = url;
	return videoPlayerViewController;
}

- (void)play {
	AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:self.url];
	self.player = [AVPlayer playerWithPlayerItem:playerItem];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
	UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
	[viewController presentViewController:self animated:YES completion:^{
		[self.player play];
	}];
}

- (void)itemDidFinishPlaying:(NSNotification *) notification {
	[self.player pause];
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
