## Advent of Code 2020
## Solutions implemented in Nim Programming Language (www.nim-lang.org)
## Day 1: Report Repair
## https://adventofcode.com/2020/day/1
##
## Resources:
## Streams: https://nim-lang.org/docs/streams.html#15
## Array and Sequence Types: https://nim-lang.org/docs/manual.html#types-array-and-sequence-types
## Parseutils: https://nim-lang.org/docs/parseutils.html
##
##



import streams
import strformat
import parseutils


const input_filename = "input.txt"

## parse the file into an array

proc parseInput(filename: string): seq[uint] =
    result = @[]
    var strm = newFileStream(filename, fmRead)
    var line = ""
    if not isNil(strm):
        var num: uint
        while strm.readLine(line):
            discard parseUInt(line, num)
            result.add(num)

func findEntries(expreport: var seq[uint]): (uint, uint) =
    while expreport.len > 0:
        var num1 = pop(expreport)
        for num2 in expreport:
            if num1 + num2 == 2020:
                return (num1, num2)


if isMainModule:
    var all_entries = parseInput(input_filename)
    let entries = findEntries(all_entries)
    let product = entries[0] * entries[1]
    echo fmt"entries found: {entries[0]}, {entries[1]}, product: {product}"
