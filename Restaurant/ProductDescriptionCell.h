//
//  ProductDescriptionCell.h
//  Restaurant
//
//  Created by Alex on 10/29/12.
//
//

#import <UIKit/UIKit.h>

@interface ProductDescriptionCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *captionLabel;
@property (weak, nonatomic) IBOutlet UILabel *nilCaption;
@property (weak, nonatomic) IBOutlet UILabel *proteinLabel;
@property (weak, nonatomic) IBOutlet UILabel *fatLabel;
@property (weak, nonatomic) IBOutlet UILabel *carbohydratesLabel;
@property (weak, nonatomic) IBOutlet UILabel *kCalLabel;
@property (weak, nonatomic) IBOutlet UILabel *portionLabel;
@property (weak, nonatomic) IBOutlet UILabel *portionProteinLabel;
@property (weak, nonatomic) IBOutlet UILabel *portionFatLabel;
@property (weak, nonatomic) IBOutlet UILabel *portionCarbohydratesLabel;
@property (weak, nonatomic) IBOutlet UILabel *portionKCalLabel;
@property (weak, nonatomic) IBOutlet UILabel *in100gLabel;
@property (weak, nonatomic) IBOutlet UILabel *in100gProteinLabel;
@property (weak, nonatomic) IBOutlet UILabel *in100gFatLabel;
@property (weak, nonatomic) IBOutlet UILabel *in100gCarbohydratesLabel;
@property (weak, nonatomic) IBOutlet UILabel *in100gKCalLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightLabel;
@end
