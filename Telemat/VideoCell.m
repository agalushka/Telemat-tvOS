//
//  VideoCell.m
//  Telemat
//
//  Created by Oliver Michalak on 03.01.16.
//  Copyright © 2016 Oliver Michalak. All rights reserved.
//

#import "VideoCell.h"
#import "PlayerView.h"
#import <AVKit/AVKit.h>

@interface VideoCell ()
@property (weak, nonatomic) IBOutlet PlayerView *playerView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic) AVPlayer *player;
@end

@implementation VideoCell

+ (NSString*) identifier {
	return NSStringFromClass(self.class);
}

- (void) awakeFromNib {
	[super awakeFromNib];

	self.player = [[AVPlayer alloc] init];
	AVPlayerLayer *layer = (AVPlayerLayer*)self.playerView.layer;
	layer.player = self.player;

	self.titleLabel.layer.shadowColor = [UIColor blackColor].CGColor;
	self.titleLabel.layer.shadowOffset = CGSizeMake(0, 1);
	self.titleLabel.layer.shadowRadius = 5;
	self.titleLabel.layer.shadowOpacity = 1;
}


- (void) setChannel:(Channel *)channel {
	_channel = channel;

	self.playerView.hidden = YES;
	self.titleLabel.text = channel.title;
	self.titleLabel.hidden = !self.focused;
	self.imageView.image = channel.image;
}

- (void)didUpdateFocusInContext:(UIFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator {
	[coordinator addCoordinatedAnimations:^{
		self.titleLabel.hidden = !self.focused;
		self.imageView.transform = self.focused ?	CGAffineTransformMakeScale(1.2, 1.2) : CGAffineTransformIdentity;
	} completion:nil];
	if (self.focused) {
		if (self.playerView.hidden) {
			[self.player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:self.channel.streamURL]];
			[self.player seekToTime:CMTimeMakeWithSeconds(0, 1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
			//		self.player.muted = YES;
			[self.player play];
			self.playerView.hidden = NO;
		}
	}
	else {
		if (!self.playerView.hidden) {
			[self.player pause];
			self.playerView.hidden = YES;
		}
	}
}

@end
