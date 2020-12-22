#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

require "dxruby"


class Container < Sprite

  attr_accessor :shadow_x, :shadow_y, :name, :id, :is_drag
  attr_reader :width, :height, :collision_ratios

  if __FILE__ == $0 then
    require "../lib/dxruby/images"
    IMAGE = "../images/container.png"
  else
    require "./lib/dxruby/images"
    IMAGE = "./images/container.png"
  end

  SHADOW_OFFSET_X = 5
  SHADOW_OFFSET_Y = 5
  ALPHA = 164
  BORDER_COLLISION_RATIOS = [0, 0, 0, 0]

  def initialize(x=0, y=0, width=100, height=100, is_drag=true, name="container", id=0, target=Window)
    super()

    image = Image.load(IMAGE)
    shadow = image.flush([64, 0, 0, 0])
    images = [image, shadow]

    scale_x = width / image.width.to_f if width
    scale_y = height / image.height.to_f if height
    scale_x = scale_y unless width
    scale_y = scale_x unless height

    @images = []
    images.each do |image|
      @images.push(Images.scale_resize(image, scale_x, scale_y))
    end

    self.x = x
    self.y = y
    self.image = @images[0]
    @width = self.image.width
    @height = self.image.height
    self.collision = [@width * 0.5, @height * 0.5, @width * 0.5]
    self.target = target
    @is_drag = is_drag
    @name = name
    @id = id
    @shadow_x = SHADOW_OFFSET_X
    @shadow_y = SHADOW_OFFSET_Y
    @collision_ratios = BORDER_COLLISION_RATIOS
  end

  def set_pos(x, y)
    self.x = x
    self.y = y
  end

  def update

  end

  def hit(obj)

  end

  def draw
    self.target.draw(self.x + @shadow_x, self.y + @shadow_y, @images[1], self.z)
    self.target.draw_ex(self.x, self.y, self.image, {:z=>self.z, :alpha=>ALPHA})
  end
end


if __FILE__ == $0 then

  Window.width = 1980
  Window.height = 1080

  height_size = Window.height * 0.37
  container = Container.new(0, 0, nil, height_size)
  container.x = (Window.width - container.width) * 0.5
  container.y = (Window.height - container.height) * 0.5

  Window.bgcolor = C_GREEN
  Window.loop do
    container.draw
  end
end
