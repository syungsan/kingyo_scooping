#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

require "dxruby"

KIND_OF_KINGYOS = ["red", "black"]
KINGYO_IMAGES = ["../images/kingyo03.png", "../images/demekin_black.png"]

SHADOW_OFFSET_X = 5
SHADOW_OFFSET_Y = 5


class Kingyo < Sprite

  attr_accessor :id, :name, :is_drag
  attr_reader :width, :height

  @@images = []
  KINGYO_IMAGES.each do |kingyo_image|
    image0 = Image.load_tiles(kingyo_image, 4, 1, true)
    image1 = image0.map { |image| image.flush([64, 0, 0, 0]) }
    images = [image0, image1]
    @@images.push(images)
  end

  def initialize(x, y, kind_of, angle=0, scale=1, id=0, target=Window, is_drag=false)
    super()

    @kind_of = kind_of

    image_src = @@images[KIND_OF_KINGYOS.index(@kind_of)][0][0]
    render_target = RenderTarget.new(image_src.width * scale, image_src.height * scale)
    @@images[KIND_OF_KINGYOS.index(@kind_of)].size.times do |index|
      @@images[KIND_OF_KINGYOS.index(@kind_of)][index].map do |image|
        render_target.draw_scale(image_src.width * (scale - 1.0) * 0.5, image_src.height * (scale - 1.0) * 0.5, image, scale, scale)
        @@images[KIND_OF_KINGYOS.index(@kind_of)][index][@@images[KIND_OF_KINGYOS.index(@kind_of)][index].index(image)] = render_target.to_image
      end
    end
    render_target.dispose

    self.x = x
    self.y = y
    self.image = @@images[KIND_OF_KINGYOS.index(@kind_of)][0][0]
    @width = self.image.width
    @height = self.image.height
    self.collision = [0, 0, @width, @height]
    self.target = target
    self.angle = angle
    @id = id
    @name = "#{kind_of}_kingyo"
    @is_drag = is_drag
    @anime_count = 0
  end

  def update
    @anime_count += 0.1
    @anime_count = 0 if @anime_count > @@images[KIND_OF_KINGYOS.index(@kind_of)][0].size
    self.image = @@images[KIND_OF_KINGYOS.index(@kind_of)][0][@anime_count.floor]
    @shadow_image = @@images[KIND_OF_KINGYOS.index(@kind_of)][1][@anime_count.floor]
  end

  def draw
    self.target.draw_ex(self.x + SHADOW_OFFSET_X, self.y + SHADOW_OFFSET_Y, @shadow_image, { :angle=>self.angle })
    self.target.draw_ex(self.x, self.y, self.image, { :angle=>self.angle })
  end

end


if __FILE__ == $0

  kingyo_red = Kingyo.new(0, 0, "red")
  kingyo_black = Kingyo.new(kingyo_red.width, kingyo_red.height, "black")

  Window.bgcolor = C_WHITE
  Window.loop do
    kingyo_red.update
    kingyo_red.draw
    kingyo_black.update
    kingyo_black.draw
  end
end