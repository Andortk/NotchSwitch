import Foundation
import AppKit

enum TerminalApp: String, CaseIterable, Identifiable {
    case notSet = "not_set"
    case alacritty = "org.alacritty"
    case kitty = "net.kovidgoyal.kitty"
    case ghostty = "com.mitchellh.ghostty"
    case iterm2 = "com.googlecode.iterm2"
    case terminal = "com.apple.Terminal"
    case warp = "dev.warp.Warp-Stable"
    case other = "other"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .notSet: return "Not Selected"
        case .alacritty: return "Alacritty"
        case .kitty: return "Kitty"
        case .ghostty: return "Ghostty"
        case .iterm2: return "iTerm2"
        case .terminal: return "Terminal (Apple)"
        case .warp: return "Warp"
        case .other: return "Other..."
        }
    }
    
    var isInstalled: Bool {
        if self == .notSet || self == .other { return true }
        return NSWorkspace.shared.urlForApplication(withBundleIdentifier: rawValue) != nil
    }
    
    static var availableTerminals: [TerminalApp] {
        allCases.filter { $0 != .notSet }
    }
    
    static var installedTerminals: [TerminalApp] {
        allCases.filter { $0.isInstalled && $0 != .notSet }
    }
}

enum SettingsMode: String, CaseIterable, Identifiable {
    case user = "user"
    case pro = "pro"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .user: return "User"
        case .pro: return "Pro"
        }
    }
}

enum WorkProfile: String, CaseIterable, Identifiable {
    case coder = "coder"
    case vibeCoding = "vibeCoding"
    case student = "student"
    case teacher = "teacher"
    case learning = "learning"
    case researcher = "researcher"
    case designer = "designer"
    case artist = "artist"
    case other = "other"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .coder: return "Coder / Programming"
        case .vibeCoding: return "Vibe Coding"
        case .student: return "Student"
        case .teacher: return "Teacher"
        case .learning: return "Learning"
        case .researcher: return "Researcher"
        case .designer: return "Designer"
        case .artist: return "Artist"
        case .other: return "Other"
        }
    }
    
    var buttonConfigs: [ButtonConfig] {
        switch self {
        case .coder:
            return [
                ButtonConfig(icon: "terminal.fill", label: "OpenCode", color: "blue", actionType: .terminal),
                ButtonConfig(icon: "globe", label: "Antigravity", color: "purple", actionType: .app),
                ButtonConfig(icon: "network", label: "Testing", color: "orange", actionType: .browserTab),
                ButtonConfig(icon: "brain.head.profile", label: "Grok", color: "pink", actionType: .browserTab)
            ]
        case .vibeCoding:
            return [
                ButtonConfig(icon: "terminal.fill", label: "OpenCode", color: "blue", actionType: .terminal),
                ButtonConfig(icon: "hammer.fill", label: "Testing", color: "orange", actionType: .app),
                ButtonConfig(icon: "play.rectangle.fill", label: "YouTube", color: "red", actionType: .browserTab),
                ButtonConfig(icon: "at", label: "X", color: "white", actionType: .browserTab)
            ]
        case .student, .teacher, .learning:
            return [
                ButtonConfig(icon: "terminal.fill", label: "OpenCode", color: "blue", actionType: .terminal),
                ButtonConfig(icon: "play.rectangle.fill", label: "YouTube", color: "red", actionType: .browserTab),
                ButtonConfig(icon: "at", label: "X", color: "white", actionType: .browserTab),
                ButtonConfig(icon: "brain.head.profile", label: "Grok", color: "pink", actionType: .browserTab)
            ]
        case .researcher:
            return [
                ButtonConfig(icon: "doc.text.fill", label: "PDF", color: "red", actionType: .app),
                ButtonConfig(icon: "books.vertical.fill", label: "References", color: "blue", actionType: .app),
                ButtonConfig(icon: "magnifyingglass", label: "SciHub", color: "green", actionType: .browserTab),
                ButtonConfig(icon: "brain.head.profile", label: "AI", color: "purple", actionType: .browserTab)
            ]
        case .designer:
            return [
                ButtonConfig(icon: "paintbrush.fill", label: "Design", color: "pink", actionType: .app),
                ButtonConfig(icon: "photo.fill", label: "Assets", color: "orange", actionType: .app),
                ButtonConfig(icon: "rectangle.3.group.fill", label: "Prototype", color: "blue", actionType: .app),
                ButtonConfig(icon: "globe", label: "Inspo", color: "purple", actionType: .browserTab)
            ]
        case .artist:
            return [
                ButtonConfig(icon: "paintpalette.fill", label: "Canvas", color: "purple", actionType: .app),
                ButtonConfig(icon: "photo.stack.fill", label: "Gallery", color: "orange", actionType: .app),
                ButtonConfig(icon: "music.note", label: "Music", color: "pink", actionType: .app),
                ButtonConfig(icon: "globe", label: "Reference", color: "blue", actionType: .browserTab)
            ]
        case .other:
            return [
                ButtonConfig(icon: "app.fill", label: "App 1", color: "blue", actionType: .app),
                ButtonConfig(icon: "app.fill", label: "App 2", color: "purple", actionType: .app),
                ButtonConfig(icon: "globe", label: "Tab 1", color: "orange", actionType: .browserTab),
                ButtonConfig(icon: "globe", label: "Tab 2", color: "pink", actionType: .browserTab)
            ]
        }
    }
}

