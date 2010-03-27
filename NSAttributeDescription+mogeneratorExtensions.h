#import <CoreData/CoreData.h>

@interface NSAttributeDescription (mogeneratorExtensions)

- (BOOL)hasScalarAttributeType;
- (NSString*)scalarAttributeType;
- (BOOL)hasDefinedAttributeType;
- (NSString*)objectAttributeType;

@end
