#import "FacebookLoginViewController.h"
#import "ShareViewController.h"

@interface FacebookLoginViewController ()

@end

@implementation FacebookLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
//    UIImage *fbBackgroundImage = [UIImage imageNamed:@"FBbackgroundNew.png"];
//    [self.backgroundImage setImage:fbBackgroundImage];
    
    UIImage *fbTitleImage = [UIImage imageNamed:@"facebookHeader.jpeg"];
    [self.titleImage setImage:fbTitleImage];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(sessionStateChanged:)
     name:FBSessionStateChangedNotification
     object:nil];
    
    RestaurantAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate openSessionWithAllowLoginUI:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)authButtonAction:(id)sender {
    RestaurantAppDelegate *appDelegate =
    [[UIApplication sharedApplication] delegate];
    if (FBSession.activeSession.isOpen) {
        [appDelegate closeSession];
    } else {
        [appDelegate openSessionWithAllowLoginUI:YES];
    }
}

- (void)sessionStateChanged:(NSNotification*)notification {
    if (FBSession.activeSession.isOpen) {
        self.publishButton.hidden = NO;
        [self.authButton setTitle:@"Logout" forState:UIControlStateNormal];
    } else {
        self.publishButton.hidden = YES;
        [self.authButton setTitle:@"Login" forState:UIControlStateNormal];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toShare"]) {
        ShareViewController *shareViewController = segue.destinationViewController;
        shareViewController.imageLink = _imageLinkLogin;
        shareViewController.info = _infoLogin;
        shareViewController.link = _linkLogin;
        shareViewController.name = _nameLogin;
    }
}

- (void)viewDidUnload {
    [self setAuthButton:nil];
    [self setPublishButton:nil];
    [self setTitleImage:nil];
    [self setBackgroundImage:nil];
    [super viewDidUnload];
}
@end
