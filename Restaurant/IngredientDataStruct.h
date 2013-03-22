//
//  IngredientDataStruct.h
//  Restaurant
//
//  Created by Alex on 11/13/12.
//
//

#import <Foundation/Foundation.h>

@interface IngredientDataStruct : NSObject

@property (nonatomic) NSNumber *ingredientId;
@property (strong, nonatomic) NSString *price;
@property (strong, nonatomic) NSString *weight;
@property (strong, nonatomic) NSString *idPicrure;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *descriptionText;
@property (nonatomic) BOOL isInCurrentProduct;

@end
