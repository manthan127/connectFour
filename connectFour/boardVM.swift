//
//  boardVM.swift
//  connectFour
//
//  Created by home on 29/11/21.
//

import SwiftUI

class BoardVM: ObservableObject {    
    @Published var board: [[Int]] = Array(repeating: Array(repeating: 0, count:7), count: 6)
    @Published var player = 1
    
    @Published var pathStart : [Int] = []
    @Published var pathEnd : [Int] = []
    
    var draw = false {
        didSet {
            if draw {
                showAlert = true
            }
        }
    }
    var win = false{
        didSet {
            if win {
                showAlert = true
            }
        }
    }
    var showAlert = false
    
    func reset() {
        board = Array(repeating: Array(repeating: 0, count:7), count: 6)
        player = 3 - player
        pathStart = []
        pathEnd = []
        win = false
        draw = false
        showAlert = false
    }
    
    func isDraw() {
        draw = !board[0].contains(0)
    }
    
    func isWin(_ row: Int, _ column: Int) {
        let point = (row, column)
        
        var row = row
        var column = column
        
        var start = point {
            didSet { (row, column) = point }
        }
        var end = point {
            didSet { (row, column) = point }
        }
        
        var colWinCond: Bool { abs(end.1 - start.1) >= 3 }
        var rowWinCond: Bool { abs(end.0 - start.0) >= 3 }
        
        
        // vertical
        while row < board.count-1 && board[row+1][column] == player {
            row += 1
        }
        end = (row, column)
        if rowWinCond {
            pathStart.append(ind(start))
            pathEnd.append(ind(end))
        }
        
        // horizontal
        while column > 0 && board[row][column-1] == player {
            column -= 1
        }
        start = (row, column)
        
        while column < 6 && board[row][column+1] == player {
            column += 1
        }
        end = (row, column)
        
        if colWinCond {
            pathStart.append(ind(start))
            pathEnd.append(ind(end))
        }
        
        // rev diagonal
        while row > 0 && column > 0 && board[row-1][column-1] == player {
            row-=1
            column-=1
        }
        start = (row, column)
        
        while row < 5 && column < 6 && board[row+1][column+1] == player {
            row+=1
            column+=1
        }
        end = (row, column)
        
        if rowWinCond && colWinCond {
            pathStart.append(ind(start))
            pathEnd.append(ind(end))
        }
        
        
        // diagonal
        while row < 5 && column > 0 && board[row+1][column-1] == player {
            row+=1
            column-=1
        }
        start = (row, column)
        
        while row > 0 && column < 6 && board[row-1][column+1] == player {
            row-=1
            column+=1
        }
        end = (row, column)
        
        if colWinCond && rowWinCond {
            pathStart.append(ind(start))
            pathEnd.append(ind(end))
        }
        
        
        if pathStart.isEmpty{
            isDraw()
        } else {
            win = true
        }
    }
    
    func click(_ row: Int, _ column: Int){
        
        board[row][column] = player
        
        isWin(row, column)
        
        if showAlert {return}
        
        player = 3-player
    }
    
    func ind(_ x :(row: Int, column: Int)) -> Int{
        x.row*7 + x.column
    }
    
    func length(_ index: Int) -> (CGFloat, Angle) {
        var angle: Angle
        let startP = (pathStart[index]/7, pathStart[index]%7)
        let endP = (pathEnd[index]/7, pathEnd[index]%7)
        
        let yDiff = endP.0 - startP.0
        let xDiff = endP.1 - startP.1
        
        if xDiff == 0 {
            angle = Angle(degrees: 0)
        } else if yDiff == 0 {
            angle = Angle(degrees: 90)
        } else if xDiff == yDiff {
            angle = Angle(degrees: -45)
        } else {
            angle = Angle(degrees: 45)
        }
        
        return (sqrt(pow(CGFloat(xDiff), 2) + pow(CGFloat(yDiff), 2)),
                angle)
    }    
}
