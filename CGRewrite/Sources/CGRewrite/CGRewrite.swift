import Foundation

public struct CGRewrite {
    public private(set) var text = "Hello, World!"

    public init() {
    }
}

public class CustomerGlu {
    internal static var sdkWriteKey: String = Bundle.main.object(forInfoDictionaryKey: "CUSTOMERGLU_WRITE_KEY") as? String ?? ""
    @objc public static var isDebugingEnabled = false
}
