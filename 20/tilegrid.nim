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
import tables
#import sugar


const
    tile_width* = 10
    tile_height* = 10
    angles* = {0, 90, 180, 270}

type
    # An x,y coordinate pair
    Point* = tuple[x, y: int]
    # A x,y coordinate pair with rotation and flip state
    Pos* = tuple[x, y, rot: int, hflip: bool]

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


func hash*(p: Point): Hash =
    var h: Hash = 0
    h = h !& p.x !& p.y
    result = !$h


iterator dirs(at: Point): (int, int, int) =
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


proc `$`*(hs: HashSet[Point]): string =
    ## stringify a HashSet of points
    var s = newSeqOfCap[string](hs.len)
    for item in hs.items:
        s.add $item
    "HashSet[Point]: " & s.join(", ")


func slice*(tile: Tile, sangle: int = 90, offset: int = 90,
        rot: int = 0, hflip: bool = false): seq[char] =
    ## Take a slice of a tile with column (x), row (y) with x or y offset
    ## `offset`, slice angle `angle` 0 (vertical slice) or 90
    ## (horizontal slice), tile rotation angle `rot` and possible
    ## horizontal flip `hflip`.
    assert sangle in {0, 90}
    assert rot in angles
    assert offset < tile_width and offset < tile_height and offset >= 0

    # start, step, offset_step for each combination of rotation, slice angle, and hflip
    let lut = {
        # rotation angle
        0: {
            # slice angle
            0: {
                # hflip state
                false: (0, tile_width, 1),
                true: (tile_width * (tile_height - 1), tile_width * -1, 1)
            }.newTable,
            90: {
                false: (0, 1, tile_width),
                true: (tile_width * (tile_height - 1), 1, tile_width * -1)
            }.newTable,
        }.newTable,
        90: {
            0: {
                false: (tile_width - 1, -1, tile_height),
                true: (0, 1, tile_width),
            }.newTable,
            90: {
                false: (tile_width - 1, tile_width, -1),
                true: (0, tile_width, 1),
            }.newTable,
        }.newTable,
        180: {
            0: {
                false: (tile_width * tile_height - 1, tile_width * -1, -1),
                true: (tile_width - 1, tile_width, -1)
            }.newTable,
            90: {
                false: (tile_width * tile_height - 1, -1, tile_width * -1),
                true: (tile_width - 1, -1, tile_width)
            }.newTable,
        }.newTable,
        270: {
            0: {
                false: (tile_width * (tile_height - 1), 1, tile_width * -1),
                true: (tile_width * tile_height - 1, -1, tile_width * -1)
            }.newTable,
            90: {
                false: (tile_width * (tile_height - 1), tile_width * -1, 1),
                true: (tile_width * tile_height - 1, tile_width * -1, -1)
            }.newTable
        }.newTable
    }.newTable
    var
        (start, step, offset_step) = lut[rot][sangle][hflip]
    # assume tile_width == tile_height
    var
        res = newSeqOfCap[char](tile_width)
    for i in 0 ..< tile_width:
        res.add(tile.data[start + i * step + offset * offset_step])
    res


func side*(tile: Tile, side: int, rot: int = 0, hflip: bool = false): seq[char] =
    ## return a string for the slice (side) of a tile, side is absolute
    ## relative to origin
    assert side in angles
    result = case side:
        of 0:
            # top (counting right)
            tile.slice(sangle=90, offset=tile_height - 1, rot, hflip)
        of 90:
            # right (counting up)
            tile.slice(sangle=0, offset=tile_width - 1, rot, hflip)
        of 180:
            # bottom (counting right)
            tile.slice(sangle=90, offset=0, rot, hflip)
        of 270:
            # left (counting up)
            tile.slice(sangle=0, offset=0, rot, hflip)
        else: @[]