struct ButtonConfig: Identifiable {
    let id = UUID()
    let icon: String
    let label: String
    let color: String
    var actionType: ActionType
    
    enum ActionType: String {
        case terminal
        case app
        case browserTab
    }
}

struct CustomButtonConfig: Codable {
    var actionType: String
    var target: String
    var icon: String?
    var label: String?
    
    static func defaultsKey(profile: String, index: Int) -> String {
        return "button_\(profile)_\(index)"
    }
}

class AppConfiguration: ObservableObject {
    static let shared = AppConfiguration()
    
    @Published var settingsMode: SettingsMode {
        didSet { UserDefaults.standard.set(settingsMode.rawValue, forKey: "settingsMode") }
    }
    
    @Published var selectedProfile: WorkProfile {
        didSet { UserDefaults.standard.set(selectedProfile.rawValue, forKey: "selectedProfile") }
    }
    
    @Published var selectedTerminal: TerminalApp {
        didSet { UserDefaults.standard.set(selectedTerminal.rawValue, forKey: "selectedTerminal") }
    }
    
    @Published var customTerminalBundleId: String {
        didSet { UserDefaults.standard.set(customTerminalBundleId, forKey: "customTerminalBundleId") }
    }
    
    @Published var antigravityBundleId: String {
        didSet { UserDefaults.standard.set(antigravityBundleId, forKey: "antigravityBundleId") }
    }
    
    @Published var testingUrlSubstring: String {
        didSet { UserDefaults.standard.set(testingUrlSubstring, forKey: "testingUrlSubstring") }
    }
    
    @Published var grokUrlSubstring: String {
        didSet { UserDefaults.standard.set(grokUrlSubstring, forKey: "grokUrlSubstring") }
    }
    
    @Published var pdfAppBundleId: String {
        didSet { UserDefaults.standard.set(pdfAppBundleId, forKey: "pdfAppBundleId") }
    }
    
    @Published var referenceManagerBundleId: String {
        didSet { UserDefaults.standard.set(referenceManagerBundleId, forKey: "referenceManagerBundleId") }
    }
    
    @Published var sciHubUrlSubstring: String {
        didSet { UserDefaults.standard.set(sciHubUrlSubstring, forKey: "sciHubUrlSubstring") }
    }
    
    @Published var aiUrlSubstring: String {
        didSet { UserDefaults.standard.set(aiUrlSubstring, forKey: "aiUrlSubstring") }
    }
    
    @Published var designAppBundleId: String {
        didSet { UserDefaults.standard.set(designAppBundleId, forKey: "designAppBundleId") }
    }
    
    @Published var artAppBundleId: String {
        didSet { UserDefaults.standard.set(artAppBundleId, forKey: "artAppBundleId") }
    }
    
    @Published var launchAtLogin: Bool {
        didSet { 
            UserDefaults.standard.set(launchAtLogin, forKey: "launchAtLogin")
        }
    }
    
    @Published var multiFunctionAction: String {
        didSet {
            UserDefaults.standard.set(multiFunctionAction, forKey: "multiFunctionAction")
        }
    }
    
    var effectiveTerminalBundleId: String {
        if selectedTerminal == .other {
            return customTerminalBundleId
        }
        return selectedTerminal.rawValue
    }
    
