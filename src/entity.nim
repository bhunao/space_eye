import raylib


type
  Entity* = object
    texture*: Texture
    source*: Rectangle
    dest*: Rectangle
    origin*: Vector2
    rotation* = 0.0
    speed* = Vector2(x: 0, y:0)
    hp* = 10
    angle*: float = 90
    distance*: float = 30
  Circle* = object
    x, y: float
    r: float
  Origin = enum
    MID, TOPLEFT

proc initEntity*(x, y: float, path: string, origin: Origin = MID): Entity =
  result.texture = loadTexture(path)
  result.source = Rectangle(x: 0, y: 0, width: result.texture.width.toFloat, height: result.texture.height.toFloat)
  result.dest = Rectangle(x: x, y: y, width: result.texture.width.toFloat, height: result.texture.height.toFloat)
  case origin:
  of MID:
    result.origin = Vector2(x: result.texture.width.toFloat/2, y:result.texture.height.toFloat/2)
  of TOPLEFT:
    result.origin = Vector2(x: 0, y: 0)

proc draw*(entity: var Entity, rotation: float = 0) =
  drawTexture(
    entity.texture,
    entity.source,
    entity.dest,
    entity.origin,
    rotation,
    White
  )

