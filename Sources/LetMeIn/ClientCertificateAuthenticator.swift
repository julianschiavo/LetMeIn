//
//  ClientCertificateAuthenticator.swift
//  LetMeIn
//
//  Adapted from https://leenarts.net/2020/02/28/client-certificate-with-urlsession-in-swift/
//

import AVFoundation
import Foundation

/// An object that authenticates server requests using a private client certificate. Implements `AVAssetResourceLoaderDelegate` to work with `AVAsset` and `URLSessionTaskDelegate` to work with `URLSession` requests.
public class ClientCertificateAuthenticator: NSObject, HasLogger, AVAssetResourceLoaderDelegate, URLSessionTaskDelegate {
    
    /// The client certificate file
    private var certificateFile: CertificateFile
    
    /// A serial queue used to process and sign requests
    private let loaderQueue = DispatchQueue(label: String(describing: self))
    
    // MARK: - Init
    
    /// Creates a new authenticator object with a certificate
    /// - Parameter certificateFile: The certificate file to use for authentication
    public init(certificateFile: CertificateFile) {
        self.certificateFile = certificateFile
    }
    
    /// Handles `URLAuthenticationChallenge`s which request a client certificate by minting and using a `URLCredential` containing a client certificate
    /// - Parameters:
    ///   - challenge: A challenge posed by the server
    ///   - completionHandler: Called to handle the challenge or skip if we cannot handle it
    public func handleChallenge(_ challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        loaderQueue.async {
            self.logger.info("Handling Challenge")
            
            guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate,
                  let certificate = self.certificateFile.createCertificate(),
                  let credential = certificate.generateCredential() else {
                completionHandler(.performDefaultHandling, nil)
                return
            }
            
            challenge.sender?.use(credential, for: challenge)
            completionHandler(.useCredential, credential)
            self.logger.info("Handled Challenge Successfully")
        }
    }
    
    // MARK: - AVAssetResourceLoaderDelegate
    
    /// Handles an authentication challenge from an `AVAssetResourceLoader`
    /// - Parameters:
    ///   - resourceLoader: The resource loader posing the challenge
    ///   - authenticationChallenge: The authentication challenge
    /// - Returns: Whether to wait for the challenge to be responded to
    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForResponseTo authenticationChallenge: URLAuthenticationChallenge) -> Bool {
        handleChallenge(authenticationChallenge) { result, credential in
            switch result {
            case .cancelAuthenticationChallenge, .rejectProtectionSpace:
                authenticationChallenge.sender?.cancel(authenticationChallenge)
            case .useCredential:
                guard let credential = credential else { return }
                authenticationChallenge.sender?.use(credential, for: authenticationChallenge)
            case .performDefaultHandling:
                authenticationChallenge.sender?.performDefaultHandling?(for: authenticationChallenge)
            @unknown default:
                authenticationChallenge.sender?.performDefaultHandling?(for: authenticationChallenge)
                self.logger.critical("Unknown Enum Case")
            }
        }
        return true
    }
    
    // MARK: - URLSessionDelegate
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        logger.info("Received Challenge from URLSession")
        handleChallenge(challenge, completionHandler: completionHandler)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        logger.info("Received Challenge from URLSession for task (URL: \(task.currentRequest?.url?.absoluteString ?? ""))")
        handleChallenge(challenge, completionHandler: completionHandler)
    }
}
