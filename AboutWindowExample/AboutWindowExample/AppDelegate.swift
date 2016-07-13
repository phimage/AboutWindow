

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var aboutWindowController: AboutWindowController!
    
    override init() {
        super.init()
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        self.aboutWindowController = AboutWindowController()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
    }
    
    @IBAction func showAboutWindow(sender: AnyObject) {
        self.aboutWindowController.appURL = NSURL(string: "https://github.com/phimage/AboutWindow")!
        self.aboutWindowController.appStoreURL = NSURL(string: "https://itunes.apple.com/us/app/app-name/id")!
        self.aboutWindowController.appName = "AboutWindow"

        let attribs:[String:AnyObject] = [NSForegroundColorAttributeName: aboutWindowController.textColor, NSFontAttributeName: aboutWindowController.font]
        self.aboutWindowController.appCopyright = NSAttributedString(string: "Copyright (c) 2016 Eric Marchand", attributes: attribs)
        
        self.aboutWindowController.windowShouldHaveShadow = true
        self.aboutWindowController.showWindow(sender)
    }
}

