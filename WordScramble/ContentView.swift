//
//  ContentView.swift
//  WordScramble
//
//  Created by karma on 5/10/22.
//

import SwiftUI

struct ContentView: View {
    @State private var rootWord = ""
    @State private var usedWords = [String]()
    @State private var inputWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    
    var body: some View {
        NavigationView{
            List{
                Section{
                    TextField("Enter a word using the root word: ", text: $inputWord)
                        .autocapitalization(.none)
                        
                }
                
                Section{
                    ForEach(usedWords, id: \.self){ word in
                        HStack{
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                        
                    }
                }
            }
            .navigationTitle(rootWord)
            .navigationBarTitleDisplayMode(.large)
            .onSubmit(addWord)
            .alert(errorTitle, isPresented: $showingError){
                Button("OK", role: .cancel){}
            }message: {
                Text(errorMessage)
            }
        }
        .onAppear(perform: startGame)
        
    }
    
    // func to add word
    func addWord(){
        let answer = inputWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else {return}
        guard isOriginal(word: answer) else {
            wordError(title: "Word is already used", message: "Use an unsed word!")
            return }
        guard isPossible(word: answer) else {
            wordError(title: "Word is not possible", message: "Form a word from the letters of \(rootWord)")
            return }
        guard isReal(word: answer) else {
            wordError(title: "Word is not a word", message: "Dumbo!")
            return
        }
        
        withAnimation{
            usedWords.insert(answer, at: 0)
        }
        inputWord = ""
        
        
    }
    
    func startGame(){
        // find the file and load the file from url
        if let startWordUrl = Bundle.main.url(forResource: "start" , withExtension: "txt"){
            // found the file
            if let startWords = try? String(contentsOf: startWordUrl){
                // loaded the file
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
                
            }
        }
        fatalError("could not load start.txt from bundle")
            
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        for letter in word {
            // finding the letter and then removing it from that position
            if let pos = tempWord.firstIndex(of: letter){
                // removing from the temp root letter so that it cant be used agian
                tempWord.remove(at: pos)
            }else{
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool{
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let missspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return missspelledRange.location == NSNotFound
        
    }
    
    
    func wordError(title: String, message: String){
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
