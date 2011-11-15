//
//  ViewController.m
//  sosmessage
//
//  Created by Arnaud K. on 30/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "SMDetailViewController.h"

@implementation ViewController
@synthesize activityIndicator;
@synthesize categories;
@synthesize messageHandler;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    id iMessageHandler = [[SMMessagesHandler alloc] initWithDelegate:self];
    self.messageHandler = iMessageHandler;
    [iMessageHandler release];
}

- (void)viewDidUnload
{
    [self setActivityIndicator:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCategories) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [self.messageHandler requestUrl:[NSString stringWithFormat:@"%@/api/v1/categories", SM_URL]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self becomeFirstResponder];
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(BOOL)canBecomeFirstResponder 
{
    return YES;
}

-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event 
{
    if (motion == UIEventSubtypeMotionShake) {
        [self.messageHandler requestUrl:[NSString stringWithFormat:@"%@/api/v1/categories", SM_URL]];
    }
}

#pragma mark Category handling

- (void)addSOSCategory:(NSString*)label inPosX:(int)posX andPosY:(int)posY {
    float blockSize = self.view.bounds.size.width / NB_BLOCKS;
    
    float rectX = floorf(blockSize * posX);
    //float rectY = posY; //origin y will be re-calculate after views are generated
    float rectWidth = ceilf([label sizeForBlocksForView:self.view]);
    float rectHeight = 1; //arbitrary set to 1
    
    //NSLog(@"Place label (%@) at (%.2f;%.2f) with size (%.2f;%.2f)", label, rectX, rectY, rectWidth, rectHeight);
    
    UILabel* uiLabel = [[[UILabel alloc] initWithFrame:CGRectMake(rectX, posY, rectWidth, rectHeight)] autorelease];
    uiLabel.backgroundColor = [UIColor colorWithHue:label.hue saturation:0.55 brightness:0.9 alpha:1.0];
    uiLabel.text = [label capitalizedString];
    uiLabel.font = SOSFONT;
    uiLabel.textAlignment = UITextAlignmentCenter;
    uiLabel.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *categoryTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCategoryTapping:)];
    [uiLabel addGestureRecognizer:categoryTap];
    [categoryTap release];
    
    [self.view addSubview:uiLabel];
}

- (void)fillEmptyBlocks:(int)nb fromPosX:(int)posX andPosY:(int)posY {
    float blockSize = self.view.bounds.size.width / NB_BLOCKS;
    NSLog(@"Bounds width: %.2f and Frame width: %.2f", self.view.bounds.size.width, self.view.frame.size.width);
    
    float rectX = floorf(blockSize * posX);
    //float rectY = posY; //origin y will be re-calculate after views are generated
    float rectWidth = blockSize * nb;
    float rectHeight = 1; //arbitrary set to 1
    
    //NSLog(@"Fill %d blocks at (%.2f;%.2f) with size (%.2f;%.2f)", nb, rectX, rectY, rectWidth, rectHeight);
    UILabel* emptyBlocks = [[[UILabel alloc] initWithFrame:CGRectMake(rectX, posY, rectWidth, rectHeight)] autorelease];
    
    float hue = (rand()%24) / 24.0;
    emptyBlocks.backgroundColor = [UIColor colorWithHue:hue saturation:0.2 brightness:1 alpha:1.0];
    
    [self.view addSubview:emptyBlocks];
}

- (void)refreshCategories {
    [self removeCategoriesLabel];
    
    NSMutableArray* workingCategories = [[NSMutableArray alloc] initWithArray:categories];
    
    int x = 0;
    int y = 0;
    while (workingCategories.count > 0) {
        NSDictionary* category = [workingCategories objectAtIndex:0];
        int blockSize = [[category objectForKey:@"name"] blocksCount:self.view];
        if ((NB_BLOCKS - x < blockSize)) {
            [self fillEmptyBlocks:NB_BLOCKS - x fromPosX:x andPosY:y];
            x = 0;
            y += 1;
        }
        
        [self addSOSCategory:[category objectForKey:@"name"] inPosX:x andPosY:y];
        
        x += blockSize;
        if (x >= NB_BLOCKS) {
            y += 1;
            x = 0;
        }
        
        [workingCategories removeObjectAtIndex:0];
    }
    
    if (x < NB_BLOCKS && x > 0) {
        [self fillEmptyBlocks:NB_BLOCKS - x fromPosX:x andPosY:y];        
    }
    [workingCategories release];
    
    if (x == 0) {
        y -= 1;
    }
    float fitHeight =  self.view.bounds.size.height / (y + 1);
    for (UIView* subView in self.view.subviews) {
        if ([subView isKindOfClass:[UILabel class]] && subView.tag == 0) {
            subView.frame = CGRectMake(subView.frame.origin.x, subView.frame.origin.y * fitHeight, subView.frame.size.width, fitHeight);
        }
    }
}

-(void)removeCategoriesLabel {
    for (UIView* subView in self.view.subviews) {
        if ([subView isKindOfClass:[UILabel class]] && subView.tag == 0) {
            [subView removeFromSuperview];
        }
    }
}

- (void)handleCategoryTapping:(UIGestureRecognizer *)sender {
    UILabel* category = (UILabel*)sender.view;
    
    CGFloat hue;
    [category.backgroundColor getHue:&hue saturation:nil brightness:nil alpha:nil];
    
    NSLog(@"Hue color: %.3f", hue);
    SMDetailViewController* detail = [[SMDetailViewController alloc] initWithHue:hue category:category.text];
    detail.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:detail animated:true];
    [detail release];
}

#pragma mark NSMessageHandlerDelegate

- (void)startActivityFromMessageHandler:(SMMessagesHandler *)messageHandler
{
    [self.activityIndicator startAnimating];
    NSLog(@"Start activity !!!");
}

- (void)stopActivityFromMessageHandler:(SMMessagesHandler *)messageHandler
{
    [self.activityIndicator stopAnimating];
    NSLog(@"Stop activity !!!");
}

- (void)messageHandler:(SMMessagesHandler *)messageHandler didFinishWithJSon:(id)result
{
    if ([result objectForKey:@"count"] > 0) {
        self.categories = [[NSMutableArray alloc] initWithArray:[result objectForKey:@"items"]];
        [self refreshCategories];
    }
}

#pragma mark Custom methods

- (void)dealloc {
    [categories release];
    [activityIndicator release];
    [messageHandler release];
    [super dealloc];
}
@end
