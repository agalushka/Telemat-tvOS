//
//  Channel.m
//  Telemat
//
//  Created by Oliver Michalak on 11.01.16.
//  Copyright © 2016 Oliver Michalak. All rights reserved.
//

#import "Channel.h"

@implementation Channel

- (instancetype) initFromDictionary:(NSDictionary*) dict {
	if ((self = [super init])) {
		_title = dict[@"SenderName"];
		
		NSString *imageName = dict[@"Bild"];
		if ([imageName hasPrefix:@"file:"])
			self.image = [UIImage imageNamed:[imageName substringFromIndex:5]];
		_streamURL = [NSURL URLWithString:dict[@"StreamURL"]];
		_programURL = [NSURL URLWithString:dict[@"ProgrammURL"]];
		_programmRegExpRules = dict[@"ProgrammRegExp"];
	}
	return self;
}

- (void) requestCurrentName:(void (^)(NSString *name))completion {
	[[[NSURLSession sharedSession] dataTaskWithURL:self.programURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		if (data.length) {
			NSError *error;
			NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			NSMutableArray *texts = [@[text] mutableCopy];
			for (NSString *rule in self.programmRegExpRules) {
				NSMutableArray *tempList = [@[] mutableCopy];
				NSRegularExpression *expr = [NSRegularExpression regularExpressionWithPattern:rule options:NSRegularExpressionCaseInsensitive|NSRegularExpressionAllowCommentsAndWhitespace|NSRegularExpressionDotMatchesLineSeparators error:&error];
				for (NSString *subtext in texts) {
					[expr enumerateMatchesInString:subtext options:0 range:NSMakeRange(0, subtext.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
						if (result.range.length > 0) {
							[tempList addObject:[subtext substringWithRange:result.range]];
						}
					}];
				}
				texts = tempList;
			}
			text = texts.firstObject;
			if (text.length < 1000) {
				NSArray *rules = @[@"<[^>]*?>(.*?)",
													 @"[\\s]+(\\s)"];
				for (NSString *rule in rules) {
					NSRegularExpression *expr = [NSRegularExpression regularExpressionWithPattern:rule options:0 error:nil];
					text = [expr stringByReplacingMatchesInString:text options:0 range:NSMakeRange(0, text.length) withTemplate:@"$1"];
				}
				text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//				NSLog(@"%@", text);
				dispatch_async(dispatch_get_main_queue(), ^{
					completion(text);
				});
			}
		}
	}] resume];
}

- (NSString*) description {
	return self.title;
}

@end
