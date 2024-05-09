//
//  KeychainValue.swift
//  
//
//  Created by Andrej Jasso on 10/04/2024.
//

import Foundation
import Combine
import CombineExt

/// The KeychainValue wraps a value of any type that conforms to the Codable protocol, in order to store it in the Keychain
@available(iOS 13.0, *)
@propertyWrapper
public class KeychainValueV1<T: Codable> {

    /// It wraps a value of any type that conforms to the Codable protocol, in order to store it in a Keychain.
    /// - Parameters:
    ///   - value: A value of any type that conforms to the Codable protocol.
    private struct Wrapper: Codable {

        let value: T

    }

    private let subject: PassthroughSubject<T, Never> = PassthroughSubject()
    private let key: String
    private let defaultValue: T
    private let accessibility: KeychainItemAccessibility?

    /// Initializes a KeychainValue instance with a given key, default value, and accessibility.
    /// - Parameters:
    ///   - key: The key for the Keychain item
    ///   - defaultValue: The default value for the Keychain item
    ///   - accessibility: The accessibility level for the Keychain item. The default value is nil.
    public init(_ key: String, defaultValue: T, accessibility: KeychainItemAccessibility? = nil) {
        self.key = key
        self.defaultValue = defaultValue
        self.accessibility = accessibility
    }

    /// Provide the wrapped value to the user which is retrieved from Keychain or the default value
    public var wrappedValue: T {
        get {
            // Retrieve data from Keychain using the key and accessibility if specified
            guard let data = KeychainWrapper.standard.data(
                forKey: key,
                withAccessibility: accessibility
            ) else {
                // Return default value if data cannot be retrieved from Keychain
                return defaultValue
            }

            // Decode the data and get the value, or return default value if decoding fails
            let value = (try? PropertyListDecoder().decode(Wrapper.self, from: data))?.value ?? defaultValue

            return value
        }

        set(newValue) {
            // Wrap the new value in a Wrapper structure
            let wrapper = Wrapper(value: newValue)

            // Encode the wrapper and set the data in Keychain using the key and accessibility if specified
            guard let data = try? PropertyListEncoder().encode(wrapper) else {
                // If encoding fails, remove the object from Keychain
                KeychainWrapper.standard.removeObject(forKey: key)
                return
            }
            KeychainWrapper.standard.set(data, forKey: key, withAccessibility: accessibility)

            // Send the new value through the subject
            subject.send(newValue)
        }
    }

    /// The publisher property provides an AnyPublisher that sends the current value of wrappedValue, followed by any future changes.
    public lazy var publisher: AnyPublisher<T, Never> = {
        Deferred {
            self.subject
                .prepend(self.wrappedValue)
                .share(replay: 1)
        }.eraseToAnyPublisher()
    }()

}
