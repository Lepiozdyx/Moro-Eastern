import UIKit
import SwiftUI
import AppsFlyerLib

extension AppDelegate: AppsFlyerLibDelegate {
    
    public static let appsFlyerDevKey = "BYbL7iQyGkW9x2ZSzbyhh7"
    public static let appleAppID = "6760656764"
    public static var afDataRecieved = false
    public static var fcmToken = ""

    static var subParams: String {
        get { UserDefaults.standard.string(forKey: "subParams") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "subParams") }
    }
    
    static var afid: String {
        get { UserDefaults.standard.string(forKey: "afid") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "afid") }
    }
    
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable: Any]) {
        print("AF ConversionData: \(conversionInfo)")
        if let campaign = conversionInfo["campaign"] as? String {
            print("AF Campaign: \(campaign)")
            let strings = campaign.split(separator: "_")
            if strings.count > 1 {
                var result = ""
                for i in 0..<strings.count {
                    result += "sub\(i + 1)=\(strings[i])&"
                }
                AppDelegate.subParams = String(result.dropLast())
                print("afid: \(AppDelegate.afid)")
                AppDelegate.afDataRecieved = true
                self.applyDecision()
            }
        }
    }
    
    func onConversionDataFail(_ error: any Error) {
        print(error)
    }

    func initAppsFlyer() {
        AppsFlyerLib.shared().appsFlyerDevKey = AppDelegate.appsFlyerDevKey
        AppsFlyerLib.shared().appleAppID = AppDelegate.appleAppID
        AppsFlyerLib.shared().delegate = self
        AppsFlyerLib.shared().deepLinkDelegate = self
        AppsFlyerLib.shared().isDebug = true
        AppsFlyerLib.shared().start(completionHandler: { (dictionary, error) in
            if error != nil {
                print("AF error: \(error!)")
            } else {
                print("AF inited: \(String(describing: dictionary))")
            }
        })
        AppDelegate.afid = AppsFlyerLib.shared().getAppsFlyerUID()
    }
}

extension AppDelegate: DeepLinkDelegate {
    func didResolveDeepLink(_ result: DeepLinkResult) {
        guard result.status == .found, let deepLink = result.deepLink else { return }

        let rawValue = deepLink.deeplinkValue
            ?? deepLink.clickEvent["campaign"] as? String

        guard let value = rawValue else { return }

        let strings = value.split(separator: "_")
        guard strings.count > 1 else { return }

        var params = ""
        for i in 0..<strings.count {
            params += "sub\(i + 1)=\(strings[i])&"
        }
        AppDelegate.subParams = String(params.dropLast())
        AppDelegate.afDataRecieved = true
        self.applyDecision()
    }
}
