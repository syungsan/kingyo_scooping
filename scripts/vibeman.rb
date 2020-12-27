#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

require "dxruby"

# バイブマンクラス
# "9"でヴァイブレーション


class VibeMan

  attr_accessor :shadow_x, :shadow_y, :name, :id, :target, :z,
                :connect_button, :title_label, :test_button, :set_time_label, :time_input_box
  attr_reader :width, :height

  if __FILE__ == $0 then
    require "../lib/dxruby/fonts"
    require "../lib/dxruby/roundbox"
    require "../lib/dxruby/images"
    require "../lib/dxruby/button"
    CONNECT_BUTTON_IMAGE = "../images/m_1.png"
    TEST_BUTTON_IMAGE = "../images/m_3.png"
    TIME_UP_BUTTON_IMAGE = "../images/yazirusi_r.png"
    TIME_DOWN_BUTTON_IMAGE = "../images/yazirusi_l.png"
    CLOSE_BUTTON_IMAGE = "../images/Close_Box_Red.png"
  else
    require "./lib/dxruby/fonts"
    require "./lib/dxruby/roundbox"
    require "./lib/dxruby/images"
    require "./lib/dxruby/button"
    CONNECT_BUTTON_IMAGE = "./images/m_1.png"
    TEST_BUTTON_IMAGE = "./images/m_3.png"
    TIME_UP_BUTTON_IMAGE = "./images/yazirusi_r.png"
    TIME_DOWN_BUTTON_IMAGE = "./images/yazirusi_l.png"
    CLOSE_BUTTON_IMAGE = "./images/Close_Box_Red.png"
  end

  SHADOW_OFFSET_X = 5
  SHADOW_OFFSET_Y = 5


  class Core

    require "rubygems"
    require "Win32Serial"
    require "win32ole"
    require "thread"

    CONNECT_TRY_COUNT = 3

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

    def check_port(ports)

      @serial = Win32Serial.new

      responses = []
      CONNECT_TRY_COUNT.times do

        ports.keys.each do |port|

          @serial.open(port)
          @serial.config(9600, 8, Win32Serial::NOPARITY, Win32Serial::ONESTOPBIT)
          @serial.timeouts(0,200,0,0,0)

          @serial.write("areyouvibeman")
          raw = @serial.read(14)

          responses.push([port, raw]) unless raw == ""
          @serial.close
        end

        break unless responses.empty?
      end
      return responses
    end

    def responce_check(responses)
      p responses
    end

    def connect

      ports = self.serialports
      responses = self.check_port(ports)
      self.responce_check(responses)
    end


=begin
        rs = rl.split('-')


        if rs[0] == "iamvibeman2"
          s.timeouts(0,1,0,0,0)
          #@vibeport = s
          vibe_found_flag = true
          @@portname = port
          @@vibe_ver = "β2"
          break
        else
          p rl = $s.read(14) || " < no response >"
          rs = rl.split('-')
          if(rs[0] == "iamvibeman2")
            s.timeouts(0,1,0,0,0)
            #@vibeport = s
            vibe_found_flag = true
            @@portname = port
            @@vibe_ver = "β2"
            break
          end
        end


        p "1_start"
        #β１の確認
        begin
          $s.timeouts(0,200,0,0,0)
          c = 0
          for i in 0...1
            p k = $s.read(10) || "< no bytes >"
            #p k.slice!(",")
            p c = k.split(/,/,0)
            p c.length
            if(c.length>=5)
              $s.timeouts(0,1,0,0,0)
              #@vibeport = s
              vibe_found_flag = true
              @@portname = port
              @@vibe_ver = "β1"
              break
            end
            p "#{i}" + "_data"
          end
        rescue
          p "res1"
        end

        if(!vibe_found_flag)
          $s.close
        end
        p "#{port}" + "_end"
      end

      if(vibe_found_flag)
        p "vibeman_found"
        p "portname:"+"#{@@portname}"
        p "version:" + "#{@@vibe_ver}"
        #return  "#{@portname}"
      else
        p "vibeman_not_found"
        @@portname = "None"
        @@vibe_ver = ""
      end
      #end
      #t.join
      #p @vibeman_panel_com_font.string = "#{@portname}"
      #@vibeman_panel_com.render
    end

    def open
      Thread.new do
        begin
          p "open"
          if($s != nil)
            $s.close
            $s = nil
          end
          check_vibeman_port
        rescue
          p "res0"
        end
        p "#{@@portname}"
        @vibeman_panel_com_font.string = "#{@@portname}"
        p "#{@@vibe_ver}"
        if(@@vibe_ver == "β2")
          #押せるようにする
          @vibe_work_panel_2.un_push_flag(false)
        end
      end
    end

    def vibration
      begin
        #@@io.puts"9\n"
        #$stdin_vibe.write("9\n")
        p "vibe"
        if(@@vibe_work_type == 0)
          if(@@vibe_ver == "β1")
            p $s.write("9\n")#|| "< no bytes >"
          elsif(@@vibe_ver == "β2")
            p $s.write("9\n")#|| "< no bytes >"
          else
            p "None_Vibe"
          end
        elsif(@@vibe_work_type == 1)
          p $s.write("8:2:"+"#{@@vibe_time}\n")#|| "< no bytes >"
        end
      rescue
        p "exception_vibe"
      end
    end

    def close
      begin
        $s.close
        sleep(0.5)
      rescue

      end
    end
