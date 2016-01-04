//
//  ServiceProvider.m
//  TelematShelfExtension
//
//  Created by Oliver Michalak on 03.01.16.
//  Copyright © 2016 Oliver Michalak. All rights reserved.
//

#import "ServiceProvider.h"

@interface ServiceProvider ()

@end

@implementation ServiceProvider

- (TVTopShelfContentStyle)topShelfStyle {
    return TVTopShelfContentStyleSectioned;
}

- (NSArray *)topShelfItems {
	NSArray *list = [NSArray arrayWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"sender" withExtension:@"plist"]];
	NSMutableArray *items = [@[] mutableCopy];
	for (NSDictionary *dict in list) {
		TVContentItem *item = [[TVContentItem alloc] initWithContentIdentifier:[[TVContentIdentifier alloc] initWithIdentifier:dict[@"streamURL"] container:nil]];
		NSURLComponents *comp = [[NSURLComponents alloc] init];
		comp.scheme = @"telemat";
		comp.path = @"video";
		comp.queryItems = @[[NSURLQueryItem queryItemWithName:@"identifier" value:dict[@"streamURL"]]];
		item.displayURL = [comp URL];
		item.imageShape = TVContentItemImageShapeSDTV;
		item.title = dict[@"title"];
		[items addObject:item];
	}
	
	TVContentItem *topItem = [[TVContentItem alloc] initWithContentIdentifier:[[TVContentIdentifier alloc] initWithIdentifier:@"ContainerID" container:nil]];
	topItem.topShelfItems = [items copy];
	return @[topItem];
}

@end
