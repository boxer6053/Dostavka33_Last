//
//  DeliveryViewController.m
//  Restaurant
//
//  Created by Matrix Soft on 6/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DeliveryViewController.h"
#import "JSONKit.h"

@interface DeliveryViewController ()
{
    int currentAddressIndex;
}

@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;
@property (strong, nonatomic) UITextField *textFieldForFeils;
@property (strong, nonatomic) NSMutableData *responseData;
@property (strong, nonatomic) NSMutableString *ids;
@property (strong, nonatomic) NSMutableString *counts;
@property (strong, nonatomic) SSHUDView *hudView;
@property (strong, nonatomic) NSString *dateString;

//titles
@property (strong, nonatomic) NSString *titleThankYouForOrder;
@property (strong, nonatomic) NSString *titleOurOperatorWillCallYou;
@property (strong, nonatomic) NSString *titleError;
@property (strong, nonatomic) NSString *titleCanNotAccessToServer;
@property (strong, nonatomic) NSString *titlePleaseTryAgain;
@property (strong, nonatomic) NSString *titleEnterJustNombers;
@property (strong, nonatomic) NSString *titleWrongTime;
@property (strong, nonatomic) NSString *titleDontRichMinimumPrice;
@property (strong, nonatomic) NSString *titleIncorectPhoneNumber;

@end

@implementation DeliveryViewController {
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
}

@synthesize scrollView;
@synthesize addressName;
@synthesize customerName;
@synthesize phone;
@synthesize CityName;
//@synthesize metroName;
@synthesize street;
@synthesize build;
@synthesize appartaments;
@synthesize otherInformation;
@synthesize deliveryTime;
//@synthesize access;
//@synthesize intercom;
//@synthesize floor;
@synthesize dictionary = _dictionary;
@synthesize historyDictionary =_historyDictionary;
@synthesize hudView;

@synthesize tapRecognizer = _tapRecognizer;
@synthesize textFieldForFeils = _textFieldForFeils;
@synthesize responseData = _responseData;
@synthesize content = _content;
@synthesize enableTime = _enableTime;
@synthesize pickerViewContainer;
@synthesize db = _db;
@synthesize dateString = _dateString;
@synthesize locationCity = _locationCity;
@synthesize locationStreet = _locationStreet;

//titles
@synthesize titleThankYouForOrder = _titleThankYouForOrder;
@synthesize titleOurOperatorWillCallYou = _titleOurOperatorWillCallYou;
@synthesize titleError = _titleError;
@synthesize titleCanNotAccessToServer = _titleCanNotAccessToServer;
@synthesize titlePleaseTryAgain = _titlePleaseTryAgain;
@synthesize titleWrongTime = _titleWrongTime;
@synthesize titleEnterJustNombers = _titleEnterJustNombers;
@synthesize titleDontRichMinimumPrice = _titleDontRichMinimumPrice;
@synthesize titleIncorectPhoneNumber = _titleIncorectPhoneNumber;

- (GettingCoreContent *)content
{
    if(!_content)
    {
        _content = [[GettingCoreContent alloc] init];
    }
    return  _content;
}

///////////////////////////////////////////////
#pragma mark
#pragma mark AddressListDelegate methods
///////////////////////////////////////////////

- (void) setAddressDictionary:(NSDictionary *)dictionary
{
    self.dictionary = [[NSDictionary dictionaryWithDictionary:dictionary] mutableCopy];
    
    self.addressName.text = [self.dictionary objectForKey:@"name"];
    self.customerName.text = [self.dictionary objectForKey:@"username"];
    self.phone.text = [self.dictionary objectForKey:@"phone"];
    self.CityName.text = [self.dictionary objectForKey:@"city"];
    self.street.text = [self.dictionary objectForKey:@"street"];
    self.build.text =  [self.dictionary objectForKey:@"house"];
    self.appartaments.text = [self.dictionary objectForKey:@"room_office"];
    //    self.metroName.text = [self.dictionary objectForKey:@"metro"];
    //    self.floor.text = [self.dictionary objectForKey:@"floor"];
    //    self.intercom.text = [self.dictionary objectForKey:@"intercom"];
    //    self.access.text = [self.dictionary objectForKey:@"access"];
    self.otherInformation.text = [self.dictionary objectForKey:@"additional_info"];
    //    self.deliveryTime.text = [self.dictionary objectForKey:@"deliveryTime"];
    
    self.dictionary = nil;
}

///////////////////////////////////////////////
#pragma mark
#pragma mark LOADS methods
///////////////////////////////////////////////

-(void)viewWillAppear:(BOOL)animated
{
    NSArray *arrayOfAddresses = [self.content getArrayFromCoreDatainEntetyName:@"Addresses" withSortDescriptor:@"name"];
    if (arrayOfAddresses.count != 0)
    {
        //[self performSelector:@selector(showListOfAddresses:) withObject:nil];
        [self performSegueWithIdentifier:@"toAddressList" sender:self];
    }
}

- (NSString *)getCurrentCityName
{
    NSArray *citiesTranslation = [[NSArray alloc] initWithArray:[self.content getArrayFromCoreDatainEntetyName:@"Cities_translation" withSortDescriptor:@"underbarid"]];
    
    for (int i = 0; i < citiesTranslation.count; i++) {
        NSString *idCity = [NSString stringWithFormat:@"%@", [[citiesTranslation objectAtIndex:i] valueForKey:@"idCity"]];
        NSString *defaultCityId = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"defaultCityId"]];
        if ([idCity isEqualToString:defaultCityId]) {
            NSString *idLanguage = [NSString stringWithFormat:@"%@", [[citiesTranslation objectAtIndex:i] valueForKey:@"idLanguage"]];
            NSString *defaultLanguageId = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"defaultLanguageId"]];
            if ([idLanguage isEqualToString:defaultLanguageId]) {
                return [[citiesTranslation objectAtIndex:i] valueForKey:@"name"];
            }
        }
    }
    
    return nil;
}

