//
//  UIApplication+MoImageViewController.m
//
//
//

#import "UIApplication+MoImageViewController.h"

@implementation UIApplication (MoImageViewController)

- (BOOL)jts_usesViewControllerBasedStatusBarAppearance {
    static dispatch_once_t once;
    static BOOL viewControllerBased;
    dispatch_once(&once, ^ {
        NSString *key = @"UIViewControllerBasedStatusBarAppearance";
        id object = [[NSBundle mainBundle] objectForInfoDictionaryKey:key];
        viewControllerBased = [object boolValue];
    });
    return viewControllerBased;
}

@end
