//
//  CertificateType.swift
//  LetMeIn
//

import Foundation

/// A type of certificate
public enum CertificateType {
    case pkcs12
    
    /// The object type for the certificate
    var representationType: Certificate.Type {
        switch self {
        case .pkcs12:
            return PKCS12Certificate.self
        }
    }
}