- (void)getCurrentLocation
{
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        //        self.longtitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        //        self.latitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
    }
    
    // Stop Location Manager
    [locationManager stopUpdatingLocation];
    
    // Reverse Geocoding
    NSLog(@"Resolving the Address");
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            //            self.addressLabel.text = [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
            //                                      placemark.subThoroughfare, placemark.thoroughfare,
            //                                      placemark.postalCode, placemark.locality,
            //                                      placemark.administrativeArea,
            //                                      placemark.country];
            
            //            self.subThoroughfare = [NSString stringWithString:placemark.subThoroughfare];
            self.street.text = [NSString stringWithString:placemark.thoroughfare];
            //            self.postalCode = [NSString stringWithString:placemark.postalCode];
            self.CityName.text = [NSString stringWithString:placemark.locality];
            //            self.administrativeArea = [NSString stringWithString:placemark.administrativeArea];
            //            self.country = [NSString stringWithString:placemark.country];
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    } ];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    
    [self getCurrentLocation];
    
    //    GettingLocationInfo *localInfo = [[GettingLocationInfo alloc] init];
    //    [localInfo findLocation];
    //
    //    NSString *street = [localInfo thoroughfare];
    //    NSString *city = [localInfo locality];
    
    //    NSString *cityName = [self getCurrentCityName];
    //    self.CityName.text = cityName;
    
    CAGradientLayer *mainGradient = [CAGradientLayer layer];
    mainGradient.frame = self.scrollView.bounds;
    mainGradient.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor], (id)[[UIColor darkGrayColor] CGColor],(id)[[UIColor blackColor] CGColor], nil];
    [self.scrollView.layer insertSublayer:mainGradient atIndex:0];
    
    [self setAllTitlesOnThisPage];
	
    self.scrollView.contentSize = CGSizeMake(320, 430);
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self selector:@selector(keyboardWillShow:) name:
     UIKeyboardWillShowNotification object:nil];
    
    [nc addObserver:self selector:@selector(keyboardWillHide:) name:
     UIKeyboardWillHideNotification object:nil];
    
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                 action:@selector(didTapAnywhere:)];
    if ([[UIScreen mainScreen] bounds].size.height == 568)
    {
        
        [self.toOrderButton setFrame:CGRectMake(self.toOrderButton.frame.origin.x, 440, self.toOrderButton.frame.size.width, self.toOrderButton.frame.size.height)];
        [self.saveAddressButton setFrame:CGRectMake(self.saveAddressButton.frame.origin.x, 440, self.saveAddressButton.frame.size.width, self.saveAddressButton.frame.size.height)];
        
    }
    //перевіряєм чи доставка по часу
    if (!self.enableTime)
    {
        [self.deliveryTime setHidden:YES];
    }
    else
    {
        //        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"TimePicker" owner:nil options:nil];
        //        for(id currentObject in topLevelObjects)
        //        {
        //            if([currentObject isKindOfClass:[TimePicker class]])
        //            {
        //                self.pickerViewContainer = (TimePicker *)currentObject;
        //                break;
        //            }
        //        }
        //        self.pickerViewContainer.frame = CGRectMake(0, 590, 320, 260);
        //        [self.pickerViewContainer.okButton setTarget:self];
        //        [self.pickerViewContainer.okButton setAction:@selector(okButton)];
        //
        //        [self.pickerViewContainer.hideButton setTarget:self];
        //        [self.pickerViewContainer.hideButton setAction:@selector(hideButton)];
    }
}

- (void)viewDidUnload
{
    [self setAddressName:nil];
    [self setCustomerName:nil];
    [self setPhone:nil];
    [self setCityName:nil];
    //    [self setMetroName:nil];
    [self setStreet:nil];
    [self setBuild:nil];
    [self setAppartaments:nil];
    [self setOtherInformation:nil];
    [self setScrollView:nil];
    //    [self setFloor:nil];
    //    [self setAccess:nil];
    //    [self setIntercom:nil];
    [self setDeliveryTime:nil];
    [self setToOrderButton:nil];
    [self setSaveAddressButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

///////////////////////////////////////////////
#pragma mark
#pragma mark TextFields and keyboards features
///////////////////////////////////////////////

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
    [theTextField resignFirstResponder];
    self.scrollView.contentSize = CGSizeMake(320, 430);
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.deliveryTime)
    {
        [self.addressName resignFirstResponder];
        [self.customerName resignFirstResponder];
        [self.phone resignFirstResponder];
        [self.CityName resignFirstResponder];
        [self.street resignFirstResponder];
        [self.build resignFirstResponder];
        [self.appartaments resignFirstResponder];
        [self.otherInformation resignFirstResponder];
        
        self.scrollView.contentSize = CGSizeMake(320, 590);
        CGFloat tempy = self.scrollView.contentSize.height;//imageView.frame.size.height;
        CGFloat tempx = self.scrollView.contentSize.width;;
        CGRect zoomRect = CGRectMake((tempx/2), (tempy/2), tempy, tempx);
        [self.scrollView scrollRectToVisible:zoomRect animated:YES];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        if (pickerViewContainer == nil)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"TimePicker" owner:nil options:nil];
            for(id currentObject in topLevelObjects)
            {
                if([currentObject isKindOfClass:[TimePicker class]])
                {
                    self.pickerViewContainer = (TimePicker *)currentObject;
                    break;
                }
            }
            self.pickerViewContainer.frame = CGRectMake(0, 590, 320, 260);
            [self.pickerViewContainer.okButton setTarget:self];
            [self.pickerViewContainer.okButton setAction:@selector(okButton)];
            
            [self.pickerViewContainer.hideButton setTarget:self];
            [self.pickerViewContainer.hideButton setAction:@selector(hideButton)];
            
            NSTimeInterval twoHours = 2 * 60 * 60;
            NSDate *date = [[self.pickerViewContainer.datePicker date] dateByAddingTimeInterval:twoHours];
            [self.pickerViewContainer.datePicker setMinimumDate:date];
            
            //            [self.view addSubview:self.pickerViewContainer];
        }
        
        self.pickerViewContainer.frame = CGRectMake(0, 330, 320, 260);
        [self.view addSubview:self.pickerViewContainer];
        [UIView commitAnimations];
        
        //        [self.view addGestureRecognizer:self.tapRecognizer];
        return NO;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.textFieldForFeils)
    {
        [self.textFieldForFeils becomeFirstResponder];
        self.textFieldForFeils = nil;
    }
    
    if (textField == self.appartaments || textField == self.build || textField == self.street || textField == self.otherInformation)
    {
        self.scrollView.contentSize = CGSizeMake(320, 590);
        CGFloat tempy = self.scrollView.contentSize.height;//imageView.frame.size.height;
        CGFloat tempx = self.scrollView.contentSize.width;;
        CGRect zoomRect = CGRectMake((tempx/2), (tempy/2), tempy, tempx);
        [self.scrollView scrollRectToVisible:zoomRect animated:YES];
    }
    else
    {
        //        self.scrollView.contentSize = CGSizeMake(320, 430);
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.phone || textField == self.build || textField == self.appartaments)
    {
        if (![textField.text isEqual:@""])
            if (![[NSScanner scannerWithString:textField.text] scanInteger:nil])
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:self.titleEnterJustNombers message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
                textField.text = nil;
                //[textField becomeFirstResponder];
                self.textFieldForFeils = textField;
            }
    }
    
    //    if (textField == self.appartaments || textField == self.build || textField == self.street || textField == self.otherInformation || textField == self.deliveryTime)
    //    {
    ////        self.scrollView.contentSize = CGSizeMake(320, 430);
    //    }
}

