## Advent of Code 2020
## Solutions implemented in Nim Programming Language (www.nim-lang.org)
## Day 12: Rain Risk
## https://adventofcode.com/2020/day/12
##
## Resources:
## Streams: https://nim-lang.org/docs/streams.html#15
## Array and Sequence Types: https://nim-lang.org/docs/manual.html#types-array-and-sequence-types
## Parseutils: https://nim-lang.org/docs/parseutils.html
## Parsing input: https://old.reddit.com/r/nim/comments/k22h74/advent_of_nim_2020/gealoo3/
## Regular Expressions: https://nim-lang.org/docs/re.html


import algorithm
import math
import os
import sequtils
import streams
import strformat
import strutils


type
    Action = enum
        north, south, east, west, left, right, forward
    NavInst = tuple
        action: Action
        value: int
    ShipState = tuple
        x: int          # positive x is east
        y: int          # positive y is north
        heading: int    # positive is clockwise (right)


const
    input_url = "https://adventofcode.com/2020/day/12/input"
    input_filename = "input.txt"


proc getInput(url: string = input_url, filename: string = input_filename) =
    ## Save input from `input_url` into a text file `input_filename` inside
    ## working directory. Skip if `input_filename` exists.
    echo "using directory ", getCurrentDir()
    if not fileExists(input_filename):
        let cmd = fmt"wget --load-cookies=../cookies-adventofcode-com.txt -O input.txt {url}"
        let res = execShellCmd(cmd)
        echo fmt"wget returned {res}"


proc parseInput(filename: string = input_filename): seq[NavInst] =
    var strm = newFileStream(filename, fmRead)
    if not isNil(strm):
        # streams.lines iterator doesn't work here when nre is imported?
        var
            line: string
            inst: NavInst
        while strm.readLine(line):
            let c = line[0]
            assert c in ['N', 'S', 'E', 'W', 'L', 'R', 'F']
            inst.action = block:
                case c:
                    of 'N': north
                    of 'S': south
                    of 'E': east
                    of 'W': west
                    of 'L': left
                    of 'R': right
                    else: forward
            inst.value = parseInt(line[1..^1])
            result.add(inst)
        strm.close()
    else:
        echo fmt"input file {filename} does not exist"


func applyInst(state: ShipState, inst: NavInst): ShipState =
    var s = state
    let val = inst.value
    func heading(initial: int, delta: int): int =
        ## helper function to compute heading changes correctly
        let d = delta mod 360
        let new = initial + d
        if new >= 360:
            result = new - 360
        elif new < 0:
            result = new + 360
        else:
            result = new
    case inst.action:
        of north: s.y += val
        of south: s.y -= val
        of east: s.x += val
        of west: s.x -= val
        of left: s.heading = heading(s.heading, -val)
        of right: s.heading = heading(s.heading, val)
        of forward:
            s.x += s.heading.toFloat.degToRad.sin.toInt * val
            s.y += s.heading.toFloat.degToRad.cos.toInt * val
    s


func md(s: ShipState, initial_state: ShipState): int =
    # compute the Manhattan Distance
    abs(s.x - initial_state.x) + abs(s.y - initial_state.y)


func run(initial_state: ShipState, instructions: seq[NavInst]): ShipState =
    var state = initial_state
    for inst in instructions:
        state = applyInst(state, inst)
    state


if isMainModule:
    getInput()
    let instructions = parseInput()
    echo instructions
    let initial_state = (x: 0, y:0, heading: 90)
    let final_state = run(initial_state, instructions)
    echo final_state
    echo fmt"The Manhattan Distance from initial state to final state is {final_state.md(initial_state)}"
