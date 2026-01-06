import SwiftUI

struct SettingsView: View {
    @ObservedObject var config = AppConfiguration.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            ScrollView {
                VStack(spacing: 24) {
                    modeSection
                    profileSection
                    terminalSection
                    profileSpecificSection
                    generalSection
                }
                .padding(24)
            }
            
            footer
        }
        .frame(width: 580, height: 700)
        .background(Color(nsColor: .windowBackgroundColor))
    }
    
    private var header: some View {
        HStack {
            Image("AppLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 2) {
                Text("NotchSwitch")
                    .font(.system(size: 18, weight: .semibold))
                Text("Configure your workflow shortcuts")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(20)
        .background(Color(nsColor: .controlBackgroundColor))
    }
    
    private var modeSection: some View {
        SettingsSection(title: "Settings Mode", icon: "slider.horizontal.2.square") {
            VStack(alignment: .leading, spacing: 8) {
                Picker("", selection: $config.settingsMode) {
                    ForEach(SettingsMode.allCases) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                
                Text(config.settingsMode == .user 
                    ? "Pick apps from your Applications folder"
                    : "Enter bundle identifiers manually")
                    .font(.system(size: 10))
                    .foregroundColor(Color(nsColor: .tertiaryLabelColor))
            }
        }
    }
    
    private var profileSection: some View {
        SettingsSection(title: "Work Profile", icon: "person.crop.circle") {
            VStack(alignment: .leading, spacing: 4) {
                Text("Profile")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                
                Picker("", selection: $config.selectedProfile) {
                    ForEach(WorkProfile.allCases) { profile in
                        Text(profile.displayName).tag(profile)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                
                Text("Choose a preset that matches your workflow")
                    .font(.system(size: 10))
                    .foregroundColor(Color(nsColor: .tertiaryLabelColor))
            }
        }
    }
    
    private var terminalSection: some View {
        SettingsSection(title: "Terminal for OpenCode", icon: "terminal.fill") {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Terminal Application")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Picker("", selection: $config.selectedTerminal) {
                        ForEach(TerminalApp.availableTerminals) { terminal in
                            Text(terminal.displayName).tag(terminal)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    
                    Text("Select the terminal where OpenCode runs")
                        .font(.system(size: 10))
                        .foregroundColor(Color(nsColor: .tertiaryLabelColor))
                }
                
                if config.selectedTerminal == .other {
                    SettingsTextField(
                        label: "Custom Terminal Bundle ID",
                        placeholder: "com.example.terminal",
                        text: $config.customTerminalBundleId,
                        hint: "Enter the bundle identifier of your terminal app"
                    )
                }
            }
        }
    }
    
    @ViewBuilder
    private var profileSpecificSection: some View {
        SettingsSection(title: "Button Configuration", icon: "square.grid.2x2") {
            VStack(spacing: 20) {
                ForEach(0..<4, id: \.self) { index in
                    ButtonConfigRow(profile: config.selectedProfile, index: index)
                    if index < 3 {
                        Divider()
                    }
                }
            }
        }
    }
    
    private var generalSection: some View {
        SettingsSection(title: "General", icon: "gearshape") {
            Toggle("Launch NotchSwitch at login", isOn: $config.launchAtLogin)
                .toggleStyle(.switch)
        }
    }
    
    private var footer: some View {
        HStack {
            Button("Reset to Defaults") {
                config.resetToDefaults()
            }
            .buttonStyle(.plain)
            .foregroundColor(.secondary)
            
            Spacer()
            
            Button("Done") {
                dismiss()
            }
            .keyboardShortcut(.defaultAction)
        }
        .padding(20)
        .background(Color(nsColor: .controlBackgroundColor))
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 8) {
                content
            }
            .padding(16)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(10)
        }
    }
}

struct SettingsTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    let hint: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(.roundedBorder)
            
            Text(hint)
                .font(.system(size: 10))
                .foregroundColor(Color(nsColor: .tertiaryLabelColor))
        }
    }
}

struct SettingsAppField: View {
    let label: String
    @Binding var bundleId: String
    let hint: String
    let isUserMode: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
            
            if isUserMode {
                HStack {
                    Text(AppPicker.getAppName(forBundleId: bundleId) ?? "No app selected")
                        .foregroundColor(AppPicker.getAppName(forBundleId: bundleId) != nil ? .primary : .secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(Color(nsColor: .textBackgroundColor))
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
                        )
                    
                    Button("Choose...") {
                        AppPicker.pickApp { selectedBundleId in
                            if let id = selectedBundleId {
                                bundleId = id
                            }
                        }
                    }
                }
            } else {
                TextField("Bundle Identifier", text: $bundleId)
                    .textFieldStyle(.roundedBorder)
            }
            
            Text(hint)
                .font(.system(size: 10))
                .foregroundColor(Color(nsColor: .tertiaryLabelColor))
        }
    }
}

