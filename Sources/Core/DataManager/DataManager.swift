//
//  DataManager.swift
//  cujira
//
//  Created by marty-suzuki on 2018/06/04.
//

import Foundation

public protocol DataTrait {
    associatedtype RawObject: Codable
    static var filename: String { get }
    static var path: String { get }
}

public enum DataManagerError: Error {
    case invalidURL(String)
    case createFileFailed(URL)
}

enum DataManagerConst {
    static let workingDir = "/usr/local/etc/cujira"
    static let domainRelationalPath = "/domain_relational"
    static let currentPath = "/./"
}

public final class DataManager<Trait: DataTrait> {
    private let fileManager: FileManager
    private let workingDirectory: String

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        self.workingDirectory = "\(DataManagerConst.workingDir)\(Trait.path)"
    }

    private func baseURLString(extraPath: String) -> String {
        return "file://\(workingDirectory)\(extraPath)"
    }

    private func workingDirectoryURL(extraPath: String) throws -> URL {
        let urlString = baseURLString(extraPath: extraPath)
        return try URL(string: urlString) ?? {
            throw DataManagerError.invalidURL(urlString)
        }()
    }

    private func getURL(extraPath: String) throws -> URL {
        let urlString = "\(baseURLString(extraPath: extraPath))/\(Trait.filename).dat"
        return try URL(string: urlString) ?? {
            throw DataManagerError.invalidURL(urlString)
        }()
    }

    func getRawModel(extraPath: String = "") throws -> Trait.RawObject? {
        let url = try getURL(extraPath: extraPath)
        if fileManager.fileExists(atPath: url.path) {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(Trait.RawObject.self, from: data)
        } else {
            return nil
        }
    }

    func write(_ object: Trait.RawObject, extraPath: String = "") throws {
        let data = try JSONEncoder().encode(object)
        let fileURL = try getURL(extraPath: extraPath)

        if fileManager.fileExists(atPath: fileURL.path) {
            try data.write(to: fileURL)
        } else {
            let dirURL = try workingDirectoryURL(extraPath: extraPath)
            try fileManager.createDirectory(at: dirURL, withIntermediateDirectories: true, attributes: nil)
            if !fileManager.createFile(atPath: fileURL.path, contents: data, attributes: [.posixPermissions: 0o755]) {
                throw DataManagerError.createFileFailed(fileURL)
            }
        }
    }
}

extension DataManagerError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL(let url):
            return "\(url) is invalid URL."
        case .createFileFailed(let url):
            return "Faild to create file to \(url)."
        }
    }
}

extension DataManager where Trait == ConfigTrait {
    func removeDomainRelationalDirectory() throws {
        let urlString = "file://\(DataManagerConst.workingDir)\(DataManagerConst.domainRelationalPath)"
        let url = try URL(string: urlString) ?? {
            throw DataManagerError.invalidURL(urlString)
        }()
        try fileManager.removeItem(at: url)
    }
}
