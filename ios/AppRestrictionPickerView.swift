import FamilyControls
import SwiftUI

@available(iOS 16.0, *)
class AppRestrictionSelectAppsModel: ObservableObject {
    @Published var activitySelection = FamilyActivitySelection(
        includeEntireCategory: true
    )
    
    @Published var pickerIsPresented = false

    init() {}
}

@available(iOS 16.0, *)
struct AppRestrictionPickerView: View {
    @ObservedObject var model: AppRestrictionSelectAppsModel
    
    var body: some View {
        Color.clear
            .contentShape(Rectangle())
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
            .familyActivityPicker(
                isPresented: $model.pickerIsPresented,
                selection: $model.activitySelection
            )
     }
}
