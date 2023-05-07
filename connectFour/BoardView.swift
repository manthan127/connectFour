//
//  BoardView.swift
//  connectFour
//
//  Created by home on 20/11/21.
//

import SwiftUI

let device = UIDevice.current.userInterfaceIdiom

struct BoardView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var vm = BoardVM()
    
    @State var ballOffset: CGFloat = 0
    @State var path: [Int : CGRect] = [:]
    
    @State var ballXPos: CGFloat = -100
    @State var ballYPos: CGFloat = 0
    
    let colorArr = [Color.gray.opacity(0.1), Color.yellow, Color.red]
    let pipeWidth: CGFloat = device == .pad ? 100 : 50
    let pipeHeight: CGFloat = device == .pad ? 300 :  250
    let numOfBall = device == .pad ? 5 : 7
    
    var body: some View {
        ZStack{
            titleBar
                .position(x: UIScreen.main.bounds.width/2, y: 30)
            
            VStack {
                pipeView
                    .ignoresSafeArea(edges: .top)
                
                Spacer()
                boardView
                    .overlay(
                        lines
                    )
            }
            .navigationBarHidden(true)
        }
        .background(Color.gray.ignoresSafeArea())
    }
    
    var titleBar: some View {
        Group {
            if vm.showAlert {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("Home Screen")
                            .font(device == .pad ? .largeTitle : .none)
                    })
                    .padding(.leading)
                    
                    Spacer()
                    
                    Button(action: {
                        ballXPos = -30
                        vm.reset()
                    }, label: {
                        Text("Replay")
                            .font(device == .pad ? .largeTitle : .none)
                    })
                    .padding(.trailing)
                }
            } else {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("Back")
                            .font(device == .pad ? .largeTitle : .none)
                    })
                    .padding(.leading)
                    
                    Spacer()
                }
            }
        }
    }
    
    var pipeView: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    gradient: Gradient(
                        stops: [
                            .init(color: Color(#colorLiteral(red: 0.06666666667, green: 0.2235294118, blue: 0.08235294118, alpha: 1)), location: 0.1),
                            .init(color: Color(#colorLiteral(red: 0.4431372549, green: 0.9803921569, blue: 0.4431372549, alpha: 1)), location: 0.6),
                            .init(color: Color(#colorLiteral(red: 0.09411764706, green: 0.3215686275, blue: 0.1137254902, alpha: 1)), location: 1),
                        ]),
                    startPoint: .leading, endPoint: .trailing)
            )
            .frame(width: pipeWidth, height: pipeHeight)
            .overlay(
                VStack(spacing: 0) {
                    Spacer()
                    ForEach(0..<numOfBall, id: \.self) { i in
                        Circle()
                            .fill(colorArr[(vm.player+i)%2 + 1])
                            .frame(width: pipeWidth-2, height: pipeWidth-2)
                            .padding(2)
                            .offset(y: ballOffset)
                    }
                }
                .offset(y: -pipeWidth)
            )
    }
    
    var boardView: some View {
        HStack(spacing: 4) {
            ForEach (0..<7){ column in
                VStack(spacing: 4) {
                    ForEach (0..<6) { row in
                        cellView(row, column)
                    }
                }
                .onTapGesture {
                    ballYPos = 0
                    let row = (0..<6).reversed().first(where: { vm.board[$0][column] == 0 })!
                    
                    ballXPos = path[column]?.midX ?? 0
                    
                    let time = Double(row)/10 + 0.1
                    
                    withAnimation(Animation.linear(duration: time)) {
                        ballOffset = pipeWidth
                        ballYPos = (path[row*7]?.midY ?? 0) - (path[0]?.minY ?? 0)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time) {
                        vm.click(row, column)
                        ballOffset = 0
                    }
                }
                .disabled(ballOffset == pipeWidth || vm.board[0][column] != 0 || vm.showAlert)
            }
        }
        .aspectRatio(7/6, contentMode: .fit)
        .padding(10)
        .background(
            ZStack {
                Color.purple
                    .cornerRadius(3.0)
                HStack(spacing: 4) {
                    ForEach (0..<7){ column in
                        VStack(spacing: 4) {
                            ForEach (0..<6) { row in
                                Circle()
                            }
                        }
                    }
                }
                .padding(10)
                .blendMode(.destinationOut)
            }
            .compositingGroup()
        )
        .padding()
        .background(
            Circle()
                .fill(colorArr[vm.player])
                .frame(width: path[0]?.height ?? 0, height: path[0]?.height ?? 0)
                .position(x: ballXPos, y: ballYPos)
                .offset(y: 26)
        )
    }
    
    func cellView(_ row: Int,_ column: Int)-> some View {
        GeometryReader { geo in
            Circle()
                .fill(colorArr[vm.board[row][column]])
                .onAppear {
                    path[vm.ind((row, column))] = geo.frame(in: .global)
                }
        }
    }
    
    var lines: some View {
        let cellSize = path[0]?.height ?? 0
        let startPos = path[0]?.minY ?? 0
        return ZStack {
            ForEach(vm.pathEnd.indices, id: \.self) { i in
                let (length, angle) = vm.length(i)
                
                let (xPos, yPos) = getPos(i)
                
                Rectangle()
                    .rotationEffect(angle)
                    .frame(width: 4, height: length * cellSize + (length-1)*4)
                    .position(x: xPos, y: yPos - startPos)
                    .offset(y: 26)
            }
        }
    }
    
    func getPos(_ i: Int) -> (CGFloat, CGFloat) {
        let s = path[vm.pathStart[i]]!
        let e = path[vm.pathEnd[i]]!
        
        return ((s.midX + e.midX) / 2, (s.midY + e.midY) / 2)
    }
}

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        BoardView()
    }
}
