import raylib, std/lenientops
import std/random
import std/sequtils
import std/math


randomize()
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
    hp = 10
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
  enemies: seq[Entity] = @[]

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

proc game_input(theta: float) =
  if isKeyDown(A):
    var val = if angle <= 180: 1 else: 0
    angle += val.toFloat
  if isKeyDown(D):
    var val = if angle >= 0: 1 else: 0
    angle += -val.toFloat
  if isKeyDown(Space):
    var b = Bullet(x: ship.dest.x, y: ship.dest.y, r:5, c: Orange, s: 3, a: radToDeg theta)
    seqBullets.add(b)

proc add_enemies(n: int) =
  if enemies.len < n:
    var ent: Entity
    ent.texture = loadTexture("resources/eye.png")
    ent.source = Rectangle(x: 0, y: 0, width: ent.texture.width.toFloat, height: ent.texture.height.toFloat)
    ent.dest = Rectangle(x: rand(0..screenWidth).float32, y: rand(0..screenHeight).float32, width: ent.texture.width.toFloat, height: ent.texture.height.toFloat)
    ent.origin = Vector2(x: ent.texture.width.toFloat/2, y:ent.texture.height.toFloat/2)
    enemies.add(ent)

proc collissions() =
  var 
    delete: seq[int] = @[]
    bulldelete: seq[int] = @[]
  for enemy in enemies.mitems:
    for bullet in seqBullets.mitems:
      var
        center = Vector2(x: bullet.x, y:bullet.y)
        radius: float32 = 5

      if checkCollisionCircleRec(center, radius, enemy.dest):
        # bulldelete.add(seqBullets.find(bullet))
        enemy.hp -= 1

      if enemy.hp <= 0:
        if enemies.find(enemy) notin delete:
          delete.add(enemies.find(enemy))
    
  if delete.len > 0:
    for val in 0..<delete.len:
      enemies.delete(delete[delete.len-1 - val])

  if bulldelete.len > 0:
    echo bulldelete
    for vval in 0..<bulldelete.len:
      enemies.delete(bulldelete[bulldelete.len-1 - vval])



proc updateGame =
  var
    plusX = distance * cos degToRad angle
    plusY = distance * sin degToRad angle
    dx = ccenter.x - ship.dest.x
    dy = ccenter.y - ship.dest.y
    theta = arctan2(dy, dx)

  ship.dest.x = ccenter.x + plusX
  ship.dest.y = ccenter.y + plusY

  game_input(theta)
  add_enemies(5)
  collissions()

  for bullet in seqBullets.mitems:
    var 
      px = bullet.s * cos degToRad bullet.a
      py = bullet.s * sin degToRad bullet.a

    bullet.x += px
    bullet.y += py
  



proc drawGame =
  beginDrawing()
  clearBackground(RayWhite)

  drawCircleLines(ccenter.x, ccenter.y, distance, DarkBlue)
  draw eye
  drawCircleLines(ccenter.x, ccenter.y, 5, Red)

  for circ in seqBullets:
    drawCircle(circ.x.int32, circ.y.int32, circ.r, circ.c)

  for enemy in enemies.mitems:
    draw enemy


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
