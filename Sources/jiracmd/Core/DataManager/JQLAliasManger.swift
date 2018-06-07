//
//  JQLAliasManager.swift
//  jiracmd
//
//  Created by marty-suzuki on 2018/06/06.
//

import Foundation

typealias JQLAliasManager = DataManager<JQLAliasTrait>

enum JQLAliasTrait: DataTrait {
    typealias RawObject = [JQLAlias]
    static let filename = "jql_aliaes"

    enum Error: Swift.Error {
        case noJQLAliases
        case nameExists(String)
        case nameNotFound(String)
    }
}

extension DataManager where Trait == JQLAliasTrait {
    static let shared = JQLAliasManager()

    func loadAliases() throws -> [JQLAlias] {
        let aliases = try getRawModel() ?? {
            throw Trait.Error.noJQLAliases
        }()

        if aliases.isEmpty {
            throw Trait.Error.noJQLAliases
        }

        return aliases
    }

    func showAliases() throws {
        let aliases = try loadAliases()
        print("Registered JIRA Query Language Aliases:\n")
        aliases.forEach {
            print("\tname: \($0.name), jql: \($0.jql)")
        }
    }

    func getAlias(name: String) throws -> JQLAlias {
        let aliases = try loadAliases()
        guard let index = aliases.index(where: { $0.name == name }) else {
            throw Trait.Error.nameNotFound(name)
        }
        return aliases[index]
    }

    func addAlias(name: String, jql: String) throws {
        let alias = JQLAlias(name: name, jql: jql)
        var aliases = try getRawModel() ?? [JQLAlias]()
        if aliases.contains(alias) {
            throw Trait.Error.nameExists(name)
        }
        aliases.append(alias)
        try write(aliases)
    }

    func removeAlias(name: String) throws {
        var aliases = try loadAliases()
        guard let index = aliases.index(where: { $0.name == name }) else {
            throw Trait.Error.nameNotFound(name)
        }
        aliases.remove(at: index)
        try write(aliases)
    }
}