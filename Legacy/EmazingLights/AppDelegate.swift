//
//  AppDelegate.swift
//  EmazingLights
//
//  Created by Kevin Kolasinski on 11/23/15.
//  Copyright © 2015 Emazing Group. All rights reserved.
//

import UIKit
import Parse
import Bolts

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        Parse.setApplicationId("6mqxvJAES068bE4cjh66DH0IfZz8RNkAO54xUWUP",
            clientKey: "Gfntz669hk7D9ji0XSx7gXMXAffAVpshgwVlYLe8")
        
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if(defaults.objectForKey("Settings") == nil || EmazingSettings.settings.clearSettingsOnStart)
        {
            let settings:Settings = Settings()
            EmazingSettings.settings = generateStockData(settings)
            EmazingSettings.settings.save()
        }
        else
        {
            //Load from settings
            let settings:Settings = EmazingSettings.settings.loadCustomObjectWithKey("Settings")
            EmazingSettings.settings = settings
        }
        
        //This initializes the CommManager, which allows for firmware to be checked from Parse
        EmazingCommManager.commManager.initialized = true
        
        return true
    }
    
    func generateStockData(settings:Settings)->Settings
    {
        //MARK: Generate stock colors
        //TODO: Update with stock colors
        let white = Color(red: 224, green: 255, blue: 160, colorRef: 0)
        let blank = Color(red: 0, green: 0, blue: 0, colorRef: 1)
        let red = Color(red: 255, green: 0, blue: 0, colorRef: 2)
        let orange = Color(red: 255, green: 64, blue: 0, colorRef: 3)
        let banyellow = Color(red: 255, green: 160, blue: 0, colorRef: 4)
        let yellow = Color(red: 255, green: 192, blue: 0, colorRef: 5)
        let cosmicowl = Color(red: 255, green: 240, blue: 32, colorRef: 6)
        let lime = Color(red: 255, green: 255, blue: 0, colorRef: 7)
        let limegreen = Color(red: 128, green: 255, blue: 0, colorRef: 8)
        let green = Color(red: 0, green: 255, blue: 0, colorRef: 9)
        let mint = Color(red: 128, green: 255, blue: 96, colorRef: 10)
        let seafoam = Color(red: 0, green: 208, blue: 32, colorRef: 11)
        let turquoise = Color(red: 0, green: 208, blue: 96, colorRef: 12)
        let cyan = Color(red: 0, green: 192, blue: 128, colorRef: 13)
        let lightblue = Color(red: 0, green: 224, blue: 255, colorRef: 14)
        let skyblue = Color(red: 0, green: 96, blue: 255, colorRef: 15)
        let blue = Color(red: 0, green: 0, blue: 255, colorRef: 16)
        let lensflare = Color(red: 64, green: 64, blue: 255, colorRef: 17)
        let purple = Color(red: 48, green: 0, blue: 255, colorRef: 18)
        let lavender = Color(red: 192, green: 96, blue: 255, colorRef: 19)
        let blush = Color(red: 255, green: 64, blue: 160, colorRef: 20)
        let pink = Color(red: 224, green: 0, blue: 96, colorRef: 21)
        let hotpink = Color(red: 224, green: 0, blue: 32, colorRef: 22)
        let lightpink = Color(red: 255, green: 64, blue: 64, colorRef: 23)
        let peach = Color(red: 255, green: 128, blue: 32, colorRef: 24)
        let snarf = Color(red: 255, green: 160, blue: 96, colorRef: 25)
        let warmwhite = Color(red: 255, green: 160, blue: 32, colorRef: 26)
        let silver = Color(red: 160, green: 224, blue: 255, colorRef: 27)
        let luna = Color(red: 128, green: 224, blue: 255, colorRef: 28)
        let tombstone = Color(red: 64, green: 128, blue: 96, colorRef: 29)
        let spaceghost = Color(red: 144, green: 224, blue: 32, colorRef: 30)
        //let color6 = Color(red: 255, green: 255, blue: 0)
        //let color7 = Color(red: 255, green: 0, blue: 255)
        settings.stockColors.append(white)
        settings.stockColors.append(blank)
        settings.stockColors.append(red)
        settings.stockColors.append(orange)
        settings.stockColors.append(banyellow)
        settings.stockColors.append(yellow)
        settings.stockColors.append(cosmicowl)
        settings.stockColors.append(lime)
        settings.stockColors.append(limegreen)
        settings.stockColors.append(green)
        settings.stockColors.append(mint)
        settings.stockColors.append(seafoam)
        settings.stockColors.append(turquoise)
        settings.stockColors.append(cyan)
        settings.stockColors.append(lightblue)
        settings.stockColors.append(skyblue)
        settings.stockColors.append(blue)
        settings.stockColors.append(lensflare)
        settings.stockColors.append(purple)
        settings.stockColors.append(lavender)
        settings.stockColors.append(blush)
        settings.stockColors.append(pink)
        settings.stockColors.append(hotpink)
        settings.stockColors.append(lightpink)
        settings.stockColors.append(peach)
        settings.stockColors.append(snarf)
        settings.stockColors.append(warmwhite)
        settings.stockColors.append(silver)
        settings.stockColors.append(luna)
        settings.stockColors.append(tombstone)
        settings.stockColors.append(spaceghost)
        //settings.stockColors.append(color6)
        //settings.stockColors.append(color7)
        
        /*settings.customColors.append(red)
         settings.customColors.append(green)
         settings.customColors.append(blue)
         settings.customColors.append(color6)
         settings.customColors.append(color7)*/
        
        //MARK: Generate stock palettes
        //TODO: Update with stock palettes
        let basicPalette = Palette(name: "Basic", colors: [white, blank, red, green, blue])
        settings.stockPalettes.append(basicPalette)
        
        //MARK: Generate default flashing patterns
        //TODO: Update with stock flashing patterns
        let fp1 = FlashingPattern(name: "Strobe", imageName: "1-Strobe", code: 1, strobeLength: 5, gapLength: 8)
        let fp2 = FlashingPattern(name: "Hyperstrobe", imageName: "2-Hyperstrobe", code: 2, strobeLength: 16, gapLength: 17)
        let fp3 = FlashingPattern(name: "Dops", imageName: "3-Dops", code: 3, strobeLength: 1, gapLength: 9)
        let fp4 = FlashingPattern(name: "Shadow", imageName: "4-Shadow", code: 4, strobeLength: 1, gapLength: 2)
        let fp5 = FlashingPattern(name: "Strobie", imageName: "5-Strobie", code: 5, strobeLength: 3, gapLength: 23)
        let fp6 = FlashingPattern(name: "Flicker", imageName: "6-Flicker", code: 6, strobeLength: 1, gapLength: 50)
        let fp7 = FlashingPattern(name: "Chroma", imageName: "7-Chroma", code: 7, strobeLength: 9, gapLength: 0)
        let fp8 = FlashingPattern(name: "Tracer", imageName: "8-Tracer", code: 8)
        let fp9 = FlashingPattern(name: "Centerpoint", imageName: "9-Centerpoint", code: 9)
        let fp10 = FlashingPattern(name: "BlinkE", imageName: "10-BlinkE", code: 10)
        let fp11 = FlashingPattern(name: "Ultra Dops", imageName: "11-UltraDops", code: 11)
        let fp12 = FlashingPattern(name: "Inova Blink", imageName: "12-InovaBlink", code: 12)
        let fp13 = FlashingPattern(name: "Strobe Fade", imageName: "13-StrobeFade", code: 13)
        let fp14 = FlashingPattern(name: "Strobe Morph", imageName: "14-StrobeMorph", code:14)
        let fp15 = FlashingPattern(name: "Dash Morph", imageName: "15-DashMorph", code:15)
        let fp16 = FlashingPattern(name: "HeartBeat", imageName: "16-HeartBeat", code:16)
        let fp17 = FlashingPattern(name: "Pulse", imageName: "17-Pulse", code:17)
        let fp18 = FlashingPattern(name: "Shape Shifter", imageName: "18-ShapeShifter", code:18)
        let fp19 = FlashingPattern(name: "Vex", imageName: "19-Vex", code:19)
        let fp20 = FlashingPattern(name: "Krush", imageName: "20-Krush", code:20)
        let fp21 = FlashingPattern(name: "OG Ribbon", imageName: "", code: 21)
        let fp22 = FlashingPattern(name: "Kandi Mode", imageName: "", code: 22)
        let fp23 = FlashingPattern(name: "Candy Strobe", imageName: "", code: 23)
        let fp24 = FlashingPattern(name: "X Change", imageName: "", code: 24)
        let fp25 = FlashingPattern(name: "Matrix Tribbon", imageName: "", code: 25)
        let fp26 = FlashingPattern(name: "X Morph", imageName: "", code: 26)
        let fp27 = FlashingPattern(name: "Dash Dot", imageName: "", code: 27)
        let fp28 = FlashingPattern(name: "Puppet's Pattern", imageName: "", code: 28)
        let fp29 = FlashingPattern(name: "Edge", imageName: "", code: 29)
        let fp30 = FlashingPattern(name: "Dash Dops", imageName: "", code: 30)
        let fp31 = FlashingPattern(name: "Seizure Strobe", imageName: "", code: 31)
        let fp32 = FlashingPattern(name: "Stutter Strobe", imageName: "", code: 32)
        let fp33 = FlashingPattern(name: "Inova Dops", imageName: "", code: 33)
        let fp34 = FlashingPattern(name: "Mini-Edge", imageName: "", code: 34)
        let fp35 = FlashingPattern(name: "VexFlow", imageName: "", code: 35)
        let fp36 = FlashingPattern(name: "Chroma Morph", imageName: "", code: 36)
        let fp37 = FlashingPattern(name: "Chroma Fade", imageName: "", code: 37)
        let fp38 = FlashingPattern(name: "Extended Strobe Fade", imageName: "", code: 38)
        let fp39 = FlashingPattern(name: "Hyper Blink", imageName: "", code: 39)
        let fp40 = FlashingPattern(name: "Heartbeat 1", imageName: "", code: 40)
        let fp41 = FlashingPattern(name: "Heartbeat 2", imageName: "", code: 41)
        let fp42 = FlashingPattern(name: "Heartbeat 3", imageName: "", code: 42)
        let fp43 = FlashingPattern(name: "Onebeat", imageName: "", code: 43)
        let fp44 = FlashingPattern(name: "Fastbeat", imageName: "", code: 44)
        let fp45 = FlashingPattern(name: "IMax Genesis Tribbon", imageName: "", code: 45)
        let fp46 = FlashingPattern(name: "IMax Tracer Strobie", imageName: "", code: 46)
        let fp47 = FlashingPattern(name: "Blending Bliss", imageName: "", code: 47)
        
        settings.stockFlashingPatterns.append(fp1)
        settings.stockFlashingPatterns.append(fp2)
        settings.stockFlashingPatterns.append(fp3)
        settings.stockFlashingPatterns.append(fp4)
        settings.stockFlashingPatterns.append(fp5)
        settings.stockFlashingPatterns.append(fp6)
        settings.stockFlashingPatterns.append(fp7)
        settings.stockFlashingPatterns.append(fp8)
        settings.stockFlashingPatterns.append(fp9)
        settings.stockFlashingPatterns.append(fp10)
        settings.stockFlashingPatterns.append(fp11)
        settings.stockFlashingPatterns.append(fp12)
        settings.stockFlashingPatterns.append(fp13)
        settings.stockFlashingPatterns.append(fp14)
        settings.stockFlashingPatterns.append(fp15)
        settings.stockFlashingPatterns.append(fp16)
        settings.stockFlashingPatterns.append(fp17)
        settings.stockFlashingPatterns.append(fp18)
        settings.stockFlashingPatterns.append(fp19)
        settings.stockFlashingPatterns.append(fp20)
        settings.stockFlashingPatterns.append(fp21)
        settings.stockFlashingPatterns.append(fp22)
        settings.stockFlashingPatterns.append(fp23)
        settings.stockFlashingPatterns.append(fp24)
        settings.stockFlashingPatterns.append(fp25)
        settings.stockFlashingPatterns.append(fp26)
        settings.stockFlashingPatterns.append(fp27)
        settings.stockFlashingPatterns.append(fp28)
        settings.stockFlashingPatterns.append(fp29)
        settings.stockFlashingPatterns.append(fp30)
        settings.stockFlashingPatterns.append(fp31)
        settings.stockFlashingPatterns.append(fp32)
        settings.stockFlashingPatterns.append(fp33)
        settings.stockFlashingPatterns.append(fp34)
        settings.stockFlashingPatterns.append(fp35)
        settings.stockFlashingPatterns.append(fp36)
        settings.stockFlashingPatterns.append(fp37)
        settings.stockFlashingPatterns.append(fp38)
        settings.stockFlashingPatterns.append(fp39)
        settings.stockFlashingPatterns.append(fp40)
        settings.stockFlashingPatterns.append(fp41)
        settings.stockFlashingPatterns.append(fp42)
        settings.stockFlashingPatterns.append(fp43)
        settings.stockFlashingPatterns.append(fp44)
        settings.stockFlashingPatterns.append(fp45)
        settings.stockFlashingPatterns.append(fp46)
        settings.stockFlashingPatterns.append(fp47)
        
        //MARK: Default element sequences
        //let sequence1 = Sequence(flashingPattern: fp1, colorSet: settings.stockColors)
        //let sequence2 = Sequence(flashingPattern: fp2, colorSet: settings.stockColors)
        let elementM1S1 = Sequence(flashingPattern: fp2, colorSet: [silver, tombstone, white])
        let elementM1S2 = Sequence(flashingPattern: fp5, colorSet: [cyan, lavender, tombstone, orange, lime, limegreen])
        let elementM2S1 = Sequence(flashingPattern: fp1, colorSet: [cosmicowl, lensflare, cyan])
        let elementM2S2 = Sequence(flashingPattern: fp1, colorSet: [cosmicowl, lensflare, cyan])
        let elementM3S1 = Sequence(flashingPattern: fp7, colorSet: [lime, lightpink, lightblue, blank, blank, blank, blank])
        let elementM3S2 = Sequence(flashingPattern: fp11, colorSet: [lightpink, lime, lightblue, blank, blank, blank, blank])
        let elementM4S1 = Sequence(flashingPattern: fp10, colorSet: [lightblue, tombstone, snarf, cosmicowl])
        let elementM4S2 = Sequence(flashingPattern: fp1, colorSet: [lightblue, tombstone, snarf, cosmicowl])
        let elementM5S1 = Sequence(flashingPattern: fp5, colorSet: [lensflare, tombstone, blank])
        let elementM5S2 = Sequence(flashingPattern: fp1, colorSet: [lime, white])
        let elementM6S1 = Sequence(flashingPattern: fp5, colorSet: [mint, mint, cyan, cyan, tombstone, tombstone])
        let elementM6S2 = Sequence(flashingPattern: fp3, colorSet: [mint, mint, cyan, cyan, tombstone, tombstone])
        
        //MARK: Default element modes
        let elementMode1 = Mode(name: "FESTIVAL", sequences: [elementM1S1, elementM1S2])
        let elementMode2 = Mode(name: "ALL AROUND", sequences: [elementM2S1, elementM2S2])
        let elementMode3 = Mode(name: "TUTTING", sequences: [elementM3S1, elementM3S2])
        let elementMode4 = Mode(name: "TECH", sequences: [elementM4S1, elementM4S2])
        let elementMode5 = Mode(name: "MUSICALITY", sequences: [elementM5S1, elementM5S2])
        let elementMode6 = Mode(name: "FLOW", sequences: [elementM6S1, elementM6S2])
        settings.stockModes.append(elementMode1)
        settings.stockModes.append(elementMode2)
        settings.stockModes.append(elementMode3)
        settings.stockModes.append(elementMode4)
        settings.stockModes.append(elementMode5)
        settings.stockModes.append(elementMode6)
        
        //MARK: Default CTRL sequences
        //let sequence1 = Sequence(flashingPattern: fp1, colorSet: settings.stockColors)
        //let sequence2 = Sequence(flashingPattern: fp2, colorSet: settings.stockColors)
        let ctrlM1S1 = Sequence(flashingPattern: fp20, colorSet: [banyellow, mint, luna, pink, peach, spaceghost])
        let ctrlM1S2 = Sequence(flashingPattern: fp20, colorSet: [banyellow, mint, luna, pink, peach, spaceghost])
        let ctrlM2S1 = Sequence(flashingPattern: fp1, colorSet: [purple, purple, luna, red])
        let ctrlM2S2 = Sequence(flashingPattern: fp1, colorSet: [purple, purple, luna, red])
        let ctrlM3S1 = Sequence(flashingPattern: fp5, colorSet: [silver, limegreen, red, mint])
        let ctrlM3S2 = Sequence(flashingPattern: fp5, colorSet: [silver, limegreen, red, mint])
        let ctrlM4S1 = Sequence(flashingPattern: fp3, colorSet: [blue, skyblue, turquoise, lightblue, mint, seafoam, luna])
        let ctrlM4S2 = Sequence(flashingPattern: fp3, colorSet: [blue, skyblue, turquoise, lightblue, mint, seafoam, luna])
        let ctrlM5S1 = Sequence(flashingPattern: fp7, colorSet: [warmwhite, lavender, blank, blank, luna, blank, blank])
        let ctrlM5S2 = Sequence(flashingPattern: fp7, colorSet: [warmwhite, lavender, blank, blank, luna, blank, blank])
        let ctrlM6S1 = Sequence(flashingPattern: fp1, colorSet: [mint, mint, cyan, cyan, tombstone, tombstone])
        let ctrlM6S2 = Sequence(flashingPattern: fp1, colorSet: [mint, mint, cyan, cyan, tombstone, tombstone])
        
        //MARK: Default CTRL modes
        let ctrlMode1 = Mode(name: "TOXIC FUSION", sequences: [ctrlM1S1, ctrlM1S2])
        let ctrlMode2 = Mode(name: "OVERCLOCKED", sequences: [ctrlM2S1, ctrlM2S2])
        let ctrlMode3 = Mode(name: "FRAG MODE", sequences: [ctrlM3S1, ctrlM3S2])
        let ctrlMode4 = Mode(name: "CRYO DREAMS", sequences: [ctrlM4S1, ctrlM4S2])
        let ctrlMode5 = Mode(name: "CHROMATECH", sequences: [ctrlM5S1, ctrlM5S2])
        let ctrlMode6 = Mode(name: "COOL CTRL MODE", sequences: [ctrlM6S1, ctrlM6S2])
        settings.stockModes.append(ctrlMode1)
        settings.stockModes.append(ctrlMode2)
        settings.stockModes.append(ctrlMode3)
        settings.stockModes.append(ctrlMode4)
        settings.stockModes.append(ctrlMode5)
        settings.stockModes.append(ctrlMode6)
        
        //MARK: Default chroma24 sequences
        //let sequence1 = Sequence(flashingPattern: fp1, colorSet: settings.stockColors)
        //let sequence2 = Sequence(flashingPattern: fp2, colorSet: settings.stockColors)
        let chroma24M1S1 = Sequence(flashingPattern: fp1, colorSet: [red, limegreen, turquoise, limegreen, turquoise])
        let chroma24M1S2 = Sequence(flashingPattern: fp1, colorSet: [red, limegreen, turquoise, limegreen, turquoise])
        let chroma24M2S1 = Sequence(flashingPattern: fp2, colorSet: [pink, lavender, lightblue, seafoam, mint, limegreen, blush])
        let chroma24M2S2 = Sequence(flashingPattern: fp2, colorSet: [pink, lavender, lightblue, seafoam, mint, limegreen, blush])
        let chroma24M3S1 = Sequence(flashingPattern: fp3, colorSet: [purple, luna, seafoam, peach, red, white])
        let chroma24M3S2 = Sequence(flashingPattern: fp3, colorSet: [purple, luna, seafoam, peach, red, white])
        let chroma24M4S1 = Sequence(flashingPattern: fp5, colorSet: [red, orange, banyellow, limegreen, seafoam, skyblue, purple])
        let chroma24M4S2 = Sequence(flashingPattern: fp5, colorSet: [red, orange, banyellow, limegreen, seafoam, skyblue, purple])
        let chroma24M5S1 = Sequence(flashingPattern: fp7, colorSet: [banyellow, blue, blue, silver, orange, orange])
        let chroma24M5S2 = Sequence(flashingPattern: fp7, colorSet: [banyellow, blue, blue, silver, orange, orange])
        let chroma24M6S1 = Sequence(flashingPattern: fp1, colorSet: [mint, mint, cyan, cyan, tombstone, tombstone])
        let chroma24M6S2 = Sequence(flashingPattern: fp1, colorSet: [mint, mint, cyan, cyan, tombstone, tombstone])
        
        //MARK: Default chroma24 modes
        let chroma24Mode1 = Mode(name: "RAV'N REMAKE", sequences: [chroma24M1S1, chroma24M1S2])
        let chroma24Mode2 = Mode(name: "iMORPH UNITY REMAKE", sequences: [chroma24M2S1, chroma24M2S2])
        let chroma24Mode3 = Mode(name: "STARRY NIGHT", sequences: [chroma24M3S1, chroma24M3S2])
        let chroma24Mode4 = Mode(name: "COLOR WHEEL", sequences: [chroma24M4S1, chroma24M4S2])
        let chroma24Mode5 = Mode(name: "FACEMELT CHROMA", sequences: [chroma24M5S1, chroma24M5S2])
        let chroma24Mode6 = Mode(name: "COOL 24 MODE", sequences: [chroma24M6S1, chroma24M6S2])
        settings.stockModes.append(elementMode1)
        settings.stockModes.append(elementMode2)
        settings.stockModes.append(elementMode3)
        settings.stockModes.append(elementMode4)
        settings.stockModes.append(elementMode5)
        settings.stockModes.append(elementMode6)
        
        //MARK: Default ezlite sequences
        //let sequence1 = Sequence(flashingPattern: fp1, colorSet: settings.stockColors)
        //let sequence2 = Sequence(flashingPattern: fp2, colorSet: settings.stockColors)
        let ezliteM1S1 = Sequence(flashingPattern: fp2, colorSet: [purple, orange, green])
        let ezliteM1S2 = Sequence(flashingPattern: fp2, colorSet: [purple, orange, green])
        let ezliteM2S1 = Sequence(flashingPattern: fp1, colorSet: [pink, yellow, blue])
        let ezliteM2S2 = Sequence(flashingPattern: fp1, colorSet: [pink, yellow, blue])
        let ezliteM3S1 = Sequence(flashingPattern: fp5, colorSet: [mint, silver, blue])
        let ezliteM3S2 = Sequence(flashingPattern: fp5, colorSet: [mint, silver, blue])
        let ezliteM4S1 = Sequence(flashingPattern: fp5, colorSet: [red, orange, banyellow, limegreen, seafoam, skyblue, purple])
        let ezliteM4S2 = Sequence(flashingPattern: fp5, colorSet: [red, orange, banyellow, limegreen, seafoam, skyblue, purple])
        let ezliteM5S1 = Sequence(flashingPattern: fp7, colorSet: [banyellow, blue, blue, silver, orange, orange])
        let ezliteM5S2 = Sequence(flashingPattern: fp7, colorSet: [banyellow, blue, blue, silver, orange, orange])
        let ezliteM6S1 = Sequence(flashingPattern: fp1, colorSet: [mint, mint, cyan, cyan, tombstone, tombstone])
        let ezliteM6S2 = Sequence(flashingPattern: fp1, colorSet: [mint, mint, cyan, cyan, tombstone, tombstone])
        
        //MARK: Default ezlite modes
        let ezliteMode1 = Mode(name: "HYPER STROBE", sequences: [ezliteM1S1, ezliteM1S2])
        let ezliteMode2 = Mode(name: "STROBE", sequences: [ezliteM2S1, ezliteM2S2])
        let ezliteMode3 = Mode(name: "STROBIE", sequences: [ezliteM3S1, ezliteM3S2])
        let ezliteMode4 = Mode(name: "COOL EZLITE MODE 1", sequences: [ezliteM4S1, ezliteM4S2])
        let ezliteMode5 = Mode(name: "COOL EZLITE MODE 2", sequences: [ezliteM5S1, ezliteM5S2])
        let ezliteMode6 = Mode(name: "COOL EZLITE MODE 3", sequences: [ezliteM6S1, ezliteM6S2])
        settings.stockModes.append(elementMode1)
        settings.stockModes.append(elementMode2)
        settings.stockModes.append(elementMode3)
        settings.stockModes.append(elementMode4)
        settings.stockModes.append(elementMode5)
        settings.stockModes.append(elementMode6)
        
        //MARK: Default enova sequences
        //let sequence1 = Sequence(flashingPattern: fp1, colorSet: settings.stockColors)
        //let sequence2 = Sequence(flashingPattern: fp2, colorSet: settings.stockColors)
        let enovaM1S1 = Sequence(flashingPattern: fp7, colorSet: [red, green, blue])
        let enovaM1S2 = Sequence(flashingPattern: fp7, colorSet: [red, green, blue])
        let enovaM2S1 = Sequence(flashingPattern: fp3, colorSet: [red, green, blue])
        let enovaM2S2 = Sequence(flashingPattern: fp3, colorSet: [red, green, blue])
        let enovaM3S1 = Sequence(flashingPattern: fp12, colorSet: [red, green, blue])
        let enovaM3S2 = Sequence(flashingPattern: fp12, colorSet: [red, green, blue])
        let enovaM4S1 = Sequence(flashingPattern: fp5, colorSet: [red, orange, banyellow, limegreen, seafoam, skyblue, purple])
        let enovaM4S2 = Sequence(flashingPattern: fp5, colorSet: [red, orange, banyellow, limegreen, seafoam, skyblue, purple])
        let enovaM5S1 = Sequence(flashingPattern: fp7, colorSet: [banyellow, blue, blue, silver, orange, orange])
        let enovaM5S2 = Sequence(flashingPattern: fp7, colorSet: [banyellow, blue, blue, silver, orange, orange])
        let enovaM6S1 = Sequence(flashingPattern: fp1, colorSet: [mint, mint, cyan, cyan, tombstone, tombstone])
        let enovaM6S2 = Sequence(flashingPattern: fp1, colorSet: [mint, mint, cyan, cyan, tombstone, tombstone])
        
        //MARK: Default enova modes
        let enovaMode1 = Mode(name: "CHROMA", sequences: [enovaM1S1, enovaM1S2])
        let enovaMode2 = Mode(name: "DOPS", sequences: [enovaM2S1, enovaM2S2])
        let enovaMode3 = Mode(name: "iNOVA BLINK", sequences: [enovaM3S1, enovaM3S2])
        let enovaMode4 = Mode(name: "COOL ENOVA MODE 1", sequences: [enovaM4S1, enovaM4S2])
        let enovaMode5 = Mode(name: "COOL ENOVA MODE 2", sequences: [enovaM5S1, enovaM5S2])
        let enovaMode6 = Mode(name: "COOL ENOVA MODE 3", sequences: [enovaM6S1, enovaM6S2])
        settings.stockModes.append(elementMode1)
        settings.stockModes.append(elementMode2)
        settings.stockModes.append(elementMode3)
        settings.stockModes.append(elementMode4)
        settings.stockModes.append(elementMode5)
        settings.stockModes.append(elementMode6)
        
        //MARK: Default flow sequences
        //let sequence1 = Sequence(flashingPattern: fp1, colorSet: settings.stockColors)
        //let sequence2 = Sequence(flashingPattern: fp2, colorSet: settings.stockColors)
        let flowM1S1 = Sequence(flashingPattern: fp7, colorSet: [red, green, blue])
        let flowM1S2 = Sequence(flashingPattern: fp7, colorSet: [red, green, blue])
        let flowM2S1 = Sequence(flashingPattern: fp17, colorSet: [red, green, blue])
        let flowM2S2 = Sequence(flashingPattern: fp17, colorSet: [red, green, blue])
        let flowM3S1 = Sequence(flashingPattern: fp15, colorSet: [red, green, blue])
        let flowM3S2 = Sequence(flashingPattern: fp15, colorSet: [red, green, blue])
        let flowM4S1 = Sequence(flashingPattern: fp13, colorSet: [red, orange, blue])
        let flowM4S2 = Sequence(flashingPattern: fp13, colorSet: [red, orange, blue])
        let flowM5S1 = Sequence(flashingPattern: fp14, colorSet: [red, green, blue])
        let flowM5S2 = Sequence(flashingPattern: fp14, colorSet: [red, green, blue])
        let flowM6S1 = Sequence(flashingPattern: fp18, colorSet: [red, green, blue])
        let flowM6S2 = Sequence(flashingPattern: fp18, colorSet: [red, green, blue])
        
        //MARK: Default flow modes
        let flowMode1 = Mode(name: "CHROMA", sequences: [flowM1S1, flowM1S2])
        let flowMode2 = Mode(name: "PULSE", sequences: [flowM2S1, flowM2S2])
        let flowMode3 = Mode(name: "DASH MORPH", sequences: [flowM3S1, flowM3S2])
        let flowMode4 = Mode(name: "STROBE FADE", sequences: [flowM4S1, flowM4S2])
        let flowMode5 = Mode(name: "STROBE MORPH", sequences: [flowM5S1, flowM5S2])
        let flowMode6 = Mode(name: "SHAPESHIFTER", sequences: [flowM6S1, flowM6S2])
        settings.stockModes.append(elementMode1)
        settings.stockModes.append(elementMode2)
        settings.stockModes.append(elementMode3)
        settings.stockModes.append(elementMode4)
        settings.stockModes.append(elementMode5)
        settings.stockModes.append(elementMode6)
        
        let testPalette = Palette(name: "Test Palette", colors: [red, green, blue, yellow, hotpink, lensflare, skyblue, cyan, turquoise, orange])
        settings.customPalettes.append(testPalette)
        
        let elementFinger = Finger(modes: [elementMode1, elementMode2, elementMode3, elementMode4, elementMode5, elementMode6], defaultPalette: testPalette)
        let ctrlFinger = Finger(modes: [ctrlMode1, ctrlMode2, ctrlMode3, ctrlMode4, ctrlMode5, ctrlMode6], defaultPalette: testPalette)
        let chroma24Finger = Finger(modes: [chroma24Mode1, chroma24Mode2, chroma24Mode3, chroma24Mode4, chroma24Mode5, chroma24Mode6], defaultPalette: testPalette)
        let ezliteFinger = Finger(modes: [ezliteMode1, ezliteMode2, ezliteMode3, ezliteMode4, ezliteMode5, ezliteMode6], defaultPalette: testPalette)
        let enovaFinger = Finger(modes: [enovaMode1, enovaMode2, enovaMode3, enovaMode4, enovaMode5, enovaMode6], defaultPalette: testPalette)
        let flowFinger = Finger(modes: [flowMode1, flowMode2, flowMode3, flowMode4, flowMode5, flowMode6], defaultPalette: testPalette)
        
        //MARK: Disable Finger defaults here
        ctrlFinger.disabledModes[5] = true
        chroma24Finger.disabledModes[5] = true
        ezliteFinger.disabledModes[3] = true
        ezliteFinger.disabledModes[4] = true
        ezliteFinger.disabledModes[5] = true
        enovaFinger.disabledModes[3] = true
        enovaFinger.disabledModes[4] = true
        enovaFinger.disabledModes[5] = true
        
        settings.stockChips.append(Chip(name: "Element", imageName: "element", finger: elementFinger, tags: ["Motion", "Favorites"]))
        settings.stockChips.append(Chip(name: "Chroma 24", imageName: "chroma", finger: chroma24Finger, tags: ["Favorites"]))
        settings.stockChips.append(Chip(name: "ChromaCTRL", imageName: "chromactrl", finger: ctrlFinger, tags: ["Favorites"]))
        settings.stockChips.append(Chip(name: "Flow", imageName: "flow", finger: flowFinger, tags: ["Favorites"]))
        settings.stockChips.append(Chip(name: "EZLite 2.0", imageName: "ezlite", finger: ezliteFinger, tags: ["Classic"]))
        settings.stockChips.append(Chip(name: "eNOVA", imageName: "enova", finger: enovaFinger, tags: ["Classic"]))
        
        
        
        
        
        
        
        
        
        let elementGloveL = Hand(handID: 0, emotion: 0, fingers: [elementFinger.copyObject(), elementFinger.copyObject(), elementFinger.copyObject(), elementFinger.copyObject(), elementFinger.copyObject()])
        let elementGloveR = Hand(handID: 1, emotion: 0, fingers: [elementFinger.copyObject(), elementFinger.copyObject(), elementFinger.copyObject(), elementFinger.copyObject(), elementFinger.copyObject()])
        
        //MARK: Generate default glove sets
        //TODO: Update with stock glove sets
        settings.stockGloveSets.append(GloveSet(name: "Element", imageName: "element", glovePair: [elementGloveL.copyObject(), elementGloveR.copyObject()], tags: ["Motion", "Favorites"]))
        settings.stockGloveSets.append(GloveSet(name: "Chroma 24", imageName: "chroma", glovePair: [elementGloveL.copyObject(), elementGloveR.copyObject()], tags: ["Favorites"]))
        settings.stockGloveSets.append(GloveSet(name: "ChromaCTRL", imageName: "chromactrl", glovePair: [elementGloveL.copyObject(), elementGloveR.copyObject()], tags: ["Favorites"]))
        settings.stockGloveSets.append(GloveSet(name: "Flow", imageName: "flow", glovePair: [elementGloveL.copyObject(), elementGloveR.copyObject()], tags: ["Favorites"]))
        settings.stockGloveSets.append(GloveSet(name: "EZLite 2.0", imageName: "ezlite", glovePair: [elementGloveL.copyObject(), elementGloveR.copyObject()], tags: ["Classic"]))
        settings.stockGloveSets.append(GloveSet(name: "eNOVA", imageName: "enova", glovePair: [elementGloveL.copyObject(), elementGloveR.copyObject()], tags: ["Classic"]))
        
        return settings

    }
    
    //MARK: - Push Notifications
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let currentInstallation:PFInstallation = PFInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
        
        //Not using currently
        //currentInstallation.channels = ["Global"]
        
        currentInstallation.saveInBackground()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Failed to register for remote notifications")
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        //TODO: Test
        let toBeRemoved:String = userInfo["sentBy"] as! String
        var detail: String = userInfo["alert"]!["body"]!!.stringByReplacingOccurrencesOfString(toBeRemoved, withString: "")
        //[MPNotificationView notifyWithText:userInfo[@"sentBy"] andDetail:detail];
        NSNotificationCenter.defaultCenter().postNotificationName("BCBlastchatDidReceivePushNotification", object: self, userInfo: userInfo)
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        let currentInstallation: PFInstallation = PFInstallation.currentInstallation()
        if currentInstallation.badge != 0 {
            currentInstallation.badge = 0
            currentInstallation.saveEventually()
        }

    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

