#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

require "dxruby"


class LoadingAnime

  attr_accessor :id, :name, :is_anime
  attr_reader :width, :height

  if __FILE__ == $0 then
    require "../lib/dxruby/images"
    IMAGES =  Dir.glob("../images/loading_kingyo_*.png")
  else
    require "./lib/dxruby/images"
    IMAGES =  Dir.glob("./images/loading_kingyo_*.png")
  end

  ANIME_SPEED = 0.3

  def initialize(x=0, y=0, width=100, height=100, z=0, id=0, name="loading_image", target=Window)

    images = []
    IMAGES.each do |image_src|
      image = Image.load(image_src)
      images.push(image)
    end

    scale_x = width / images[0].width.to_f if width
    scale_y = height / images[0].height.to_f if height
    scale_x = scale_y unless width
    scale_y = scale_x unless height

    @images = []
    images.each do |image|
      @images.push(Images.scale_resize(image, scale_x, scale_y))
    end

    @x = x
    @y = y
    @width = @images[0].width
    @height = @images[0].height
    @z = z

    @id = id
    @name = name
    @target = target

    @image = @images[0]

    @frame_count = 0
    @anime_count = 0
    @is_anime = false
  end

  def set_pos(x, y)
    @x = x
    @y = y
  end

  def update

    if @is_anime then
      if @frame_count * ANIME_SPEED / @images.size < @images.size then
        @image = @images[@frame_count * ANIME_SPEED / @images.size]
      else
        @frame_count = 0
      end
      @frame_count += 1
    end
  end

  def draw
    @target.draw(@x, @y, @image, @z)
  end
end


if __FILE__ == $0 then

  Window.width = 1280
  Window.height = 720

  loading_kingyo = LoadingAnime.new(0, 0, nil, Window.height * 0.3)
  loading_kingyo.set_pos(0, Window.height - loading_kingyo.height)
  loading_kingyo.is_anime = true

  Window.bgcolor = C_GREEN
  Window.loop do
    loading_kingyo.update if loading_kingyo.is_anime
    loading_kingyo.draw if loading_kingyo.is_anime
  end
end
