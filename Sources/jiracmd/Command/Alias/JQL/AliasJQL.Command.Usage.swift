//
//  AliasJQL.Command.Usage.swift
//  jiracmd
//
//  Created by marty-suzuki on 2018/06/08.
//

import Core

extension AliasJQL.Command {
    static func usageDescription(_ cmd: String) -> String {
        let values = elements.map { element -> String in
            switch element {
            case .add:
                return AliasJQL.Add.usageDescription(element.rawValue)
            case .remove:
                return AliasJQL.Remove.usageDescription(element.rawValue)
            case .list:
                return AliasJQL.List.usageDescription(element.rawValue)
            }
        }

        return usageFormatted(root: cmd, cmd: Alias.Command.jql, values: values, separator: "\n")
    }
}

extension AliasJQL.Add: UsageDescribable {
    static func usageDescription(_ cmd: String) -> String {
        return """
            + \(cmd) [NAME] [JQL]
        """
    }
}

extension AliasJQL.Remove: UsageDescribable {
    static func usageDescription(_ cmd: String) -> String {
        return """
            + \(cmd) [NAME]
        """
    }
}

extension AliasJQL.List: UsageDescribable {
    static func usageDescription(_ cmd: String) -> String {
        return """
            + \(cmd)
        """
    }
}
