//
//  ContentView.swift
//  LonelyExplorer
//
//  Created by Åsa Östmark on 2024-09-25.
//


import SwiftUI
import Combine


//structs

class GameData: ObservableObject {
    
    
    //variables
    
    @Published var playerName: String = ""
    @Published var explorers: Int = 1
    @Published var explorerMult: Double = 1.0
    @Published var resources: [String: Resource]
    @Published var buildings: [String: Building]
    @Published var crafting: [String: Crafting]
    @Published var research: [String: Research]
    @Published var materials: [String: Material]
    
    private var happinessTimer: AnyCancellable?
    private var woodTimer: AnyCancellable?
    private var resourceTimer: AnyCancellable?
    
    init() {
        
        //dictionaries
        
        //resource amounts have been boosted for testing purposes
        self.resources = [
            "wood": Resource(name: "Wood", amount: 90, ratePerSecond: 0.5, maxAmount: 500),
            "stone": Resource(name: "Stone", amount: 90, ratePerSecond: 0.5, maxAmount: 2500),
            "clay": Resource(name: "Clay", amount: 90, ratePerSecond: 0.5, maxAmount: 500),
            "iron": Resource(name: "Iron", amount: 90, ratePerSecond: 0.5, maxAmount: 150),
            "coal": Resource(name: "Coal", amount: 10, ratePerSecond: 0.1, maxAmount: 100),
            "happiness": Resource(name: "Happiness", amount: 0, ratePerSecond: 0.1, maxAmount: 1000)
        ]
        
        self.buildings = [
            "home": Building(name: "Home", baseCost: ["wood" : 100, "clay" : 100], owned: 0, productionRate: 0.5, resourceProduced: "happiness"),
            "woodcutter": Building(name: "Woodcutter", baseCost: ["beam" : 1, "slab" : 1, "bar" : 1], owned: 0, productionRate: 0.5, resourceProduced: "wood", research: "woodCutter"),
            "miner": Building(name: "Miner", baseCost: ["beam" : 1, "slab" : 1, "bar" : 1], owned: 0, productionRate: 0.5, resourceProduced: "stone", research: "automaticMiner")
            
        ]
        
        self.crafting = [
            "constructor": Crafting(name: "Constructor", baseCost: ["wood" : 100, "stone" : 100, "iron" : 50], owned: 0, research: "constructor")
        ]
        
        //material amounts have been boosted for testing purposes
        self.materials = [
            "beam": Material(name: "Wooden Beam", amount: 1, cost: ["wood" : 100], maxAmount: 50),
            "slab": Material(name: "Stone Slab", amount: 1, cost: ["stone" : 100], maxAmount: 50),
            "bar": Material(name: "Iron Bar", amount: 1, cost: ["iron" : 100], maxAmount: 25),
            "ingot": Material(name: "Steel Ingot", amount: 1, cost: ["steel" : 100], maxAmount: 10),
            "brick": Material(name: "Brick", amount: 1, cost: ["clay" : 10], maxAmount: 100)
        ]
        
        self.research = [
            "woodCutter": Research(name: "Woodcutter", cost: ["happiness": 100], isUnlocked: false),
            "automaticMiner": Research(name: "Automatic Miner", cost: ["happiness": 100], isUnlocked: false),
            "constructor": Research(name: "Constructor", cost: ["happiness": 500], isUnlocked: false),
        ]
        
        
        //preparing generation and consumption of resources
        
        prepareHappinessgeneration()
        prepareWoodConsumption()
        prepareResourceGeneration()
        
    }
    
    
    //structs
    
    struct Building {
        var name: String
        var baseCost: [String: Double]
        var owned: Int
        var productionRate: Double?
        var resourceProduced: String?
        var research: String?
    }
    
    struct Crafting {
        var name: String
        var baseCost: [String: Double]
        var owned: Int
        var research: String?
    }
    
    struct Resource {
        var name: String
        var amount: Double
        var ratePerSecond: Double
        var maxAmount: Double?
    }
    
