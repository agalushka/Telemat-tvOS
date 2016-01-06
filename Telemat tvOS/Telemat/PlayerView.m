//
//  PlayerView.m
//  videoTest
//
//  Created by Oliver Michalak on 17.09.15.
//  Copyright © 2015 Oliver Michalak. All rights reserved.
//

#import "PlayerView.h"
#import <AVFoundation/AVFoundation.h>

@implementation PlayerView

+ (Class) layerClass {
	return AVPlayerLayer.class;
}

@end
