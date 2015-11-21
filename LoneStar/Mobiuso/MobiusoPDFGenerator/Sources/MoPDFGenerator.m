//
//  MoPDFGenerator.m
//  MobiusoPDFGen
//
//  Created by Sandeep on 2014/07/31.
//  Copyright (c) 2014 Sandeep Shah. All rights reserved.
//
//  Support for Header/Footer added - images TBD
//
//  Reference - Oliver Rickard

#import "MoPDFGenerator.h"
#import <CoreText/CoreText.h>
#import "DTCoreText/DTCoreText.h"
#import "NSString+GHMarkdownParser.h"

@implementation MoPDFGenerator

+ (NSString *) generatePDFFromAttributedString:(NSAttributedString *)str withHeader: (NSAttributedString *) header andFooter: (NSAttributedString *) footer {
    //create a CFUUID - it knows how to create unique identifiers
    CFUUIDRef newUniqueID = CFUUIDCreate (kCFAllocatorDefault);
    
    //create a string from unique identifier
    NSString * newUniqueIDString = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, newUniqueID));
    
    NSString *fileName = [NSString stringWithFormat:@"%@.pdf", newUniqueIDString];
    DLog(@"newUniqueID %p", newUniqueID);
    DLog(@"newUniqueIDString %p", newUniqueIDString);
    DLog(@"fileName %p", fileName);
    
    CFRelease(newUniqueID);
   // CFRelease((newUniqueIDString));
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *newFilePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    
    DLog(@"paths %p", paths);
    
    int fontSize = 12;
    NSString *font = @"Verdana";
    UIColor *color = [UIColor blackColor];
    
