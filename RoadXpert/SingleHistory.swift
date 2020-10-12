//
//  SingleHistory.swift
//  RoadXpert
//
//  Created by Chelsey Bergmann on 10/9/20.
//

import SwiftUI

struct SingleHistory: View {
    var body: some View {
        Text("History per record").offset(y: -250).frame(alignment: .center).font(.system(size: 25, weight: .bold))
    }
}

struct SwiftUIView2_Previews: PreviewProvider {
    static var previews: some View {
        SingleHistory()
    }
}
