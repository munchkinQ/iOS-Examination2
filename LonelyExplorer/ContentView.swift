//
//  ContentView.swift
//  LonelyExplorer
//
//  Created by Åsa Östmark on 2024-09-25.
//

import SwiftUI


//structs

struct Building {
    var name: String
    var baseCost: [String: Double]
    var costMultiplier: Double
    var owned: Int
    var productionRate: Double?
    var resourceProduced: String?
}

struct Resource {
    var name: String
    var amount: Double
    var ratePerSecond: Double
    var maxAmount: Double?
}

struct Research {
    var name: String
    var cost: Double
    var isUnlocked: Bool
}

struct Material {
    var name: String
    var amount: Double
    var cost: [String : Double]
    var maxAmount: Double?
}

//dictionaries

var resources: [String: Resource] = [
    "wood": Resource(name: "Wood", amount: 0, ratePerSecond: 0.5, maxAmount: 250),
    "stone": Resource(name: "Stone", amount: 0, ratePerSecond: 0.5, maxAmount: 250),
    "clay": Resource(name: "Clay", amount: 0, ratePerSecond: 0.5, maxAmount: 250),
    "iron": Resource(name: "Iron", amount: 0, ratePerSecond: 0.5, maxAmount: 100),
    "coal": Resource(name: "Coal", amount: 0, ratePerSecond: 0.1, maxAmount: 50),
    "happiness": Resource(name: "Happiness", amount: 0, ratePerSecond: 0.5, maxAmount: 250)
]

var buildings: [String: Building] = [
    "home": Building(name: "Home", baseCost: ["wood" : 100, "clay" : 100], costMultiplier: 2, owned: 0, productionRate: 0.5, resourceProduced: "happiness"),
    "warehouse": Building(name: "Warehouse", baseCost: ["beam" : 1, "slab" : 1, "bar" : 1, "brick" : 10], costMultiplier: 2, owned: 0, productionRate: nil, resourceProduced: nil),
    "woodcutter": Building(name: "Woodcutter", baseCost: ["beam" : 1, "slab" : 1, "bar" : 1], costMultiplier: 0.1, owned: 0, productionRate: 0.5, resourceProduced: "wood"),
    "miner": Building(name: "Miner", baseCost: ["beam" : 1, "slab" : 1, "bar" : 1], costMultiplier: 0.1, owned: 0, productionRate: 0.5, resourceProduced: "stone"),
    "constructer": Building(name: "Constructor", baseCost: ["wood" : 100, "stone" : 100, "iron" : 50], costMultiplier: 0, owned: 0, productionRate: nil, resourceProduced: nil)
]

var materials: [String: Material] = [
    "beam": Material(name: "Wooden Beam", amount: 0, cost: ["wood" : 100], maxAmount: 50),
    "slab": Material(name: "Stone Slab", amount: 0, cost: ["stone" : 100], maxAmount: 50),
    "bar": Material(name: "Iron Bar", amount: 0, cost: ["iron" : 100], maxAmount: 25),
    "ingot": Material(name: "Steel Ingot", amount: 0, cost: ["steel" : 100], maxAmount: 10),
    "brick": Material(name: "Brick", amount: 0, cost: ["clay" : 10], maxAmount: 100)
    
    
]

var explorer = 1


//functions

func purchaseBuilding() {
    //
}

func inviteExplorer() {
    let homes = buildings["home"]?.owned ?? 0
    if homes > explorer && resources["happiness"]?.amount ?? 0 >= 100 {
        explorer += 1
        resources["happiness"]?.amount -= 100
    }
}

func research() {
    //
}


//cview

struct ContentView: View {
    var body: some View {
        
        ZStack { //need dark mode asw.
            Color(hue: 0.1, saturation: 0.5, brightness: 0.3, opacity: 0.4)
                .ignoresSafeArea(.all)
            
            VStack {
                Text("Lonely Explorer")
                    .foregroundColor(Color(hue: 0.34, saturation: 1.0, brightness: 0.2, opacity: 0.8))
                    .font(.largeTitle)
                
                HStack {
                    Button(action: {
                        resources["wood"]?.amount += 1
                        print("\(resources["wood"]?.amount ?? 0) wood")
                    }, label: {
                        Image("axe")
                            .resizable()
                            .frame(width: 100)
                            .frame(height: 100)
                    })
                    Button(action: {
                        resources["stone"]?.amount += 1
                        print("\(resources["stone"]?.amount ?? 0) stone")
                        if Double.random(in: 0..<1) < 0.05 {
                            resources["coal"]?.amount += 1
                            print("\(resources["coal"]?.amount ?? 0) coal")
                        }
                    }, label: {
                        Image("pickaxe")
                            .resizable()
                            .frame(width: 100)
                            .frame(height: 100)
                    })
                    
                }
                HStack {
                    Button(action: {
                        resources["iron"]?.amount += 1
                        print("\(resources["iron"]?.amount ?? 0) iron")
                    }, label: {
                        Image("drill")
                            .resizable()
                            .frame(width: 100)
                            .frame(height: 100)
                    })
                    Button(action: {
                        resources["clay"]?.amount += 1
                        print("\(resources["clay"]?.amount ?? 0) clay")
                    }, label: {
                        Image("shovel")
                            .resizable()
                            .frame(width: 100)
                            .frame(height: 100)
                        
                    })
                }
                
            }
            
        }
        //Spacer()
    }
}

