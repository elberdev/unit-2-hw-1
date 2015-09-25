//
//  ViewController.m
//  TalkinToTheNet
//
//  Created by Michael Kavouras on 9/20/15.
//  Copyright © 2015 Mike Kavouras. All rights reserved.
//

#import "ViewController.h"
#import "SearchResultsTableViewCell.h"
#import "AuthenticationViewController.h"
#import "Config.h"
#import "APIManager.h"
#import "Venue.h"
#import "DetailViewController.h"

@interface ViewController ()
@property (nonatomic) NSString *oAuthToken;
@property (nonatomic) NSMutableArray *searchResults;
@property (nonatomic) UIButton *connectToFoursquare;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    
    self.searchResults = [[NSMutableArray alloc] init];
    self.oAuthToken = @"";
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (![defaults objectForKey:ACCESS_TOKEN_KEY]) {
        [self.connectToFoursquare setHidden:NO];
        [self.tableView setHidden:YES];
    } else {
        [self.connectToFoursquare setHidden:YES];
        [self.tableView setHidden:NO];
        self.oAuthToken = [defaults objectForKey:ACCESS_TOKEN_KEY];
        [self search];
        
    }
    
    NSLog(@"From ViewController - access token: %@", [defaults objectForKey:ACCESS_TOKEN_KEY]);
}

- (void)search {
    NSString *urlString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/explore?near=new_york,_NY&venuePhotos=1&oauth_token=%@%@", self.oAuthToken, FOURSQUARE_VERSION];
    NSLog(@"%@", urlString);
    NSURL *foursquareExploreSearch = [NSURL URLWithString:urlString];
    
    [APIManager GETRequestWithURL:foursquareExploreSearch completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        //NSLog(@"%@", json);
        
        NSArray *results = [[json objectForKey:@"response"] objectForKey:@"groups"];
        NSArray *items = [results[0] objectForKey:@"items"];
        //NSLog(@"%@", items);
        
        for (NSDictionary *item in items) {
            Venue *venue = [[Venue alloc] initWithJSON:item];
            [self.searchResults addObject:venue];
            //NSLog(@"%@", venue.venueName);
        }
        //NSLog(@"%@", self.searchResults);
        
        [self.tableView reloadData];
        
    }];
}

- (IBAction)connect:(id)sender {
    AuthenticationViewController *controller = [[AuthenticationViewController alloc] init];
    [self presentViewController:controller animated:YES completion:nil];
    [self.connectToFoursquare setHidden:YES];
    [self.tableView setHidden:NO];
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    SearchResultsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchResultsCell" forIndexPath:indexPath];
    
    cell.venueNameLabel.text = [self.searchResults[indexPath.row] venueName];
    cell.venueImage.image = [self.searchResults[indexPath.row] imageSmall];
    
    return cell;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    DetailViewController *controller = [segue destinationViewController];
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
    controller.venueImageURL = [self.searchResults[indexPath.row] imageLargeURL];
}

@end
