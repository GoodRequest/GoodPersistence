//
//  KeychainValue.swift
//
//  Created by Sebastián Mráz on 3/1/24.
//

import Foundation
import Combine
import CombineExt
import KeychainAccess
import SwiftUI

/// Configuration options for changing Keychain settings.
///
/// Use this struct to specify various parameters when working with the Keychain, such as service name, server information,
/// protocol type, access group, and authentication type.
///
/// - Parameters:
///   - service: A string specifying the service name for the Keychain configuration.
///   - server: A string indicating the server information related to the Keychain configuration.
///   - protocolType: An enumeration specifying the protocol type associated with the Keychain configuration.
///   - accessGroup: A string indicating the access group for the Keychain configuration.
///   - authenticationType: An enumeration specifying the authentication type for the Keychain configuration.
public struct KeychainConfiguration {
    
    let service: String?
    let server: String?
    let protocolType: ProtocolType?
    let accessGroup: String?
    let authenticationType: AuthenticationType?

    init(
        service: String? = nil,
        server: String? = nil,
        protocolType: ProtocolType? = nil,
        accessGroup: String? = nil,
        authenticationType: AuthenticationType? = nil
    ) {
        self.service = service
        self.server = server
        self.protocolType = protocolType
        self.accessGroup = accessGroup
        self.authenticationType = authenticationType
    }

}

/// A utility enum for managing Keychain operations and configuration.
///
/// Use this enum to interact with the Keychain, set default configurations, and modify settings as needed.
public enum Keychain {
    
    /// The default Keychain instance.
    public private(set) static var `default` = KeychainAccess.Keychain()
    
    /// Configures the default Keychain instance with the specified configuration.
    ///
    /// The configuration options include service name, server information, protocol type, access group, and authentication type.
    ///
    /// - Parameter configuration: The `KeychainConfiguration` struct specifying the desired Keychain settings.
    public static func configure(with configuration: KeychainConfiguration) {
        if let server = configuration.server,
           let protocolType = configuration.protocolType,
           let accessGroup = configuration.accessGroup,
           let authenticationType = configuration.authenticationType {
            Self.default = KeychainAccess.Keychain(
                server: server,
                protocolType: protocolType,
                accessGroup: accessGroup,
                authenticationType: authenticationType
            )
        } else if let service = configuration.service,
                  let accessGroup = configuration.accessGroup {
            Self.default = KeychainAccess.Keychain(service: service, accessGroup: accessGroup)
        } else if let server = configuration.server,
                  let protocolType = configuration.protocolType {
            Self.default = KeychainAccess.Keychain(server: server, protocolType: protocolType)
        } else if let service = configuration.service {
            Self.default = KeychainAccess.Keychain(service: service)
        } else if let accessGroup = configuration.accessGroup {
            Self.default = KeychainAccess.Keychain(accessGroup: accessGroup)
        }
    }
    
}

/// An enumeration representing errors that may occur during Keychain operations.
///
/// - `accessError`: An error indicating an issue with accessing or retrieving data from the Keychain.
/// - `decodeError`: An error indicating a problem decoding data retrieved from the Keychain.
/// - `encodeError`: An error indicating a problem encoding data before storing it in the Keychain.
public enum KeychainError: Error, Equatable, Hashable {

    public static func == (lhs: KeychainError, rhs: KeychainError) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    public func hash(into hasher: inout Hasher) {
        switch self {
        case .accessError(let error):
            hasher.combine(self.localizedDescription)
            hasher.combine(error.localizedDescription)
        case .decodeError(let error):
            hasher.combine(self.localizedDescription)
            hasher.combine(error.localizedDescription)
        case .encodeError(let error):
            hasher.combine(self.localizedDescription)
            hasher.combine(error.localizedDescription)
        }
    }

    case accessError(Error)
    case decodeError(Error)
    case encodeError(Error)

}

