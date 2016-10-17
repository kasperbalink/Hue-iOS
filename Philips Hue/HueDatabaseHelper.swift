//
//  BridgeViewController.swift
//  Philips Hue
//
//  Created by Kasper Balink on 13/10/2016.
//  Copyright © 2016 Kasper Balink. All rights reserved.
//

import UIKit
import MapKit
import Foundation

class HueDatabaseHelper: NSObject {
    
    // Make the class singleton
    static let sharedInstance = HueDatabaseHelper()
    
    
    
    internal let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
    internal let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
    // Database pointer
    var db : OpaquePointer? = nil
    
    override init() {
        super.init()
        let bundlePathUrl = Bundle.main.url(forResource: "huebridges", withExtension: "sqlite")
        let docPathUrl = getDocumentsDirectory().appendingPathComponent("huebridges.sqlite")
        
        // Copy db file als deze niet bestaat
        if !FileManager.default.fileExists(atPath: docPathUrl.path) {
            try! FileManager.default.copyItem(at: bundlePathUrl!, to: docPathUrl)
        }
        
        // Open vanaf de document directory de db
        if sqlite3_open(docPathUrl.path, &db) != SQLITE_OK {
            print("Error opening database!!")
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0];
    }
    
    
    // Perform query
    func getBridges() -> [HueBridge]? {
        
        var bridges = [HueBridge]()
        
        let query = "SELECT * FROM bridges"
        
        // Prepare query and execute
        var statement : OpaquePointer? = nil
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("error query: \(errmsg)")
            return .none
        }
        
        // Convert results to objects
        while sqlite3_step(statement) == SQLITE_ROW {
            let bridge = HueBridge();
            
            // set bridge values
            bridge.name = String(cString: sqlite3_column_text(statement, 1))
            
            bridge.url = String(cString: sqlite3_column_text(statement, 2))
            
            bridge.apiKey = String(cString: sqlite3_column_text(statement, 3))
            
            // Add to result
            bridges.append(bridge)
        }
        return bridges
    }
    
    func addBridge(url : String, apiKey : String) -> Int
    {
        var returnValue = 1
        print(url)
        print("----------")
        let insertStatementString = "INSERT INTO bridges (name, url, api_key) VALUES (?, ?, ?)"
        var insertStatement: OpaquePointer? = nil
        
        // 1
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            
            // 2
            if(sqlite3_bind_text(insertStatement, 1, url, -1, SQLITE_TRANSIENT) == SQLITE_OK)
            {
                
                if(sqlite3_bind_text(insertStatement, 2, url, -1, SQLITE_TRANSIENT) == SQLITE_OK)
                {
                    if(sqlite3_bind_text(insertStatement, 3, apiKey, -1, SQLITE_TRANSIENT) == SQLITE_OK)
                    {
                        print(insertStatement?.debugDescription.description)
                        print(insertStatementString)
                        print("Binding url and apiKey succesfull")
                        if sqlite3_step(insertStatement) == SQLITE_DONE {
                            print("Successfully inserted row.")
                        } else {
                            print("Could not insert row.")
                            returnValue = 0
                        }
                    }
                    else{
                        print("Binding Api Key failed")
                        returnValue = 0
                    }
                }
                else{
                    print("Binding url failed")
                    returnValue = 0
                }
            }
            else{
                print("Binding name failed")
                returnValue = 0
            }
        } else {
            print("INSERT statement could not be prepared.")
            returnValue = 0
        }
        // 5
        sqlite3_finalize(insertStatement)
        return returnValue
        
    }
    
    func removeBridge(apiKey : String) -> Int
    {
        var returnValue = 1
        let deleteStatementString = "DELETE FROM bridges WHERE api_key = (?)"
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
            
            if(sqlite3_bind_text(deleteStatement, 1, apiKey, -1, SQLITE_TRANSIENT) == SQLITE_OK )
            {
                print("succesful binding \(apiKey)")
                if sqlite3_step(deleteStatement) == SQLITE_DONE
                {
                    print("Successfully deleted row.")
                }
                else
                {
                    print("Could not delete row.")
                    returnValue = 0
                }
            }
            else
            {
                print("could not bind \(apiKey)")
                returnValue = 0
            }
        }
        else
        {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("error query: \(errmsg)")
            print("DELETE statement could not be prepared")
            returnValue = 0
        }        
        sqlite3_finalize(deleteStatement)
        return returnValue
    }
    
    func changeName(apiKey : String, newName : String) -> Int
    {
        var returnValue: Int = 1;
        let changeStatmentString = "UPDATE bridges SET name = (?) WHERE api_key = (?)"
        var changeStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, changeStatmentString, -1, &changeStatement, nil) == SQLITE_OK {
            
            if(sqlite3_bind_text(changeStatement, 1, newName, -1, SQLITE_TRANSIENT) == SQLITE_OK )
            {
                print("succesful binding \(newName)")
                if(sqlite3_bind_text(changeStatement, 2, apiKey, -1, SQLITE_TRANSIENT) == SQLITE_OK )
                {
                    print("succesful binding \(apiKey)")
                    if sqlite3_step(changeStatement) == SQLITE_DONE {
                        print("Successfully canged name.")
                    } else {
                        print("Could not change name.")
                        returnValue =  0
                    }
                }
                else{
                    print("could not bind \(apiKey)")
                    returnValue =  0
                }
                
            }
            else{
                print("could not bind \(newName)")
                returnValue =  0
            }
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("error query: \(errmsg)")
            print("DELETE statement could not be prepared")
            returnValue =  0
        }
        sqlite3_finalize(changeStatement)
        return returnValue;
    }
    
    
    
    
}
