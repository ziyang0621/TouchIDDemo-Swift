//
//  EditNoteViewController.swift
//  TouchIDDemo
//
//  Created by Ziyang Tan on 4/1/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

protocol EditNoteViewControllerDelegate{
    func noteWasSaved()
}

class EditNoteViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var txtNoteTitle: UITextField!
    @IBOutlet var tvNoteBody: UITextView!
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    var delegate : EditNoteViewControllerDelegate?
    var indexOfEditedNote : Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.txtNoteTitle.becomeFirstResponder()
        txtNoteTitle.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        if (indexOfEditedNote != nil) {
            editNote()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        tvNoteBody.becomeFirstResponder()
        
        return true
    }
    
    func editNote() {
        var notesArray = NSArray(contentsOfFile: appDelegate.getPathOfDataFile())!
        
        let noteDict = notesArray.objectAtIndex(indexOfEditedNote) as Dictionary<String, String>
        
        txtNoteTitle.text = noteDict["title"]
        
        tvNoteBody.text = noteDict["body"]
    }

    @IBAction func saveNote(sender: AnyObject) {
        if self.txtNoteTitle.text.isEmpty {
            println("No title for the note was typed")
            return
        }
        
        var noteDict = ["title": self.txtNoteTitle.text, "body": self.tvNoteBody.text]
        
        var dataArray: NSMutableArray
        
        if appDelegate.checkIfDataFileExists() {
            dataArray = NSMutableArray(contentsOfFile: appDelegate.getPathOfDataFile())!
            
            if indexOfEditedNote == nil {
                dataArray.addObject(noteDict)
            } else {
                dataArray.replaceObjectAtIndex(indexOfEditedNote, withObject: noteDict)
            }
        } else {
            dataArray = NSMutableArray(object: noteDict)
        }
        
        dataArray.writeToFile(appDelegate.getPathOfDataFile(), atomically: true)
        
        delegate?.noteWasSaved()
        
        self.navigationController!.popViewControllerAnimated(true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
