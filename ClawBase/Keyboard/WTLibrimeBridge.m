#import "WTLibrimeBridge.h"
#import "rime_api.h"

static const int WTKeyBackSpace = 0xff08;
static const int WTKeyPageUp = 0xff55;
static const int WTKeyPageDown = 0xff56;

@implementation WTLibrimeCandidateRecord
- (instancetype)initWithText:(NSString *)text comment:(NSString *)comment {
  if ((self = [super init])) {
    _text = [text copy];
    _comment = [comment copy];
  }
  return self;
}
@end

@implementation WTLibrimeContextSnapshot
- (instancetype)initWithComposition:(NSString *)composition
                         candidates:(NSArray<WTLibrimeCandidateRecord *> *)candidates
                          composing:(BOOL)composing
                         pageNumber:(NSInteger)pageNumber
                           pageSize:(NSInteger)pageSize
                           lastPage:(BOOL)lastPage
                  compositionLength:(NSInteger)compositionLength
                     cursorPosition:(NSInteger)cursorPosition
                     selectionStart:(NSInteger)selectionStart
                       selectionEnd:(NSInteger)selectionEnd {
  if ((self = [super init])) {
    _composition = [composition copy];
    _candidates = [candidates copy];
    _composing = composing;
    _pageNumber = pageNumber;
    _pageSize = pageSize;
    _lastPage = lastPage;
    _compositionLength = compositionLength;
    _cursorPosition = cursorPosition;
    _selectionStart = selectionStart;
    _selectionEnd = selectionEnd;
  }
  return self;
}
@end

@interface WTLibrimeBridge () {
  RimeSessionId _sessionID;
}
@property(nonatomic, assign, readwrite, getter=isReady) BOOL ready;
@property(nonatomic, copy, readwrite) NSString *lastError;
@end

@implementation WTLibrimeBridge

+ (BOOL)initializeRimeOnceWithSharedDataDir:(NSString *)sharedDataDir
                               userDataDir:(NSString *)userDataDir
                                     error:(NSString **)error {
  static BOOL initialized = NO;
  static NSString *initializedSharedPath = nil;
  static NSString *initializedUserPath = nil;
  @synchronized(self) {
    if (initialized) {
      if (![initializedSharedPath isEqualToString:sharedDataDir] ||
          ![initializedUserPath isEqualToString:userDataDir]) {
        if (error) *error = @"librime already initialized with a different data directory";
        return NO;
      }
      return YES;
    }

    RIME_STRUCT(RimeTraits, traits);
    traits.shared_data_dir = sharedDataDir.UTF8String;
    traits.user_data_dir = userDataDir.UTF8String;
    traits.distribution_name = "CLAW TALK";
    traits.distribution_code_name = "clawtalk";
    traits.distribution_version = "3.0.1";
    traits.app_name = "rime.clawtalk";
    traits.min_log_level = 2;

    RimeSetup(&traits);
    RimeInitialize(&traits);
    if (RimeStartMaintenance(False)) {
      RimeJoinMaintenanceThread();
    }

    initialized = YES;
    initializedSharedPath = [sharedDataDir copy];
    initializedUserPath = [userDataDir copy];
    return YES;
  }
}

- (instancetype)initWithSharedDataDir:(NSString *)sharedDataDir
                          userDataDir:(NSString *)userDataDir {
  if ((self = [super init])) {
    _lastError = @"";
    NSString *initializationError = nil;
    if (![[self class] initializeRimeOnceWithSharedDataDir:sharedDataDir
                                              userDataDir:userDataDir
                                                    error:&initializationError]) {
      _lastError = initializationError ?: @"librime initialization failed";
      _ready = NO;
      return self;
    }
    _sessionID = RimeCreateSession();
    if (_sessionID == 0) {
      _lastError = @"RimeCreateSession returned 0";
      _ready = NO;
      return self;
    }
    _ready = YES;
  }
  return self;
}

- (void)dealloc {
  if (_sessionID != 0) {
    RimeDestroySession(_sessionID);
    _sessionID = 0;
  }
}

- (NSString *)currentSchemaID {
  if (!_ready) return @"";
  char buffer[256] = {0};
  if (!RimeGetCurrentSchema(_sessionID, buffer, sizeof(buffer))) return @"";
  return [NSString stringWithUTF8String:buffer] ?: @"";
}

- (WTLibrimeContextSnapshot *)emptySnapshot {
  return [[WTLibrimeContextSnapshot alloc] initWithComposition:@""
                                                   candidates:@[]
                                                    composing:NO
                                                   pageNumber:0
                                                     pageSize:0
                                                     lastPage:YES
                                            compositionLength:0
                                               cursorPosition:0
                                               selectionStart:0
                                                 selectionEnd:0];
}

