#import "ProductDetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SSToolkit/SSToolkit.h"
#import "checkConnection.h"
#import "FacebookLoginViewController.h"
#import "IngredientCell.h"
#import "ProductDescriptionCell.h"
#import "SizeStruct.h"

@interface ProductDetailViewController () <UITextViewDelegate>
{
    BOOL isDownloadingPicture;
    BOOL isDeletingFromCart;
    BOOL isPictureViewContanerShow;
}

@property BOOL isInFavorites;
@property BOOL isFromCart;
@property (strong, nonatomic) NSString *labelString;
@property (strong, nonatomic) UIAlertView *alert;
@property (nonatomic, strong) SSLoadingView *loadingView;
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) GettingCoreContent *content;
@property (strong, nonatomic) NSString *currentEmail;
@property (strong, nonatomic) NSString *currentPrice;
@property (strong, nonatomic) UITableView *sizeTableView;
@property (strong, nonatomic) UIView *popupView;
@property (strong, nonatomic) NSArray *arrayOfSizes;
@property (strong, nonatomic) SizeStruct *currentSize;
@property (nonatomic) int height;
@property (nonatomic) int width;

//titles
@property (strong, nonatomic) NSString *titleWihtDiscounts;
@property (strong, nonatomic) NSString *titleCancel;
@property (strong, nonatomic) NSString *titleAddetItemToTheCart;
@property (weak, nonatomic) NSString *titleYES;
@property (weak, nonatomic) NSString *titleNO;
@property (weak, nonatomic) NSString *titleDoYouWantDeleteItemFromCart;

@end

@implementation ProductDetailViewController
@synthesize db = _db;
@synthesize product = _product;
@synthesize ingredients = _ingredients;
@synthesize countPickerView = _countPickerView;
@synthesize tableViewIngredients = _tableViewIngredients;
@synthesize priceView = _priceView;
@synthesize cartButton = _cartButton;
@synthesize count = _count;
@synthesize shareButton = _addToFavorites;
@synthesize nameLabal = _nameLabal;
@synthesize pictureViewContainer = _pictureViewContainer;
@synthesize pictureButton = _pictureButton;
@synthesize imageView = _imageView;
@synthesize scrollView = _scrollView;
@synthesize captionLabel = _captionLabel;
@synthesize nilCaption = _nilCaption;
@synthesize proteinLabel = _proteinLabel;
@synthesize fatLabel = _fatLabel;
@synthesize carbohydratesLabel = _carbohydratesLabel;
@synthesize kCalLabel = _kCal;
@synthesize portionLabel = _portionLabel;
@synthesize portionProteinLabel = _portionProteinLabel;
@synthesize portionFatLabel = _portionFatLabel;
@synthesize portionCarbohydratesLabel = _portionCarbohydratesLabel;
@synthesize portionKCalLabel = _portionKCalLabel;
@synthesize in100gLabel = _in100gLabel;
@synthesize in100gProteinLabel = _in100gProteinLabel;
@synthesize in100gFatLabel = _in100gFatLabel;
@synthesize in100gCarbohydratesLabel = _in100gCarbohydratesLabel;
@synthesize in100gKCalLabel = _in100gKCalLabel;
@synthesize descriptionLabel = _descriptionLabel;
@synthesize weightLabel = _weightLabel;
@synthesize isFromCart = _isFromCart;
@synthesize isInFavorites = _isInFavorites;
@synthesize labelString = _labelString;
@synthesize alert = _alert;
@synthesize loadingView = _loadingView;
@synthesize textView = _textView;
@synthesize titleAddetItemToTheCart = _titleAddetItemToTheCart;
@synthesize content = _content;
@synthesize currentEmail = _currentEmail;
@synthesize currentPrice = _currentPrice;
@synthesize width = _width;
@synthesize height = _height;
@synthesize imageDownloadsInProgress = _imageDownloadsInProgress;
@synthesize sizeButton = _sizeButton;
@synthesize sizeTableView = _sizeTableView;
@synthesize arrayOfSizes = _arrayOfSizes;
@synthesize currentSize = _currentSize;
@synthesize popupView = _popupView;

//titles
@synthesize titleWihtDiscounts = _titleWihtDiscounts;
@synthesize titleCancel = _titleCancel;
@synthesize titleYES = _titleYES;
@synthesize titleNO = _titleNO;
@synthesize titleDoYouWantDeleteItemFromCart = _titleDoYouWantDeleteItemFromCart;

- (void)setProduct:(ProductDataStruct *)product isFromFavorites:(BOOL)boolValue isFromCart:(BOOL)cartValue
{
    _product = product;
    self.isInFavorites = boolValue;
    self.isFromCart = cartValue;
}

-(void)setLabelOfAddingButtonWithString:(NSString *)labelString withIndexPathInDB:(NSIndexPath *)indexPath
{
    self.labelString = labelString;
    //[_product setCount:[NSNumber numberWithInt:0]];
}

