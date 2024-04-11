//
//  KeychainItemAccessibility.swift
//
//
//  Created by Andrej Jasso on 10/04/2024.
//

import Foundation

protocol KeychainAttrRepresentable {
    var keychainAttrValue: CFString { get }
}

// MARK: - KeychainItemAccessibility

/// Represents level of accessibility for data stored in the keychain.
public enum KeychainItemAccessibility {

    case always
    /**
     The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user.

     After the first unlock, the data remains accessible until the next restart. This is recommended for items that need to be accessed by background applications. Items with this attribute migrate to a new device when using encrypted backups.
     */
    @available(iOS 4, *)
    case afterFirstUnlock

    /**
     The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user.

     After the first unlock, the data remains accessible until the next restart. This is recommended for items that need to be accessed by background applications. Items with this attribute do not migrate to a new device. Thus, after restoring from a backup of a different device, these items will not be present.
     */
    @available(iOS 4, *)
    case afterFirstUnlockThisDeviceOnly

    /**
     The data in the keychain can only be accessed when the device is unlocked. Only available if a passcode is set on the device.

     This is recommended for items that only need to be accessible while the application is in the foreground. Items with this attribute never migrate to a new device. After a backup is restored to a new device, these items are missing. No items can be stored in this class on devices without a passcode. Disabling the device passcode causes all items in this class to be deleted.
     */
    @available(iOS 8, *)
    case whenPasscodeSetThisDeviceOnly

    /**
     The data in the keychain item can be accessed only while the device is unlocked by the user.

     This is recommended for items that need to be accessible only while the application is in the foreground. Items with this attribute migrate to a new device when using encrypted backups.

     This is the default value for keychain items added without explicitly setting an accessibility constant.
     */
    @available(iOS 4, *)
    case whenUnlocked

    /**
     The data in the keychain item can be accessed only while the device is unlocked by the user.

     This is recommended for items that need to be accessible only while the application is in the foreground. Items with this attribute do not migrate to a new device. Thus, after restoring from a backup of a different device, these items will not be present.
     */
    @available(iOS 4, *)
    case whenUnlockedThisDeviceOnly

    /// Returns the KeychainItemAccessibility for the given keychain attribute value.
    ///
    /// - Parameter keychainAttrValue: The keychain attribute value for which to return the corresponding KeychainItemAccessibility.
    /// - Returns: The KeychainItemAccessibility for the given attribute value, or nil if no match is found.
    static func accessibilityForAttributeValue(_ keychainAttrValue: CFString) -> KeychainItemAccessibility? {
        for (key, value) in keychainItemAccessibilityLookup {
            if value == keychainAttrValue {
                return key
            }
        }

        return nil
    }
}

private let keychainItemAccessibilityLookup: [KeychainItemAccessibility:CFString] = {
    var lookup: [KeychainItemAccessibility:CFString] = [
        .afterFirstUnlock: kSecAttrAccessibleAfterFirstUnlock,
        .afterFirstUnlockThisDeviceOnly: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
        .whenUnlocked: kSecAttrAccessibleWhenUnlocked,
        .whenUnlockedThisDeviceOnly: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
        .always: kSecAttrAccessibleAlways
    ]

    return lookup
}()

extension KeychainItemAccessibility : KeychainAttrRepresentable {

    internal var keychainAttrValue: CFString {
        return keychainItemAccessibilityLookup[self]!
    }

}