struct ButtonConfigRow: View {
    let profile: WorkProfile
    let index: Int
    @ObservedObject var config = AppConfiguration.shared
    @State private var showingIconPicker = false
    
    private var buttonConfig: ButtonConfig {
        profile.buttonConfigs[index]
    }
    
    private var actionType: ButtonConfig.ActionType {
        config.getButtonActionType(profile: profile, index: index)
    }
    
    private var target: String {
        config.getButtonTarget(profile: profile, index: index)
    }
    
    private var currentIcon: String {
        config.getButtonIcon(profile: profile, index: index)
    }
    
    private var currentLabel: String {
        config.getButtonLabel(profile: profile, index: index)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Button(action: { showingIconPicker.toggle() }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.accentColor.opacity(0.15))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: currentIcon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.accentColor)
                    }
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showingIconPicker) {
                    IconPickerView(
                        selectedIcon: currentIcon,
                        onSelect: { icon in
                            config.setButtonIcon(profile: profile, index: index, icon: icon)
                            showingIconPicker = false
                        }
                    )
                }
                
                TextField("Label", text: Binding(
                    get: { currentLabel },
                    set: { config.setButtonLabel(profile: profile, index: index, label: $0) }
                ))
                .textFieldStyle(.roundedBorder)
                .frame(width: 90)
                
                Spacer()
                
                Picker("", selection: Binding(
                    get: { actionType },
                    set: { config.setButtonActionType(profile: profile, index: index, actionType: $0) }
                )) {
                    Text("App").tag(ButtonConfig.ActionType.app)
                    Text("Browser Tab").tag(ButtonConfig.ActionType.browserTab)
                    if index == 0 && profile == .coder {
                        Text("Terminal").tag(ButtonConfig.ActionType.terminal)
                    }
                }
                .pickerStyle(.segmented)
                .frame(minWidth: (index == 0 && profile == .coder) ? 240 : 180)
            }
            
            if actionType == .terminal {
                Text("Opens OpenCode in your selected terminal")
                    .font(.system(size: 10))
                    .foregroundColor(Color(nsColor: .tertiaryLabelColor))
            } else if actionType == .app {
                appTargetField
            } else {
                browserTabTargetField
            }
        }
        .padding(.vertical, 8)
    }
    
    private var appTargetField: some View {
        Group {
            if config.settingsMode == .user {
                HStack {
                    Text(AppPicker.getAppName(forBundleId: target) ?? "No app selected")
                        .foregroundColor(AppPicker.getAppName(forBundleId: target) != nil ? .primary : .secondary)
                        .font(.system(size: 12))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(Color(nsColor: .textBackgroundColor))
                        .cornerRadius(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
                        )
                    
                    Button("Choose...") {
                        AppPicker.pickApp { bundleId in
                            if let id = bundleId {
                                config.setButtonTarget(profile: profile, index: index, target: id)
                            }
                        }
                    }
                    .font(.system(size: 11))
                }
            } else {
                TextField("Bundle Identifier (e.g., com.apple.Preview)", text: Binding(
                    get: { target },
                    set: { config.setButtonTarget(profile: profile, index: index, target: $0) }
                ))
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 12))
            }
        }
    }
    
    private var browserTabTargetField: some View {
        TextField("URL contains... (e.g., localhost, chatgpt.com)", text: Binding(
            get: { target },
            set: { config.setButtonTarget(profile: profile, index: index, target: $0) }
        ))
        .textFieldStyle(.roundedBorder)
        .font(.system(size: 12))
    }
}

struct IconPickerView: View {
    let selectedIcon: String
    let onSelect: (String) -> Void
    
    private let icons = [
        "terminal.fill", "globe", "network", "brain.head.profile",
        "doc.text.fill", "books.vertical.fill", "magnifyingglass", "folder.fill",
        "paintbrush.fill", "photo.fill", "rectangle.3.group.fill", "paintpalette.fill",
        "photo.stack.fill", "music.note", "play.fill", "video.fill",
        "message.fill", "envelope.fill", "phone.fill", "calendar",
        "chart.bar.fill", "list.bullet", "checkmark.circle.fill", "star.fill",
        "heart.fill", "bolt.fill", "gear", "wrench.fill",
        "hammer.fill", "cube.fill", "shippingbox.fill", "tray.fill",
        "app.fill", "square.grid.2x2.fill", "circle.grid.3x3.fill", "link"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Choose Icon")
                .font(.system(size: 12, weight: .semibold))
                .padding(.horizontal, 12)
                .padding(.top, 12)
            
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(36)), count: 6), spacing: 8) {
                ForEach(icons, id: \.self) { icon in
                    Button(action: { onSelect(icon) }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(icon == selectedIcon ? Color.accentColor : Color.clear)
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: icon)
                                .font(.system(size: 14))
                                .foregroundColor(icon == selectedIcon ? .white : .primary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(12)
        }
        .frame(width: 260)
    }
}
