## Advent of Code 2020
## Solutions implemented in Nim Programming Language (www.nim-lang.org)
## Day 9: Encoding Error
## https://adventofcode.com/2020/day/9
##
## Resources:
## Streams: https://nim-lang.org/docs/streams.html#15
## Array and Sequence Types: https://nim-lang.org/docs/manual.html#types-array-and-sequence-types
## Parseutils: https://nim-lang.org/docs/parseutils.html
## Parsing input: https://old.reddit.com/r/nim/comments/k22h74/advent_of_nim_2020/gealoo3/
## Regular Expressions: https://nim-lang.org/docs/re.html


import intsets
import options
import os
import sequtils
import streams
import strformat
import strutils


const
    input_url = "https://adventofcode.com/2020/day/9/input"
    input_filename = "input.txt"


proc getInput(url: string = input_url, filename: string = input_filename) =
    ## Save input from `input_url` into a text file `input_filename` inside
    ## working directory. Skip if `input_filename` exists.
    echo "using directory ", getCurrentDir()
    if not fileExists(input_filename):
        let cmd = fmt"wget --load-cookies=../cookies-adventofcode-com.txt -O input.txt {url}"
        let res = execShellCmd(cmd)
        echo fmt"wget returned {res}"


proc parseInput(filename: string = input_filename): seq[BiggestUInt] =
    var strm = newFileStream(filename, fmRead)
    if not isNil(strm):
        # streams.lines iterator doesn't work here when nre is imported?
        var line = ""
        while strm.readLine(line):
            result.add(parseBiggestUint(line))
        strm.close()
    else:
        echo fmt"input file {filename} does not exist"


func findSumInSlice(list: seq[BiggestUInt], slice: HSlice, val: BiggestUInt):
        Option[(BiggestUInt, BiggestUInt)] =
    # this iteration will check `slice - 1` numbers twice, but it's likely not
    # worth skipping the values since this introduces another conditional
    for i in slice:
        for j in slice:
            if i == j: continue
            if list[i] + list[j] == val:
                return some((list[i], list[j]))


func findFirstError(list: seq[BiggestUInt], preamble: int = 25):
        Option[(int, BiggestUInt)] =
    ## Return the index and value of the first number which is not the sum of
    ## two of the `premable` numbers before it.
    for i, val in list.pairs():
        if i < preamble: continue
        let res = list.findSumInSlice(i-preamble .. i-1, val)
        if res.isNone:
            return some((i, val))


func findContSum(list: seq[BiggestUInt], val: BiggestUInt):
        Option[seq[BiggestUInt]] =
    ## Returns a subset of `list` where a contigous set of at least two numbers
    ## add up to `val`
    # the maximum set length here is a guess
    let max_set_len = 20
    for set_len in (2 .. max_set_len):
        for i in (0 .. list.len - set_len):
            let subset = list[i .. i + set_len - 1]
            # debugEcho "checking set: ", subset
            if subset.foldl(a + b) == val:
                return some(subset)


if isMainModule:
    getInput()
    let
        lines = parseInput()
        preamble = if lines.len < 25: 5 else: 25
        res = lines.findFirstError(preamble)
    if res.isSome:
        let (index, value) = res.get()
        echo fmt"found first error at index {index}, value {value}"
        let res_cont = lines.findContSum(value)
        if res_cont.isSome:
            let res_set = res_cont.get()
            echo fmt"found contiguous set which adds to {value}:"
            echo res_set
            let
                min_val = res_set[res_set.min_index]
                max_val = res_set[res_set.max_index]
            echo fmt"min: {min_val}, max: {max_val}, sum:{min_val + max_val}"

    else:
        echo "no errors found in list"
