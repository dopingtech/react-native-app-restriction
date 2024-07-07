import SwiftUI
import ManagedSettings
import FamilyControls
import Combine

@available(iOS 16.0, *)
@objc(AppRestrictionViewManager)
class AppRestrictionViewManager: RCTViewManager {
    private let store = ManagedSettingsStore()

    override func view() -> (AppRestrictionView) {
        return AppRestrictionView()
    }

    @objc(addRestrictedApps:base64Data:)
    func addRestrictedApps(_ arg:NSNumber, base64Data: String) {
        let ac = AuthorizationCenter.shared

        Task {
            do {
                if(ac.authorizationStatus != .approved){
                    try await ac.requestAuthorization(for: .individual)
                }

                let decoder = JSONDecoder()
                let data = Data(base64Encoded: base64Data)!
                let selection = try decoder.decode(FamilyActivitySelection.self, from: data)

                store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
                store.shield.applicationCategories = selection.categoryTokens.isEmpty ? nil : ShieldSettings.ActivityCategoryPolicy.specific(selection.categoryTokens)
                store.media.denyExplicitContent = true
                store.application.denyAppRemoval = true
                store.dateAndTime.requireAutomaticDateAndTime = false

                print("deny app removal: ",  store.application.denyAppRemoval ?? false)
            } catch {
                print(error.localizedDescription)
                
                AppRestrictionEventEmitter.emitter.sendEvent(withName: "onError", body: error.localizedDescription)
            }
        }
    }

    @objc
    func clearRestrictedApps(_ arg: NSNumber) {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.media.denyExplicitContent = false
        store.application.denyAppRemoval = false
        store.dateAndTime.requireAutomaticDateAndTime = false

        print("deny app removal: ",  store.application.denyAppRemoval ?? false)
    }

    @objc
    override static func requiresMainQueueSetup() -> Bool {
        return true
    }
}

@available(iOS 16.0, *)
class AppRestrictionView : UIView {
    public var model = AppRestrictionSelectAppsModel()

    private var cancellable = Set<AnyCancellable>()

    var previousSelection: FamilyActivitySelection?

    func updateSelection(selection: FamilyActivitySelection) {
      let encoder = JSONEncoder()

      do {
        let json = try encoder.encode(selection)
        let jsonString = json.base64EncodedString()

        onSelectionChange(jsonString: jsonString)
      } catch {
        print("json encode error")
      }
    }

    @objc
    func onSelectionChange(jsonString: String) {
        AppRestrictionEventEmitter.emitter.sendEvent(withName: "onSelectionChange", body: jsonString)
    }

    @objc
    var show: Bool = false {
        didSet {
            model = AppRestrictionSelectAppsModel()
            
            if(show) {
                let ac = AuthorizationCenter.shared

                Task {
                    do {
                        if(ac.authorizationStatus != .approved){
                            try await ac.requestAuthorization(for: .individual)
                        }
                        
                        model.pickerIsPresented = true
                        
                        let contentView = UIHostingController<AppRestrictionPickerView>(rootView: AppRestrictionPickerView(model: model))

                        self.addSubview(contentView.view)
                        
                        model.$pickerIsPresented.sink { isPresented in
                            if(!isPresented && !self.model.pickerIsPresented){
                                AppRestrictionEventEmitter.emitter.sendEvent(withName: "onClosePicker", body: nil)
                            }
                        }
                        .store(in: &cancellable)
                    }
                    catch {
                        print(error.localizedDescription)
                        
                        AppRestrictionEventEmitter.emitter.sendEvent(withName: "onError", body: error.localizedDescription)
                    }
                }
                
                model.$activitySelection.sink { selection in
                    if(selection.applicationTokens.count > 0 && selection != self.previousSelection){
                        self.updateSelection(selection: selection)
                        self.previousSelection = selection
                    }
                }
                .store(in: &cancellable)
            }
        }
    }
}
