## Advent of Code 2020
## Solutions implemented in Nim Programming Language (www.nim-lang.org)
## Day 2: Password Philosophy
## https://adventofcode.com/2020/day/2
##
## Resources:
## Streams: https://nim-lang.org/docs/streams.html#15
## Array and Sequence Types: https://nim-lang.org/docs/manual.html#types-array-and-sequence-types
## Parseutils: https://nim-lang.org/docs/parseutils.html
## Parsing input: https://old.reddit.com/r/nim/comments/k22h74/advent_of_nim_2020/gealoo3/
## Regular Expressions: https://nim-lang.org/docs/re.html


import os
import re
import streams
import strformat
import sequtils
import strutils


const input_url = "https://adventofcode.com/2020/day/2/input"
const input_filename = "input.txt"
let policy_re = re"^(\d+)-(\d+) (\w)"


proc getInput(url: string=input_url, filename: string=input_filename) =
    ## Save input from `input_url` into a text file `input_filename` inside
    ## working directory. Skip if `input_filename` exists.
    echo "using directory ", getCurrentDir()
    if not fileExists(input_filename):
        let cmd = fmt"wget --load-cookies=../cookies-adventofcode-com.txt -O input.txt {url}"
        let res = execShellCmd(cmd)
        echo fmt"wget returned {res}"


proc parseInput(filename: string): seq[seq[string]] =
    ## parse input text into a sequence of sequences in the form @[policy, password]
    var strm = newFileStream(filename, fmRead)
    if not isNil(strm):
        result = toSeq(strm.lines).filterIt(it.len > 0).mapIt(it.split(": "))
        strm.close()
    else:
        echo fmt"input file {filename} does not exist"


func validatePassword(policy_str: string, password_str: string, policy_reg: Regex=policy_re): bool =
    ## validate a policy and password pair
    result = false
    if policy_str =~ policy_reg:
        let policy = (min: matches[0].parseInt, max: matches[1].parseInt, character: matches[2][0])
        assert policy.min > 0
        assert policy.max > policy.min
        if policy.min > password_str.len or policy.max > password_str.len:
            # reject password if policy specifies characters beyond the end of the string
            return false
        if password_str[policy.min - 1] == policy.character xor
                password_str[policy.max - 1] == policy.character:
            return true


if isMainModule:
    getInput()
    var items = parseInput(input_filename)
    echo fmt"Parsed {items.len} policy and password combinations"
    let valid_count = items.mapIt(validatePassword(it[0], it[1])).count(true)
    echo fmt"There are {valid_count} passwords that are valid"

