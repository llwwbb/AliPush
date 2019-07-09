import CloudPushSDK
import UserNotifications

extension AppDelegate {
    
    override open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        print("llllllllllllllll")
        self.viewController = MainViewController()
        CloudPushSDK.sendNotificationAck(launchOptions);
        if(launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] != nil){
            let userInfo = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as! [AnyHashable : Any];
            let aps = userInfo["aps"] as! [AnyHashable : Any];
            let alert = aps["alert"] as! [AnyHashable: Any];
            let title = alert["title"] as! String;
            let body = alert["body"] as! String;
            AliPushPlugin.fireNotificationEvent(object: ["eventType":"openNotification", "title": title, "content": body, "extras": userInfo]);
        }
        // 初始化阿里云推送SDK
        self.initCloudPushSDK();
        return super.application(application,didFinishLaunchingWithOptions:launchOptions);
    }
    
    // 初始化推送SDK
    func initCloudPushSDK() {
        // 打开Log，线上建议关闭
        //        CloudPushSDK.turnOnDebug()
        var appkey = ""
        var appSecret = ""
        #if DEBUG
        appkey = "27664687"
         appSecret = "f0d42204285f53b39ccb9f449aeefb87"
        #else
        appkey = "27696256"
        appSecret = "a032273c15a26e774f618f76e79450a5"
        #endif
        CloudPushSDK.asyncInit(appkey, appSecret: appSecret, callback: {res in
            if(res!.success){
    
            }else{
        
            }
        })
    }
    
    open override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
 
//        print("++++++\(deviceToken)")
//        NSString *deviceTokenSt = [[[[deviceToken description]
//            stringByReplacingOccurrencesOfString:@"<" withString:@""]
//            stringByReplacingOccurrencesOfString:@">" withString:@""]
//            stringByReplacingOccurrencesOfString:@" " withString:@""];
        CloudPushSDK.registerDevice(deviceToken) {res in
            if (res!.success) {
                print("Upload deviceToken to Push Server, deviceToken: \(CloudPushSDK.getApnsDeviceToken()!), deviceId: \(CloudPushSDK.getDeviceId()!)")
            } else {
                print("Upload deviceToken to Push Server failed, error: \(String(describing: res?.error))")
            }
        }
    }
    
    override open func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("register for remote notifications error", error);
    }
    
    override open func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("Receive one notification.")
        let aps = userInfo["aps"] as! [AnyHashable : Any];
        let alert = aps["alert"] as! [AnyHashable: Any];
        let title = alert["title"] as! String;
        let body = alert["body"] as! String;
        AliPushPlugin.fireNotificationEvent(object: ["eventType":"receiveNotification", "title": title, "content": body, "extras": userInfo]);
        CloudPushSDK.sendNotificationAck(userInfo)
        print("Notification, title: \(title), body: \(body).");
    }
}
