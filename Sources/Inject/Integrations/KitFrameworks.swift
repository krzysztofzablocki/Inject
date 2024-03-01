#if !os(watchOS)
#if canImport(UIKit)
import Foundation
import UIKit

extension UIView: InjectListener {}
extension UIViewController: InjectListener {}
#elseif canImport(AppKit)
import AppKit
import Foundation

extension NSView: InjectListener {}
extension NSViewController: InjectListener {}
extension NSWindow: InjectListener {}
#endif
#endif
