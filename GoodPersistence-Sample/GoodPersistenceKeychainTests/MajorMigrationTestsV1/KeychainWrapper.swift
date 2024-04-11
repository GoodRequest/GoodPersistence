//
//  KeychainWrapper.swift
//  
//
//  Created by Andrej Jasso on 10/04/2024.
//

import Foundation

private let SecMatchLimit: String! = kSecMatchLimit as String
private let SecReturnData: String! = kSecReturnData as String
private let SecReturnPersistentRef: String! = kSecReturnPersistentRef as String
private let SecValueData: String! = kSecValueData as String
private let SecAttrAccessible: String! = kSecAttrAccessible as String
private let SecClass: String! = kSecClass as String
private let SecAttrService: String! = kSecAttrService as String
private let SecAttrGeneric: String! = kSecAttrGeneric as String
private let SecAttrAccount: String! = kSecAttrAccount as String
private let SecAttrAccessGroup: String! = kSecAttrAccessGroup as String
private let SecReturnAttributes: String = kSecReturnAttributes as String

/// KeychainWrapper is a class to help make Keychain access in Swift more straightforward. It is designed to make accessing the Keychain services more like using NSUserDefaults, which is much more familiar to people.
@available(OSX 10.13, *)
open class KeychainWrapper {

    @available(*, deprecated, message: "KeychainWrapper.defaultKeychainWrapper is deprecated, use KeychainWrapper.standard instead")
    public static let defaultKeychainWrapper = KeychainWrapper.standard

    /// Default keychain wrapper access
    public static let standard = KeychainWrapper()

    /// ServiceName is used for the kSecAttrService property to uniquely identify this keychain accessor. If no service name is specified, KeychainWrapper will default to using the bundleIdentifier.
    private (set) public var serviceName: String

    /// AccessGroup is used for the kSecAttrAccessGroup property to identify which Keychain Access Group this entry belongs to. This allows you to use the KeychainWrapper with shared keychain access between different applications.
    private (set) public var accessGroup: String?

    /// A private static constant defaultServiceName that returns the bundle identifier of the main bundle or "SwiftKeychainWrapper".
    private static let defaultServiceName: String = {
        return Bundle.main.bundleIdentifier ?? "SwiftKeychainWrapper"
    }()

    private convenience init() {
        self.init(serviceName: KeychainWrapper.defaultServiceName)
    }

    /// Create a custom instance of KeychainWrapper with a custom Service Name and optional custom access group.
    /// - Parameters:
    ///   - serviceName: The ServiceName for this instance. Used to uniquely identify all keys stored using this keychain wrapper instance.
    ///   - accessGroup: Optional unique AccessGroup for this instance. Use a matching AccessGroup between applications to allow shared keychain access.
    public init(serviceName: String, accessGroup: String? = nil) {
        self.serviceName = serviceName
        self.accessGroup = accessGroup
    }

    // MARK:- Public Methods

    /// Checks if keychain data exists for a specified key.
    /// - Parameters:
    ///   - key: The key to check for.
    ///   - accessibility: Optional accessibility to use when retrieving the keychain item.
    /// - Returns: True if a value exists for the key. False otherwise.
    open func hasValue(forKey key: String, withAccessibility accessibility: KeychainItemAccessibility? = nil) -> Bool {
        if let _ = data(forKey: key, withAccessibility: accessibility) {
            return true
        } else {
            return false
        }
    }

    /// Retrieves the `KeychainItemAccessibility` of a key stored in the Keychain.
    /// - Parameter key: the key for which the accessibility should be retrieved
    /// - Returns: accessibility of the given key stored in the Keychain, or nil if its not present
    open func accessibilityOfKey(_ key: String) -> KeychainItemAccessibility? {
        var keychainQueryDictionary = setupKeychainQueryDictionary(forKey: key)

        // Remove accessibility attribute
        keychainQueryDictionary.removeValue(forKey: SecAttrAccessible)

        // Limit search results to one
        keychainQueryDictionary[SecMatchLimit] = kSecMatchLimitOne

        // Specify we want SecAttrAccessible returned
        keychainQueryDictionary[SecReturnAttributes] = kCFBooleanTrue

        // Search
        var result: AnyObject?
        let status = SecItemCopyMatching(keychainQueryDictionary as CFDictionary, &result)

        guard status == noErr, let resultsDictionary = result as? [String:AnyObject], let accessibilityAttrValue = resultsDictionary[SecAttrAccessible] as? String else {
            return nil
        }

        return KeychainItemAccessibility.accessibilityForAttributeValue(accessibilityAttrValue as CFString)
    }

