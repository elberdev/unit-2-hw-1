//
//  Venue.m
//  TalkinToTheNet
//
//  Created by Elber Carneiro on 9/25/15.
//  Copyright © 2015 Mike Kavouras. All rights reserved.
//

#import "Venue.h"
#import <UIKit/UIKit.h>

@implementation Venue

- (instancetype)initWithJSON:(NSDictionary *)jsonPost {
    
    if (self = [super init]) {

        self.venueName = jsonPost[@"venue"][@"name"];
        
        NSArray *photos = jsonPost[@"venue"][@"photos"][@"groups"];
        if ([photos count] > 0) {
            NSString *urlPrefix = photos[0][@"items"][0][@"prefix"];
            NSString *urlSuffix = photos[0][@"items"][0][@"suffix"];
            
            NSString *urlSmallString = [urlPrefix stringByAppendingString:@"100x100"];
            NSString *urlLargeString = [urlPrefix stringByAppendingString:@"original"];
            
            urlSmallString = [urlSmallString stringByAppendingString:urlSuffix];
            urlLargeString = [urlLargeString stringByAppendingString:urlSuffix];
            
            NSURL *urlSmall = [NSURL URLWithString:urlSmallString];
            NSData *smallData = [NSData dataWithContentsOfURL:urlSmall];
            self.imageSmall = [UIImage imageWithData:smallData];
            
            self.imageLargeURL = [NSURL URLWithString:urlLargeString];

            //NSLog(@"%@", urlSmallString);
            
        } else {
            self.imageSmall = [UIImage imageNamed:@"smallImage"];
            //NSLog(@"No Photo");
        }
        
        self.tipText = jsonPost[@"tips"][0][@"text"];
        //NSLog(@"%@", self.tipText);
        
        self.hereNow = [jsonPost[@"venue"][@"hereNow"][@"count"] integerValue];
        //NSLog(@"%ld", self.hereNow);
        
        self.rating = [jsonPost[@"venue"][@"rating"] floatValue];
        //NSLog(@"%f", self.rating);
        
        self.checkinsCount = [jsonPost[@"venue"][@"stats"][@"checkinsCount"] integerValue];
        //NSLog(@"%ld", self.checkinsCount);
        
        self.address = jsonPost[@"venue"][@"location"][@"formattedAddress"];
        //NSLog(@"%@", self.address);
        
        return self;
    }
    return nil;
}

@end
