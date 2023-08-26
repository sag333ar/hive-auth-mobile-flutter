//
//  HASWebViewController.swift
//  Runner
//
//  Created by Sagar on 26/08/23.
//

import UIKit
import WebKit

class HASWebViewController: UIViewController {
    let hiveauthsigner = "hiveauthsigner"
    let config = WKWebViewConfiguration()
    let rect = CGRect(x: 0, y: 0, width: 10, height: 10)
    var webView: WKWebView?
    var didFinish = false

    override func viewDidLoad() {
        super.viewDidLoad()
        config.userContentController.add(self, name: hiveauthsigner)
        webView = WKWebView(frame: rect, configuration: config)
        webView?.navigationDelegate = self
        //#if DEBUG
        if #available(iOS 16.4, *) {
            self.webView?.isInspectable = true
        }
        //#endif
        guard
            let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "public")
        else { return }
        let dir = url.deletingLastPathComponent()
        webView?.loadFileURL(url, allowingReadAccessTo: dir)
    }
}

extension HASWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        didFinish = true
    }
}

extension HASWebViewController: WKScriptMessageHandler {
    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        guard message.name == ironvest else { return }
        guard let dict = message.body as? [String: AnyObject] else { return }
        guard let type = dict["type"] as? String else { return }
        switch type {
            case "keys":
                debugPrint("Keys")
            default:
                debugPrint("Do nothing")
        }
    }
}
