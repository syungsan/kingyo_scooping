#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

require "dxruby"


class BgmInfo < Sprite

  attr_accessor :shadow_x, :shadow_y, :name, :id, :is_drag, :mode, :acceleration, :initial_velocity
  attr_reader :width, :height

  if __FILE__ == $0 then
    require "../lib/dxruby/fonts"
    require "../lib/dxruby/roundbox"
  else
    require "./lib/dxruby/fonts"
    require "./lib/dxruby/roundbox"
  end

  SHADOW_OFFSET_X = 5
  SHADOW_OFFSET_Y = 5

  def initialize(x=0, y=0, width=300, height=100, option={})
    option = {:frame_thickness=>2, :radius=>10, :bg_color=>C_WHITE, :frame_color=>C_GREEN, :max_wait_count=>120,
              :acceleration=>-9.8, :initial_velocity=>-82.0, :name=>"bgm_info", :id=>0, :target=>Window, :is_drag=>false}.merge(option)
    super()

    @frame_thickness = option[:frame_thickness]
    @radius = option[:radius]
    @bg_color = option[:bg_color]
    @frame_color = option[:frame_color]
    @max_wait_count = option[:max_wait_count]

    self.x = x
    self.y = y
    @width = width
    @height = height

    self.target = option[:target]
    @id = option[:id]
    @name = option[:name]
    @is_drag = option[:is_drag]

    @shadow_x = SHADOW_OFFSET_X
    @shadow_y = SHADOW_OFFSET_Y

    @acceleration = option[:acceleration]
    @initial_velocity = option[:initial_velocity]

    @first_pos_x = x
    @frame = 0
    @wait_count = 0
    @mode = :wait

    self.image = Image.new(@width, @height)

    @title_label = Fonts.new()
    @data_label = Fonts.new()
    @copyright_label = Fonts.new()

    @title_label.target = self.image
    @data_label.target = self.image
    @copyright_label.target = self.image

    self.constract
  end

  def set_pos(x, y)
    self.x = x
    self.y = y
  end

  def constract

    self.image.clear
    self.image.roundbox_fill(0, 0, @width, @height, @radius, [128] + @bg_color)

    @frame_thickness.times do |index|
      self.image.roundbox(index, index, @width - 1 - index, @height - 1 - index, @radius, @frame_color)
    end
    @shadow = self.image.flush([64, 0, 0, 0])
  end

  def set_info(info={:title=>nil, :data=>nil, :copyright=>nil}, font_name={:title=>nil, :data=>nil, :copyright=>nil},
               font_size={:title=>30, :data=>24, :copyright=>28}, font_color={:title=>C_WHITE, :data=>C_WHITE, :copyright=>C_WHITE},
               italic={:title=>false, :data=>true, :copyright=>false}, weight={:title=>800, :data=>800, :copyright=>800})

    self.constract

    @title_label.string = info[:title]
    @data_label.string = info[:data]
    @copyright_label.string = info[:copyright]

    @title_label.size = font_size[:title]
    @data_label.size = font_size[:data]
    @copyright_label.size = font_size[:copyright]

    @title_label.color = font_color[:title]
    @data_label.color = font_color[:data]
    @copyright_label.color = font_color[:copyright]

    @title_label.font_name = font_name[:title]
    @data_label.font_name = font_name[:data]
    @copyright_label.font_name = font_name[:copyright]

    @title_label.set_italic = italic[:title]
    @data_label.set_italic = italic[:data]
    @copyright_label.set_italic = italic[:copyright]

    @title_label.set_weight = weight[:title]
    @data_label.set_weight = weight[:data]
    @copyright_label.set_weight = weight[:copyright]

    margin_y = (@height - (@title_label.height + @data_label.height + @copyright_label.height)) * 0.5

    @title_label.set_pos((@width - @title_label.width) * 0.5, margin_y)
    @data_label.set_pos((@width - @data_label.width) * 0.5, margin_y + @title_label.height)
    @copyright_label.set_pos((@width - @copyright_label.width) * 0.5, margin_y + @title_label.height + @data_label.height)

    @title_label.draw
    @data_label.draw
    @copyright_label.draw
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
          @frame = 0
          @wait_count = 0
          @mode = :wait
        end
      end
    end
  end

  def draw
    self.target.draw(self.x + @shadow_x, self.y + @shadow_y, @shadow, self.z)
    self.target.draw(self.x, self.y, self.image, self.z)
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

  bgm_info_height = Window.height * 0.15
  bgm_info_width = bgm_info_height * 2.7

  bgm_info = BgmInfo.new(Window.width, Window.height * 0.04, bgm_info_width, bgm_info_height)
  bgm_info.set_info({:title=>MAIN_BGM_DATE[0], :data=>MAIN_BGM_DATE[1], :copyright=>MAIN_BGM_DATE[2]},
                    {:title=>TANUKI_MAGIC_FONT_TYPE, :data=>TANUKI_MAGIC_FONT_TYPE, :copyright=>TANUKI_MAGIC_FONT_TYPE},
                    {:title=>bgm_info.height * 0.3, :data=>bgm_info.height * 0.2, :copyright=>bgm_info.height * 0.25})
  bgm_info.initial_velocity = -1 * Math.sqrt(Window.height * 8.7)
  bgm_info.mode = :run

  Window.bgcolor = C_BLUE
  Window.loop do
    bgm_info.update if bgm_info.mode == :run
    bgm_info.draw if bgm_info.mode == :run
  end
end