func checkSide(a, b: (Tile, int, bool), angle: int = 0): bool =
    ## Check a single side of each adjacent tiles
    ## Angle is the angle of the virtual vector from tile a to tile b
    ## For example, if tile b is directly to the right of tile a then
    ## angle is 90. If tile b is below tile a then angle is 180.
    assert angle in angles
    let
        (tilea, rota, hflipa) = a
        (tileb, rotb, hflipb) = b
    assert tilea.id != 0
    if tileb.id == 0:
        # empty tile
        return true
    tilea.side(angle, rota, hflipa) == tileb.side(angle.addAngle(180), rotb, hflipb)


iterator sides*(tile: Tile): (int, seq[char]) =
    ## Iterate over all sides of a tile. Return a tuple of `(angle, side)`
    ## for all 4 sides of a tile.
    for a in angles:
        yield (a, tile.side(a))


proc insertTile*(group: var Group, tile: Tile, pos: Pos) =
    ## Insert a tile into grid at coordinate postion
    assert pos notin group.data.unzip[0]
    if pos.x < group.xsl.a: group.xsl.a = pos.x
    if pos.x > group.xsl.b: group.xsl.b = pos.x
    if pos.y < group.ysl.a: group.ysl.a = pos.y
    if pos.y > group.ysl.b: group.ysl.b = pos.y
    group.data.add (pos, tile)


func tileAt*(group: Group, at: Point): Option[(Pos, Tile)] =
    ## get tile from group at position if it exists
    # debugEcho fmt"tileAt: at: {at}, xs: {group.xsl}, ys: {group.ysl}"
    if at.x < group.xsl.a or at.x > group.xsl.b or
        at.y < group.ysl.a or at.y > group.ysl.b:
            return none((Pos, Tile))
    let res = group.data.filterIt(it[0].x == at.x and it[0].y == at.y)
    # debugEcho fmt"res: {res}"
    if res.len == 0:
            return none((Pos, Tile))
    some(res[0])


proc tryInsertAt*(group: var Group, tile: Tile, pos: Pos): bool =
    ## Try to insert a tile into group at position. Return `true`
    ## if insert succeeds, `false` if it fails.
    # echo fmt"tryInsertAt: tile:{tile.id}, x:{pos.x}, y:{pos.y}"
    if group.data.len == 0:
        group.insertTile(tile, pos)
        return true
    for (x, y, a) in (pos.x, pos.y).dirs:
        let res = group.tileAt((x, y))
        if res.isNone:
            # echo fmt"check {x}, {y}, {a}: no tile"
            continue
        # echo fmt"check {x}, {y}, {a}, tile: {t.get()[1]}"
        let
            (posb, tileb) = res.get()
            fits = checkSide((tile, pos.rot, pos.hflip), (tileb, posb.rot, posb.hflip), a)
        if not fits:
            return false
    group.insertTile(tile, pos)
    return true


func perimeter*(group: Group): HashSet[Point] =
    ## return a set of all the perimeter coordinates of a
    ## tile group. These are the positions which do not
    ## contain a tile but are adjacent to positions which do
    assert group.data.len > 0
    var tiles_at = HashSet[Point]()
    for (pos, tile) in group.data:
        tiles_at.incl((pos.x, pos.y))
        for (x, y, _) in (pos.x, pos.y).dirs:
            result.incl((x, y))
    result = result - tiles_at


proc `$`*(gr: Group): string =
    result = &"(Group, xsl: {gr.xsl}, ysl: {gr.ysl})\n\n"
    var y = gr.ysl.b
    while (y >= gr.ysl.a):
        var lines = newSeq[string](tile_height + 1)
        for x in gr.xsl:
            let res = gr.tileAt((x, y))
            if res.isSome:
                let (pos, tile) = res.get()
                let f = if pos.hflip: 'f' else: ' '
                lines[0].add fmt"{tile.id:04} {pos.rot:03} {f} "
                for i in (0 ..< tile_height):
                    let s = tile.slice(sangle=90, offset=i, rot=pos.rot, hflip=pos.hflip)
                    lines[tile_height - i].add $s.join("") & " "
            else:
                for i in (0 ..< lines.len):
                    lines[i].add "           "
        for i in lines:
            result.add i & "\n"
        dec y
