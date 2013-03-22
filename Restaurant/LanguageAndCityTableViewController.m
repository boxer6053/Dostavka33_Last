//
//  LanguageAndCityTableViewController.m
//  Restaurant
//
//  Created by Matrix Soft on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LanguageAndCityTableViewController.h"
#import "GettingCoreContent.h"
#import "checkConnection.h"
#import "SSToolkit/SSToolkit.h"

@interface LanguageAndCityTableViewController ()

@property BOOL isCity;
@property NSUInteger selectedIndex;
@property (strong,nonatomic) NSArray *destinationArray;
@property (strong, nonatomic) NSMutableData *responseData;
@property (nonatomic, strong) XMLParse *db;
@property BOOL isDid;
@property (nonatomic, strong) SSHUDView *hudView;
//@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (strong, nonatomic) NSMutableDictionary *cityWithIdDictionary;
@property (strong, nonatomic) GettingCoreContent *content;

//titles
@property (nonatomic, weak) NSString *titleLoading;
@property (nonatomic, weak) NSString *titleFinished;
@property (nonatomic, weak) NSString *titleUnableFetchData;
@property (nonatomic, weak) NSString *titleSuccesLanguage;

@end

@implementation LanguageAndCityTableViewController

@synthesize isCity = _isCity;
@synthesize selectedIndex = _selectedIndex;
@synthesize destinationArray = _destinationArray;
@synthesize responseData = _responseData;
@synthesize db = _db;
@synthesize isDid = _isDid;
@synthesize hudView = _hudView;
//@synthesize activityView = _activityView;
@synthesize  cityWithIdDictionary = _cityWithIdDictionary;
@synthesize content = _content;

//titles
@synthesize titleLoading = _titleLoading;
@synthesize titleFinished = _titleFinished;
@synthesize titleUnableFetchData = _titleUnableFetchData;
@synthesize titleSuccesLanguage = _titleSuccesLanguage;

- (GettingCoreContent *)content
{
    if(!_content)
    {
        _content = [[GettingCoreContent alloc] init];
    }
    return  _content;
}

