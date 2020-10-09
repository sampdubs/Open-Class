//
//  ContentView.swift
//  Open Class
//
//  Created by Sam Prausnitz-Weinbaum on 8/26/20.
//  Copyright © 2020 Sam Prausnitz-Weinbaum. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    private let classTimes = [
        Calendar.current.date(bySettingHour: 8, minute: 30, second: 0, of: Date())!,
        Calendar.current.date(bySettingHour: 8, minute: 50, second: 0, of: Date())!,
        Calendar.current.date(bySettingHour: 10, minute: 15, second: 0, of: Date())!,
        Calendar.current.date(bySettingHour: 12, minute: 10, second: 0, of: Date())!,
        Calendar.current.date(bySettingHour: 13, minute: 35, second: 0, of: Date())!
    ]
    
    @State private var showSheet = false
    @State private var openIndex = 0
    
    private func timeDiff(_ now: Date, _ target: Date) -> Int {
        
        return Calendar.current.dateComponents(
            [.second], from: now,
            to: target
        ).second!
        
    }
    
    private func getLink(_ i: Int) -> URL {
        let str = (UserDefaults.standard.array(forKey: "zoomLinks") ?? Array(repeating: "https://large-type.com/#You%20have%20not%20set%20up%20this%20zoom%20link%20yet", count: 5))[i] as? String
        return URL(string: str ?? "") ?? URL(string: "https://large-type.com/#You%20have%20not%20set%20up%20this%20zoom%20link%20yet")!
    }
    
    private func getClass(_ i: Int) -> String {
        let str = (UserDefaults.standard.array(forKey: "classNames") ?? Array(repeating: "Class name not set", count: 5))[i] as? String
        return str ?? "Class name not set"
    }
    
    var body: some View {
        VStack {
            HStack{
                Button(action: {
                    self.showSheet = true
                }) {
                    Text("Settings")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                Spacer()
            }
            Spacer()
            Text(self.getClass(self.openIndex))
            Text("\(Calendar.current.component(.hour, from: self.classTimes[self.openIndex])):\(Calendar.current.component(.minute, from: self.classTimes[self.openIndex]))")
            Button(action: {
                NSWorkspace.shared.open(self.getLink(self.openIndex))
            }) {
                Text("Open")
            }
            Spacer()
            
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear{
            if (UserDefaults.standard.object(forKey: "zoomLinks") == nil) {
                UserDefaults.standard.set(Array(repeating: "https://large-type.com/#You%20have%20not%20set%20up%20this%20zoom%20link%20yet", count: 5), forKey: "zoomLinks")
            }
            if (UserDefaults.standard.object(forKey: "classNames") == nil) {
                UserDefaults.standard.set(Array(repeating: "Class name not set", count: 5), forKey: "classNames")
            }
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
        .sheet(isPresented: self.$showSheet) {
            Settings(showSheet: self.$showSheet)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
