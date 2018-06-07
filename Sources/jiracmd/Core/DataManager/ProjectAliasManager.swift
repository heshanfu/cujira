//
//  ProjectAliasManager.swift
//  jiracmd
//
//  Created by marty-suzuki on 2018/06/07.
//

import Foundation

typealias ProjectAliasManager = DataManager<ProjectAliasTrait>

enum ProjectAliasTrait: DataTrait {
    typealias RawObject = [ProjectAlias.Raw]
    static let filename = "project_aliases"

    enum Error: Swift.Error {
        case noProjectAliases
        case nameExists(String)
        case nameNotFound(String)
    }
}

extension DataManager where Trait == ProjectAliasTrait {
    static let shared = ProjectAliasManager()

    func loadAliases() throws -> [ProjectAlias] {
        let rawAliases = try getRawModel() ?? {
            throw Trait.Error.noProjectAliases
            }()

        if rawAliases.isEmpty {
            throw Trait.Error.noProjectAliases
        }

        let aliases: [ProjectAlias] = rawAliases.compactMap {
            guard let name = $0.name, let projectID = $0.projectID, let boardID = $0.boardID else {
                return nil
            }
            return ProjectAlias(name: name, projectID: projectID, boardID: boardID)
        }

        return aliases
    }

    func showAliases() throws {
        let aliases = try loadAliases()
        print("Registered Project Aliases:\n")
        aliases.forEach {
            print("\tname: \($0.name), projectID: \($0.projectID), boardID: \($0.boardID)")
        }
    }

    func getAlias(name: String) throws -> ProjectAlias {
        let aliases = try loadAliases()
        guard let index = aliases.index(where: { $0.name == name }) else {
            throw Trait.Error.nameNotFound(name)
        }
        return aliases[index]
    }

    func addAlias(name: String, projectID: Int, boardID: Int) throws {
        let alias = ProjectAlias(name: name, projectID: projectID, boardID: boardID)
        var aliases: [ProjectAlias]
        do {
            aliases = try loadAliases()
        } catch {
            aliases = []
        }
        if aliases.contains(alias) {
            throw Trait.Error.nameExists(name)
        }
        aliases.append(alias)
        try write(aliases.map { $0.toRaw() })
    }

    func removeAlias(name: String) throws {
        var aliases = try loadAliases()
        guard let index = aliases.index(where: { $0.name == name }) else {
            throw Trait.Error.nameNotFound(name)
        }
        aliases.remove(at: index)
        try write(aliases.map { $0.toRaw() })
    }
}