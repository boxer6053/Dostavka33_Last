//
//  IngredientCell.m
//  Restaurant
//
//  Created by Alex on 10/27/12.
//
//

#import "IngredientCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation IngredientCell
@synthesize ingredientName = _ingredientName;
@synthesize ingredientPrice = _ingredientPrice;
@synthesize addButton = _addButton;
@synthesize isAdded = _isAdded;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
//    CAGradientLayer *gradient = [CAGradientLayer layer];
//    gradient.frame = self.bounds;
//    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:115.0/255.0 green:115.0/255.0 blue:115.0/255.0 alpha:1.0] CGColor],(id)[[UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1.0] CGColor], nil];
//    [self.layer insertSublayer:gradient atIndex:0];
}

- (IBAction)addButtonClicked:(id)sender {
    if(!self.isAdded)
    {
        [self.addButton setBackgroundImage:[UIImage imageNamed:@"Checkbox_checked_40px.png"] forState:UIControlStateNormal];
        self.isAdded = YES;
    }
    else
    {
        [self.addButton setBackgroundImage:[UIImage imageNamed:@"Checkbox_unchecked_40px.png"] forState:UIControlStateNormal];
        self.isAdded = NO;
    }
}
@end