    /// Get the keys of all keychain entries matching the current ServiceName and AccessGroup if one is set.
    open func allKeys() -> Set<String> {
        var keychainQueryDictionary: [String:Any] = [
            SecClass: kSecClassGenericPassword,
            SecAttrService: serviceName,
            SecReturnAttributes: kCFBooleanTrue!,
            SecMatchLimit: kSecMatchLimitAll,
            String(kSecAttrSynchronizable): kCFBooleanTrue!
        ]

        if let accessGroup = self.accessGroup {
            keychainQueryDictionary[SecAttrAccessGroup] = accessGroup
        }

        var result: AnyObject?
        let status = SecItemCopyMatching(keychainQueryDictionary as CFDictionary, &result)
        guard status == errSecSuccess else { return [] }

        var keys = Set<String>()
        if let results = result as? [[AnyHashable: Any]] {
            for attributes in results {
                if let accountData = attributes[SecAttrAccount] as? Data,
                   let account = String(data: accountData, encoding: String.Encoding.utf8) {
                    keys.insert(account)
                }
            }
        }
        return keys
    }

    // MARK: Public Getters

    /// Returns an Int value for a specified key.
    /// - Parameters:
    ///   - key: The key to lookup data for.
    ///   - accessibility: Optional accessibility to use when retrieving the keychain item.
    /// - Returns: The Integer associated with the key if it exists. If no data exists, or the data found cannot be encoded as a NSNumber, returns nil.
    open func integer(forKey key: String, withAccessibility accessibility: KeychainItemAccessibility? = nil) -> Int? {
        guard let numberValue = object(forKey: key, withAccessibility: accessibility) as? NSNumber else {
            return nil
        }

        return numberValue.intValue
    }

    /// Returns a Float value for a specified key.
    /// - Parameters:
    ///   - key: The key to lookup data for.
    ///   - accessibility: Optional accessibility to use when retrieving the keychain item.
    /// - Returns: The Float associated with the key if it exists. If no data exists, or the data found cannot be encoded as a NSNumber, returns nil.
    open func float(forKey key: String, withAccessibility accessibility: KeychainItemAccessibility? = nil) -> Float? {
        guard let numberValue = object(forKey: key, withAccessibility: accessibility) as? NSNumber else {
            return nil
        }

        return numberValue.floatValue
    }

    /// Returns a Double value for a specified key.
    /// - Parameters:
    ///   - key: The key to lookup data for.
    ///   - accessibility: Optional accessibility to use when retrieving the keychain item.
    /// - Returns: The Double associated with the key if it exists. If no data exists, or the data found cannot be encoded as a NSNumber, returns nil.
    open func double(forKey key: String, withAccessibility accessibility: KeychainItemAccessibility? = nil) -> Double? {
        guard let numberValue = object(forKey: key, withAccessibility: accessibility) as? NSNumber else {
            return nil
        }

        return numberValue.doubleValue
    }

    /// Returns a Bool value for a specified key.
    /// - Parameters:
    ///   - key: The key to lookup data for.
    ///   - accessibility: Optional accessibility to use when retrieving the keychain item.
    /// - Returns: The Bool associated with the key if it exists. If no data exists, or the data found cannot be encoded as a NSNumber, returns nil.
    open func bool(forKey key: String, withAccessibility accessibility: KeychainItemAccessibility? = nil) -> Bool? {
        guard let numberValue = object(forKey: key, withAccessibility: accessibility) as? NSNumber else {
            return nil
        }

        return numberValue.boolValue
    }

    /// Returns a string value for a specified key.
    /// - Parameters:
    ///   - key: The key to lookup data for.
    ///   - accessibility: Optional accessibility to use when retrieving the keychain item.
    /// - Returns: The String associated with the key if it exists. If no data exists, or the data found cannot be encoded as a string, returns nil.
    open func string(forKey key: String, withAccessibility accessibility: KeychainItemAccessibility? = nil) -> String? {
        guard let keychainData = data(forKey: key, withAccessibility: accessibility) else {
            return nil
        }

        return String(data: keychainData, encoding: String.Encoding.utf8) as String?
    }

