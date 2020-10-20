//
//  PKCS12Certificate.swift
//  LetMeIn
//
//  Adapted from https://leenarts.net/2020/02/28/client-certificate-with-urlsession-in-swift/
//

import Foundation

/// A representation of a PKCS12 Client Certificate
class PKCS12Certificate: Certificate, HasLogger {
    let label: String?
    let keyID: NSData?
    let trust: SecTrust?
    let certChain: [SecTrust]?
    let identity: SecIdentity?
    
    /// Creates a PKCS12 representation from a certificate file's data.
    /// - Parameters:
    ///   - data: The certificate's data
    ///   - password: The password required to unlock the data.
    required public init?(data: Data, password: String) {
        let importPasswordOption: NSDictionary = [kSecImportExportPassphrase as NSString: password]
        var wrappedItems: CFArray?
        let secError = SecPKCS12Import(data as NSData, importPasswordOption, &wrappedItems)
        guard secError == errSecSuccess, let items = wrappedItems else {
            return nil
        }
        
        let itemsNSArray = items as NSArray
        guard let dictionaryArray = itemsNSArray as? [[String: AnyObject]] else {
            return nil
        }
        
        func valueForKey<T>(_ key: CFString) -> T? {
            let keyString = key as String
            for dictionary in dictionaryArray {
                guard let value = dictionary[keyString] as? T else { continue }
                return value
            }
            return nil
        }
        
        self.label = valueForKey(kSecImportItemLabel)
        self.keyID = valueForKey(kSecImportItemKeyID)
        self.trust = valueForKey(kSecImportItemTrust)
        self.certChain = valueForKey(kSecImportItemCertChain)
        self.identity = valueForKey(kSecImportItemIdentity)
    }
    
    /// Creates a `URLCredential` object for the client certificate
    /// - Returns: The credential
    func generateCredential() -> URLCredential? {
        guard let identity = identity else {
            logger.error("Failed to Generate Credential due to Missing Identity")
            return nil
        }
        
        logger.info("Generated Credential")
        return URLCredential(identity: identity, certificates: nil, persistence: .forSession)
    }
}