-(void) keyboardWillShow:(NSNotification *) note
{
    if (self.scrollView.contentSize.height != 590)
    {
        self.scrollView.contentSize = CGSizeMake(320, 590);
    }
    
    if ([self.appartaments isEditing] || [self.build isEditing] || [self.street isEditing] || [self.otherInformation isEditing])
    {
        //        self.scrollView.contentSize = CGSizeMake(320, 590);
        CGFloat tempy = self.scrollView.contentSize.height;//imageView.frame.size.height;
        CGFloat tempx = self.scrollView.contentSize.width;;
        CGRect zoomRect = CGRectMake((tempx/2), (tempy/2), tempy, tempx);
        [self.scrollView scrollRectToVisible:zoomRect animated:YES];
    }
    [self.view addGestureRecognizer:self.tapRecognizer];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    self.pickerViewContainer.frame = CGRectMake(0, 590, 320, 260);
    [UIView commitAnimations];
    
    [self performSelector:@selector(removingPickerContainer) withObject:nil afterDelay:0.5];
}

-(void) keyboardWillHide:(NSNotification *) note
{
    [self.view removeGestureRecognizer:self.tapRecognizer];
}

-(void)didTapAnywhere: (UITapGestureRecognizer*) recognizer {
    [self.addressName resignFirstResponder];
    [self.customerName resignFirstResponder];
    [self.phone resignFirstResponder];
    [self.CityName resignFirstResponder];
    //    [self.metroName resignFirstResponder];
    [self.street resignFirstResponder];
    [self.build resignFirstResponder];
    [self.appartaments resignFirstResponder];
    [self.otherInformation resignFirstResponder];
    [self.deliveryTime resignFirstResponder];
    
    self.scrollView.contentSize = CGSizeMake(320, 430);
    
    //    [UIView beginAnimations:nil context:NULL];
    //    [UIView setAnimationDuration:0.3];
    //    self.pickerViewContainer.frame = CGRectMake(0, 590, 320, 260);
    //    [UIView commitAnimations];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/////////////////////////////////////////////////////
#pragma mark
#pragma mark PickerContainer private methods
/////////////////////////////////////////////////////

- (void)hideButton
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    pickerViewContainer.frame = CGRectMake(0, 590, 320, 260);
    [UIView commitAnimations];
    
    [self performSelector:@selector(removingPickerContainer) withObject:nil afterDelay:0.5];
    //    self.scrollView.contentSize = CGSizeMake(320, 430);
    //    [self.pickerViewContainer removeFromSuperview];
}

- (void)okButton
{
    //  get the current date
    NSDate *date = [self.pickerViewContainer.datePicker date];
    
    // format it
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    NSString *dateString = [dateFormat stringFromDate:date];
    self.deliveryTime.text = dateString;
    
    self.dateString = dateString;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    pickerViewContainer.frame = CGRectMake(0, 590, 320, 260);
    [UIView commitAnimations];
    
    [self performSelector:@selector(removingPickerContainer) withObject:nil afterDelay:0.5];
    //    self.scrollView.contentSize = CGSizeMake(320, 430);
}

- (void)removingPickerContainer
{
    [self.pickerViewContainer removeFromSuperview];
    
    if ([self.appartaments isEditing] || [self.build isEditing] || [self.street isEditing] || [self.otherInformation isEditing])
    {
        //        self.scrollView.contentSize = CGSizeMake(320, 590);
        CGFloat tempy = self.scrollView.contentSize.height;//imageView.frame.size.height;
        CGFloat tempx = self.scrollView.contentSize.width;;
        CGRect zoomRect = CGRectMake((tempx/2), (tempy/2), tempy, tempx);
        [self.scrollView scrollRectToVisible:zoomRect animated:YES];
    }
    else
        self.scrollView.contentSize = CGSizeMake(320, 430);
    //    pickerViewContainer = nil;
}


/////////////////////////////////////////////////////
#pragma mark
#pragma mark IBActions
/////////////////////////////////////////////////////

