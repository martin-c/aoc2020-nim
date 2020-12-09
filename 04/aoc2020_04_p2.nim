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


import nre
import os
import sequtils
import streams
import strformat
import strutils
import sugar


type FieldDef = tuple
    id: string
    parse_regex: string
    validator: proc(matches: seq[string]): bool


const input_url = "https://adventofcode.com/2020/day/4/input"
const input_filename = "input.txt"
func valInRange(val, min, max: int): bool = val >= min and val <= max
func validateHeight(height: string, unit: string): bool


const required_fields = @[
    (
        id: "byr",
        parse_regex: r"(\d{4})",
        validator: proc(matches: seq[string]): bool{.closure.} =
            valInRange(parseInt(matches[0]), 1920, 2002)
    ),
    (
        id: "iyr",
        parse_regex: r"(\d{4})",
        validator: proc(matches: seq[string]): bool{.closure.} =
            valInRange(parseInt(matches[0]), 2010, 2020)
    ),
    (
        id: "eyr",
        parse_regex: r"(\d{4})",
        validator: proc(matches: seq[string]): bool{.closure.} =
            valInRange(parseInt(matches[0]), 2020, 2030)
    ),
    (
        id: "hgt",
        parse_regex: r"(\d+)(in|cm)",
        validator: proc(matches: seq[string]): bool{.closure.} =
            validateHeight(matches[0], matches[1])
    ),
    (
        id: "hcl",
        parse_regex: r"(#[0-9a-f]{6})",
        validator: proc(matches: seq[string]): bool{.closure.} =
            matches.len > 0
    ),
    (
        id: "ecl",
        parse_regex: r"(amb|blu|brn|gry|grn|hzl|oth)",
        validator: proc(matches: seq[string]): bool{.closure.} =
            matches.len > 0
    ),
    (
        id: "pid",
        parse_regex: r"(\d{9})",
        validator: proc(matches: seq[string]): bool{.closure.} =
            matches.len > 0
    )
]


func validateHeight(height: string, unit: string): bool =
    ## validate a height field
    let val = parseInt(height)
    case unit
        of "cm": valInRange(val, 150, 193)
        of "in": valInRange(val, 59, 76)
        else: false


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
        var line = ""
        var fragments: seq[string]
        while strm.readLine(line):
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


func filterComplete(records: seq[string], fields: seq[FieldDef] = required_fields):
        seq[string] =
    records.filter(rec => allIt(fields, rec.contains(it.id & ':')))


func buildValidator(field: FieldDef): (proc(record: string): bool) =
    let (id, regex, validator) = field
    # regexr.com/5i4cc
    let rx = re(r"(?U).*" & id & r":" & regex & r"\b")
    result = proc(record: string): bool{.closure.} =
        let ret = record.match(rx)
        if isSome(ret):
            try:
                let match_seq = ret.get.captures.toSeq.map(m => get(m))
                validator(match_seq)
            except IndexDefect:
                false
        else: false


func validateFields(records: seq[string], fields: seq[FieldDef] = required_fields):
        seq[string] =
    let validator_functions = fields.map(buildValidator)
    records.filter(
        proc(record: string): bool =
            for fn in validator_functions:
                if fn(record):
                    # validator function returns true
                    continue
                else:
                    return false
            # all validator functions returned true
            true
    )


if isMainModule:
    getInput()
    let records = parseInput(input_filename)
    echo fmt"Parsed {records.len} passport record(s)"
    #echo records
    let valid_records = validateFields(records)
    echo fmt"Found {valid_records.len} valid passport record(s)"
    echo valid_records
