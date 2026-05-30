import Flutter
import UIKit
import YandexLoginSDK

public class YandexoauthPlugin: NSObject, FlutterPlugin {
  private var yandexObserver = MyYandexLoginSDKObserver()

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "yandexoauth", binaryMessenger: registrar.messenger())
    let instance = YandexoauthPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    registrar.addApplicationDelegate(instance)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "start":
      startYandexSdk(result: result)
    case "yandexAuth":
      authorizeWithYandex(result: result)
    case "logoutYandex":
      logoutYandex(result: result)
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "ping":
      let message = call.arguments as? String ?? "pong"
      result("iOS received: \(message)")
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  public func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([Any]?) -> Void
  ) -> Bool {
    return YandexLoginSDK.shared.tryHandleUserActivity(userActivity)
  }

  public func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    return YandexLoginSDK.shared.tryHandleOpenURL(url)
  }

  private func startYandexSdk(result: @escaping FlutterResult) {
    guard let clientID = Bundle.main.object(forInfoDictionaryKey: "YAClientId") as? String,
          !clientID.isEmpty else {
      result(
        FlutterError(
          code: "YANDEX_CLIENT_ID_MISSING",
          message: "YAClientId is missing in Info.plist",
          details: nil
        )
      )
      return
    }

    do {
      try YandexLoginSDK.shared.activate(with: clientID)
      yandexObserver = MyYandexLoginSDKObserver()
      YandexLoginSDK.shared.add(observer: yandexObserver)
      result(true)
    } catch {
      result(
        FlutterError(
          code: "YANDEX_INIT_ERROR",
          message: "Failed to activate YandexLoginSDK",
          details: String(describing: error)
        )
      )
    }
  }

  private func authorizeWithYandex(result: @escaping FlutterResult) {
    guard let rootViewController = topViewController() else {
      result(
        FlutterError(
          code: "YANDEX_VIEW_CONTROLLER_MISSING",
          message: "Unable to resolve root view controller for Yandex auth",
          details: nil
        )
      )
      return
    }

    yandexObserver.setResult(result: result)

    do {
      try YandexLoginSDK.shared.authorize(with: rootViewController)
    } catch {
      result(
        FlutterError(
          code: "YANDEX_AUTHORIZE_ERROR",
          message: "Failed to start Yandex authorization",
          details: String(describing: error)
        )
      )
    }
  }

  private func logoutYandex(result: @escaping FlutterResult) {
    do {
      try YandexLoginSDK.shared.logout()
      if let clientID = Bundle.main.object(forInfoDictionaryKey: "YAClientId") as? String,
         !clientID.isEmpty {
        try YandexLoginSDK.shared.logout(with: clientID)
      }
      result([
        "success": true,
        "provider": "yandex"
      ])
    } catch {
      result(
        FlutterError(
          code: "YANDEX_LOGOUT_ERROR",
          message: "Failed to logout from Yandex",
          details: String(describing: error)
        )
      )
    }
  }

  private func topViewController(
    base: UIViewController? = UIApplication.shared
      .connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap(\.windows)
      .first(where: \.isKeyWindow)?
      .rootViewController
  ) -> UIViewController? {
    if let navigationController = base as? UINavigationController {
      return topViewController(base: navigationController.visibleViewController)
    }

    if let tabBarController = base as? UITabBarController,
       let selected = tabBarController.selectedViewController {
      return topViewController(base: selected)
    }

    if let presented = base?.presentedViewController {
      return topViewController(base: presented)
    }

    return base
  }
}

final class MyYandexLoginSDKObserver: NSObject, YandexLoginSDKObserver {
  private var resultFlutter: FlutterResult?

  func setResult(result: @escaping FlutterResult) {
    resultFlutter = result
  }

  func didFinishLogin(with result: Result<LoginResult, any Error>) {
    guard let resultFlutter else { return }

    switch result {
    case .success(let loginResult):
      resultFlutter([
        "success": true,
        "token": loginResult.token,
        "jwt": loginResult.jwt
      ])
    case .failure(let error):
      resultFlutter(
        FlutterError(
          code: "YANDEX_LOGIN_FAILED",
          message: "Yandex login failed",
          details: String(describing: error)
        )
      )
    }

    self.resultFlutter = nil
  }
}
