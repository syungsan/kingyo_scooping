#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

require "dxruby"


KIND_OF_KINGYOS = ["red", "black"]
KINGYO_IMAGES = ["../images/kingyo03.png", "../images/demekin_black.png"]


class Kingyo < Sprite

  @@images = []
  KINGYO_IMAGES.each do |kingyo_image|
    image0 = Image.load_tiles(kingyo_image, 4, 1, true)
    image1 = image0.map { |image| image.flush([64, 0, 0, 0]) }
    images = [image0, image1]
    @@images.push(images)
  end

  def initialize(x, y, kind_of, target=Window)
    super()

    self.x = x
    self.y = y
    @kind_of = kind_of
    self.image = @@images[KIND_OF_KINGYOS.index(@kind_of)][0][0]
    self.target = target
    @anime_count = 0
  end

  def update
    @anime_count += 0.1
    @anime_count = 0 if @anime_count > @@images[KIND_OF_KINGYOS.index(@kind_of)][0].size
  end

  def draw
    self.target.draw_ex(self.x, self.y, @@images[KIND_OF_KINGYOS.index(@kind_of)][0][@anime_count.floor])
  end

end


if __FILE__ == $0

  kingyo = Kingyo.new(0, 0, "red")

  Window.loop do
    kingyo.update
    kingyo.draw
  end
end