## Advent of Code 2020
## Solutions implemented in Nim Programming Language (www.nim-lang.org)
## Day 6: Custom Customs
## https://adventofcode.com/2020/day/6
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
    input_url = "https://adventofcode.com/2020/day/6/input"
    input_filename = "input.txt"


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
        result = toSeq(strm.lines)
        strm.close()
    else:
        echo fmt"input file {filename} does not exist"


func makeSets(lines: seq[string]): seq[set[char]] =
    var group: set[char]
    for line in lines:
        if line.len == 0:
            result.add(group)
            group = {}
            continue
        for c in line:
            group.incl(c)
    result.add(group)


func countDistinctAnswers(groups: seq[set[char]]): seq[int] =
    groups.map(proc(group: set[char]): int = group.len)


if isMainModule:
    getInput()
    let lines = parseInput()
    let groups = makeSets(lines)
    let answers = countDistinctAnswers(groups)
    let total = foldl(answers, a + b)
    echo fmt"Found {groups.len} group(s), total questions answered is {total}"
