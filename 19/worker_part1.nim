## Worker program, called from main program

import macros
import npeg
import sequtils
import strformat
import strutils
import tables


macro eval(value: static[string]): untyped =
  result = parseStmt value

let messages = eval(slurp("messages_out.txt"))


proc check(): seq[bool] =

    let parser = peg("aaa"):
        # insert rules here
