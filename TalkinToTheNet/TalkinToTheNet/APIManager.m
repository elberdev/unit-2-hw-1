//
//  APIManager.m
//  Networking
//
//  Created by Elber Carneiro on 9/20/15.
//  Copyright © 2015 Elber Carneiro. All rights reserved.
//

#import "APIManager.h"

@implementation APIManager

// Nasty abstracted logic
+ (void)GETRequestWithURL:(NSURL *)URL
        completionHandler:(void(^)(NSData *data, NSURLResponse *response, NSError *error)) completionHandler {
    
    // Create a session (look, ma! a singleton!).
    NSURLSession *session = [NSURLSession sharedSession];
    
    // Create a task with the URL and a completion block
    NSURLSessionDataTask *task = [session dataTaskWithURL:URL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        // if you try to change the interface from outside the main thread, it
        // will throw all sorts of errors. That's why we need to make sure we
        // dispatch the action to the main thread.
        dispatch_async(dispatch_get_main_queue(), ^ {
            
            completionHandler(data, response, error);
            
        });
    }];
    
    // Get the task going
    [task resume];
}

@end
