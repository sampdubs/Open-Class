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
        
//        UserDefaults.standard.set([
//            "https://atlantapublicschools-us.zoom.us/j/9810763587?pwd=OXBmMkU0eTYyK2JockxJZG13d3pyQT09",
//            "https://atlantapublicschools-us.zoom.us/j/83151288446?pwd=OERkRWMxdGM3UmRzQUUyRHFXKzNkZz09",
//            "https://atlantapublicschools-us.zoom.us/j/84717885279?pwd=L0ZtaDAzWXMxN2hqVmZ3QmY5YVlPQT09",
//            "https://atlantapublicschools-us.zoom.us/j/83020266109?pwd=bUh3eit3eG5BYTV5WFFON0xHK0NqZz09",
//            "https://atlantapublicschools-us.zoom.us/j/85152004164?pwd=bElXSVY4b0c1L21zS2xaTWYrNU15dz09"
//        ], forKey: "zoomLinks")
        
//    UserDefaults.standard.set([
//        "SEL - Falcone",
//        "Spanish IV - Ortegon",
//        "AP CSA - Fuller",
//        "Adv. Band - Staton",
//        "AP World History - Looman"
//    ], forKey: "classNames")
    }
    
    

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed (_ theApplication: NSApplication) -> Bool {
        return true
        
    }


}

