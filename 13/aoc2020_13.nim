## Advent of Code 2020
## Solutions implemented in Nim Programming Language (www.nim-lang.org)
## Day 13: Shuttle Search
## https://adventofcode.com/2020/day/13
##
## Resources:
## Streams: https://nim-lang.org/docs/streams.html#15
## Array and Sequence Types: https://nim-lang.org/docs/manual.html#types-array-and-sequence-types
## Parseutils: https://nim-lang.org/docs/parseutils.html
## Parsing input: https://old.reddit.com/r/nim/comments/k22h74/advent_of_nim_2020/gealoo3/
## Regular Expressions: https://nim-lang.org/docs/re.html


import os
import re
import sequtils
import streams
import strformat
import strutils
import sugar


const
    input_url = "https://adventofcode.com/2020/day/13/input"
    input_filename = "input.txt"


proc getInput(url: string = input_url, filename: string = input_filename) =
    ## Save input from `input_url` into a text file `input_filename` inside
    ## working directory. Skip if `input_filename` exists.
    echo "using directory ", getCurrentDir()
    if not fileExists(input_filename):
        let cmd = fmt"wget --load-cookies=../cookies-adventofcode-com.txt -O input.txt {url}"
        let res = execShellCmd(cmd)
        echo fmt"wget returned {res}"


proc parseInput(filename: string = input_filename): (int, seq[int]) =
    var strm = newFileStream(filename, fmRead)
    if not isNil(strm):
        var line = ""
        # read time
        assert strm.readLine(line) == true
        result[0] = parseInt(line)
        assert strm.readLine(line) == true
        result[1] = line.split(',').filter(s => s.match(re"\d+")).map(parseInt)
        strm.close()
    else:
        echo fmt"input file {filename} does not exist"


func findNextBus(busses: seq[int], time: int): (int, int) =
    let max_iter = 1_000_000
    var t = time
    for _ in (0..<max_iter):
        for id in busses:
            if t mod id == 0: return (t, id)
        inc t


if isMainModule:
    getInput()
    let (time, busses) = parseInput()
    echo "parsed notes: ", time, busses
    let (bus_time, bus_id) = busses.findNextBus(time)
    echo fmt"found bus {bus_id} at time {bus_time}"
    echo (bus_time - time) * bus_id