- (void)setArrayFromSegue:(BOOL)isCityEnter;
{
    GettingCoreContent *getCon = [[GettingCoreContent alloc] init];
    if (!isCityEnter) 
    {
        _destinationArray = [getCon fetchAllLanguages];
    }
    else 
    {
        _destinationArray = [getCon fetchAllCitiesByLanguage:[[NSUserDefaults standardUserDefaults] objectForKey:@"defaultLanguageId"]];
        self.isCity = YES;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setAllTitlesOnThisPage];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{ 
    return [[self destinationArray] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.isCity)
    {
        cell.textLabel.text = [[[self destinationArray] objectAtIndex:indexPath.row] valueForKey:@"name"];
        
        NSString *userCityId = [[NSUserDefaults standardUserDefaults] objectForKey:@"defaultCityId"];
        NSString *currCityId = [[[self destinationArray] objectAtIndex:indexPath.row] valueForKey:@"idCity"]; 
        if ([userCityId.description isEqual:currCityId.description])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.selectedIndex = indexPath.row;
        }
    }
    else 
    {
        cell.textLabel.text = [[[self.destinationArray objectAtIndex:indexPath.row] valueForKey:@"language"] description];
        
        NSString *userLangId = [[NSUserDefaults standardUserDefaults] objectForKey:@"defaultLanguageId"];
        NSString *currLangId = [[[self destinationArray] objectAtIndex:indexPath.row] valueForKey:@"underbarid"];
        if ([userLangId.description isEqual:currLangId.description])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.selectedIndex = indexPath.row;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (/*checkConnection.hasConnectivity*/ TRUE)
    {
        self.hudView = [[SSHUDView alloc] initWithTitle:self.titleLoading];
        [self.hudView show];
        
        //        UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        //        activityView.frame = self.view.frame;
        //        activityView.backgroundColor = [UIColor grayColor];
        //        activityView.center=self.view.center;
        //        [activityView startAnimating];
        //        [self.view addSubview:activityView];
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSString *changeStringForUserDefaults;
        NSString *wasDownloaded;
        id data;
        GettingCoreContent *content = [[GettingCoreContent alloc] init];
        
        if (self.isCity)
        {
            changeStringForUserDefaults = @"defaultCityId";
            data = [[self.destinationArray objectAtIndex:indexPath.row] valueForKey:@"idCity"];
            wasDownloaded = [NSString stringWithFormat:@"isCityHere%@", data];
            
            //--------------------------Change city-----------------------------------
            
            int checkCount = [[self.content getArrayFromCoreDatainEntetyName:@"CheckChangesSettings" withSortDescriptor:@"idCity"] count];
            
            BOOL isCity = NO;
            
            for (int i = 0; i < checkCount; i++) {
                NSString *idCityString = [[[self.content getArrayFromCoreDatainEntetyName:@"CheckChangesSettings" withSortDescriptor:@"idCity"] objectAtIndex:i] valueForKey:@"idCity"];
                if ([idCityString isEqualToString:[NSString stringWithFormat:@"%@", data]]) {
                    isCity = YES;
                    break;
                }
                
            }
            
            if (!isCity) {
                if (self.selectedIndex != NSNotFound)
                {
                    UITableViewCell *cell = [tableView
                                             cellForRowAtIndexPath:[NSIndexPath
                                                                    indexPathForRow:self.selectedIndex inSection:0]];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                self.selectedIndex = indexPath.row;
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                [[NSUserDefaults standardUserDefaults] setObject:data forKey:changeStringForUserDefaults];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[NSUserDefaults standardUserDefaults] setObject:data forKey:wasDownloaded];
                
                // http request updatePHP with &tag=rmp
                NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@%@%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"dbLink"], @"/Customer_Scripts/update.php?", [[NSUserDefaults standardUserDefaults] valueForKey:@"DBid"], @"&tag=rmp"];
                [urlString appendFormat:@"&idLang=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"defaultLanguageId"]];
                [urlString appendFormat:@"&idCity=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"defaultCityId"]];
                NSURL *url = [NSURL URLWithString:urlString.copy];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
                [request setHTTPMethod:@"GET"];
                NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
                if (!theConnection)
                {
                    // Inform the user that the connection failed.
                    UIAlertView *connectFailMessage = [[UIAlertView alloc] initWithTitle:@"NSURLConnection"
                                                                                 message:@"Not success"
                                                                                delegate:self
                                                                       cancelButtonTitle:@"Ok"
                                                                       otherButtonTitles:nil];
                    [connectFailMessage show];
                    //            }
                }
                
                self.cityWithIdDictionary = [[NSMutableDictionary alloc] init];
                
                [self.cityWithIdDictionary setValue: [NSString stringWithFormat:@"%@", data] forKey:@"idCity"];
                [self.cityWithIdDictionary setValue:[[[NSUserDefaults standardUserDefaults] objectForKey:@"defaultLanguageId"] stringValue] forKey:@"idLanguage"];
                
                [self.content addObjectToCoreDataEntity:@"CheckChangesSettings" withDictionaryOfAttributes:self.cityWithIdDictionary.copy];
                
            }
            else
            {
                int checkCount = [[self.content getArrayFromCoreDatainEntetyName:@"CheckChangesSettings" withSortDescriptor:@"idCity"] count];
                
                BOOL isLanguage = NO;
                
                for (int i = 0; i < checkCount; i++) {
                    NSString *idCityString = [[[self.content getArrayFromCoreDatainEntetyName:@"CheckChangesSettings" withSortDescriptor:@"idCity"] objectAtIndex:i] valueForKey:@"idCity"];
                    if ([idCityString isEqualToString:[NSString stringWithFormat:@"%@", data]]) {
                        NSString *idLanguageString = [[[self.content getArrayFromCoreDatainEntetyName:@"CheckChangesSettings" withSortDescriptor:@"idCity"] objectAtIndex:i] valueForKey:@"idLanguage"];
                        if ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"defaultLanguageId"] stringValue] isEqualToString:idLanguageString]) {
                            isLanguage = YES;
                            break;
                        }
                    }
                }
                
                if (isLanguage) {
                    if (self.selectedIndex != NSNotFound)
                    {
                        UITableViewCell *cell = [tableView
                                                 cellForRowAtIndexPath:[NSIndexPath
                                                                        indexPathForRow:self.selectedIndex inSection:0]];
                        cell.accessoryType = UITableViewCellAccessoryNone;
                    }
                    self.selectedIndex = indexPath.row;
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    [[NSUserDefaults standardUserDefaults] setObject:data forKey:changeStringForUserDefaults];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:data forKey:wasDownloaded];
                    
                    if (checkConnection.hasConnectivity) {
                        // http request updatePHP with &tag=rmp
                        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@%@%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"dbLink"], @"/Customer_Scripts/update.php?", [[NSUserDefaults standardUserDefaults] valueForKey:@"DBid"], @"&tag=update"];
                        [urlString appendFormat:@"&lang_id=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"defaultLanguageId"]];
                        [urlString appendFormat:@"&city_id=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"defaultCityId"]];
                        
                        NSArray *productArray = [[NSArray alloc] initWithArray:[self.content getArrayFromCoreDatainEntetyName:@"Products" withSortDescriptor:@"underbarid"]];
                        NSArray *restaurantArray = [[NSArray alloc] initWithArray:[self.content getArrayFromCoreDatainEntetyName:@"Restaurants" withSortDescriptor:@"underbarid"]];
                        NSArray *menuArray = [[NSArray alloc] initWithArray:[self.content getArrayFromCoreDatainEntetyName:@"Menus" withSortDescriptor:@"underbarid"]];
                        
                        int prod_v = 0;
                        int mprod_id = [[[productArray objectAtIndex:[productArray count]-1] valueForKey:@"underbarid"] intValue];
                        
                        int rest_v = 0;
                        int mrest_id = [[[restaurantArray objectAtIndex:[restaurantArray count]-1] valueForKey:@"underbarid"] intValue];
                        
                        int menu_v = 0;
                        int mmenu_id = [[[menuArray objectAtIndex:[menuArray count]-1] valueForKey:@"underbarid"] intValue];
                        
                        for (int i = 0; i < productArray.count; i++) {
                            if ([[[productArray objectAtIndex:i] valueForKey:@"version"] intValue] > prod_v) {
                                prod_v = [[[productArray objectAtIndex:i] valueForKey:@"version"] intValue];
                            }
                        }
                        for (int i = 0; i < restaurantArray.count; i++) {
                            if ([[[restaurantArray objectAtIndex:i] valueForKey:@"version"] intValue] > rest_v) {
                                rest_v = [[[restaurantArray objectAtIndex:i] valueForKey:@"version"] intValue];
                            }
                        }
                        for (int i = 0; i < menuArray.count; i++) {
                            if ([[[menuArray objectAtIndex:i] valueForKey:@"version"] intValue] > menu_v) {
                                menu_v = [[[menuArray objectAtIndex:i] valueForKey:@"version"] intValue];
                            }
                        }
                        
                        [urlString appendFormat:@"&prod_v=%u", prod_v];
                        [urlString appendFormat:@"&mprod_id=%u", mprod_id];
                        [urlString appendFormat:@"&rest_v=%u", rest_v];
                        [urlString appendFormat:@"&mrest_id=%u", mrest_id];
                        [urlString appendFormat:@"&menu_v=%u", menu_v];
                        [urlString appendFormat:@"&mmenu_id=%u", mmenu_id];
                        
                        NSURL *url = [NSURL URLWithString:urlString.copy];
                        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
                        [request setHTTPMethod:@"GET"];
                        NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
                        if (!theConnection)
                        {
                            // Inform the user that the connection failed.
                            UIAlertView *connectFailMessage = [[UIAlertView alloc] initWithTitle:@"NSURLConnection"
                                                                                         message:@"Not success"
                                                                                        delegate:self
                                                                               cancelButtonTitle:@"Ok"
                                                                               otherButtonTitles:nil];
                            [connectFailMessage show];
                            //            }
                        }

                    } else {
                        if (!self.isCity)
                        {
                            [Singleton titlesTranslation_withISfromSettings:YES];
                        }

                        [self performSelector:@selector(complete:) withObject:nil];
                    }
                    
                }
                else
                {
                    if (checkConnection.hasConnectivity) {
                        if (self.selectedIndex != NSNotFound)
                        {
                            UITableViewCell *cell = [tableView
                                                     cellForRowAtIndexPath:[NSIndexPath
                                                                            indexPathForRow:self.selectedIndex inSection:0]];
                            cell.accessoryType = UITableViewCellAccessoryNone;
                        }
                        self.selectedIndex = indexPath.row;
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        [[NSUserDefaults standardUserDefaults] setObject:data forKey:changeStringForUserDefaults];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        [[NSUserDefaults standardUserDefaults] setObject:data forKey:wasDownloaded];
                        
                        // http request updatePHP with &tag=rmp
                        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@%@%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"dbLink"], @"/Customer_Scripts/update.php?", [[NSUserDefaults standardUserDefaults] valueForKey:@"DBid"], @"&tag=update_t"];
                        [urlString appendFormat:@"&lang_id=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"defaultLanguageId"]];
                        [urlString appendFormat:@"&city_id=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"defaultCityId"]];
                        
                        NSArray *productArray = [[NSArray alloc] initWithArray:[self.content getArrayFromCoreDatainEntetyName:@"Products" withSortDescriptor:@"underbarid"]];
                        NSArray *restaurantArray = [[NSArray alloc] initWithArray:[self.content getArrayFromCoreDatainEntetyName:@"Restaurants" withSortDescriptor:@"underbarid"]];
                        NSArray *menuArray = [[NSArray alloc] initWithArray:[self.content getArrayFromCoreDatainEntetyName:@"Menus" withSortDescriptor:@"underbarid"]];
                        
                        int prod_v = 0;
                        int mprod_id = [[[productArray objectAtIndex:[productArray count]-1] valueForKey:@"underbarid"] intValue];
                        
                        int rest_v = 0;
                        int mrest_id = [[[restaurantArray objectAtIndex:[restaurantArray count]-1] valueForKey:@"underbarid"] intValue];
                        
                        int menu_v = 0;
                        int mmenu_id = [[[menuArray objectAtIndex:[menuArray count]-1] valueForKey:@"underbarid"] intValue];
                        
                        for (int i = 0; i < productArray.count; i++) {
                            if ([[[productArray objectAtIndex:i] valueForKey:@"version"] intValue] > prod_v) {
                                prod_v = [[[productArray objectAtIndex:i] valueForKey:@"version"] intValue];
                            }
                        }
                        for (int i = 0; i < restaurantArray.count; i++) {
                            if ([[[restaurantArray objectAtIndex:i] valueForKey:@"version"] intValue] > rest_v) {
                                rest_v = [[[restaurantArray objectAtIndex:i] valueForKey:@"version"] intValue];
                            }
                        }
                        for (int i = 0; i < menuArray.count; i++) {
                            if ([[[menuArray objectAtIndex:i] valueForKey:@"version"] intValue] > menu_v) {
                                menu_v = [[[menuArray objectAtIndex:i] valueForKey:@"version"] intValue];
                            }
                        }
                        
                        [urlString appendFormat:@"&prod_v=%u", prod_v];
                        [urlString appendFormat:@"&mprod_id=%u", mprod_id];
                        [urlString appendFormat:@"&rest_v=%u", rest_v];
                        [urlString appendFormat:@"&mrest_id=%u", mrest_id];
                        [urlString appendFormat:@"&menu_v=%u", menu_v];
                        [urlString appendFormat:@"&mmenu_id=%u", mmenu_id];
                        
                        NSURL *url = [NSURL URLWithString:urlString.copy];
                        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
                        [request setHTTPMethod:@"GET"];
                        NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
                        if (!theConnection)
                        {
                            // Inform the user that the connection failed.
                            UIAlertView *connectFailMessage = [[UIAlertView alloc] initWithTitle:@"NSURLConnection"
                                                                                         message:@"Not success"
                                                                                        delegate:self
                                                                               cancelButtonTitle:@"Ok"
                                                                               otherButtonTitles:nil];
                            [connectFailMessage show];
                            //            }
                        }
                        
                        self.cityWithIdDictionary = [[NSMutableDictionary alloc] init];
                        
                        [self.cityWithIdDictionary setValue: [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"defaultCityId"]] forKey:@"idCity"];
                        [self.cityWithIdDictionary setValue:[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"defaultLanguageId"]] forKey:@"idLanguage"];
                        
                        [self.content addObjectToCoreDataEntity:@"CheckChangesSettings" withDictionaryOfAttributes:self.cityWithIdDictionary.copy];
                    } else {
                        [self.hudView failAndDismissWithTitle:self.titleUnableFetchData];
                        [self performSelector:@selector(pop:) withObject:nil afterDelay:1];
                    }
                }
            }
            
            
            //видалаляємо вміст корзини i favorites, якщо змінюємо city
            //GettingCoreContent *content = [[GettingCoreContent alloc] init];
            [content deleteAllObjectsFromEntity:@"Cart"];
            //            [content deleteAllObjectsFromEntity:@"Favorites"];
            //            [content deleteAllObjectsFromEntity:@"Favorites"];
        }
        else
        {
            changeStringForUserDefaults = @"defaultLanguageId";
            data = [[self.destinationArray objectAtIndex:indexPath.row] valueForKey:@"underbarid"];
            wasDownloaded = [NSString stringWithFormat:@"isLanguageHere%@", data];
            
            //-----------------------Change lang---------------------------------------
            
            int checkCount = [[self.content getArrayFromCoreDatainEntetyName:@"CheckChangesSettings" withSortDescriptor:@"idCity"] count];
            
            BOOL isLanguage = NO;
            
            for (int i = 0; i < checkCount; i++) {
                NSString *idCityString = [[[self.content getArrayFromCoreDatainEntetyName:@"CheckChangesSettings" withSortDescriptor:@"idCity"] objectAtIndex:i] valueForKey:@"idCity"];
                if ([idCityString isEqualToString:[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"defaultCityId"]]]) {
                    NSString *idLanguageString = [[[self.content getArrayFromCoreDatainEntetyName:@"CheckChangesSettings" withSortDescriptor:@"idCity"] objectAtIndex:i] valueForKey:@"idLanguage"];
                    if ([[NSString stringWithFormat:@"%@", data] isEqualToString:idLanguageString]) {
                        isLanguage = YES;
                        break;
                    }
                }
            }
            
            if (isLanguage) {
                if (self.selectedIndex != NSNotFound)
                {
                    UITableViewCell *cell = [tableView
                                             cellForRowAtIndexPath:[NSIndexPath
                                                                    indexPathForRow:self.selectedIndex inSection:0]];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                self.selectedIndex = indexPath.row;
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                [[NSUserDefaults standardUserDefaults] setObject:data forKey:changeStringForUserDefaults];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[NSUserDefaults standardUserDefaults] setObject:data forKey:wasDownloaded];
                
                if (checkConnection.hasConnectivity) {
                    // http request updatePHP with &tag=update
                    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@%@%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"dbLink"], @"/Customer_Scripts/update.php?", [[NSUserDefaults standardUserDefaults] valueForKey:@"DBid"], @"&tag=update"];
                    [urlString appendFormat:@"&lang_id=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"defaultLanguageId"]];
                    [urlString appendFormat:@"&city_id=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"defaultCityId"]];
                    
                    NSArray *productArray = [[NSArray alloc] initWithArray:[self.content getArrayFromCoreDatainEntetyName:@"Products" withSortDescriptor:@"underbarid"]];
                    NSArray *restaurantArray = [[NSArray alloc] initWithArray:[self.content getArrayFromCoreDatainEntetyName:@"Restaurants" withSortDescriptor:@"underbarid"]];
                    NSArray *menuArray = [[NSArray alloc] initWithArray:[self.content getArrayFromCoreDatainEntetyName:@"Menus" withSortDescriptor:@"underbarid"]];
                    
                    int prod_v = 0;
                    int mprod_id = [[[productArray objectAtIndex:[productArray count]-1] valueForKey:@"underbarid"] intValue];
                    
                    int rest_v = 0;
                    int mrest_id = [[[restaurantArray objectAtIndex:[restaurantArray count]-1] valueForKey:@"underbarid"] intValue];
                    
                    int menu_v = 0;
                    int mmenu_id = [[[menuArray objectAtIndex:[menuArray count]-1] valueForKey:@"underbarid"] intValue];
                    
                    for (int i = 0; i < productArray.count; i++) {
                        if ([[[productArray objectAtIndex:i] valueForKey:@"version"] intValue] > prod_v) {
                            prod_v = [[[productArray objectAtIndex:i] valueForKey:@"version"] intValue];
                        }
                    }
                    for (int i = 0; i < restaurantArray.count; i++) {
                        if ([[[restaurantArray objectAtIndex:i] valueForKey:@"version"] intValue] > rest_v) {
                            rest_v = [[[restaurantArray objectAtIndex:i] valueForKey:@"version"] intValue];
                        }
                    }
                    for (int i = 0; i < menuArray.count; i++) {
                        if ([[[menuArray objectAtIndex:i] valueForKey:@"version"] intValue] > menu_v) {
                            menu_v = [[[menuArray objectAtIndex:i] valueForKey:@"version"] intValue];
                        }
                    }
                    
                    [urlString appendFormat:@"&prod_v=%u", prod_v];
                    [urlString appendFormat:@"&mprod_id=%u", mprod_id];
                    [urlString appendFormat:@"&rest_v=%u", rest_v];
                    [urlString appendFormat:@"&mrest_id=%u", mrest_id];
                    [urlString appendFormat:@"&menu_v=%u", menu_v];
                    [urlString appendFormat:@"&mmenu_id=%u", mmenu_id];
                    
                    NSURL *url = [NSURL URLWithString:urlString.copy];
                    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
                    [request setHTTPMethod:@"GET"];
                    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
                    if (!theConnection)
                    {
                        // Inform the user that the connection failed.
                        UIAlertView *connectFailMessage = [[UIAlertView alloc] initWithTitle:@"NSURLConnection"
                                                                                     message:@"Not success"
                                                                                    delegate:self
                                                                           cancelButtonTitle:@"Ok"
                                                                           otherButtonTitles:nil];
                        [connectFailMessage show];
                        //            }
                    }

                } else {
                    if (!self.isCity)
                    {
                        [Singleton titlesTranslation_withISfromSettings:YES];
                    }

                    [self performSelector:@selector(complete:) withObject:nil];
                }
                
                
            }
            else
            {
                if (checkConnection.hasConnectivity) {
                    if (self.selectedIndex != NSNotFound)
                    {
                        UITableViewCell *cell = [tableView
                                                 cellForRowAtIndexPath:[NSIndexPath
                                                                        indexPathForRow:self.selectedIndex inSection:0]];
                        cell.accessoryType = UITableViewCellAccessoryNone;
                    }
                    self.selectedIndex = indexPath.row;
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    [[NSUserDefaults standardUserDefaults] setObject:data forKey:changeStringForUserDefaults];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:data forKey:wasDownloaded];
                    
                    // http request updatePHP with &tag=rmp
                    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@%@%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"dbLink"], @"/Customer_Scripts/update.php?", [[NSUserDefaults standardUserDefaults] valueForKey:@"DBid"], @"&tag=update_t"];
                    [urlString appendFormat:@"&lang_id=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"defaultLanguageId"]];
                    [urlString appendFormat:@"&city_id=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"defaultCityId"]];
                    
                    NSArray *productArray = [[NSArray alloc] initWithArray:[self.content getArrayFromCoreDatainEntetyName:@"Products" withSortDescriptor:@"underbarid"]];
                    NSArray *restaurantArray = [[NSArray alloc] initWithArray:[self.content getArrayFromCoreDatainEntetyName:@"Restaurants" withSortDescriptor:@"underbarid"]];
                    NSArray *menuArray = [[NSArray alloc] initWithArray:[self.content getArrayFromCoreDatainEntetyName:@"Menus" withSortDescriptor:@"underbarid"]];
                    
                    int prod_v = 0;
                    int mprod_id = [[[productArray objectAtIndex:[productArray count]-1] valueForKey:@"underbarid"] intValue];
                    
                    int rest_v = 0;
                    int mrest_id = [[[restaurantArray objectAtIndex:[restaurantArray count]-1] valueForKey:@"underbarid"] intValue];
                    
                    int menu_v = 0;
                    int mmenu_id = [[[menuArray objectAtIndex:[menuArray count]-1] valueForKey:@"underbarid"] intValue];
                    
                    for (int i = 0; i < productArray.count; i++) {
                        if ([[[productArray objectAtIndex:i] valueForKey:@"version"] intValue] > prod_v) {
                            prod_v = [[[productArray objectAtIndex:i] valueForKey:@"version"] intValue];
                        }
                    }
                    for (int i = 0; i < restaurantArray.count; i++) {
                        if ([[[restaurantArray objectAtIndex:i] valueForKey:@"version"] intValue] > rest_v) {
                            rest_v = [[[restaurantArray objectAtIndex:i] valueForKey:@"version"] intValue];
                        }
                    }
                    for (int i = 0; i < menuArray.count; i++) {
                        if ([[[menuArray objectAtIndex:i] valueForKey:@"version"] intValue] > menu_v) {
                            menu_v = [[[menuArray objectAtIndex:i] valueForKey:@"version"] intValue];
                        }
                    }
                    
                    [urlString appendFormat:@"&prod_v=%u", prod_v];
                    [urlString appendFormat:@"&mprod_id=%u", mprod_id];
                    [urlString appendFormat:@"&rest_v=%u", rest_v];
                    [urlString appendFormat:@"&mrest_id=%u", mrest_id];
                    [urlString appendFormat:@"&menu_v=%u", menu_v];
                    [urlString appendFormat:@"&mmenu_id=%u", mmenu_id];
                    
                    NSURL *url = [NSURL URLWithString:urlString.copy];
                    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
                    [request setHTTPMethod:@"GET"];
                    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
                    if (!theConnection)
                    {
                        // Inform the user that the connection failed.
                        UIAlertView *connectFailMessage = [[UIAlertView alloc] initWithTitle:@"NSURLConnection"
                                                                                     message:@"Not success"
                                                                                    delegate:self
                                                                           cancelButtonTitle:@"Ok"
                                                                           otherButtonTitles:nil];
                        [connectFailMessage show];
                        //            }
                    }
                    
                    self.cityWithIdDictionary = [[NSMutableDictionary alloc] init];
                    
                    [self.cityWithIdDictionary setValue: [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"defaultCityId"]] forKey:@"idCity"];
                    [self.cityWithIdDictionary setValue:[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"defaultLanguageId"]] forKey:@"idLanguage"];
                    
                    [self.content addObjectToCoreDataEntity:@"CheckChangesSettings" withDictionaryOfAttributes:self.cityWithIdDictionary.copy];
                } else {
                    [self.hudView failAndDismissWithTitle:self.titleUnableFetchData];
                    [self performSelector:@selector(pop:) withObject:nil afterDelay:1];
                }
                
            }
        }
        
