//
//  AliasJQL.Command.swift
//  jiracmd
//
//  Created by marty-suzuki on 2018/06/06.
//

import Core

enum AliasJQL {
    static func run(_ parser: ArgumentParser) throws {
        let command: Command = try parser.parse()
        switch command {
        case .add:
            try Add.run(parser)
        case .remove:
            try Remove.run(parser)
        case .list:
            try List.run(parser)
        }
    }

    enum Command: String, CommandList {
        case add
        case remove
        case list
    }

    enum Add {
        static func run(_ parser: ArgumentParser, facade: Facade = .init()) throws {
            guard let name = parser.shift(), !name.isEmpty else {
                return
            }

            guard let jql = parser.shift(), !jql.isEmpty else {
                return
            }

            try facade.jqlService.addAlias(name: name, jql: jql)
        }
    }

    enum Remove {
        static func run(_ parser: ArgumentParser, facade: Facade = .init()) throws {
            guard let name = parser.shift(), !name.isEmpty else {
                return
            }

            try facade.jqlService.removeAlias(name: name)
        }
    }

    enum List {
        static func run(_ parser: ArgumentParser, facade: Facade = .init()) throws {
            let aliases = try facade.jqlService.loadAliases()

            print("Registered Jira Query Language Aliases:\n")
            aliases.forEach {
                print("\tname: \($0.name), jql: \($0.jql)")
            }
        }
    }
}
