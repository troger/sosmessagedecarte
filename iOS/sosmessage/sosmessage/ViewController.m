//
//  ViewController.m
//  sosmessage
//
//  Created by Arnaud K. on 30/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
@synthesize messageLabel;
@synthesize activityIndicator;
@synthesize currentConnection;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setActivityIndicator:nil];
    [self setMessageLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self becomeFirstResponder];
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.currentConnection cancel];
    [self.currentConnection release];
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
    
    /*
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }*/
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

#pragma mark NSURLConnection delegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self stopActivity];
    self.messageLabel.text = error.description;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self stopActivity];
    if (messageReceiving) {
        NSError* error;
        id response = [NSJSONSerialization JSONObjectWithData:messageReceiving options:0 error:&error];
        if (response) {
            // TODO should handle other request
            NSLog(@"%@", response);
            self.messageLabel.text = [[response objectAtIndex:(random() % [response count])] objectForKey:@"label"];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (messageReceiving) {
        [messageReceiving appendData:data];
    } else {
        messageReceiving = [[NSMutableData alloc] initWithData:data];
    }
}

-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        [self fetchAnotherMessage];
    }
}


#pragma mark Custom methods

-(void)startActivity {
    [self.activityIndicator startAnimating];
}

-(void)stopActivity {
    [self.activityIndicator stopAnimating];
}

-(void)fetchAnotherMessage {
    [self startActivity];
    
    NSURL* url = [[NSURL alloc] initWithString:@"http://kervern.me/v1/categories"];
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:url];
    messageReceiving = nil;
    
    self.currentConnection = [NSURLConnection connectionWithRequest:request delegate:self];
    
    [request release];
    [url release];
}
- (void)dealloc {
    [activityIndicator release];
    [messageLabel release];
    [super dealloc];
}
@end
