## Advent of Code 2020
## Solutions implemented in Nim Programming Language (www.nim-lang.org)
## Day 2: Report Repair Part 2
## https://adventofcode.com/2020/day/1#part2
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

func findEntries(expreport: var seq[uint]): (uint, uint, uint) =
    while expreport.len > 0:
        var num1 = pop(expreport)
        for num2 in expreport:
            # note that this checks num2 against itself alsso this may return an
            # incorrect result if there is a case where a + b + b == 2020
            for num3 in expreport:
                if num1 + num2 + num3 == 2020:
                    return (num1, num2, num3)


if isMainModule:
    var all_entries = parseInput(input_filename)
    let entries = findEntries(all_entries)
    let product = entries[0] * entries[1] * entries[2]
    echo fmt"entries found: {entries[0]}, {entries[1]}, {entries[2]}, product: {product}"
