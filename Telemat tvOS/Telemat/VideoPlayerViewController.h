//
//  VideoPlayerViewController.h
//  Telemat
//
//  Created by Oliver Michalak on 04.01.16.
//  Copyright © 2016 Oliver Michalak. All rights reserved.
//

#import <AVKit/AVKit.h>

@interface VideoPlayerViewController : AVPlayerViewController

@property (nonatomic) NSURL *url;

+ (instancetype) videoPlayerWithURL:(NSURL*)url;

- (void) play;

@end