- (IBAction)SizeButtonClicked:(id)sender
{
    if(!self.popupView)
    {
        self.popupView = [[UIView alloc]initWithFrame:CGRectMake(107,200, 120, 100)];
        self.popupView.backgroundColor = [UIColor blackColor];
        [self.popupView.layer setCornerRadius:5.0f];
        [self.popupView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [self.popupView.layer setBorderWidth:1.5f];
        [self.popupView.layer setShadowColor:[UIColor blackColor].CGColor];
        [self.popupView.layer setShadowOpacity:0.8];
        [self.popupView.layer setShadowRadius:3.0];
        [self.popupView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
        [self.view addSubview:self.popupView];
        
        self.sizeTableView = [[UITableView alloc]initWithFrame:CGRectMake(7, 7, 106, 86)];
        self.sizeTableView.delegate = self;
        self.sizeTableView.dataSource = self;
        [self.popupView addSubview:self.sizeTableView];
    }
    else
    {
        if(self.popupView.hidden)
            self.popupView.hidden = NO;
        else
            self.popupView.hidden = YES;
    }
}

- (IBAction)share:(id)sender
{
    UIActionSheet* actionSheet = [[UIActionSheet alloc] init];
    [actionSheet setTitle:self.shareButton.titleLabel.text];
    [actionSheet setDelegate:(id)self];
    [actionSheet addButtonWithTitle:@"Twitter"];
    [actionSheet addButtonWithTitle:@"Facebook"];
    [actionSheet addButtonWithTitle:@"Cancel"];
    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
    [actionSheet showInView:self.view];
}

- (IBAction)showOrHidePictureViewContainer:(id)sender {
    if (!isPictureViewContanerShow) {
        
        if ([[UIScreen mainScreen] bounds].size.height == 480)
        {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.3];
            self.pictureViewContainer.frame = CGRectMake(0, -210, self.width, self.height);
            [UIView commitAnimations];
        }
        else
        {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.3];
            self.pictureViewContainer.frame = CGRectMake(0, -290, self.width, 320);
            [UIView commitAnimations];
        }
                
        [self.scrollView setHidden:NO];
        
        isPictureViewContanerShow = YES;
    } else {
        
        if ([[UIScreen mainScreen] bounds].size.height == 480)
        {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.3];
            self.pictureViewContainer.frame = CGRectMake(0, 0, self.width, self.height);
            [UIView commitAnimations];
        }
        else
        {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.3];
            self.pictureViewContainer.frame = CGRectMake(0, 0, self.width, 320);
            [UIView commitAnimations];
        }
        
        isPictureViewContanerShow = NO;
    }
}

- (IBAction)dragPictureViewContainer:(UIPanGestureRecognizer *)sender
{
    CGPoint translation = [sender translationInView:self.view];
    //    translation.y
    sender.view.center = CGPointMake(sender.view.center.x, sender.view.center.y + translation.y);
    
    if ([[UIScreen mainScreen] bounds].size.height == 480)
    {
        if (sender.view.center.y >= 120) {
            sender.view.center = CGPointMake(sender.view.center.x, 120);
            [sender setTranslation:CGPointMake(0, 0) inView:self.view];
            
            isPictureViewContanerShow = NO;
        } else if (sender.view.center.y <= -90) {
            sender.view.center = CGPointMake(sender.view.center.x, -90);
            [sender setTranslation:CGPointMake(0, 0) inView:self.view];
            
            //        [self.scrollView setHidden:NO];
            
            isPictureViewContanerShow = YES;
            
        } else {
            [sender setTranslation:CGPointMake(0, 0) inView:self.view];
            
            isPictureViewContanerShow = NO;
            
        }
    }
    else
    {
        if (sender.view.center.y >= 160) {
            sender.view.center = CGPointMake(sender.view.center.x, 160);
            [sender setTranslation:CGPointMake(0, 0) inView:self.view];
            
            isPictureViewContanerShow = NO;
        } else if (sender.view.center.y <= -130) {
            sender.view.center = CGPointMake(sender.view.center.x, -130);
            [sender setTranslation:CGPointMake(0, 0) inView:self.view];
            
            //        [self.scrollView setHidden:NO];
            
            isPictureViewContanerShow = YES;
            
        } else {
            [sender setTranslation:CGPointMake(0, 0) inView:self.view];
            
            isPictureViewContanerShow = NO;
            
        }
    }
    
}

- (GettingCoreContent *)content
{
    if(!_content)
       {
           _content = [[GettingCoreContent alloc] init];
       }
    return _content;
}

