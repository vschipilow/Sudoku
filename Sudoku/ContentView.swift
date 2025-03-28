//
//  ContentView.swift
//  Sudoku
//
//  Created by Victor Schipilow on 24/3/2025.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
//        uiView.load(UR*/LRequest(url: URL(string: "https://victor9.w3spaces.com/sudoku/")!))
        uiView.loadHTMLString(loadHTMLString(), baseURL: nil)
    }
}

// loadHTMLString
struct ContentView: View {
    var body: some View {
        WebView ()
    }
}

func loadHTMLString() -> String {
    return """
    <!DOCTYPE html>
    <html lang="en">
    <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>
        Sudoku
    </title>
    <style>
    :root {
        --color: #EEEEEE;
        --border-color: #777777;
        --background: #222222;
    }
    body {
        font-family: Arial, Helvetica, sans-serif;
        font-size: 100%;
        background: #181800;
        color: var(--color);
    }
    table, td {
        border-style: none;
        border-collapse: collapse;
        text-align: left;
        vertical-align: top;
        border-color: #555555;
    }
    input {
        font-size: 1em;
        background: var(--background);
        border: 1px;
        border-color: var(--border-color);
        border-style: solid;
    }
    input[type=button] {
        color: #00FF00;
    }
    a {
        color: #00B0FF;
    }
    select {
        font-family: Arial, Helvetica, sans-serif;
        font-size: 0.9em;
        background: var(--background);
        color: var(--color);
        border: 1px;
        border-color: var(--color);
        border-style: solid;
    }
    .calculated {
        color: #00CCCC;
    }
    .entered {
        color: #FFFF00;
    }
    </style>
    <script>
    "use strict";

    let ctrl;

    function onload() {
        ctrl = new Control();
        ctrl.changeGrid();
    }

    class Control {
        constructor () {
            this.model = new Model();
            this.view = new View();
        }

        changeGrid() {
            this.model.initialiseGrid(document.getElementById('gridType').value);
            this.view.buildGrid(this.model.size, this.model.width, this.model.height);
        }

        cleanseInput(id, i, j) {
            const convertToNum = (this.model.gridType == '33N');
            const char = this.view.getCleanInput(id, i, j, convertToNum, this.model.pattern);
            this.model.changeInput(char, i, j, id);
            this.view.updateGrid('', this.model.enteredNos, this.model.found, this.model.pattern);
        }

        clearGrid() {
            this.model.clearGrid();
            this.view.clearGrid();
        }

        back() {
            this.view.updateGrid(this.model.back().id, this.model.enteredNos, this.model.found, this.model.pattern);
        }
    }

    class Model {
        initialiseGrid(gridType) {
            this.gridType = gridType;
            this.width = parseInt(gridType[0]);
            this.height = parseInt(gridType[1]);
            this.size = this.width * this.height;
            this.numeric = this.gridType[2] == 'N';
            this.pattern = (this.numeric ? '123456789ABCDEFGHIJK' : 'ABCDEFGHIJKLMNOPQRST').substr(0, this.size);
            this.enteredNos = [];
            for (let i = 0; i < this.size; i++) {
                const row = [];
                for (let j = 0; j < this.size; j++) {
                    row.push(0);
                }
                this.enteredNos.push(row);
            }
            this.entries = [];
        }

        changeInput(char, row, col, id) {
            const num = this.enteredNos[row][col];
            const newNum = (char == '') ? 0 : this.pattern.indexOf(char) + 1;
            if (newNum != num) {
                this.entries.push( { id, row,  col, num } );
                this.enteredNos[row][col] = newNum;
            }
            this.search();
        }

        back() {
            const entry = this.entries.pop();
            if (entry) {
                this.enteredNos[entry.row][entry.col] = entry.num;
                this.search();
                return entry;
            }
            return { id: '' };
        }

        clearGrid(size) {
            this.enteredNos.forEach((value, i) => {
                value.forEach((x, j) => {
                    this.enteredNos[i][j] = 0;
                });
            });
            this.entries = [];
        }

        search() {
            this.found = [];
            for (let i = 0; i < this.size; i++) {
                const foundRow = [];
                for (let j = 0; j < this.size; j++) {
                    let tempInt = this.enteredNos[i][j];
                    foundRow.push(tempInt);
                }
                this.found.push(foundRow);
            }
            this.sudoku();
        }

        sudoku() {
            //
            // "found" contains sudoku 2 dimensional array of numbers
            // if alpha sudoku or numeric sudoku with more than 9 numbers,
            // then alphas have been converted to numbers
            // ie A, B, C, D........ => 1, 2, 3, 4..........
            // or ....8, 9, A, B...... => ...8, 9, 10, 11.....
            //
            // SUDOKU
            //
            let rax;
            let changed = true;
            while (changed) {
                changed = false;
                rax = []; // array of rows
                for (let i = 0; i < this.size; i++) { // for each row
                    let y = []; // array of columns
                    for (let j = 0; j < this.size; j++) { // for each column
                        let z = [];  // list of candidates for given cell
                        if (this.found[i][j] == 0) {
                            for (let n = 1; n <= this.size; n++) {
                                if (this.isValid(i, j, n)) {
                                    // true if "n" does not exist in same row, column and box as cell[i][j]
                                    z.push(n);
                                }
                            }
                        }
                        y.push(z);
                    }
                    rax.push(y);
                }
                for (let i = 0; i < this.size; i++) {
                    for (let j = 0; j < this.size; j++) {
                        // true if number is only valid number in that cell
                        if (rax[i][j].length == 1) {
                            this.found[i][j] = rax[i][j][0];
                            console.log(`${i}, ${j}, ${rax[i][j][0]}`);
                            changed = true;
                            break;
                        }
                    }
                    if (changed) break;
                }
                if (changed == false) {
                    for (let i = 0; i < this.size; i++) {
                        // true if number can only appear once in a row
                        changed = this.check(rax, i, i, 0, this.size - 1);
                        if (changed) break;
                        // true if number can only appear once in a column
                        changed = this.check(rax, 0, this.size - 1, i, i);
                        if (changed) break;
                    }
                }
                if (changed == false) {
                    for (let i = 0; i < this.size; i += this.height) {
                        for (let j = 0; j < this.size; j += this.width) {
                            // true if number can only appear once in a box
                            changed = this.check(rax, i, i + this.height - 1, j, j + this.width - 1);
                            if (changed) break;
                        }
                        if (changed) break;
                    }
                }
            }
        }

        isValid(i, j, n) {
            // true if "n" does not exist in same row, column and box as cell[i, j]
            for (let k = 0; k < this.size; k++) {
                if (this.found[i][k] == n) {
                    return false;
                }
                if (this.found[k][j] == n) {
                    return false;
                }
            }
            // x & y are top left corner of width X height square surrounding cell 'i j'
            let x = Math.trunc(i / this.height) * this.height;
            let y = Math.trunc(j / this.width) * this.width;
            for (let p = x; p < x + this.height; p++) {
                for (let q = y; q < y + this.width; q++) {
                    if (this.found[p][q] == n) {
                        return false;
                    }
                }
            }
            return true;
        }

        check (rax, xFrom, xTo, yFrom, yTo) {
            let foundX = 0;
            let foundY = 0;
            for (let n = 1; n <= this.size; n++) {
                let timesFound = 0;
                for (let i = xFrom; i <= xTo; i++) { // for each row
                    for (let j = yFrom; j <= yTo; j++) { // for each column
                        for (let k = 0; k < rax[i][j].length; k++) { // for each valid value in the cell
                            if (rax[i][j][k] == n) {
                                timesFound++;
                                foundX = i;
                                foundY = j;
                            }
                        }
                    }
                }
                if (timesFound == 1) {
                    this.found[foundX][foundY] = n;
                    console.log(`${foundX}, ${foundY}, ${n}`);
                    return true;
                }
            }
            return false;
        }
    }

    class View {
        constructor() {
            this.gridType = document.getElementById('gridType').value;
        }

        buildGrid (size, width, height) {
            this.size = size;
            this.width = width;
            this.height = height;
            const table = [];
            const platform = window.navigator.platform;
            for (let i = 0; i < size; i++) {
                table.push(`
                    <tr>`);
                for (let j = 0; j < size; j++) {
                    const id = this.createId(i, j);
                    switch (true) {
                        case platform == 'iPhone' && this.gridType == '33N':
                            table.push(`
                                <td style="${this.createBorderStyle(i, j)}">
                                    <input type="number" id="${id}" class="calculated" style="width: 1em"
                                        onkeyup="ctrl.cleanseInput('${id}', ${i}, ${j});" >
                                </td>`);
                            break;
                        case platform == 'iPhone':
                            table.push(`
                                <td style="${this.createBorderStyle(i, j)}">
                                    <input type="text" id="${id}" class="calculated" size="1"
                                        onkeyup="ctrl.cleanseInput('${id}', ${i}, ${j});" >
                                </td>`);
                            break;
                        default:
                            table.push(`
                                <td style="${this.createBorderStyle(i, j)}">
                                    <input type="text" id="${id}" class="calculated" size="2"
                                        onkeyup="ctrl.cleanseInput('${id}', ${i}, ${j});" >
                                </td>`);
                    }
                }
                table.push(`
                    </tr>`);
            }
            const first = Math.trunc(size / 2);
            const last = size - first;
            table.push(`
                <tr>
                    <td colspan="${size}">
                        <br>
                    </td>
                </tr>
                <tr>
                    <td colspan="${first}">
                        <input type="button" onclick="ctrl.clearGrid();" value="Clear">
                    </td>
                    <td colspan="${last}" style="text-align: right;">
                        <input type="button" onclick="ctrl.back();" value="Back">
                    </td>
                </tr>`);
            document.getElementById('table').innerHTML = table.join('');
        }

        getCleanInput(id, i, j, convertToNum, pattern) {
            const char = this.getValue(id);
            document.getElementById(this.createNextId(i, j)).focus();
            if (pattern.includes(char)) {
                this.setValue(id, char, 'entered');
                return char;
            } else if (convertToNum) {
                let tempChar = ('ABCDEFGHI'.indexOf(char) + 1).toString();
                this.setValue(id, tempChar, 'entered');
                return tempChar;
            } else {
                this.setValue(id, '', 'calculated');
                return char;
            }
        }

        updateGrid(id, entered, found, pattern) {
            found.forEach((row, i) => {
                row.forEach((num, j) => {
                    const id = this.createId(i, j);
                    if (num == 0) {
                        this.setValue(id, '', 'calculated');
                    } else {
                        const char = pattern[num - 1];
                        const className = (entered[i][j] == 0) ? 'calculated' : 'entered';
                        this.setValue(id, char, className);
                    }
                });
            });
            if (id) {
                document.getElementById(id).focus();
            }
        }

        clearGrid() {
            for (let i = 0; i < this.size; i++) {
                for (let j = 0; j < this.size; j++) {
                    document.getElementById(this.createId(i, j)).value = '';
                }
            }
        }

        createId(i, j) {
            return String.fromCharCode('a'.charCodeAt(0) + i).concat(j + 1);
        }

        setValue (id, value, className) {
            const input = document.getElementById(id);
            input.value = value;
            input.className = className;
        }

        getValue (id) {
            let tag = document.getElementById(id);
            let char = tag.value.trim();
            if (char == '') {
                return '0';
            } else {
                return char.substr(0, 1).toUpperCase();
            }
        }

        createNextId(i, j) {
            let n = j + 1;
            let m = i;
            if (n >= this.size) {
                n = 0;
                m++;
                if (m >= this.size) {
                    m = 0;
                }
            }
            return this.createId(m, n);
        }

        createBorderStyle (i, j) {
            let left = ((j + 1) % this.width == 1) ? 'solid' : 'hidden';
            let right = ((j + 1) % this.width == 0) ? 'solid' : 'hidden';
            let top = ((i + 1) % this.height == 1) ? 'solid' : 'hidden';
            let bottom = ((i + 1) % this.height == 0) ? 'solid' : 'hidden';
            return `border-style: ${top} ${right} ${bottom} ${left};`;
        }
    }
    </script>
    </head>
    <body onload="onload();">
    <h1>
        Sudoku
    </h1>
    <label for="gridType">
        Value Range:
    </label>
    <select id="gridType" onChange="ctrl.changeGrid();">
        <option value="33N" selected>1..9</option>
        <option value="33A">A..I</option>
        <option value="44N">1..G</option>
        <option value="44A">A..P</option>
        <option value="45N">1..K</option>
        <option value="45A">A..T</option>
    </select>
    <br>
    <br>
    <table id="table">
    </table>
    </body>
    </html>
    """
}

#Preview {
    ContentView()
}
