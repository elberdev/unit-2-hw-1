//
//  DetailViewController.m
//  TalkinToTheNet
//
//  Created by Elber Carneiro on 9/25/15.
//  Copyright © 2015 Mike Kavouras. All rights reserved.
//

#import "DetailViewController.h"

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.venueImageURL != nil) {
        NSData *data = [NSData dataWithContentsOfURL:self.venueImageURL];
        self.venueImageLarge.image = [UIImage imageWithData:data];
    } else {
        self.venueImageLarge.image = [UIImage imageNamed:@"largeImage"];
    }
}

@end
