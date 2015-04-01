//
//  ViewController.swift
//  TouchIDDemo
//
//  Created by Ziyang Tan on 4/1/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit
import LocalAuthentication

class ViewController: UIViewController, UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource, EditNoteViewControllerDelegate {

    @IBOutlet var tblNotes: UITableView!
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    var dataArray: NSMutableArray = NSMutableArray()
    var noteIndextoEdit: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblNotes.delegate = self
        tblNotes.dataSource = self
        authenticateUser()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData() {
        if appDelegate.checkIfDataFileExists() {
            self.dataArray = NSMutableArray(contentsOfFile: appDelegate.getPathOfDataFile())!
            self.tblNotes.reloadData()
        } else {
            println("File does not exist")
        }
    }
    
    func authenticateUser() {
        let context = LAContext()
        
        var error: NSError?
        
        var reasonString = "Authentication is needed to access your notes"
        
        if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString, reply: {
                (success: Bool, evalPolicyError: NSError?) -> Void in
                if success {
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        self.loadData()
                    })
                } else {
                    println(evalPolicyError?.localizedDescription)
                    
                    switch evalPolicyError!.code {
                    case LAError.SystemCancel.rawValue:
                        println("Authentication was cancelled by the system")
                    case LAError.UserCancel.rawValue:
                        println("Authentication was cancelled by the uesr")
                    case LAError.UserFallback.rawValue:
                        println("User selected to enter custom password")
                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            () -> Void in
                            self.showPasswordAlert()
                        })
                    default:
                        println("Authentication failed")
                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            () -> Void in
                            self.showPasswordAlert()
                        })
                    }
                }
            })
        } else {
            switch error!.code {
            case LAError.TouchIDNotEnrolled.rawValue:
                println("Touch ID is not enrolled")
            case LAError.PasscodeNotSet.rawValue:
                println("A passcode has not been set")
            default:
                println("TouchID not available")
            }
            
            println(error?.localizedDescription)
            self.showPasswordAlert()
        }
    }

    func showPasswordAlert() {
        var passwordAlert: UIAlertView = UIAlertView(title: "TouchDemo", message: "Please type your password", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Okay")
        passwordAlert.alertViewStyle = .SecureTextInput
        passwordAlert.show()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            if !alertView.textFieldAtIndex(0)!.text.isEmpty {
                if alertView.textFieldAtIndex(0)!.text == "appcoda" {
                    loadData()
                } else {
                    showPasswordAlert()
                }
            } else {
                showPasswordAlert()
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("idCell") as UITableViewCell
        let currentNote = self.dataArray.objectAtIndex(indexPath.row) as Dictionary<String, String>
        cell.textLabel?.text = currentNote["title"]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        noteIndextoEdit = indexPath.row
        
        performSegueWithIdentifier("idSegueEditNote", sender: self)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            dataArray.removeObjectAtIndex(indexPath.row)
            
            dataArray.writeToFile(appDelegate.getPathOfDataFile(), atomically: true)
        
            tblNotes.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "idSegueEditNote" {
            var editNoteViewController: EditNoteViewController = segue.destinationViewController as EditNoteViewController
            editNoteViewController.delegate = self
            
            if (noteIndextoEdit != nil) {
                editNoteViewController.indexOfEditedNote = noteIndextoEdit
                
                noteIndextoEdit = nil
            }
        }
    }
    
    func noteWasSaved() {
        loadData()
    }

}

