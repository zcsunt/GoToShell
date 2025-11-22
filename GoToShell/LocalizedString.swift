//
//  LocalizedString.swift
//  GoToShell
//
//  Created for localization support
//

import Foundation

extension String {
    /// 本地化字符串的便捷扩展
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    /// 带参数的本地化字符串
    func localized(with arguments: CVarArg...) -> String {
        return String(format: NSLocalizedString(self, comment: ""), arguments: arguments)
    }
}

