#import "NSString+camelCaseString.h"
#import "FoundationAdditions.h"
#import "NSString+MiscAdditions.h"

@implementation NSString (camelCaseString)

- (NSString*)camelCaseString {
	NSArray *lowerCasedWordArray = [[self wordArray] arrayByMakingObjectsPerformSelector:@selector(lowercaseString)];
    
	unsigned wordIndex = 1, wordCount = [lowerCasedWordArray count];
	NSMutableArray *camelCasedWordArray = [NSMutableArray arrayWithCapacity:wordCount];
    
	if (wordCount) {
		[camelCasedWordArray addObject:[lowerCasedWordArray objectAtIndex:0]];
    }
	for (; wordIndex < wordCount; wordIndex++) {
		[camelCasedWordArray addObject:[[lowerCasedWordArray objectAtIndex:wordIndex] initialCapitalString]];
	}
	return [camelCasedWordArray componentsJoinedByString:@""];
}

@end
