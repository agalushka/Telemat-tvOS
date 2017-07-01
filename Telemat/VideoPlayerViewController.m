//
//  VideoPlayerViewController.m
//  Telemat
//
//  Created by Oliver Michalak on 04.01.16.
//  Copyright © 2016 Oliver Michalak. All rights reserved.
//

#import "VideoPlayerViewController.h"
#import "VideoCell.h"
#import <AVKit/AVKit.h>
#import "PlayerView.h"

#define kAnimationTimer (1)
#define kNameHeight (100)
#define kMenuHeight (240)

@interface VideoPlayerViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet PlayerView *playerView;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *nameContainer;
@property (weak, nonatomic) IBOutlet UILabel *nameView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *menuContainer;
@property (weak, nonatomic) IBOutlet UICollectionView *listView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *listBottomConstraint;
@property (nonatomic) AVPlayer *player;
@property (nonatomic) NSArray *list;
@property (weak, nonatomic) VideoCell *previousCell;
@property (nonatomic) NSTimer *hideTimer;
@end

@implementation VideoPlayerViewController

- (void) viewDidLoad {
	[super viewDidLoad];

	self.list = [self parseChannels];

	self.nameTopConstraint.constant = kNameHeight;
	self.nameContainer.hidden = YES;
	self.listBottomConstraint.constant = -kMenuHeight;
	self.menuContainer.hidden = YES;
	[self.listView reloadData];

	self.player = [[AVPlayer alloc] init];
	AVPlayerLayer *layer = (AVPlayerLayer*)self.playerView.layer;
	layer.player = self.player;

	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
	tapGesture.allowedPressTypes = @[@(UIPressTypePlayPause), @(UIPressTypeSelect)];
	[self.view addGestureRecognizer:tapGesture];

	UISwipeGestureRecognizer *swipeUpGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
	swipeUpGesture.direction = UISwipeGestureRecognizerDirectionUp;
	[self.view addGestureRecognizer:swipeUpGesture];
	UISwipeGestureRecognizer *swipeDownGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
	swipeDownGesture.direction = UISwipeGestureRecognizerDirectionDown;
	[self.view addGestureRecognizer:swipeDownGesture];

}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	NSUInteger index = [[NSUserDefaults standardUserDefaults] integerForKey:@"lastChannel"];
	[self playChannel:index];
	[self.listView selectItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
}

- (void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	[self.player pause];
}

- (NSArray*) parseChannels {
	NSMutableArray *result = [@[] mutableCopy];
	NSData *data = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"channel" withExtension:@"json"]];
	NSArray *list = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
	for (NSDictionary *dict in list)
		[result addObject:[[Channel alloc] initFromDictionary:dict]];
	return [result copy];
}

- (void) playChannel:(NSInteger) index {
	Channel *channel = self.list[index];
	[self.player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:channel.streamURL]];
	[self.player seekToTime:CMTimeMakeWithSeconds(0, 1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
	[self.player play];

	self.nameView.text = @"";
//	[channel requestCurrentName:^(NSString *name) {
//		self.nameView.text = name;
//	}];

	[[NSUserDefaults standardUserDefaults] setInteger:index forKey:@"lastChannel"];
	[self startHideTimer];
}

- (UIView*) preferredFocusedView {
	if (self.menuContainer.hidden)
		return self.view;
	if (self.previousCell)
		return self.previousCell;
	return self.listView;
}

- (void) tap:(UITapGestureRecognizer*)gesture {
	if (self.menuContainer.hidden) {
		if (gesture.state == UIGestureRecognizerStateEnded) {
			if (self.player.rate > 0)
				[self.player pause];
			else
				[self.player play];
		}
	}
	else if (self.previousCell) {
		[self hideMenu];
		NSIndexPath *indexPath = [self.listView indexPathForCell:self.previousCell];
		[self playChannel:indexPath.row];
	}
}

- (void) swipe:(UISwipeGestureRecognizer*)gesture {
	if (gesture.direction == UISwipeGestureRecognizerDirectionUp) {
		if (!self.nameContainer.hidden)
			[self hideName];
		else
			[self showMenu];
	}
	else if (gesture.direction == UISwipeGestureRecognizerDirectionDown) {
		if (!self.menuContainer.hidden)
			[self hideMenu];
		else
			[self showName];
	}
}

- (void) showName {
	if (self.nameContainer.hidden) {
		self.nameContainer.hidden = NO;
		[self.nameContainer layoutIfNeeded];
		[UIView animateWithDuration:kAnimationTimer delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
			self.nameTopConstraint.constant = 0;
			[self.menuContainer layoutIfNeeded];
		} completion:^(BOOL finished) {
			[self startHideTimer];
		}];
	}
}

- (void) hideName {
	[self.hideTimer invalidate];
	self.hideTimer = nil;
	if (!self.nameContainer.hidden) {
		[self.nameContainer layoutIfNeeded];
		[UIView animateWithDuration:kAnimationTimer delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
			self.nameTopConstraint.constant = kNameHeight;
			[self.nameContainer layoutIfNeeded];
		} completion:^(BOOL finished) {
			self.nameContainer.hidden = YES;
			[self setNeedsFocusUpdate];
		}];
	}
}

- (void) showMenu {
	if (self.menuContainer.hidden) {
		[self.player pause];
		self.menuContainer.hidden = NO;
		[self.menuContainer layoutIfNeeded];
		[UIView animateWithDuration:kAnimationTimer delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
			self.listBottomConstraint.constant = 0;
			[self.menuContainer layoutIfNeeded];
		} completion:^(BOOL finished) {
			[self setNeedsFocusUpdate];
			[self startHideTimer];
		}];
	}
}

- (void) hideMenu {
	[self.hideTimer invalidate];
	self.hideTimer = nil;
	if (!self.menuContainer.hidden) {
		[self.player play];
		[self.menuContainer layoutIfNeeded];
		[UIView animateWithDuration:kAnimationTimer delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
			self.listBottomConstraint.constant = -kMenuHeight;
			[self.menuContainer layoutIfNeeded];
		} completion:^(BOOL finished) {
			self.menuContainer.hidden = YES;
			[self setNeedsFocusUpdate];
		}];
	}
}

- (void) startHideTimer {
	[self.hideTimer invalidate];
	self.hideTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(hide) userInfo:nil repeats:NO];
}

- (void) hide {
	[self hideName];
	[self hideMenu];
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return self.list.count;
}

- (UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	VideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:VideoCell.identifier forIndexPath:indexPath];
	cell.channel = self.list[indexPath.row];
	if (!self.previousCell && indexPath.row == [[NSUserDefaults standardUserDefaults] integerForKey:@"lastChannel"]) {
		self.previousCell = cell;
		[self setNeedsFocusUpdate];
	}
	return cell;
}

- (void)didUpdateFocusInContext:(UIFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator {
	if ([context.nextFocusedView isKindOfClass:VideoCell.class])
		self.previousCell = (VideoCell*)context.nextFocusedView;
	[self startHideTimer];
}

@end
