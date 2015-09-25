//
//  Venue.h
//  TalkinToTheNet
//
//  Created by Elber Carneiro on 9/25/15.
//  Copyright © 2015 Mike Kavouras. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Venue : NSObject
@property (nonatomic) NSString *venueName;
@property (nonatomic) UIImage *imageSmall;
@property (nonatomic) NSURL *imageLargeURL;
@property (nonatomic) NSString *tipText;
@property (nonatomic) NSInteger hereNow;
@property (nonatomic) CGFloat rating;
@property (nonatomic) NSInteger checkinsCount;
@property (nonatomic) NSArray *address;
- (instancetype)initWithJSON:(NSDictionary *)jsonPost;
@end