-(NSString* )findEmail
{
    NSArray *restaurantArray = [[NSArray alloc] initWithArray:[self.content getArrayFromCoreDatainEntetyName:@"Restaurants_translation" withSortDescriptor:@"underbarid"]];
        
    for (int i = 0; i < restaurantArray.count; i++)
    {
        if ([[[restaurantArray objectAtIndex:i] valueForKey:@"idRestaurant"] isEqualToString:[self.content fetchIdRestaurantFromIdMenu:self.product.idMenu]]) {
            _currentEmail = [[restaurantArray objectAtIndex:i] valueForKey:@"metro"];
            break;
        }
    }
    
    return _currentEmail;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self findEmail];
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
        {
            SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            [tweetSheet setInitialText:[NSString stringWithFormat:@"I like %@ from %@",self.product.title, _currentEmail]];
            [tweetSheet addImage:_product.image];
            [self presentViewController:tweetSheet animated:YES completion:nil];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                                message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup"
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }

    }
    if (buttonIndex == 1)
    {
        [self findEmail];
        
        [self performSegueWithIdentifier:@"toLogin" sender:self];
    }
}

#pragma mark UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toLogin"]) {
        FacebookLoginViewController *facebookLoginViewController = segue.destinationViewController;
        facebookLoginViewController.imageLinkLogin = self.product.link;
        facebookLoginViewController.infoLogin = @"I like it in \"Dostavka 33 \"!";
        facebookLoginViewController.linkLogin = _currentEmail;
        facebookLoginViewController.nameLogin = self.product.title;
    }
}

