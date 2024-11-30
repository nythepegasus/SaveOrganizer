import Foundation


public extension Data {
    init?(filePath: String){ try? self.init(contentsOf: URL(fileURLWithPath: filePath)) }

    @inlinable
    var hexString: String { get { map { String(format: "%02x", $0) }.joined() } }
}

public extension URL {
    var attributes: [FileAttributeKey: Any]? {
        do {
            return try FileManager.default.attributesOfItem(atPath: path)
        } catch let error as NSError {
            print("FileAttribute error: \(error)")
        }
        return nil
    }

    var fileSize: UInt64 { attributes?[.size] as? UInt64 ?? 0 }
    var fileSizeS: String { ByteCountFormatter().string(fromByteCount: Int64(fileSize)) }

    var parent: Self { .init(fileURLWithPath: pathComponents[0..<pathComponents.count-1].joined(separator: "/")) }
}

// MARK: - Errors
public enum SOGameError: Error {
    case invalidPath(String)
    case invalidDateFormat(String)
    case uuidParsingFailed(String)
}

public protocol SOGamePath {
    var path: URL { get }
}

public extension SOGamePath {
    func mkdir() throws { try FileManager.default.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil) }
}

// MARK: - SOGame
public class SOGame: SOGamePath, Encodable {
    let name: String
    private(set) var profiles: [SOGameProfile] = []
    
    public init(name: String) { self.name = name }
    
    public var path: URL { URL(fileURLWithPath: name) }

    public func newProfile() -> SOGameProfile { .init(game: self) }
    
    public func newProfile(persist: Bool = false) throws -> SOGameProfile {
        let profile = newProfile()
        if persist {
            try profile.mkdir()
            profiles.append(profile)
        }
        return profile
    }
    
    public init(path: URL) throws { name = path.lastPathComponent }
}

// MARK: - SOGameProfile
public class SOGameProfile: SOGamePath, Identifiable, Encodable {
    public let id: UUID
    let game: SOGame
    private(set) var saves: [SOGameSave] = []
    
    public init(game: SOGame, id: UUID = UUID()) {
        self.game = game
        self.id = id
    }
    
    public var path: URL { game.path.appendingPathComponent(id.uuidString) }

    public func newSave() -> SOGameSave { return SOGameSave(profile: self) }
    
    public func newSave(persist: Bool = false) throws -> SOGameSave {
        let save = newSave()
        if persist {
            try save.mkdir()
            saves.append(save)
        }
        return save
    }
    
    init(game: SOGame, path: URL) throws {
        guard let uuid = UUID(uuidString: path.lastPathComponent) else {
            throw SOGameError.uuidParsingFailed(path.lastPathComponent)
        }
        self.game = game
        self.id = uuid
    }
}

// MARK: - SOGameSave
public class SOGameSave: SOGamePath, Encodable {
    public let profile: SOGameProfile
    public let timestamp: Date
    
    public init(profile: SOGameProfile, timestamp: Date = Date()) {
        self.profile = profile
        self.timestamp = timestamp
    }
    
    var dayPath: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy-MM-dd"
        return formatter.string(from: timestamp)
    }
    
    var timePath: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH-mm-ss"
        return formatter.string(from: timestamp)
    }
    
    public var path: URL { profile.path.appendingPathComponent(dayPath).appendingPathComponent(timePath) }
    
    init(profile: SOGameProfile, path: URL) throws {
        let components = path.pathComponents
        guard components.count >= 2 else {
            throw SOGameError.invalidPath(path.absoluteString)
        }
        
        let day = components[components.count - 2]
        let time = components[components.count - 1]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yy-MM-dd/HH-mm-ss"
        
        guard let timestamp = formatter.date(from: "\(day)/\(time)") else {
            throw SOGameError.invalidDateFormat("\(day)/\(time)")
        }
        self.profile = profile
        self.timestamp = timestamp
    }
}

