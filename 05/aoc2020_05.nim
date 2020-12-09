## Advent of Code 2020
## Solutions implemented in Nim Programming Language (www.nim-lang.org)
## Day 5: Binary Boarding
## https://adventofcode.com/2020/day/5
##
## Resources:
## Streams: https://nim-lang.org/docs/streams.html#15
## Array and Sequence Types: https://nim-lang.org/docs/manual.html#types-array-and-sequence-types
## Parseutils: https://nim-lang.org/docs/parseutils.html
## Parsing input: https://old.reddit.com/r/nim/comments/k22h74/advent_of_nim_2020/gealoo3/
## Regular Expressions: https://nim-lang.org/docs/re.html


import intsets
import os
import sequtils
import streams
import strformat
import strutils
import sugar


const
    input_url = "https://adventofcode.com/2020/day/5/input"
    input_filename = "input.txt"
    upper_half = ['B', 'R']
    rows = 128
    columns = 8


proc getInput(url: string = input_url, filename: string = input_filename) =
    ## Save input from `input_url` into a text file `input_filename` inside
    ## working directory. Skip if `input_filename` exists.
    echo "using directory ", getCurrentDir()
    if not fileExists(input_filename):
        let cmd = fmt"wget --load-cookies=../cookies-adventofcode-com.txt -O input.txt {url}"
        let res = execShellCmd(cmd)
        echo fmt"wget returned {res}"


proc parseInput(filename: string = input_filename): seq[string] =
    var strm = newFileStream(filename, fmRead)
    if not isNil(strm):
        result = toSeq(strm.lines).filterIt(it.len > 0)
        strm.close()
    else:
        echo fmt"input file {filename} does not exist"


func partition(list: string, slice, offset: int = 0): (string, int, int) =
    var s = slice div 2
    var o = offset
    var l = list[1..^1]
    if list[0] in upper_half:
        o += s
    result = (l, s, o)
    # debugEcho result
    if l.len >= 1:
        result = partition(l, s, o)


func computeSeat(list: string): (int, int, int) =
    assert list.len == 10
    let (_, _, row) = partition(list[0..6], rows)
    let (_, _, column) = partition(list[7..9], columns)
    (row, column, row * columns + column)


proc runTests() =
    ## test the examples from the problem description as well as several other
    ## values
    assert computeSeat("FBFBBFFRLR") == (44, 5, 357)
    assert computeSeat("BFFFBBFRRR") == (70, 7, 567)
    assert computeSeat("FFFBBBFRRR") == (14, 7, 119)
    assert computeSeat("BBFFBBFRLL") == (102, 4, 820)
    assert computeSeat("FFFFFFFLLL") == (0, 0, 0)
    assert computeSeat("BBBBBBBRRR") == (127, 7, 1023)
    echo "Tests passed"


func highestSeat(acc, seat: (int, int, int)): (int, int, int) =
    if seat[2] > acc[2]: result = seat else: result = acc


if isMainModule:
    getInput()
    runTests()
    let passes = parseInput()
    let seats = passes.map(computeSeat)
    let highest_id = foldl(seats, highestSeat(a, b))
    echo fmt"The seat with the highest id is {highest_id}"
    let pass_id_set = seats.map(seat => seat[2]).toIntSet()
    # I hope to find a more efficient way to create an IntSet than this!
    let all_id_set = (0..highest_id[2]).toseq.toIntSet
    echo fmt"The seat ids missing are {all_id_set - pass_id_set}"