    struct Research {
        var name: String
        var cost: [String: Double]
        var isUnlocked: Bool
    }
    
    struct Material {
        var name: String
        var amount: Double
        var cost: [String : Double]
        var maxAmount: Double?
    }
    
    
    //functions
    
    //checks if a building is able to be purchased by player
    
    func confirmIfCanPurchaseBuilding(named buildingName: String) -> Bool {
        guard let building = buildings[buildingName] else {
            return false
        }
        if let requiredResearch = building.research {
            if !(research[requiredResearch]?.isUnlocked ?? false) {
                return false
            }
        }
        
        return building.baseCost.allSatisfy { key, cost in
            (resources[key]?.amount ?? 0 >= cost) || (materials[key]?.amount ?? 0 >= cost)
                
            }
        }
    
    
    //checks if the player has enough resources to craft and have researched it
    
    func confirmIfCanPurchaseCrafting(named craftingName: String) -> Bool {
        guard let crafting = crafting[craftingName] else {
            return false
        }
        
        if let requiredResearch = crafting.research {
            if !(research[requiredResearch]?.isUnlocked ?? false) {
                return false
            }
        }
        
        return crafting.baseCost.allSatisfy { key, cost in
            (resources[key]?.amount ?? 0) >= cost
        }
    }

    
    //function that handles the player purchasing a building
    
    func purchaseBuilding(named buildingName: String) {
        guard confirmIfCanPurchaseBuilding(named: buildingName),
              var building = buildings[buildingName] else { return }
        building.owned += 1
        buildings[buildingName] = building
        for (resource, cost) in building.baseCost {
            resources[resource]?.amount -= cost
        }
    }
    
    
    //handles the player purchasing the constructor
    
    func purchaseCrafting(named craftingName: String) {
        guard confirmIfCanPurchaseCrafting(named: craftingName),
              var craft = crafting[craftingName] else { return }
        craft.owned += 1
        crafting[craftingName] = craft
        for (resource, cost) in craft.baseCost {
            resources[resource]?.amount -= cost
        }
    }
    
    
    //prepares resources to be generated by buildings
    
    private func prepareResourceGeneration() {
        resourceTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.generateResources()
            }
    }
    
    
    //generates resources
    
    func generateResources() {
        for (_, building) in buildings {
            if building.owned > 0,
               let productionRate = building.productionRate,
               let resourceName = building.resourceProduced,
               research[resourceName]?.isUnlocked ?? true {
                
                let totalProduction = Double(building.owned) * productionRate
                
                if var resource = resources[resourceName] {
                    resource.amount = min(resource.amount + totalProduction, resource.maxAmount ?? .infinity)
                    resources[resourceName] = resource
                }
            }
        }
    }
    
    
    //handles the player crafting a material via the constructor
    
    func craftMaterial(named materialName: String) {
        guard let material = materials[materialName],
              let constructor = crafting["constructor"], constructor.owned > 0
        else {
            return
        }

        for (resourceName, cost) in material.cost {
            guard let resource = resources[resourceName], resource.amount >= cost else {
                return
            }
        }

        for (resourceName, cost) in material.cost {
            resources[resourceName]?.amount -= cost
        }

        materials[materialName]?.amount += 1
    }

    
