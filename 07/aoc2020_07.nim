## Advent of Code 2020
## Solutions implemented in Nim Programming Language (www.nim-lang.org)
## Day 7: Handy Haversacks
## https://adventofcode.com/2020/day/7
##
## Resources:
## Streams: https://nim-lang.org/docs/streams.html#15
## Array and Sequence Types: https://nim-lang.org/docs/manual.html#types-array-and-sequence-types
## Parseutils: https://nim-lang.org/docs/parseutils.html
## Parsing input: https://old.reddit.com/r/nim/comments/k22h74/advent_of_nim_2020/gealoo3/
## Regular Expressions: https://nim-lang.org/docs/re.html


import options
import os
import nre
import sequtils
import sets
import streams
import strformat
import strutils
import sugar


type
    BagRule = object
        color: string
        contains: seq[tuple[count: int, color: string]]

const
    input_url = "https://adventofcode.com/2020/day/7/input"
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
        # streams.lines iterator doesn't work here when nre is imported?
        var line = ""
        while strm.readLine(line):
            result.add(line)
        strm.close()
    else:
        echo fmt"input file {filename} does not exist"


func parseRule(rule: string): BagRule =
    ## Parse the rules using regular expressions.
    ## simple case (no contents): https://regexr.com/5i62i
    ## with contents: https://regexr.com/5i64h
    let
        ncre = re"^([\w\s]+) bags contain no other bags?\.$"
        wcre = re"^([\w\s]+) bags contain(?: (\d+) ([\w\s]+) bags?[,\.])(?: (\d+) ([\w\s]+) bags?[,\.])?(?: (\d+) ([\w\s]+) bags?[,\.])?(?: (\d+) ([\w\s]+) bags?[,\.])?$"
        ret_nc = rule.match(ncre)
        ret_wc = rule.match(wcre)
    if isSome(ret_nc):
        let match_seq = ret_nc.get.captures.toSeq.filter(s => not s.isNone).map(s => get(s))
        #debugEcho match_seq
        result = BagRule(color: match_seq[0], contains: @[])
    elif isSome(ret_wc):
        let match_seq = ret_wc.get.captures.toSeq.filter(s => not s.isNone).map(s => get(s))
        #debugEcho match_seq
        var
            contents: seq[tuple[count: int, color: string]]
            n = 1
        while n < match_seq.len - 1:
            contents.add((count: parseInt(match_seq[n]), color: match_seq[n+1]))
            n += 2
        result = BagRule(color: match_seq[0], contains: contents)
    else:
        raise newException(AssertionError, "neither regular expression matches")


func contains(rules: seq[BagRule], color: string): seq[BagRule] =
    ## Returns a sequence of `BagRule`s which contain the specified `color`.
    func match_color(rule: BagRule): bool =
        for item in rule.contains:
            if item.color == color:
                return true
        false
    rules.filter(match_color)


func eventuallyContains(rules: seq[BagRule], color: string): HashSet[string] =
    ## For bag `color` specified, find all the bag color(s) which can
    ## contain this bag.
    #debugEcho "eventually contains: ", color
    let contains_color = rules.contains(color)
    #debugEcho "contains_color: ", contains_color
    for item in contains_color:
        result.incl(item.color)
        result = result + eventuallyContains(rules, item.color)


func forColor(rules: seq[BagRule], color: string): Option[BagRule] =
    ## Return the bag rule for the bag with `color`.
    let res = rules.filterIt(it.color == color)
    assert res.len <= 1
    if res.len == 1:
        return some(res[0])


func countBags(rules: seq[BagRule], color: string): int =
    ## count all bags contained within a bag with `color`
    let res = rules.forColor(color)
    if res.isNone:
        return
    for item in res.get.contains:
        result += item.count + item.count * countBags(rules, item.color)


if isMainModule:
    getInput()
    let
        lines = parseInput()
        rules = lines.map(parseRule)
        my_bag_color = "shiny gold"
    echo "rules: ", rules
    echo fmt"contains {my_bag_color}: ", rules.contains(my_bag_color)
    let eventually_contains = rules.eventuallyContains(my_bag_color)
    echo fmt"eventually contains {my_bag_color}: ", eventually_contains
    echo fmt"there are {eventually_contains.len} total bags which may eventually contain a {my_bag_color} bag."
    echo fmt"rule for color {my_bag_color}: ", rules.forColor(my_bag_color).get()
    let bag_count = rules.countBags(my_bag_color)
    # https://twitter.com/pauladozsa/status/1336061757933187072
    echo fmt"there are {bag_count} bags inside a {my_bag_color} bag."
