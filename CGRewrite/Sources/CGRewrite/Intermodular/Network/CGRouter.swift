//
//  CGRouter.swift
//  
//
//  Created by Yasir on 06/07/23.
//

import Foundation

internal enum HTTPHeaderField: String {
    case contentType = "Content-Type"
    case authorization = "Authorization"
    case xApiKey = "x-api-key"
    case platform = "platform"
    case xGluAuth = "X-GLU-AUTH"
    case cgSDKVersionKey = "cg-sdk-version"
    case sandbox = "sandbox"
}

internal struct CGRequest {
    var urlRequest: URLRequest?
    var maxRetry: Int
}

internal enum CGRouter: Codable {
    case userRegister
    case getWalletRewards
    case sendEvent
    case crashReport
    case entryPointData
    case entryPointsConfig
    case sendAnalyticsEvent
    case appConfig
    case cgDeepLink
    case cgMetricDiagnostics
    case cgNudgeIntegration
    case onboardingSDKNotificationConfig
    case onboardingSDKTestSteps
}

extension CGRouter {
    private var baseURL: String {
        switch self {
        case .userRegister,
                .getWalletRewards,
                .crashReport,
                .entryPointData,
                .entryPointsConfig,
                .appConfig,
                .cgDeepLink,
                .cgNudgeIntegration,
                .onboardingSDKNotificationConfig,
                .onboardingSDKTestSteps:
            return BaseURLs.baseURL
        case .sendEvent:
            return BaseURLs.eventURL
        case .sendAnalyticsEvent:
            return BaseURLs.streamURL
        case .cgMetricDiagnostics:
            return BaseURLs.diagnosticURL
        }
    }
    
    private var path: String {
        switch self {
        case .userRegister:
            return "user/v1/user/sdk?token=true"
        case .getWalletRewards:
            return "reward/v1.1/user"
        case .sendEvent:
            return "server/v4"
        case .crashReport:
            return "api/v1/report"
        case .entryPointData:
            return "entrypoints/v1/list"
        case .entryPointsConfig:
            return "entrypoints/v1/config"
        case .sendAnalyticsEvent:
            return "v4/sdk"
        case .appConfig:
            return "client/v1/sdk/config"
        case .cgDeepLink:
            return "api/v1/wormhole/sdk/url"
        case .cgMetricDiagnostics:
            return "sdk/v4"
        case .cgNudgeIntegration:
            return "integrations/v1/nudge/sdk/test"
        case .onboardingSDKNotificationConfig:
            return "integrations/v1/onboarding/sdk/notification-config"
        case .onboardingSDKTestSteps:
            return "integrations/v1/onboarding/sdk/test-steps"
            
        }
    }
    
    private var httpMethod: HTTPMethod {
        switch self {
        case .userRegister,
                .sendEvent,
                .entryPointsConfig,
                .sendAnalyticsEvent,
                .cgMetricDiagnostics,
                .cgNudgeIntegration,
                .onboardingSDKNotificationConfig,
                .onboardingSDKTestSteps:
            return .post
        case .getWalletRewards, .entryPointData, .appConfig, .cgDeepLink:
            return .get
        case .crashReport:
            return .put
        }
    }
    
    private var httpBody: Data? {
        return nil
    }
    
    var urlRequest: CGRequest {
        guard let safeURL = URL(string: baseURL) else { return .init(urlRequest: nil, maxRetry: 0) }
        
        let url = safeURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.value
        
        #warning("Need to configure few headers in a constant")
        
        request.setValue("application/json", forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
        request.setValue(CustomerGlu.sdkWriteKey, forHTTPHeaderField: HTTPHeaderField.xApiKey.rawValue)
        request.setValue("ios", forHTTPHeaderField: HTTPHeaderField.platform.rawValue)
        request.setValue(CustomerGlu.isDebugingEnabled.description, forHTTPHeaderField: HTTPHeaderField.sandbox.rawValue)
        request.setValue("2.3.10", forHTTPHeaderField: HTTPHeaderField.cgSDKVersionKey.rawValue)
//        switch self {
//        case .sendEvent:
//            request.httpMethod = httpMethod.value
//            request.httpBody = httpBody
//        }
        
        print("Router request is: \(request)")
        return .init(urlRequest: request, maxRetry: 4)
    }
}

