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
import sugar
import tables


type
    Rule = object
        test: proc(v: int): bool {.noSideEffect.}
        label: string


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


func parseRule(ruledef: string): Rule =
    var
        label: string
        min1, max1, min2, max2: int
    # class: 1-3 or 5-7
    # debugEcho ruledef
    assert ruledef.scanf("$+: $i-$i or $i-$i", label, min1, max1, min2, max2)
    result.test = proc(v: int): bool {.noSideEffect.} =
        (v >= min1 and v <= max1) or (v >= min2 and v <= max2)
    result.label = label


func parseTicket(line: string): seq[int] =
    line.split(',').map(parseInt)


func ticketValid(ticket: seq[int], rules: seq[Rule]): bool =
    for fld in ticket:
        if not rules.anyIt(it.test(fld)):
            return false
    true


iterator fields(tickets: seq[seq[int]]): (int, seq[int]) =
    ## transpose a sequence of tickets into a seqence of the same field from
    ## each ticket. Iterator `i` counts up for each field offset
    var col = newSeq[int](tickets.len)
    for f in 0..<tickets[0].len:
        for t in 0..<tickets.len:
            col[t] = tickets[t][f]
        yield (f, col)


proc validFields(tickets: seq[seq[int]], rules: seq[Rule],
        fmap: OrderedTableRef[string, seq[int]]) =
    # map of valid fields where key is the field label and value is sequence of
    # the field offset(s) which are valid
    for rule in rules:
        var s: seq[int]
        for (i, field) in tickets.fields:
            if field.all(rule.test):
                s.add(i)
        fmap[rule.label] = s


proc solveFields(fmap: OrderedTableRef[string, seq[int]]) =
    var exclude: seq[int]
    # sort by length of sequence of field offsets
    fmap.sort((x, y) => x[1].len - y[1].len)
    for possible_fields in fmap.mvalues:
        possible_fields.keepItIf(it notin exclude)
        # if this is false there are at least two valid combinations
        assert(possible_fields.len == 1)
        exclude.add(possible_fields[0])


func mergeTicketValues(fmap: OrderedTableRef[string, seq[int]], ticket: seq[int]):
        Table[string, int] =
    for (label, field) in fmap.pairs:
        result[label] = ticket[field[0]]


if isMainModule:
    getInput()
    let
        res = splitInput()
        rules = res[0].map(parseRule)
        ticket = res[1].map(parseTicket)[0]
        nearby_tickets = res[2].map(parseTicket)
        valid_tickets = nearby_tickets.filterIt(ticketValid(it, rules))
    echo "nearby tickets: ", nearby_tickets.len, " valid nearby tickets: ", valid_tickets.len
    var field_map = newOrderedTable[string, seq[int]]()
    validFields(valid_tickets, rules, field_map)
    solveFields(field_map)
    let ticket_map = mergeTicketValues(field_map, ticket)
    echo ticket_map
    var product = 1
    for (label, val) in ticket_map.pairs:
        if label.split(" ")[0] == "departure":
            product *= val
    echo "product: ", product
