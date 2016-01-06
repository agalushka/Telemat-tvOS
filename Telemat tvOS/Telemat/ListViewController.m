//
//  ViewController.m
//  Telemat
//
//  Created by Oliver Michalak on 03.01.16.
//  Copyright © 2016 Oliver Michalak. All rights reserved.
//

#import "ListViewController.h"
#import "VideoPlayerViewController.h"
#import "VideoCell.h"

@interface ListViewController () <UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *listView;
@property (nonatomic) NSArray *list;
@end

@implementation ListViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	NSData *data = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"channel" withExtension:@"json"]];
	self.list = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
	[self.listView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return self.list.count;
}

- (UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	VideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:VideoCell.identifier forIndexPath:indexPath];
	cell.info = self.list[indexPath.row];
	return cell;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"showChannel"]) {
		VideoPlayerViewController *videoPlayer = segue.destinationViewController;
		videoPlayer.index = ((NSIndexPath*)[self.listView indexPathsForSelectedItems].firstObject).row;
	}
}

@end