    /// Returns an object that conforms to NSCoding for a specified key.
    /// - Parameters:
    ///   - key: The key to lookup data for.
    ///   - accessibility: Optional accessibility to use when retrieving the keychain item.
    /// - Returns: The decoded object associated with the key if it exists. If no data exists, or the data found cannot be decoded, returns nil.
    open func object(
        forKey key: String, withAccessibility accessibility: KeychainItemAccessibility? = nil
    ) -> NSCoding? {
        guard let keychainData = data(forKey: key, withAccessibility: accessibility) else {
            return nil
        }

        return try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(keychainData) as? NSCoding
    }

    /// Returns a Data object for a specified key.
    /// - Parameters:
    ///   - key: The key to lookup data for.
    ///   - accessibility: Optional accessibility to use when retrieving the keychain item.
    /// - Returns: The Data object associated with the key if it exists. If no data exists, returns nil.
    open func data(forKey key: String, withAccessibility accessibility: KeychainItemAccessibility? = nil) -> Data? {
        var keychainQueryDictionary = setupKeychainQueryDictionary(forKey: key, withAccessibility: accessibility)

        // Limit search results to one
        keychainQueryDictionary[SecMatchLimit] = kSecMatchLimitOne

        // Specify we want Data/CFData returned
        keychainQueryDictionary[SecReturnData] = kCFBooleanTrue

        print("OLD KEYCHAIN",keychainQueryDictionary)
        keychainQueryDictionary.forEach {
            print($0.key, String(describing: $0.value))
        }
        // Search
        var result: AnyObject?
        let status = SecItemCopyMatching(keychainQueryDictionary as CFDictionary, &result)

        return status == noErr ? result as? Data : nil
    }

    /// Returns a persistent data reference object for a specified key.
    /// - Parameters:
    ///   - key: The key to lookup data for.
    ///   - accessibility: Optional accessibility to use when retrieving the keychain item.
    /// - Returns: The persistent data reference object associated with the key if it exists. If no data exists, returns nil.
    open func dataRef(forKey key: String, withAccessibility accessibility: KeychainItemAccessibility? = nil) -> Data? {
        var keychainQueryDictionary = setupKeychainQueryDictionary(forKey: key, withAccessibility: accessibility)

        // Limit search results to one
        keychainQueryDictionary[SecMatchLimit] = kSecMatchLimitOne

        // Specify we want persistent Data/CFData reference returned
        keychainQueryDictionary[SecReturnPersistentRef] = kCFBooleanTrue

        // Search
        var result: AnyObject?
        let status = SecItemCopyMatching(keychainQueryDictionary as CFDictionary, &result)

        return status == noErr ? result as? Data : nil
    }

    // MARK: Public Setters

    /// Save an Integer value to the keychain associated with a specified key. If an object already exists for the given key, the object will be overwritten with the new value.
    ///
    /// - parameter value: The Integer value to save.
    /// - parameter forKey: The key to save the Integer under.
    /// - parameter withAccessibility: Optional accessibility to use when setting the keychain item.
    /// - returns: True if the save was successful, false otherwise.
    @discardableResult open func set(
        _ value: Int, forKey key: String, withAccessibility accessibility: KeychainItemAccessibility? = nil
    ) -> Bool {
        return set(NSNumber(value: value), forKey: key, withAccessibility: accessibility)
    }

    /// Save a Float value to the keychain associated with a specified key. If an object already exists for the given key, the object will be overwritten with the new value.
    ///
    /// - parameter value: The Float value to save.
    /// - parameter forKey: The key to save the Float under.
    /// - parameter withAccessibility: Optional accessibility to use when setting the keychain item.
    /// - returns: True if the save was successful, false otherwise.
    @discardableResult open func set(
        _ value: Float, forKey key: String, withAccessibility accessibility: KeychainItemAccessibility? = nil
    ) -> Bool {
        return set(NSNumber(value: value), forKey: key, withAccessibility: accessibility)
    }

    /// Save a Double value to the keychain associated with a specified key. If an object already exists for the given key, the object will be overwritten with the new value.
    ///
    /// - parameter value: The Double value to save.
    /// - parameter forKey: The Double to save the Double under.
    /// - parameter withAccessibility: Optional accessibility to use when setting the keychain item.
    /// - returns: True if the save was successful, false otherwise.
    @discardableResult open func set(
        _ value: Double, forKey key: String, withAccessibility accessibility: KeychainItemAccessibility? = nil
    ) -> Bool {
        return set(NSNumber(value: value), forKey: key, withAccessibility: accessibility)
    }

