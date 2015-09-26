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
@property (nonatomic) NSUserDefaults *defaults;
@property (nonatomic) UISearchBar *searchBar;
@property (nonatomic) NSString *query;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.searchResults = [[NSMutableArray alloc] init];
    
    self.searchBar = [[UISearchBar alloc] init];
    self.navigationItem.titleView = self.searchBar;
    [self.searchBar setUserInteractionEnabled:NO];
    self.searchBar.delegate = self;
    
    self.oAuthToken = @"";
    self.query = @"";
    
    // comment these next lines out to save for realz. They're just here for
    // better demo to force authentication.
    self.defaults = [NSUserDefaults standardUserDefaults];
    [self.defaults removeObjectForKey:ACCESS_TOKEN_KEY];
}

- (void)viewWillAppear:(BOOL)animated {
    
    if (![self.defaults objectForKey:ACCESS_TOKEN_KEY]) {
        [self.connectToFoursquare setHidden:NO];
        [self.tableView setHidden:YES];
    } else {
        [self.connectToFoursquare setHidden:YES];
        [self.tableView setHidden:NO];
        self.oAuthToken = [self.defaults objectForKey:ACCESS_TOKEN_KEY];
        [self.searchBar setUserInteractionEnabled:YES];
    }
    
    NSLog(@"From ViewController - access token: %@", [self.defaults objectForKey:ACCESS_TOKEN_KEY]);
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.query = searchBar.text;
    [self search];
    NSLog(@"search button clicked");
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    self.query = searchBar.text;
    [self search];
    NSLog(@"text did end editing");
}

- (void)search {
    
    NSString *safeQuery = [self.query stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/explore?near=%@&venuePhotos=1&oauth_token=%@%@", safeQuery, self.oAuthToken, FOURSQUARE_VERSION];
    //NSLog(@"%@", urlString);
    NSURL *foursquareExploreSearch = [NSURL URLWithString:urlString];
    
    [APIManager GETRequestWithURL:foursquareExploreSearch completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        NSArray *results = [[json objectForKey:@"response"] objectForKey:@"groups"];
        NSArray *items = [results[0] objectForKey:@"items"];
        
        [self.searchResults removeAllObjects];
        
        for (NSDictionary *item in items) {
            Venue *venue = [[Venue alloc] initWithJSON:item];
            [self.searchResults addObject:venue];
        }
        
        [self.tableView reloadData];
        
    }];
}

#pragma mark - UIButton action
- (IBAction)connect:(id)sender {
    AuthenticationViewController *controller = [[AuthenticationViewController alloc] init];
    [self presentViewController:controller animated:YES completion:nil];
    [self.connectToFoursquare setHidden:YES];
//    [self.tableView setHidden:NO];
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
    
    Venue *venue = self.searchResults[indexPath.row];
    
    controller.venueImageURL = venue.imageLargeURL;
    controller.venueName = venue.venueName;
    controller.tipText = venue.tipText;
    controller.hereNow = venue.hereNow;
    controller.rating = venue.rating;
    controller.checkinsCount = venue.checkinsCount;
    controller.address = venue.address;
}

@end