//    NSString *content = str;
    
    int DOC_WIDTH = 612;
    int DOC_HEIGHT = 792;
    int LEFT_MARGIN = 50;
    int RIGHT_MARGIN = 50;
    int TOP_MARGIN = 50;
    int BOTTOM_MARGIN = 50;
    
    int CURRENT_TOP_MARGIN = TOP_MARGIN;
    
    //You can make the first page have a different top margin to place headers, etc.
    int FIRST_PAGE_TOP_MARGIN = TOP_MARGIN;
    
    CGRect a4Page = CGRectMake(0, 0, DOC_WIDTH, DOC_HEIGHT);
    
    NSDictionary *fileMetaData = [[NSDictionary alloc] init];
    DLog(@"filemetadata: %p", fileMetaData);

    
    if (!UIGraphicsBeginPDFContextToFile(newFilePath, a4Page, fileMetaData )) {
        NSLog(@"error creating PDF context");
        return nil;
    }
    
    BOOL done = NO;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CFRange currentRange = CFRangeMake(0, 0);
    
    CGContextSetTextDrawingMode (context, kCGTextFill);
    CGContextSelectFont (context, [font cStringUsingEncoding:NSUTF8StringEncoding], fontSize, kCGEncodingMacRoman);                                                 
    CGContextSetFillColorWithColor(context, [color CGColor]);
    // Initialize an attributed string.
    CFAttributedStringRef attrString = (__bridge CFAttributedStringRef)str;
 
    // Initialize an attributed string for Header
    CFAttributedStringRef hAttrString = (__bridge CFAttributedStringRef)header;

    // Initialize an attributed string for Footer
    CFAttributedStringRef fAttrString = (__bridge CFAttributedStringRef)footer;
    
    // Create the framesetter with the attributed string.
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attrString);
    CTFramesetterRef hFramesetter = CTFramesetterCreateWithAttributedString(hAttrString);
    CTFramesetterRef fFramesetter = CTFramesetterCreateWithAttributedString(fAttrString);
    
    int pageCount = 1;
    
    do {
        UIGraphicsBeginPDFPage();
        
#if 0
        // Try Page # - Sandeep - problem - it flips the page
        CGContextSaveGState(context);
        [self drawPageNumber:pageCount];
        CGContextRestoreGState(context);
#endif
        CGMutablePathRef path = CGPathCreateMutable();
        
        if(pageCount == 1) {
            CURRENT_TOP_MARGIN = FIRST_PAGE_TOP_MARGIN;
        } else {
            CURRENT_TOP_MARGIN = TOP_MARGIN;
        }
        
        CGRect bounds = CGRectMake(LEFT_MARGIN, 
                                   CURRENT_TOP_MARGIN + 42,
                                   DOC_WIDTH - RIGHT_MARGIN - LEFT_MARGIN, 
                                   DOC_HEIGHT - CURRENT_TOP_MARGIN - 84 - BOTTOM_MARGIN);
        
        CGPathAddRect(path, NULL, bounds);
        
        // Create the frame and draw it into the graphics context
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, currentRange, path, NULL);
        
        if(frame) {
            CGContextSaveGState(context);
            CGContextTranslateCTM(context, 0, bounds.origin.y); 
            CGContextScaleCTM(context, 1, -1); 
            CGContextTranslateCTM(context, 0, -(bounds.origin.y + bounds.size.height)); 
            CTFrameDraw(frame, context);
            CGContextRestoreGState(context); 
            
            // Update the current range based on what was drawn.
            currentRange = CTFrameGetVisibleStringRange(frame);
            currentRange.location += currentRange.length;
            currentRange.length = 0;
            
            DLog(@"frame: %p", frame);
            CFRelease(frame);
        }

        DLog(@"path: %p", path);

		CFRelease(path);

        // If we're at the end of the text, exit the loop.
        if (currentRange.location == CFAttributedStringGetLength((CFAttributedStringRef)attrString))
            done = YES;
        
        // Put Header now - begin Sandeep
        if (header) {
            CGRect hBounds = CGRectMake(LEFT_MARGIN,
                                        CURRENT_TOP_MARGIN,
                                        DOC_WIDTH - RIGHT_MARGIN - LEFT_MARGIN,
                                        36);
            CGMutablePathRef hPath = CGPathCreateMutable();
            CGPathAddRect(hPath, NULL, hBounds);
            
            // Create the frame and draw it into the graphics context
            CTFrameRef hFrame = CTFramesetterCreateFrame(hFramesetter, CFRangeMake(0, 0), hPath, NULL);
            
            if(hFrame) {
                CGContextSaveGState(context);
                CGContextTranslateCTM(context, 0, hBounds.origin.y);
                CGContextScaleCTM(context, 1, -1);
                CGContextTranslateCTM(context, 0, -(hBounds.origin.y + hBounds.size.height));
                CTFrameDraw(hFrame, context);
                CGContextRestoreGState(context);
                                
                DLog(@"frame: %p", hFrame);
                CFRelease(hFrame);
            }
            
            DLog(@"path: %p", hPath);
            
            CFRelease(hPath);

        }

        // Put Header now - begin Sandeep
        if (footer) {
            CGRect fBounds = CGRectMake(LEFT_MARGIN,
                                        DOC_HEIGHT - BOTTOM_MARGIN,
                                        DOC_WIDTH - RIGHT_MARGIN - LEFT_MARGIN,
                                        36);
            CGMutablePathRef fPath = CGPathCreateMutable();
            CGPathAddRect(fPath, NULL, fBounds);
            
            // Create the frame and draw it into the graphics context
            CTFrameRef fFrame = CTFramesetterCreateFrame(fFramesetter, CFRangeMake(0, 0), fPath, NULL);
            
            if(fFrame) {
                CGContextSaveGState(context);
                CGContextTranslateCTM(context, 0, fBounds.origin.y);
                CGContextScaleCTM(context, 1, -1);
                CGContextTranslateCTM(context, 0, -(fBounds.origin.y + fBounds.size.height));
                CTFrameDraw(fFrame, context);
                CGContextRestoreGState(context);
                
                DLog(@"frame: %p", fFrame);
                CFRelease(fFrame);
            }
            
            DLog(@"path: %p", fPath);
            
            CFRelease(fPath);
            
        }

        
#if 1
        CGContextSaveGState(context);
        UIImage *ssLogo=[UIImage imageNamed:@"SkyscapeLogo_256x64.png"];