//handles the player adding another explorer into the game and the explorerMult
    
    func inviteExplorer() {
        let homes = buildings["home"]?.owned ?? 0
        if homes > explorers && resources["happiness"]?.amount ?? 0 >= 100 * explorerMult {
            explorers += 1
            resources["happiness"]?.amount -= 100 * explorerMult
            explorerMult += 0.1
        }
    }

    
    //handles the player researching something through the research menu
    
    func research(_ researchName: String) {
        guard let currentResearch = research[researchName], !currentResearch.isUnlocked else {
            return
        }
        
        if let happinessResource = resources["happiness"], happinessResource.amount >= currentResearch.cost["happiness"] ?? 0 {
            resources["happiness"]?.amount -= currentResearch.cost["happiness"] ?? 0
            
            research[researchName]?.isUnlocked = true
            print("Research \(researchName) has been unlocked, you can now purchase it in the buildings menu.")
            
        } else {
            return
        }
    }
    
    
    //prepares generation of the happiness resource
    
    private func prepareHappinessgeneration() {
        happinessTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink {
                [weak self] _ in
                self?.generateHappiness()
            }
    }
    
    
    //handles the generation of the happiness resource
    
    private func generateHappiness() {
        let homesAvailable = buildings["home"]?.owned ?? 0
        let heatedHomes = min(homesAvailable, Int(resources["wood"]?.amount ?? 0) / 10)
        
        if heatedHomes > 0 && explorers > 0 {
            resources["happiness"]?.amount +=
            Double(heatedHomes)
        }
    }
    
    
    //prepares consumption of the wood resource
    
    private func prepareWoodConsumption() {
        woodTimer = Timer.publish(every: 10, on: .main, in: .common)
            .autoconnect()
            .sink {
                [weak self] _ in self?.consumeWood()
            }
    }
    
    
    //handles the consumption of the wood resource
    
    private func consumeWood() {
        let homesAvailable = buildings["home"]?.owned ?? 0
        let woodAmount = resources["wood"]?.amount ?? 0
        if homesAvailable > 0 && woodAmount >= Double(homesAvailable) {
            resources["wood"]?.amount -= Double(homesAvailable)
        }
    }
    
    //checks if materials can be crafted
    
    func canCraftMaterial(named materialName: String) -> Bool {
        guard let material = materials[materialName] else { return false }
        return material.cost.allSatisfy { resourceName, cost in
            (resources[resourceName]?.amount ?? 0) >= cost
        }
    }
    
    
    //will be used to load data of the game on the starting screen view at a later point
    
    func loadGame() {
        // nothing to see here yet...
    }
    
}


//cview

struct ContentView: View {
    @ObservedObject var gameData: GameData
    @State private var showBuildingSheet = false
    @State private var showResearchSheet = false
    @State private var showProgressSheet = false
    
    @State var lonelyExplorerText: String = ""
    
    //change the header when there are more than one explorer
    
    private var headerText: String {
            if gameData.explorers == 1 {
                return "\(gameData.playerName) is lonely"
            } else if gameData.explorers > 1 {
                return "Lonely no more"
            } else {
                return "Lonely Explorer"
            }
        }
    
    private func updateHeaderText() {
        lonelyExplorerText = self.headerText
    }

    
    init(gameData: GameData = GameData()) {
        self.gameData = gameData
    }
    