=end
  end


  class UI



    def initialize


    end

    def init_vibeman
      if(!$vibeman_open)
        @@vibe_time = 200
        @@portname = "COM ?"
        @@vibe_work_type = 0
        @@vibe_ver = ""
        $vibeman_open = true
      else
        p "else"
      end

      @vibeman_panel = Images.new(0,0, Black,320,160)
      @vibeman_panel.image("lib/image/panel/pink_panel2.png")
      @vibeman_panel.x = ($panel_under.w * 3 / 4)-(@vibeman_panel.w/2) - $btn_setup.w/2
      @vibeman_panel.y = Window_h-Window_h/5.5 + (@vibeman_panel.h/15)#Window_h-@vibeman_panel.h-(70*$ratio_y) #- $panel_under.h

      @vibeman_panel_com = Images.new(0,0, Black,210,120)
      #@vibeman_panel_com.size(210,120)
      @vibeman_panel_com.image("lib/image/panel/white_panel3.png")
      @vibeman_panel_com.x =@vibeman_panel.x+(@vibeman_panel.w/25)
      @vibeman_panel_com.y =@vibeman_panel.y+(@vibeman_panel.h/15)
      #@vibeman_panel_com.string = "COM"
      #@vibeman_panel_com.draw_string2(0,0)
      @vibeman_panel_com_font = Fonts.new("#{@@portname}",0+50*$ratio_x,Window_h-70*$ratio_y,30*$ratio_x,Black)
      @vibeman_panel_com_font.x =@vibeman_panel.x+(@vibeman_panel.w/25)+@vibeman_panel_com.w/5
      @vibeman_panel_com_font.y = @vibeman_panel.y+(@vibeman_panel.h/15)+@vibeman_panel_com.h/5

      @vibeman_panel_time = Images.new(0,0, Black,210,120)
      @vibe_time_btn_up = Button.new(0, 0, "",36,10,10)
      @vibe_time_btn_down = Button.new(0, 0, "",36,10,10)
      @vibeman_panel_time.image("lib/image/panel/white_panel3.png")
      @vibe_time_btn_up.image = ("lib/image/button/single_up2.png")
      @vibe_time_btn_down.image = ("lib/image/button/single_down2.png")

      @vibeman_panel_time.x = @vibeman_panel.x+(@vibeman_panel.w/2)-(@vibeman_panel_time.w/2)#+(@vibeman_panel.w/25)+(@vibeman_panel.w/25)
      @vibeman_panel_time.y = @vibeman_panel.y+@vibeman_panel.h-(@vibeman_panel.h/15)-@vibeman_panel_time.h
      @vibeman_panel_time_font = Fonts.new("#{@@vibe_time}" + " ms",0+50*$ratio_x,Window_h-70*$ratio_y,30*$ratio_x,Black)
      @vibeman_panel_time_font.x = @vibeman_panel_time.x+@vibeman_panel_time.w/5
      @vibeman_panel_time_font.y = @vibeman_panel_time.y+@vibeman_panel_time.h/5

      @vibe_time_btn_up.x = @vibeman_panel.x+(@vibeman_panel.w)-@vibe_time_btn_down.w-(@vibeman_panel.w/25) #+(2* @vibeman_panel.w/25)+@vibeman_panel_time.w+@vibe_time_btn_down.w+(@vibeman_panel.w/50)
      @vibe_time_btn_up.y = @vibeman_panel_time.y+(@vibe_time_btn_up.h/8)#+(@vibeman_panel.h/25)#-@vibeman_panel_time.h#Window_h-(70*$ratio_y)-(@vibeman_panel.h/25)-@vibeman_panel_time.h

      @vibe_time_btn_down.x = @vibeman_panel.x+(@vibeman_panel.w/25)
      @vibe_time_btn_down.y = @vibe_time_btn_up.y

      @vibe_work_panel_1 = Button.new(0, 0, "",36,10,10)
      @vibe_work_panel_1.image = ("lib/image/panel/white_panel3.png")
      @vibe_work_panel_2 = Button.new(0, 0, "",36,10,10)
      @vibe_work_panel_2.image = ("lib/image/panel/white_panel3.png")

      @vibe_work_panel_1.x = @vibeman_panel.x+(@vibeman_panel.w/25)#@vibe_time_btn_down.w(@vibeman_panel.w/25)
      @vibe_work_panel_1.y = @vibeman_panel.y+@vibeman_panel.h-(@vibeman_panel.h/2)-(@vibe_work_panel_1.h/2)#(@vibeman_panel_time.h/2)#-(@vibeman_panel.h/15)
      @vibe_work_panel_2.x = @vibeman_panel.x+(@vibeman_panel.w)-(@vibe_work_panel_2.w)-(@vibeman_panel.w/25)#+(@vibeman_panel.w/25)
      @vibe_work_panel_2.y = @vibe_work_panel_1.y

      @vibe_work_panel_1_font = Fonts.new("振動まくら",0,0,25*$ratio_x,Black)

      @vibe_work_panel_1_font.x = @vibe_work_panel_1.x+@vibe_work_panel_1.w/7.5
      @vibe_work_panel_1_font.y = @vibe_work_panel_1.y+@vibe_work_panel_1.h/5

      @vibe_work_panel_2_font = Fonts.new("任意時間",0,0,25*$ratio_x,Black)

      @vibe_work_panel_2_font.x = @vibe_work_panel_2.x+@vibe_work_panel_2.w/6.5
      @vibe_work_panel_2_font.y = @vibe_work_panel_2.y+@vibe_work_panel_2.h/5


      if(@@vibe_work_type == 0)
        @vibe_work_panel_1.image = ("lib/image/panel/orange_panel3.png")
        @vibe_work_panel_2.image = ("lib/image/panel/white_panel3.png")
      else
        @vibe_work_panel_1.image = ("lib/image/panel/white_panel3.png")
        @vibe_work_panel_2.image = ("lib/image/panel/orange_panel3.png")
      end

      if(@@vibe_ver == "β2")
        #押せるようにする
        @vibe_work_panel_2.un_push_flag(false)
      else
        #押せないようにする
        @vibe_work_panel_2.un_push_flag(true)
      end
    end

    def vibeman_render
      @vibeman_panel.render
      @vibeman_panel_com.render
      @vibeman_panel_com_font.render
      @vibe_work_panel_1.render
      @vibe_work_panel_2.render
      @vibe_work_panel_1_font.render
      @vibe_work_panel_2_font.render
      @vibeman_panel_time.render
      @vibeman_panel_time_font.render
      @vibe_time_btn_up.render
      @vibe_time_btn_down.render
    end

    def vibeman_btn
      if @vibe_time_btn_up.pushed?($mouse_use)
        @@vibe_time = @@vibe_time + 50
        #@vibeman_panel_time.string = "#{@vibe_time}" + " ms"
        @vibeman_panel_time_font.string = "#{@@vibe_time}" + " ms"
      end
      if @vibe_time_btn_down.pushed?($mouse_use)
        @@vibe_time = @@vibe_time - 50
        #@vibeman_panel_time.string = "#{@vibe_time}" + " ms"
        @vibeman_panel_time_font.string = "#{@@vibe_time}" + " ms"
      end
      if @vibe_work_panel_1.pushed?($mouse_use)
        p "push_1"
        @vibe_work_panel_1.image = ("lib/image/panel/orange_panel3.png")
        @vibe_work_panel_2.image = ("lib/image/panel/white_panel3.png")
        #p @vibeman_panel_com_font.string = "#{@portname}"
        @@vibe_work_type = 0
      end
      if @vibe_work_panel_2.pushed?($mouse_use)
        p "push_2"
        @vibe_work_panel_1.image = ("lib/image/panel/white_panel3.png")
        @vibe_work_panel_2.image = ("lib/image/panel/orange_panel3.png")
        @@vibe_work_type = 1
      end
    end
  end

  def initialize(x=0, y=0, width=100, height=100, option={})
    option = {:frame_thickness=>2, :radius=>10, :bg_color=>C_WHITE, :frame_color=>C_GREEN,
              :name=>"vibeman", :id=>0, :target=>Window, :z=>0}.merge(option)

    @frame_thickness = option[:frame_thickness]
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

    @title_label = Fonts.new(0, 0, "Vibeman Control", @height * 0.1, C_GRAY, {:target=>@image, :edge=>true})
    @title_label.set_pos((@width - @title_label.width) * 0.67, (@height - @title_label.height) * 0.06)

    @message_box = Images.new(@x + @width * 0.05, @y + @height * 0.2, @width * 0.9, @height * 0.25,
                              "", @height * 0.075, C_WHITE, C_BLACK)
    @message_box.frame(C_BROWN, @message_box.height * 0.03)

    @time_input_box = Images.new(@x + @width * 0.35, @y + @height * 0.6, @width * 0.3, @height * 0.1,
                              "100", @height * 0.1, C_WHITE, C_BLACK)
    @time_input_box.frame(C_YELLOW, @time_input_box.height * 0.05)

    connect_button_width = @width * 0.3
    connect_button_height = connect_button_width * 0.4
    @connect_button = Button.new(@x + (@width - connect_button_width) * 0.8, @y + (@height - connect_button_height) * 0.9,
                                 connect_button_width, connect_button_height, string="Connect",
                            font_size=connect_button_height * 0.7)

    connect_button_image = Image.load(CONNECT_BUTTON_IMAGE)
    @connect_button.set_image(Images.fit_resize(connect_button_image, @connect_button.width, @connect_button.height))

    test_button_width = @width * 0.3
    test_button_height = test_button_width * 0.4
    @test_button = Button.new(@x + (@width - test_button_width) * 0.2, @y + (@height - test_button_height) * 0.9,
                              test_button_width, test_button_height, string="Test",
                                 font_size=test_button_height * 0.7)

    test_button_image = Image.load(TEST_BUTTON_IMAGE)
    @test_button.set_image(Images.fit_resize(test_button_image, @test_button.width, @test_button.height))

    time_up_button_image = Image.load(TIME_UP_BUTTON_IMAGE)
    time_up_button_scale_y = @height * 0.1 / time_up_button_image.height
    time_up_button_scale_x = time_up_button_scale_y
    time_up_button_converted_image = Images.scale_resize(time_up_button_image, time_up_button_scale_x, time_up_button_scale_y)

    @time_up_button = Button.new(0, 0, time_up_button_converted_image.width, time_up_button_converted_image.height)
    @time_up_button.set_image(time_up_button_converted_image)
    @time_up_button.set_pos(@x + (@width - @time_up_button.width) * 0.75, @y + (@height - @time_up_button.height) * 0.665)

    time_down_button_image = Image.load(TIME_DOWN_BUTTON_IMAGE)
    time_down_button_scale_y = @height * 0.1 / time_down_button_image.height
    time_down_button_scale_x = time_down_button_scale_y
    time_down_button_converted_image = Images.scale_resize(time_down_button_image, time_down_button_scale_x, time_down_button_scale_y)

    @time_down_button = Button.new(0, 0, time_down_button_converted_image.width, time_down_button_converted_image.height)
    @time_down_button.set_image(time_down_button_converted_image)
    @time_down_button.set_pos(@x + (@width - @time_down_button.width) * 0.25, @y + (@height - @time_down_button.height) * 0.665)

    @set_time_label = Fonts.new(0, 0, "viberation time", @height * 0.07, C_BLACK, {:target=>@image, :shadow=>false})
    @set_time_label.set_pos((@width - @set_time_label.width) * 0.65, (@height - @set_time_label.height) * 0.55)


    # core = Core.new

  end

  def set_pos(x, y)
    @x = x
    @y = y
    @message_box.set_pos(@x + @width * 0.05, @y + @height * 0.2)
    @time_input_box.set_pos(@x + @width * 0.35, @y + @height * 0.6)
    @connect_button.set_pos(@x + (@width - @connect_button.width) * 0.8, @y + (@height - @connect_button.height) * 0.9)
    @test_button.set_pos(@x + (@width - @test_button.width) * 0.2, @y + (@height - @test_button.height) * 0.9)
    @time_up_button.set_pos(@x + (@width - @time_up_button.width) * 0.75, @y + (@height - @time_up_button.height) * 0.665)
    @time_down_button.set_pos(@x + (@width - @time_down_button.width) * 0.25, @y + (@height - @time_down_button.height) * 0.665)
  end

  def draw
    @target.draw(@x + @shadow_x, @y + @shadow_y, @shadow, @z)
    @target.draw(@x, @y, @image, @z)
    @title_label.draw
    @message_box.draw
    @time_input_box.draw
    @connect_button.draw
    @test_button.draw
    @time_up_button.draw
    @time_down_button.draw
    @set_time_label.draw
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

  Window.width = 1280
  Window.height = 720

  vibeman = VibeMan.new(0, 0, Window.width * 0.24, Window.height * 0.5, {:bg_color=>C_IVORY, :frame_color=>C_BROWN})
  vibeman.set_pos((Window.width - vibeman.width) * 0.96, (Window.height - vibeman.height) * 0.93)

  vibeman.title_label.set_font_name = "Ballpark"
  vibeman.set_time_label.set_font_name = "Phenomena"
  vibeman.connect_button.font_name = "Phenomena"
  vibeman.test_button.font_name = "Phenomena"
  vibeman.time_input_box.font_name = "Phenomena"


  Window.bgcolor = C_GREEN
  Window.loop do
    vibeman.draw if vibeman
  end
end