//        CGPoint drawingLogoOrigin = CGPointMake(DOC_WIDTH - RIGHT_MARGIN - 30, DOC_HEIGHT - BOTTOM_MARGIN + 10);
//        [ssLogo drawAtPoint:drawingLogoOrigin];
        [ssLogo drawInRect:CGRectMake(DOC_WIDTH - RIGHT_MARGIN - 60, TOP_MARGIN - 24, 64, 16) blendMode:kCGBlendModeOverlay alpha:0.5];
        UIImage *skillsLogo = [UIImage imageNamed:@"Icon-Mask-2048.png"];
        [skillsLogo drawInRect:CGRectMake(DOC_WIDTH/2 - 128, DOC_HEIGHT/2 - 128, 256, 256) blendMode:kCGBlendModeOverlay alpha:0.05f];
        CGContextRestoreGState(context);
#endif

        pageCount++;
    } while(!done);
    
    UIGraphicsEndPDFContext();
    
    // sandeep [fileMetaData release];
    CFRelease(framesetter);
    DLog(@"newFilePath: %p", newFilePath);
    
    return newFilePath;
}

+ (void)drawPageNumber:(NSInteger)pageNum

{
    
    NSString *pageString = [NSString stringWithFormat:@"Page %ld", (long) pageNum];
    
    UIFont *theFont = [UIFont systemFontOfSize:12];
    
    CGSize maxSize = CGSizeMake(612, 72);
    
    
    
    CGSize pageStringSize = [pageString sizeWithFont:theFont
                             
                                   constrainedToSize:maxSize
                             
                                       lineBreakMode:NSLineBreakByClipping];
    
    CGRect stringRect = CGRectMake(((612.0 - pageStringSize.width) / 2.0),
                                   
                                   720.0 + ((72.0 - pageStringSize.height) / 2.0),
                                   
                                   pageStringSize.width,
                                   
                                   pageStringSize.height);
    
    
    
    [pageString drawInRect:stringRect withFont:theFont];
    
}

+(NSString *)generatePDFFromNSString:(NSString *)str {
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:str];
    return [self generatePDFFromAttributedString:attrStr withHeader:nil andFooter:nil];
}

+(NSString *)generatePDFFromHTMLString:(NSString *)html {
    NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
	
	// Create attributed string from HTML
	CGSize maxImageSize = CGSizeMake(500, 500);
	
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:1.0], NSTextSizeMultiplierDocumentOption, [NSValue valueWithCGSize:maxImageSize], DTMaxImageSize,
                             @"Avenir", DTDefaultFontFamily,  @"blue", DTDefaultLinkColor, nil];
	
	NSAttributedString *string = [[NSAttributedString alloc] initWithHTML:data options:options documentAttributes:NULL];
    
    return [self generatePDFFromAttributedString: string withHeader:nil andFooter:nil];
}

+ (NSString *) generatePDFFromHTMLString:(NSString *)html withHeader: (NSString *)hHtml andFooter: (NSString *) fHtml {
    NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
    NSData *hdata = [hHtml dataUsingEncoding:NSUTF8StringEncoding];
    NSData *fdata = [fHtml dataUsingEncoding:NSUTF8StringEncoding];
	
	// Create attributed string from HTML
	CGSize maxImageSize = CGSizeMake(500, 500);
	
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:1.0], NSTextSizeMultiplierDocumentOption, [NSValue valueWithCGSize:maxImageSize], DTMaxImageSize,
                             @"Avenir", DTDefaultFontFamily,  @"blue", DTDefaultLinkColor, nil];
	
	NSAttributedString *string = [[NSAttributedString alloc] initWithHTML:data options:options documentAttributes:NULL];
 	NSAttributedString *header = [[NSAttributedString alloc] initWithHTML:hdata options:options documentAttributes:NULL];
	NSAttributedString *footer = [[NSAttributedString alloc] initWithHTML:fdata options:options documentAttributes:NULL];
   
    return [self generatePDFFromAttributedString: string withHeader: header andFooter: footer];
}

+ (NSString *) generatePDFFromMarkDownString:(NSString *)md {
    NSString *html = md.HTMLStringFromMarkdown;
    return [self generatePDFFromHTMLString:html];
}

@end
