//
//  VideoCell.h
//  Telemat
//
//  Created by Oliver Michalak on 03.01.16.
//  Copyright © 2016 Oliver Michalak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoCell : UICollectionViewCell

+ (NSString*) identifier;

@property (weak, nonatomic) IBOutlet UILabel *title;

@end