//        if (self.selectedIndex != NSNotFound)
//        {
//            UITableViewCell *cell = [tableView
//                                     cellForRowAtIndexPath:[NSIndexPath
//                                                            indexPathForRow:self.selectedIndex inSection:0]];
//            cell.accessoryType = UITableViewCellAccessoryNone;
//        }
//        self.selectedIndex = indexPath.row;
//        cell.accessoryType = UITableViewCellAccessoryCheckmark;
//        [[NSUserDefaults standardUserDefaults] setObject:data forKey:changeStringForUserDefaults];
//        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //[self.navigationController popViewControllerAnimated:YES];
        
        
        //        if ([[NSUserDefaults standardUserDefaults] objectForKey:wasDownloaded] != nil)
        //        {
        //            // http request updatePHP with &tag=update
        //            GettingCoreContent *content = [[GettingCoreContent alloc] init];
        //
        //            NSNumber *maxRestaurantId = [content fetchMaximumNumberOfAttribute:@"underbarid" fromEntity:@"Restaurants"];
        //            NSNumber *maxRestaurantVersion = [content fetchMaximumNumberOfAttribute:@"version" fromEntity:@"Restaurants"];
        //
        //            NSNumber *maxMenuId = [content fetchMaximumNumberOfAttribute:@"underbarid" fromEntity:@"Menus"];
        //            NSNumber *maxMenuVersion = [content fetchMaximumNumberOfAttribute:@"version" fromEntity:@"Menus"];
        //
        //            NSNumber *maxProductId = [content fetchMaximumNumberOfAttribute:@"underbarid" fromEntity:@"Products"];
        //            NSNumber *maxProductVersion = [content fetchMaximumNumberOfAttribute:@"version" fromEntity:@"Products"];
        //
        //            NSMutableString *myString = [NSMutableString stringWithString: @"http://matrix-soft.org/clients/Customer_Scripts/update.php?DBid=3&tag=update"];
        //
        //            [myString appendFormat:@"&city_id=%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"defaultCityId"]];
        //            [myString appendFormat:@"&lang_id=%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"defaultLanguageId"]];
        //
        //            [myString appendFormat:@"&rest_v=%@", maxRestaurantVersion];
        //            [myString appendFormat:@"&mrest_id=%@", maxRestaurantId];
        //
        //            [myString appendFormat:@"&menu_v=%@", maxMenuVersion];
        //            [myString appendFormat:@"&mmenu_id=%@", maxMenuId];
        //
        //            [myString appendFormat:@"&prod_v=%@", maxProductVersion];
        //            [myString appendFormat:@"&mprod_id=%@", maxProductId];
        //
        //            NSURL *url = [NSURL URLWithString:myString.copy];
        //            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        //            [request setHTTPMethod:@"GET"];
        //            NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        //            if (!theConnection)
        //            {
        //                // Inform the user that the connection failed.
        //                UIAlertView *connectFailMessage = [[UIAlertView alloc] initWithTitle:@"NSURLConnection"
        //                                                                             message:@"Not success"
        //                                                                            delegate:self
        //                                                                   cancelButtonTitle:@"Ok"
        //                                                                   otherButtonTitles:nil];
        //                [connectFailMessage show];
        //            }
        ////            NSArray *arrayOfCartsIds = [content fetchAllIdsFromEntity:@"Cart"];
        ////            NSArray *arrayOfFavoritesIds = [content fetchAllIdsFromEntity:@"Favorites"];
        //
        //        }
        //        else
        //        {
