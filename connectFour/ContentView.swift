//
//  ContentView.swift
//  connectFour
//
//  Created by home on 20/11/21.
//

import SwiftUI
let width = UIScreen.main.bounds.width/3
struct ContentView: View {
    @State var nav = false
    var body: some View {
        ZStack {
            if nav {
                NavigationLink("", destination: BoardView(), isActive: $nav)
            }
            VStack {
                Button {
                    nav.toggle()
                } label: {
                    Text("Play")
                        .font(.largeTitle)
                        .foregroundColor(.black)
                        .frame(width: width, height: (width/3)*2)
                        .background(RadialGradient(gradient: Gradient(colors: [Color.white, Color.blue]), center: .init(x: 0.4, y: 0.4), startRadius: 5, endRadius: 70))
                        .cornerRadius(10)
                }

            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
