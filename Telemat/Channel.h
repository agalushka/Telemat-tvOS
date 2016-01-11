//
//  Channel.h
//  Telemat
//
//  Created by Oliver Michalak on 11.01.16.
//  Copyright © 2016 Oliver Michalak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Channel : NSObject

@property (nonatomic) NSString *title;
@property (nonatomic) UIImage *image;
@property (nonatomic) NSURL *streamURL;
@property (nonatomic) NSURL *programURL;
@property (nonatomic) NSArray <NSString*> *programmRegExpRules;

- (instancetype) initFromDictionary:(NSDictionary*) dict;
- (void) requestCurrentName:(void (^)(NSString *name))completion;

@end
