## Advent of Code 2020
## Solutions implemented in Nim Programming Language (www.nim-lang.org)
## Day 11: Seating System
## https://adventofcode.com/2020/day/10
##
## Resources:
## Streams: https://nim-lang.org/docs/streams.html#15
## Array and Sequence Types: https://nim-lang.org/docs/manual.html#types-array-and-sequence-types
## Parseutils: https://nim-lang.org/docs/parseutils.html
## Parsing input: https://old.reddit.com/r/nim/comments/k22h74/advent_of_nim_2020/gealoo3/
## Regular Expressions: https://nim-lang.org/docs/re.html


import algorithm
import os
import sequtils
import streams
import strformat
import strutils



type
    # the state of each element in the field/grid
    EState = enum
        empty, occupied, keepout

    SimState = object
        width, height: int
        iteration, changed, occupied: int
        field: seq[EState]


const
    input_url = "https://adventofcode.com/2020/day/11/input"
    input_filename = "input.txt"


proc getInput(url: string = input_url, filename: string = input_filename) =
    ## Save input from `input_url` into a text file `input_filename` inside
    ## working directory. Skip if `input_filename` exists.
    echo "using directory ", getCurrentDir()
    if not fileExists(input_filename):
        let cmd = fmt"wget --load-cookies=../cookies-adventofcode-com.txt -O input.txt {url}"
        let res = execShellCmd(cmd)
        echo fmt"wget returned {res}"


proc parseInput(filename: string = input_filename): SimState =
    var strm = newFileStream(filename, fmRead)
    if not isNil(strm):
        # streams.lines iterator doesn't work here when nre is imported?
        var
            line = ""
            row = 0
        while strm.readLine(line):
            # ensure line lengths are the same
            if result.width == 0:
                result.width = line.len
            else:
                assert line.len == result.width
            for c in line.items:
                result.field.add(block:
                    case c:
                        of 'L': empty
                        of '#': occupied
                        else: keepout
                )
            row.inc
        result.height = row
        strm.close()
    else:
        echo fmt"input file {filename} does not exist"

proc printState(s: SimState) =
    ## print the field state to stdout
    # CURSOR_UP_ONE = '\x1b[1A'
    # ERASE_LINE = '\x1b[2K'
    # print(CURSOR_UP_ONE + ERASE_LINE)
    var line = ""
    for i, elem in s.field.pairs:
        if i mod s.width == 0:
            stdout.writeLine(line)
            line = ""
        let c = block:
            case elem:
                of empty: 'L'
                of occupied: '#'
                else: '.'
        line = line & c
    stdout.writeLine(line & "\n")


func countAdjacent(s: SimState, index: int, es: EState = occupied): int =
    ## count the elements in `es` adjacent to element `index`
    proc lookup(x, y: int, es: var EState): bool =
        if x < 0 or x >= s.width:
            return false
        if y < 0 or y >= s.height:
            return false
        es = s.field[y * s.width + x]
        true
    let
        x = index mod s.width
        y = index div s.width
    for dx in [-1, 0, 1]:
        for dy in [-1, 0, 1]:
            if dx == 0 and dy == 0:
                continue
            var lookup_state: EState
            if lookup(x + dx, y + dy, lookup_state):
                if lookup_state == es: result.inc


func applyRules(s: SimState): SimState =
    result.width = s.width
    result.height = s.height
    result.iteration = s.iteration + 1

    for i, f in s.field.pairs:
        let c = countAdjacent(s, i)
        result.field.add(block:
            case f:
                of empty:
                    if c == 0: occupied else: empty
                of occupied:
                    if c >= 4: empty else: occupied
                else: f
        )
        if result.field[i] != s.field[i]: result.changed.inc
        if result.field[i] == occupied: result.occupied.inc


if isMainModule:
    getInput()
    var state = parseInput()
    printState(state)
    echo fmt"starting state"
    while true:
        let new_state = applyRules(state)
        printState(new_state)
        echo fmt"iteration {new_state.iteration}, changed {new_state.changed}, {new_state.occupied} occupied"
        if new_state.changed == 0:
            break
        state = new_state