    private init() {
        let modeRaw = UserDefaults.standard.string(forKey: "settingsMode") ?? "user"
        self.settingsMode = SettingsMode(rawValue: modeRaw) ?? .user
        
        let profileRaw = UserDefaults.standard.string(forKey: "selectedProfile") ?? "coder"
        self.selectedProfile = WorkProfile(rawValue: profileRaw) ?? .coder
        
        let terminalRaw = UserDefaults.standard.string(forKey: "selectedTerminal") ?? "not_set"
        self.selectedTerminal = TerminalApp(rawValue: terminalRaw) ?? .notSet
        self.customTerminalBundleId = UserDefaults.standard.string(forKey: "customTerminalBundleId") ?? ""
        self.antigravityBundleId = UserDefaults.standard.string(forKey: "antigravityBundleId") ?? "com.google.Antigravity"
        self.testingUrlSubstring = UserDefaults.standard.string(forKey: "testingUrlSubstring") ?? "localhost"
        self.grokUrlSubstring = UserDefaults.standard.string(forKey: "grokUrlSubstring") ?? "grok.com"
        
        self.pdfAppBundleId = UserDefaults.standard.string(forKey: "pdfAppBundleId") ?? "com.apple.Preview"
        self.referenceManagerBundleId = UserDefaults.standard.string(forKey: "referenceManagerBundleId") ?? "org.zotero.Zotero"
        self.sciHubUrlSubstring = UserDefaults.standard.string(forKey: "sciHubUrlSubstring") ?? "webofscience"
        self.aiUrlSubstring = UserDefaults.standard.string(forKey: "aiUrlSubstring") ?? "chatgpt.com"
        
        self.designAppBundleId = UserDefaults.standard.string(forKey: "designAppBundleId") ?? "com.figma.Desktop"
        self.artAppBundleId = UserDefaults.standard.string(forKey: "artAppBundleId") ?? "com.procreate.procreate"
        
        self.launchAtLogin = UserDefaults.standard.bool(forKey: "launchAtLogin")
        self.multiFunctionAction = UserDefaults.standard.string(forKey: "multiFunctionAction") ?? "toggleMusic"
    }
    
