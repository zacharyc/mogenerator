#import <CoreData/CoreData.h>

@interface NSEntityDescription (mogeneratorExtensions)

- (BOOL)hasCustomSuperentity;
- (NSString*)customSuperentity;
- (NSArray*)prettyFetchRequests;

@end
