//
//  PvCGameView.swift
//  contoh1
//
//  Created by Iqbal Fachry on 11/08/23.
//

import SwiftUI

struct PvCGameView: View {
    @StateObject var gameState: GameState
    @State private var isComputingAIMove = false
    init() {
        _gameState = StateObject(wrappedValue: GameState(makeAIMoveFunction: {}))
        setupTempGameState()
    }
    
    private func setupTempGameState() {
        let tempGameState: GameState = gameState
        
        tempGameState.shouldPlayFirst = gameState.noughtsScore > gameState.crossesScore
        
        let makeAIMoveFunction: () -> Void = {
            if tempGameState.turn == .Nought {
                tempGameState.makeAIMove()
            }
        }
        
        tempGameState.setMakeAIMoveFunction(makeAIMoveFunction)
    }
    var body: some View {
        let borderSize = CGFloat(5)
        
        VStack {
            Text(gameState.turnText())
                .font(.title)
                .bold()
                .padding()
            
            Spacer()
            
            Text(String(format: "Crosses: %d", gameState.crossesScore))
                .font(.title)
                .bold()
                .padding()
            
            VStack(spacing: borderSize) {
                ForEach(0...2, id: \.self) { row in
                    HStack(spacing: borderSize) {
                        ForEach(0...2, id: \.self) { column in
                            let cell = gameState.board[row][column]
                            
                            Text(cell.displayTile())
                                .font(.system(size: 60))
                                .foregroundColor(cell.tileColor())
                                .bold()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .aspectRatio(1, contentMode: .fit)
                                .background(Color.white)
                                .onTapGesture {
                                    if gameState.turn == .Cross && !gameState.checkForVictory() {
                                        gameState.placeTile(row, column)
                                        if !gameState.checkForVictory() {
                                            makeAIMoveIfNeeded()
                                        }
                                    }
                                }

                        }
                    }
                }
            }
            .background(Color.black)
            .padding()
            .alert(isPresented: $gameState.showAlert) {
                Alert(
                    title: Text(gameState.alertMessage),
                    dismissButton: .default(Text("Okay")) {
                        gameState.resetBoard()
                        if gameState.turn != .Cross {
                                        makeAIMoveIfNeeded()
                                    }
                    }
                )
            }
            
            Text(String(format: "Noughts: %d", gameState.noughtsScore))
                .font(.title)
                .bold()
                .padding()
            
            Spacer()
        }
        .onAppear {
            makeAIMoveIfNeeded()
        }
        .overlay(
            ZStack {
                if isComputingAIMove {
                    Color.black.opacity(0.8)
                        .edgesIgnoringSafeArea(.all)
                        .allowsHitTesting(true)
                    
                    ProgressView("Computing AI Move...")
                        .foregroundColor(.white)
                        .font(.headline)
                }
            }
        )
        
    }
    
    private func makeAIMoveIfNeeded() {
        print("Checking for AI move need")
           if gameState.turn == .Nought && !isComputingAIMove {
               print("Initiating AI move")
            isComputingAIMove = true // Show loading state
            gameState.makeAIMove()
            
            // The AI move is done within the closure
            // Set isComputingAIMove to false when the AI move is done
            gameState.setMakeAIMoveFunction {
                isComputingAIMove = false
            }
        }
    }


}

struct PvCGameView_Previews: PreviewProvider {
    static var previews: some View {
        PvCGameView()
    }
}
