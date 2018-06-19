//
//  List.Command.Usage.swift
//  cujira
//
//  Created by marty-suzuki on 2018/06/18.
//

import Foundation

extension List.Command {
    static func usageDescription(_ cmd: String) -> String {
        let values = elements.map { element -> String in
            switch element {
            case .sprint:
                return List.Sprint.usageDescription(element.rawValue)
            case .board:
                return List.Board.usageDescription(element.rawValue)
            case .field:
                return List.Field.usageDescription(element.rawValue)
            case .status:
                return List.Status.usageDescription(element.rawValue)
            case .epic:
                return List.Epic.usageDescription(element.rawValue)
            }
        } + ["""
            Options:

                -f | --fetch
                    ... Fetch from API.
        """]

        return usageFormatted(root: cmd, cmd: Root.Command.list, values: values, separator: "\n\n")
    }
}
