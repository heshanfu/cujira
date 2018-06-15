//
//  Issue.Command.swift
//  cujira
//
//  Created by marty-suzuki on 2018/06/06.
//

import Core
import Foundation

enum Issue {
    static func run(_ parser: ArgumentParser, facade: Facade) throws {
        let command: Command = try parser.parse()

        switch command {
        case .list:
            do {
                try List.run(parser, facade: facade)
            } catch {
                throw Root.Error(inner: error, usage: Issue.List.usageDescription(command.rawValue))
            }
        case .jql:
            do {
                try JQL.run(parser, facade: facade)
            } catch {
                throw Root.Error(inner: error, usage: Issue.JQL.usageDescription(command.rawValue))
            }
        }
    }

    enum Command: String, CommandList {
        case list
        case jql
    }

    enum AggregateParameter {
        case total
        case label(String)
        case type(String)
        case user(String)
        case status(String)
        case epicLink(String)
    }

    private typealias Aggregation = IssueAggregation.Aggregation

    private static func aggregations(issueResults: [IssueResult], aggregateParameters: [AggregateParameter]) -> [Aggregation] {
        return aggregateParameters.map {
            switch $0 {
            case .total:
                return Aggregation(issueResults: issueResults, name: "Issues", count: issueResults.count)
            case .label(let name):
                let filteredIssues = issueResults.filter { $0.issue.fields.labels.first { $0 == name } != nil }
                let count = filteredIssues.count
                return Aggregation(issueResults: filteredIssues, name: name, count: count)
            case .type(let name):
                let filteredIssues = issueResults.filter { $0.issue.fields.issuetype.name == name }
                let count = filteredIssues.count
                return Aggregation(issueResults: filteredIssues, name: name, count: count)
            case .user(let name):
                let filteredIssues = issueResults.filter { $0.issue.fields.assignee?.name == name }
                let count = filteredIssues.count
                return Aggregation(issueResults: filteredIssues, name: name, count: count)
            case .status(let name):
                let filteredIssues = issueResults.filter { $0.issue.fields.status.name == name }
                let count = filteredIssues.count
                return Aggregation(issueResults: filteredIssues, name: name, count: count)
            case .epicLink(let name):
                let filteredIssues = issueResults.filter { $0.issue.fields.status.name == name }
                let count = filteredIssues.count
                return Aggregation(issueResults: filteredIssues, name: name, count: count)
            }
        }
    }

    private static func filteredIssueResults(_ issueResults: [IssueResult], by aggregateParameters: [AggregateParameter]) -> [IssueResult] {
        return aggregateParameters.reduce(issueResults) { result, parameter -> [IssueResult] in
            switch parameter {
            case .total:
                return result
            case .label(let name):
                return result.filter { $0.issue.fields.labels.first { $0 == name } != nil }
            case .type(let name):
                return result.filter { $0.issue.fields.issuetype.name == name }
            case .user(let name):
                return result.filter { $0.issue.fields.assignee?.name == name }
            case .status(let name):
                return result.filter { $0.issue.fields.status.name == name }
            case .epicLink(let name):
                return result.filter { $0.issue.fields.status.name == name }
            }
        }
    }

    static func printIssueResults(_ issueResults: [IssueResult],
                                  jql: String,
                                  config: Config,
                                  isJson: Bool,
                                  aggregateParameters: [AggregateParameter],
                                  isAllIssues: Bool) throws {
        if isJson {
            let data: Data
            if aggregateParameters.isEmpty {
                data = try JSONEncoder().encode(issueResults)
            } else {
                let _filteredIssues = filteredIssueResults(issueResults, by: aggregateParameters)
                let _aggregations = aggregations(issueResults: issueResults, aggregateParameters: aggregateParameters)
                let matched = Aggregation(issueResults: _filteredIssues, name: "Matched Issues", count: _filteredIssues.count)
                let aggregation = IssueAggregation(aggregations: _aggregations + [matched])
                data = try JSONEncoder().encode(aggregation)
            }

            let jsonString = String(data: data, encoding: .utf8) ?? "{}"
            print(jsonString)
        } else {
            print("JQL: \(jql)")

            func printIssueResults(_ results: [IssueResult]) {
                results.forEach { result in
                    let issue = result.issue
                    print("\nSummary: \(issue.fields.summary)")
                    print("URL: https://\(config.domain).atlassian.net/browse/\(issue.key)")
                    print("IssueType: \(issue.fields.issuetype.name)")
                    print("Status: \(issue.fields.status.name)")
                    print("User: \(issue.fields.assignee.map { $0.name } ?? "--")")

                    issue.fields.fixVersions.forEach { version in
                        print("Fix Version: \(version.name)")
                    }

                    if let epic = result.epic {
                        print("Epic Link: \(epic.name)")
                    }

                    if let storyPoint = result.storyPoint {
                        print("Story Points: \(storyPoint)")
                    }
                }
            }

            if aggregateParameters.isEmpty {
                printIssueResults(issueResults)
            } else {
                let _filteredIssues = filteredIssueResults(issueResults, by: aggregateParameters)

                if isAllIssues {
                    printIssueResults(issueResults)
                } else {
                    printIssueResults(_filteredIssues)
                }

                print("")

                let _aggregations = aggregations(issueResults: issueResults, aggregateParameters: aggregateParameters)
                _aggregations.forEach {
                    print("Number of \($0.name): \($0.count)")
                }
                print("Number of Matched Issues: \(_filteredIssues.count)")
            }
        }
    }
}