    /// Save a Bool value to the keychain associated with a specified key. If an object already exists for the given key, the object will be overwritten with the new value.
    ///
    /// - parameter value: The Bool value to save.
    /// - parameter forKey: The key to save the Bool under.
    /// - parameter withAccessibility: Optional accessibility to use when setting the keychain item.
    /// - returns: True if the save was successful, false otherwise.
    @discardableResult open func set(
        _ value: Bool, forKey key: String, withAccessibility accessibility: KeychainItemAccessibility? = nil
    ) -> Bool {
        return set(NSNumber(value: value), forKey: key, withAccessibility: accessibility)
    }

    /// Save a String value to the keychain associated with a specified key. If a String value already exists for the given key, the string will be overwritten with the new value.
    ///
    /// - parameter value: The String value to save.
    /// - parameter forKey: The key to save the String under.
    /// - parameter withAccessibility: Optional accessibility to use when setting the keychain item.
    /// - returns: True if the save was successful, false otherwise.
    @discardableResult open func set(
        _ value: String, forKey key: String, withAccessibility accessibility: KeychainItemAccessibility? = nil
    ) -> Bool {
        if let data = value.data(using: .utf8) {
            return set(data, forKey: key, withAccessibility: accessibility)
        } else {
            return false
        }
    }

    /// Save a NSCoding compliant object to the keychain associated with a specified key. If an object already exists for the given key, the object will be overwritten with the new value.
    ///
    /// - parameter value: The NSCoding compliant object to save.
    /// - parameter forKey: The key to save the object under.
    /// - parameter withAccessibility: Optional accessibility to use when setting the keychain item.
    /// - returns: True if the save was successful, false otherwise.
    @discardableResult open func set(
        _ value: NSCoding, forKey key: String, withAccessibility accessibility: KeychainItemAccessibility? = nil
    ) -> Bool {
        let data = try! NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: false)

