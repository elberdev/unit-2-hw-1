//
//  DetailViewController.m
//  TalkinToTheNet
//
//  Created by Elber Carneiro on 9/25/15.
//  Copyright © 2015 Mike Kavouras. All rights reserved.
//

#import "DetailViewController.h"
#import "FLAnimatedImageView.h"
#import "FLAnimatedImage.h"
#import "APIManager.h"
#import "Config.h"

@interface DetailViewController()
@property (weak, nonatomic) IBOutlet UILabel *venueNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet UILabel *hereNowLabel;
@property (weak, nonatomic) IBOutlet UILabel *checkinsLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet FLAnimatedImageView *stickerView;
@property (nonatomic) NSMutableArray *stickers;
@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.stickers = [[NSMutableArray alloc] init];
    
    if (self.venueImageURL != nil) {
        NSData *data = [NSData dataWithContentsOfURL:self.venueImageURL];
        self.venueImageLarge.image = [UIImage imageWithData:data];
    } else {
        self.venueImageLarge.image = [UIImage imageNamed:@"largeImage"];
    }
    
    self.venueNameLabel.text = self.venueName;
    self.ratingLabel.text = [NSString stringWithFormat:@"Rating: %.2f", self.rating];
    self.hereNowLabel.text = [NSString stringWithFormat:@"Here now: %ld", self.hereNow];
    self.checkinsLabel.text = [NSString stringWithFormat:@"Checkins: %ld", self.checkinsCount];
    self.tipTextLabel.text = self.tipText;
    self.addressLabel.text = self.address[0];
    
    [self fetchSticker];
    
}

- (void)fetchSticker {
    NSArray *searchWords = [self.venueName componentsSeparatedByString:@" "];
    NSArray *searchWords2 = [self.tipText componentsSeparatedByString:@" "];
    
    NSArray *fullSearchArray = [searchWords arrayByAddingObjectsFromArray:searchWords2];
    NSLog(@"%@", fullSearchArray);
    
    NSString *urlPrefixString = @"http://api.giphy.com/v1/stickers/search?q=";
    
    for (NSString *searchTerm in fullSearchArray) {
        
        if ([self.stickers count] > 0) {
            break;
        }
        
        NSString *lowerSearch = [searchTerm lowercaseString];
        if ([lowerSearch isEqualToString:@"the"] ||
            [lowerSearch isEqualToString:@"an"] ||
            [lowerSearch isEqualToString:@"a"]) {
            continue;
        }
        
        NSString *urlString = [NSString stringWithFormat:@"%@%@%@", urlPrefixString, lowerSearch, GIPHY_STICKER_KEY];
        //NSLog(@"url: %@", urlString);
        NSURL *searchURL = [NSURL URLWithString:urlString];
        
        [APIManager GETRequestWithURL:searchURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (data != nil) {
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                //NSLog(@"json: %@", json);
                
                if ([json[@"data"] count] > 0) {
                    for (NSDictionary *dict in json[@"data"]) {
                        NSString *stickerUrlString = dict[@"images"][@"fixed_height"][@"url"];
                        //NSLog(@"stickerUrlString: %@", stickerUrlString);
                        NSURL *stickerUrl = [NSURL URLWithString:stickerUrlString];
                        [self.stickers addObject:stickerUrl];
                        NSLog(@"self.stickers: %@", self.stickers);
                    }
                    
                    NSInteger randomIndex = arc4random_uniform((uint32_t)self.stickers.count);
                    NSLog(@"random index: %ld", randomIndex);
                    NSData *stickerData = [NSData dataWithContentsOfURL:self.stickers[randomIndex]];
                    FLAnimatedImage *image = [[FLAnimatedImage alloc] initWithAnimatedGIFData:stickerData];
                    [self.stickerView setAnimatedImage:image];
                    [self.stickerView setNeedsDisplay];

                }
                
            }

        }];
    }
}

@end
