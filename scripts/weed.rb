#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

require "dxruby"

if __FILE__ == $0 then
  WEED_IMAGE = "../images/kingyomo001.png"
else
  WEED_IMAGE = "./images/kingyomo001.png"
end

WEED_SHADOW_OFFSET_X = 5
WEED_SHADOW_OFFSET_Y = 5


class Weed < Sprite

  attr_accessor :id, :name, :is_drag, :mode, :is_reserved
  attr_reader :width, :height

  def initialize(x, y, angle=0, scale=1, id=0, target=Window, is_drag=false)
    super()

    image0 = Image.load(WEED_IMAGE)
    image1 = image0.flush([64, 0, 0, 0])
    images = [image0, image1]

    render_target = RenderTarget.new(images[0].width * scale, images[0].height * scale)
    @images = []
    images.each do |image|
      render_target.draw_scale(image.width * (scale - 1.0) * 0.5, image.height * (scale - 1.0) * 0.5, image, scale, scale)
      @images.push(render_target.to_image)
      image.dispose
    end
    render_target.dispose

    self.x = x
    self.y = y
    self.image = @images[0]
    @width = self.image.width
    @height = self.image.height
    self.collision = [0, 0, @width, @height]
    self.target = target
    self.angle = angle
    @id = id
    @name = "weed"
    @is_drag = is_drag
  end

  def update

  end

  def hit(obj)

  end

  def draw
    self.target.draw_ex(self.x + WEED_SHADOW_OFFSET_X, self.y + WEED_SHADOW_OFFSET_Y, @images[1], {:z=>self.z, :angle=>self.angle})
    self.target.draw_ex(self.x, self.y, self.image, {:z=>self.z, :angle=>self.angle})
  end
end


if __FILE__ == $0 then

  require "../lib/common"
  include Common

  weeds = []
  30.times do
    weed = Weed.new(0, 0, rand(360), rand_float(0.4, 0.8))
    weed.x = random_int(0, Window.width - weed.width)
    weed.y = random_int(0, Window.height - weed.height)
    weeds.push(weed)
  end

  Window.loop do
    weeds.each do |weed|
      weed.draw
    end
  end
end
