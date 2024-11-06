//
//  StartingScreenView.swift
//  LonelyExplorer
//
//  Created by Åsa Östmark on 2024-10-28.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct StartingScreenView: View {
    
    func savePlayer(playerName: String) {
        let db = Firestore.firestore()
        
        let explorers = db.collection("explorers").document("explorers")
        
        explorers.setData([
            "name": playerNameInput,
            "createdAt": Timestamp(date: Date())
        ]) { error in
            if let error = error {
                print("Womp Womp: \(error)")
            } else {
                print("Explorer added to Firestore!")
            }
        }
    }
    
    @ObservedObject var gameData = GameData()
    @State private var showNameEntry = false
    @State private var navigateToContentView: Bool = false
    @State private var playerNameInput = ""

    var body: some View {
        NavigationStack {

            ZStack{
                Color(red: 1/255, green: 1/255, blue: 1/255)
                    .ignoresSafeArea(.all)
                VStack {
                    Text("Lonely Explorer")
                        .font(.largeTitle)
                        .foregroundColor(.pink)
                    
                    Button(action: {
                        showNameEntry = true
                    }) {
                        Text("New Game")
                            .foregroundColor(.white)
                            .padding()
                            .background(LinearGradient(gradient:
                        Gradient(colors: [.pink, .purple]), startPoint:
                            .leading, endPoint: .trailing))
                            .cornerRadius(10)
                            .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 5)
                    }
                    .padding()
                    .sheet(isPresented: $showNameEntry) {
                       
                        VStack {
                            
                            Image("explorer")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 150)
                            
                            TextField("Enter Player Name", text: $playerNameInput)
                                .foregroundColor(.pink)
                                .padding(10)
                                .background(.black)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white, lineWidth: 1))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button(action: {
                                if !playerNameInput.isEmpty {
                                    savePlayer(playerName: playerNameInput)
                                                } else {
                                                    print("Player name cannot be empty")
                                                }
                                gameData.playerName = playerNameInput
                                navigateToContentView = true
                                showNameEntry = false
                            }) {
                                Text("Start Game")
                                    .foregroundStyle(.pink)
                            }
                        }
                    }
                    
                    Button(action: {
                        gameData.loadGame()
                        navigateToContentView = true
                    }) {
                        Text("Load Game")
                            .foregroundColor(.white)
                            .padding()
                            .background(LinearGradient(gradient:
                        Gradient(colors: [.pink, .purple]), startPoint:
                            .leading, endPoint: .trailing))
                            .cornerRadius(10)
                            .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 5)
                    }

                }
                
            }
            
            
                            .navigationTitle("")
                            .navigationDestination(isPresented: $navigateToContentView) {
                                ContentView(gameData: gameData)
                            }
                        }
                    }
    
                }

                #Preview {
                    StartingScreenView()
                }