        return set(data, forKey: key, withAccessibility: accessibility)
    }

    /// Save a Data object to the keychain associated with a specified key. If data already exists for the given key, the data will be overwritten with the new value.
    ///
    /// - parameter value: The Data object to save.
    /// - parameter forKey: The key to save the object under.
    /// - parameter withAccessibility: Optional accessibility to use when setting the keychain item.
    /// - returns: True if the save was successful, false otherwise.
    @discardableResult open func set(
        _ value: Data, forKey key: String, withAccessibility accessibility: KeychainItemAccessibility? = nil
    ) -> Bool {
        var keychainQueryDictionary: [String:Any] = setupKeychainQueryDictionary(forKey: key, withAccessibility: accessibility)

        keychainQueryDictionary[SecValueData] = value

        if let accessibility = accessibility {
            keychainQueryDictionary[SecAttrAccessible] = accessibility.keychainAttrValue
        } else {
            // Assign default protection - Protect the keychain entry so it's only valid when the device is unlocked
            keychainQueryDictionary[SecAttrAccessible] = KeychainItemAccessibility.whenUnlocked.keychainAttrValue
        }

        let status: OSStatus = SecItemAdd(keychainQueryDictionary as CFDictionary, nil)

        if status == errSecSuccess {
            return true
        } else if status == errSecDuplicateItem {
            return update(value, forKey: key, withAccessibility: accessibility)
        } else {
            return false
        }
    }

    @available(*, deprecated, message: "remove is deprecated, use removeObject instead")
    @discardableResult open func remove(
        key: String, withAccessibility accessibility: KeychainItemAccessibility? = nil
    ) -> Bool {
        return removeObject(forKey: key, withAccessibility: accessibility)
    }

    /// Remove an object associated with a specified key. If re-using a key but with a different accessibility, first remove the previous key value using removeObjectForKey(:withAccessibility) using the same accessibilty it was saved with.
    ///
    /// - parameter forKey: The key value to remove data for.
    /// - parameter withAccessibility: Optional accessibility level to use when looking up the keychain item.
    /// - returns: True if successful, false otherwise.
    @discardableResult open func removeObject(
        forKey key: String, withAccessibility accessibility: KeychainItemAccessibility? = nil
    ) -> Bool {
        let keychainQueryDictionary: [String:Any] = setupKeychainQueryDictionary(forKey: key, withAccessibility: accessibility)

        // Delete
        let status: OSStatus = SecItemDelete(keychainQueryDictionary as CFDictionary)

        if status == errSecSuccess {
            return true
        } else {
            return false
        }
    }

    /// Remove all keychain data added through KeychainWrapper. This will only delete items matching the currnt ServiceName and AccessGroup if one is set.
    /// - Returns: True if successful, false otherwise.
    open func removeAllKeys() -> Bool {
        // Setup dictionary to access keychain and specify we are using a generic password (rather than a certificate, internet password, etc)
        var keychainQueryDictionary: [String:Any] = [SecClass:kSecClassGenericPassword]

        // Uniquely identify this keychain accessor
        keychainQueryDictionary[SecAttrService] = serviceName

        // Set the keychain access group if defined
        if let accessGroup = self.accessGroup {
            keychainQueryDictionary[SecAttrAccessGroup] = accessGroup
        }

        let status: OSStatus = SecItemDelete(keychainQueryDictionary as CFDictionary)

        if status == errSecSuccess {
            return true
        } else {
            return false
        }
    }

    /// Remove all keychain data, including data not added through keychain wrapper.
    ///
    /// - Warning: This may remove custom keychain entries you did not add via SwiftKeychainWrapper.
    ///
    open class func wipeKeychain() {
        deleteKeychainSecClass(kSecClassGenericPassword) // Generic password items
        deleteKeychainSecClass(kSecClassInternetPassword) // Internet password items
        deleteKeychainSecClass(kSecClassCertificate) // Certificate items
        deleteKeychainSecClass(kSecClassKey) // Cryptographic key items
        deleteKeychainSecClass(kSecClassIdentity) // Identity items
    }

    // MARK:- Private Methods

    /// Remove all items for a given Keychain Item Class
    /// - Parameter secClass: AnyObject which is the secClass of the items to be deleted
    /// - Returns: True if successful, false otherwise.
    @discardableResult private class func deleteKeychainSecClass(_ secClass: AnyObject) -> Bool {
        let query = [SecClass: secClass]
        let status: OSStatus = SecItemDelete(query as CFDictionary)

        if status == errSecSuccess {
            return true
        } else {
            return false
        }
    }

    /// Update existing data associated with a specified key name. The existing data will be overwritten by the new data.
    /// - Parameters:
    ///   - value:  The Data object to update
    ///   - key: The key to update the object under
    ///   - accessibility: Optional accessibility to use when setting the keychain item.
    /// - Returns: True if successful, false otherwise.
    private func update(
        _ value: Data, forKey key: String, withAccessibility accessibility: KeychainItemAccessibility? = nil
    ) -> Bool {
        var keychainQueryDictionary: [String:Any] = setupKeychainQueryDictionary(forKey: key, withAccessibility: accessibility)
        let updateDictionary = [SecValueData:value]

        // on update, only set accessibility if passed in
        if let accessibility = accessibility {
            keychainQueryDictionary[SecAttrAccessible] = accessibility.keychainAttrValue
        }

        // Update
        let status: OSStatus = SecItemUpdate(keychainQueryDictionary as CFDictionary, updateDictionary as CFDictionary)

        if status == errSecSuccess {
            return true
        } else {
            return false
        }
    }

    /// Setup the keychain query dictionary used to access the keychain on iOS for a specified key name. Takes into account the Service Name and Access Group if one is set.
    /// - parameter forKey: The key this query is for
    /// - parameter withAccessibility: Optional accessibility to use when setting the keychain item. If none is provided, will default to .WhenUnlocked
    /// - returns: A dictionary with all the needed properties setup to access the keychain on iOS
    private func setupKeychainQueryDictionary(
        forKey key: String, withAccessibility accessibility: KeychainItemAccessibility? = nil
    ) -> [String:Any] {
        // Setup default access as generic password (rather than a certificate, internet password, etc)
        var keychainQueryDictionary: [String:Any] = [SecClass:kSecClassGenericPassword]

        // Uniquely identify this keychain accessor
        keychainQueryDictionary[SecAttrService] = serviceName

        // Only set accessibiilty if its passed in, we don't want to default it here in case the user didn't want it set
        if let accessibility = accessibility {
            keychainQueryDictionary[SecAttrAccessible] = accessibility.keychainAttrValue
        }

        // Set the keychain access group if defined
        if let accessGroup = self.accessGroup {
            keychainQueryDictionary[SecAttrAccessGroup] = accessGroup
        }

//         Uniquely identify the account who will be accessing the keychain
        let encodedIdentifier: Data? = key.data(using: String.Encoding.utf8)

        keychainQueryDictionary[SecAttrGeneric] = encodedIdentifier

        keychainQueryDictionary[SecAttrAccount] = key

        return keychainQueryDictionary
    }
}
