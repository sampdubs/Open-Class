//
//  AppDelegate.swift
//  Open Class
//
//  Created by Sam Prausnitz-Weinbaum on 8/26/20.
//  Copyright © 2020 Sam Prausnitz-Weinbaum. All rights reserved.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        
        let contentView = ContentView()
//        let contentView = Settings()

        // Create the window and set the content view. 
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
        
        if (UserDefaults.standard.object(forKey: "zoomLinks") == nil) {
            UserDefaults.standard.set(Array(repeating: "https://large-type.com/#You%20have%20not%20set%20up%20this%20zoom%20link%20yet", count: 5), forKey: "zoomLinks")
        }
        if (UserDefaults.standard.object(forKey: "classNames") == nil) {
            UserDefaults.standard.set(Array(repeating: "Class name not set", count: 5), forKey: "classNames")
        }
        if (UserDefaults.standard.object(forKey: "classTimes") == nil) {
            UserDefaults.standard.set(["8:30", "8:50", "10:15", "12:10", "13:35"], forKey: "classTimes")
        }
    }
    
    

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed (_ theApplication: NSApplication) -> Bool {
        return true
        
    }


}

