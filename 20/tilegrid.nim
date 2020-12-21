## A module for working with tiles and grids of tiles
## Day 20: Jurassic Jigsaw
## https://adventofcode.com/2020/day/20

import algorithm
import hashes
import options
import sequtils
import strformat
import strutils
import sets
#import sugar


const
    tile_width* = 10
    tile_height* = 10
    angles* = {0, 90, 180, 270}

type
    Pos* = tuple[x, y: int]

    Tile* = object
        id*: int
        data*: seq[char]

    Group* = object
        xsl*: Slice[int]
        ysl*: Slice[int]
        data*: seq[(Pos, Tile)]


func addAngle(a, b: int): int =
    result = a + b
    if result >= 360:
        result -= 360
    if result < 0:
        result += 360


func hash*(p: Pos): Hash =
    var h: Hash = 0
    h = h !& p.x !& p.y
    result = !$h


iterator dirs(at: Pos): (int, int, int) =
    ## Iterate over the 4 valid positions relative to `pos`.
    ## Retur a tuple of x, y, and angle
    let d = @[ # neighbor positions
            (at.x, at.y + 1, 0),
            (at.x + 1, at.y, 90),
            (at.x, at.y - 1, 180),
            (at.x - 1, at.y, 270)
        ]
    for i in d:
        yield i


proc `$`*(tile: Tile): string =
    ## stringify a tile
    result = fmt"(Tile {tile.id})"
    # for line in tile.data.distribute(tile_width):
    #    result.add line.join("") & "\n"


proc `$`*(hs: HashSet[Pos]): string =
    ## stringify a HashSet of points
    var s = newSeqOfCap[string](hs.len)
    for item in hs.items:
        s.add $item
    "HashSet[Pos]: " & s.join(", ")


func slice*(tile: Tile, at: Pos = (0, 0), angle: int = 0): seq[char] =
    ## Take a slice of a tile with column (x), row (y) in `offset` and `angle` 0
    ## (horizontal slice) or 90 (vertical slice).
    assert angle in {0, 90}
    assert at.x < tile_width and at.y < tile_height
    result = case angle:
    of 0:
        let f = at.y * tile_height
        tile.data[f ..< f + tile_width]
    of 90:
        var col = newSeqOfCap[char](tile_height)
        for i in (0 ..< tile_height):
            col.add tile.data[i * tile_width + at.x]
        col
    else:
        @[]


func side*(tile: Tile, side: int): seq[char] =
    ## return a string for the slice (side) of a tile
    assert side in angles
    result = case side:
        of 0: tile.slice()
        of 180: tile.slice(at=(0, tile_height - 1))
        of 90: tile.slice(at=(tile_width - 1, 0), angle=90)
        of 270: tile.slice(angle=90)
        else: @[]


func checkSide(a, b: Tile, angle: int = 0): bool =
    ## Check a single side of each adjacent tiles
    ## Angle is the angle of the virtual vector from tile a to tile b
    ## For example, if tile b is directly to the right of tile a then
    ## angle is 90. If tile b is below tile a then angle is 180.
    assert angle in angles
    assert a.id != 0
    if b.id == 0:
        # empty tile
        # debugEcho fmt"checkSide a:{a}, b:{b}, angle: {angle}"
        return true
    a.side(angle) == b.side(angle.addAngle(180))


iterator sides*(tile: Tile): (int, seq[char]) =
    ## Iterate over all sides of a tile. Return a tuple of `(angle, side)`
    ## for all 4 sides of a tile.
    for a in angles:
        yield (a, tile.side(a))


proc insertTile*(group: var Group, tile: Tile, at: Pos) =
    ## Insert a tile into grid at coordinate postion
    assert at notin group.data.unzip[0]
    if at.x < group.xsl.a: group.xsl.a = at.x
    if at.x > group.xsl.b: group.xsl.b = at.x
    if at.y < group.ysl.a: group.ysl.a = at.y
    if at.y > group.ysl.b: group.ysl.b = at.y
    group.data.add (at, tile)


func tileAt(group: Group, at: Pos): Option[Tile] =
    ## get tile from group at position if it exists
    # debugEcho fmt"tileAt: at: {at}, xs: {group.xsl}, ys: {group.ysl}"
    if at.x < group.xsl.a or at.x > group.xsl.b or
        at.y < group.ysl.a or at.y > group.ysl.b:
            return none(Tile)
    let res = group.data.filterIt(it[0] == at)
    debugEcho fmt"res: {res}"
    if res.len == 0:
            return none(Tile)
    some(res[0][1])


proc tryInsertAt*(group: var Group, tile: Tile, at: Pos): bool =
    ## Try to insert a tile into group at position. Return `true`
    ## if insert succeeds, `false` if it fails.
    echo fmt"tryInsertAt: tile:{tile.id}, x:{at.x}, y:{at.y}"
    if group.data.len == 0:
        group.insertTile(tile, at)
        return true
    for (x, y, a) in at.dirs:
        let t = group.tileAt((x, y))
        if t.isNone:
            # echo fmt"check {x}, {y}, {a}: no tile"
            continue
        # echo fmt"check {x}, {y}, {a}, tile: {t.get()}"
        let fits = checkSide(tile, t.get(), a)
        if not fits:
            return false
    group.insertTile(tile, at)
    return true


func perimeter*(group: Group): HashSet[Pos] =
    ## return a set of all the perimeter coordinates of a
    ## tile group. These are the positions which do not
    ## contain a tile but are adjacent to positions which do
    assert group.data.len > 0
    var tiles_at = HashSet[Pos]()
    for (at, tile) in group.data:
        tiles_at.incl(at)
        for (x, y, _) in at.dirs:
            result.incl((x, y))
    result = result - tiles_at


proc `$`*(gr: Group): string =
    result = &"(Group, xsl: {gr.xsl}, ysl: {gr.ysl})\n\n"
    var y = gr.ysl.b
    while (y >= gr.ysl.a):
        dec y
        var lines = newSeq[string](tile_height + 1)
        for x in gr.xsl:
            let t = gr.tileAt((x, y))
            if t.isSome:
                lines[0].add $t.get().id & "       "
                for i in (0 ..< tile_height):
                    lines[i+1].add $t.get().slice((0, i)).join("") & " "
            else:
                for i in (0 ..< lines.len):
                    lines[i].add "           "
        for i in lines:
            result.add i & "\n"
