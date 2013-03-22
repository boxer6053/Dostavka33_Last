#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface RestaurantAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSString *testToken1;
@property (strong, nonatomic) NSString *local;
@property (strong, nonatomic) NSString *testDeviceToken;

extern NSString *const FBSessionStateChangedNotification;
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;
- (void) closeSession;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
