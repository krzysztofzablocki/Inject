#if canImport(AppKit)
import AppKit
import Foundation

extension NSView: InjectListener {}
extension NSViewController: InjectListener {}
extension NSWindow: InjectListener {}
#elseif canImport(UIKit)
import Foundation
import UIKit

extension UIView: InjectListener {}
extension UIViewController: InjectListener {}
#endif
