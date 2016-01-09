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
#define kRowHeight (240)

@interface VideoPlayerViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet PlayerView *playerView;
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

	NSData *data = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"channel" withExtension:@"json"]];
	self.list = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
	self.listBottomConstraint.constant = -kRowHeight;
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

- (void) playChannel:(NSInteger) index {
	NSDictionary *info = self.list[index];
	[self.player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:[NSURL URLWithString:info[@"StreamURL"]]]];
	[self.player seekToTime:CMTimeMakeWithSeconds(0, 1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
	[self.player play];

	[[NSUserDefaults standardUserDefaults] setInteger:index forKey:@"lastChannel"];
	[self startHideTimer];
}

- (UIView*) preferredFocusedView {
	if (self.listView.hidden)
		return self.view;
	if (self.previousCell)
		return self.previousCell;
	return self.listView;
}

- (void) tap:(UITapGestureRecognizer*)gesture {
	if (self.listView.hidden) {
		if (gesture.state == UIGestureRecognizerStateEnded) {
			if (self.player.rate > 0)
				[self.player pause];
			else
				[self.player play];
		}
	}
	else if (self.previousCell) {
		NSIndexPath *indexPath = [self.listView indexPathForCell:self.previousCell];
		[self playChannel:indexPath.row];
	}
}

- (void) swipe:(UISwipeGestureRecognizer*)gesture {
	if (gesture.direction == UISwipeGestureRecognizerDirectionUp)
		[self showMenu];
	else if (gesture.direction == UISwipeGestureRecognizerDirectionDown)
		[self hideMenu];
}

- (void) showMenu {
	if (self.listView.hidden) {
		self.listView.hidden = NO;
		[self.listView layoutIfNeeded];
		[UIView animateWithDuration:kAnimationTimer delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
			self.listBottomConstraint.constant = 0;
			((UICollectionViewFlowLayout*)self.listView.collectionViewLayout).scrollDirection = UICollectionViewScrollDirectionHorizontal;
			[self.listView layoutIfNeeded];
		} completion:^(BOOL finished) {
			[self setNeedsFocusUpdate];
			[self startHideTimer];
		}];
	}
}

- (void) hideMenu {
	[self.hideTimer invalidate];
	self.hideTimer = nil;
	if (!self.listView.hidden) {
		[self.listView layoutIfNeeded];
		[UIView animateWithDuration:kAnimationTimer delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
			self.listBottomConstraint.constant = -kRowHeight;
			((UICollectionViewFlowLayout*)self.listView.collectionViewLayout).scrollDirection = UICollectionViewScrollDirectionHorizontal;
			[self.listView layoutIfNeeded];
		} completion:^(BOOL finished) {
			self.listView.hidden = YES;
			[self setNeedsFocusUpdate];
		}];
	}
}

- (void) startHideTimer {
	[self.hideTimer invalidate];
	self.hideTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(hideMenu) userInfo:nil repeats:NO];
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return self.list.count;
}

- (UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	VideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:VideoCell.identifier forIndexPath:indexPath];
	cell.info = self.list[indexPath.row];
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
