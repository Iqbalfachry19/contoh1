import Foundation

class GameState: ObservableObject
{
    @Published var board = [[Cell]]()
    @Published var turn = Tile.Nought
    @Published var noughtsScore = 0
    @Published var crossesScore = 0
    @Published var showAlert = false
    @Published var alertMessage = "Draw"
    @Published var shouldPlayFirst = true
    private var makeAIMoveFunction: () -> Void

    init(makeAIMoveFunction: @escaping () -> Void) {
        self.makeAIMoveFunction = makeAIMoveFunction
        resetBoard()
        turn = Tile.Nought  // Initialize the turn as Nought
    }
    func setMakeAIMoveFunction(_ function: @escaping () -> Void) {
           self.makeAIMoveFunction = function
       }
    func turnText() -> String
    {
        return turn == Tile.Cross ? "Turn: X" : "Turn: O"
    }
    
    func placeTile(_ row: Int,_ column: Int)
    {
        if row < 0 || row >= 3 || column < 0 || column >= 3 {
              // Invalid indices, do not place tile
              return
          }

          if board[row][column].tile != Tile.Empty {
              // Cell is already occupied, do not place tile
              return
          }
        
        board[row][column].tile = turn == Tile.Cross ? Tile.Cross : Tile.Nought
        
        
        if(checkForVictory())
        {
            if(turn == Tile.Cross)
            {
                crossesScore += 1
            }
            else
            {
                noughtsScore += 1
            }
            let winner = turn == Tile.Cross ? "Crosses" : "Noughts"
            alertMessage = winner + " Win!"
            showAlert = true
        }
        else
        {
            turn = turn == Tile.Cross ? Tile.Nought : Tile.Cross
        }
        
        if(checkForDraw())
        {
            alertMessage = "Draw"
            showAlert = true
        }
        makeAIMoveFunction()
    }
    
    func checkForDraw() -> Bool
    {
        for row in board
        {
            for cell in row
            {
                if cell.tile == Tile.Empty
                {
                    return false
                }
            }
        }
        
        return true
    }
    
    func checkForVictory() -> Bool
    {
        // vertical victory
        if isTurnTile(0, 0) && isTurnTile(1, 0) && isTurnTile(2, 0)
        {
            return true
        }
        if isTurnTile(0, 1) && isTurnTile(1, 1) && isTurnTile(2, 1)
        {
            return true
        }
        if isTurnTile(0, 2) && isTurnTile(1, 2) && isTurnTile(2, 2)
        {
            return true
        }
        
        // horizontal victory
        if isTurnTile(0, 0) && isTurnTile(0, 1) && isTurnTile(0, 2)
        {
            return true
        }
        if isTurnTile(1, 0) && isTurnTile(1, 1) && isTurnTile(1, 2)
        {
            return true
        }
        if isTurnTile(2, 0) && isTurnTile(2, 1) && isTurnTile(2, 2)
        {
            return true
        }
        
        // diagonal victory
        if isTurnTile(0, 0) && isTurnTile(1, 1) && isTurnTile(2, 2)
        {
            return true
        }
        if isTurnTile(0, 2) && isTurnTile(1, 1) && isTurnTile(2, 0)
        {
            return true
        }
        
        
        return false
    }
    
    func isTurnTile(_ row: Int,_ column: Int) -> Bool
    {
        return board[row][column].tile == turn
    }
    
    func resetBoard()
    {
        var newBoard = [[Cell]]()
        
        for _ in 0...2
        {
            var row = [Cell]()
            for _ in 0...2
            {
                row.append(Cell(tile: Tile.Empty))
            }
            newBoard.append(row)
        }
        board = newBoard
        shouldPlayFirst.toggle()
    }
    func makeAIMove() {
        print("Making AI move")
           guard !checkForVictory() && !checkForDraw() else {
               print("AI move not possible")
               return
           }
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }

                let bestMove = self.minimax(board: self.board, depth: 0, maximizingPlayer: false).move
                print(bestMove)
                DispatchQueue.main.async {
                    self.placeTile(bestMove.row, bestMove.column)
                    self.makeAIMoveFunction() // Call the AI move function here
                }
            }
        print("AI move executed")
        }
        
    private func minimax(board: [[Cell]], depth: Int, maximizingPlayer: Bool) -> (score: Int, move: (row: Int, column: Int)) {
        if checkForVictory() {
            // Calculate score based on depth
            let score = maximizingPlayer ? 10 - depth : depth - 10
            return (score, (-1, -1))
        }
        
        if checkForDraw() {
            return (0, (-1, -1))
        }
        
        var bestScore = maximizingPlayer ? Int.min : Int.max
        var bestMove = (-1, -1)
        
        for row in 0..<3 {
            for column in 0..<3 {
                if board[row][column].tile == .Empty {
                    var newBoard = board
                    newBoard[row][column].tile = maximizingPlayer ? .Nought : .Cross
                    
                    let score = minimax(board: newBoard, depth: depth + 1, maximizingPlayer: !maximizingPlayer).score
                    
                    if (maximizingPlayer && score > bestScore) || (!maximizingPlayer && score < bestScore) {
                        bestScore = score
                        bestMove = (row, column)
                    }
                }
            }
        }
        
        // If no valid move is found, return the best move with a neutral score
        if bestMove == (-1, -1) {
            return (0, (-1, -1))
        }
        
        return (bestScore, bestMove)
    }

}
