#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

require "dxruby"

if __FILE__ == $0 then
  CONTAINER_IMAGE = "../images/container.png"
else
  CONTAINER_IMAGE = "./images/container.png"
end

CONTAINER_SHADOW_OFFSET_X = 5
CONTAINER_SHADOW_OFFSET_Y = 5

CONTACT_OBJECT_Z_POSITION = 0
LEAVE_OBJECT_Z_POSITION = 200

CONTACT_ADJUST_RANGE_RATIO = 1.2
RESERVE_ADJUST_RANGE_RATIO = 0.6


class Container < Sprite

  attr_accessor :id, :name, :is_drag
  attr_reader :width, :height

  def initialize(x, y, scale=1, id=0, target=Window, is_drag=true)
    super()

    image = Image.load(CONTAINER_IMAGE)
    shadow_image = image.flush([64, 0, 0, 0])
    container_images = [image, shadow_image]

    @container_images = []
    container_images.each do |container_image|
      render_target = RenderTarget.new(container_image.width * scale, container_image.height * scale)
      render_target.draw_scale(container_image.width * (scale - 1.0) * 0.5, container_image.height * (scale - 1.0) * 0.5, container_image, scale, scale)
      @container_images.push(render_target.to_image)
      container_image.dispose
      render_target.dispose
    end

    self.x = x
    self.y = y
    self.image = @container_images[0]
    @width = self.image.width
    @height = self.image.height
    self.collision = [@width * 0.5, @height * 0.5, @width * 0.5]
    self.target = target
    @id = id
    @name = "container"
    @is_drag = is_drag
  end

  def update

  end

  def draw
    self.target.draw(self.x + CONTAINER_SHADOW_OFFSET_X, self.y + CONTAINER_SHADOW_OFFSET_Y, @container_images[1], self.z)
    self.target.draw_ex(self.x, self.y, self.image, {:z=>self.z, :alpha=>164})
  end

  def hit(obj)

    case obj.name

    when "red_kingyo", "black_kingyo"
      if not obj.mode == "catched" and not obj.is_reserved then
        if (obj.x + obj.center_x - (self.x + (@width * 0.5))) ** 2 + ((obj.y + obj.center_y - (self.y + (@height * 0.5))) ** 2) <= (@width * 0.5 * CONTACT_ADJUST_RANGE_RATIO) ** 2 then
          obj.z = CONTACT_OBJECT_Z_POSITION
        else
          obj.z = LEAVE_OBJECT_Z_POSITION
        end
      elsif obj.is_reserved then
        max_radius = @width * 0.5 * RESERVE_ADJUST_RANGE_RATIO
        obj_radius = Math.sqrt((obj.x + obj.center_x - (self.x + self.center_x)) ** 2 + ((obj.y + obj.center_y - (self.y + self.center_y)) ** 2))

        if obj_radius >= max_radius then
          angle = Math.atan2(obj.y + obj.center_y - (self.y + self.center_y), obj.x + obj.center_x - (self.x + self.center_x))
          obj.x = self.x + self.center_x - (obj.width * 0.5) + (max_radius * Math.cos(angle))
          obj.y = self.y + self.center_y - (obj.height * 0.5) + (max_radius * Math.sin(angle))
        end
      end
    end
  end
end


if __FILE__ == $0 then

  Window.width = 1280
  Window.height = 720

  container = Container.new(0, 0, 0.8)
  container.x = (Window.width - container.width) * 0.5
  container.y = (Window.height - container.height) * 0.5

  Window.loop do
    container.draw
  end
end
