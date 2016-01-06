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
	NSData *data = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"channel" withExtension:@"json"]];
	NSArray *list = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

	NSMutableArray *items = [@[] mutableCopy];
	for (NSDictionary *dict in list) {
		TVContentItem *item = [[TVContentItem alloc] initWithContentIdentifier:[[TVContentIdentifier alloc] initWithIdentifier:dict[@"StreamURL"] container:nil]];
		NSURLComponents *comp = [[NSURLComponents alloc] init];
		comp.scheme = @"telemat";
		comp.path = @"video";
		comp.queryItems = @[[NSURLQueryItem queryItemWithName:@"identifier" value:dict[@"StreamURL"]]];
		item.displayURL = [comp URL];
		NSString *imageName = dict[@"Bild"];
		if ([imageName hasPrefix:@"file:"])
			item.imageURL = [[NSBundle mainBundle] URLForResource:[imageName substringWithRange:NSMakeRange(5, imageName.length - (5+4))] withExtension:@"png"];

		item.imageShape = TVContentItemImageShapeSDTV;
		item.title = dict[@"SenderName"];
		[items addObject:item];
	}
	
	TVContentItem *topItem = [[TVContentItem alloc] initWithContentIdentifier:[[TVContentIdentifier alloc] initWithIdentifier:@"Container" container:nil]];
	topItem.topShelfItems = [items copy];
	return @[topItem];
}

@end
