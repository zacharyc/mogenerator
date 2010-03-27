#import <CoreData/CoreData.h>

@interface NSManagedObjectModel (mogeneratorExtensions)
- (NSArray*)entitiesWithACustomSubclass:(NSString*)customBaseClass;
@end
