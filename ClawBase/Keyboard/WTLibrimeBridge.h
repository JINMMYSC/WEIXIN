#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WTLibrimeCandidateRecord : NSObject
@property(nonatomic, copy, readonly) NSString *text;
@property(nonatomic, copy, readonly) NSString *comment;
- (instancetype)initWithText:(NSString *)text comment:(NSString *)comment;
@end

@interface WTLibrimeContextSnapshot : NSObject
@property(nonatomic, copy, readonly) NSString *composition;
@property(nonatomic, copy, readonly) NSArray<WTLibrimeCandidateRecord *> *candidates;
@property(nonatomic, assign, readonly) BOOL composing;
@property(nonatomic, assign, readonly) NSInteger pageNumber;
@property(nonatomic, assign, readonly) NSInteger pageSize;
@property(nonatomic, assign, readonly) BOOL lastPage;
@property(nonatomic, assign, readonly) NSInteger compositionLength;
@property(nonatomic, assign, readonly) NSInteger cursorPosition;
@property(nonatomic, assign, readonly) NSInteger selectionStart;
@property(nonatomic, assign, readonly) NSInteger selectionEnd;
- (instancetype)initWithComposition:(NSString *)composition
                         candidates:(NSArray<WTLibrimeCandidateRecord *> *)candidates
                          composing:(BOOL)composing
                         pageNumber:(NSInteger)pageNumber
                           pageSize:(NSInteger)pageSize
                           lastPage:(BOOL)lastPage
                  compositionLength:(NSInteger)compositionLength
                     cursorPosition:(NSInteger)cursorPosition
                     selectionStart:(NSInteger)selectionStart
                       selectionEnd:(NSInteger)selectionEnd;
@end

@interface WTLibrimeBridge : NSObject
@property(nonatomic, assign, readonly, getter=isReady) BOOL ready;
@property(nonatomic, copy, readonly) NSString *lastError;
@property(nonatomic, copy, readonly) NSString *currentSchemaID;

- (instancetype)initWithSharedDataDir:(NSString *)sharedDataDir
                          userDataDir:(NSString *)userDataDir;
- (WTLibrimeContextSnapshot *)snapshot;
- (BOOL)processText:(NSString *)text;
- (nullable NSString *)drainCommit;
- (BOOL)selectSchema:(NSString *)schemaID;
- (void)setOption:(NSString *)option value:(BOOL)value;
- (void)setProperty:(NSString *)property value:(NSString *)value;
- (BOOL)movePage:(NSInteger)direction;
- (nullable NSString *)selectCandidateAtIndex:(NSInteger)index;
- (void)deleteBackward;
- (void)reset;
@end

NS_ASSUME_NONNULL_END
