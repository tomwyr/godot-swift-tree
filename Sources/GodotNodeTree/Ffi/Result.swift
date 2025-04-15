import Foundation

enum Result<T: Codable, E: Error & Codable> {
  case ok(T)
  case err(E)

  init(_ resolve: () throws(E) -> T) {
    do {
      self = .ok(try resolve())
    } catch {
      self = .err(error)
    }
  }

  func unwrap() throws(E) -> T {
    switch self {
    case let .ok(value):
      return value
    case let .err(value):
      throw value
    }
  }
}

extension Result: Codable {
  enum CodingKeys: String, CodingKey {
    case ok, err
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    if let value = try? container.decode(T.self, forKey: .ok) {
      self = .ok(value)
    } else if let value = try? container.decode(E.self, forKey: .err) {
      self = .err(value)
    } else {
      throw DecodingError.dataCorruptedError(
        forKey: CodingKeys.ok, in: container,
        debugDescription: "Invalid data format for Result enum"
      )
    }
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    switch self {
    case .ok(let value):
      try container.encode(value, forKey: .ok)
    case .err(let value):
      try container.encode(value, forKey: .err)
    }
  }
}

extension Result {
  init?(json: String) {
    if let result = try? jsonDecode(json, into: Self.self) {
      self = result
    } else {
      return nil
    }
  }

  func jsonEncoded() -> String {
    if let encoded = try? jsonEncode(self) {
      encoded
    } else {
      #"{"error": "Unexpected encoding error of result \#(self)"}"#
    }
  }
}

private func jsonEncode<T: Encodable>(_ input: T) throws -> String {
  let data = try JSONEncoder().encode(input)
  return String(data: data, encoding: .utf8)!
}

private func jsonDecode<T: Decodable>(_ input: String, into: T.Type) throws -> T {
  let data = input.data(using: .utf8)!
  return try JSONDecoder().decode(T.self, from: data)
}
