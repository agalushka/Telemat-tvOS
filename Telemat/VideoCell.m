//
//  VideoCell.m
//  Telemat
//
//  Created by Oliver Michalak on 03.01.16.
//  Copyright © 2016 Oliver Michalak. All rights reserved.
//

#import "VideoCell.h"

@interface VideoCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end

@implementation VideoCell

+ (NSString*) identifier {
	return NSStringFromClass(self.class);
}

- (void) awakeFromNib {
	[super awakeFromNib];

	self.titleLabel.layer.shadowColor = [UIColor blackColor].CGColor;
	self.titleLabel.layer.shadowOffset = CGSizeMake(0, 1);
	self.titleLabel.layer.shadowRadius = 5;
	self.titleLabel.layer.shadowOpacity = 1;
}

- (void) setInfo:(NSDictionary *)info {
	_info = info;
	
	self.titleLabel.text = info[@"SenderName"];
	self.titleLabel.hidden = !self.focused;
	NSString *imageName = info[@"Bild"];
	if ([imageName hasPrefix:@"file:"])
		self.imageView.image = [UIImage imageNamed:[imageName substringFromIndex:5]];
	else
		self.imageView.image = nil;
}

- (NSURL*) streamURL {
	return [NSURL URLWithString:self.info[@"StreamURL"]];
}

- (void)didUpdateFocusInContext:(UIFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator {
	[coordinator addCoordinatedAnimations:^{
		self.titleLabel.hidden = !self.focused;
		self.imageView.transform = self.focused ?	CGAffineTransformMakeScale(1.2, 1.2) : CGAffineTransformIdentity;
	} completion:nil];
}

@end
