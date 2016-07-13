//
//  AboutWindowController.swift
//  AboutWindow
/*
 The MIT License (MIT)
 Copyright (c) 2015 Eric Marchand (phimage)
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */
import Cocoa

public class AboutWindowController : NSWindowController {

    public var appName: String?
    public var appVersion: String?
    public var appCopyright: NSAttributedString?
    /** The string to hold the credits if we're showing them in same window. */
    public var appCredits: NSAttributedString?
    public var appEULA: NSAttributedString?
    public var appURL: NSURL?
    public var appStoreURL: NSURL?

    public var logClosure: (String) -> Void = { message in print(message) }
    
    public var font: NSFont = NSFont(name: "HelveticaNeue", size: 11.0)!
    /** Select a background color (defaults to white). */
    public var backgroundColor: NSColor = NSColor.whiteColor()
    /** Select the title (app name & version) color (defaults to black). */
    public var titleColor: NSColor = NSColor.blackColor()
    /** Select the text (Acknowledgments & EULA) color (defaults to light grey). */
    public var textColor: NSColor = (floor(NSAppKitVersionNumber) <= Double(NSAppKitVersionNumber10_9)) ? NSColor.lightGrayColor() : NSColor.tertiaryLabelColor()
    public var windowShouldHaveShadow: Bool = true
    public var windowState: Int = 0
    public var amountToIncreaseHeight:CGFloat  = 100

    
    /** The info view. */
    @IBOutlet var infoView: NSView!
    /** The main text view. */
    @IBOutlet var textField: NSTextView!
    /** The app version's text view. */
    @IBOutlet var versionField: NSTextField!

    /** The button that opens the app's website. */
    @IBOutlet var visitWebsiteButton: NSButton!
    /** The button that opens the EULA. */
    @IBOutlet var EULAButton: NSButton!
    /** The button that opens the credits. */
    @IBOutlet var creditsButton: NSButton!
    /** The button that opens the appstore's website. */
    @IBOutlet var ratingButton: NSButton!
    
    @IBOutlet var EULAConstraint: NSLayoutConstraint!
    @IBOutlet var creditsConstraint: NSLayoutConstraint!
    @IBOutlet var ratingConstraint: NSLayoutConstraint!


    // MARK: override
    
    override public var windowNibName : String! {
        return "PFAboutWindow"
    }

    override public func windowDidLoad() {
        super.windowDidLoad()

        assert (self.window != nil)
        self.window?.backgroundColor = backgroundColor
        self.window?.hasShadow = self.windowShouldHaveShadow
        
        self.windowState = 0

        self.infoView.wantsLayer = true
        self.infoView.layer?.cornerRadius = 10.0
        self.infoView.layer?.backgroundColor = NSColor.whiteColor().CGColor
    
        (self.visitWebsiteButton.cell as? NSButtonCell)?.highlightsBy = NSCellStyleMask.NoCellMask
        
        if self.appName == nil {
            self.appName = valueFromInfoDict("CFBundleName")
        }
        
        if self.appVersion == nil {
            let version = valueFromInfoDict("CFBundleVersion")
            let shortVersion = valueFromInfoDict("CFBundleShortVersionString")
            self.appVersion = String(format: NSLocalizedString("Version %@ (Build %@)", comment:"Version %@ (Build %@), displayed in the about window"), shortVersion, version)
        }
        versionField.stringValue = self.appVersion ?? ""
        versionField.textColor = self.titleColor
        
        if self.appCopyright == nil {
          
            let attribs: [String:AnyObject] = [NSForegroundColorAttributeName: textColor, NSFontAttributeName: font]
            self.appCopyright = NSAttributedString(string: valueFromInfoDict("NSHumanReadableCopyright"), attributes:attribs)
        }
        if let copyright = self.appCopyright {
            self.textField.textStorage?.setAttributedString(copyright)
            self.textField.textColor = self.textColor
        }

        self.creditsButton.title = NSLocalizedString("Credits", comment: "Caption of the 'Credits' button in the about window")
        if self.appCredits == nil {
            if let creditsRTF = NSBundle.mainBundle().URLForResource("Credits", withExtension: "rtf"),
                str = try? NSAttributedString(URL: creditsRTF, options: [:], documentAttributes : nil) {
                self.appCredits = str
            }
            else {
                hideButton(self.creditsButton, self.creditsConstraint)
                logClosure("Credits not found in bundle. Hiding Credits Button.")
            }
        }
        
        self.EULAButton.title = NSLocalizedString("License Agreement", comment: "Caption of the 'License Agreement' button in the about window")
        if self.appEULA == nil {
            if let eulaRTF = NSBundle.mainBundle().URLForResource("EULA", withExtension: "rtf"),
                str = try? NSAttributedString(URL: eulaRTF, options: [:], documentAttributes: nil) {
                self.appEULA = str
            }
            else {
                hideButton(self.EULAButton, self.EULAConstraint)
                logClosure("EULA not found in bundle. Hiding EULA Button.")
            }
        }
        
        self.ratingButton.title = NSLocalizedString("★Rate on the app store", comment: "Caption of the 'Rate on the app store'")
        if appStoreURL == nil {
            hideButton(self.ratingButton, self.ratingConstraint)
        }
    }
    
    // MARK: IBAction
 
    @IBAction func visitWebsite(sender: AnyObject) {
        if let URL = appURL {
            NSWorkspace.sharedWorkspace().openURL(URL)
        }
    }
    
    @IBAction func visitAppStore(sender: AnyObject) {
        if let URL = appStoreURL {
            NSWorkspace.sharedWorkspace().openURL(URL)
        }
    }

    @IBAction func showCredits(sender: AnyObject) {
        changeWindowState(1, amountToIncreaseHeight)
        self.textField.textStorage?.setAttributedString(self.appCredits ?? NSAttributedString())
        self.textField.textColor = self.textColor
    }
    
    @IBAction func showEULA(sender: AnyObject) {
        changeWindowState(1, amountToIncreaseHeight)
        self.textField.textStorage?.setAttributedString(self.appEULA ?? NSAttributedString())
        self.textField.textColor = self.textColor
    }
    
    @IBAction func showCopyright(sender: AnyObject) {
        changeWindowState(0, -amountToIncreaseHeight)
        self.textField.textStorage?.setAttributedString(self.appCopyright ?? NSAttributedString())
        self.textField.textColor = self.textColor
    }
    
    public func windowShouldClose(sender: AnyObject) -> Bool {
        self.showCopyright(sender)
        return true
    }
    
    // MARK: Private

    private func valueFromInfoDict(string: String) -> String {
        let dictionary = NSBundle.mainBundle().infoDictionary!
        return dictionary[string] as! String
    }
    
    private func changeWindowState(state: Int,_ amountToIncreaseHeight: CGFloat) {
        if let window = self.window where self.windowState != state {
            var oldFrame = window.frame
            oldFrame.size.height += amountToIncreaseHeight
            oldFrame.origin.y -= amountToIncreaseHeight
            window.setFrame(oldFrame, display: true, animate: true)
            self.windowState = state
        }
    }
    
    private func hideButton(button: NSButton,_ constraint: NSLayoutConstraint) {
        button.hidden = true
        button.setFrameSize(NSSize(width: 0, height:  self.creditsButton.frame.height))
        button.title = ""
        button.bordered = false
        constraint.constant = 0
        print("\(button.frame)")
    }
}
