import SwiftUI
import AppKit

struct SettingsView: View {
    @State private var terminal: TerminalOption = Config.shared.load().terminal
    @State private var installing = false
    @State private var saved = false

    var entries: [TerminalEntry] { TerminalOption.allCases.map { TerminalEntry(option: $0) }.filter { $0.available } }

    var body: some View {
        VStack(spacing: 0) {
            // 主内容区域
            VStack(spacing: 24) {
                // 终端选择区域
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 10) {
                        Image(systemName: "terminal.fill")
                            .foregroundStyle(.blue)
                            .font(.title2)
                            .imageScale(.large)
                        Text("terminal".localized)
                            .font(.title2.weight(.semibold))
                    }
                    
                    Picker("terminal_picker_label".localized, selection: $terminal) {
                        ForEach(entries, id: \.option) { e in
                            HStack(spacing: 8) {
                                Image(nsImage: e.icon)
                                Text(e.name)
                                    .font(.body)
                            }
                            .tag(e.option)
                        }
                    }
                    .pickerStyle(.menu)
                    .controlSize(.large)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(18)
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(10)
                
                Divider()
                
                // 说明文字区域
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(.blue)
                        Text("instruction_title".localized)
                            .font(.headline)
                    }
                    
                    Text("instruction_text".localized)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(4)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
                .cornerRadius(10)
                
                Spacer()
            }
            .padding(20)
            
            // 底部操作栏
            VStack(spacing: 0) {
                Divider()
                
                HStack(spacing: 12) {
                    Button(action: {
                        Config.shared.save(Config.Model(terminal: terminal, command: ""))
                        withAnimation(.spring(response: 0.3)) {
                            saved = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation {
                                saved = false
                            }
                        }
                    }) {
                        Label("save_settings".localized, systemImage: "checkmark.circle")
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    
                    if saved {
                        Label("saved".localized, systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.body.weight(.medium))
                            .transition(.scale.combined(with: .opacity))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        Config.shared.save(Config.Model(terminal: terminal, command: ""))
                        installing = true
                        Installer.showHelperInFinder {
                            installing = false
                        }
                    }) {
                        Label("show_in_finder".localized, systemImage: "plus.rectangle.on.folder")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .disabled(installing)
                }
                .padding(16)
                .background(Color(nsColor: .windowBackgroundColor))
            }
        }
        .frame(minWidth: 500, minHeight: 400)
        .overlay(alignment: .top) {
            if installing {
                VStack {
                    ProgressView("opening_customize_toolbar".localized)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(8)
                }
                .padding(.top, 20)
            }
        }
        .onAppear {
            if !TerminalEntry(option: terminal).available, let first = entries.first {
                terminal = first.option
            }
        }
    }
}

 

struct TerminalEntry: Identifiable {
    let option: TerminalOption
    var id: TerminalOption { option }
    var name: String { option.displayName }
    var bundleId: String { option.bundleId }
    var available: Bool {
        NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) != nil
    }
    var icon: NSImage {
        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) {
            let originalIcon = NSWorkspace.shared.icon(forFile: url.path)
            // 创建固定尺寸的图标
            let size = NSSize(width: 20, height: 20)
            let resizedIcon = NSImage(size: size)
            resizedIcon.lockFocus()
            originalIcon.draw(in: NSRect(origin: .zero, size: size))
            resizedIcon.unlockFocus()
            return resizedIcon
        }
        return NSImage(systemSymbolName: "gearshape", accessibilityDescription: nil) ?? NSImage()
    }
}

enum TerminalOption: String, CaseIterable, Codable {
    case terminal
    case iterm2
    case ghostty
    case warp
    case alacritty
    case hyper
    case kitty
    case wezterm
    case tabby
    case blackbox

    var displayName: String {
        switch self {
        case .terminal: return "Terminal"
        case .iterm2: return "iTerm2"
        case .ghostty: return "Ghostty"
        case .warp: return "Warp"
        case .alacritty: return "Alacritty"
        case .hyper: return "Hyper"
        case .kitty: return "Kitty"
        case .wezterm: return "WezTerm"
        case .tabby: return "Tabby"
        case .blackbox: return "Black Box"
        }
    }

    var bundleId: String {
        switch self {
        case .terminal: return "com.apple.Terminal"
        case .iterm2: return "com.googlecode.iterm2"
        case .ghostty: return "com.mitchellh.ghostty"
        case .warp: return "dev.warp.Warp"
        case .alacritty: return "org.alacritty"
        case .hyper: return "co.zeit.hyper"
        case .kitty: return "net.kovidgoyal.kitty"
        case .wezterm: return "com.github.wez.wezterm"
        case .tabby: return "org.tabby"
        case .blackbox: return "com.blackboxterminal.blackbox"
        }
    }
}

struct Installer {
    static func showHelperInFinder(completion: @escaping () -> Void) {
        let appBundle = Bundle.main.bundleURL
        
        // Helper 在 MacOS 目录
        let macosHelperPath = appBundle.appendingPathComponent("Contents/MacOS/GoToShellHelper.app")
        let resourcesHelperPath = appBundle.appendingPathComponent("Contents/Resources/GoToShellHelper.app")
        
        // 确定 Helper 的位置
        let helperPath: URL
        if FileManager.default.fileExists(atPath: macosHelperPath.path) {
            helperPath = macosHelperPath
        } else if FileManager.default.fileExists(atPath: resourcesHelperPath.path) {
            // 如果在 Resources 目录，复制到 MacOS 目录
            do {
                try FileManager.default.copyItem(at: resourcesHelperPath, to: macosHelperPath)
                helperPath = macosHelperPath
            } catch {
                print("Failed to copy Helper to MacOS directory: \(error)")
                helperPath = resourcesHelperPath
            }
        } else {
            print("Helper app not found!")
            DispatchQueue.main.async {
                let alert = NSAlert()
                alert.messageText = "Error"
                alert.informativeText = "GoToShellHelper.app not found in application bundle."
                alert.alertStyle = .critical
                alert.addButton(withTitle: "OK")
                alert.runModal()
                completion()
            }
            return
        }
        
        // 在 Finder 中显示并选中 Helper
        NSWorkspace.shared.activateFileViewerSelecting([helperPath])
        
        // 显示使用说明
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let alert = NSAlert()
            alert.messageText = "add_to_toolbar_title".localized
            alert.informativeText = "add_to_toolbar_instruction".localized
            alert.alertStyle = .informational
            alert.addButton(withTitle: "ok".localized)
            alert.runModal()
            completion()
        }
    }
}

final class Config {
    static let shared = Config()

    struct Model: Codable {
        var terminal: TerminalOption
        var command: String
    }

    private var url: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = base.appendingPathComponent("GoToShell", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("config.json")
    }

    func load() -> Model {
        guard let data = try? Data(contentsOf: url), let m = try? JSONDecoder().decode(Model.self, from: data) else {
            return Model(terminal: .terminal, command: "")
        }
        return m
    }

    func save(_ model: Model) {
        if let data = try? JSONEncoder().encode(model) {
            try? data.write(to: url)
        }
    }
}

enum AppleScriptRunner {
    static func run(_ source: String, completion: ((String?) -> Void)? = nil) {
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        proc.arguments = ["-e", source]
        let pipe = Pipe()
        proc.standardOutput = pipe
        proc.standardError = Pipe()
        try? proc.run()
        proc.terminationHandler = { _ in
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let s = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
            completion?(s)
        }
    }
}