#Preview {
    ContentView()
}



/**
 
 You are a lonely explorer, who has set off in search of a new planet to build a colony on. When you land, you will need to start gathering resources so that you can survive.
 
 Resources/Materials:
 - wood
 - stone
 - coal
 - iron
 - steel
 - clay
 - more...
 
 Buildings/Upgrades:
 - warehouse
 - home
 - furnace
 - factory
 - automatic miner
 - woodcutting machine
 - constructor
 - lab
 - more...
 
 You start with some basic tools, if you click on the tool it will start to generate 1 of the resource for each click. For example, if you click te axe you will receive wood, if you click the pickaxe you will get stone, and ocationally coal, if you click the drill you will receive iron, the shovel will get you clay (tools will later be upgradeable with iron, steel, alien metals, etc...)
 
 For 50 wood and 50 clay, you can build your first home. This will generate happiness, very slowly. Happiness makes it so that your tools are more efficient, at certain milestones. You can spend happiness on stuff as well.
 
 For 100 stone, 100 iron, 10 coal and 100 wood you can build an automatic miner. This will mine stone, and coal for you with a rate of 0.5 per second. Each miner will generate the same amount.
 
 For 10 steel you can create a steel ingot.
 
 For 100 wood you can create a wooden beam.
 For 100 stone you can create a stone slab.
 For 100 iron you can create a metal bar.
 For 10 clay you can create a brick.
 
 Your first warehouse will cost you 1 beam, 1 slab, 1 bar and 10 bricks.
 Each warehouse doubles the cost.
 
 For 100 happiness you can start researching steel production.
 For 50 happiness you can start researching the automatic miner.
 For 10 happiness you can start researching the woodcutting machine.
 More happiness-based researches will be added as well...
 
 Wood is used to heat up the home(s), at a rate of 0.1 per second per home.
 
 For 250 happiness you can start researching a constructor.
 For 100 happiness, you can invite a fellow explorer to join your colony.
 Each explorer doubles in price.
 
 Each explorer needs a home.
 
 Each explorer generates happiness if in a heated home.
 
 For 500 happiness you can start researching science, unlocking a building where you can do different research, not linked to the colony per se but more scienc-y things.
 
 This will make it so that explorers can become scientists. Scientists will generate less happiness, but will start generating science instead.
 
 Science can be used to unlock researches in the lab.
 
 For 10 science you can research a second scientist.
 For 25 science you can research improved woodcutting.
 For 50 science you can research improved mining.
 For 100 science you can research alien flora.
 For 100 science you can research alien fauna.
 For 200 science & 100 alien knowledge you can research alien megaflora.
 For 200 science & 100 alien knowledge you can research alien megafauna.
 
 Researching both alien floara & fauna will unlock the alien research lab building.
 This will make it so that an explorer can be assignes to an alien researcher, which will make it so that they generate less happiness, but will instead generate alien knowledge.
 
 Researching both megaflora and megafauna will let you buy upgrades to the alien resear h lab, letting more explorers become alien researchers and generate more knowledge.
 
 Eventually, for 1000 science, 1000 alien knowledge, 1000 happiness, 20 metal bars, 10 wooden beams & 50 ingots you can research and build an alien transponder/translater.
 
 This will unlock alien communication and will make it so that you can send out explorers to find alien civilizations to trade with. This will not cost anything, but the explorers that are sent out will not be generating any happiness.
 
 To be able to trade you will need to research and build a certain type of extractor, that extracts an alien material out of the earth, do not know what to call it. This will be used as an alien currency in any case and will need to be manned by an explorer, who will not be producing happiness while working as only explorers do, and only explorers in a heated house not currently out on an expedition.
 
 
 
 This is the FULL applikation, examinationsuppgift kommer bara gå fram till och med happiness-researcharna.
 
 */





/*
 
 */
