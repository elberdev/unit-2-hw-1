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

- (NSString *)chooseSearchTerm {
    
    // COMPILE SEARCH TERMS AND PICK A RANDOM ONE
    NSString *searchTerm = [[self.venueName lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSArray *separateSearchWords = [searchTerm componentsSeparatedByString:@"+"];
    NSArray *searchWordsAdditional = [self.tipText componentsSeparatedByString:@" "];
    
    NSMutableArray *searchWordsAdditionalClean = [[NSMutableArray alloc] init];
    
    for (NSString *string in searchWordsAdditional) {
        NSString *cleanString = [string stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        NSString *cleanerString = [cleanString stringByReplacingOccurrencesOfString:@"," withString:@""];
        NSString *evenCleanerString = [cleanerString stringByReplacingOccurrencesOfString:@"\'"withString:@""];
        NSString *ridiculouslyClean = [evenCleanerString stringByReplacingOccurrencesOfString:@"." withString:@""];
        [searchWordsAdditionalClean addObject:ridiculouslyClean];
    }
    
    NSArray *searchTermsComplete = [separateSearchWords arrayByAddingObjectsFromArray:searchWordsAdditionalClean];
    
    NSMutableArray *prunedArray = [[NSMutableArray alloc] init];
    
    for (NSString *string in searchTermsComplete) {
        
        NSString *stringToCopy = [[NSString alloc] init];
        
        if ([[string lowercaseString] isEqualToString:@"a"] ||
            [[string lowercaseString] isEqualToString:@"an"] ||
            [[string lowercaseString] isEqualToString:@"at"] ||
            [[string lowercaseString] isEqualToString:@"the"] ||
            [[string lowercaseString] isEqualToString:@"and"] ||
            [[string lowercaseString] isEqualToString:@"in"] ||
            [[string lowercaseString] isEqualToString:@"on"] ||
            [[string lowercaseString] isEqualToString:@"be"] ||
            [[string lowercaseString] isEqualToString:@"of"] ||
            [[string lowercaseString] isEqualToString:@"is"] ||
            [[string lowercaseString] isEqualToString:@"it"] ||
            [[string lowercaseString] isEqualToString:@"for"] ||
            [[string lowercaseString] isEqualToString:@"to"] ||
            [[string lowercaseString] isEqualToString:@"gracie"] ||
            [[string lowercaseString] isEqualToString:@"foodies"]) {
            
            stringToCopy = @"new+york";
            
        } else {
            
            stringToCopy = string;
        }
        
        [prunedArray addObject:stringToCopy];
    }
    
    NSInteger randomSearchIndex = arc4random_uniform((uint32_t)prunedArray.count);
    return prunedArray[randomSearchIndex];
}

- (void)fetchSticker {
    
    NSString *searchTerm = [self chooseSearchTerm];
    
    NSString *urlPrefixString = @"http://api.giphy.com/v1/stickers/search?q=";
        
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@", urlPrefixString, searchTerm, GIPHY_STICKER_KEY];
    NSLog(@"url: %@", urlString);
    NSURL *searchURL = [NSURL URLWithString:urlString];

    [APIManager GETRequestWithURL:searchURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSLog(@"json: %@", json);
        
        if ([json[@"data"] count] > 0) {
            for (NSDictionary *dict in json[@"data"]) {
                NSString *stickerUrlString = dict[@"images"][@"fixed_height"][@"url"];
                NSLog(@"stickerUrlString: %@", stickerUrlString);
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
            return;
        } else {
            NSLog(@"No search results found");
        }
        
    }];

}

@end