/// A property wrapper class for simplifying the storage and retrieval of Codable values in the Keychain.
///
/// Use this property wrapper to store and access values of any type that conforms to the Codable protocol securely in the Keychain.
/// The class provides a convenient way to handle default values, accessibility levels, and synchronization options.
@available(iOS 13.0, *)
@propertyWrapper
public class KeychainValue<T: Codable & Equatable> {

    // MARK: - Initialization
    
    /// Initializes a `KeychainValue` instance with a given key, default value, accessibility, and optional synchronization and authentication policy.
    ///
    /// - Parameters:
    ///   - key: The key for the Keychain item.
    ///   - defaultValue: The default value for the Keychain item.
    ///   - accessibility: The accessibility level for the Keychain item. The default value is nil.
    ///   - synchronizable: A boolean indicating whether the Keychain item should be synchronized across devices. The default is false.
    ///   - authenticationPolicy: An optional authentication policy for the Keychain item.
    public init(
        _ key: String,
        defaultValue: T,
        accessibility: KeychainAccess.Accessibility? = nil,
        synchronizable: Bool = false,
        authenticationPolicy: KeychainAccess.AuthenticationPolicy? = nil
    ) {
        self.key = key
        self.defaultValue = defaultValue
        self.accessibility = accessibility
        self.synchronizable = synchronizable
        self.authenticationPolicy = authenticationPolicy

        Keychain.configure(with: .init(service: Bundle.main.bundleIdentifier ?? "SwiftKeychainWrapper"))
    }
    
    // MARK: - Wrapper

    /// A private structure used to wrap a value of any type that conforms to the Codable protocol for storage in the Keychain.
    ///
    /// This struct is responsible for encapsulating the value within the Codable protocol requirements and is utilized
    /// internally by the `KeychainValue` class to manage the storage and retrieval of values in the Keychain.
    ///
    /// - Parameters:
    ///   - value: A value of any type that conforms to the Codable protocol.
    private struct Wrapper: Codable {

        let value: T

    }
    
    // MARK: - Properties

    private let valueSubject: PassthroughSubject<T, Never> = PassthroughSubject()

    private let key: String
    private let defaultValue: T
    private let accessibility: KeychainAccess.Accessibility?
    private let synchronizable: Bool
    private let authenticationPolicy: KeychainAccess.AuthenticationPolicy?

    public func retrieveValue(key: String) throws -> T {
        // Setting up the Keychain for retrieval.
        let keychain = setupKeychain()
        do {
            // Attempting to retrieve data from the Keychain using the specified key.
            guard let data = try keychain.getData(key)
            else {
                // If no data is found in the Keychain, return the default value.
                GoodPersistence.log(message: "Default keychain value [\(defaultValue)] for key [\(key)] used. Reason: Empty data.")
                return defaultValue
            }
            do {
                return try decodeJSON(data: data)
            } catch {
                do {
                    // ONLY SERVES AS BACKWARDS COMPATIBILITY ADAPTER FROM V1->V2
                    return try decodePlist(data: data)
                } catch {
                    throw error
                }
            }
        } catch {
            GoodPersistence.log(message: "Default keychain value [\(defaultValue)] for key [\(key)] used. Reason: Keychain access.")
            throw error
        }
    }

    func decodeJSON(data: Data) throws -> T {
        do {
            // Decoding the retrieved data to get the value using Json Decoder.
            return try JSONDecoder().decode(Wrapper.self, from: data).value
        } catch {
            GoodPersistence.log(message: "Default keychain value [\(defaultValue)] for key [\(key)] used. Reason: Decoding error using JSON Decoder.")
            throw error
        }
    }

    func decodePlist(data: Data) throws -> T {
        do {
            // Decoding fallback of retrieved data to get the value using Plist Decoder.
            return try PropertyListDecoder().decode(Wrapper.self, from: data).value
        } catch {
            GoodPersistence.log(message: "Default keychain value [\(defaultValue)] for key [\(key)] used. Reason: Decoding error using PList Decoder.")
            throw error
        }
    }