//send info to the server
//метод з використанням JSON 
- (IBAction)toOrderJSON:(id)sender
{
    //    if (!self.enableTime)
    //    {
    self.scrollView.contentSize = CGSizeMake(320, 430);
    if ([self checkForLiteracy])
    {
        if ([self checkForNumberCount])
        {
            //save address
            self.dictionary = [[NSMutableDictionary alloc] init];
            [self.dictionary setObject:self.addressName.text forKey:@"name"];
            [self.dictionary setObject:self.customerName.text forKey:@"username"];
            [self.dictionary setObject:self.phone.text forKey:@"phone"];
            [self.dictionary setObject:self.CityName.text forKey:@"city"];
            [self.dictionary setObject:self.street.text forKey:@"street"];
            [self.dictionary setObject:self.build.text forKey:@"house"];
            [self.dictionary setObject:self.appartaments.text forKey:@"room_office"];
            //        [self.dictionary setObject:self.metroName.text forKey:@"metro"];
            //        [self.dictionary setObject:self.floor.text forKey:@"floor"];
            //        [self.dictionary setObject:self.intercom.text forKey:@"intercom"];
            //        [self.dictionary setObject:self.access.text forKey:@"access"];
            [self.dictionary setObject:self.otherInformation.text forKey:@"additional_info"];
            //            [self.dictionary setObject:self.deliveryTime.text forKey:@"deliveryTime"];
            
            [self.content addObjectToEntity:@"Addresses" withDictionaryOfAttributes:self.dictionary.copy];
            //
            //            UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            //            activityView.backgroundColor = [UIColor darkTextColor];
            //            self.scrollView.frame = self.parentViewController.view.frame;
            //            activityView.frame = self.parentViewController.view.frame;
            //            activityView.center=self.view.center;
            //            [activityView startAnimating];
            //            [self.view addSubview:activityView];
            
            
            //    NSString *orderStringUrl = [@"http://matrix-soft.org/addon_domains_folder/test5/root/Customer_Scripts/makeOrder.php?tag=" stringByAppendingString: @"order"];
            //    orderStringUrl = [orderStringUrl stringByAppendingString: @"&DBid=10&UUID=fdsampled-roma-roma-roma-69416d19df4e&ProdIDs=9;11&counts=30;5&city=Kyiv&street=qweqw&house=1&room_office=232&custName=eqweqwewqewe&phone=+380(099)9999999&idDelivery=1"];
            
            
            NSMutableString *order = [NSMutableString stringWithFormat:@"%@%@%@%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"dbLink"], @"/Customer_Scripts/makeOrder.php?", [[NSUserDefaults standardUserDefaults] valueForKey:@"DBid"], @"&tag=order&idPhone=1&UUID="];
            //                [self.dictionary setObject: [[NSUserDefaults standardUserDefaults] valueForKey:@"DBid"] forKey:@"DBid"];
            
                   //      This is for using on device
            
                        NSString *deviceToken = [(RestaurantAppDelegate *)[[UIApplication sharedApplication] delegate] testToken1];
            NSLog(@"deviceToken %@", deviceToken);
            [order appendString:deviceToken];
                        // [self.dictionary setObject: deviceToken forKey:@"UUID"];
            
            
            //                this is for simulation
//            if (![[NSUserDefaults standardUserDefaults] objectForKey:@"uid"])
//            {
//                NSString *uid = [self createUUID];
//                [[NSUserDefaults standardUserDefaults] setValue:uid forKey:@"uid"];
//                //9E3C884C-6E57-4D16-884F-46132825F21E
//                [[NSUserDefaults standardUserDefaults] synchronize];
//                [order  appendString:uid];
//            }
//            else
//            {
//                [order appendString:[[NSUserDefaults standardUserDefaults] objectForKey:@"uid"]];
//            }
            
            NSArray *cartArray = [[[GettingCoreContent alloc] init] fetchAllProductsIdAndTheirCountWithPriceForEntity:@"Cart"];
            NSMutableArray *arrayOfProducts = [[NSMutableArray alloc]init];
            for (int i = 0; i < cartArray.count; i++)
            {
                NSMutableDictionary *productsDict = [[NSMutableDictionary alloc]init];
                NSString *prodId = [NSString stringWithFormat:@"%@;",[[cartArray objectAtIndex:i] valueForKey:@"underbarid"]];
                NSString *count = [NSString stringWithFormat:@"%@;",[[cartArray objectAtIndex:i] valueForKey:@"count"]];
                if ([[[cartArray objectAtIndex:i] valueForKey:@"isMultisize"] intValue])
                {
                    NSString *size = [NSString stringWithFormat:@"%@;",[[cartArray objectAtIndex:i] valueForKey:@"size"]];
                    [productsDict setObject:size forKey:@"size"];
                }
                NSArray *productIngredientsIds = [[[GettingCoreContent alloc] init] fetchAllIngredientsIdWithProductId: [NSNumber numberWithFloat: prodId.floatValue] fromEntity:@"Cart_Products_Ingredients"];
                [productsDict setObject:prodId forKey:@"ProdId"];
                [productsDict setObject:count forKey:@"counts"];
                if ([[[cartArray objectAtIndex:i] valueForKey:@"isTopping"] intValue])
                {
                    [productsDict setObject:productIngredientsIds forKey:@"ingredients"];
                }
                [arrayOfProducts addObject:productsDict];
            }
            [self.dictionary setObject:arrayOfProducts forKey:@"Products"];
            
            NSString *jsonString = [self.dictionary JSONString];
            
            NSLog(@"jsonRequest is %@", jsonString);
            
            //                self.ids = ids;
            //                self.counts = counts;
            
            
            //            NSDate *date = [NSDate date];
            //            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            //            [dateFormat setDateFormat:@"dd.MM.yyyy"];
            //            NSString *dateString = [dateFormat stringFromDate:date];
            //
            //            self.historyDictionary = [[NSMutableDictionary alloc] init];
            //            [self.historyDictionary setObject:addressName.text forKey:@"name"];
            //            [self.historyDictionary setObject:build.text forKey:@"house"];
            //            [self.historyDictionary setObject:CityName.text forKey:@"city"];
            //            [self.historyDictionary setObject:dateString forKey:@"date"];
            //            [self.historyDictionary setObject:@"deliveryID" forKey:@"deliveryID"];
            ////            [self.historyDictionary setObject:@"floor" forKey:@"floor"];
            //            [self.historyDictionary setObject:@"metro" forKey:@"metro"];
            //            [self.historyDictionary setObject:@"orderID" forKey:@"orderID"];
            //            [self.historyDictionary setObject:counts forKey:@"productsCounts"];
            //            [self.historyDictionary setObject:ids forKey:@"productsIDs"];
            //            [self.historyDictionary setObject:self.appartaments.text forKey:@"room_office"];
            //            [self.historyDictionary setObject:@"status id" forKey:@"statusID"];
            //            [self.historyDictionary setObject:self.street.text forKey:@"street"];
            //
            //            [self.content addObjectToCoreDataEntity:@"CustomerOrders" withDictionaryOfAttributes:self.historyDictionary.copy];
            
            
            //                NSString *deliveryType;
            //                if (!self.enableTime)
            //                    deliveryType = @"1";
            //                else
            //                    deliveryType = @"2";
            //
            //                [order appendFormat:@"&ProdIDs=%@&counts=%@&city=%@&street=%@&house=%@&room_office=%@&custName=%@&phone=%@&additional_info=%@&deliveryType=%@&deliveryTime=%@",ids,counts,self.CityName.text,self.street.text,self.build.text,self.appartaments.text,self.customerName.text,self.phone.text,self.otherInformation.text, deliveryType,self.dateString];
            //
            //                order = [order stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding].copy;
            //                NSLog(@"order url = %@", order);
            
            //NSData *requestData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
            
            [order appendString:jsonString];
            order = [order stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding].copy;
            NSURL *url = [NSURL URLWithString:order.copy];
            NSLog(@"Request string:%@", url);
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
            [request setHTTPMethod:@"POST"];
            NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            
            
            self.scrollView.frame = self.parentViewController.view.frame;
            self.hudView = [[SSHUDView alloc] init];
            hudView.backgroundColor = [UIColor clearColor];
            [self.hudView show];
            
            if (!theConnection)
            {
                // Inform the user that the connection failed.
                UIAlertView *connectFailMessage = [[UIAlertView alloc] initWithTitle:@"NSURLConnection"
                                                                             message:@"Not success"
                                                                            delegate:self
                                                                   cancelButtonTitle:@"Ok"
                                                                   otherButtonTitles:nil];
                [connectFailMessage show];
            }
            
        }
        else
        {
            UIAlertView *connectFailMessage = [[UIAlertView alloc] initWithTitle:self.titleIncorectPhoneNumber
                                                                         message:nil //@"Not success"
                                                                        delegate:self
                                                               cancelButtonTitle:@"Ok"
                                                               otherButtonTitles:nil];
            [connectFailMessage show];
        }
    }
    else
    {
        UIAlertView *connectFailMessage = [[UIAlertView alloc] initWithTitle:@"Fil all rows with '*'."
                                                                     message:nil //@"Not success"
                                                                    delegate:self
                                                           cancelButtonTitle:@"Ok"
                                                           otherButtonTitles:nil];
        [connectFailMessage show];
    }
    //    }
    //    else
    //    {
    //        // send order delivery by Time
    //    }
}

- (IBAction)toOrder:(id)sender
{
    //    if (!self.enableTime)
    //    {
    self.scrollView.contentSize = CGSizeMake(320, 430);
    if ([self checkForLiteracy])
    {
        if([self checkForNumberCount]){
        //save address
        self.dictionary = [[NSMutableDictionary alloc] init];
        [self.dictionary setObject:self.addressName.text forKey:@"name"];
        [self.dictionary setObject:self.customerName.text forKey:@"username"];
        [self.dictionary setObject:self.phone.text forKey:@"phone"];
        [self.dictionary setObject:self.CityName.text forKey:@"city"];
        [self.dictionary setObject:self.street.text forKey:@"street"];
        [self.dictionary setObject:self.build.text forKey:@"house"];
        [self.dictionary setObject:self.appartaments.text forKey:@"room_office"];
        //        [self.dictionary setObject:self.metroName.text forKey:@"metro"];
        //        [self.dictionary setObject:self.floor.text forKey:@"floor"];
        //        [self.dictionary setObject:self.intercom.text forKey:@"intercom"];
        //        [self.dictionary setObject:self.access.text forKey:@"access"];
        [self.dictionary setObject:self.otherInformation.text forKey:@"additional_info"];
        //            [self.dictionary setObject:self.deliveryTime.text forKey:@"deliveryTime"];
        
        [self.content addObjectToEntity:@"Addresses" withDictionaryOfAttributes:self.dictionary.copy];
        //
        //            UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        //            activityView.backgroundColor = [UIColor darkTextColor];
        //            self.scrollView.frame = self.parentViewController.view.frame;
        //            activityView.frame = self.parentViewController.view.frame;
        //            activityView.center=self.view.center;
        //            [activityView startAnimating];
        //            [self.view addSubview:activityView];
        
        
        //    NSString *orderStringUrl = [@"http://matrix-soft.org/addon_domains_folder/test5/root/Customer_Scripts/makeOrder.php?tag=" stringByAppendingString: @"order"];
        //    orderStringUrl = [orderStringUrl stringByAppendingString: @"&DBid=10&UUID=fdsampled-roma-roma-roma-69416d19df4e&ProdIDs=9;11&counts=30;5&city=Kyiv&street=qweqw&house=1&room_office=232&custName=eqweqwewqewe&phone=+380(099)9999999&idDelivery=1"];
        
        NSMutableString *order = [NSMutableString stringWithString: @"http://matrix-soft.org/addon_domains_folder/test7/root/Customer_Scripts/makeOrder.php?tag=order&DBid=12&UUID="];
        if (![[NSUserDefaults standardUserDefaults] objectForKey:@"uid"])
        {
            NSString *uid = [self createUUID];
            [[NSUserDefaults standardUserDefaults] setValue:uid forKey:@"uid"];
            //9E3C884C-6E57-4D16-884F-46132825F21E
            [[NSUserDefaults standardUserDefaults] synchronize];
            [order appendString: uid];
        }
        else
            [order appendString:[[NSUserDefaults standardUserDefaults] objectForKey:@"uid"]];
        
        NSArray *cartArray = [[[GettingCoreContent alloc] init] fetchAllProductsIdAndTheirCountWithPriceForEntity:@"Cart"];
        NSMutableString *ids = [[NSMutableString alloc] init];
        NSMutableString *counts = [[NSMutableString alloc] init];
        for (int i = 0; i < cartArray.count; i++)
        {
            [ids appendString:[NSString stringWithFormat:@"%@;",[[cartArray objectAtIndex:i] valueForKey:@"underbarid"]]];
            [counts appendString:[NSString stringWithFormat:@"%@;",[[cartArray objectAtIndex:i] valueForKey:@"count"]]];
        }
        [ids setString:[ids substringToIndex:(ids.length - 1)]];
        [counts setString:[counts substringToIndex:(counts.length - 1)]];
        
        self.ids = ids;
        self.counts = counts;
        
        
        //            NSDate *date = [NSDate date];
        //            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        //            [dateFormat setDateFormat:@"dd.MM.yyyy"];
        //            NSString *dateString = [dateFormat stringFromDate:date];
        //
        //            self.historyDictionary = [[NSMutableDictionary alloc] init];
        //            [self.historyDictionary setObject:addressName.text forKey:@"name"];
        //            [self.historyDictionary setObject:build.text forKey:@"house"];
        //            [self.historyDictionary setObject:CityName.text forKey:@"city"];
        //            [self.historyDictionary setObject:dateString forKey:@"date"];
        //            [self.historyDictionary setObject:@"deliveryID" forKey:@"deliveryID"];
        ////            [self.historyDictionary setObject:@"floor" forKey:@"floor"];
        //            [self.historyDictionary setObject:@"metro" forKey:@"metro"];
        //            [self.historyDictionary setObject:@"orderID" forKey:@"orderID"];
        //            [self.historyDictionary setObject:counts forKey:@"productsCounts"];
        //            [self.historyDictionary setObject:ids forKey:@"productsIDs"];
        //            [self.historyDictionary setObject:self.appartaments.text forKey:@"room_office"];
        //            [self.historyDictionary setObject:@"status id" forKey:@"statusID"];
        //            [self.historyDictionary setObject:self.street.text forKey:@"street"];
        //
        //            [self.content addObjectToCoreDataEntity:@"CustomerOrders" withDictionaryOfAttributes:self.historyDictionary.copy];
        
        
        NSString *deliveryType;
        if (!self.enableTime)
            deliveryType = @"1";
        else
            deliveryType = @"2";
        
        [order appendFormat:@"&ProdIDs=%@&counts=%@&city=%@&street=%@&house=%@&room_office=%@&custName=%@&phone=%@&additional_info=%@&deliveryType=%@&deliveryTime=%@",ids,counts,self.CityName.text,self.street.text,self.build.text,self.appartaments.text,self.customerName.text,self.phone.text,self.otherInformation.text, deliveryType,self.deliveryTime.text];
        
        order = [order stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding].copy;
        
        NSURL *url = [NSURL URLWithString:order.copy];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        [request setHTTPMethod:@"GET"];
        NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        
        self.scrollView.frame = self.parentViewController.view.frame;
        self.hudView = [[SSHUDView alloc] init];
        hudView.backgroundColor = [UIColor clearColor];
        [self.hudView show];
        
        if (!theConnection)
        {
            // Inform the user that the connection failed.
            UIAlertView *connectFailMessage = [[UIAlertView alloc] initWithTitle:@"NSURLConnection"
                                                                         message:@"Not success"
                                                                        delegate:self
                                                               cancelButtonTitle:@"Ok"
                                                               otherButtonTitles:nil];
            [connectFailMessage show];
        }
    }
        else{
            UIAlertView *connectFailMessage = [[UIAlertView alloc] initWithTitle:@"Input correct phone number!"
                                                                         message:nil //@"Not success"
                                                                        delegate:self
                                                               cancelButtonTitle:@"Ok"
                                                               otherButtonTitles:nil];
            [connectFailMessage show];

        }
    }
    else
    {
        UIAlertView *connectFailMessage = [[UIAlertView alloc] initWithTitle:@"Fil all rows with '*'."
                                                                     message:nil //@"Not success"
                                                                    delegate:self
                                                           cancelButtonTitle:@"Ok"
                                                           otherButtonTitles:nil];
        [connectFailMessage show];
    }
    //    }
    //    else
    //    {
    //        // send order delivery by Time
    //    }
}

- (IBAction)saveAddress:(id)sender
{
    self.scrollView.contentSize = CGSizeMake(320, 430);
    if ([self checkForLiteracy])
    {
        self.dictionary = [[NSMutableDictionary alloc] init];
        [self.dictionary setObject:self.addressName.text forKey:@"name"];
        [self.dictionary setObject:self.customerName.text forKey:@"username"];
        [self.dictionary setObject:self.phone.text forKey:@"phone"];
        [self.dictionary setObject:self.CityName.text forKey:@"city"];
        [self.dictionary setObject:self.street.text forKey:@"street"];
        [self.dictionary setObject:self.build.text forKey:@"house"];
        [self.dictionary setObject:self.appartaments.text forKey:@"room_office"];
        //        [self.dictionary setObject:self.metroName.text forKey:@"metro"];
        //        [self.dictionary setObject:self.floor.text forKey:@"floor"];
        //        [self.dictionary setObject:self.intercom.text forKey:@"intercom"];
        //        [self.dictionary setObject:self.access.text forKey:@"access"];
        [self.dictionary setObject:self.otherInformation.text forKey:@"additional_info"];
        
        BOOL isSaved = [self.content addObjectToEntity:@"Addresses" withDictionaryOfAttributes:self.dictionary.copy];
        
        if (isSaved)
        {
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Saved new address %@.", self.addressName.text]
                                                              message:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
            [message show];
            return;
        }
        else
        {
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"You already have address with name %@.", self.addressName.text]
                                                              message:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
            [message show];
            return;
        }
    }
    else
    {
        UIAlertView *connectFailMessage = [[UIAlertView alloc] initWithTitle:@"Fill all rows with '*'."
                                                                     message:nil //@"Not success"
                                                                    delegate:self
                                                           cancelButtonTitle:@"Ok"
                                                           otherButtonTitles:nil];
        [connectFailMessage show];
        return;
    }
}

