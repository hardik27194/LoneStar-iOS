//
//  CSVParser.m
//  CSVParser
//
//

#import "CSVParser.h"

@interface CSVParser()
+ (NSArray *)trimComponents:(NSArray *)array withCharacters:(NSString *)characters;
@end

@implementation CSVParser

+ (NSArray *)trimComponents:(NSArray *)array withCharacters:(NSString *)characters
{
    NSMutableArray *marray = [[NSMutableArray alloc] initWithCapacity:array.count];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [marray addObject:[obj stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:characters]]];
    }];
    return marray;
}

+ (void)parseCSVIntoArrayOfDictionariesFromFile:(NSString *)path
                   withSeparatedCharacterString:(NSString *)character
                           quoteCharacterString:(NSString *)quote
                               firstRowIsHeader: (BOOL) headerExpected
                                      withBlock:(void (^)(NSArray *array, NSError *error))block
{
    dispatch_queue_t queue = dispatch_queue_create("parseQueue", NULL);
    dispatch_async(queue, ^{
        NSError *err = nil;
        NSMutableArray *mutArray = [[NSMutableArray alloc] init];
        NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
        if (!content) return;
        NSString *delimiter;
        if ([content rangeOfString:@"\n\r"].location != NSNotFound) {
            DLog(@"Delimiter \\n\\r"); delimiter = @"\n\r";
        } else if ([content rangeOfString:@"\r"].location != NSNotFound) {
            DLog(@"Delimiter \\r"); delimiter = @"\r";
        } else if ([content rangeOfString:@"\n"].location != NSNotFound) {
            DLog(@"Delimiter \\n"); delimiter = @"\n";
        } else {
            DLog(@"ERROR in DELIMITER");
        }
        NSArray *rows;
        if (delimiter) {
            rows = [content componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:delimiter]];
        } else {
            rows = @[content];
            
        }
        NSString *trimStr = (quote != nil) ? [quote stringByAppendingString:@"\n\r "] : @"\n\r ";
        
        NSMutableArray *keys;
        if (headerExpected)
            keys = [NSMutableArray arrayWithArray: [CSVParser trimComponents:[[rows objectAtIndex:0] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:character]]
                                   withCharacters:trimStr]];
        for (int i = headerExpected?1:0; i < rows.count; i++) {
            NSArray *objects = [CSVParser trimComponents:[[rows objectAtIndex:i] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:character]]
                                          withCharacters:trimStr];
            if (!keys && !headerExpected) {
                keys = [[NSMutableArray alloc] init];
                // Create keys based on the first ROW - it has to be the same number of entries for the rest of the file
                for (int j=0; j < [objects count]; j++) {
                    [keys addObject:[NSString stringWithFormat:@"key%d", j]];
                }
                //
            }
            if ([objects count] != [keys count]) {
                DLog(@"SKIPPING row: %d - Error in Entry: %@", i, [rows objectAtIndex:i]);
                
            } else {
                [mutArray addObject:[NSDictionary dictionaryWithObjects:objects forKeys:keys]];
            }
        }
        if (block) {
//            dispatch_async(callerQueue, ^{
                block(mutArray, err);
//            });
        }
    });
}

+ (void)parseCSVIntoArrayOfArraysFromFile:(NSString *)path
             withSeparatedCharacterString:(NSString *)character
                     quoteCharacterString:(NSString *)quote
                                withBlock:(void (^)(NSArray *array, NSError *error))block
{
    dispatch_queue_t queue = dispatch_queue_create("parseQueue", NULL);
    
    dispatch_async(queue, ^{
        NSError *err = nil;
        NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
        NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
        if (!content) return;
        NSArray *rows = [content componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r"]];
        NSString *trimStr = (quote != nil) ? [quote stringByAppendingString:@"\n\r "] : @"\n\r ";
        [rows enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [mutableArray addObject:[CSVParser trimComponents:[obj componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:character]]
                                               withCharacters:trimStr]];
        }];
        if (block) {
                block(mutableArray, err);
        }
    });
}

+ (NSArray *)parseCSVIntoArrayOfDictionariesFromFile:(NSString *)path
                        withSeparatedCharacterString:(NSString *)character
                                quoteCharacterString:(NSString *)quote
{
    NSError *error = nil;
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];    
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (!content) return nil;
    NSArray *rows = [content componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r"]];
    NSString *trimStr = (quote != nil) ? [quote stringByAppendingString:@"\n\r "] : @"\n\r ";
    NSArray *keys = [CSVParser trimComponents:[[rows objectAtIndex:0] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:character]]
                               withCharacters:trimStr];
    for (int i = 1; i < rows.count; i++) {
        NSArray *objects = [CSVParser trimComponents:[[rows objectAtIndex:i] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:character]]
                                      withCharacters:trimStr];
        [mutableArray addObject:[NSDictionary dictionaryWithObjects:objects forKeys:keys]];
    }
    return mutableArray;
}


+ (NSArray *)parseCSVIntoArrayOfArraysFromFile:(NSString *)path
                  withSeparatedCharacterString:(NSString *)character
                          quoteCharacterString:(NSString *)quote
{
    NSError *error = nil;
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (!content) return nil;
    NSArray *rows = [content componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r"]];
    NSString *trimStr = (quote != nil) ? [quote stringByAppendingString:@"\n\r "] : @"\n\r ";
    [rows enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [mutableArray addObject:[CSVParser trimComponents:[obj componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:character]]
                                           withCharacters:trimStr]];
    }];
    return mutableArray;
}

@end
