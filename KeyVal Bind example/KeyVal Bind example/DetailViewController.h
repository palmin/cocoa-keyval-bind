//
//  DetailViewController.h
//  KeyVal Bind example
//
//  Created by Anders Borum on 04/03/15.
//
//

#import <UIKit/UIKit.h>
#import "Model.h"

@interface DetailViewController : UIViewController <UITextFieldDelegate>
@property (strong, nonatomic) Model* item;

@end

