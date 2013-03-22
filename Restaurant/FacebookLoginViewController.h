#import <UIKit/UIKit.h>
#import "RestaurantAppDelegate.h"

@interface FacebookLoginViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *authButton;
@property (strong, nonatomic) IBOutlet UIButton *publishButton;
@property (strong, nonatomic) IBOutlet UIImageView *titleImage;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImage;
- (IBAction)authButtonAction:(id)sender;

@property (strong,nonatomic) NSString *nameLogin;
@property (strong,nonatomic) NSString *infoLogin;
@property (strong,nonatomic) NSString *linkLogin;
@property (strong,nonatomic) NSString *imageLinkLogin;

@end