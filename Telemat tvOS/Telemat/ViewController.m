//
//  ViewController.m
//  Telemat
//
//  Created by Oliver Michalak on 03.01.16.
//  Copyright © 2016 Oliver Michalak. All rights reserved.
//

#import "ViewController.h"
#import "VideoPlayerViewController.h"
#import "VideoCell.h"

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *listView;
@property (nonatomic) NSArray *list;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	self.list = [NSArray arrayWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"sender" withExtension:@"plist"]];
	[self.listView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return self.list.count;
}

- (UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	VideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:VideoCell.identifier forIndexPath:indexPath];
	NSDictionary *dict = self.list[indexPath.row];
	cell.title.text = dict[@"title"];

	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *dict = self.list[indexPath.row];

	[[VideoPlayerViewController videoPlayerWithURL:[NSURL URLWithString:dict[@"streamURL"]]] play];
}

@end
