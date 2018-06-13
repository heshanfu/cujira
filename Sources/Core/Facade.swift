//
//  Facade.swift
//  cujira
//
//  Created by marty-suzuki on 2018/06/08.
//

import Foundation

public final class Facade {
    public let sprintService: SprintService
    public let issueService: IssueService
    public let projectService: ProjectService
    public let jqlService: JQLService
    public let configService: ConfigService
    public let boardService: BoardService

    public convenience init() {
        self.init(baseDirectoryPath: DataManagerConst.workingDir)
    }

    public convenience init(baseDirectoryPath: String) {
        let configManager = ConfigManager(workingDirectory: { "\(baseDirectoryPath)" })
        let configService = ConfigService(manager: configManager)

        let subDirectoryPath: () throws -> String = {
            try "\(baseDirectoryPath)/\(configService.loadConfig().domain)"
        }

        let projectAliasManager = ProjectAliasManager(workingDirectory: subDirectoryPath)
        let jqlAliasManager = JQLAliasManager(workingDirectory: subDirectoryPath)
        let boardDataManager = BoardDataManager(workingDirectory: subDirectoryPath)
        let sprintDataManager = SprintDataManager(workingDirectory: subDirectoryPath)
        let issueTypeDataManager = IssueTypeDataManager(workingDirectory: subDirectoryPath)
        let statusDataManager = StatusDataManager(workingDirectory: subDirectoryPath)

        let session = URLSession.shared
        let jiraSession = JiraSession(session: session,
                                      domain: { try configService.loadConfig().domain },
                                      apiKey: { try configService.loadConfig().apiKey },
                                      username: { try configService.loadConfig().username })
        let sprintService = SprintService(session: jiraSession, sprintDataManager: sprintDataManager)
        let issueService = IssueService(session: jiraSession,
                                        issueTypeDataManager: issueTypeDataManager,
                                        statusDataManager: statusDataManager)
        let projectService = ProjectService(session: jiraSession, aliasManager: projectAliasManager)
        let jqlService = JQLService(aliasManager: jqlAliasManager)
        let boardService = BoardService(session: jiraSession, boardDataManager: boardDataManager)

        self.init(sprintService: sprintService,
                  issueService: issueService,
                  projectService: projectService,
                  jqlService: jqlService,
                  configService: configService,
                  boardService: boardService)
    }

    public init(sprintService: SprintService,
                issueService: IssueService,
                projectService: ProjectService,
                jqlService: JQLService,
                configService: ConfigService,
                boardService: BoardService) {
        self.sprintService = sprintService
        self.issueService = issueService
        self.projectService = projectService
        self.jqlService = jqlService
        self.configService = configService
        self.boardService = boardService
    }
}
