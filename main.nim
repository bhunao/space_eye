import raylib, std/lenientops
import std/sequtils
import std/math


const
  screenWidth = 800
  screenHeight = 600

type
  Entity = object
    texture: Texture
    source: Rectangle
    dest: Rectangle
    origin: Vector2
    rotation = 0.0
    speed = Vector2(x: 0, y:0)
  point = object
    x: int = screenWidth div 2
    y: int = screenHeight div 3
  Bullet = object
    x: float
    y: float
    r: float
    c: Color
    s: float = 1
    a: float = 45

var
  ship: Entity
  eye: Entity
  distance: float = 350
  angle: float = 90
  ccenter = point()
  seqBullets: seq[Bullet] = @[]

proc initGame =
  ship.texture = loadTexture("resources/ship.png")
  ship.source = Rectangle(x: 0, y: 0, width: ship.texture.width.toFloat, height: ship.texture.height.toFloat)
  ship.dest = Rectangle(x: screenWidth/2, y: screenHeight/2, width: ship.texture.width.toFloat, height: ship.texture.height.toFloat)
  ship.origin = Vector2(x: ship.texture.width.toFloat/2, y:ship.texture.height.toFloat/2)

  eye.texture = loadTexture("resources/eye.png")
  eye.source = Rectangle(x: 0, y: 0, width: eye.texture.width.toFloat, height: eye.texture.height.toFloat)
  eye.dest = Rectangle(x: ccenter.x, y: ccenter.y, width: eye.texture.width.toFloat, height: eye.texture.height.toFloat)
  eye.origin = Vector2(x: eye.texture.width.toFloat/2, y:eye.texture.height.toFloat/2)

proc draw*(entity: var Entity) =
  drawTexture(
    entity.texture,
    entity.source,
    entity.dest,
    entity.origin,
    entity.rotation,
    White
  )

proc updateGame =
  var
    plusX = distance * cos degToRad angle
    plusY = distance * sin degToRad angle
    dx = ccenter.x - ship.dest.x
    dy = ccenter.y - ship.dest.y
    theta = arctan2(dy, dx)

  echo radToDeg theta

  ship.dest.x = ccenter.x + plusX
  ship.dest.y = ccenter.y + plusY

  if isKeyDown(A):
    var val = if angle <= 180: 1 else: 0
    angle += val.toFloat
  if isKeyDown(D):
    var val = if angle >= 0: 1 else: 0
    angle += -val.toFloat
  if isKeyDown(Space):
    var b = Bullet(x: ship.dest.x, y: ship.dest.y, r:5, c: Orange, s: 3, a: radToDeg theta)
    seqBullets.add(b)

  for bullet in seqBullets.mitems:
    var 
      px = bullet.s * cos degToRad bullet.a
      py = bullet.s * sin degToRad bullet.a

    bullet.x += px
    bullet.y += py
  

  echo seqBullets.len


proc drawGame =
  beginDrawing()
  clearBackground(RayWhite)

  drawCircleLines(ccenter.x, ccenter.y, distance, DarkBlue)
  draw eye
  drawCircleLines(ccenter.x, ccenter.y, 5, Red)

  for circ in seqBullets:
    drawCircle(circ.x.int32, circ.y.int32, circ.r, circ.c)


  draw ship

  endDrawing()

proc unloadGame =
  # Unload game variables
  # TODO: Unload all dynamic loaded data (textures, sounds, models...)
  discard

proc updateDrawFrame {.cdecl.} =
  updateGame()
  drawGame()


proc main =
  initWindow(screenWidth, screenHeight, "Naylib Web Template")
  try:
    initGame()
    when defined(emscripten):
      emscriptenSetMainLoop(updateDrawFrame, 60, 1)
    else:
      setTargetFPS(60)
      while not windowShouldClose():
        updateDrawFrame()
    unloadGame()
  finally:
    closeWindow()

main()
