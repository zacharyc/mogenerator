#import "NSManagedObjectModel+mogeneratorExtensions.h"
#import "JRLog.h"
#import "nsenumerate.h"

@implementation NSManagedObjectModel (mogeneratorExtensions)

- (NSArray*)entitiesWithACustomSubclass:(NSString*)customBaseClass {
	NSMutableArray *result = [NSMutableArray array];
	
	if([[self entities] count] == 0){
        JRLogInfo(@"No entities found in model. No files will be generated.\n(model description: %@)\n", self);
	}
	
	nsenumerate ([self entities], NSEntityDescription, entity) {
		NSString *entityClassName = [entity managedObjectClassName];
		
		if ([entityClassName isEqualToString:@"NSManagedObject"] || [entityClassName isEqualToString:customBaseClass]){
            JRLogInfo(@"skipping entity %@ because it doesn't use a custom subclass.\n", entityClassName);
		} else {
			[result addObject:entity];
		}
	}
    
    NSArray *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"managedObjectClassName"
                                                           ascending:YES] autorelease];
	return [result sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}

@end
