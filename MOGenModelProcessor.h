#import <CoreData/CoreData.h>

@interface MOGenModelProcessorResult : NSObject {
@public
	NSMutableArray	*humanMFiles;   /** @TypeInfo NSString */
	NSMutableArray	*humanHFiles;   /** @TypeInfo NSString */
	NSMutableArray	*machineMFiles; /** @TypeInfo NSString */
	NSMutableArray	*machineHFiles; /** @TypeInfo NSString */
	unsigned		machineFilesGenerated;
	unsigned		humanFilesGenerated;
}
@end

@interface MOGenModelProcessor : NSObject

- (MOGenModelProcessorResult*)processEntities:(NSArray*)entities_ /** @TypeInfo NSEntityDescription */
                              generatingFiles:(BOOL)genFiles_
                             templatesDirPath:(NSString*)templatesDirPath_
                                templateGroup:(NSString*)templateGroup_
                                     humanDir:(NSString*)humanDir_
                                   machineDir:(NSString*)machineDir_
                                        error:(NSError**)error_;

@end
