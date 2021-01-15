#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

require "dxruby"


class Splash < Sprite

  attr_accessor :id, :name, :is_drag, :mode
  attr_reader :width, :height

  if __FILE__ == $0 then
    IMAGE = "../images/water_splash.png"
  else
    IMAGE = "./images/water_splash.png"
  end

  SHADOW_OFFSET_X = 3
  SHADOW_OFFSET_Y = 3
  ALPHA = 142

  def initialize(div_x, div_y, id=0, name="splash", target=Window, is_drag=false)
    super()

    images = Image.load_tiles(IMAGE, div_x, div_y, true)
    shadows = images.map { |image| image.flush([64, 0, 0, 0]) }
    @images = [images, shadows]
    self.image = @images[0][0]
    @width = self.image.width
    @height = self.image.height
    @shadow = @images[1][0]

    self.target = target
    self.alpha = ALPHA

    @is_drag = is_drag
    @id = id
    @name = name
    @mode = :wait
  end

  def run(x, y, draw_target, wide, delay)

    self.x = x
    self.y = y
    self.z = draw_target.z - 1
    self.angle = rand(360)
    self.scale_x = wide / @width
    self.scale_y = wide / @height

    @delay = delay
    @anime_count = 0
    @mode = :run
  end

  def update

    if @mode == :run then
      if @anime_count < @delay * 60 then

        image_no = @anime_count / (@delay * 60 / @images[0].size)
        self.image = @images[0][image_no]
        @shadow = @images[1][image_no]
        @anime_count += 1
      else
        @anime_count = 0
        @mode = :finish
        self.vanish
      end
    end
  end

  def draw
    self.target.draw_ex(self.x + SHADOW_OFFSET_X, self.y + SHADOW_OFFSET_Y,
                        @shadow, {:scale_x=>self.scale_x, :scale_y=>self.scale_y,
                                  :z=>self.z, :angle=>self.angle, :alpha=>self.alpha})

    self.target.draw_ex(self.x, self.y, self.image, {:scale_x=>self.scale_x, :scale_y=>self.scale_y,
                                                     :z=>self.z, :angle=>self.angle, :alpha=>self.alpha})
  end
end


if __FILE__ == $0 then

  Window.width = 800
  Window.height = 600

  target = Sprite.new(0, 0, Image.new(100, 100).circle_fill(50, 50, 50, C_RED))
  target.x = (Window.width - target.image.width) * 0.5
  target.y = (Window.height - target.image.height) * 0.5

  splash = Splash.new(10, 1)
  splash.run(target.x + target.center_x - (splash.width * 0.5),
             target.y + target.center_y - (splash.height * 0.5), target, 300, 0.8)

  Window.bgcolor = C_GREEN
  Window.loop do
    target.draw
    if splash.mode == :run
      splash.update
      splash.draw
    end
  end
end
