#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

require "dxruby"


class Boss < Sprite

  attr_accessor :shadow_x, :shadow_y, :name, :id, :is_drag, :is_reserved, :angle_candidate
  attr_reader :width, :height, :collision_ratios, :bubble_shots, :mode, :pre_mode

  if __FILE__ == $0 then
    require "../lib/common"
    require "../lib/dxruby/images"
    require "../lib/weighted_randomizer"
    require "../lib/dxruby/easing"
    IMAGE = "../images/boss_kingyo.PNG"
  else
    require "./lib/common"
    require "./lib/dxruby/images"
    require "./lib/weighted_randomizer"
    require "./lib/dxruby/easing"
    IMAGE = "./images/boss_kingyo.PNG"
  end

  include Common
  include Easing

  SHADOW_OFFSET_X = 5
  SHADOW_OFFSET_Y = 5

  ANIME_ADJUST_SPEED_RATIO = 0.05
  CATCHED_ANIME_SPEED_RATIO = 1.5

  BORDER_COLLISION_RATIOS_FOR_BOSS = [0.01, 0.2, 0.2, 0.01]

  MAX_BUBBLE_SHOT_NUMBER = 6
  IS_SHOT_BUBBLE = true

  def initialize(x=0, y=0, width=100, height=100, angle=0, id=0,
                 speed_ranges={:wait=>[0, 1], :move=>[1, 3], :escape=>[1, 3]},
                 mode_ranges={:wait=>[0, 200], :move=>[0, 100], :escape=>[0, 200]},
                 personality_weights = {:escape=>80, :ignore=>50, :against=>20},
                 escape_change_timing = 0.2, attack_target=nil, borders=nil, name="boss", target=Window, is_drag=false)
    super()

    image0 = Image.load_tiles(IMAGE, 4, 1, true)
    image1 = image0.map { |image| image.flush([64, 0, 0, 0]) }
    image01s = [image0, image1]

    scale_x = width / image0[0].width.to_f if width
    scale_y = height / image0[0].height.to_f if height
    scale_x = scale_y unless width
    scale_y = scale_x unless height

    @images = []
    image01s.each do |image01|
      images = []
      image01.map do |image|
        images.push(Images.scale_resize(image, scale_x, scale_y))
      end
      @images.push(images)
    end

    self.x = x
    self.y = y
    self.image = @images[0][0]
    @shadow_image = @images[1][0]
    @width = self.image.width
    @height = self.image.height
    self.collision = [0, 0, @width, @height]
    self.target = target
    self.angle = angle

    @shadow_x = SHADOW_OFFSET_X
    @shadow_y = SHADOW_OFFSET_Y

    @id = id
    @name = name
    @is_drag = is_drag
    @mode_ranges = mode_ranges
    @speed_ranges = speed_ranges
    @anime_count = 0
    @collision_ratios = BORDER_COLLISION_RATIOS_FOR_BOSS

    @escape_count = 0
    @escape_length = 0
    @personal_w_ran = WeightedRandomizer.new(personality_weights)
    @escape_cahange_timing = escape_change_timing

    @attack_target = attack_target
    @borders = borders

    @is_all_bubble_borned = false

    if IS_SHOT_BUBBLE then
      @bubble_shots = []
      MAX_BUBBLE_SHOT_NUMBER.times do
        bubble_shot = BubbleShot.new(nil, @height * 0.7, self, @attack_target, @borders)
        bubble_shot.change_mode(:preparation)
        @bubble_shots.push(bubble_shot)
      end
    end

    modes = [:wait, :move]
    self.change_mode(modes[rand(2)])
  end

  def set_pos(x, y)
    self.x = x
    self.y = y

    if @bubble_shots and not @bubble_shots.empty? and IS_SHOT_BUBBLE then
      @bubble_shots.each do |bubble_shot|
        bubble_shot.fit_pos_for_mother_ship
      end
    end
  end

  def update
    @anime_count += @speed * ANIME_ADJUST_SPEED_RATIO if @speed
    @anime_count = 0 if @anime_count > @images[0].size
    self.image = @images[0][@anime_count.floor]
    @shadow_image = @images[1][@anime_count.floor]

    case @mode
    when :wait
      self.wait

    when :move
      self.move

    when :escape
      self.escape

    when :catched
      self.catched

    when :reserved, :ignore, :broke
      modes = [:wait, :move]
      self.change_mode(modes[rand(2)])
    end

    if IS_SHOT_BUBBLE and @bubble_shots and not @bubble_shots.empty? then
      @bubble_shots.each do |bubble_shot|
        bubble_shot.update
      end
    end

    Sprite.check(@borders + @bubble_shots) if @borders and @bubble_shots and IS_SHOT_BUBBLE
    Sprite.check(@bubble_shots + [@attack_target]) if @bubble_shots and @attack_target and IS_SHOT_BUBBLE
  end

  def change_mode(mode)

    case mode

    when :wait
      @wait_count = 0
      @wait_length = random_int(@mode_ranges[:wait][0], @mode_ranges[:wait][1])
      @speed = rand_float(@speed_ranges[:wait][0], @speed_ranges[:wait][1])
      @old_speed = @speed

    when :move
      @move_count = 0
      @move_time = 0
      @move_length = random_int(@mode_ranges[:move][0], @mode_ranges[:move][1])
      @speed = rand_float(@speed_ranges[:move][0], @speed_ranges[:move][1])
      @old_speed = @speed
      self.angle = rand(360)

    when :escape

      @escape_count = 0 if @escape_count > @escape_length * @escape_cahange_timing

      if @escape_count == 0 then
        personality = @personal_w_ran.sample
        @angle_candidate = @angle_candidate + 180 if personality == :against

        if personality == :escape or personality == :against then
          self.angle = @angle_candidate
          @escape_length = random_int(@mode_ranges[:escape][0], @mode_ranges[:escape][1])
          @speed = rand_float(@speed_ranges[:escape][0], @speed_ranges[:escape][1])
          @old_speed = @speed
        else
          mode = :ignore
        end
      end

    when :catched
      @pre_mode = @mode

    when :broke
    end
    @mode = mode
  end

  def wait
    if @wait_count > @wait_length then
      self.change_mode(:move)
    else
      @wait_count += 1
    end
  end

  def move

    if @move_count >= @move_length then
      self.change_mode(:wait)
    else
      half_length = @move_length / 2
      radian = (self.angle - 90) * (Math::PI / 180)

      if @move_count < half_length.round then
        in_speed = ease_in_out_quad(@move_time, 0, @old_speed, half_length.round * 0.01)
        if not in_speed.nan? then
          self.x += Math.cos(radian) * in_speed
          self.y += Math.sin(radian) * in_speed
          @speed = in_speed
          @move_time += 0.01
        end

      elsif @move_count == half_length.round then
        @move_time = 0
        @move_count += 1

      elsif @move_count > half_length.round then
        out_speed = ease_in_out_quad(@move_time, @old_speed, -1 * @old_speed, half_length.round * 0.01)
        if not out_speed.nan? then
          self.x += Math.cos(radian) * out_speed
          self.y += Math.sin(radian) * out_speed
          @speed = out_speed
          @move_time += 0.01
        end
      end
      @move_count += 1
    end
  end

  def escape
    if @escape_count > @escape_length then
      modes = [:wait, :move]
      self.change_mode(modes[rand(2)])
    else
      radian = (self.angle - 90) * (Math::PI / 180)
      self.x += Math.cos(radian) * @speed
      self.y += Math.sin(radian) * @speed
      @escape_count += 1
    end
  end

  def catched
    @speed = @old_speed * CATCHED_ANIME_SPEED_RATIO if @speed == @old_speed
  end

  def hit(obj)

  end

  def draw

    self.target.draw_ex(self.x + @shadow_x, self.y + @shadow_y, @shadow_image, {:z=>self.z, :angle=>self.angle})
    self.target.draw_ex(self.x, self.y, self.image, {:z=>self.z, :angle=>self.angle})

    if @bubble_shots and not @bubble_shots.empty? then
      @bubble_shots.each do |bubble_shot|
        bubble_shot.draw
      end
    end
  end


  class BubbleShot < Sprite

    attr_accessor :shadow_x, :shadow_y, :name, :id, :is_drag, :killed_by_poi
    attr_reader :width, :height, :collision_ratios

    if __FILE__ == $0 then
      IMAGE_0 = "../images/bubble_0.PNG"
      IMAGE_1 = "../images/bubble_1.PNG"
      BORN_SOUND = "../sounds/sei_ge_bubble02.wav"
      BURST_SOUND = "../sounds/bubble-burst1.wav"
    else
      IMAGE_0 = "./images/bubble_0.PNG"
      IMAGE_1 = "./images/bubble_1.PNG"
      BORN_SOUND = "./sounds/sei_ge_bubble02.wav"
      BURST_SOUND = "./sounds/bubble-burst1.wav"
    end

    BORDER_COLLISION_RATIOS_FOR_BUBBLE_SHOT = [0, 0, 0, 0]

    MOVE_SPEED = 2.0
    SCALE_UP_SPEED = 0.001

    MAX_BURST_WAIT_COUNT = 30
    MAX_WAIT_COUNT = 30
    MAX_BORN_SPAN = 720

    def initialize(width=100, height=100, mother_ship=nil, attack_target=nil, borders=nil,
                   id=0, name="bubble_shot", target=Window, is_drag=false)
      super

      @born_sound = Sound.new(BORN_SOUND)
      @burst_sount = Sound.new(BURST_SOUND)

      image_0 = Image.load(IMAGE_0)
      image_1 = Image.load(IMAGE_1)

      images = [image_0, image_1]

      scale_x = width / images[0].width.to_f if width
      scale_y = height / images[0].height.to_f if height
      scale_x = scale_y unless width
      scale_y = scale_x unless height

      @images = []
      images.each do |image|
        @images.push(Images.scale_resize(image, scale_x, scale_y))
      end

      self.image = @images[0]
      @width = self.image.width
      @height = self.image.height

      self.collision = [@width* 0.5, @width * 0.5, @width * 0.5]
      self.target = target

      @id = id
      @name = name
      @is_drag = is_drag

      @collision_ratios = BORDER_COLLISION_RATIOS_FOR_BOSS

      @mother_ship = mother_ship
      @attack_target = attack_target
      @borders = borders

      @burst_wait_count = 0
      @preparation_count = 0
      @shot_direction_radian = 0

      # @scale = 0
      @born_span_count = 0
      @killed_by_poi = false

      self.fit_pos_for_mother_ship
      self.change_mode(:wait)
    end

    def fit_pos_for_mother_ship
      position_radian = (@mother_ship.angle + 90) * (Math::PI / 180)
      self.x = @mother_ship.x + @mother_ship.center_x - (@mother_ship.height * 0.5 * Math.cos(position_radian)) - (@width * 0.5)
      self.y = @mother_ship.y + @mother_ship.center_y - (@mother_ship.height * 0.5 * Math.sin(position_radian)) - (@height * 0.5)
    end

    def change_mode(mode)

      case mode

      when :wait

      when :preparation
        @born_span = rand(MAX_BORN_SPAN)

      when :move
        @born_sound.play

      when :disappear
        self.image = @images[1]
        @burst_sount.play
      end
      @mode = mode
    end

    def update

      case @mode

      when :preparation
        if @born_span_count > @born_span then
          self.scale_x = 0.1 unless self.scale_x == 0.1
          self.scale_y = 0.1 unless self.scale_y == 0.1
          self.fit_pos_for_mother_ship
          self.preparation
        else
          self.scale_x = 0 unless self.scale_x == 0
          self.scale_y = 0 unless self.scale_y == 0
          @born_span_count += 1
        end

      when :move
        self.move

      when :disappear
        self.disappear
      end
    end

    def preparation
      if @preparation_count > MAX_WAIT_COUNT then
        @shot_direction_radian = Math.atan2(@attack_target.y + @attack_target.center_y - (self.y + self.center_y),
                                            @attack_target.x + @attack_target.center_x - (self.x + self.center_x))
        @born_span_count = 0
        @preparation_count = 0
        self.change_mode(:move)
      else
        position_radian = (@mother_ship.angle + 90) * (Math::PI / 180)
        self.x = @mother_ship.x + @mother_ship.center_x - (@mother_ship.height * 0.5 * Math.cos(position_radian)) - (@width * 0.5)
        self.y = @mother_ship.y + @mother_ship.center_y - (@mother_ship.height * 0.5 * Math.sin(position_radian)) - (@height * 0.5)
        @preparation_count += 1
      end
    end

    def move
      move_direction_radian = @shot_direction_radian * (180 / Math::PI) * (Math::PI / 180)
      self.x += Math.cos(move_direction_radian) * MOVE_SPEED
      self.y += Math.sin(move_direction_radian) * MOVE_SPEED

      self.scale_x += SCALE_UP_SPEED # + Math.sqrt(@scale)
      self.scale_y += SCALE_UP_SPEED # + Math.sqrt(@scale)
      # @scale += SCALE_UP_SPEED
    end

    def hit(obj)

      if not @mode == :disappear and not @mode == :preparation then
        if obj.class == Border::Block then
          self.change_mode(:disappear)
        end
        if obj.class == Poi then
          self.change_mode(:disappear)
          @killed_by_poi = true
        end
      end
    end

    def draw
      self.target.draw_ex(self.x, self.y, self.image, {:scale_x=>self.scale_x, :scale_y=>self.scale_y, :z=>self.z}) if
        self.image and not @mode == :wait
    end

    def disappear
      if @burst_wait_count > MAX_BURST_WAIT_COUNT then
        self.image = @images[0]
        # @scale = 0
        self.change_mode(:preparation)
        @burst_wait_count = 0
      else
        @burst_wait_count += 1
      end
    end
  end
