#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

require "dxruby"

if __FILE__ == $0 then
  require "../lib/dxruby/fonts"
  require "../lib/dxruby/roundbox"
else
  require "./lib/dxruby/fonts"
  require "./lib/dxruby/roundbox"
end


class BgmInfo < Sprite

  attr_accessor :id, :name, :is_drag, :mode
  attr_reader :width, :height


  def initialize(x, y, z, width=300, height=100, max_wait_count=120, border_width=1, radius=10, bg_color=C_WHITE, border_color=C_GREEN, id=0, target=Window, is_drag=false)
    super()

    image = Image.new(width, height).roundbox_fill(0, 0, width - border_width, height - border_width, radius, bg_color.unshift(128))
    frame = Image.new(width, height).roundbox(0, 0, width - border_width, height - border_width, radius, border_color)
    image.draw(0, 0, frame)
    @shadow = image.flush([64, 0, 0, 0])

    self.x = x
    self.y = y
    self.image = image
    self.target = target
    @z = z
    @width = self.image.width
    @height = self.image.height
    @id = id
    @name = "bgm_info"
    @is_drag = is_drag
    @first_pos_x = x
    @acceleration = -9.8
    @initial_velocity = -80.0
    @frame = 0
    @max_wait_count = max_wait_count
    @wait_count = 0
    @mode = :wait
  end

  def set_info(info={:title=>nil, :data=>nil, :copyright=>nil}, font_type={:title=>nil, :data=>nil, :copyright=>nil}, font_color={:title=>C_WHITE, :data=>C_WHITE, :copyright=>C_WHITE}, font_size={:title=>30, :data=>24, :copyright=>28}, italic={:title=>false, :data=>true, :copyright=>false}, weight={:title=>800, :data=>800, :copyright=>800})

    font0 = Fonts.new(0, 0, info[:title], font_size[:title], font_color[:title], 0, "title_font", {:target=>self.image, :fontType=>font_type[:title], :isItalic=>italic[:title], :isBold=>weight[:title]})
    font1 = Fonts.new(0, 0, info[:data], font_size[:data], font_color[:data], 0, "data_font", {:target=>self.image, :fontType=>font_type[:data], :isItalic=>italic[:data], :isBold=>weight[:data]})
    font2 = Fonts.new(0, 0, info[:copyright], font_size[:copyright], font_color[:copyright], 0, "copyright_font", {:target=>self.image, :fontType=>font_type[:copyright], :isItalic=>italic[:copyright], :isBold=>weight[:copyright]})

    margin_y = (@height - (font0.get_height + font0.get_height + font1.get_height)) * 0.5

    font0.set_pos((@width - font0.get_width) * 0.5, margin_y)
    font1.set_pos((@width - font1.get_width) * 0.5, margin_y + font0.get_height)
    font2.set_pos((@width - font2.get_width) * 0.5, margin_y + font0.get_height + font1.get_height)

    font0.render
    font1.render
    font2.render
  end

  def update

    if @mode == :run
      if @initial_velocity - (@acceleration * @frame) < 0 then
        self.x = @first_pos_x + @initial_velocity * @frame - (0.5 * @acceleration * @frame * @frame)
        @frame += 0.1

      else
        if @wait_count >= @max_wait_count then
          self.x = @first_pos_x + @initial_velocity * @frame - (0.5 * @acceleration * @frame * @frame)
          @frame += 0.1
        end

        @wait_count += 1 if @wait_count < @max_wait_count
        if self.x >= @first_pos_x
          @mode = :wait
        end
      end
    end
  end

  def vanish

  end

  def draw
    self.target.draw(self.x, self.y, self.image, @z)
  end
end


if __FILE__ == $0 then

  Window.width = 1280
  Window.height = 720

  TANUKI_MAGIC_FONT = "../fonts/TanukiMagic.ttf"
  Font.install(TANUKI_MAGIC_FONT)
  TANUKI_MAGIC_FONT_TYPE = "たぬき油性マジック"

  require "../lib/encode"
  tilde =  "\x81\x60".encode("BINARY")

  MAIN_BGM_DATE = ["水面", "Composed by iPad", "しゅんじ" + tilde]

  bgm_info = BgmInfo.new(Window.width, Window.height * 0.04)
  bgm_info.set_info({:title=>MAIN_BGM_DATE[0], :data=>MAIN_BGM_DATE[1], :copyright=>MAIN_BGM_DATE[2]}, {:title=>TANUKI_MAGIC_FONT_TYPE, :data=>TANUKI_MAGIC_FONT_TYPE, :copyright=>TANUKI_MAGIC_FONT_TYPE})
  bgm_info.mode = :run

  Window.bgcolor = C_BLUE
  Window.loop do
    bgm_info.update if bgm_info.mode == :run
    bgm_info.draw if bgm_info.mode == :run
  end
end
