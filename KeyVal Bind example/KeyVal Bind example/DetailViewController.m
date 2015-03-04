//
//  DetailViewController.m
//  KeyVal Bind example
//
//  Created by Anders Borum on 04/03/15.
//
//

#import "DetailViewController.h"

@interface DetailViewController ()
@property (strong, nonatomic) IBOutlet UITextField *titleField;
@property (strong, nonatomic) IBOutlet UITextField *summaryField;

@end

@implementation DetailViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleField.text = self.item.title;
    self.summaryField.text = self.item.summary;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // determine replacement text
    NSString* replacement = [textField.text stringByReplacingCharactersInRange:range
                                                                    withString:string];
    if(replacement == nil) replacement = string;
    
    if(textField == self.titleField) self.item.title = replacement;
    else if (textField == self.summaryField) self.item.summary = replacement;
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField == self.titleField) [self.summaryField becomeFirstResponder];
    else [textField resignFirstResponder];
    
    return YES;
}


@end
