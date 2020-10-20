//
//  Certificate.swift
//  LetMeIn
//

import Foundation

/// A representation of a client certificate
protocol Certificate {
    var identity: SecIdentity? { get }
    
    /// Creates a certificate from a file's data
    /// - Parameters:
    ///   - data: The data
    ///   - password: The certificate's password, used to read the certificate
    init?(data: Data, password: String)
    
    /// Creates a `URLCredential` object for the client certificate
    /// - Returns: The credential
    func generateCredential() -> URLCredential?
}