//        [[NSUserDefaults standardUserDefaults] setObject:data forKey:wasDownloaded];
//        // http request updatePHP with &tag=rmp
//        NSMutableString *urlString = [NSMutableString stringWithString: @"http://matrix-soft.org/clients/Customer_Scripts/update.php?DBid=3&tag=rmp"];
//        [urlString appendFormat:@"&idLang=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"defaultLanguageId"]];
//        [urlString appendFormat:@"&idCity=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"defaultCityId"]];
//        NSURL *url = [NSURL URLWithString:urlString.copy];
//        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
//        [request setHTTPMethod:@"GET"];
//        NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
//        if (!theConnection)
//        {
//            // Inform the user that the connection failed.
//            UIAlertView *connectFailMessage = [[UIAlertView alloc] initWithTitle:@"NSURLConnection"
//                                                                         message:@"Not success"
//                                                                        delegate:self
//                                                               cancelButtonTitle:@"Ok"
//                                                               otherButtonTitles:nil];
//            [connectFailMessage show];
//            //            }
//        }
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"You do not have internet connecntion to update data" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

#pragma connection with server

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
    //NSString *txt = [[NSString alloc] initWithData:self.responseData encoding: NSASCIIStringEncoding];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Unable to fetch data");
    
    [self.hudView failAndDismissWithTitle:self.titleUnableFetchData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Succeeded! Received %d bytes of data",[self.responseData
                                                   length]);
    NSString *txt = [[NSString alloc] initWithData:self.responseData encoding: NSASCIIStringEncoding];
    NSLog(@"strinng is - %@",txt);
    
    // создаем парсер
    XMLParse* parser = [[XMLParse alloc] initWithData:self.responseData];
    [parser setDelegate:parser];
    [parser parse];
    self.db = parser;
    [self XMLToCoreData];
    
    if (!self.isCity)
    {
        [Singleton titlesTranslation_withISfromSettings:YES];
    }
    
    [self performSelector:@selector(complete:) withObject:nil];
