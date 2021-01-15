#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

require "dxruby"

# バイブマンクラス
# "9"でヴァイブレーション


class VibeMan

  attr_accessor :x, :y, :shadow_x, :shadow_y, :name, :id, :target, :z,
                :title_label, :set_time_label, :time_input_box, :connect_button, :test_button, :is_active_dialog,
                :ok_button, :output_box, :change_type_labels, :change_type_radio_buttons, :is_lock
  attr_reader :width, :height, :buttons, :is_connecting

  if __FILE__ == $0 then
    require "../lib/dxruby/fonts"
    require "../lib/dxruby/roundbox"
    require "../lib/dxruby/images"
    require "../lib/dxruby/button"
    require "../lib/dxruby/color"
    require "../lib/dxruby/radio_button"
    require "../lib/encode"

    CONNECT_BUTTON_IMAGE = "../images/m_1.png"
    TEST_BUTTON_IMAGE = "../images/m_3.png"
    TIME_UP_BUTTON_IMAGE = "../images/yazirusi_r.png"
    TIME_DOWN_BUTTON_IMAGE = "../images/yazirusi_l.png"
    OK_BUTTON_IMAGE = "../images/m_2.png"
    CLICK_SE = "../sounds/meka_ge_mouse_s02.wav"
  else
    require "./lib/dxruby/fonts"
    require "./lib/dxruby/roundbox"
    require "./lib/dxruby/images"
    require "./lib/dxruby/button"
    require "./lib/dxruby/color"
    require "./lib/dxruby/radio_button"
    require "./lib/encode"

    CONNECT_BUTTON_IMAGE = "./images/m_1.png"
    TEST_BUTTON_IMAGE = "./images/m_3.png"
    TIME_UP_BUTTON_IMAGE = "./images/yazirusi_r.png"
    TIME_DOWN_BUTTON_IMAGE = "./images/yazirusi_l.png"
    OK_BUTTON_IMAGE = "./images/m_2.png"
    CLICK_SE = "./sounds/meka_ge_mouse_s02.wav"
  end

  include Color

  SHADOW_OFFSET_X = 5
  SHADOW_OFFSET_Y = 5


  class Core

    attr_accessor :type, :vibe_time
    attr_reader :output

    require "rubygems"
    require "Win32Serial"
    require "win32ole"
    require "thread"

    CONNECT_TRY_COUNT = 3

    def initialize(parent)
      @parent = parent
      @serials = []
      @responses = []
      @vibemans = []
      @vibe_type = 1
      @vibe_time = 200
    end

    #利用可能なシリアルポートをハッシュで返す
    def serialports

      locator = WIN32OLE.new("WbemScripting.SWbemLocator")

      services = locator.ConnectServer()

      comlist = {}

      # 内蔵シリアルポート一覧を取得
      services.ExecQuery("SELECT * FROM Win32_SerialPort").each do |item|
        comlist[item.DeviceID] = item.Name
      end

      # PnPシリアルポート一覧を取得
      services.ExecQuery("SELECT * FROM Win32_PnPEntity").each do |item|
        comlist[$1] = item.Description if item.Name =~ /\((COM\d+)\)/
      end

      return Hash[
        # シリアルポート名に含まれる数字も考慮し昇順にソート
        comlist.sort_by {|k, v|
          k.scan(/(\d+)|([^\d]+)/).map{|s|
            s[0] ? [0, s[0].to_i] : [1, s[1]]
          }
        }
      ]
    end

    def connect

      ports = self.serialports.select { |port, value| not value.include?("Bluetooth") }

      check_port = Thread.new do
        CONNECT_TRY_COUNT.times do

          ports.each do |port|
            serial = Win32Serial.new

            serial.open(port[0])
            serial.config(9600, 8, Win32Serial::NOPARITY, Win32Serial::ONESTOPBIT)
            serial.timeouts(0,200,0,0,0)

            serial.write("areyouvibeman")
            raw = serial.read(14)

            @responses.push({:port=>port[0], :raw=>raw}) if not raw == "" and raw
            serial.close
          end
          break unless @responses.empty?
        end
      end

      check_port.join

      output = ""
      unless @responses.empty? then

        @responses.each do |response|

          unit = response[:raw].split(/-|,/)

          if unit[0] == "iamvibeman2" then
            vibeman = {:port=>response[:port], :version=>"β2", :serial=>nil}
            output += "Now connected in #{response[:port]} : Ver #{vibeman[:version]}\n"

          elsif unit.size >= 5 then
            vibeman = {:port=>response[:port], :version=>"β1", :serial=>nil}
            output += "Now connected in #{response[:port]} : Ver #{vibeman[:version]}\n"
          end
          @vibemans.push(vibeman)
        end
      end
      @parent.callback_output(output)
      @responses.clear

      self.open
    end

    def open

      @vibemans.each do |vibeman|
        serial = Win32Serial.new

        serial.open(vibeman[:port])
        serial.config(9600, 8, Win32Serial::NOPARITY, Win32Serial::ONESTOPBIT)
        serial.timeouts(0,200,0,0,0)

        vibeman[:serial] = serial
      end
    end

    def vibe

      @vibemans.each do |vibeman|
        case @vibe_type

        when 1
          vibeman[:serial].write("9\n")

        when 2
          vibeman[:serial].write("8:2:#{@vibe_time}\n")
        end
        response = vibeman[:serial].read(14)

        if not response == "" and response then
          output = "Signal send success!\nVibeman working no problem."
        else
          output = "Signal send failed..."
        end
        @parent.callback_output(output)
      end
    end

    def disconnect

      @vibemans.each do |vibeman|
        vibeman[:serial].close
        vibeman[:serial] = nil
        @vibemans.clear
      end
      @parent.callback_output("All vibeman disconnected.")
    end
  end

  def initialize(x=0, y=0, width=100, height=100, option={})
    option = {:frame_thickness=>2, :radius=>10, :bg_color=>C_WHITE, :frame_color=>C_GREEN,
              :name=>"vibeman", :id=>0, :target=>Window, :z=>0}.merge(option)

    @click_se = Sound.new(CLICK_SE)

    @frame_thickness = option[:frame_thickness].round
    @radius = option[:radius]
    @bg_color = option[:bg_color]
    @frame_color = option[:frame_color]

    @x = x
    @y = y
    @width = width
    @height = height

    @target = option[:target]
    @id = option[:id]
    @name = option[:name]
    @z = option[:z]

    @shadow_x = SHADOW_OFFSET_X
    @shadow_y = SHADOW_OFFSET_Y

    @image = Image.new(@width, @height)
    @image.roundbox_fill(0, 0, @width, @height, @radius, @bg_color)

    @frame_thickness.times do |index|
      @image.roundbox(index, index, @width - 1 - index, @height - 1 - index, @radius, @frame_color)
    end
    @shadow = @image.flush([64, 0, 0, 0])

    @core = Core.new(self)

    @title_label = Fonts.new(0, 0, "Vibeman Control",
                             @height * 0.07, C_GRAY, {:target=>@image, :edge=>true})
    @title_label.set_pos((@width - @title_label.width) * 0.67, (@height - @title_label.height) * 0.04)

    @output_box = Images.new(@x + @width * 0.05, @y + @height * 0.13, @width * 0.9, @height * 0.25,
                              "", @height * 0.034, C_WHITE, C_BLACK)
    @output_box.frame(C_BROWN, @output_box.height * 0.012)

    @time_input_box = Images.new(@x + @width * 0.35, @y + @height * 0.468, @width * 0.3, @height * 0.1,
                                 @core.vibe_time.to_s, @height * 0.1, C_WHITE, C_BLACK)
    @time_input_box.frame(C_YELLOW, @time_input_box.height * 0.01)

    connect_button_height = @height * 0.07
    connect_button_width = connect_button_height * 2.4
    @connect_button = Button.new(@x + (@width - connect_button_width) * 0.8,
                                 @y + (@height - connect_button_height) * 0.83,
                                 connect_button_width, connect_button_height, string="Connect",
                            font_size=connect_button_height * 0.7)

    connect_button_image = Image.load(CONNECT_BUTTON_IMAGE)
    @connect_button.set_image(Images.fit_resize(connect_button_image, @connect_button.width, @connect_button.height))

    test_button_height = @height * 0.07
    test_button_width = test_button_height * 2.4
    @test_button = Button.new(@x + (@width - test_button_width) * 0.2, @y + (@height - test_button_height) * 0.83,
                              test_button_width, test_button_height, string="Test",
                                 font_size=test_button_height * 0.7)

    test_button_image = Image.load(TEST_BUTTON_IMAGE)
    @test_button.set_image(Images.fit_resize(test_button_image, @test_button.width, @test_button.height))

    time_up_button_image = Image.load(TIME_UP_BUTTON_IMAGE)
    time_up_button_scale_y = @height * 0.1 / time_up_button_image.height
    time_up_button_scale_x = time_up_button_scale_y
    time_up_button_converted_image = Images.scale_resize(time_up_button_image,
                                                         time_up_button_scale_x, time_up_button_scale_y)

    @time_up_button = Button.new(0, 0, time_up_button_converted_image.width, time_up_button_converted_image.height)
    @time_up_button.set_image(time_up_button_converted_image)
    @time_up_button.set_pos(@x + (@width - @time_up_button.width) * 0.75,
                            @y + (@height - @time_up_button.height) * 0.52)

    time_down_button_image = Image.load(TIME_DOWN_BUTTON_IMAGE)
    time_down_button_scale_y = @height * 0.1 / time_down_button_image.height
    time_down_button_scale_x = time_down_button_scale_y
    time_down_button_converted_image = Images.scale_resize(time_down_button_image,
                                                           time_down_button_scale_x, time_down_button_scale_y)

    @time_down_button = Button.new(0, 0, time_down_button_converted_image.width,
                                   time_down_button_converted_image.height)
    @time_down_button.set_image(time_down_button_converted_image)
    @time_down_button.set_pos(@x + (@width - @time_down_button.width) * 0.25,
                              @y + (@height - @time_down_button.height) * 0.52)

    @set_time_label = Fonts.new(0, 0, "vibration time", @height * 0.05, C_BLACK,
                                {:target=>@image, :shadow=>false})
    @set_time_label.set_pos((@width - @set_time_label.width) * 0.64, (@height - @set_time_label.height) * 0.43)

    ok_button_height = @height * 0.07
    ok_button_width = ok_button_height * 2.4
    @ok_button = Button.new(@x + (@width - ok_button_width) * 0.5, @y + (@height - ok_button_height) * 0.95,
                            ok_button_width, ok_button_height, string="OK", font_size=ok_button_height * 0.7)

    ok_button_image = Image.load(OK_BUTTON_IMAGE)
    @ok_button.set_image(Images.fit_resize(ok_button_image, @ok_button.width, @ok_button.height))

    change_type_texts =
      ["Type-" + "\x87\x54".encode("BINARY"), "Type-" + "\x87\x55".encode("BINARY")]
    @change_type_labels = []
    @change_type_radio_buttons = []

    2.times do |index|
      change_type_label = Fonts.new(0, 0, change_type_texts[index], @height * 0.04, C_BLACK)
      change_type_label.shadow = false
      @change_type_labels << change_type_label
      change_type_radio_button = RadioButton.new(0, 0, index, @height * 0.04, C_BLACK, C_WHITE, C_BLACK,
                                                 {:markSize=>@height * 0.012, :frameSize=>Window.height * 0.0015})
      @change_type_radio_buttons << change_type_radio_button
    end
    @change_type_radio_buttons[0].setCheck(true)

    2.times do |index|
      @change_type_labels[index].set_pos(@x + @width * 0.43, @y + @height * 0.60 + (@height * 0.07 * index))
      @change_type_radio_buttons[index].setPos(@x + @width * 0.33, @y + @height * 0.60 + (@height * 0.07 * index))
    end

    @buttons = [@connect_button, @test_button, @time_up_button, @time_down_button, @ok_button]

    @is_active_dialog = true
    @is_challenge_connect = false

    @challenge_connect_count = 0
    @is_connecting = false

    @test_button.enable = false

    @vibe_time = 200
    @response_count = 0

    @is_lock = false
  end

  def set_pos(x, y)
    @x = x
    @y = y

    @output_box.set_pos(@x + @width * 0.05, @y + @height * 0.13)
    @connect_button.set_pos(@x + (@width - @connect_button.width) * 0.8, @y + (@height - @connect_button.height) * 0.83)
    @test_button.set_pos(@x + (@width - @test_button.width) * 0.2, @y + (@height - @test_button.height) * 0.83)

    @time_input_box.set_pos(@x + @width * 0.35, @y + @height * 0.468)
    @time_up_button.set_pos(@x + (@width - @time_up_button.width) * 0.75,
                            @y + (@height - @time_up_button.height) * 0.52)
    @time_down_button.set_pos(@x + (@width - @time_down_button.width) * 0.25,
                              @y + (@height - @time_down_button.height) * 0.52)
    @ok_button.set_pos(@x + (@width - @ok_button.width) * 0.5, @y + (@height - @ok_button.height) * 0.95)

    2.times do |index|
      @change_type_labels[index].set_pos(@x + @width * 0.43, @y + @height * 0.60 + (@height * 0.07 * index))
      @change_type_radio_buttons[index].setPos(@x + @width * 0.33, @y + @height * 0.60 + (@height * 0.07 * index))
    end
  end

  def callback_output(output)

    unless output == "" then
      @output_box.string = output

      if not @is_connecting and output.include?("connected") then

        @connect_button.string = "Disconnect"
        @connect_button.enable = true
        @test_button.enable = true
        @is_connecting = true

      elsif output.include?("disconnected") then

        @connect_button.string = "Connect"
        @connect_button.enable = true
        @test_button.enable = false
        @is_connecting = false
      end
    else
      @output_box.string = "Not connect any Vibeman..."
      @connect_button.enable = true
    end
  end

  def update

    if (@connect_button and @connect_button.is_enable and @is_active_dialog and not @is_lock and
      (@connect_button.pushed? or @connect_button.add_push)) then
      @connect_button.add_push = false

      @click_se.play if @click_se
      unless @is_connecting then
        @output_box.string = "Now connecting..."
      else
        @output_box.string = "Now disconnecting..."
      end
      @connect_button.enable = false
      @is_challenge_connect = true
    end

    if @is_challenge_connect then
      if @challenge_connect_count == 5 then

        unless @is_connecting then
          @core.connect
        else
          @core.disconnect
        end
      elsif @challenge_connect_count > 5 then
        @challenge_connect_count = 0
        @is_challenge_connect = false
      end
      @challenge_connect_count += 1
    end

    if (@test_button and @test_button.is_enable and @is_active_dialog and not @is_lock and
      (@test_button.pushed? or @test_button.add_push)) then
      @test_button.add_push = false

      @click_se.play if @click_se
      if @is_connecting then
        @output_box.string = "Now testing..."
        @core.vibe
      end
    end

    if (@time_up_button and @is_active_dialog and not @is_lock and
      (@time_up_button.pushing? or @time_up_button.add_push)) then

      @time_up_button.add_push = false
      @click_se.play if @click_se
      @vibe_time += 1
      @time_input_box.string = @vibe_time.to_s
      @core.vibe_time = @vibe_time
    end

    if (@time_down_button and @is_active_dialog and not @is_lock and
      (@time_down_button.pushing? or @time_down_button.add_push)) then

      @time_down_button.add_push = false
      @click_se.play if @click_se
      @vibe_time -= 1
      @time_input_box.string = @vibe_time.to_s
      @core.vibe_time = @vibe_time
    end

    if (@ok_button and @is_active_dialog and not @is_lock and (@ok_button.pushed? or @ok_button.add_push)) then
      @ok_button.add_push = false
      @is_active_dialog = false

      @core.vibe_time = @output_box.string.to_i
      @vibe_time = @time_input_box.string.to_i

      @click_se.play if @click_se
    end

    if @buttons and not @buttons.empty? and @is_active_dialog and not @is_lock then
      @buttons.each do |button|
        button.hovered?
      end
    end

    if @is_active_dialog and not @is_lock then
      check_id = nil
      for change_type_radio_button in @change_type_radio_buttons do

        if change_type_radio_button.checked? or change_type_radio_button.add_push then
          change_type_radio_button.setCheck(true) if change_type_radio_button.add_push
          change_type_radio_button.add_push = false
          @click_se.play if @click_se
          check_id = change_type_radio_button.id

          case check_id
          when 0 then
            @core.type = 0
          when 1 then
            @core.type = 1
          end
        end
      end

      if check_id then
        for change_type_radio_button in @change_type_radio_buttons do
          unless change_type_radio_button.id == check_id then
            change_type_radio_button.setCheck(false)
          end
        end
      end
    end
  end

  def run
    @core.vibe if @is_connecting
  end

  def draw

    if @is_active_dialog then
      @target.draw(@x + @shadow_x, @y + @shadow_y, @shadow, @z)
      @target.draw(@x, @y, @image, @z)

      @title_label.draw
      @output_box.draw

      @connect_button.draw
      @test_button.draw
      @ok_button.draw

      @time_input_box.draw
      @time_up_button.draw
      @time_down_button.draw
      @set_time_label.draw

      2.times do |index|
        @change_type_radio_buttons[index].draw
        @change_type_labels[index].draw
      end
    end
  end

  def vanish

    @shadow.dispose
    @image.dispose
  end
