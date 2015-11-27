//
//  Design.m
//  WeatherApp
//
//  Created by Alex Sheverdin on 11/27/15.
//  Copyright © 2015 Alex Sheverdin. All rights reserved.
//

#import "Design.h"

@implementation UILabel (WeatherDesign)

+ (UILabel *)navigationTitle:(NSString *)title andSubtitle:(NSString *)subtitle {
    
    NSMutableAttributedString *attributedTitle =[[NSMutableAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:21.0]}];
    NSAttributedString *attributedSubtitle =[[NSAttributedString alloc] initWithString:subtitle attributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:14.0]}];
    [attributedTitle appendAttributedString:attributedSubtitle];
    
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],
                                 NSParagraphStyleAttributeName:paragraphStyle};
    [attributedTitle addAttributes:attributes range:NSMakeRange(0, [attributedTitle length])];
    
    UILabel *label = [[UILabel alloc] init];
    label.attributedText=attributedTitle;
    label.numberOfLines = 0;
    [label sizeToFit];
    return label;
}

@end