    var body: some View {
        ZStack {
            Color(red: 190/255, green: 190/255, blue: 190/255)
                .ignoresSafeArea(.all)
            
            VStack {
                Text(lonelyExplorerText)
                    .foregroundColor(Color(hue: 0.34, saturation: 1.0, brightness: 0.2, opacity: 0.8))
                    .font(.largeTitle)
                
                
                //four clickable buttons that will generate resources when clicked
                
                HStack {
                    Button(action: {
                        gameData.resources["wood"]?.amount += 10 //resource generation has been boosted x10 for testing purposes
                        print("\(gameData.resources["wood"]?.amount ?? 0) wood")
                    }, label: {
                        Image("axe")
                            .resizable()
                            .frame(width: 100)
                            .frame(height: 100)
                    })
                    
                    //coal is given 5% of the time when the pickaxe is clicked
                    
                    Button(action: {
                        gameData.resources["stone"]?.amount += 10
                        print("\(gameData.resources["stone"]?.amount ?? 0) stone")
                        if Double.random(in: 0..<1) < 0.05 {
                            gameData.resources["coal"]?.amount += 10
                            print("\(gameData.resources["coal"]?.amount ?? 0) coal")
                        }
                    }, label: {
                        Image("pickaxe")
                            .resizable()
                            .frame(width: 100)
                            .frame(height: 100)
                    })
                    
                }
                
                HStack {
                    Text("Wood: \(Int(gameData.resources["wood"]?.amount ?? 0))")
                        .foregroundStyle(.black)
                    Image("Wood")
                        .resizable()
                        .frame(width: 20, height: 20)
                    
                    
                    VStack {
                        
                        HStack {
                            Text("Stone: \(Int(gameData.resources["stone"]?.amount ?? 0))")
                                .foregroundStyle(.black)
                            Image("Stone")
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                        
                        HStack{
                            Text("Coal: \(Int(gameData.resources["coal"]?.amount ?? 0))")
                                .foregroundStyle(.black)
                            Image("Coal")
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                        
                    }
                }
                
                HStack {
                    Button(action: {
                        gameData.resources["iron"]?.amount += 10
                        print("\(gameData.resources["iron"]?.amount ?? 0) iron")
                    }, label: {
                        Image("drill")
                            .resizable()
                            .frame(width: 100)
                            .frame(height: 100)
                    })
                    Button(action: {
                        gameData.resources["clay"]?.amount += 10
                        print("\(gameData.resources["clay"]?.amount ?? 0) clay")
                    }, label: {
                        Image("shovel")
                            .resizable()
                            .frame(width: 100)
                            .frame(height: 100)
                        
                    })
                }
                
                HStack {
                    Text("Iron: \(Int(gameData.resources["iron"]?.amount ?? 0))")
                        .foregroundStyle(.black)
                    Image("Iron")
                        .resizable()
                        .frame(width: 20, height: 20)
                    
                    Text("Clay: \(Int(gameData.resources["clay"]?.amount ?? 0))")
                        .foregroundStyle(.black)
                    Image("Clay")
                        .resizable()
                        .frame(width: 20, height: 20)
                }

                HStack {
                    
                    //building sheet button
                    
                    Button(action: {
                        showBuildingSheet.toggle()
                    }) {
                        Text("Purchase Buildings")
                            .foregroundColor(.white)
                            .padding()
                            .background(LinearGradient(gradient:
                        Gradient(colors: [Color(hue: 0.34, saturation: 1.0, brightness: 0.2, opacity: 0.8), Color(hue: 0.50, saturation: 1.0, brightness: 0.2, opacity: 0.8)]), startPoint:
                            .leading, endPoint: .trailing))
                            .cornerRadius(10)
                            .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 5)
                    }
                    
                    //research sheet button
                    
                    Button(action: {
                        showResearchSheet.toggle()
                    }) {
                        Text("Conduct Research")
                            .foregroundColor(.white)
                            .padding()
                            .background(LinearGradient(gradient:
                        Gradient(colors: [Color(hue: 0.34, saturation: 1.0, brightness: 0.2, opacity: 0.8), Color(hue: 0.50, saturation: 1.0, brightness: 0.2, opacity: 0.8)]), startPoint:
                            .leading, endPoint: .trailing))
                            .cornerRadius(10)
                            .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 5)
                    }
                    
                  
                    //progress sheet button
                    
                    Button(action: {
                        showProgressSheet.toggle()
                    }) {
                        Text("View Progress")
                            .foregroundColor(.white)
                            .padding()
                            .background(LinearGradient(gradient:
                        Gradient(colors: [Color(hue: 0.34, saturation: 1.0, brightness: 0.2, opacity: 0.8), Color(hue: 0.50, saturation: 1.0, brightness: 0.2, opacity: 0.8)]), startPoint:
                            .leading, endPoint: .trailing))
                            .cornerRadius(10)
                            .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 5)
                    }
                }.padding()
                
            }
            
            .onReceive(gameData.$explorers) { _ in
                updateHeaderText()
            }
            
            .sheet(isPresented: $showBuildingSheet) {
                BuildingSheet(gameData: gameData)
            }
            .sheet(isPresented: $showResearchSheet) {
                ResearchSheet(gameData: gameData)
            }
            .sheet(isPresented: $showProgressSheet) {
                ProgressSheet(gameData: gameData)
            }
            
        }
        
    }
    
}

