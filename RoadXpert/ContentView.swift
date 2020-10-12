//
//  ContentView.swift
//  RoadXpert
//
//  Created by Chelsey Bergmann on 10/9/20.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        NavigationView {
        HStack {
            NavigationLink(destination: RecordHistory()) {  Text("Start").position(x: 150, y: 300).font(.system(size: 25, weight: .bold))
            }.buttonStyle(PlainButtonStyle())
            
            NavigationLink(destination: History()) {  Text("Records").position(x: -10, y: 350).font(.system(size: 25, weight: .bold))
            }.buttonStyle(PlainButtonStyle()) 
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


