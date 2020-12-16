## Advent of Code 2020
## Solutions implemented in Nim Programming Language (www.nim-lang.org)
## Day 14: Docking Data
## https://adventofcode.com/2020/day/14
##
## Resources:
## Streams: https://nim-lang.org/docs/streams.html#15
## Array and Sequence Types: https://nim-lang.org/docs/manual.html#types-array-and-sequence-types
## Parseutils: https://nim-lang.org/docs/parseutils.html
## Parsing input: https://old.reddit.com/r/nim/comments/k22h74/advent_of_nim_2020/gealoo3/
## Regular Expressions: https://nim-lang.org/docs/re.html


import os
import parseutils
import sequtils
import streams
import strformat
import strscans
import strutils
#import sugar
#import tables


const
    input_url = "https://adventofcode.com/2020/day/16/input"
    input_filename = "input.txt"


proc getInput(url: string = input_url, filename: string = input_filename) =
    ## Save input from `input_url` into a text file `input_filename` inside
    ## working directory. Skip if `input_filename` exists.
    echo "using directory ", getCurrentDir()
    if not fileExists(input_filename):
        let cmd = fmt"wget --load-cookies=../cookies-adventofcode-com.txt -O input.txt {url}"
        let res = execShellCmd(cmd)
        echo fmt"wget returned {res}"


proc splitInput(filename: string = input_filename):
        array[3, seq[string]] =
    type
        ParseState = enum
            prules, pticket, pnearby_tickets
    var
        strm = newFileStream(filename, fmRead)
        parse_state = prules
    if not isNil(strm):
        var line = ""
        while strm.readLine(line):
            if line.len == 0:
                parse_state.inc
                continue
            if line in @["your ticket:", "nearby tickets:"]:
                continue
            result[parse_state.ord].add(line)
        strm.close()
    else:
        echo fmt"input file {filename} does not exist"


func parseRule(ruledef: string): proc(v:int): bool =
    var
        label: string
        min1, max1, min2, max2: int
    # class: 1-3 or 5-7
    # debugEcho ruledef
    assert ruledef.scanf("$+: $i-$i or $i-$i", label, min1, max1, min2, max2)
    result = proc(v: int): bool =
        #let label = label
        (v >= min1 and v <= max1) or (v >= min2 and v <= max2)


func parseTicket(line: string): seq[int] =
    line.split(',').map(parseInt)


proc errorRate(tickets: seq[seq[int]], rules: seq[proc(v:int): bool]): int =
    for tkt in tickets:
        for fld in tkt:
            var c: int
            for rle in rules:
                if rle(fld):
                    c.inc
                    break
            if c == 0:
                result += fld


if isMainModule:
    getInput()
    let
        res = splitInput()
        rules = res[0].map(parseRule)
        ticket = res[1].map(parseTicket)
        nearby_tickets = res[2].map(parseTicket)
        error_rate = nearby_tickets.error_rate(rules)
    echo "computed error rate: ", error_rate
