#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit
import FZUIKit
import FZSwiftUtils

@available(macOS 12.0, *)
extension NSView {
    /// The current content-unavailable configuration of the view.
    ///
    /// Use this property to configure a content-unavailable view that the view displays. The value of this property is commonly an instance of `NSContentUnavailableConfiguration`, but you can use other types of content configuration, including a `NSHostingConfiguration, to display a SwiftUI view.
    public var contentUnavailableConfiguration: NSContentConfiguration? {
        get { getAssociatedValue("NSView_contentUnavailableConfiguration") }
        set {
            setAssociatedValue(newValue, key: "NSView_contentUnavailableConfiguration")
            configurateUnavailableView()
        }
    }

    internal var unavailableView: (NSView & NSContentView)? {
        get { getAssociatedValue("NSView_unavailableView") }
        set { setAssociatedValue(newValue, key: "NSView_unavailableView")
        }
    }

    internal func configurateUnavailableView() {
        if let contentUnavailableConfiguration {
            if let unavailableView, unavailableView.supports(contentUnavailableConfiguration) {
                unavailableView.configuration = contentUnavailableConfiguration
            } else {
                self.unavailableView?.removeFromSuperview()
                let unavailableView = contentUnavailableConfiguration.makeContentView()
                self.unavailableView = unavailableView
                addSubview(withConstraint: unavailableView)
            }
        } else {
            unavailableView?.removeFromSuperview()
        }
    }

    /// The current configuration state of the content-unavailable view.
    ///
    /// To add your own custom state, see ``NSConfigurationStateCustomKey``.
    public var contentUnavailableConfigurationState: NSContentUnavailableConfigurationState {
        let state = NSContentUnavailableConfigurationState()
        return state
    }

    /// Requests that the system update the content-unavailable configuration for the latest state.
    public func setNeedsUpdateContentUnavailableConfiguration() {
        updateContentUnavailableConfiguration(using: contentUnavailableConfigurationState)
    }

    /// Updates the content-unavailable configuration for the provided state.
    ///
    /// Override this method to update the value of `contentUnavailableConfiguration` as appropriate for the given state.
    ///
    /// Don’t call this method directly. Instead, call `setNeedsUpdateContentUnavailableConfiguration() to tell the system to request an update.
    ///
    /// - Parameter state:  The current configuration state for a content-unavailable view.
    public func updateContentUnavailableConfiguration(using: NSContentUnavailableConfigurationState) {}
}

@available(macOS 12.0, *)
/**
 A structure that encapsulates state for a content-unavailable view.
  
 You can create your own custom states to add to a content-unavailable configuration state by defining a custom state key with ``UIConfigurationStateCustomKey`.
 */
public struct NSContentUnavailableConfigurationState: NSConfigurationState, Hashable {
    /// Accesses custom states by key.
    public subscript(key: NSConfigurationStateCustomKey) -> AnyHashable? {
        get { customStates[key] }
        set { customStates[key] = newValue }
    }

    var customStates = [NSConfigurationStateCustomKey: AnyHashable]()
}

#endif