- (IBAction)toAddressList:(id)sender
{
    //    [[[AddressListTableViewController alloc] initWithNibName:@"AddressListTableViewController" bundle:[NSBundle mainBundle]] setDelegate:self];
    //    AddressListTableViewController *controller =  [[AddressListTableViewController alloc] init];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toAddressList"])
    {
        AddressListTableViewController *controller =  [segue destinationViewController];
        controller.delegate = self;
    }
}

/////////////////////////////////////////////////////
#pragma mark
#pragma mark working with server
/////////////////////////////////////////////////////

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Unable to fetch data");
    [self.hudView failAndDismissWithTitle:nil];
    
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:self.titleCanNotAccessToServer
                                                      message:self.titlePleaseTryAgain
                                                     delegate:self
                                            cancelButtonTitle:@"Ok"
                                            otherButtonTitles:nil];
    [message show];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Succeeded! Received %d bytes of data",[self.responseData
                                                   length]);
    NSString *txt = [[NSString alloc] initWithData:self.responseData encoding: NSASCIIStringEncoding];
    NSLog(@"strinng is - %@",txt);
    
    // создаем парсер
    XMLParseResponseFromTheServer *parser = [[XMLParseResponseFromTheServer alloc] initWithData:self.responseData];
    [parser setDelegate:parser];
    [parser parse];
    self.db = parser;
    
    if ([self.db.success isEqualToString:@"1"])
    {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:self.titleThankYouForOrder
                                                          message:self.titleOurOperatorWillCallYou
                                                         delegate:self
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
        
    }
    else
    {
        if ([self.db.cause isEqualToString:@"0"]) // 0 - is index of time error (when u try to order something in non-working time)
        {
            [self.hudView failAndDismissWithTitle:nil];
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:self.titleError
                                                              message:self.titleWrongTime
                                                             delegate:self
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
            [message show];
            self.enableTime = YES;
            self.deliveryTime.hidden = NO;
            return;
        }
        else
            if ([self.db.cause isEqualToString:@"3"]) {
                
                [self.hudView failAndDismissWithTitle:nil];
                UIAlertView *message = [[UIAlertView alloc] initWithTitle:self.titleError
                                                                  message:self.titleDontRichMinimumPrice
                                                                 delegate:self
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
                [message show];
                return;
            }
            else
            {
                [self.hudView failAndDismissWithTitle:nil];
                UIAlertView *message = [[UIAlertView alloc] initWithTitle:self.titleError
                                                                  message:self.titlePleaseTryAgain
                                                                 delegate:self
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
                [message show];
                [self.navigationController popViewControllerAnimated:YES];
                return;
            }
    }
    
    NSLog(@"Success: %@", self.db.success);
    NSLog(@"orderNumber: %@", self.db.orderNumber);
    
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd.MM.yyyy"];
    NSString *dateString = [dateFormat stringFromDate:date];
    
    self.historyDictionary = [[NSMutableDictionary alloc] init];
    [self.historyDictionary setObject:addressName.text forKey:@"name"];
    [self.historyDictionary setObject:build.text forKey:@"house"];
    [self.historyDictionary setObject:CityName.text forKey:@"city"];
    [self.historyDictionary setObject:dateString forKey:@"date"];
    [self.historyDictionary setObject:@"deliveryID" forKey:@"deliveryID"];
    //            [self.historyDictionary setObject:@"floor" forKey:@"floor"];
    [self.historyDictionary setObject:@"metro" forKey:@"metro"];
    [self.historyDictionary setObject:self.db.orderNumber forKey:@"orderID"];
    [self.historyDictionary setObject:self.counts forKey:@"productsCounts"];
    [self.historyDictionary setObject:self.ids forKey:@"productsIDs"];
    [self.historyDictionary setObject:self.appartaments.text forKey:@"room_office"];
    [self.historyDictionary setObject:@"3" forKey:@"statusID"];
    [self.historyDictionary setObject:self.street.text forKey:@"street"];
    [self.historyDictionary setObject:self.otherInformation.text forKey:@"additional_info"];
    
    
    [self.content addObjectToCoreDataEntity:@"CustomerOrders" withDictionaryOfAttributes:self.historyDictionary.copy];
    
    [[[GettingCoreContent alloc] init] deleteAllObjectsFromEntity:@"Cart"];
    
    [self.hudView completeAndDismissWithTitle:nil];
    [self performSelector:@selector(pop:) withObject:nil afterDelay:0.9];
}

- (void)pop:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

/////////////////////////////////////////////////////
#pragma mark
#pragma mark scrollViewDelegate
/////////////////////////////////////////////////////

- (void) scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [self removingPickerContainer];
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self removingPickerContainer];
}
/////////////////////////////////////////////////////
#pragma mark
#pragma mark private methods
/////////////////////////////////////////////////////

