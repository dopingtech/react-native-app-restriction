@objc(AppRestrictionEventEmitter)
open class AppRestrictionEventEmitter: RCTEventEmitter {

  public static var emitter: RCTEventEmitter!

  override init() {
    super.init()
    AppRestrictionEventEmitter.emitter = self
  }

  open override func supportedEvents() -> [String] {
    ["onSelectionChange", "onClosePicker", "onError"]
  }
}
