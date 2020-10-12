//
//  SwiftUIView.swift
//  RoadXpert
//
//  Created by Chelsey Bergmann on 10/9/20.
//

import SwiftUI

struct RecordHistory: View {
    var body: some View {
        HStack {
            NavigationView {
                Text("Record")}.position(x: 75, y: 350).font(.system(size: 25)).foregroundColor(.black).onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                    record()
                })
          
            NavigationLink(destination:SingleHistory()){ Text("Trip History")}.position(x: 75, y: 396).font(.system(size: 25)).foregroundColor(.black).padding(.trailing, 10.0)
            }
    }
}

/**
 Records the trip process.
 */
func record() {

}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        RecordHistory()
    }
}
