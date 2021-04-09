//
//  ContentView.swift
//  Open Class - iOS
//
//  Created by Sam Prausnitz-Weinbaum on 9/2/20.
//  Copyright © 2020 Sam Prausnitz-Weinbaum. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @State private var classTimes: [Date] = []
    
    @State private var showAlert = false
    @State private var openIndex = 0
    @State var update = false
    
    private func timeDiff(_ now: Date, _ target: Date) -> Int {
        
        return Calendar.current.dateComponents(
            [.second], from: now,
            to: target
        ).second!
        
    }
    
    private func getLink(_ i: Int) -> URL {
        let str = (UserDefaults.standard.array(forKey: "zoomLinks") ?? Array(repeating: "https://large-type.com/#You%20have%20not%20set%20up%20this%20zoom%20link%20yet", count: 5))[i] as? String
        return URL(string: str?.replacingOccurrences(of: " ", with: "") ?? "") ?? URL(string: "https://large-type.com/#You%20have%20not%20set%20up%20this%20zoom%20link%20yet")!
    }
    
    private func getClass(_ i: Int) -> String {
        let str = (UserDefaults.standard.array(forKey: "classNames") ?? Array(repeating: "Class name not set", count: 5))[i] as? String
        return str ?? "Class name not set"
    }
    
    private func setupClassTimes(_ times: [String]) {
        self.classTimes = []
        for t in times {
            let time = t.components(separatedBy: ":")
            self.classTimes.append(Calendar.current.date(bySettingHour: Int(time[0]) ?? 0, minute: Int(time[1]) ?? 0, second: 0, of: Date())!)
        }
    }
    
    public func setup() {
        if (UserDefaults.standard.object(forKey: "zoomLinks") == nil) {
            UserDefaults.standard.set(Array(repeating: "https://large-type.com/#You%20have%20not%20set%20up%20this%20zoom%20link%20yet", count: 5), forKey: "zoomLinks")
        }
        if (UserDefaults.standard.object(forKey: "classNames") == nil) {
            UserDefaults.standard.set(Array(repeating: "Class name not set", count: 5), forKey: "classNames")
        }
        if (UserDefaults.standard.object(forKey: "classTimes") == nil) {
            UserDefaults.standard.set(["8:30", "8:50", "10:15", "12:10", "13:35"], forKey: "classTimes")
        }
        setupClassTimes((UserDefaults.standard.array(forKey: "classTimes") ?? ["8:30", "8:50", "10:15", "12:10", "13:35"]) as? [String] ?? ["8:30", "8:50", "10:15", "12:10", "13:35"])
        let now = Date()
        var winner = self.classTimes[0]
        var winnerIndex = 0
        var winnerMargin = abs(self.timeDiff(now, winner))
        for i in 0..<self.classTimes.count {
            if abs(self.timeDiff(now, self.classTimes[i])) < winnerMargin {
                winner = self.classTimes[i]
                winnerIndex = i
                winnerMargin = abs(self.timeDiff(now, self.classTimes[i]))
            }
        }
        self.openIndex = winnerIndex
    }
    
    var body: some View {
        NavigationView {
            VStack {
            if (self.openIndex < self.classTimes.count) {
                Text(self.getClass(self.openIndex))
                Text("\(Calendar.current.component(.hour, from: self.classTimes[self.openIndex])):\(Calendar.current.component(.minute, from: self.classTimes[self.openIndex]))")
                Button(action: {
                    let link = self.getLink(self.openIndex)
                    if (UIApplication.shared.canOpenURL(link)) {
                        UIApplication.shared.open(link)
                    } else {
                        self.showAlert = true;
                    }
                }) {
                    Text("Open")
                }
            } 
                Text(update ? " " : "  ")
                    .hidden()
                
            }
            .padding()
            .navigationBarItems(leading: NavigationLink(destination: Settings(update: self.$update, classTimes: self.$classTimes, hideSheet: self.setup)) {
                Text("Settings")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            })
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .alert(isPresented: self.$showAlert) {
                    Alert(title: Text("Invalid URL"), message: Text("Make sure that the link to the class zoom has https:// at the beginning"), dismissButton: .default(Text("Okay")))
            }
            .onAppear(perform: self.setup)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
