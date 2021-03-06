//
//  ProductDataStruct.m
//  Restaurant
//
//  Created by Bogdan Geleta on 24.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProductDataStruct.h"

@implementation ProductDataStruct

@synthesize productId = _productId;
@synthesize price = _price;
@synthesize customPrice = _customPrice;
@synthesize image = _image;
@synthesize descriptionText = _descriptionText;
@synthesize title = _title;
@synthesize count = _count;
@synthesize sizeId = _sizeId;
@synthesize idPicture = _idPicture;
@synthesize idMenu = _idMenu;
@synthesize link = _link;
@synthesize isFavorites = _isFavorites;
@synthesize isTopping = _isTopping;
@synthesize isMultisize = _isMultisize;
@synthesize hit = _hit;
@synthesize discountValue = _discountValue;
@synthesize weight = _weight;
@synthesize protein = _protein;
@synthesize carbs = _carbs;
@synthesize fats = _fats;
@synthesize calories = _calories;

- (NSNumber *)count
{
    if(!_count)
    {
        _count = [[NSNumber alloc] initWithInteger:1];
        return _count;
    }
    else return _count;
    
}

- (id)initWithDictionary:(NSMutableDictionary *)aDictionary
{
    self.productId = [aDictionary objectForKey:@"productId"];
    self.price = [aDictionary objectForKey:@"price"];
    self.customPrice = [aDictionary objectForKey:@"customPrice"];
    //self.image = [aDictionary objectForKey:@"image"];
    self.descriptionText = [aDictionary objectForKey:@"descriptionText"];
    self.title = [aDictionary objectForKey:@"title"];
    self.count = [aDictionary objectForKey:@"count"];
    self.discountValue = [aDictionary objectForKey:@"idDiscount"];
    self.isFavorites = [aDictionary objectForKey:@"isFavorites"];
    self.isTopping = [aDictionary objectForKey:@"isTopping"];
    self.isMultisize = [aDictionary objectForKey:@"isMultisize"];
    self.weight = [aDictionary objectForKey:@"weight"];
    self.protein = [aDictionary objectForKey:@"protein"];
    self.carbs = [aDictionary objectForKey:@"carbs"];
    self.fats = [aDictionary objectForKey:@"fats"];
    self.calories = [aDictionary objectForKey:@"calories"];
    self.hit = [aDictionary objectForKey:@"hit"];
    self.idMenu = [aDictionary objectForKey:@"idMenu"];
    return self;
    
}

- (NSDictionary *)getDictionaryDependOnDataStruct
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    [result setObject:self.price forKey:@"price"];
    [result setObject:self.customPrice forKey:@"customPrice"];
    [result setObject:self.productId forKey:@"productId"];
    [result setObject:self.descriptionText forKey:@"descriptionText"];
    [result setObject:self.title forKey:@"title"];
    [result setObject:self.count forKey:@"count"];
    [result setObject:self.discountValue forKey:@"idDiscount"];
    [result setObject:self.isFavorites forKey:@"isFavorites"];
    [result setObject:self.isTopping forKey:@"isTopping"];
    [result setObject:self.isMultisize forKey:@"isMultisize"];
    [result setObject:self.weight forKey:@"weight"];
    [result setObject:self.protein forKey:@"protein"];
    [result setObject:self.carbs forKey:@"carbs"];
    [result setObject:self.fats forKey:@"fats"];
    [result setObject:self.calories forKey:@"calories"];
    [result setObject:self.hit forKey:@"hit"];
    [result setObject:self.idMenu forKey:@"idMenu"];
    return result.copy;
}

@end
