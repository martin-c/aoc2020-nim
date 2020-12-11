## Advent of Code 2020
## Solutions implemented in Nim Programming Language (www.nim-lang.org)
## Day 10: Adapter Array
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


const
    input_url = "https://adventofcode.com/2020/day/10/input"
    input_filename = "input.txt"


proc getInput(url: string = input_url, filename: string = input_filename) =
    ## Save input from `input_url` into a text file `input_filename` inside
    ## working directory. Skip if `input_filename` exists.
    echo "using directory ", getCurrentDir()
    if not fileExists(input_filename):
        let cmd = fmt"wget --load-cookies=../cookies-adventofcode-com.txt -O input.txt {url}"
        let res = execShellCmd(cmd)
        echo fmt"wget returned {res}"


proc parseInput(filename: string = input_filename): seq[int] =
    var strm = newFileStream(filename, fmRead)
    if not isNil(strm):
        # streams.lines iterator doesn't work here when nre is imported?
        var line = ""
        while strm.readLine(line):
            result.add(parseInt(line))
        strm.close()
    else:
        echo fmt"input file {filename} does not exist"


func deltaDist(list: seq[int]): seq[int] =
    result = repeat(0, 4)
    for i in 1..<list.len:
        let delta = list[i] - list[i-1]
        assert delta <= 3
        inc(result[delta])


func combinations(list: seq[int]): BiggestUInt =
    var
        # https://brilliant.org/wiki/tribonacci-sequence/
        # https://old.reddit.com/r/adventofcode/comments/ka8z8x/2020_day_10_solutions/gfbnbld/
        ts = @[0, 1, 1, 2, 4, 7, 13]
        # the number of delta=1 in a row
        count = 0
    result = 1
    for i in 1..<list.len:
        let delta = list[i] - list[i-1]
        assert delta <= 3
        if delta == 1:
            count.inc
        elif delta == 3:
            result = result * cast[BiggestUInt](ts[count + 1])
            count = 0


if isMainModule:
    getInput()
    let
        lines = parseInput()
    var list = lines
    # add wall(0)
    list.add(0)
    list.sort()
    # add laptop adapter (3)
    list.add(list[list.len-1] + 3)
    let dist = list.deltaDist()
    echo dist
    echo fmt"1-jolt differences: {dist[1]}, 3-jolt differences: {dist[3]}, product: {dist[1] * dist[3]}"
    let comb = list.combinations()
    echo fmt"adapter combinations: {comb}"
