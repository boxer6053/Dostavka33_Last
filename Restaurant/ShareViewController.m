#import "ShareViewController.h"

@interface ShareViewController () <UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *postImageView;
@property (strong, nonatomic) IBOutlet UILabel *postNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *postCaptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *postDescriptionLabel;
@property (strong, nonatomic) NSMutableDictionary *postParams;
@property (strong, nonatomic) NSMutableData *imageData;
@property (strong, nonatomic) NSURLConnection *imageConnection;

- (IBAction)share:(id)sender;
@end

@implementation ShareViewController
@synthesize postParams = _postParams;
@synthesize imageData = _imageData;
@synthesize imageConnection = _imageConnection;
@synthesize name = _name;
@synthesize imageLink = _imageLink;
@synthesize info = _info;
@synthesize link = _link;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.postParams =
    [[NSMutableDictionary alloc] initWithObjectsAndKeys:
     _link, @"link",
     _imageLink, @"picture",
     _name, @"name",
     @"", @"caption",
     _info, @"description",
    nil];
    
    self.postNameLabel.text = [self.postParams objectForKey:@"name"];
    self.postCaptionLabel.text = [self.postParams
                                  objectForKey:@"caption"];
    [self.postCaptionLabel sizeToFit];
    self.postDescriptionLabel.text = [self.postParams
                                      objectForKey:@"description"];
    [self.postDescriptionLabel sizeToFit];
    
    self.imageData = [[NSMutableData alloc] init];
    NSURLRequest *imageRequest = [NSURLRequest
                                  requestWithURL:
                                  [NSURL URLWithString:
                                   [self.postParams objectForKey:@"picture"]]];
    self.imageConnection = [[NSURLConnection alloc] initWithRequest:
                            imageRequest delegate:self];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    if (self.imageConnection) {
        [self.imageConnection cancel];
        self.imageConnection = nil;
    }
    [super viewDidUnload];
}
- (IBAction)share:(id)sender {
    
    if ([FBSession.activeSession.permissions
         indexOfObject:@"publish_actions"] == NSNotFound) {
        [FBSession.activeSession
         reauthorizeWithPublishPermissions:
         [NSArray arrayWithObject:@"publish_actions"]
         defaultAudience:FBSessionDefaultAudienceFriends
         completionHandler:^(FBSession *session, NSError *error) {
             if (!error) {
                 [self publishStory];
             }
         }];
    } else {
        [self publishStory];
    }
}

//// image ////
- (void)connection:(NSURLConnection*)connection
    didReceiveData:(NSData*)data{
    [self.imageData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    self.postImageView.image = [UIImage imageWithData:
                                [NSData dataWithData:_imageData]];
    self.imageConnection = nil;
    self.imageData = nil;
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error{
    self.imageConnection = nil;
    self.imageData = nil;
}
///////end image/////

- (void)publishStory
{
    [FBRequestConnection
     startWithGraphPath:@"me/feed"
     parameters:self.postParams
     HTTPMethod:@"POST"
     completionHandler:^(FBRequestConnection *connection,
                         id result,
                         NSError *error) {
         NSString *alertText;
         if (error) {
             alertText = [NSString stringWithFormat:
                          @"error: domain = %@, code = %d",
                          error.domain, error.code];
         } else {
             alertText = [NSString stringWithFormat:
                          @"Posted successfully"];
         }
         [[[UIAlertView alloc] initWithTitle:@"Result"
                                     message:alertText
                                    delegate:self
                           cancelButtonTitle:@"OK!"
                           otherButtonTitles:nil]
          show];
     }];
}
@end