- (WTLibrimeContextSnapshot *)snapshot {
  if (!_ready) return [self emptySnapshot];

  RIME_STRUCT(RimeContext, context);
  if (!RimeGetContext(_sessionID, &context)) return [self emptySnapshot];

  NSString *composition = context.composition.preedit
      ? [NSString stringWithUTF8String:context.composition.preedit]
      : @"";
  NSMutableArray<WTLibrimeCandidateRecord *> *candidates = [NSMutableArray array];
  int count = context.menu.num_candidates;
  if (count > 0 && context.menu.candidates != NULL) {
    for (int index = 0; index < count; ++index) {
      RimeCandidate candidate = context.menu.candidates[index];
      NSString *text = candidate.text ? [NSString stringWithUTF8String:candidate.text] : @"";
      NSString *comment = candidate.comment ? [NSString stringWithUTF8String:candidate.comment] : @"";
      [candidates addObject:[[WTLibrimeCandidateRecord alloc] initWithText:text ?: @""
                                                                      comment:comment ?: @""]];
    }
  }
  NSInteger pageNumber = MAX(0, context.menu.page_no);
  NSInteger pageSize = MAX(0, context.menu.page_size);
  BOOL lastPage = context.menu.is_last_page != 0;
  NSInteger compositionLength = MAX(0, context.composition.length);
  NSInteger cursorPosition = MAX(0, context.composition.cursor_pos);
  NSInteger selectionStart = MAX(0, context.composition.sel_start);
  NSInteger selectionEnd = MAX(0, context.composition.sel_end);
  BOOL composing = compositionLength > 0 || composition.length > 0;
  RimeFreeContext(&context);

  return [[WTLibrimeContextSnapshot alloc] initWithComposition:composition ?: @""
                                                   candidates:candidates
                                                    composing:composing
                                                   pageNumber:pageNumber
                                                     pageSize:pageSize
                                                     lastPage:lastPage
                                            compositionLength:compositionLength
                                               cursorPosition:cursorPosition
                                               selectionStart:selectionStart
                                                 selectionEnd:selectionEnd];
}

- (BOOL)processText:(NSString *)text {
  if (!_ready || text.length == 0) return NO;
  BOOL consumedAny = NO;
  for (NSUInteger index = 0; index < text.length; ++index) {
    unichar scalar = [text characterAtIndex:index];
    if (scalar > 0x7f) return consumedAny;
    Bool consumed = RimeProcessKey(_sessionID, (int)scalar, 0);
    if (!consumed) return consumedAny;
    consumedAny = YES;
  }
  return consumedAny;
}

- (NSString *)drainCommit {
  if (!_ready) return nil;
  RIME_STRUCT(RimeCommit, commit);
  if (!RimeGetCommit(_sessionID, &commit)) return nil;
  NSString *text = commit.text ? [NSString stringWithUTF8String:commit.text] : @"";
  RimeFreeCommit(&commit);
  return text.length > 0 ? text : nil;
}

- (BOOL)selectSchema:(NSString *)schemaID {
  if (!_ready || schemaID.length == 0) return NO;
  return RimeSelectSchema(_sessionID, schemaID.UTF8String) != 0;
}

- (BOOL)deploySchemaFile:(NSString *)schemaFile {
  if (!_ready || schemaFile.length == 0) return NO;
  return RimeDeploySchema(schemaFile.fileSystemRepresentation) != 0;
}

- (BOOL)syncUserData {
  if (!_ready) return NO;
  return RimeSyncUserData() != 0;
}

- (void)setOption:(NSString *)option value:(BOOL)value {
  if (!_ready || option.length == 0) return;
  RimeSetOption(_sessionID, option.UTF8String, value ? True : False);
}

- (void)setProperty:(NSString *)property value:(NSString *)value {
  if (!_ready || property.length == 0) return;
  RimeSetProperty(_sessionID, property.UTF8String, value.UTF8String);
}

- (BOOL)movePage:(NSInteger)direction {
  if (!_ready) return NO;
  int key = direction < 0 ? WTKeyPageUp : WTKeyPageDown;
  return RimeProcessKey(_sessionID, key, 0) != 0;
}

- (NSString *)selectCandidateAtIndex:(NSInteger)index {
  if (!_ready || index < 0) return nil;
  WTLibrimeContextSnapshot *state = [self snapshot];
  NSInteger pageSize = MAX(1, state.pageSize);
  size_t globalIndex = (size_t)(state.pageNumber * pageSize + index);
  RimeApi *api = rime_get_api();
  Bool selected = False;
  if (api && RIME_API_AVAILABLE(api, select_candidate_on_current_page)) {
    selected = api->select_candidate_on_current_page(_sessionID, (size_t)index);
  } else if (api && RIME_API_AVAILABLE(api, select_candidate)) {
    selected = api->select_candidate(_sessionID, globalIndex);
  }
  if (!selected) return nil;
  return [self drainCommit];
}

- (void)deleteBackward {
  if (!_ready) return;
  RimeProcessKey(_sessionID, WTKeyBackSpace, 0);
}

- (void)reset {
  if (!_ready) return;
  RimeClearComposition(_sessionID);
}

@end
