import SwiftUI
struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Tic Tac Toe")
                    .font(.title)
                    .bold()
                    .padding()
                
                NavigationLink(destination: PvPGameView()) {
                    Text("Player vs. Player")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.vertical, 10)
                
                NavigationLink(destination: PvCGameView()) {
                    Text("Player vs. Computer")
                        .font(.headline)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.vertical, 10)
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
