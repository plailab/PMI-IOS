import Foundation
import SwiftUI
import Combine

// https://docs.livekit.io/agents/overview/ (great resource to look at on the communication protocol works)
class UIUpdateClient: ObservableObject {
    private var webSocket: URLSessionWebSocketTask?
    private var session: URLSession?
    private var reconnectTimer: Timer?
    
    @Published var shouldStartGame: Bool = false
    @Published var backgroundColor: Color = .white
    @Published var reps: Int = 12
    @Published var textSize: CGFloat = 16
    
    func connect() {
        /*
            Connects to server (not local host, but the livekit websockets server)
            The server I run then communicates with that server. It is like there is two middle men,
            and the first one is the websocket server, and the second one is the local, and the third is the realtime openai api
            (https://docs.livekit.io/agents/overview/)
        */
        guard webSocket == nil else { return }
        
        session = URLSession(configuration: .default)
        // I wonder if it is okay that this is public lol
        guard let url = URL(string: "wss://pmi-ios-9dsuqmkw.livekit.cloud/ws") else { return }
        
        webSocket = session?.webSocketTask(with: url)
        webSocket?.resume()
        
        receiveMessage()
        
        print("Connected to UI update server")
    }
    
    func disconnect() {
        /*
            Bye bye websocket connection
        */
        webSocket?.cancel(with: .normalClosure, reason: nil)
        webSocket = nil
        session = nil
        
        // Stop reconnect timer if it's running
        reconnectTimer?.invalidate()
        reconnectTimer = nil
        
        print("Disconnected from UI update server")
    }
    
    private func receiveMessage() {
        webSocket?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    print("Received message: \(text)")
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        print("Received data: \(text)")
                    }
                @unknown default:
                    break
                }
                
                // Continue receiving messages
                self?.receiveMessage()
                
            case .failure(let error):
                print("WebSocket error: \(error)")
                self?.scheduleReconnect()
            }
        }
    }
    
    private func scheduleReconnect() {
        // Disconnect current socket if any
        webSocket?.cancel(with: .abnormalClosure, reason: nil)
        webSocket = nil
        
        // Schedule reconnect after 5 seconds
        DispatchQueue.main.async {
            self.reconnectTimer?.invalidate()
            self.reconnectTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { [weak self] _ in
                self?.connect()
            }
        }
    }
    
    func startGameFromCommand() {
        DispatchQueue.main.async {
            self.shouldStartGame = true
        }
    }
    
    // RIGHT HERE NEEDS TO BE CHANGED
    func changeReps(_ reps: Int) {
        DispatchQueue.main.async {
            self.reps = reps
            print(self.reps)
        }
    }
    
    func updateBackgroundColor(_ colorString: String) {
        /*
             Args (str): color (in name form (eg. blue, brown), not hexadecimal)

             Changes the background based off the input from the user (look at python agent to learn more about the function)
             Global variable (background color, so when it changes, it will actually affect the ContentView (where it is called)
             IN THE FUTURE WE CAN ASK IT TO PASS A HEXADECIMAL, SO IT CAN BE ANY COLOR RATHER THAN A SWITCH AND CASE
        */
        DispatchQueue.main.async {
               let newColor = self.color(from: colorString) ?? .black
               print("Setting background color to: \(newColor)")
               self.backgroundColor = newColor
            print(self.backgroundColor)
           }

    }
    
    private func color(from string: String) -> Color? {
        /*
         Args (str): color (in name form (eg. blue, brown), not hexadecimal)
         
         IN THE FUTURE WE CAN ASK IT TO PASS A HEXADECIMAL, SO IT CAN BE ANY COLOR RATHER THAN A SWITCH AND CASE
         */
        
        // Handle common color names
        switch string.lowercased() {
        case "red": return .red
        case "blue": return .blue
        case "green": return .green
        case "yellow": return .yellow
        case "orange": return .orange
        case "purple": return .purple
        case "black": return .black
        case "white": return .white
        case "gray", "grey": return .gray
        default:
            // Try to parse as hex (currently not doing it)
            if string.hasPrefix("#") {
                let hex = string.dropFirst() // Remove the '#' symbol
                var rgbValue: UInt64 = 0
                Scanner(string: String(hex)).scanHexInt64(&rgbValue)
                
                let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
                let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
                let b = Double(rgbValue & 0x0000FF) / 255.0
                
                return Color(red: r, green: g, blue: b)
            }
            return nil // Return nil if not a valid named color or hex
        }
    }
    
    func updateTextSize(_ textSize: String) {
        /*
             Args (str):

             Changes the background based off the input from the user (look at python agent to learn more about the function)
             Global variable (background color, so when it changes, it will actually affect the ContentView (where it is called)
             IN THE FUTURE WE CAN ASK IT TO PASS A HEXADECIMAL, SO IT CAN BE ANY COLOR RATHER THAN A SWITCH AND CASE
        */
        print(textSize)
        DispatchQueue.main.async {
            self.textSize = self.textSize(from: textSize) ?? 24 // black means you won't be able to see anything lol, so its broken
        }
    }
    
    // future function for changing font based on user saying it is too small
    private func textSize(from string: String) -> CGFloat {
        switch string.lowercased() {
        case "small": return 12
        case "medium": return 16
        case "large": return 20
        case "xlarge": return 24
        default: return 16
        }
    }
    
    
    
    // Simple decodable structure for UI update messages
    struct UIUpdateMessage: Decodable {
        struct DataValue: Decodable {
            let value: Any
            
            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                
                if let string = try? container.decode(String.self) {
                    value = string
                } else if let int = try? container.decode(Int.self) {
                    value = int
                } else if let double = try? container.decode(Double.self) {
                    value = double
                } else if let bool = try? container.decode(Bool.self) {
                    value = bool
                } else if container.decodeNil() {
                    value = NSNull()
                } else {
                    throw DecodingError.dataCorruptedError(
                        in: container,
                        debugDescription: "Cannot decode value"
                    )
                }
            }
        }
        
        let type: String
        let data: [String: Any]
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            type = try container.decode(String.self, forKey: .type)
            
            let dataContainer = try container.decode([String: DataValue].self, forKey: .data)
            data = dataContainer.mapValues { $0.value }
        }
        
        private enum CodingKeys: String, CodingKey {
            case type, data
        }
    }
}
