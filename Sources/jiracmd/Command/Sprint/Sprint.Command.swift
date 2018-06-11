//
//  Sprint.Command.swift
//  jiracmd
//
//  Created by marty-suzuki on 2018/06/06.
//

import Core
import Foundation

enum Sprint {
    static func run(_ parser: ArgumentParser) throws {
        let command: Command = try parser.parse()
        switch command {
        case .list:
            try List.run(parser)
        }
    }

    enum Command: String, CommandList {
        case list
    }

    enum List {
        enum Error: Swift.Error {
            case noBoardID
        }

        static func run(_ parser: ArgumentParser, facade: Facade = .init()) throws {
            guard let boardId = parser.shift().flatMap(Int.init) else {
                throw Error.noBoardID
            }

            let sprints = try facade.sprintService.fetchAllSprints(boardId: boardId)

            print("Results:")
            if sprints.isEmpty {
                print("\n\tEmpty")
            } else {
                let dateFormatter = DateFormatter.core.yyyyMMdd
                let sorted = sprints.sorted { $0.id < $1.id }
                sorted.forEach {
                    print("\n\tid: \($0.id)")
                    print("\tname: \($0.name)")
                    print("\tstartDate: \($0.startDate.map { dateFormatter.string(from: $0) } ?? "--")")
                    print("\tendDate: \($0.endDate.map { dateFormatter.string(from: $0) } ?? "--")")
                }
            }
        }
    }
}

extension Sprint.List.Error: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .noBoardID:
            return "BOARD_ID is required parameter."
        }
    }
}