import SwiftUI
import AppKit
import Foundation

@main
struct GoToShellHelperApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // 使用 WindowGroup 但不显示任何内容
        WindowGroup {
            EmptyView()
                .frame(width: 0, height: 0)
                .hidden()
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 0, height: 0)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 设置应用为后台应用，不显示在 Dock 和菜单栏
        NSApp.setActivationPolicy(.accessory)
        
        // 隐藏所有窗口
        NSApplication.shared.windows.forEach { window in
            window.orderOut(nil)
            window.close()
        }
        
        // 立即执行任务
        self.run()
    }
    
    func run() {
        let cfg = Config().load()
        
        // 写入日志用于调试
        let logPath = NSHomeDirectory() + "/Library/Logs/GoToShellHelper.log"
        let logMessage = "[\(Date())] Opening terminal: \(cfg.terminal.rawValue)\n"
        try? logMessage.appendToFile(at: logPath)
        
        TerminalLauncher.openTerminal(terminal: cfg.terminal)
        
        // 延迟退出，确保脚本执行完成
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            NSApplication.shared.terminate(nil)
        }
    }
}

extension String {
    func appendToFile(at path: String) throws {
        let url = URL(fileURLWithPath: path)
        if let data = self.data(using: .utf8) {
            if FileManager.default.fileExists(atPath: path) {
                let fileHandle = try FileHandle(forWritingTo: url)
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            } else {
                try data.write(to: url)
            }
        }
    }
}

struct Config {
    struct Model: Codable {
        var terminal: TerminalOption
        var command: String
    }

    func load() -> Model {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let url = base.appendingPathComponent("GoToShell/config.json")
        guard let data = try? Data(contentsOf: url), let m = try? JSONDecoder().decode(Model.self, from: data) else {
            return Model(terminal: .terminal, command: "")
        }
        return m
    }
}

enum TerminalOption: String, Codable {
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

enum TerminalLauncher {
    static func getCurrentFinderPath() -> String {
        let script = """
        tell application "Finder"
            if (count of windows) > 0 then
                set currentPath to (POSIX path of (target of front window as alias))
            else
                set currentPath to POSIX path of (path to home folder)
            end if
            return currentPath
        end tell
        """
        
        return AppleScriptRunner.runSync(script) ?? NSHomeDirectory()
    }
    
    static func openTerminal(terminal: TerminalOption) {
        let currentPath = getCurrentFinderPath()
        let pathURL = URL(fileURLWithPath: currentPath)
        
        switch terminal {
        case .terminal:
            // Terminal 使用 AppleScript 是最可靠的方式
            let script = """
            tell application "Terminal"
                activate
                do script "cd " & quoted form of "\(currentPath)"
            end tell
            """
            _ = AppleScriptRunner.runSync(script)
            
        case .iterm2:
            // iTerm2 使用 AppleScript 是最可靠的方式
            let script = """
            tell application "iTerm"
                activate
                try
                    tell current window
                        create tab with default profile
                    end tell
                on error
                    create window with default profile
                end try
                tell current session of current window
                    write text "cd " & quoted form of "\(currentPath)"
                end tell
            end tell
            """
            _ = AppleScriptRunner.runSync(script)
            
        case .ghostty:
            // Ghostty 支持直接传递工作目录
            openWithNSWorkspace(bundleId: terminal.bundleId, workingDirectory: pathURL)
            
        case .warp:
            // Warp 支持通过 open 传递工作目录
            openWithNSWorkspace(bundleId: terminal.bundleId, workingDirectory: pathURL)
            
        case .alacritty:
            // Alacritty 支持通过 open 传递工作目录
            openWithNSWorkspace(bundleId: terminal.bundleId, workingDirectory: pathURL)
            
        case .hyper:
            // Hyper 支持通过 open 传递工作目录
            openWithNSWorkspace(bundleId: terminal.bundleId, workingDirectory: pathURL)
            
        case .kitty:
            // Kitty 支持通过 open 传递工作目录
            openWithNSWorkspace(bundleId: terminal.bundleId, workingDirectory: pathURL)
            
        case .wezterm:
            // WezTerm 支持通过 open 传递工作目录
            openWithNSWorkspace(bundleId: terminal.bundleId, workingDirectory: pathURL)
            
        case .tabby:
            // Tabby 支持通过 open 传递工作目录
            openWithNSWorkspace(bundleId: terminal.bundleId, workingDirectory: pathURL)
            
        case .blackbox:
            // Black Box 支持通过 open 传递工作目录
            openWithNSWorkspace(bundleId: terminal.bundleId, workingDirectory: pathURL)
        }
    }
    
    // 使用 NSWorkspace 打开应用并传递工作目录
    private static func openWithNSWorkspace(bundleId: String, workingDirectory: URL) {
        guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) else {
            print("Failed to find app with bundle ID: \(bundleId)")
            return
        }
        
        // 使用 open 命令，-n 参数确保每次都打开新窗口
        // 相当于: open -n -a "AppName" /path/to/directory
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        process.arguments = ["-n", "-a", appURL.path, workingDirectory.path]
        
        do {
            try process.run()
        } catch {
            print("Failed to open \(bundleId) with directory: \(error)")
        }
    }
    
}

enum AppleScriptRunner {
    static func runSync(_ source: String) -> String? {
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        proc.arguments = ["-e", source]
        let pipe = Pipe()
        proc.standardOutput = pipe
        proc.standardError = Pipe()
        try? proc.run()
        proc.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let s = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
        return s?.isEmpty == true ? nil : s
    }
}