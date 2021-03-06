//
//  ConfirmViewController.swift
//  TINU
//
//  Created by Pietro Caruso on 26/08/17.
//  Copyright © 2017 Pietro Caruso. All rights reserved.
//

import Cocoa

class ConfirmViewController: GenericViewController {
    
    @IBOutlet weak var driveName: NSTextField!
    @IBOutlet weak var driveImage: NSImageView!
    
    @IBOutlet weak var appImage: NSImageView!
    @IBOutlet weak var appName: NSTextField!
    
    @IBOutlet weak var warning: NSImageView!
    
    @IBOutlet weak var warningField: NSTextField!
    
    @IBOutlet weak var errorLabel: NSTextField!
    @IBOutlet weak var errorImage: NSImageView!
    
    
    var notDone = false
    
    private var ps: Bool!
    //private var fs: Bool!
    override func viewDidAppear() {
        super.viewDidAppear()
        
        if let w = sharedWindow{
            w.isMiniaturizeEnaled = true
            w.isClosingEnabled = true
            w.canHide = true
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        errorImage.isHidden = true
        errorLabel.isHidden = true
        
        if sharedInstallMac{
            warningField.stringValue = "If you go ahead, this app will modify the drive you selected, and macOS will be installed on it, if you are sure, continue at your own risk."
            
            if let f = sharedVolumeNeedsPartitionMethodChange{
                if f{
                    warningField.stringValue = "If you go ahead, this app will erase the entire drive you selected and all the data on it will be lost, if you are, continue at you own risk"
                }
            }
            
        }
        
        warning.image = warningIcon
        
        ps = sharedVolumeNeedsPartitionMethodChange
        //fs = sharedVolumeNeedsFormat
        
        if let a = NSApplication.shared().delegate as? AppDelegate{
            a.QuitMenuButton.isEnabled = true
        }
        
        notDone = false
        
        if let sa = sharedApp{
            print(sa)
            appImage.image = getInstallerAppIcon(forApp: sa)
            appName.stringValue = FileManager.default.displayName(atPath: sa)
            print("Installation app that will be used is: " + sa)
        }else{
            notDone = true
        }
        
        
        
        if let sv = sharedVolume{
            print(sv)
            var sr = sv
            
            
            if !FileManager.default.fileExists(atPath: sv){
                if let sb = sharedBSDDrive{
                    if let sd = getDriveNameFromBSDID(sb){
                        sr = sd
                        sharedVolume = sr
                    }else{
                        notDone = true
                    }
                    
                    
                    print("corrected the name of the target volume" + sr)
                }else{
                    notDone = true
                }
            }
            
            driveImage.image = NSWorkspace.shared().icon(forFile: sr)
            driveName.stringValue = FileManager.default.displayName(atPath: sr)
            
            print("The target volume is: " + sr)
        }else{
            notDone = true
        }
        
        //just to simulate a failure to get data for the drive and the app
        if simulateConfirmGetDataFail{
            notDone = true
        }
        
        if notDone {
            print("Couldn't get valid info about the installation app and/or the drive")
            //yes.isEnabled = false
            
            yes.title = "Quit"
            info.isHidden = true
            
            driveName.isHidden = true
            driveImage.isHidden = true
            
            appImage.isHidden = true
            appName.isHidden = true
            
            self.warning.isHidden = true
            
            errorImage.image = warningIcon
            
            errorImage.isHidden = false
            errorLabel.isHidden =  false
            
            titleLabel.stringValue = "Impossible to create the macOS install meadia"
            
            /*let label = NSTextField(frame: NSRect(x: titleLabel.frame.origin.x, y: self.view.frame.size.height / 2 - 15, width: titleLabel.frame.size.width, height: 30))
            label.isEditable = false
            label.isBordered = false
            label.font = NSFont.systemFont(ofSize: 25)
            label.stringValue = "There was an error while getting app and drive data 🙁"
            label.alignment = .center
            label.isSelectable = false
            label.drawsBackground = false
            
            self.view.addSubview(label)*/
        }else{
            print("Everything is ready to start the installer creation process")
        }
        
    }
    
    @IBOutlet weak var info: NSTextField!
    @IBOutlet weak var yes: NSButton!
    @IBOutlet weak var titleLabel: NSTextField!
    
    @IBAction func goBack(_ sender: Any) {
        sharedVolumeNeedsPartitionMethodChange = ps
        //sharedVolumeNeedsFormat = fs
        /*if sharedInstallMac{
            openSubstituteWindow(windowStoryboardID: "ChoseApp", sender: sender)
		}else{*/
		if sharedMediaIsCustomized{
			openSubstituteWindow(windowStoryboardID: "Customize", sender: sender)
		}else{
            openSubstituteWindow(windowStoryboardID: "ChooseCustomize", sender: sender)
		}
        //}
    }
    
    @IBAction func install(_ sender: Any) {
        sharedVolumeNeedsPartitionMethodChange = ps
        //sharedVolumeNeedsFormat = fs
        if notDone{
            NSApp.terminate(sender)
            return
        }
        
        let _ = openSubstituteWindow(windowStoryboardID: "Install", sender: sender)
        
    }
    
}