- (GettingCoreContent *)db
{
    if(!_db)
    {
        _db = [[GettingCoreContent alloc] init];
    }
    return  _db;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setAllTitlesOnThisPage];
    self.height = 240;
    self.width = 320;
    self.currentPrice = self.product.price;
    
    if (![self.db isRestaurantCanMakeOrderWithRestaurantID:[self.db fetchIdRestaurantFromIdMenu:self.product.idMenu]])
    {
        self.cartButton.hidden = YES;
        self.countPickerView.hidden = YES;
    }
    
    self.countPickerView.frame = CGRectMake(244, 248, 63, 77);
    self.pictureViewContainer.frame = CGRectMake(0, 0, self.width, self.height);
    
    [self setPriceValueView];
    
    self.imageView.frame = CGRectMake(0, 0, self.pictureButton.frame.size.width, self.pictureButton.frame.size.height);
    
    self.nameLabal.text = self.product.title;
    
    if (self.product.image) {
        
        self.imageView.image = self.product.image;
        [self.pictureButton addSubview:self.imageView];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        self.pictureViewContainer.frame = CGRectMake(0, 0, self.width, self.height);
        [UIView commitAnimations];
        
        [self.scrollView setHidden:NO];

        
    } else {
        if (checkConnection.hasConnectivity) {
            
            self.loadingView = [[SSLoadingView alloc] initWithFrame:CGRectMake(0, 0, 250, 240)];
            self.loadingView.textLabel.text = @"";
            self.loadingView.backgroundColor = [UIColor clearColor];
            self.loadingView.activityIndicatorView.color = [UIColor whiteColor];
            self.loadingView.textLabel.textColor = [UIColor whiteColor];
            [self.pictureButton addSubview:self.loadingView];
        }
    }
    
    if (self.product.hit.integerValue == 1)
    {
        [self.imageView.layer addSublayer:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HIT1.png"]].layer];
    }
    else
        if (self.product.hit.integerValue == 2)
        {
            [self.imageView.layer addSublayer:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"New1.png"]].layer];
        }
    
    
    NSArray *sizesIds = [self.db fetchAllSizeIdWithProductId:self.product.productId];
    self.arrayOfSizes = [self.db fetchArrayOfSizesByIds:sizesIds withDefaultLanguageId:[[NSUserDefaults standardUserDefaults] objectForKey:@"defaultLanguageId"]];
    if (self.product.isMultisize.intValue == 1 )
    {
        if (self.product.sizeId == NULL)
        {
            self.currentSize = [self.arrayOfSizes objectAtIndex:0];
            self.product.sizeId = self.currentSize.sizeId;
        }
        else
        {
            for (int i = 0; i < self.arrayOfSizes.count; i++) {
                if ([self.product.sizeId isEqual: [[self.arrayOfSizes objectAtIndex:i] valueForKey:@"sizeId"]])
                {
                    self.currentSize = [self.arrayOfSizes objectAtIndex:i];
                }
            }
        }
        [self.sizeButton setTitle:self.currentSize.name forState:UIControlStateNormal];
        self.sizeButton.hidden = NO;
    }
    else
    {
        self.sizeButton.hidden = YES;
    }
    self.ingredients = [[NSMutableArray alloc] init];
    if(!self.isFromCart)
    {
        NSArray *ingredientsId = [self.db fetchAllIngredientsIdWithProductId:self.product.productId fromEntity:@"Toppings"];
    self.ingredients = [self.db fetchArrayOfIngredientsByIds:ingredientsId withDefaultLanguageId:[[NSUserDefaults standardUserDefaults] objectForKey:@"defaultLanguageId"]].mutableCopy;
        NSArray *defaultIngredients = [self.db fetchAllDefaultIngredientsIdWithProductId:self.product.productId];
        for (int i = 0 ; i < self.ingredients.count; i++)
        {
            IngredientDataStruct *ingredient = [self.ingredients objectAtIndex:i];
            for (int j = 0; j < defaultIngredients.count; j++)
            {
                if ([ingredient.ingredientId isEqual: [[defaultIngredients objectAtIndex:j] valueForKey:@"idIngredient"]])
                {
                    ingredient.isInCurrentProduct = YES;
                    [self.ingredients removeObject:ingredient];
                    [self.ingredients insertObject:ingredient atIndex:0];
                    
                }
            }
        }
    }
    else
    {
        NSArray *ingredientsId = [self.db fetchAllIngredientsIdWithProductId:self.product.productId fromEntity:@"Cart_Products_Ingredients"];
        NSArray *allToppingIngredients = [self.db fetchAllIngredientsIdWithProductId:self.product.productId fromEntity:@"Toppings"];
        self.ingredients = [self.db fetchArrayOfIngredientsByIds:allToppingIngredients withDefaultLanguageId:[[NSUserDefaults standardUserDefaults] objectForKey:@"defaultLanguageId"]].mutableCopy;
        for (int i = 0; i<self.ingredients.count; i++)
        {
            IngredientDataStruct *ingredient = [self.ingredients objectAtIndex:i];
            NSLog(@"%@",ingredient.ingredientId);
            for (int j =0; j<ingredientsId.count; j++) {
                NSNumber *ingrId = [ingredientsId objectAtIndex:j];
                if ([ingredient.ingredientId isEqual: ingrId]) {
                    ingredient.isInCurrentProduct = YES;
                    [self.ingredients removeObject:ingredient];
                    [self.ingredients insertObject:ingredient atIndex:0];
                    break;
                }
                else
                {
                    ingredient.isInCurrentProduct = NO;
                }
            }
        }
        
        [self.countPickerView selectRow: self.product.count.integerValue inComponent:0 animated:NO];
    }
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor], (id)[[UIColor darkGrayColor] CGColor],(id)[[UIColor blackColor] CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    if(self.product.isFavorites.boolValue)
    {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    }
    
    if ([[UIScreen mainScreen] bounds].size.height == 568)
    {        
        [self.pictureViewContainer setFrame:CGRectMake(self.pictureViewContainer.frame.origin.x, self.pictureViewContainer.frame.origin.y, self.pictureViewContainer.frame.size.width, 320)];

        [self.pictureButton setFrame:CGRectMake(0, 0, 320, 320)];
        
        [self.imageView setFrame:self.pictureButton.frame];
        
        [self.tableViewIngredients setFrame:CGRectMake(self.tableViewIngredients.frame.origin.x, self.tableViewIngredients.frame.origin.y, self.tableViewIngredients.frame.size.width, 334)];
        
        [self.nameLabal setFrame:CGRectMake(self.nameLabal.frame.origin.x, self.nameLabal.frame.origin.y + 88, self.nameLabal.frame.size.width, self.nameLabal.frame.size.height)];
        
        [self.priceView setFrame:CGRectMake(self.priceView.frame.origin.x, self.priceView.frame.origin.y + 88, self.priceView.frame.size.width, self.priceView.frame.size.height)];
        
        [self.sizeButton setFrame:CGRectMake(self.sizeButton.frame.origin.x, self.sizeButton.frame.origin.y + 88, self.sizeButton.frame.size.width, self.sizeButton.frame.size.height)];
        
        [self.cartButton setFrame:CGRectMake(self.cartButton.frame.origin.x, self.cartButton.frame.origin.y + 88, self.cartButton.frame.size.width, self.cartButton.frame.size.height)];
        
        [self.shareButton setFrame:CGRectMake(self.shareButton.frame.origin.x, self.shareButton.frame.origin.y + 88, self.shareButton.frame.size.width, self.shareButton.frame.size.height)];
        
        [self.countPickerView setFrame:CGRectMake(self.countPickerView.frame.origin.x, self.countPickerView.frame.origin.y + 88, self.countPickerView.frame.size.width, self.countPickerView.frame.size.height)];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) viewDidAppear:(BOOL)animated
{
    if (!self.product.image && isDownloadingPicture == NO && checkConnection.hasConnectivity)
    {
        isDownloadingPicture = YES;
        NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:self.product.idPicture,@"pictureId",self.imageView,@"imageView",self.loadingView,@"loadView", nil];
        [self.scrollView setHidden:NO];
        [self performSelectorInBackground:@selector(downloadingPicWithParams:) withObject:params];
    }
}

- (void)downloadingPicWithParams:(NSDictionary *)params
{
    NSLog(@"start downloading");
    NSString *pictureId = [params objectForKey:@"pictureId"];
    UIImageView *imageView = [params objectForKey:@"imageView"];
    SSLoadingView *loadView = [params objectForKey:@"loadView"];
    NSURL *url = [self.db fetchImageURLbyPictureID:pictureId];
    NSData *dataOfPicture = [NSData dataWithContentsOfURL:url];
    [self.db SavePictureToCoreData:pictureId toData:dataOfPicture];
    imageView.image = [UIImage imageWithData:dataOfPicture];
    [loadView removeFromSuperview];
    [imageView reloadInputViews];
    NSLog(@"finish downloading");
}

