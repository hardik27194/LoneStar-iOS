//
//  MoPDFGenerator.h
//  MobiusoPDFGen
//
//  Created by Sandeep on 2014/07/31.
//  Copyright (c) 2014 Sandeep Shah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MoPDFGenerator : NSObject

+(NSString *)generatePDFFromAttributedString:(NSAttributedString *)str withHeader: (NSAttributedString *) header andFooter: (NSAttributedString *) footer;
+(NSString *)generatePDFFromNSString:(NSString *)str;
+(NSString *)generatePDFFromHTMLString:(NSString *)str;
+(NSString *)generatePDFFromHTMLString:(NSString *)html withHeader: (NSString *)hHtml andFooter: (NSString *) fHtml;
+(NSString *)generatePDFFromMarkDownString:(NSString *)md;

@end
