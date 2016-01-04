//
//  VideoCell.m
//  Telemat
//
//  Created by Oliver Michalak on 03.01.16.
//  Copyright © 2016 Oliver Michalak. All rights reserved.
//

#import "VideoCell.h"

@implementation VideoCell

+ (NSString*) identifier {
	return NSStringFromClass(self.class);
}

- (void) awakeFromNib {
	[super awakeFromNib];
	self.title.layer.shadowOffset = CGSizeMake(0, 0);
	self.title.layer.shadowRadius = 3;
	self.title.layer.shadowOpacity = 0.5;
	self.title.layer.shadowColor = [UIColor whiteColor].CGColor;
}

- (void)didUpdateFocusInContext:(UIFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator {
	[coordinator addCoordinatedAnimations:^{
		self.title.textColor = self.focused ? [UIColor orangeColor] : [UIColor darkGrayColor];
		self.title.layer.shadowColor = self.focused ? [UIColor darkGrayColor].CGColor : [UIColor whiteColor].CGColor;
		self.title.transform = self.focused ?	CGAffineTransformMakeScale(1.2, 1.2) : CGAffineTransformIdentity;
	} completion:nil];
}

@end