end


if __FILE__ == $0 then

  Window.width = 1920
  Window.height = 1080

  mouse = nil
  poi = nil

  Dir.chdir("../") do
    require "scripts/border"
    require "scripts/poi"
    include Common

    mouse = Sprite.new
    mouse.collision = [0, 0]

    poi = Poi.new(0, 0, nil, Window.height * 0.35, mouse)
  end

  border = Border.new(50, 50, Window.width - 100, Window.height - 100)

  bosss = []
  5.times do |index|
    boss_height = Window.height * rand_float(0.3, 0.6)
    boss = Boss.new(0, 0, nil, boss_height, rand(360), index,
                    {:wait=>[0, Math.sqrt(Window.height * 0.001)],
                     :move=>[Math.sqrt(Window.height * 0.001), Math.sqrt(Window.height * 0.009)],
                     :escape=>[Math.sqrt(Window.height * 0.001), Math.sqrt(Window.height * 0.009)]},
                    {:wait=>[0, 200], :move=>[0, 100], :escape=>[0, 200]},
                    {:escape=>80, :ignore=>50, :against=>20},
                    0.2, poi, border.blocks)
    boss.set_pos(random_int(border.x, border.x + border.width - boss.width),
                 random_int(border.y, border.y + border.height - boss.height))
    bosss.push(boss)
  end

  Window.bgcolor = C_WHITE
  Window.loop do

    border.draw

    mouse.x, mouse.y = Input.mouse_pos_x, Input.mouse_pos_y if mouse
    poi.update if poi
    poi.draw if poi

    bosss.each do |boss|
      boss.update
      boss.draw

      if boss.bubble_shots and not boss.bubble_shots.empty? then
        boss.bubble_shots.each do |bubble_shot|
          if bubble_shot.killed_by_poi then
            bubble_shot.killed_by_poi = false
            # Life Gauge を減らす処理
          end
        end
      end
    end
    Sprite.check(border.blocks + bosss)
  end
end
