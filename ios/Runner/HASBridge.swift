//
//  HASBridge.swift
//  Runner
//
//  Created by Sagar on 26/08/23.
//

import UIKit
import Flutter

class HASBridge {
    var window: UIWindow?
    var hasWeb: HASWebViewController?

    func initiate(
        controller: FlutterViewController,
        window: UIWindow,
        hasWeb: HASWebViewController
    ) {
        self.window = window
        self.hasWeb = hasWeb

        let bridgeChannel = FlutterMethodChannel(
            name: "com.hiveauth.hiveauthsigner/bridge",
            binaryMessenger: controller.binaryMessenger
        )

        bridgeChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            switch (call.method) {
                case "getProofOfKey":
                    guard
                        let arguments = call.arguments as? NSDictionary,
                        let privateKey = arguments ["privateKey"] as? String,
                        let publicKey = arguments ["publicKey"] as? String,
                        let memo = arguments ["memo"] as? String
                    else {
                        result(FlutterMethodNotImplemented)
                        return
                    }
                    self?.getProofOfKey(privateKey: privateKey, publicKey: publicKey, memo: memo, result: result)
                case "validateHiveKey":
                    guard
                        let arguments = call.arguments as? NSDictionary,
                        let accountName = arguments ["accountName"] as? String,
                        let userKey = arguments ["userKey"] as? String
                    else {
                        result(FlutterMethodNotImplemented)
                        return
                    }
                self?.validateHiveKey(accountName: accountName, userKey: userKey, result: result)
                default:
                    debugPrint("do nothing")
            }
        })
    }

    private func getProofOfKey(
        privateKey: String,
        publicKey: String,
        memo: String,
        result: @escaping FlutterResult
    ) {
        guard let hasWeb = hasWeb else {
            result(FlutterError(code: "ERROR", message: "Error setting up HASBridge", details: nil))
            return
        }
        hasWeb.getProofOfKey(privateKey: privateKey, publicKey: publicKey, memo: memo) { response in
            result(response)
        }
    }

    private func validateHiveKey(
        accountName: String,
        userKey: String,
        result: @escaping FlutterResult
    ) {
        guard let hasWeb = hasWeb else {
            result(FlutterError(code: "ERROR", message: "Error setting up HASBridge", details: nil))
            return
        }
        hasWeb.validateHiveKey(accountName: accountName, userKey: userKey) { response in
            result(response)
        }
    }
}