//    if (!self.isCity)
//    {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil/*Success*/ message:self.titleSuccesLanguage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alertView show];
//    }
    
    //[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - hudView Actions

- (void)complete:(id)sender {
	[self.hudView completeWithTitle:self.titleFinished];
	[self performSelector:@selector(pop:) withObject:nil afterDelay:0.9];
}


- (void)pop:(id)sender {
	[self.hudView dismiss];
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma finish pragma connention with server

- (void)XMLToCoreData
{
    NSArray *allKeys = [self.db.tables allKeys];
    GettingCoreContent *content = [[GettingCoreContent alloc] init];
    if (!self.isCity)
    {
        for(int i = 0; i< allKeys.count; i++)
        {
            id key = [allKeys objectAtIndex:i];
            if (![key isEqualToString:@"Pictures"])
            {
                id object = [self.db.tables objectForKey:key];
                if(object)
                    [content setCoreDataForEntityWithName:key dictionaryOfAtributes:object];
            }
        }
    }
    else
    {
        for(int i = 0; i< allKeys.count; i++)
        {
            id key = [allKeys objectAtIndex:i];
            id object = [self.db.tables objectForKey:key];
            if(object)
                [content setCoreDataForEntityWithName:key dictionaryOfAtributes:object];
        }
    }
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Prive methods

-(void)setAllTitlesOnThisPage
{
    NSArray *array = [Singleton titlesTranslation_withISfromSettings:NO];
    for (int i = 0; i <array.count; i++)
    {
        if ([[[array objectAtIndex:i] valueForKey:@"name_EN"] isEqualToString:@"Loading..."])
        {
            self.titleLoading = [[array objectAtIndex:i] valueForKey:@"title"];
        }
        
        else if ([[[array objectAtIndex:i] valueForKey:@"name_EN"] isEqualToString:@"Finished"])
        {
            self.titleFinished = [[array objectAtIndex:i] valueForKey:@"title"];
        }
        
        else if ([[[array objectAtIndex:i] valueForKey:@"name_EN"] isEqualToString:@"Please. Relaunch application to see all changes"])
        {
            self.titleSuccesLanguage = [[array objectAtIndex:i] valueForKey:@"title"];
        }
        
        else if ([[[array objectAtIndex:i] valueForKey:@"name_EN"] isEqualToString:@"Unable to fetch data"])
        {
            self.titleUnableFetchData = [[array objectAtIndex:i] valueForKey:@"title"];
        }
    }
}
@end