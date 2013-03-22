//
//  IngredientCell.h
//  Restaurant
//
//  Created by Alex on 10/27/12.
//
//

#import <UIKit/UIKit.h>

@interface IngredientCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *ingredientName;
@property (weak, nonatomic) IBOutlet UILabel *ingredientPrice;
@property (weak, nonatomic) IBOutlet UIImageView *ingredientImageView;
@property (nonatomic) BOOL isAdded;
- (IBAction)addButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *addButton;

@end