-(BOOL)checkForLiteracy
{
    if (!self.enableTime)
    {
        if (![self.addressName.text isEqual:@""] && ![self.customerName.text isEqual:@""] && ![self.phone.text isEqual:@""] && ![self.CityName.text isEqual:@""] && ![self.street.text isEqual:@""] && ![self.build.text isEqual:@""] && ![self.appartaments.text isEqual:@""])
        {
            return YES;
        }
        else
            return NO;
    }
    else
    {
        if (![self.addressName.text isEqual:@""] && ![self.customerName.text isEqual:@""] && ![self.phone.text isEqual:@""] && ![self.CityName.text isEqual:@""] && ![self.street.text isEqual:@""] && ![self.build.text isEqual:@""] && ![self.appartaments.text isEqual:@""] && ![self.deliveryTime.text isEqual:@""])
        {
            return YES;
        }
        else
            return NO;
    }
}

- (BOOL)checkForNumberCount
{
    NSString *phoneNumberString = [self.phone text];
    int phoneNumberCount = [phoneNumberString length];
    
    if ((phoneNumberCount ==10) &([phoneNumberString characterAtIndex:0] == 0) ) {
        
        return YES;
        
    } else
        return NO;
}

#pragma mark
#pragma mark PRIVATE METHODS

- (NSString *)createUUID
{
    // Create universally unique identifier (object)
    CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
    
    // Get the string representation of CFUUID object.
    NSString *uuidStr = (__bridge NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidObject);
    
    // If needed, here is how to get a representation in bytes, returned as a structure
    // typedef struct {
    //   UInt8 byte0;
    //   UInt8 byte1;
    //   ...
    //   UInt8 byte15;
    // } CFUUIDBytes;
    //CFUUIDBytes bytes = CFUUIDGetUUIDBytes(uuidObject);
    
    //CFRelease(uuidObject);
    
    return uuidStr;
}