//- (void)downloadingPic
//{
//    NSURL *url = [self.db fetchImageURLbyPictureID:self.product.idPicture];
//    NSData *dataOfPicture = [NSData dataWithContentsOfURL:url];
//    [self.db SavePictureToCoreData:self.product.idPicture toData:dataOfPicture];
//    self.product.image  = [UIImage imageWithData:dataOfPicture];
//    self.imageView.image = self.product.image;
//    [self.loadingView removeFromSuperview];
//    [self.imageView reloadInputViews];
//    
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:0.3];
//    self.pictureViewContainer.frame = CGRectMake(0, 0, self.width, self.height);
//    [UIView commitAnimations];
//    
//    [self.scrollView setHidden:NO];
//}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)addToCart:(id)sender {
    
    if (self.product.count.intValue == 0)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:[NSString stringWithFormat:self.titleDoYouWantDeleteItemFromCart, self.product.title]
                                                       delegate:self
                                              cancelButtonTitle:self.titleYES
                                              otherButtonTitles:self.titleNO, nil];
        [alert show];
        isDeletingFromCart = YES;
        
    }
    else
    {
        [self.db SaveProductToEntityName:@"Cart" WithId:self.product.productId
                               withCount:self.product.count.integerValue
                                withSizeId:self.product.sizeId
                               withPrice:self.currentPrice.floatValue
                             withPicture:UIImagePNGRepresentation(self.product.image)
                       withDiscountValue:self.product.discountValue.floatValue
                              withWeight:self.product.weight
                             withProtein:self.product.protein withCarbs:self.product.carbs
                                withFats:self.product.fats
                            withCalories:self.product.calories
                             isFavorites:self.product.isFavorites.boolValue
                               isTopping:self.product.isTopping.boolValue
                             isMultisize:self.product.isMultisize.boolValue
                                   isHit:NO
                              withIdMenu:self.product.idMenu];
        
        [self.db deleteIngredientByProductId:self.product.productId];
        
        for (int i = 0; i<self.ingredients.count; i++)
        {
            IngredientDataStruct *ingredient = [self.ingredients objectAtIndex:i];
            if (ingredient.isInCurrentProduct)
            {
                [self.db SaveProduct:self.product.productId withIngredient:ingredient.ingredientId];
            }
        }
        
        self.alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:self.titleAddetItemToTheCart,self.product.count.integerValue, self.product.title] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [self. alert show];
        [self performSelector:@selector(dismiss) withObject:nil afterDelay:2];
        [[self navigationController] popViewControllerAnimated:YES];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0 && isDeletingFromCart == YES)
    {
        [self.db deleteObjectFromEntity:@"Cart" withProductId:self.product.productId];
        NSLog(@"deleted");
        [self.navigationController popViewControllerAnimated:NO];
    }
}

- (IBAction)AddToFavorites:(id)sender
{
    // add to favorites here
    id currentOne = self.product;
    //changing is database
    [self.db changeFavoritesBoolValue:![[currentOne isFavorites] boolValue] forId:[currentOne productId]];
    //changing in Array
    [currentOne setIsFavorites:[NSNumber numberWithBool:![[currentOne isFavorites] boolValue]]];
    
    if ([currentOne isFavorites].boolValue)
    {
        self.alert = [[UIAlertView alloc] initWithTitle:nil
                                                message:[NSString stringWithFormat:@"Added \"%@\" to favorites.", [currentOne title]]
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
    }
    else
    {
        self.alert = [[UIAlertView alloc] initWithTitle:nil
                                                message:[NSString stringWithFormat:@"Removed \"%@\" from favorites.", [currentOne title]]
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
    }
    
    [self.alert show];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:2];

}

- (void) dismiss
{
    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
    [self setAlert:nil]; 
}



- (void)viewDidUnload
{
    [self setCountPickerView:nil];
    [self setPriceView:nil];
    [self setCartButton:nil];
    [self setShareButton:nil];
    [self setNameLabal:nil];
    [self setAlert:nil];
    
    [self setLoadingView:nil];
    [self setDb:nil];
    [self setProduct:nil];

    [self setPictureViewContainer:nil];
    [self setPictureButton:nil];
    [self setImageView:nil];
    [self setScrollView:nil];
    [self setCaptionLabel:nil];
    [self setNilCaption:nil];
    [self setProteinLabel:nil];
    [self setFatLabel:nil];
    [self setCarbohydratesLabel:nil];
    [self setKCalLabel:nil];
    [self setPortionLabel:nil];
    [self setPortionProteinLabel:nil];
    [self setPortionFatLabel:nil];
    [self setPortionCarbohydratesLabel:nil];
    [self setPortionKCalLabel:nil];
    [self setIn100gLabel:nil];
    [self setIn100gProteinLabel:nil];
    [self setIn100gFatLabel:nil];
    [self setIn100gCarbohydratesLabel:nil];
    [self setIn100gKCalLabel:nil];
    [self setDescriptionLabel:nil];
    [self setWeightLabel:nil];
    [self setFavoritesButton:nil];
    [self setPriceView:nil];
    [self setTableViewIngredients:nil];
    [self setSizeButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
        if (self.labelString)
            return 21;
        else
            return 20;

}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *rowNumber;
    if (self.labelString)
    {
        rowNumber = [[NSString alloc] initWithFormat:@"%i", row];
    }
    else
    {
        rowNumber = [[NSString alloc] initWithFormat:@"%i", row+1];
    }
    return rowNumber;

}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(pickerView == self.countPickerView)
    {
    if (self.labelString)
        self.product.count = [NSNumber numberWithInt:row];
    else 
        self.product.count = [NSNumber numberWithInt:row+1];
    }
}

