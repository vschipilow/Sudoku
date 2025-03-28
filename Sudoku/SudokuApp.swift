//
//  SudokuApp.swift
//  Sudoku
//
//  Created by Victor Schipilow on 24/3/2025.
//

/* git doco
// square brackets are not part of valid command syntax.
// square brackets are just used to signify options
// git username = vschipilow //
git config [--global] user.name "Victor Schipilow" // display name?
git config [--global] user.email "victorschipilow@icloud.com"
git init // create repository
git add file_name    // add single file to staged environment
git add --all        // add all files in directory according to .gitignore
git commit -m "commit message"
git commit -a -m "commit message" // stages change and commits in one operation
git status [--short]
git fetch origin
 
 // 
git remote add origin https://github.com/vschipilow/Sudoku.git
git branch -M main
git push -u origin main
 
// end git doco */

import SwiftUI

@main
struct SudokuApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
