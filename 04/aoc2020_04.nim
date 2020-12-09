## Advent of Code 2020
## Solutions implemented in Nim Programming Language (www.nim-lang.org)
## Day 4: Passport Processing
## https://adventofcode.com/2020/day/4
##
## Resources:
## Streams: https://nim-lang.org/docs/streams.html#15
## Array and Sequence Types: https://nim-lang.org/docs/manual.html#types-array-and-sequence-types
## Parseutils: https://nim-lang.org/docs/parseutils.html
## Parsing input: https://old.reddit.com/r/nim/comments/k22h74/advent_of_nim_2020/gealoo3/
## Regular Expressions: https://nim-lang.org/docs/re.html


import os
import sequtils
import streams
import strformat
import strutils
import sugar


const input_url = "https://adventofcode.com/2020/day/4/input"
const input_filename = "input.txt"
const required_fields = @["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"]


proc getInput(url: string=input_url, filename: string=input_filename) =
    ## Save input from `input_url` into a text file `input_filename` inside
    ## working directory. Skip if `input_filename` exists.
    echo "using directory ", getCurrentDir()
    if not fileExists(input_filename):
        let cmd = fmt"wget --load-cookies=../cookies-adventofcode-com.txt -O input.txt {url}"
        let res = execShellCmd(cmd)
        echo fmt"wget returned {res}"


proc parseInput(filename: string): seq[string] =
    ## parse input text into a sequence of strings, where each string
    ## contains the text of a single passport record.
    var strm = newFileStream(filename, fmRead)
    if not isNil(strm):
        let lines = toSeq(strm.lines)
        var fragments: seq[string]
        for line in lines:
            if line.len > 0:
                fragments.add(line)
            else:
                # newline between record fragments is discarded so add a space
                result.add(fragments.join(" "))
                fragments = @[]
        # the last record is terminated by a single newline, so add whatever
        # fragments are left
        result.add(fragments.join(" "))
        strm.close()
    else:
        echo fmt"input file {filename} does not exist"


proc filterValid(records: seq[string], fields: seq[string] = required_fields):
        seq[string] =
    records.filter(rec => allIt(fields, rec.contains(it & ':')))


if isMainModule:
    getInput()
    let records = parseInput(input_filename)
    echo fmt"Parsed {records.len} passport record(s)"
    #echo records
    let valid_records = filterValid(records)
    echo fmt"Found {valid_records.len} valid passport record(s)"
    #echo valid_records