#pragma mark TableViewDelegates
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableViewIngredients)
    {
        if (indexPath.section == 0)
        {
            return 180;
        }
        else
        {
            return 70;
        }
    }
    else if(tableView == self.sizeTableView)
    {
        return 30;
    }
    else
    {
        return 50;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView ==self.tableViewIngredients)
    {
        if (section == 0)
        {
            return 1;
        }
        else
        {
            return self.ingredients.count;
        }
    }
    else if(tableView == self.sizeTableView)
    {
        return self.arrayOfSizes.count;
    }
    else
    {
        return 10;
    }
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.tableViewIngredients)
    {
//    if (!self.product.isTopping)
//    {
//        return 1;
//    }
//    else
        return 2;
    }
    else if(tableView == self.sizeTableView)
    {
        return 1;
    }
    else
    {
        return 1;
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableViewIngredients)
    {
        cell.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.1];
    }
    if (tableView == self.sizeTableView)
    {
        cell.textLabel.font = [UIFont systemFontOfSize:14];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableViewIngredients)
    {
        if(indexPath.section == 0)
        {
            NSString *CellIdentifier = @"ProductDescriptionCell";
            ProductDescriptionCell *cell = (ProductDescriptionCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if(!cell)
            {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ProductDescriptionCell" owner:nil options:nil];
                for(id currentObject in topLevelObjects)
                {
                    if([currentObject isKindOfClass:[ProductDescriptionCell class]])
                    {
                        cell = (ProductDescriptionCell *)currentObject;
                        
                        break;
                    }
                }
                
                cell.portionProteinLabel.text = [NSString stringWithFormat:@"%5.1f", ((self.product.weight.floatValue * self.product.protein.floatValue) / 100)];
                cell.portionFatLabel.text = [NSString stringWithFormat:@"%5.1f", ((self.product.weight.floatValue * self.product.fats.floatValue) / 100)];
                cell.portionCarbohydratesLabel.text = [NSString stringWithFormat:@"%5.1f", ((self.product.weight.floatValue * self.product.carbs.floatValue) / 100)];
                cell.portionKCalLabel.text = [NSString stringWithFormat:@"%5.1f", ((self.product.weight.floatValue * self.product.calories.floatValue) / 100)];
                
                cell.in100gProteinLabel.text = [NSString stringWithFormat:@"%@",self.product.protein];
                cell.in100gFatLabel.text = [NSString stringWithFormat:@"%@",self.product.fats];
                cell.in100gCarbohydratesLabel.text = [NSString stringWithFormat:@"%@",self.product.carbs];
                cell.in100gKCalLabel.text = [NSString stringWithFormat:@"%@",self.product.calories];
                
                cell.weightLabel.text = [NSString stringWithFormat:@"%@%@%@%@",cell.weightLabel.text, @" ", self.product.weight, @" g"];
                
                cell.descriptionLabel.text = self.product.descriptionText;
            }
            return cell;
        }
        else
        {
            IngredientDataStruct *ingredient = [self.ingredients objectAtIndex:indexPath.row];
            NSString *CellIdentifier = @"IngredientCell";
            IngredientCell *cell = (IngredientCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if(!cell)
            {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"IngredientCell" owner:nil options:nil];
                for(id currentObject in topLevelObjects)
                {
                    if([currentObject isKindOfClass:[IngredientCell class]])
                    {
                        cell = (IngredientCell *)currentObject;
                        
                        break;
                    }
                }
            }
            cell.addButton.tag = indexPath.row;
            [cell.addButton addTarget:self action:@selector(addButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            cell.ingredientName.text = ingredient.name;
            //cell.ingredientImageView.image = ingredient.image;
            
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            formatter.roundingIncrement = [NSNumber numberWithDouble:0.01];
            formatter.numberStyle = NSNumberFormatterDecimalStyle;
            NSString *price = [formatter stringFromNumber:[NSNumber numberWithFloat:(ingredient.price.floatValue * [[[NSUserDefaults standardUserDefaults] objectForKey:@"CurrencyCoefficient"] floatValue])]];
            NSString *priceString = [NSString stringWithFormat:@"%@ %@", price, [[NSUserDefaults standardUserDefaults] objectForKey:@"Currency"]];
            cell.ingredientPrice.text = priceString;
            
            cell.ingredientImageView.image = ingredient.image;
            //        if (!ingredient.image && checkConnection.hasConnectivity)
            //        {
            //            NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:ingredient.idPicrure,@"pictureId",cell.ingredientImageView,@"imageView", nil];
            //            [self performSelectorInBackground:@selector(downloadingPicWithParams:) withObject:params];
            //        }
            cell.isAdded = ingredient.isInCurrentProduct;
            if (cell.isAdded)
            {
                [cell.addButton setBackgroundImage:[UIImage imageNamed:@"Checkbox_checked_40px.png"] forState:UIControlStateNormal];
            }
            return cell;
        }
    }
    else
    {
        NSString * CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        SizeStruct *size = [self.arrayOfSizes objectAtIndex: indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@",size.name];
        cell.tag = size.sizeId.integerValue;
        return cell;
    }
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    for (int i= 0 ; i<self.arrayOfSizes.count; i++)
    {
        SizeStruct *size = [self.arrayOfSizes objectAtIndex:i];
        if ( size.sizeId.integerValue == cell.tag)
        {
            self.currentSize = size;
        }
    }
    self.product.sizeId = self.currentSize.sizeId;
    [self.sizeButton setTitle:self.currentSize.name forState:UIControlStateNormal];
    self.popupView.hidden = YES;
}

#pragma mark
#pragma mark PRIVATE METHODS

-(void)setPriceValueView //using datastruct!!
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.roundingIncrement = [NSNumber numberWithDouble:0.01];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    
    NSString *price = [formatter stringFromNumber:[NSNumber numberWithFloat:(self.currentPrice.floatValue * [[[NSUserDefaults standardUserDefaults] objectForKey:@"CurrencyCoefficient"] floatValue])]];
    NSString *priceString = [NSString stringWithFormat:@"%@ %@", price, [[NSUserDefaults standardUserDefaults] objectForKey:@"Currency"]];
    
    NSArray *discountsArray = [self.db getArrayFromCoreDatainEntetyName:@"Discounts" withSortDescriptor:@"underbarid"];
    if (self.product.discountValue.floatValue >= 1)
    {
        for (int i = 0; i < discountsArray.count; i++)
        {
            if ([[[[discountsArray objectAtIndex:i] valueForKey:@"underbarid"] description] isEqual:self.product.discountValue])
            {
                self.product.discountValue = [[discountsArray objectAtIndex:i] valueForKey:@"value"];
                if ([[[[discountsArray objectAtIndex:i] valueForKey:@"value"] description] isEqual:@"0"])
                {
                    break;
                }
                else
                {
                    priceString = [NSString stringWithFormat:@"(<strike style=\"color:White;\">%@</strike>) %@ %@", price, [formatter stringFromNumber:[NSNumber numberWithFloat:(self.currentPrice.floatValue * (1 - self.product.discountValue.floatValue) * [[[NSUserDefaults standardUserDefaults] objectForKey:@"CurrencyCoefficient"] floatValue])]], [[NSUserDefaults standardUserDefaults] objectForKey:@"Currency"]];
                }
                break;
            }
        }
    }
    else
    {
        if (self.product.discountValue.floatValue != 0)
            priceString = [NSString stringWithFormat:@"(<strike style=\"color:White;\">%@</strike>) %@ %@", price, [formatter stringFromNumber:[NSNumber numberWithFloat:(self.currentPrice.floatValue * (1 - self.product.discountValue.floatValue) * [[[NSUserDefaults standardUserDefaults] objectForKey:@"CurrencyCoefficient"] floatValue])]], [[NSUserDefaults standardUserDefaults] objectForKey:@"Currency"]];
    }
    
    //self.priceLabel.text = priceString;
    NSString* htmlContentString = [NSString stringWithFormat:
                                   @"<html>"
                                   "<body style=\"font-family:Helvetica; font-size:14px;color:#FF7F00;text-align:left;\">"
                                   "<p>%@</p>"
                                   "</body></html>", priceString];
    
    self.priceView.opaque = NO;
    self.priceView.backgroundColor = [UIColor clearColor];
    [self.priceView loadHTMLString:htmlContentString baseURL:nil];
}

-(void)addButtonClicked: (UIButton *)sender
{
    IngredientDataStruct *currentIngredient = [self.ingredients objectAtIndex:sender.tag];
    if (currentIngredient.isInCurrentProduct) {
        currentIngredient.isInCurrentProduct = NO;
        self.currentPrice = [NSString stringWithFormat:@"%f", (self.currentPrice.floatValue - currentIngredient.price.floatValue)];
        [self setPriceValueView];
    }
    else
    {
        currentIngredient.isInCurrentProduct = YES;
        self.currentPrice = [NSString stringWithFormat:@"%f", (self.currentPrice.floatValue + currentIngredient.price.floatValue)];
        [self setPriceValueView];
    }
}

-(void)setAllTitlesOnThisPage
{
    NSArray *array = [Singleton titlesTranslation_withISfromSettings:NO];
    for (int i = 0; i <array.count; i++)
    {
        if ([[[array objectAtIndex:i] valueForKey:@"name_EN"] isEqualToString:@"the nutritional values"])
        {
            self.captionLabel.text = [[array objectAtIndex:i] valueForKey:@"title"];
        }
        
        else if ([[[array objectAtIndex:i] valueForKey:@"name_EN"] isEqualToString:@"portion"])
        {
            self.portionLabel.text = [[array objectAtIndex:i] valueForKey:@"title"];
        }
        
        else if ([[[array objectAtIndex:i] valueForKey:@"name_EN"] isEqualToString:@"protein"])
        {
            self.proteinLabel.text = [[array objectAtIndex:i] valueForKey:@"title"];
        }
        
        else if ([[[array objectAtIndex:i] valueForKey:@"name_EN"] isEqualToString:@"in 100g"])
        {
            self.in100gLabel.text = [[array objectAtIndex:i] valueForKey:@"title"];
        }
        
        else if ([[[array objectAtIndex:i] valueForKey:@"name_EN"] isEqualToString:@"fat"])
        {
            self.fatLabel.text = [[array objectAtIndex:i] valueForKey:@"title"];
        }
        
        else if ([[[array objectAtIndex:i] valueForKey:@"name_EN"] isEqualToString:@"carbohydrate"])
        {
            self.carbohydratesLabel.text = [[array objectAtIndex:i] valueForKey:@"title"];
        }
        
        else if ([[[array objectAtIndex:i] valueForKey:@"name_EN"] isEqualToString:@"Weight"])
        {
            self.weightLabel.text = [[array objectAtIndex:i] valueForKey:@"title"];
        }
        
        else if ([[[array objectAtIndex:i] valueForKey:@"name_EN"] isEqualToString:@"Add favorites"])
        {
            self.favoritesButton.title = [[array objectAtIndex:i] valueForKey:@"title"];
        }
        
        else if (!self.labelString && [[[array objectAtIndex:i] valueForKey:@"name_EN"] isEqualToString:@"Add to Cart"])
        {
            [self.cartButton setTitle:[[array objectAtIndex:i] valueForKey:@"title"] forState:UIControlStateNormal];
        }
        
        else if (self.labelString && [[[array objectAtIndex:i] valueForKey:@"name_EN"] isEqualToString:@"Change"])
        {
            [self.cartButton setTitle:[[array objectAtIndex:i] valueForKey:@"title"] forState:UIControlStateNormal];
        }
        
        else if ([[[array objectAtIndex:i] valueForKey:@"name_EN"] isEqualToString:@"Share"])
        {
            [self.shareButton setTitle:[[array objectAtIndex:i] valueForKey:@"title"] forState:UIControlStateNormal];
        }
        
        else if ([[[array objectAtIndex:i] valueForKey:@"name_EN"] isEqualToString:@"with discount"])
        {
            self.titleWihtDiscounts = [[array objectAtIndex:i] valueForKey:@"title"];
        }

        else if ([[[array objectAtIndex:i] valueForKey:@"name_EN"] isEqualToString:@"Cancel"])
        {
            self.titleCancel = [[array objectAtIndex:i] valueForKey:@"title"];
        }
        
        else if ([[[array objectAtIndex:i] valueForKey:@"name_EN"] isEqualToString:@"Added %i item(s) %@ to the Cart."])
        {
            self.titleAddetItemToTheCart = [[array objectAtIndex:i] valueForKey:@"title"];
        }
        
        else if ([[[array objectAtIndex:i] valueForKey:@"name_EN"] isEqualToString:@"Do you want to delete item %@"])
        {
            self.titleDoYouWantDeleteItemFromCart = [[array objectAtIndex:i] valueForKey:@"title"];
        }
    
        else if ([[[array objectAtIndex:i] valueForKey:@"name_EN"] isEqualToString:@"YES"])
        {
            self.titleYES = [[array objectAtIndex:i] valueForKey:@"title"];
        }
        else if ([[[array objectAtIndex:i] valueForKey:@"name_EN"] isEqualToString:@"NO"])
        {
            self.titleNO = [[array objectAtIndex:i] valueForKey:@"title"];
        }
        
        else if ([[[array objectAtIndex:i] valueForKey:@"name_EN"] isEqualToString:@"Loading..."])
        {
            self.loadingView.textLabel.text = [[array objectAtIndex:i] valueForKey:@"title"];
        }
    }
}


@end