end


if __FILE__ == $0 then

  require "../lib/dxruby/color"
  include Color

  BALL_PARK_FONT = "../fonts/BALLW___.TTF"
  Font.install(BALL_PARK_FONT)

  PHENOMENA_FONT = "../fonts/Phenomena-Bold.ttf"
  Font.install(PHENOMENA_FONT)

  JIYUNO_TSUBASA_FONT = "../fonts/JiyunoTsubasa.ttf"
  Font.install(JIYUNO_TSUBASA_FONT)

  Window.width = 1920
  Window.height = 1080

  vibeman = VibeMan.new(0, 0, Window.height * 0.3, Window.height * 0.6,
                        {:bg_color=>C_IVORY, :frame_color=>C_BROWN})
  vibeman.set_pos((Window.width - vibeman.width) * 0.96, (Window.height - vibeman.height) * 0.93)

  vibeman.title_label.font_name = "Ballpark"
  vibeman.set_time_label.font_name = "Phenomena"
  vibeman.connect_button.font_name = "Phenomena"
  vibeman.test_button.font_name = "Phenomena"
  vibeman.time_input_box.font_name = "Phenomena"
  vibeman.ok_button.font_name = "Phenomena"
  vibeman.output_box.font_name = "自由の翼フォント"
  2.times do |index|
    vibeman.change_type_labels[index].font_name = "自由の翼フォント"
  end

  Window.bgcolor = C_GREEN
  Window.loop do
    vibeman.update if vibeman and vibeman.is_active_dialog
    vibeman.draw if vibeman and vibeman.is_active_dialog
  end
end

