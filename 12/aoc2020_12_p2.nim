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


import os
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
        # positive x is east, positive y is north
        pos: tuple[x: int, y: int]
        #heading: int    # positive is clockwise (right)
        # waypoint position relative to ship
        wpt: tuple[x: int, y: int]


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


func x_wp(wpt: tuple[x: int, y: int], delta: int): tuple[x: int, y: int] =
    ## helper function to transform waypoint coordinates by an integer
    ## multiple of 90 degrees
    var d = delta mod 360
    # -90 is the same as +270
    if d < 0: d += 360
    result = (wpt.x, wpt.y)
    for i in (0..<(d div 90)):
        (result.x, result.y) = (result.y, -result.x)


func applyInst(state: ShipState, inst: NavInst): ShipState =
    var s = state
    let val = inst.value
    case inst.action:
        of north: s.wpt.y += val
        of south: s.wpt.y -= val
        of east: s.wpt.x += val
        of west: s.wpt.x -= val
        of left: s.wpt = s.wpt.x_wp(-val)
        of right: s.wpt = s.wpt.x_wp(val)
        of forward:
            s.pos.x += s.wpt.x * val; s.pos.y += s.wpt.y * val
    s


func md(s: ShipState, initial_state: ShipState): int =
    # compute the Manhattan Distance
    abs(s.pos.x - initial_state.pos.x) + abs(s.pos.y - initial_state.pos.y)


func run(initial_state: ShipState, instructions: seq[NavInst]): ShipState =
    var state = initial_state
    for inst in instructions:
        #debugEcho "\n", fmt"instruction: {inst}"
        state = applyInst(state, inst)
        #debugEcho fmt"state: {state}"
    state


if isMainModule:
    getInput()
    let instructions = parseInput()
    let initial_state = (pos: (x: 0, y: 0), wpt: (x: 10, y: 1))
    let final_state = run(initial_state, instructions)
    echo final_state
    echo fmt"The Manhattan Distance from initial state to final state is {final_state.md(initial_state)}"
