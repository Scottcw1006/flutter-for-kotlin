import CryptoKit
import Foundation
import UIKit

// [snippet:pigeon-api]
// 實作 Pigeon 產生的 protocol；方法簽章寫錯會直接編譯失敗
final class DeviceApiImpl: DeviceApi {
    func getDeviceInfo() throws -> DeviceInfo {
        let device = UIDevice.current
        return DeviceInfo(
            manufacturer: "Apple",
            model: device.model,
            sdkInt: Int64(device.systemVersion.split(separator: ".").first ?? "0") ?? 0
        )
    }

    // @async 方法產生成 async 函式，相當於 Kotlin 的 suspend fun
    func sha256(text: String) async throws -> String {
        SHA256.hash(data: Data(text.utf8))
            .map { String(format: "%02x", $0) }
            .joined()
    }
}
// [/snippet]
