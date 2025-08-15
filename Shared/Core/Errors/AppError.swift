//
//  AppError.swift
//  TeaElephant
//
//  Created for comprehensive error handling across the app
//

import Foundation

enum AppError: LocalizedError {
    case networkError(String)
    case authenticationFailed
    case authenticationRequired
    case tokenExpired
    case dataCorrupted
    case collectionNotFound
    case teaNotFound
    case invalidQRCode
    case invalidNFCTag
    case arSessionFailed(String)
    case cacheError(String)
    case graphQLErrors([Error])
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network error: \(message)"
        case .authenticationFailed:
            return "Authentication failed. Please sign in again."
        case .authenticationRequired:
            return "Authentication required. Please sign in to continue."
        case .tokenExpired:
            return "Your session has expired. Please sign in again."
        case .dataCorrupted:
            return "Data corruption detected. Please refresh and try again."
        case .collectionNotFound:
            return "Collection not found. It may have been deleted."
        case .teaNotFound:
            return "Tea not found in the database."
        case .invalidQRCode:
            return "Invalid QR code. Please scan a valid tea QR code."
        case .invalidNFCTag:
            return "Invalid NFC tag. Please use a valid tea tag."
        case .arSessionFailed(let reason):
            return "AR session failed: \(reason)"
        case .cacheError(let message):
            return "Cache error: \(message)"
        case .graphQLErrors(let errors):
            let messages = errors.map { $0.localizedDescription }.joined(separator: ", ")
            return "Server errors: \(messages)"
        case .unknown(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .networkError:
            return "Please check your internet connection and try again."
        case .authenticationFailed, .authenticationRequired, .tokenExpired:
            return "Tap to sign in with your Apple ID."
        case .dataCorrupted:
            return "Pull to refresh the data."
        case .collectionNotFound, .teaNotFound:
            return "Go back and refresh the list."
        case .invalidQRCode, .invalidNFCTag:
            return "Make sure you're scanning a valid TeaElephant tag."
        case .arSessionFailed:
            return "Make sure your device supports AR and camera permissions are granted."
        case .cacheError:
            return "Try clearing the app cache in settings."
        case .graphQLErrors:
            return "Please try again. If the problem persists, contact support."
        case .unknown:
            return "Please try again or restart the app."
        }
    }
    
    var isRetryable: Bool {
        switch self {
        case .networkError, .tokenExpired, .cacheError:
            return true
        case .authenticationFailed, .authenticationRequired:
            return false
        case .dataCorrupted, .collectionNotFound, .teaNotFound:
            return true
        case .invalidQRCode, .invalidNFCTag:
            return false
        case .arSessionFailed:
            return true
        case .graphQLErrors, .unknown:
            return true
        }
    }
}

extension AppError {
    static func from(_ error: Error) -> AppError {
        if let appError = error as? AppError {
            return appError
        }
        
        let nsError = error as NSError
        
        switch nsError.domain {
        case NSURLErrorDomain:
            switch nsError.code {
            case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost:
                return .networkError("No internet connection")
            case NSURLErrorTimedOut:
                return .networkError("Request timed out")
            default:
                return .networkError(error.localizedDescription)
            }
        default:
            return .unknown(error)
        }
    }
}