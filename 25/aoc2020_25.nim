## Advent of Code 2020
## Solutions implemented in Nim Programming Language (www.nim-lang.org)
## Day 25: Combo Breaker
## https://adventofcode.com/2020/day/25
##
## Resources:
## Streams: https://nim-lang.org/docs/streams.html#15
## Array and Sequence Types: https://nim-lang.org/docs/manual.html#types-array-and-sequence-types
## HashSet: https://nim-lang.org/docs/sets.html#HashSet
## Parseutils: https://nim-lang.org/docs/parseutils.html
## Parsing input: https://old.reddit.com/r/nim/comments/k22h74/advent_of_nim_2020/gealoo3/
## Regular Expressions: https://nim-lang.org/docs/re.html
## Nim memory model: http://zevv.nl/nim-memory/#_memory_organization_in_nim
## Nim Npeg: https://github.com/zevv/npeg


import os
import streams
import strformat
import strutils


const
    input_url = "https://adventofcode.com/2020/day/25/input"
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
    ## Parse input data file into appropriate Nim data structures
    var
        strm = newFileStream(filename, fmRead)
    if not isNil(strm):
        for line in strm.lines:
            if line.len == 0:
                continue
            result.add line.parseInt
        strm.close()
    else:
        echo fmt"input file {filename} does not exist"


func findLoopSize(pub_key: int, key_sn: int = 7): int =
    var n = 1
    while n != pub_key:
        n *= key_sn
        n = n mod 20201227
        inc result


func findEncKey(pub_key: int, loop_size: int): int =
    var
        i = 0
        res = 1
    while i < loop_size:
        res *= pub_key
        res = res mod 20201227
        inc i
    res


if isMainModule:
    getInput()
    let
        pub_keys = parseInput()
        c_pk = pub_keys[0]
        d_pk = pub_keys[1]
        c_ls = findLoopSize(c_pk)
        d_ls = findLoopSize(d_pk)
    echo fmt"loop size for card public key {c_pk} is {c_ls}"
    echo fmt"loop size for door public key {d_pk} is {d_ls}"
    let
        c_enckey = findEncKey(d_pk, c_ls)
        d_enckey = findEncKey(c_pk, d_ls)
    echo fmt"card encryption key {c_enckey}, door encryption key {d_enckey}"
    echo "encryption keys are equal: ", c_enckey == d_enckey
