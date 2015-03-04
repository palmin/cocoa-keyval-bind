//
//  ModelCell.m
//  KeyVal Bind example
//
//  Created by Anders Borum on 04/03/15.
//
//

#import "ModelCell.h"
#import "AB_KeyValueUpdater.h"

@implementation ModelCell

-(void)setItem:(Model *)item {
    [self bindInitialObject:item mapping:@{@"title":   @"textLabel.text",
                                           @"summary": @"detailTextLabel.text"}];
}

@end
