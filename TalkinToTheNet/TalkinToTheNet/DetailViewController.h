//
//  DetailViewController.h
//  TalkinToTheNet
//
//  Created by Elber Carneiro on 9/25/15.
//  Copyright © 2015 Mike Kavouras. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (nonatomic) NSURL *venueImageURL;
@property (weak, nonatomic) IBOutlet UIImageView *venueImageLarge;
@property (nonatomic) NSString *venueName;
@property (nonatomic) NSString *tipText;
@property (nonatomic) NSInteger hereNow;
@property (nonatomic) CGFloat rating;
@property (nonatomic) NSInteger checkinsCount;
@property (nonatomic) NSArray *address;

@end
