import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    var hasWebView: HASWebViewController?
    let hasBridge = HASBridge()

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        hasWebView = UIStoryboard(
            name: "Main",
            bundle: nil
        ).instantiateViewController(withIdentifier: "HASWebViewController") as? HASWebViewController

        hasWebView?.viewDidLoad()
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        if let window = window, let hasWebView = hasWebView {
            hasBridge.initiate(controller: controller, window: window, hasWeb: hasWebView)
        }

        GeneratedPluginRegistrant.register(with: self)

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
