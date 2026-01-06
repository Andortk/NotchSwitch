import Foundation
import AppKit

class PermissionChecker {
    static let shared = PermissionChecker()
    
    private init() {}
    
    func checkAllPermissions() {
        checkAccessibilityPermission()
    }
    
    private func checkAccessibilityPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false]
        let accessibilityEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary)
        
        if !accessibilityEnabled {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.promptForAccessibility()
            }
        }
    }
    
    private func promptForAccessibility() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Permission Required"
        alert.informativeText = "NotchSwitch needs Accessibility permission to control media playback and switch between apps.\n\nPlease enable it in System Settings > Privacy & Security > Accessibility."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open Settings")
        alert.addButton(withTitle: "Later")
        
        let response = alert.runModal()
        
        if response == .alertFirstButtonReturn {
            openAccessibilitySettings()
        }
    }
    
    private func openAccessibilitySettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }
    
    func showPermissionStatus() {
        let accessibilityEnabled = AXIsProcessTrusted()
        
        let alert = NSAlert()
        alert.messageText = "Permission Status"
        
        var status = ""
        status += "Accessibility: \(accessibilityEnabled ? "✅ Granted" : "❌ Not Granted")\n"
        status += "\nAutomation permissions are requested when first used."
        
        alert.informativeText = status
        alert.alertStyle = .informational
        
        if !accessibilityEnabled {
            alert.addButton(withTitle: "Open Settings")
            alert.addButton(withTitle: "OK")
            
            if alert.runModal() == .alertFirstButtonReturn {
                openAccessibilitySettings()
            }
        } else {
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
}
