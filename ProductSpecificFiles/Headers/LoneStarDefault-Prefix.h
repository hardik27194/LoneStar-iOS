//
//  LoneStar-Prefix.pch
//  LoneStar
//
//  Created by sandeep on 10/30/15.
//  Copyright © 2015 Medpresso. All rights reserved.
//

#ifndef LoneStar_Prefix_h
#define LoneStar_Prefix_h

// Include any system framework and library headers here that should be included in all compilation units.
// You will also need to set the Prefix Header build setting of one or more of your targets to reference this file.
//
//  Prefix header
//
//  The contents of this file are implicitly included at the beginning of every source file.
//
#ifdef __OBJC__
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#endif

// PDF
#define IMPORT_PDF_VIEWER

// Begin - Sandeep inspired from  http://www.cimgf.com/2010/05/02/my-current-prefix-pch-file/
#ifdef DEBUG
#define DLog(...) NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])
#define ALog(...) [[NSAssertionHandler currentHandler] handleFailureInFunction:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding] file:[NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding] lineNumber:__LINE__ description:__VA_ARGS__]
#else
#define DLog(...) do { } while (0)
#ifndef NS_BLOCK_ASSERTIONS
#define NS_BLOCK_ASSERTIONS
#endif
#define ALog(...) NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])
#endif

#define ZAssert(condition, ...) do { if (!(condition)) { ALog(__VA_ARGS__); }} while(0)
// End of http://www.cimgf.com/2010/05/02/my-current-prefix-pch-file/



#define IS_IPAD  ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

#define IS_IOS7 ((floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1))

#define IS_IOS8 ((floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1))

#define HAS_BIOMETRIC_SUPPORT ([LAContext class])

#define IS_MAP_LOCATION_ZERO(x)    (((x).latitude == 0.0) && ((x).longitude == 0.0))


#endif /* LoneStar_Prefix_pch */