-(void)setAllTitlesOnThisPage
{
    NSArray *array = [Singleton titlesTranslation_withISfromSettings:NO];
    for (int i = 0; i <array.count; i++)
    {
        if ([[[array objectAtIndex:i] valueForKey:@"name_EN"] isEqualToString:@"*Address name"])
        {
            self.addressName.placeholder = [[array objectAtIndex:i] valueForKey:@"title"];
        }
        
        else if ([[[array objectAtIndex:i] valueForKey:@"name_EN"] isEqualToString:@"*Your name"])
        {
            self.customerName.placeholder = [[array objectAtIndex:i] valueForKey:@"title"];
        }
        
        else if ([[[array objectAtIndex:i] valueForKey:@"name_EN"] isEqualToString:@"*Phone"])
        {
            self.phone.placeholder = [[array objectAtIndex:i] valueForKey:@"title"];
        }
        
        else if ([[[array objectAtIndex:i] valueForKey:@"name_EN"] isEqualToString:@"*City"])
        {
            self.CityName.placeholder = [[array objectAtIndex:i] valueForKey:@"title"];
        }
        
        else if ([[[array objectAtIndex:i] valueForKey:@"name_EN"] isEqualToString:@"*Street"])
        {
            self.street.placeholder = [[array objectAtIndex:i] valueForKey:@"title"];
        }
        
        else if ([[[array objectAtIndex:i] valueForKey:@"name_EN"] isEqualToString:@"*Build"])
        {
            self.build.placeholder = [[array objectAtIndex:i] valueForKey:@"title"];
        }
        
        else if ([[[array objectAtIndex:i] valueForKey:@"name_EN"] isEqualToString:@"*App/office"])
        {
            self.appartaments.placeholder = [[array objectAtIndex:i] valueForKey:@"title"];
        }
        
        else if ([[[array objectAtIndex:i] valueForKey:@"name_EN"] isEqualToString:@"*Other information"])
        {
            self.otherInformation.placeholder = [[array objectAtIndex:i] valueForKey:@"title"];
        }
        
        else if ([[[array objectAtIndex:i] valueForKey:@"name_EN"] isEqualToString:@"*Time"])
        {
            self.deliveryTime.placeholder = [[array objectAtIndex:i] valueForKey:@"title"];
        }
        
        else if ([[[array objectAtIndex:i] valueForKey:@"name_EN"] isEqualToString:@"To order"])
        {
            [self.toOrderButton setTitle:[[array objectAtIndex:i] valueForKey:@"title"] forState:UIControlStateNormal];
        }
        
        else if ([[[array objectAtIndex:i] valueForKey:@"name_EN"] isEqualToString:@"Save address"])
        {
            [self.saveAddressButton setTitle:[[array objectAtIndex:i] valueForKey:@"title"] forState:UIControlStateNormal];
        }
        
        else if ([[[array objectAtIndex:i] valueForKey:@"name_EN"] isEqualToString:@"Thank you for order!"])
        {
            self.titleThankYouForOrder = [[array objectAtIndex:i] valueForKey:@"title"];
        }
        
        else if ([[[array objectAtIndex:i] valueForKey:@"name_EN"] isEqualToString:@"Our operator will call you for a while."])
        {
            self.titleOurOperatorWillCallYou = [[array objectAtIndex:i] valueForKey:@"title"];
        }
        
        else if ([[[array objectAtIndex:i] valueForKey:@"name_EN"] isEqualToString:@"Error"])
        {
            self.titleError = [[array objectAtIndex:i] valueForKey:@"title"];
        }
        
        else if ([[[array objectAtIndex:i] valueForKey:@"name_EN"] isEqualToString:@"Can not access to the server"])
        {
            self.titleCanNotAccessToServer = [[array objectAtIndex:i] valueForKey:@"title"];
        }
        
        else if ([[[array objectAtIndex:i] valueForKey:@"name_EN"] isEqualToString:@"Please try again."])
        {
            self.titlePleaseTryAgain = [[array objectAtIndex:i] valueForKey:@"title"];
        }
        
        else if ([[[array objectAtIndex:i] valueForKey:@"name_EN"] isEqualToString:@"Enter please just numbers!"])
        {
            self.titleEnterJustNombers = [[array objectAtIndex:i] valueForKey:@"title"];
        }
        else if ([[[array objectAtIndex:i] valueForKey:@"name_EN"] isEqualToString:@"Right now restaurant doesn't work, please order delivery by time"])
        {
            self.titleWrongTime = [[array objectAtIndex:i] valueForKey:@"title"];
        }
        else if ([[[array objectAtIndex:i] valueForKey:@"name_EN"] isEqualToString:@"Your order is less than the minimum order value"])
        {
            self.titleDontRichMinimumPrice = [[array objectAtIndex:i] valueForKey:@"title"];
        }
        else if ([[[array objectAtIndex:i] valueForKey:@"name_EN"] isEqualToString:@"Phone Number Digit Must be min 7"])
        {
            self.titleIncorectPhoneNumber = [[array objectAtIndex:i] valueForKey:@"title"];
        }
    }
}
@end