    func resetToDefaults() {
        settingsMode = .user
        selectedProfile = .coder
        selectedTerminal = .notSet
        customTerminalBundleId = ""
        antigravityBundleId = "com.google.Antigravity"
        testingUrlSubstring = "localhost"
        grokUrlSubstring = "grok.com"
        pdfAppBundleId = "com.apple.Preview"
        referenceManagerBundleId = "org.zotero.Zotero"
        sciHubUrlSubstring = "webofscience"
        aiUrlSubstring = "chatgpt.com"
        designAppBundleId = "com.figma.Desktop"
        artAppBundleId = "com.procreate.procreate"
        launchAtLogin = false
        multiFunctionAction = "toggleMusic"
        
        for profile in WorkProfile.allCases {
            for i in 0..<4 {
                let key = CustomButtonConfig.defaultsKey(profile: profile.rawValue, index: i)
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
    }
    
    func getButtonActionType(profile: WorkProfile, index: Int) -> ButtonConfig.ActionType {
        let key = CustomButtonConfig.defaultsKey(profile: profile.rawValue, index: index)
        if let data = UserDefaults.standard.data(forKey: key),
           let config = try? JSONDecoder().decode(CustomButtonConfig.self, from: data) {
            return ButtonConfig.ActionType(rawValue: config.actionType) ?? profile.buttonConfigs[index].actionType
        }
        return profile.buttonConfigs[index].actionType
    }
    
    func setButtonActionType(profile: WorkProfile, index: Int, actionType: ButtonConfig.ActionType) {
        let key = CustomButtonConfig.defaultsKey(profile: profile.rawValue, index: index)
        let target = getButtonTarget(profile: profile, index: index)
        let icon = getButtonIcon(profile: profile, index: index)
        let label = getButtonLabel(profile: profile, index: index)
        let config = CustomButtonConfig(actionType: actionType.rawValue, target: target, icon: icon, label: label)
        if let data = try? JSONEncoder().encode(config) {
            UserDefaults.standard.set(data, forKey: key)
        }
        objectWillChange.send()
    }
    
    func getButtonTarget(profile: WorkProfile, index: Int) -> String {
        let key = CustomButtonConfig.defaultsKey(profile: profile.rawValue, index: index)
        if let data = UserDefaults.standard.data(forKey: key),
           let config = try? JSONDecoder().decode(CustomButtonConfig.self, from: data) {
            return config.target
        }
        return defaultButtonTarget(profile: profile, index: index)
    }
    
    func setButtonTarget(profile: WorkProfile, index: Int, target: String) {
        let key = CustomButtonConfig.defaultsKey(profile: profile.rawValue, index: index)
        let actionType = getButtonActionType(profile: profile, index: index)
        let icon = getButtonIcon(profile: profile, index: index)
        let label = getButtonLabel(profile: profile, index: index)
        let config = CustomButtonConfig(actionType: actionType.rawValue, target: target, icon: icon, label: label)
        if let data = try? JSONEncoder().encode(config) {
            UserDefaults.standard.set(data, forKey: key)
        }
        objectWillChange.send()
    }
    
    func getButtonIcon(profile: WorkProfile, index: Int) -> String {
        let key = CustomButtonConfig.defaultsKey(profile: profile.rawValue, index: index)
        if let data = UserDefaults.standard.data(forKey: key),
           let config = try? JSONDecoder().decode(CustomButtonConfig.self, from: data),
           let icon = config.icon {
            return icon
        }
        return profile.buttonConfigs[index].icon
    }
    
    func setButtonIcon(profile: WorkProfile, index: Int, icon: String) {
        let key = CustomButtonConfig.defaultsKey(profile: profile.rawValue, index: index)
        let actionType = getButtonActionType(profile: profile, index: index)
        let target = getButtonTarget(profile: profile, index: index)
        let label = getButtonLabel(profile: profile, index: index)
        let config = CustomButtonConfig(actionType: actionType.rawValue, target: target, icon: icon, label: label)
        if let data = try? JSONEncoder().encode(config) {
            UserDefaults.standard.set(data, forKey: key)
        }
        objectWillChange.send()
    }
    
    func getButtonLabel(profile: WorkProfile, index: Int) -> String {
        let key = CustomButtonConfig.defaultsKey(profile: profile.rawValue, index: index)
        if let data = UserDefaults.standard.data(forKey: key),
           let config = try? JSONDecoder().decode(CustomButtonConfig.self, from: data),
           let label = config.label {
            return label
        }
        return profile.buttonConfigs[index].label
    }
    
    func setButtonLabel(profile: WorkProfile, index: Int, label: String) {
        let key = CustomButtonConfig.defaultsKey(profile: profile.rawValue, index: index)
        let actionType = getButtonActionType(profile: profile, index: index)
        let target = getButtonTarget(profile: profile, index: index)
        let icon = getButtonIcon(profile: profile, index: index)
        let config = CustomButtonConfig(actionType: actionType.rawValue, target: target, icon: icon, label: label)
        if let data = try? JSONEncoder().encode(config) {
            UserDefaults.standard.set(data, forKey: key)
        }
        objectWillChange.send()
    }
    
    private func defaultButtonTarget(profile: WorkProfile, index: Int) -> String {
        switch profile {
        case .coder:
            switch index {
            case 0: return ""
            case 1: return antigravityBundleId
            case 2: return testingUrlSubstring
            case 3: return grokUrlSubstring
            default: return ""
            }
        case .vibeCoding:
            switch index {
            case 0: return ""
            case 1: return "com.apple.dt.Xcode"
            case 2: return "https://www.youtube.com/"
            case 3: return "https://x.com/"
            default: return ""
            }
        case .student, .teacher, .learning:
            switch index {
            case 0: return ""
            case 1: return "https://www.youtube.com/"
            case 2: return "https://x.com/"
            case 3: return "https://grok.com/"
            default: return ""
            }
        case .researcher:
            switch index {
            case 0: return pdfAppBundleId
            case 1: return referenceManagerBundleId
            case 2: return sciHubUrlSubstring
            case 3: return aiUrlSubstring
            default: return ""
            }
        case .designer:
            switch index {
            case 0: return designAppBundleId
            default: return ""
            }
        case .artist:
            switch index {
            case 0: return artAppBundleId
            default: return ""
            }
        case .other:
            return ""
        }
    }
}

enum TerminalPicker {
    static func promptForTerminalSelection(completion: @escaping (TerminalApp?) -> Void) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Select Your Terminal"
            alert.informativeText = "OpenCode runs in a terminal. Please select which terminal you use:"
            alert.alertStyle = .informational
            
            let installedTerminals = TerminalApp.installedTerminals
            
            for terminal in installedTerminals {
                alert.addButton(withTitle: terminal.displayName)
            }
            alert.addButton(withTitle: "Cancel")
            
            let response = alert.runModal()
            let buttonIndex = response.rawValue - 1000
            
            if buttonIndex < installedTerminals.count {
                completion(installedTerminals[buttonIndex])
            } else {
                completion(nil)
            }
        }
    }
}

enum AppPicker {
    static func pickApp(completion: @escaping (String?) -> Void) {
        DispatchQueue.main.async {
            let panel = NSOpenPanel()
            panel.title = "Select Application"
            panel.allowedContentTypes = [.application]
            panel.allowsMultipleSelection = false
            panel.canChooseDirectories = false
            panel.canChooseFiles = true
            panel.directoryURL = URL(fileURLWithPath: "/Applications")
            
            let response = panel.runModal()
            guard response == .OK, let url = panel.url else {
                completion(nil)
                return
            }
            
            if let bundle = Bundle(url: url), let bundleId = bundle.bundleIdentifier {
                completion(bundleId)
            } else {
                completion(nil)
            }
        }
    }
    
    static func getAppName(forBundleId bundleId: String) -> String? {
        guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) else {
            return nil
        }
        return url.deletingPathExtension().lastPathComponent
    }
}
