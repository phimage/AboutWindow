//
//  AboutWindowController.swift
//  AboutWindow
/*
 The MIT License (MIT)
 Copyright (c) 2015-2016 Perceval Faramaz
 Copyright (c) 2016 Eric Marchand (phimage)
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

open class AboutWindowController : NSWindowController {

    open var appName: String?
    open var appVersion: String?
    open var appCopyright: NSAttributedString?
    /** The string to hold the credits if we're showing them in same window. */
    open var appCredits: NSAttributedString?
    open var appEULA: NSAttributedString?
    open var appURL: URL?
    open var appStoreURL: URL?

    open var logClosure: (String) -> Void = { message in print(message) }
    
    open var font: NSFont = NSFont(name: "HelveticaNeue", size: 11.0)!
    /** Select a background color (defaults to white). */
    open var backgroundColor: NSColor = NSColor.white
    /** Select the title (app name & version) color (defaults to black). */
    open var titleColor: NSColor = NSColor.black
    /** Select the text (Acknowledgments & EULA) color (defaults to light grey). */
    open var textColor: NSColor = (floor(NSAppKitVersionNumber) <= Double(NSAppKitVersionNumber10_9)) ? NSColor.lightGray : NSColor.tertiaryLabelColor
    open var windowShouldHaveShadow: Bool = true
    open var windowState: Int = 0
    open var amountToIncreaseHeight:CGFloat  = 100

    
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
    
    override open var windowNibName : String! {
        return "PFAboutWindow"
    }

    override open func windowDidLoad() {
        super.windowDidLoad()

        assert (self.window != nil)
        self.window?.backgroundColor = backgroundColor
        self.window?.hasShadow = self.windowShouldHaveShadow
        
        self.windowState = 0

        self.infoView.wantsLayer = true
        self.infoView.layer?.cornerRadius = 10.0
        self.infoView.layer?.backgroundColor = NSColor.white.cgColor
    
        (self.visitWebsiteButton.cell as? NSButtonCell)?.highlightsBy = NSCellStyleMask()
        
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
            if let creditsRTF = Bundle.main.url(forResource: "Credits", withExtension: "rtf"),
                let str = try? NSAttributedString(url: creditsRTF, options: [:], documentAttributes : nil) {
                self.appCredits = str
            }
            else {
                hideButton(self.creditsButton, self.creditsConstraint)
                logClosure("Credits not found in bundle. Hiding Credits Button.")
            }
        }
        
        self.EULAButton.title = NSLocalizedString("License Agreement", comment: "Caption of the 'License Agreement' button in the about window")
        if self.appEULA == nil {
            if let eulaRTF = Bundle.main.url(forResource: "EULA", withExtension: "rtf"),
                let str = try? NSAttributedString(url: eulaRTF, options: [:], documentAttributes: nil) {
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
    
    open func windowShouldClose(_ sender: AnyObject) -> Bool {
        self.showCopyright(sender)
        return true
    }

    // MARK: IBAction
 
    @IBAction open func visitWebsite(_ sender: AnyObject) {
        if let URL = appURL {
            NSWorkspace.shared().open(URL)
        }
    }
    
    @IBAction open func visitAppStore(_ sender: AnyObject) {
        if let URL = appStoreURL {
            NSWorkspace.shared().open(URL)
        }
    }

    @IBAction open func showCredits(_ sender: AnyObject) {
        changeWindowState(1, amountToIncreaseHeight)
        self.textField.textStorage?.setAttributedString(self.appCredits ?? NSAttributedString())
        self.textField.textColor = self.textColor
    }
    
    @IBAction open func showEULA(_ sender: AnyObject) {
        changeWindowState(1, amountToIncreaseHeight)
        self.textField.textStorage?.setAttributedString(self.appEULA ?? NSAttributedString())
        self.textField.textColor = self.textColor
    }
    
    @IBAction open func showCopyright(_ sender: AnyObject) {
        changeWindowState(0, -amountToIncreaseHeight)
        self.textField.textStorage?.setAttributedString(self.appCopyright ?? NSAttributedString())
        self.textField.textColor = self.textColor
    }

    
    // MARK: Private

    fileprivate func valueFromInfoDict(_ string: String) -> String {
        let dictionary = Bundle.main.infoDictionary!
        return dictionary[string] as! String
    }
    
    fileprivate func changeWindowState(_ state: Int,_ amountToIncreaseHeight: CGFloat) {
        if let window = self.window , self.windowState != state {
            var oldFrame = window.frame
            oldFrame.size.height += amountToIncreaseHeight
            oldFrame.origin.y -= amountToIncreaseHeight
            window.setFrame(oldFrame, display: true, animate: true)
            self.windowState = state
        }
    }
    
    fileprivate func hideButton(_ button: NSButton,_ constraint: NSLayoutConstraint) {
        button.isHidden = true
        button.setFrameSize(NSSize(width: 0, height:  self.creditsButton.frame.height))
        button.title = ""
        button.isBordered = false
        constraint.constant = 0
        print("\(button.frame)")
    }
}
