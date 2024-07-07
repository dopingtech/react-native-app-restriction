#import <React/RCTViewManager.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_MODULE(AppRestrictionViewManager, RCTViewManager)

RCT_EXPORT_VIEW_PROPERTY(show, BOOL)

RCT_EXTERN_METHOD(clearRestrictedApps:(nonnull NSNumber *)arg)

RCT_EXTERN_METHOD(addRestrictedApps:(nonnull NSNumber *)arg base64Data:(NSString *)base64Data)

@end

@interface RCT_EXTERN_MODULE(AppRestrictionEventEmitter, RCTEventEmitter)

RCT_EXTERN_METHOD(supportedEvents)

@end