    private func saveValue(key: String, newValue: T) throws {
        // Setting up the Keychain for storage.
        let keychain = setupKeychain()
        if newValue == defaultValue {
            // If the new value is equal to the default value, remove the corresponding entry from the Keychain.
            do {
                try keychain.remove(key)
                valueSubject.send(newValue)
            } catch {
                GoodPersistence.log(message: "Setting keychain value [\(defaultValue)] for key [\(key)] not performed. Reason: Removing from keychain failed.")
                throw error
            }
        } else {
            // If the new value is different from the default value, wrap it in a Wrapper structure for encoding.
            let wrapper = Wrapper(value: newValue)

            do {
                // Encoding the wrapped value.
                let data = try JSONEncoder().encode(wrapper)
                // Storing data in the Keychain using the specified key
                try keychain.set(data, key: key)
                valueSubject.send(newValue)
            } catch {
                GoodPersistence.log(message: "Setting keychain value [\(newValue)] for key [\(key)] not performed. Reason: Data encoding failed.")
                throw error
            }
            GoodPersistence.log(message: "Keychain Data for key [\(key)] has changed to \(newValue).")
        }
    }

    /// Provides the wrapped value retrieved from the Keychain or the default value.
    ///
    /// Use this property to access the value stored in the Keychain. If the value does not exist in the Keychain,
    /// the default value specified during initialization is returned.
    ///
    /// - Note: The wrapped value is automatically retrieved from the Keychain upon access, and any changes
    /// made to this property will be reflected in the Keychain as well.
    public var wrappedValue: T {
        get {
            do {
                return try retrieveValue(key: key)
            } catch {
                GoodPersistence.log(error: error)

                return defaultValue
            }
        }

        set(newValue) {
            do {
                try saveValue(key: key, newValue: newValue)
            } catch {
                GoodPersistence.log(error: error)
            }
        }
    }
    
    /// A projected value that provides a `Binding` to the wrapped value.
    ///
    /// Use this property to create a two-way binding to the `wrappedValue` property.
    /// The `Binding` allows external entities to read and modify the value in a reactive manner.
    public var projectedValue: Binding<T> {
        Binding(get: {
            return self.wrappedValue
        }, set: { newValue in
            self.wrappedValue = newValue
        })
    }

    /// The `valuePublisher` property provides an `AnyPublisher` that sends the current value of `wrappedValue`,
    /// followed by any future changes, with error handling for Keychain-related errors.
    ///
    /// Use this property to observe changes to the value of the `KeychainValue` instance, receiving updates
    /// through a publisher that includes error information when applicable.
    ///
    /// - Note: The publisher shares the current value on subscription, followed by subsequent changes.
    ///
    public lazy var valuePublisher: AnyPublisher<T, Never> = {
        if let authenticationPolicy {
            Deferred {
                self.valueSubject
                    .share(replay: 1)
            }.eraseToAnyPublisher()
        } else {
            Deferred {
                self.valueSubject
                    .prepend(self.wrappedValue)
                    .share(replay: 1)
            }.eraseToAnyPublisher()
        }
    }()

    /// Sets up and returns a `KeychainAccess.Keychain` instance based on the provided configurations.
    ///
    /// This method constructs a `KeychainAccess.Keychain` instance with optional accessibility and authentication policy,
    /// considering the specified synchronization option. It is used internally by the `KeychainValue` class to create
    /// a Keychain instance tailored to the desired settings.
    ///
    /// - Returns: A configured `KeychainAccess.Keychain` instance based on the provided parameters.
    private func setupKeychain() -> KeychainAccess.Keychain {
        if let accessibility, let authenticationPolicy {
            return Keychain.default
                .accessibility(accessibility, authenticationPolicy: authenticationPolicy)
        } else if let accessibility {
            return Keychain.default
                .synchronizable(synchronizable)
                .accessibility(accessibility)
        } else {
            return Keychain.default
                .synchronizable(synchronizable)
        }
    }

}