//building sheet

struct BuildingSheet: View {
    @ObservedObject var gameData: GameData
    
    var body: some View {
        NavigationView {
             List {
                 ForEach(gameData.buildings.keys.sorted(), id: \.self) { buildingName in
                     let building = gameData.buildings[buildingName]!
                     HStack {
                         Text(building.name)
                         Spacer()
                         Button(action: {
                             gameData.purchaseBuilding(named: buildingName)
                         }) {
                             Text("Buy")
                                 .foregroundStyle(gameData.confirmIfCanPurchaseBuilding(named: buildingName) ? .green : .gray)
                         }
                         .disabled(!gameData.confirmIfCanPurchaseBuilding(named: buildingName))
                     }
                 }
                 
                ForEach(gameData.crafting.keys.sorted(), id: \.self) { craftingName in
                                         let crafting = gameData.crafting[craftingName]!
                                         HStack {
                                             Text(crafting.name)
                                             Spacer()
                                             Button(action: {
                                                 gameData.purchaseCrafting(named: craftingName)
                                             }) {
                                                 Text("Buy")
                                                     .foregroundStyle(gameData.confirmIfCanPurchaseCrafting(named: craftingName) ? .green : .gray)
                                             }
                                             .disabled(!gameData.confirmIfCanPurchaseCrafting(named: craftingName))
                                         }
                                     }
             }
             .navigationTitle("Buildings")
         }
     }
}

//research sheet

struct ResearchSheet: View {
    @ObservedObject var gameData: GameData
    
    var body: some View {
        NavigationView {
            List {
                ForEach(gameData.research.keys.sorted(), id: \.self) { researchName in
                    let research = gameData.research[researchName]!
                    HStack {
                        Text(research.name)
                        Spacer()
                        Button(action: {
                            gameData.research(researchName)
                        }) {
                            Text("Research")
                                .foregroundStyle(.green)
                        }
                        .disabled(research.isUnlocked)
                    }
                }
            }
            .navigationTitle("Research")
        }
    }
}

// Progress Sheet

struct ProgressSheet: View {
    @ObservedObject var gameData: GameData
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(gameData.resources.keys.sorted(), id: \.self) { resourceKey in
                        if let resource = gameData.resources[resourceKey] {
                            HStack {
                                Text("\(resource.name): \(Int(resource.amount))")
                                    .foregroundStyle(.green)
                                Image("\(resource.name)")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                            }
                        }
                    }
                    HStack {
                        Text("Houses: \(gameData.buildings["home"]?.owned ?? 0)")
                        Text("Explorers: \(gameData.explorers)")
                    }
                }
                
                if gameData.crafting["constructor"]?.owned ?? 0 > 0 {
                    Section(header: Text("Crafting")) {
                        ForEach(gameData.materials.keys.sorted(), id: \.self) {
                            materialName in
                            if let material = gameData.materials[materialName] {
                                Button(action: {
                                    gameData.craftMaterial(named: materialName)
                                }) {
                                    HStack {
                                        Text("Craft \(material.name)")
                                            .foregroundStyle(.green)
                                        Spacer()
                                        Text("Cost: \(material.cost.map { "\($0.key): \(Int($0.value))" }.joined(separator: ", "))")
                                            .foregroundStyle(.green)
                                    }
                                }
                                
                                .disabled(!gameData.canCraftMaterial(named: materialName))
                                
                            }
                        }
                    }
            
                }
                
                
                Button(action: {
                    gameData.inviteExplorer()
                }) {
                    Text("Invite Explorer")
                        .foregroundStyle(.white)
                }.padding()
            }
            .navigationTitle("Inventory")
        }
    }
}

#Preview {
    ContentView()
}
