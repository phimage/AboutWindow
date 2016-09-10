

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var aboutWindowController: AboutWindowController!
    
    override init() {
        super.init()
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.aboutWindowController = AboutWindowController()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        self.aboutWindowController = nil
    }
    
    @IBAction func showAboutWindow(_ sender: AnyObject) {
        self.aboutWindowController.appURL = URL(string: "https://github.com/phimage/AboutWindow")!
        self.aboutWindowController.appStoreURL = URL(string: "https://itunes.apple.com/us/app/app-name/id")!
        self.aboutWindowController.appName = "AboutWindow"

        let attribs:[String:AnyObject] = [NSForegroundColorAttributeName: aboutWindowController.textColor, NSFontAttributeName: aboutWindowController.font]
        self.aboutWindowController.appCopyright = NSAttributedString(string: "Copyright (c) 2016 Eric Marchand", attributes: attribs)
        
        self.aboutWindowController.windowShouldHaveShadow = true
        self.aboutWindowController.showWindow(sender)
    }
}

