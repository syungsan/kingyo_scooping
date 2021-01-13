#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

# exerbで固めたexeから起動するときカレントディレクトリをexeのパスにするネ！
if defined?(ExerbRuntime)
  Dir.chdir(File.dirname(ExerbRuntime.filepath))
end

require "dxruby" # DXRuby本体
require "./lib/dxruby/scene"

# インストールするフォント ###
# たぬき油性マジック
# 自由の翼フォント
# チェックポイントフォント
# 07ラノベPOP
# AR教科書体M
# みかちゃん
# Ballpark
# Boldhead
# Phenomena


class Configuration

  attr_reader :fps, :frame_step, :app_name, :app_sub_title, :copyright, :ver_number,
              :post_url, :get_url, :default_name

  require "./lib/display"
  require "./lib/dxruby/color"
  require "./scripts/resolution"

  include Display
  include Color

  # アプリケーション設定
  APPLICATION_NAME = "金魚すくい"
  APPLICATION_SUB_TITLE = "視線入力対応版"
  COPYRIGHT = "Powered by Ruby, DXRuby & VisualuRuby."
  VERSION_NUMBER = "0.9.5"
  APPLICATION_ICON = "./images/icon.ico"

  FPS = 60
  FRAME_STEP = 1
  FRAME_SKIP = true

  # データベース POST URL
  POST_URL = "http://tk2-254-36598.vs.sakura.ne.jp/ranking/kingyo_scoopings/record"

  # データベース GET URL
  GET_URL = "http://tk2-254-36598.vs.sakura.ne.jp/ranking/kingyo_scoopings/show"

  DEFAULT_NAME = "ななしさん"

  # 初期のウィンドウカラー
  DEFAULT_BACK_GROUND_COLER = C_AQUA_MARINE

  # 起動時にウィンドウを画面中央に表示する
  IS_WINDOW_CENTER = true

  TANUKI_MAGIC_FONT = "./fonts/TanukiMagic.ttf"
  JIYUNO_TSUBASA_FONT = "./fonts/JiyunoTsubasa.ttf"
  CHECK_POINT_FONT = "./fonts/CP Font.ttf"
  LIGHT_NOVEL_POP_FONT = "./fonts/ラノベPOP.otf"
  AR_KYOUKASYOTAI_M_FONT = "./fonts/JTST00M.TTC"
  MIKACHAN_FONT = "./fonts/mikachanALL.ttc"
  BALL_PARK_FONT = "./fonts/BALLW___.TTF"
  BOLDHEAD_FONT = "./fonts/Boldhead.otf"
  PHENOMENA_FONT = "./fonts/Phenomena-Bold.ttf"

  def initialize

    $scores = {:name=>DEFAULT_NAME, :score=>0, :technical_point=>0, :max_combo=>0,
               :catched_kingyo_number=>0, :catched_boss_number=>0, :cognomen=>"ウンコちゃん", :color=>C_BROWN}

    @fps = FPS
    @frame_step = FRAME_STEP

    @app_name = APPLICATION_NAME
    @app_sub_title = APPLICATION_SUB_TITLE
    @copyright = COPYRIGHT
    @ver_number = VERSION_NUMBER

    @post_url = POST_URL
    @get_url = GET_URL

    @default_name = DEFAULT_NAME

    # フォントのインストール
    Font.install(TANUKI_MAGIC_FONT)
    Font.install(JIYUNO_TSUBASA_FONT)
    Font.install(CHECK_POINT_FONT)
    Font.install(LIGHT_NOVEL_POP_FONT)
    Font.install(AR_KYOUKASYOTAI_M_FONT)
    Font.install(MIKACHAN_FONT)
    Font.install(BALL_PARK_FONT)
    Font.install(BOLDHEAD_FONT)
    Font.install(BALL_PARK_FONT)
    Font.install(PHENOMENA_FONT)

    resolutions =  Window.get_screen_modes.select {
      |resolution| resolution.delete_at(2) }.uniq!.sort {|a,b| a[0] <=> b[0]}.reverse

    option = {:resolutions=>resolutions, :app_name=>APPLICATION_NAME, :version=>VERSION_NUMBER}
    resolution = VRLocalScreen.modalform(nil, nil, ResolutionDialog, nil, option)

    if resolution == "cancel" or resolution == false then
      exit
    else
      window_size = resolution[0]
      window_mode = resolution[1]
    end

    initWindowRect = setDisplayFixWindow(window_size, IS_WINDOW_CENTER)
    if initWindowRect[:windowX] and initWindowRect[:windowY] then
      windowX, windowY = initWindowRect[:windowX], initWindowRect[:windowY]
      Window.x = windowX
      Window.y = windowY
    end

    Window.width  = initWindowRect[:windowWidth]
    Window.height = initWindowRect[:windowHeight]
    Window.caption = "#{APPLICATION_NAME} Ver#{VERSION_NUMBER}"
    Window.loadIcon(APPLICATION_ICON)
    Window.bgcolor = DEFAULT_BACK_GROUND_COLER
    Window.frameskip = FRAME_SKIP
    Window.windowed = window_mode

    # Windowを最前面表示
    set_window_top(Window.hWnd)
  end
end

# mp3などを鳴らすため
Dir.chdir("./lib/dxruby") do
  require "Bass"
end
Bass.init(Window.hWnd)

$config = Configuration.new


class SplashScene < Scene::Base

  require "./lib/dxruby/color"
  require "./scripts/card"

  include Color

  SYMBOL_FRONT_IMAGE = "./images/simple_goldfish.png"
  SYMBOL_BACK_IMAGE = "./images/icon.png"

  MAX_WAIT_COUNT = 180

  def init
    @copyright_1_label = Fonts.new(0, 0, "Produced by", Window.height * 0.02, C_GREEN,
                             {:font_name=>"Boldhead"})
    @copyright_1_label.set_pos((Window.width - @copyright_1_label.width) * 0.5,
                               (Window.height - @copyright_1_label.height) * 0.6)

    @copyright_2_label = Fonts.new(0, 0, "Tadano Laboratory", Window.height * 0.02, C_RED,
                             {:font_name=>"Boldhead"})
    @copyright_2_label.set_pos((Window.width - @copyright_2_label.width) * 0.5,
                               (Window.height - @copyright_2_label.height) * 0.63)

    @card = Card.new(0, 0, Window.width * 0.11, Window.width * 0.11)
    @card.set_pos((Window.width - @card.width) * 0.5, (Window.height - @card.height) * 0.45)

    @card.set_image(SYMBOL_FRONT_IMAGE, SYMBOL_BACK_IMAGE)
    @card.flip_speed = 2
    @card.mode = :turn

    @wait_count = 0
  end

  def update
    if @wait_count >= MAX_WAIT_COUNT then
      self.next_scene = TitleScene
    else
      @card.update if @card
      @wait_count += 1
    end
  end

  def render
    @copyright_1_label.draw if @copyright_1_label
    @copyright_2_label.draw if @copyright_2_label
    @card.draw
  end

  def will_disappear

  end
end


# タイトル・シーン
class TitleScene < Scene::Base

  require "./lib/dxruby/images"
  require "./lib/dxruby/fonts"
  require "./lib/dxruby/button"
  require "./lib/dxruby/color"
  require "./lib/dxruby/easing"

  require "./scripts/poi"
  require "./scripts/vibeman"

  include Color
  include Easing

  CLICK_SE = "./sounds/meka_ge_mouse_s02.wav"
  START_GAME_SE = "./sounds/decision27.wav"
  BACK_GROUND_IMAGE = "./images/VectorNaturalGreenBackground_S.png"
  START_BUTTON_IMAGE = "./images/start_button.png"
  EXIT_BUTTON_IMAGE = "./images/s_3.png"
  WINDOW_MODE_BUTTON_IMAGE = "./images/s_2.png"
  RANKING_BUTTON_IMAGE = "./images/ranking_button.png"
  VIBEMAN_BUTTON_IMAGE = "./images/1067276.png"
  OK_BUTTON_IMAGE = "./images/m_4.png"
  CANCEL_BUTTON_IMAGE = "./images/m_1.png"

  MAX_COUNT_IN_WINDOW = 40
  MAX_COUNT_IN_GAZE_AREA = 30

  POI_WIDTH_SIZE_RATIO = 0.13
  MAX_GAZE_COUNT = 15
  POI_GAZE_RADIUS_RATIO = 0.8
  
  def init

    # 必要最小限のグローバル変数を初期化
    $scores = {:name=>$config.default_name, :score=>0, :technical_point=>0, :max_combo=>0,
               :catched_kingyo_number=>0, :catched_boss_number=>0, :cognomen=>"ウンコちゃん", :color=>C_BROWN}

    @click_se = Sound.new(CLICK_SE)
    @start_game_se = Sound.new(START_GAME_SE)

    background_image = Image.load(BACK_GROUND_IMAGE)
    @background_image = Images.fit_resize(background_image, Window.width, Window.height)

    @title_label = Fonts.new(0, 0, $config.app_name, Window.height * 0.2, C_RED,
                            {:font_name=>"チェックポイントフォント"})
    @title_label.set_pos((Window.width - @title_label.width) * 0.5, (Window.height - @title_label.height) * 0.3)

    @sub_title_label = Fonts.new(0, 0, $config.app_sub_title, Window.height * 0.1, C_ORANGE,
                                 {:font_name=>"AR教科書体M"})
    @sub_title_label.set_pos((Window.width - @sub_title_label.width) * 0.5,
                             (Window.height - @sub_title_label.height) * 0.12)

    @version_number_label = Fonts.new(0, 0, "Version #{$config.ver_number}",
                                      @title_label.height * 0.3, C_GREEN, {:font_name=>"自由の翼フォント"})
    @version_number_label.set_pos(@title_label.x + @title_label.width - @version_number_label.width,
                                  @title_label.y + @title_label.height)

    @copyright_label = Fonts.new(0, 0, $config.copyright, Window.height * 0.06, C_BLACK,
                                {:font_name=>"07ラノベPOP"})
    @copyright_label.set_pos((Window.width - @copyright_label.width) * 0.5,
                             (Window.height - @copyright_label.height) * 0.9)

    ranking_button_image = Image.load(RANKING_BUTTON_IMAGE)
    ranking_button_scale = Window.height * 0.04 / ranking_button_image.height
    ranking_button_converted_image = Images.scale_resize(ranking_button_image,
                                                         ranking_button_scale, ranking_button_scale)
    @ranking_button = Button.new
    @ranking_button.set_image(ranking_button_converted_image)
    @ranking_button.set_pos((Window.width - @ranking_button.width) * 0.5,
                            (Window.height - @ranking_button.height) * 0.6)

    start_button_image = Image.load(START_BUTTON_IMAGE)
    start_button_scale = Window.height * 0.06 / start_button_image.height
    start_button_converted_image = Images.scale_resize(start_button_image, start_button_scale, start_button_scale)
    @start_button = Button.new
    @start_button.set_image(start_button_converted_image)
    @start_button.set_pos((Window.width - @start_button.width) * 0.5, (Window.height - @start_button.height) * 0.73)

    exit_button_image = Image.load(EXIT_BUTTON_IMAGE)
    exit_button_scale = Window.width * 0.065 / exit_button_image.width
    exit_button_converted_image = Images.scale_resize(exit_button_image, exit_button_scale, exit_button_scale)
    @exit_button = Button.new
    @exit_button.set_image(exit_button_converted_image)
    @exit_button.set_string("Exit", exit_button_converted_image.height * 0.6,
                              "07ラノベPOP", {:color=>C_DARK_BLUE})
    @exit_button.set_pos(Window.width - @exit_button.width, 0)

    window_mode_button_image = Image.load(WINDOW_MODE_BUTTON_IMAGE)
    window_mode_button_scale = Window.width * 0.065 / window_mode_button_image.width
    window_mode_button_converted_image = Images.scale_resize(window_mode_button_image,
                                                             window_mode_button_scale, window_mode_button_scale)
    @window_mode_button = Button.new
    @window_mode_button.set_image(window_mode_button_converted_image)
    @window_mode_button.set_string("Full/Win", window_mode_button_converted_image.height * 0.5,
                                   "07ラノベPOP", {:color=>C_DARK_BLUE})
    @window_mode_button.set_pos(Window.width - (@exit_button.width + @window_mode_button.width), 0)

    vibeman_button_image = Image.load(VIBEMAN_BUTTON_IMAGE)
    vibeman_button_scale = Window.height * 0.08 / vibeman_button_image.height
    vibeman_button_converted_image = Images.scale_resize(vibeman_button_image,
                                                         vibeman_button_scale, vibeman_button_scale)
    @vibeman_start_button = Button.new(0, 0, vibeman_button_converted_image.width,
                                       vibeman_button_converted_image.height,
                                 "Vibeman", vibeman_button_converted_image.height * 0.4,
                                       {:font_name=>"Ballpark", :str_color=>C_CREAM})
    @vibeman_start_button.set_image(vibeman_button_converted_image)
    @vibeman_start_button.name = "vibeman_start_button"
    @vibeman_start_button.set_pos((Window.width - @vibeman_start_button.width) * 0.99,
                                  (Window.height - @vibeman_start_button.height) * 0.98)

    $vibeman = VibeMan.new(0, 0, Window.width * 0.24, Window.width * 0.398,
                           {:bg_color=>C_IVORY, :frame_color=>C_BROWN,
                            :frame_thickness=>(Window.width * 0.004).to_i, :radius=>Window.width * 0.02})
    $vibeman.set_pos(Window.width, (Window.height - $vibeman.height) * 0.6)
    $vibeman.is_active_dialog = false

    $vibeman.title_label.font_name = "Ballpark"
    $vibeman.set_time_label.font_name = "Phenomena"
    $vibeman.connect_button.font_name = "Phenomena"
    $vibeman.test_button.font_name = "Phenomena"
    $vibeman.time_input_box.font_name = "Phenomena"
    $vibeman.ok_button.font_name = "Phenomena"
    $vibeman.output_box.font_name = "自由の翼フォント"
    2.times do |index|
      $vibeman.change_type_labels[index].font_name = "自由の翼フォント"
    end

    exit_message_dialog_width = Window.width * 0.5
    exit_message_dialog_height = exit_message_dialog_width * 0.5
    exit_message_dialog_option = {:frame_thickness=>(exit_message_dialog_width * 0.02).round,
                                    :radius=>exit_message_dialog_width * 0.03,
                                    :bg_color=>C_CREAM, :frame_color=>C_CYAN}
    @exit_message_dialog = MessageDialog.new(0, 0, exit_message_dialog_width, exit_message_dialog_height,
                                               1, exit_message_dialog_option)
    @exit_message_dialog.set_message("アプリを終了しますか？", "",
                                       @exit_message_dialog.height * 0.15, C_BROWN, "みかちゃん")
    @exit_message_dialog.set_pos((Window.width - @exit_message_dialog.width) * 0.5,
                                   (Window.height - @exit_message_dialog.height) * 0.5)

    @exit_message_dialog.ok_button.font_color = C_DARK_BLUE
    @exit_message_dialog.ok_button.font_name = "07ラノベPOP"
    @exit_message_dialog.ok_button.name = "exit_message_ok_button"

    @exit_message_dialog.cancel_button.font_color = C_DARK_BLUE
    @exit_message_dialog.cancel_button.font_name = "07ラノベPOP"
    @exit_message_dialog.cancel_button.name = "exit_message_cancel_button"

    ok_button_image = Image.load(OK_BUTTON_IMAGE)
    @exit_message_dialog.ok_button.set_image(
      Images.fit_resize(ok_button_image, @exit_message_dialog.ok_button.width,
                        @exit_message_dialog.ok_button.height))

    cancel_button_image = Image.load(CANCEL_BUTTON_IMAGE)
    @exit_message_dialog.cancel_button.set_image(Images.fit_resize(
      cancel_button_image, @exit_message_dialog.cancel_button.width, @exit_message_dialog.cancel_button.height))

    @is_exitable = false

    @buttons = [@start_button, @exit_button, @window_mode_button, @ranking_button, @exit_message_dialog.ok_button,
                @exit_message_dialog.cancel_button, @vibeman_start_button]

    @is_start_button_blink = false
    @start_button_blink_count = 0
    @wait_stage_change_count = 0

    @cover_layer = Image.new(Window.width, Window.height).box_fill(0, 0,
                                                                   Window.width, Window.height, [164, 128, 128, 128])
    @mouse = Sprite.new
    @mouse.collision = [0, 0]

    @poi = Poi.new(0, 0, nil, Window.width * POI_WIDTH_SIZE_RATIO, @mouse,
                   MAX_GAZE_COUNT, self, nil, {:max_count_in_window=>MAX_COUNT_IN_WINDOW,
                                               :gaze_radius_ratio=>POI_GAZE_RADIUS_RATIO,
                                               :max_count_in_gaze_area=>MAX_COUNT_IN_GAZE_AREA})
    @poi.set_pos((Window.width - @poi.width) * 0.5, (Window.height - @poi.height) * 0.5)

    @vibeman_is_appear = false
    @vibeman_appear_count = 0
  end

  def update

    if @start_button and not @is_exitable and (@start_button.pushed? or @start_button.is_gazed) then
      @start_button.is_gazed = false
      @is_start_button_blink = true unless @is_start_button_blink
      @start_button.hover = false if @start_button.is_hoverable
      @start_game_se.play
      @wait_stage_change_count = 0
    end

    if @window_mode_button and not @is_exitable and (@window_mode_button.pushed? or @window_mode_button.is_gazed) then
      @window_mode_button.is_gazed = false
      if Window.windowed? then
        Window.windowed = false
      else
        Window.windowed = true
      end
      @click_se.play if @click_se
    end

    if (@exit_button and not @is_exitable and
      (@exit_button.pushed? or @exit_button.is_gazed)) or Input.key_push?(K_ESCAPE) then
      @exit_button.is_gazed = false

      @click_se.play if @click_se
      @is_exitable = true
    end

    if (@ranking_button and not @is_exitable and (@ranking_button.pushed? or @ranking_button.is_gazed)) then
      @ranking_button.is_gazed = false
      @click_se.play if @click_se
      self.next_scene = RankingScene
    end

    if @buttons and not @buttons.empty? then
      @buttons.each do |button|
        if $vibeman.is_active_dialog and not button.name == "vibeman_start_button" then
          button.hovered?
        elsif not $vibeman.is_active_dialog and button.name == "vibeman_start_button" and not @is_exitable then
          button.hovered?
        end
        if @is_exitable and (button.name == "exit_message_ok_button" or
          button.name == "exit_message_cancel_button") then
          button.hovered?
        elsif not @is_exitable and not (button.name == "exit_message_ok_button" or
          button.name == "exit_message_cancel_button") then
          button.hovered?
        end
      end
    end

    if (@vibeman_start_button and not @is_exitable and (@vibeman_start_button.pushed? or
      @vibeman_start_button.is_gazed)) and not $vibeman.is_active_dialog then
      @vibeman_start_button.is_gazed = false

      $vibeman.is_active_dialog = true
      @click_se.play if @click_se
      @vibeman_is_appear = true
    end
    $vibeman.update if $vibeman

    if $vibeman.buttons and not $vibeman.buttons.empty? and $vibeman.is_active_dialog and not @is_exitable then
      $vibeman.buttons.each do |vibeman_button|
        vibeman_button.hovered?
      end
    end

    if @vibeman_is_appear and $vibeman then
      if @vibeman_appear_count <= 1 then
        $vibeman.set_pos(ease_in_out_quad(@vibeman_appear_count, Window.width, -1 * $vibeman.width * 1.06, 1),
                         (Window.height - $vibeman.height) * 0.6)
        @vibeman_appear_count += 0.01
      else
        @vibeman_appear_count = 0
        @vibeman_is_appear = false
      end
    end
    $vibeman.set_pos(Window.width, (Window.height - $vibeman.height) * 0.6) if not
    $vibeman.x == Window.width and
      not $vibeman.y == (Window.height - $vibeman.height) * 0.6 and not $vibeman.is_active_dialog

    if @is_exitable then
      $vibeman.is_lock = true
    else
      $vibeman.is_lock = false
    end

    if @exit_message_dialog and @is_exitable and
      (@exit_message_dialog.ok_button.pushed? or @exit_message_dialog.ok_button.is_gazed) then
      @exit_message_dialog.ok_button.is_gazed = false
      exit
    end

    if @exit_message_dialog and @is_exitable and
      (@exit_message_dialog.cancel_button.pushed? or @exit_message_dialog.cancel_button.is_gazed) then
      @exit_message_dialog.cancel_button.is_gazed = false

      @click_se.play if @click_se
      @is_exitable = false
    end

    @mouse.x, @mouse.y = Input.mouse_pos_x, Input.mouse_pos_y if @mouse

    @poi.update if @poi

    if @is_start_button_blink then
      if @start_button_blink_count >= 10 then
        @start_button.blink
        @start_button_blink_count = 0
      else
        @start_button_blink_count += 1
      end
      if @wait_stage_change_count >= 150 then
        self.next_scene = GameScene
        @wait_stage_change_count = 0
      else
        @wait_stage_change_count += 1
      end
    end
  end

  def gazed(x, y, center_x, center_y)

    if @buttons and not @buttons.empty? then
      @buttons.each do |button|
        if x + center_x >= button.x and x + center_x <= button.x + button.width and
          y + center_y >= button.y and y + center_y <= button.y + button.height then

          if @is_exitable and (button.name == "exit_message_ok_button" or
            button.name == "exit_message_cancel_button") then
            button.is_gazed = true
          elsif not @is_exitable and
            not (button.name == "exit_message_ok_button" or button.name == "exit_message_cancel_button") then
            button.is_gazed = true
          end
        end
      end
    end
    @poi.mode = :search

    if $vibeman.buttons and not $vibeman.buttons.empty? and not @is_exitable then
      $vibeman.buttons.each do |vibeman_button|
        if x + center_x >= vibeman_button.x and x + center_x <= vibeman_button.x + vibeman_button.width and
          y + center_y >= vibeman_button.y and y + center_y <= vibeman_button.y + vibeman_button.height then
          vibeman_button.is_gazed = true
        end
      end
    end

    if $vibeman.change_type_radio_buttons and not $vibeman.change_type_radio_buttons.empty? and not @is_exitable then
      $vibeman.change_type_radio_buttons.each do |vibeman_radio_button|
        if x + center_x >= vibeman_radio_button.x and
          x + center_x <= vibeman_radio_button.x + vibeman_radio_button.size and
          y + center_y >= vibeman_radio_button.y and
          y + center_y <= vibeman_radio_button.y + vibeman_radio_button.size then
          vibeman_radio_button.is_gazed = true
        end
      end
    end
  end

  def render

    Window.draw(0, 0, @background_image)

    @title_label.draw if @title_label
    @sub_title_label.draw if @sub_title_label
    @version_number_label.draw if @version_number_label
    @copyright_label.draw if @copyright_label

    @ranking_button.draw if @ranking_button
    @start_button.draw if @start_button
    @exit_button.draw if @exit_button
    @window_mode_button.draw if @window_mode_button

    @vibeman_start_button.draw if @vibeman_start_button and not $vibeman.is_active_dialog
    $vibeman.draw if $vibeman and $vibeman.is_active_dialog

    Window.draw(0, 0, @cover_layer) if @cover_layer and @is_exitable
    @exit_message_dialog.draw if @exit_message_dialog and @is_exitable

    @poi.draw if @poi
  end

  def will_disappear

  end
end


# ゲーム・シーン
class GameScene < Scene::Base

  require "rubygems"
  require "bigdecimal"

  require "./lib/dxruby/fonts"
  require "./lib/dxruby/images"
  require "./lib/dxruby/button"
  require "./lib/dxruby/color"
  require "./lib/common"
  require "./lib/encode" # 文字コード変換

  require "./scripts/border"
  require "./scripts/kingyo"
  require "./scripts/poi"
  require "./scripts/container"
  require "./scripts/weed"
  require "./scripts/boss"
  require "./scripts/bgm_info"
  require "./scripts/alert"
  require "./scripts/splash"
  require "./scripts/SampleMapping"
  require "./scripts/gauge"

  include Common
  include Color

  CLICK_SE = "./sounds/meka_ge_mouse_s02.wav"
  MAIN_BGM = "./sounds/minamo.mp3"
  ALERT_BGM = "./sounds/nc40157.wav"
  BOSS_BGM = "./sounds/boss_panic_big_march.mp3"
  SPLASH_SMALL_SE = "./sounds/water-drop3.wav"
  SPLASH_RARGE_SE = "./sounds/water-throw-stone2.wav"
  CHANGE_STAGE_SE = "./sounds/sei_ge_bubble06.wav"

  OK_BUTTON_IMAGE = "./images/m_4.png"
  RETURN_BUTTON_IMAGE = "./images/s_3.png"
  WINDOW_MODE_BUTTON_IMAGE = "./images/s_2.png"
  CANCEL_BUTTON_IMAGE = "./images/m_1.png"
  STONE_TILE_IMAGE = "./images/stone_tile.png"
  AQUARIUM_BACK_IMAGE = "./images/seamless-water.jpg"

  MAX_COUNT_IN_WINDOW = 60
  MAX_COUNT_IN_GAZE_AREA = 30

  POI_HEIGHT_SIZE_RATIO = 0.35
  MAX_GAZE_COUNT = 60
  POI_GAZE_RADIUS_RATIO = 0.5

  POI_IS_IMPACT = true
  POI_IS_VIEW_IMPACT_RANGE = true

  FIRST_STAGE_NUMBER = 1
  FIRST_MODE = :start
  MAX_STAGE_NUMBER = 3

  IMPACT_GAINS = [1.0, 2.0, 3.0]

  KINGYO_NUMBERS = [5, 15, 25]
  KINGYO_SCALE_RANGES = [[0.1, 0.15], [0.1, 0.2], [0.1, 0.25]]

  KINGYO_SPEED_RANGES = [{:wait=>[0, 0.001], :move=>[0.001, 0.024], :escape=>[0.003, 0.072]},
                         {:wait=>[0, 0.001], :move=>[0.001, 0.024], :escape=>[0.003, 0.072]},
                         {:wait=>[0, 0.001], :move=>[0.001, 0.024], :escape=>[0.003, 0.072]}]

  KINGYO_MODE_RANGES = [{:wait=>[360, 660], :move=>[0, 100], :escape=>[0, 100]},
                        {:wait=>[60, 360], :move=>[0, 200], :escape=>[0, 200]},
                        {:wait=>[0, 60], :move=>[0, 300], :escape=>[0, 300]}]

  KINGYO_PERSONALITY_WEIGHTS = [{:escape=>50, :ignore=>50, :against=>10},
                               {:escape=>60, :ignore=>30, :against=>20},
                               {:escape=>80, :ignore=>10, :against=>30}]

  KINGYO_ESCAPE_CHANGE_TIMINGS = [0.4, 0.3, 0.2]

  KIND_OF_KINGYOS = [:red, :black]

  BOSS_SCALE_RANGES = [0.3, 0.7]
  BOSS_SPEED_RANGES = {:wait=>[0, 0.01], :move=>[0.001, 0.01], :escape=>[0.001, 0.01]}
  BOSS_MODE_RANGES = {:wait=>[0, 100], :move=>[0, 100], :escape=>[0, 100]}
  BOSS_PERSONALITY_WEIGHTS = {:escape=>10, :ignore=>30, :against=>80}
  BOSS_ESCAPE_CHANGE_TIMINGS = 0.3

  WEED_NUMBERS = [2, 5, 8]
  WEED_SPEED_RANGES = {:escape=>[10.0, 20.0]}
  WEED_MODE_RANGES = {:escape=>[0, 50]}
  WEED_SCALE_RANGES = [[0.1, 0.3], [0.2, 0.4], [0.3, 0.5]]
  WEED_ESCAPE_CHANGE_TIMINGS = 0.3

  CONTAINER_SPEED_RANGES = {:escape=>[80.0, 100.0]}
  CONTAINER_MODE_RANGES = {:escape=>[0, 80]}
  CONTAINER_ESCAPE_CHANGE_TIMINGS = 0.3

  BASE_SCORES = {"red_kingyo"=>100, "black_kingyo"=>50, "weed"=>-300, "boss"=>5000}

  KINGYO_DAMAGE_UNIT_RATIO = 0.01
  WEED_DAMAGE_UNIT_RATIO = 0.1
  BOSS_DAMAGE_UNIT_RATIO = 0.05
  BUBBLE_SHOT_DAMAGE_UNIT_RATIO = 0.01

  CHALLENGE_POINT_UP_RANGE = 600
  MAX_POI_GAUGE_NUMBER = 5

  TILDE =  "\x81\x60".encode("BINARY")
  MAIN_BGM_DATE = ["水面", "Composed by iPad", "しゅんじ" + TILDE]
  BOSS_BGM_DATE = ["ボス・パニック大行進", "Composed by iPad", "しゅんじ" + TILDE]
  MAIN_ALERT_STRING = "警告！ ボス金魚出現！"
  SUB_ALERT_STRING = "WARNING!"

  Z_POSITION_FLY = 400
  Z_POSITION_TOP = 300
  Z_POSITION_UP = 200
  Z_POSITION_DOWN = 100
  Z_POSITION_BOTTOM = 0

  POI_CATCH_ADJUST_RANGE_RATIO = 1.0

  CONTAINER_CATCH_ADJUST_RANGE_RATIO = 1.0
  CONTAINER_RESERVE_ADJUST_RANGE_RATIO = 0.55
  CONTAINER_CONTACT_ADJUST_RANGE_RATIO = 1.2

  START_MAX_COUNT = 180
  POINT_LABEL_MOVE_SCALE = 5.0
  
  def init

    @click_se = Sound.new(CLICK_SE)
    @change_stage_se = Sound.new(CHANGE_STAGE_SE)
    @splash_small_se = Sound.new(SPLASH_SMALL_SE)
    @splash_rarge_se = Sound.new(SPLASH_RARGE_SE)

    @main_bgm = Bass.loadSample(MAIN_BGM)
    @alert_bgm = Bass.loadSample(ALERT_BGM)
    @boss_bgm = Bass.loadSample(BOSS_BGM)

    return_button_image = Image.load(RETURN_BUTTON_IMAGE)
    return_button_scale = Window.width * 0.065 / return_button_image.width
    return_button_converted_image = Images.scale_resize(return_button_image, return_button_scale, return_button_scale)
    @return_button = Button.new
    @return_button.set_image(return_button_converted_image)
    @return_button.set_string("Return", return_button_converted_image.height * 0.6,
                              "07ラノベPOP", {:color=>C_DARK_BLUE})
    @return_button.set_pos(Window.width - @return_button.width, 0)

    window_mode_button_image = Image.load(WINDOW_MODE_BUTTON_IMAGE)
    window_mode_button_scale = Window.width * 0.065 / window_mode_button_image.width
    window_mode_button_converted_image = Images.scale_resize(window_mode_button_image,
                                                             window_mode_button_scale, window_mode_button_scale)
    @window_mode_button = Button.new
    @window_mode_button.set_image(window_mode_button_converted_image)
    @window_mode_button.set_string("Full/Win", window_mode_button_converted_image.height * 0.5,
                                   "07ラノベPOP", {:color=>C_DARK_BLUE})
    @window_mode_button.set_pos(Window.width - (@return_button.width + @window_mode_button.width), 0)

    return_message_dialog_width = Window.width * 0.5
    return_message_dialog_height = return_message_dialog_width * 0.5
    return_message_dialog_option = {:frame_thickness=>(return_message_dialog_width * 0.02).round,
                                    :radius=>return_message_dialog_width * 0.03,
                                    :bg_color=>C_CREAM, :frame_color=>C_CYAN}
    @return_message_dialog = MessageDialog.new(0, 0, return_message_dialog_width, return_message_dialog_height,
                                               1, return_message_dialog_option)
    @return_message_dialog.set_message("タイトルに戻りますか？", "",
                                       @return_message_dialog.height * 0.15, C_BROWN, "みかちゃん")
    @return_message_dialog.set_pos((Window.width - @return_message_dialog.width) * 0.5,
                                   (Window.height - @return_message_dialog.height) * 0.5)
    @return_message_dialog.z = Z_POSITION_TOP

    @return_message_dialog.ok_button.font_color = C_DARK_BLUE
    @return_message_dialog.ok_button.font_name = "07ラノベPOP"
    @return_message_dialog.ok_button.name = "return_message_ok_button"
    @return_message_dialog.ok_button.z = Z_POSITION_TOP

    @return_message_dialog.cancel_button.font_color = C_DARK_BLUE
    @return_message_dialog.cancel_button.font_name = "07ラノベPOP"
    @return_message_dialog.cancel_button.name = "return_message_cancel_button"
    @return_message_dialog.cancel_button.z = Z_POSITION_TOP

    ok_button_image = Image.load(OK_BUTTON_IMAGE)
    @return_message_dialog.ok_button.set_image(
      Images.fit_resize(ok_button_image, @return_message_dialog.ok_button.width,
                        @return_message_dialog.ok_button.height))

    cancel_button_image = Image.load(CANCEL_BUTTON_IMAGE)
    @return_message_dialog.cancel_button.set_image(Images.fit_resize(
      cancel_button_image, @return_message_dialog.cancel_button.width, @return_message_dialog.cancel_button.height))

    @is_returnable = false

    @buttons = [@return_button, @window_mode_button, @return_message_dialog.ok_button,
                @return_message_dialog.cancel_button]

    stone_tile_image = Image.load(STONE_TILE_IMAGE)
    stone_tile_image_scale = Window.height * 0.3 / stone_tile_image.height
    stone_tile_converted_image = Images.scale_resize(stone_tile_image, stone_tile_image_scale, stone_tile_image_scale)
    stone_tile_rt = RenderTarget.new(Window.width, Window.height)
    stone_tile_rt.drawTile(0, 0, [[0]], [stone_tile_converted_image], nil, nil, nil, nil)
    @stone_tile_image = stone_tile_rt.to_image
    stone_tile_converted_image.dispose
    stone_tile_rt.dispose

    aquarium_back_image = Image.load(AQUARIUM_BACK_IMAGE)
    aquarium_back_image_scale = Window.height * 0.15 / aquarium_back_image.height
    aquarium_back_converted_image = Images.scale_resize(aquarium_back_image, aquarium_back_image_scale,
                                                        aquarium_back_image_scale)
    aquarium_back_rt = RenderTarget.new(Window.width, Window.height)
    aquarium_back_rt.drawTile(0, 0, [[0]], [aquarium_back_converted_image], nil, nil, nil, nil)
    @aquarium_back_image = aquarium_back_rt.to_image
    aquarium_back_converted_image.dispose
    aquarium_back_rt.dispose

    @wave_shader = SampleMappingShader.new
    @shader_rt = RenderTarget.new(Window.width, Window.height)

    @stage_info_label = Fonts.new(0, 0, "", Window.height * 0.2, C_BROWN, {:font_name=>"07ラノベPOP"})
    @stage_info_label.z = Z_POSITION_TOP

    @score_label = Fonts.new(0, 0, "SCORE : #{$scores[:score]}点", Window.height * 0.05, C_GREEN,
                             {:font_name=>"自由の翼フォント"})
    @score_label.z = Z_POSITION_TOP

    @border = Border.new(0, 0, Window.width, Window.height)

    @container = Container.new(0, 0, nil, Window.height * 0.4,
                               { :escape=>[Math.sqrt(Window.height * CONTAINER_SPEED_RANGES[:escape][0]),
                                           Math.sqrt(Window.height * CONTAINER_SPEED_RANGES[:escape][1])]},
      {:escape=>[Math.sqrt(Window.height * CONTAINER_MODE_RANGES[:escape][0]),
                  Math.sqrt(Window.height * CONTAINER_MODE_RANGES[:escape][1])]}, CONTAINER_ESCAPE_CHANGE_TIMINGS)

    @container.set_pos(rand_float(@border.x, @border.x + @border.width - @container.width),
                       rand_float(@border.y, @border.y + @border.height - @container.height))
    @container.z = Z_POSITION_DOWN

    @mouse = Sprite.new
    @mouse.collision = [0, 0]

    @poi = Poi.new(0, 0, nil, Window.height * POI_HEIGHT_SIZE_RATIO, @mouse,
                   MAX_GAZE_COUNT, self, @container, {:max_count_in_window=>MAX_COUNT_IN_WINDOW,
                                         :gaze_radius_ratio=>POI_GAZE_RADIUS_RATIO,
                                                      :max_count_in_gaze_area=>MAX_COUNT_IN_GAZE_AREA})
    @poi.set_pos((Window.width - @poi.width) * 0.5, (Window.height - @poi.height) * 0.5)
    @poi.z = Z_POSITION_TOP

    @poi.is_impact = POI_IS_IMPACT
    @poi.view_impact_range = POI_IS_VIEW_IMPACT_RANGE

    bgm_info_height = Window.height * 0.15
    bgm_info_width = bgm_info_height * 2.7
    @bgm_info = BgmInfo.new(Window.width, Window.height * 0.08, bgm_info_width, bgm_info_height)
    @bgm_info.initial_velocity = -1 * Math.sqrt(Window.height * 8.7)
    @bgm_info.z = Z_POSITION_TOP

    life_gauge_width = Window.width * 0.75
    life_gauge_height = Window.height * 0.02
    @life_gauge = LifeGauge.new(life_gauge_width, life_gauge_height)
    @life_gauge.set_pos((Window.width - @life_gauge.width) * 0.2, (Window.height - @life_gauge.height) * 0.95)
    @life_gauge.z = Z_POSITION_UP
    @life_continueble = true

    poi_gauge_height_size = Window.height * 0.1
    poi_gauge_interval = Window.width * 0.023

    @poi_gauges = []
    MAX_POI_GAUGE_NUMBER.times do |index|
      poi_gauge = PoiGage.new(nil, poi_gauge_height_size)
      poi_gauge.set_pos((Window.width - poi_gauge.width) * 0.85 + (poi_gauge_interval * index),
                        (Window.height - poi_gauge.height) * 0.96)
      poi_gauge.z = Z_POSITION_UP
      @poi_gauges.push(poi_gauge)
    end
    @poi_gauges.reverse!

    @cover_layer = Image.new(Window.width, Window.height).box_fill(0, 0,
                                                                   Window.width, Window.height, [164, 128, 128, 128])

    @alert = Alert.new(0, 0, Window.width, Window.height)
    @alert.z = Z_POSITION_TOP
    @alert.make_sub_alert(SUB_ALERT_STRING, "07ラノベPOP")
    @alert.make_main_alert(MAIN_ALERT_STRING, "チェックポイントフォント")
    @alert.main_alert_speed = -1 * Math.sqrt(Window.height * 0.1)
    @alert.sub_alert_speed = Math.sqrt(Window.height * 0.1)

    @windows = []
    @swimmers = []
    @splashs = []
    @catch_objects = []

    @challenge_point = 0
    @start_count = 0
    @end_count = 0

    @stage_number = FIRST_STAGE_NUMBER
    self.change_mode(FIRST_MODE)
  end

  def change_mode(mode)

    case mode

    when :start

      @change_stage_se.play if @change_stage_se
      self.stage_init

      if @stage_info_label then
        @stage_info_label.string = "ステージ#{@stage_number}"
        @stage_info_label.set_pos((Window.width - @stage_info_label.width) * 0.5,
                                  (Window.height - @stage_info_label.height) * 0.5)
      end

    when :normal

      if  @stage_number == 1 then
        if @bgm then
          @bgm.stop
          @bgm = nil
        end
        if @main_bgm then
          @bgm = @main_bgm
          @bgm.play(:loop=>true, :volume=>0.5)
        end
        if @bgm_info then
          @bgm_info.set_info({:title=>MAIN_BGM_DATE[0], :data=>MAIN_BGM_DATE[1], :copyright=>MAIN_BGM_DATE[2]},
                             {:title=>"たぬき油性マジック",
                              :data=>"たぬき油性マジック", :copyright=>"たぬき油性マジック"},
                             {:title=>@bgm_info.height * 0.3, :data=>@bgm_info.height * 0.2,
                              :copyright=>@bgm_info.height * 0.25})
          @bgm_info.mode = :run
        end
      end

    when :game_over

      if @bgm then
        @bgm.stop
        @bgm = nil
      end
      if @stage_info_label then
        @stage_info_label.string = "Game Over"
        @stage_info_label.color = C_CREAM
        @stage_info_label.set_pos((Window.width - @stage_info_label.width) * 0.5,
                                  (Window.height - @stage_info_label.height) * 0.5)
      end

    when :game_clear

      if @bgm then
        @bgm.stop
        @bgm = nil
      end
      if @stage_info_label then
        @stage_info_label.string = "Game Clear"
        @stage_info_label.color = C_MIKUSAN
        @stage_info_label.set_pos((Window.width - @stage_info_label.width) * 0.5,
                                  (Window.height - @stage_info_label.height) * 0.5)
      end

    when :alert

      @alert.mode = :run if @alert

      if @bgm then
        @bgm.stop
        @bgm = nil
      end
      if @alert_bgm then
        @bgm = @alert_bgm
        @bgm.play(:loop=>true, :volume=>0.5)
      end

      self.boss_init

    when :boss

      if @swimmers.select { |obj| obj.class == Boss}.empty? then
        self.boss_init
      else
        bosss = @swimmers.select { |obj| obj.class == Boss }
        bosss.each do |boss|
          unless boss.is_attackable then
            boss.is_attackable = true
          end
        end
      end

      if @bgm then
        @bgm.stop
        @bgm = nil
      end
      if @boss_bgm then
        @bgm = @boss_bgm
        @bgm.play(:loop=>true, :volume=>0.5)
      end
      if @bgm_info then
        @bgm_info.set_info({:title=>BOSS_BGM_DATE[0], :data=>BOSS_BGM_DATE[1], :copyright=>BOSS_BGM_DATE[2]},
                           {:title=>"たぬき油性マジック", :data=>"たぬき油性マジック", :copyright=>"たぬき油性マジック"},
                           {:title=>@bgm_info.height * 0.24, :data=>@bgm_info.height * 0.2,
                            :copyright=>@bgm_info.height * 0.25})
        @bgm_info.mode = :run
      end
    end

    @mode = mode
  end

  def stage_init

    @poi.impact_gain = IMPACT_GAINS[@stage_number - 1]

    weeds = []
    WEED_NUMBERS[@stage_number - 1].times do |index|
      weed_height = Window.height * rand_float(WEED_SCALE_RANGES[@stage_number - 1][0], WEED_SCALE_RANGES[@stage_number - 1][1])
      weed = Weed.new(0, 0, nil, weed_height, rand(360), index,
                      {:escape=>[Math.sqrt(Window.height * WEED_SPEED_RANGES[:escape][0]),
                                 Math.sqrt(Window.height * WEED_SPEED_RANGES[:escape][1])]},
                      {:escape=>[Math.sqrt(Window.height * WEED_MODE_RANGES[:escape][0]),
                                 Math.sqrt(Window.height * WEED_MODE_RANGES[:escape][1])]}, WEED_ESCAPE_CHANGE_TIMINGS)
      weed.set_pos(random_int(@border.x, @border.x + @border.width - weed.width),
                   random_int(@border.y, @border.y + @border.height - weed.height)) if @border
      weed.z = Z_POSITION_TOP
      weeds.push(weed)
    end

    kingyos = []
    KINGYO_NUMBERS[@stage_number - 1].times do |index|
      kingyo_height = Window.height * rand_float(KINGYO_SCALE_RANGES[@stage_number - 1][0], KINGYO_SCALE_RANGES[@stage_number - 1][1])
      kingyo = Kingyo.new(0, 0, nil, kingyo_height, KIND_OF_KINGYOS[rand(2)], rand(360),
                          index, {:wait=>[Math.sqrt(Window.height * KINGYO_SPEED_RANGES[@stage_number - 1][:wait][0]),
                                          Math.sqrt(Window.height * KINGYO_SPEED_RANGES[@stage_number - 1][:wait][1])],
                                  :move=>[Math.sqrt(Window.height * KINGYO_SPEED_RANGES[@stage_number - 1][:move][0]),
                                          Math.sqrt(Window.height * KINGYO_SPEED_RANGES[@stage_number - 1][:move][1])],
                                  :escape=>[Math.sqrt(Window.height * KINGYO_SPEED_RANGES[@stage_number - 1][:escape][0]),
                                            Math.sqrt(Window.height * KINGYO_SPEED_RANGES[@stage_number - 1][:escape][1])]},
                          {:wait=>[Math.sqrt(Window.height * KINGYO_MODE_RANGES[@stage_number - 1][:wait][0]),
                                   Math.sqrt(Window.height * KINGYO_MODE_RANGES[@stage_number - 1][:wait][1])],
                           :move=>[Math.sqrt(Window.height * KINGYO_MODE_RANGES[@stage_number - 1][:move][0]),
                                   Math.sqrt(Window.height * KINGYO_MODE_RANGES[@stage_number - 1][:move][1])],
                           :escape=>[Math.sqrt(Window.height * KINGYO_MODE_RANGES[@stage_number - 1][:escape][0]),
                                     Math.sqrt(Window.height * KINGYO_MODE_RANGES[@stage_number - 1][:escape][1])]},
                          KINGYO_PERSONALITY_WEIGHTS[@stage_number - 1], KINGYO_ESCAPE_CHANGE_TIMINGS[@stage_number - 1])
      kingyo.set_pos(random_int(@border.x, @border.x + @border.width - kingyo.width),
                     random_int(@border.y, @border.y + @border.height - kingyo.height)) if @border
      kingyo.z = Z_POSITION_TOP
      kingyos.push(kingyo)
    end

    @swimmers = weeds + kingyos
    fisher_yates(@swimmers)
  end

  def boss_init

    bosss = []
    @poi_gauges.size.times do |index|
      boss_height = Window.height * rand_float(BOSS_SCALE_RANGES[0], BOSS_SCALE_RANGES[1])
      boss = Boss.new(0, 0, nil, boss_height, rand(360), index,
                      {:wait=>[Math.sqrt(Window.height * BOSS_SPEED_RANGES[:wait][0]),
                               Math.sqrt(Window.height * BOSS_SPEED_RANGES[:wait][1])],
                       :move=>[Math.sqrt(Window.height * BOSS_SPEED_RANGES[:move][0]),
                               Math.sqrt(Window.height * BOSS_SPEED_RANGES[:move][1])],
                       :escape=>[Math.sqrt(Window.height * BOSS_SPEED_RANGES[:escape][0]),
                                 Math.sqrt(Window.height * BOSS_SPEED_RANGES[:escape][1])]},
                      {:wait=>[Math.sqrt(Window.height * BOSS_MODE_RANGES[:wait][0]),
                               Math.sqrt(Window.height * BOSS_MODE_RANGES[:wait][1])],
                       :move=>[Math.sqrt(Window.height * BOSS_MODE_RANGES[:move][0]),
                               Math.sqrt(Window.height * BOSS_MODE_RANGES[:move][1])],
                       :escape=>[Math.sqrt(Window.height * BOSS_MODE_RANGES[:escape][0]),
                                 Math.sqrt(Window.height * BOSS_MODE_RANGES[:escape][1])]},
                      BOSS_PERSONALITY_WEIGHTS, BOSS_ESCAPE_CHANGE_TIMINGS, @poi, @border.blocks)
      boss.set_pos(random_int(@border.x, @border.x + @border.width - boss.width),
                   random_int(@border.y, @border.y + @border.height - boss.height)) if @border
      boss.z = Z_POSITION_TOP
      bosss.push(boss)
    end

    @swimmers += bosss
    fisher_yates(@swimmers)
  end

  def update

    if @window_mode_button and not @is_returnable and (@window_mode_button.pushed? or @window_mode_button.is_gazed) then
      @window_mode_button.is_gazed = false
      if Window.windowed? then
        Window.windowed = false
      else
        Window.windowed = true
      end
      @click_se.play if @click_se
    end

    if (@return_button and not @is_returnable and
      (@return_button.pushed? or @return_button.is_gazed)) or Input.key_push?(K_ESCAPE) then
      @return_button.is_gazed = false

      @click_se.play if @click_se
      @is_returnable = true
      @poi.z = Z_POSITION_FLY
    end

    if @buttons and not @buttons.empty? then
      @buttons.each do |button|
        if @is_returnable and (button.name == "return_message_ok_button" or
          button.name == "return_message_cancel_button") then
          button.hovered?
        elsif not @is_returnable and
          not (button.name == "return_message_ok_button" or button.name == "return_message_cancel_button") then
          button.hovered?
        end
      end
    end

    if @return_message_dialog and @is_returnable and
      (@return_message_dialog.ok_button.pushed? or @return_message_dialog.ok_button.is_gazed) then
      @return_message_dialog.ok_button.is_gazed = false

      if @bgm then
        @bgm.stop
        @bgm = nil
      end
      @click_se.play if @click_se
      self.next_scene = TitleScene
      @is_returnable = false
      @poi.z = Z_POSITION_TOP
    end

    if @return_message_dialog and @is_returnable and
      (@return_message_dialog.cancel_button.pushed? or @return_message_dialog.cancel_button.is_gazed) then
      @return_message_dialog.cancel_button.is_gazed = false

      @click_se.play if @click_se
      @is_returnable = false
      @poi.z = Z_POSITION_TOP
    end

    @mouse.x, @mouse.y = Input.mouse_pos_x, Input.mouse_pos_y if @mouse

    if @mode == :start then
      if @start_count <= START_MAX_COUNT then
        @wave_shader.update if @wave_shader
        @start_count += 1
      else
        @start_count = 0
        self.change_mode(:normal)
      end
    end

    @bgm_info.update if @bgm_info and @bgm_info.mode == :run and not @mode == :start

    if @alert and @alert.mode == :run and not @mode == :start then
      @alert.update
    elsif @alert and @alert.mode == :finish
      @alert.mode = :wait
      self.change_mode(:boss)
    end

    if @swimmers and not @swimmers.empty? and not @mode == :start
      @swimmers.each do |swimmer|
        swimmer.update

        if not swimmer.mode == :catched and not swimmer.is_reserved then
          if (swimmer.x + swimmer.center_x - (@container.x + (@container.width * 0.5))) ** 2 +
            ((swimmer.y + swimmer.center_y - (@container.y + (@container.height * 0.5))) ** 2) <=
            (@container.width * 0.5 * CONTAINER_CONTACT_ADJUST_RANGE_RATIO) ** 2 then
            swimmer.z = Z_POSITION_BOTTOM
          else
            swimmer.z = Z_POSITION_TOP
          end
        end

        if swimmer.is_reserved then
          max_radius = @container.width * 0.5 * CONTAINER_RESERVE_ADJUST_RANGE_RATIO
          obj_radius = Math.sqrt((swimmer.x + swimmer.center_x - (@container.x + @container.center_x)) ** 2 +
                                   ((swimmer.y + swimmer.center_y - (@container.y + @container.center_y)) ** 2))

          if obj_radius >= max_radius then
            angle = Math.atan2(swimmer.y + swimmer.center_y - (@container.y + @container.center_y),
                               swimmer.x + swimmer.center_x - (@container.x + @container.center_x))
            swimmer.x = @container.x + @container.center_x - (swimmer.width * 0.5) + (max_radius * Math.cos(angle))
            swimmer.y = @container.y + @container.center_y - (swimmer.height * 0.5) + (max_radius * Math.sin(angle))
          end
        end

        if @poi.impact_radius and not @is_returnable and
          (swimmer.x + swimmer.center_x - (@poi.x + (@poi.width * 0.5))) ** 2 +
            ((swimmer.y + swimmer.center_y - (@poi.y + (@poi.height * 0.5))) ** 2) <= @poi.impact_radius ** 2 then

          if swimmer.class == Kingyo or swimmer.class == Boss or swimmer.class == Weed then

            swimmer_radian = Math.atan2(swimmer.y + swimmer.center_y - (@poi.y + (@poi.height * 0.5)),
                                        swimmer.x + swimmer.center_x - (@poi.x + (@poi.width * 0.5)))

            swimmer.angle_candidate = swimmer_radian * (180 / Math::PI) + 90

            if swimmer.class == Weed then
              radian = swimmer.angle * (Math::PI / 180)

              weed_vec_scale = swimmer.height * 0.5
              weed_vector_x = weed_vec_scale * Math.sin(radian)
              weed_vector_y = -1 * weed_vec_scale * Math.cos(radian)

              poi_vector_x = @poi.x + @poi.center_x - (swimmer.x + swimmer.center_x)
              poi_vector_y = @poi.y + @poi.center_y - (swimmer.y + swimmer.center_y)
              poi_vec_scale = Math.sqrt(poi_vector_x ** 2 + (poi_vector_y ** 2))

              dot_weed_and_poi_vec = weed_vector_x * poi_vector_x + (weed_vector_y * poi_vector_y) # 内積
              phi = Math.acos(dot_weed_and_poi_vec / (weed_vec_scale * poi_vec_scale))

              deg_phi = phi * (180 / Math::PI)
              cross = weed_vector_x * poi_vector_y - (weed_vector_y * poi_vector_x) # 外積

              direction_of_rotation = 1 if 0 < deg_phi and deg_phi <= 90
              direction_of_rotation = -1 if 90 < deg_phi and deg_phi <= 180

              if direction_of_rotation * cross < 0 then
                swimmer.direction_of_rotation = :right
              else
                swimmer.direction_of_rotation = :left
              end
            end
            swimmer.change_mode(:escape)
          end
        end

        if @poi.impact_radius and not @is_returnable and
          (@container.x + @container.center_x - (@poi.x + (@poi.width * 0.5))) ** 2 +
          ((@container.y + @container.center_y - (@poi.y + (@poi.height * 0.5))) ** 2) <= @poi.impact_radius ** 2 then

          container_radian = Math.atan2(@container.y + @container.center_y - (@poi.y + (@poi.height * 0.5)),
                                        @container.x + @container.center_x - (@poi.x + (@poi.width * 0.5)))
          @container.angle = container_radian * (180 / Math::PI) + 90
          @container.change_mode(:escape)
        end

        if not @swimmers.select { |obj| obj.class == Boss }.empty? and not @is_returnable then
          bosss = @swimmers.select { |obj| obj.class == Boss }

          bosss.each do |boss|
            if boss.bubble_shots and not boss.bubble_shots.empty? and boss.is_attackable then

              boss.bubble_shots.each do |bubble_shot|
                bubble_shot.z = Z_POSITION_TOP if not bubble_shot.z == Z_POSITION_TOP

                if bubble_shot.killed_by_poi then
                  bubble_shot.killed_by_poi = false

                  @life_gauge.change_life(-1 * bubble_shot.height * BUBBLE_SHOT_DAMAGE_UNIT_RATIO) if
                    not @mode == :game_over and not @mode == :game_clear
                  @poi.set_damage
                end
              end
            end
          end
        end
      end
    end

    if @splashs and not @splashs.empty? and not @mode == :start
      @splashs.each do |splash|
        if splash.mode == :finish then
          @splashs.delete(splash)
        else
          splash.update
        end
      end
    end

    @container.update if @container

    @poi.update if @poi

    @point_label.update if @point_label
    @point_label = nil if @point_label and @point_label.vanished?

    @combo_label.update if @combo_label
    @combo_label = nil if @combo_label and @combo_label.vanished?

    Sprite.check(@border.blocks + @swimmers + [@container]) if
      @border and @swimmers and not @swimmers.empty? and @container and not @mode == :start

    if @poi and @poi.mode == :transport then
      $vibeman.run if $vibeman

      @catch_objects.each do |catch_object|
        catch_object[0].set_pos(@poi.x + catch_object[1][0], @poi.y + catch_object[1][1])

        distance_in_poi = Math.sqrt((catch_object[1][0] + catch_object[0].center_x - @poi.center_x) ** 2 +
                                      (catch_object[1][0] + catch_object[0].center_y - @poi.center_y) ** 2)
        distance_damage_unit = 1 / distance_in_poi

        damage_unit_ratio = KINGYO_DAMAGE_UNIT_RATIO if catch_object[0].class == Kingyo
        damage_unit_ratio = WEED_DAMAGE_UNIT_RATIO if catch_object[0].class == Weed
        damage_unit_ratio = BOSS_DAMAGE_UNIT_RATIO if catch_object[0].class == Boss

        @life_gauge.change_life(-1 * catch_object[0].height * damage_unit_ratio * distance_damage_unit) if
          not @mode == :game_over and not @mode == :game_clear
      end
    elsif @poi and (@poi.mode == :reserve or @poi.mode == :broke) then
      catched_objects = []

      @catch_objects.each do |catch_object|
        if (catch_object[0].x + catch_object[0].center_x - (@container.x + (@container.width * 0.5))) ** 2 +
          ((catch_object[0].y + catch_object[0].center_y - (@container.y + (@container.height * 0.5))) ** 2) <=
          (@container.width * 0.5 * CONTAINER_CATCH_ADJUST_RANGE_RATIO) ** 2 then

          catch_object[0].z = Z_POSITION_UP
          catch_object[0].is_reserved = true
          catch_object[0].change_mode(:reserved)
          catched_objects.push(catch_object[0])
        else
          catch_object[0].change_mode(:broke)
        end
      end
      self.reserved(catched_objects)
      @catch_objects.clear
    end

    if @life_gauge.has_out_of_life and not @mode == :game_over and not @mode == :game_clear then
      if @poi_gauges.empty? then
        @life_gauge.change_gauge(0)
        self.change_mode(:game_over)
        @poi.set_break(true)
      else
        @poi_gauges[-1].vanish
        @poi_gauges.delete_at(-1)
        @poi.set_break(false)
      end
      @life_gauge.has_out_of_life = false
    end

    if @mode == :game_over or @mode == :game_clear then
      if @end_count > 240 then
        @end_count = 0
        self.will_disappear
        self.next_scene = ResultScene
      else
        @end_count += 1
      end
    end
  end

  def gazed(x, y, center_x, center_y)

    if @buttons and not @buttons.empty? then
      @buttons.each do |button|
        if x + center_x >= button.x and x + center_x <= button.x + button.width and
          y + center_y >= button.y and y + center_y <= button.y + button.height then

          if @is_returnable and (button.name == "return_message_ok_button" or
            button.name == "return_message_cancel_button") then
            button.is_gazed = true
          elsif not @is_returnable and
            not (button.name == "return_message_ok_button" or button.name == "return_message_cancel_button") then
            button.is_gazed = true
          end
        end
      end
    end

    if @poi and not @mode == :start and not @is_returnable then
      @catch_objects = []
      if @swimmers and not @swimmers.empty? then

        @swimmers.each do |swimmer|
          if not swimmer.z == Z_POSITION_BOTTOM and not swimmer.is_reserved and
            not (swimmer.class == Boss and @mode == :alert) then

            if (swimmer.x + swimmer.center_x - (x + center_x)) ** 2 +
              ((swimmer.y + swimmer.center_y - (y + center_y)) ** 2) <=
              (@poi.width * 0.5 * POI_CATCH_ADJUST_RANGE_RATIO) ** 2 then

              if not swimmer.class == Boss then
                swimmer.change_mode(:catched)
                @catch_objects.push([swimmer, [swimmer.x - x, swimmer.y - y]])
              else
                swimmer.hp -= 1
                if swimmer.hp > 0 then
                  swimmer.change_mode(:damaged)
                else
                  swimmer.change_mode(:died)
                  @catch_objects.push([swimmer, [swimmer.x - x, swimmer.y - y]])
                end
              end
            end
          end
        end
        unless @catch_objects.empty? then
          @poi.old_pos = [@poi.x, @poi.y]
          @poi.mode = :transport
        else
          @poi.mode = :search
        end
      end
    end
  end

  def reserved(catched_objects)

    if catched_objects and not catched_objects.empty? then

      point = 0
      technical_point_diff = 0

      catched_object_center_xs = []
      catched_object_center_ys = []

      catched_objects.each do |catched_object|

        catched_object_center_x = catched_object.x + catched_object.center_x
        catched_object_center_y = catched_object.y + catched_object.center_y

        distance_in_poi = Math.sqrt((catched_object_center_x - (@poi.x + @poi.center_x)) ** 2 +
                                      (catched_object_center_y - (@poi.y + @poi.center_y)) ** 2)
        technical_distance_in_poi = distance_in_poi / (@poi.width * 0.5)

        if catched_object.class == Kingyo then
          techinical_max_size = Window.height * KINGYO_SCALE_RANGES[@stage_number - 1][1]
          $scores[:catched_kingyo_number] += 1

        elsif catched_object.class == Boss then
          techinical_max_size = Window.height * BOSS_SCALE_RANGES[1]
          $scores[:catched_boss_number] += 1

          catched_object.is_shot = false

        elsif catched_object.class == Weed then
          techinical_max_size = Window.height * WEED_SCALE_RANGES[@stage_number - 1][1]
        else
        end
        technical_size = catched_object.height / techinical_max_size

        if catched_object.pre_mode == :wait then
          mode_point_unit = 1
        elsif catched_object.pre_mode == :move then
          mode_point_unit = 3
        elsif catched_object.pre_mode == :escape then
          mode_point_unit = 2
        else
          mode_point_unit = 0.5
        end
        mode_point = mode_point_unit / 3.to_f

        techinical_unit = technical_size + technical_distance_in_poi + mode_point
        point += BASE_SCORES[catched_object.name] * techinical_unit

        technical_point_diff += techinical_unit * 10
        technical_point_diff *= -1 if catched_object.class == Weed

        catched_object_center_xs.push(catched_object_center_x)
        catched_object_center_ys.push(catched_object_center_y)

        splash = Splash.new(10, 1)
        splash.run(catched_object_center_x - (splash.width * 0.5), catched_object_center_y - (splash.height * 0.5),
                   catched_object, catched_object.height * 2.0, 0.8)

        if catched_object.class == Boss then
          @splash_rarge_se.play
        else
          @splash_small_se.play
        end
        @splashs.push(splash)
      end

      combo = catched_objects.size
      point *= combo
      technical_point_diff += combo / @swimmers.size.to_f * 10

      $scores[:score] += point.round
      @score_label.string = "SCORE : #{$scores[:score]}点"

      original_points = [@container.x + @container.center_x, @container.y + @container.center_y]
      geometric_centers = calc_geometric_center(catched_object_center_xs, catched_object_center_ys)
      diff_vector = [geometric_centers[0] - original_points[0], geometric_centers[1] - original_points[1]]
      v_changes = [diff_vector[0] * POINT_LABEL_MOVE_SCALE, diff_vector[1] * POINT_LABEL_MOVE_SCALE]
      weight_ratio = 1 - (1 / (1 + (point.abs * 0.03)))

      point_color = C_RED if point >= 0
      point_color = C_BLUE if point < 0
      @point_label = SpriteFont.new(0, 0, "#{point.round}点", 128, point_color, C_DEFAULT,
                                    {:font_name=>"みかちゃん", :shadow=>true, :shadow_color=>[128, 128, 128, 128]})
      @point_label.alpha = 0
      @point_label.z = Z_POSITION_TOP
      @point_label.fade_move(geometric_centers, v_changes, weight_ratio, [0, 0, Window.width, Window.height])

      if combo > 1 then
        v_changes = v_changes.map { |v_change| v_change * -1 }
        weight_ratio = 1 - (1 / (1 + (combo * 0.8)))

        @combo_label = SpriteFont.new(0, 0, "#{combo}コンボ！", 164, C_PURPLE, C_DEFAULT,
                                      {:font_name=>"みかちゃん", :weight=>true,  :shadow=>true,
                                       :shadow_color=>[128, 128, 128, 128]})
        @combo_label.alpha = 0
        @combo_label.z = Z_POSITION_TOP
        @combo_label.fade_move(geometric_centers, v_changes, weight_ratio, [0, 0, Window.width, Window.height])
      end

      $scores[:technical_point] += technical_point_diff
      $scores[:technical_point] = BigDecimal($scores[:technical_point].to_s).round(2).to_f
      $scores[:max_combo] = combo if combo > $scores[:max_combo]

      @challenge_point += technical_point_diff

      boss_remaind_numbes = @swimmers.select { |obj| obj.name == "boss" and not obj.is_reserved }
      if @challenge_point >= CHALLENGE_POINT_UP_RANGE and not @mode == :alert and boss_remaind_numbes.empty? then
        self.change_mode(:alert)
        @challenge_point = 0
      end

      if @swimmers.select { |obj| not obj.is_reserved and not obj.class == Weed }.empty? then

        if @stage_number < MAX_STAGE_NUMBER then
          @stage_number += 1
          self.change_mode(:start)
        elsif not @mode == :game_clear
          self.change_mode(:game_clear)
        end
      end
    end
  end

  def render

    Window.draw(0, 0, @stone_tile_image) if @stone_tile_image
    Window.draw_ex(0, 0, @aquarium_back_image, :alpha=>180) if @aquarium_back_image

    @border.draw if @border and @mode == :start

    @shader_rt.draw(0, 0, @aquarium_back_image) if @shader_rt and @aquarium_back_image and @mode == :start
    Window.draw_shader(0, 0, @shader_rt, @wave_shader) if @shader_rt and @wave_shader and @mode == :start

    @container.draw if @container and not @mode == :start

    @poi.draw if @poi

    if @swimmers and not @swimmers.empty? and not @mode == :start then
      @swimmers.each do |swimmer|
        swimmer.draw if not (swimmer.class == Boss and not swimmer.is_reserved) or not @mode == :alert
      end
    end

    if @splashs and not @splashs.empty? and not @mode == :start
      @splashs.each do |splash|
        splash.draw
      end
    end

    @return_button.draw if @return_button
    @window_mode_button.draw if @window_mode_button

    @score_label.draw if @score_label and not @mode == :start
    @bgm_info.draw if @bgm_info and @bgm_info.mode == :run and not @mode == :start

    @life_gauge.draw unless @mode == :start

    unless @mode == :start then
      @poi_gauges.each do |poi_gauge|
        poi_gauge.draw
      end
    end

    @point_label.draw if @point_label
    @combo_label.draw if @combo_label

    @alert.draw if @alert and @alert.mode == :run and not @mode == :start

    Window.draw(0, 0, @cover_layer, Z_POSITION_TOP) if @cover_layer and
      ((@mode == :game_over or @mode == :game_clear) or @is_returnable)

    @stage_info_label.draw if @stage_info_label and (@mode == :start or @mode == :game_over or @mode == :game_clear)

    @return_message_dialog.draw if @return_message_dialog and @is_returnable
  end

  def will_disappear
    if @bgm then
      @bgm.stop
      @bgm = nil
      @main_bgm.free if @main_bgm
      @alert_bgm.free if @alert_bgm
      @boss_bgm.free if @boss_bgm
    end
  end
end


class ResultScene < Scene::Base

  require "./lib/common"
  require "./lib/dxruby/images"
  require "./lib/dxruby/color"

  require "./scripts/confetti"

  include Common
  include Color

  CLICK_SE = "./sounds/meka_ge_mouse_s02.wav"
  CONGRATULATIONS_SE = "./sounds/nc134713.wav"
  OK_BUTTON_IMAGE = "./images/m_4.png"
  RETURN_BUTTON_IMAGE = "./images/s_3.png"
  WINDOW_MODE_BUTTON_IMAGE = "./images/s_2.png"
  CANCEL_BUTTON_IMAGE = "./images/m_1.png"

  COMMENDATION_POINT = 800
  CONFETTI_MAX_NUMBER = 800

  MAX_COUNT_IN_WINDOW = 40
  MAX_COUNT_IN_GAZE_AREA = 30

  POI_WIDTH_SIZE_RATIO = 0.13
  MAX_GAZE_COUNT = 15
  POI_GAZE_RADIUS_RATIO = 0.8

  def init

    @click_se = Sound.new(CLICK_SE)
    @congratulations_se = Sound.new(CONGRATULATIONS_SE)

    @background = Image.new(Window.width, Window.height).box_fill(0, 0, Window.width, Window.height, C_MISTY_ROSE)

    $scores[:cognomen], $scores[:color] = "ウンコちゃん", C_BROWN if $scores[:technical_point] < COMMENDATION_POINT * 0.5
    $scores[:cognomen], $scores[:color] = "ザコりん", C_CYAN if
      $scores[:technical_point] >= COMMENDATION_POINT * 0.5 and $scores[:technical_point] < COMMENDATION_POINT * 0.6
    $scores[:cognomen], $scores[:color] = "初心者ペー", C_YELLOW if
      $scores[:technical_point] >= COMMENDATION_POINT * 0.6 and $scores[:technical_point] < COMMENDATION_POINT * 0.7
    $scores[:cognomen], $scores[:color] = "普通ヲタ", C_GREEN if
      $scores[:technical_point] >= COMMENDATION_POINT * 0.7 and $scores[:technical_point] < COMMENDATION_POINT * 0.8
    $scores[:cognomen], $scores[:color] = "良しヲくん", C_ORANGE if
      $scores[:technical_point] >= COMMENDATION_POINT * 0.8 and $scores[:technical_point] < COMMENDATION_POINT * 0.9
    $scores[:cognomen], $scores[:color] = "スーパーカブ", C_MAGENTA if
      $scores[:technical_point] >= COMMENDATION_POINT * 0.9 and $scores[:technical_point] < COMMENDATION_POINT * 1.0
    $scores[:cognomen], $scores[:color] = "レジェンドン", C_BLUE if
      $scores[:technical_point] >= COMMENDATION_POINT * 1.0 and $scores[:technical_point] < COMMENDATION_POINT * 1.1
    $scores[:cognomen], $scores[:color] = "金魚人", C_PURPLE if
      $scores[:technical_point] >= COMMENDATION_POINT * 1.1 and $scores[:technical_point] < COMMENDATION_POINT * 1.2
    $scores[:cognomen], $scores[:color] = "金魚神", C_RED if $scores[:technical_point] >= COMMENDATION_POINT * 1.2

    @titleLabel = Fonts.new(0, 0, "結果", Window.height * 0.1, C_PURPLE, {:font_name=>"チェックポイントフォント"})
    @titleLabel.set_pos((Window.width - @titleLabel.width) * 0.5, (Window.height - @titleLabel.height) * 0.03)

    @score_label = Fonts.new(0, 0, "SCORE : #{$scores[:score]}点",
                             Window.height * 0.05, C_GREEN, {:font_name=>"自由の翼フォント"})
    @score_label.set_pos((Window.width - @score_label.width) * 0.5, (Window.height - @score_label.height) * 0.18)

    @catched_kingyo_number_label = Fonts.new(0, 0, "金魚捕獲数 : #{$scores[:catched_kingyo_number]}匹",
                                             Window.height * 0.07, C_RED, {:font_name=>"自由の翼フォント"})
    @catched_kingyo_number_label.set_pos((Window.width - @catched_kingyo_number_label.width) * 0.5,
                                         (Window.height - @catched_kingyo_number_label.height) * 0.28)

    @catched_boss_number_label = Fonts.new(0, 0, "ボス捕獲数 : #{$scores[:catched_boss_number]}匹",
                                           Window.height * 0.07, C_RED, {:font_name=>"自由の翼フォント"})
    @catched_boss_number_label.set_pos((Window.width - @catched_boss_number_label.width) * 0.5,
                                       (Window.height - @catched_boss_number_label.height) * 0.38)

    @max_combo_label = Fonts.new(0, 0, "MAXコンボ : #{$scores[:max_combo]}",
                                 Window.height * 0.07, C_ORANGE, {:font_name=>"自由の翼フォント"})
    @max_combo_label.set_pos((Window.width - @max_combo_label.width) * 0.5,
                             (Window.height - @max_combo_label.height) * 0.48)

    @technical_point_label = Fonts.new(0, 0, "テクニカルポイント : #{$scores[:technical_point]}",
                                       Window.height * 0.05, C_DARK_BLUE, {:font_name=>"自由の翼フォント"})
    @technical_point_label.set_pos((Window.width - @technical_point_label.width) * 0.5,
                                   (Window.height - @technical_point_label.height) * 0.6)

    @cognomen_label = Fonts.new(0, 0, "称号 : #{$scores[:cognomen]}",
                                Window.height * 0.1, $scores[:color], {:font_name=>"たぬき油性マジック"})
    @cognomen_label.set_pos((Window.width - @cognomen_label.width) * 0.5,
                            (Window.height - @cognomen_label.height) * 0.75)
    @cognomen_label.set_weight = true

    ok_button_image = Image.load(OK_BUTTON_IMAGE)
    @ok_button = Button.new(Window.width * 0.4, Window.height * 0.85, Window.width * 0.2, Window.height * 0.1, "OK",
                            Window.height * 0.08, {:str_color=>C_DARK_BLUE, :font_name=>"07ラノベPOP"})
    @ok_button.set_image(Images.fit_resize(ok_button_image, Window.width * 0.2, Window.height * 0.1))

    return_button_image = Image.load(RETURN_BUTTON_IMAGE)
    return_button_scale = Window.width * 0.065 / return_button_image.width
    return_button_converted_image = Images.scale_resize(return_button_image, return_button_scale, return_button_scale)
    @return_button = Button.new
    @return_button.set_image(return_button_converted_image)
    @return_button.set_string("Return", return_button_converted_image.height * 0.6,
                              "07ラノベPOP", {:color=>C_DARK_BLUE})
    @return_button.set_pos(Window.width - @return_button.width, 0)

    window_mode_button_image = Image.load(WINDOW_MODE_BUTTON_IMAGE)
    window_mode_button_scale = Window.width * 0.065 / window_mode_button_image.width
    window_mode_button_converted_image = Images.scale_resize(window_mode_button_image,
                                                             window_mode_button_scale, window_mode_button_scale)
    @window_mode_button = Button.new
    @window_mode_button.set_image(window_mode_button_converted_image)
    @window_mode_button.set_string("Full/Win", window_mode_button_converted_image.height * 0.5,
                                   "07ラノベPOP", {:color=>C_DARK_BLUE})
    @window_mode_button.set_pos(Window.width - (@return_button.width + @window_mode_button.width), 0)

    return_message_dialog_width = Window.width * 0.5
    return_message_dialog_height = return_message_dialog_width * 0.5
    return_message_dialog_option = {:frame_thickness=>(return_message_dialog_width * 0.02).round,
                                    :radius=>return_message_dialog_width * 0.03,
                                    :bg_color=>C_CREAM, :frame_color=>C_CYAN}
    @return_message_dialog = MessageDialog.new(0, 0, return_message_dialog_width, return_message_dialog_height,
                                               1, return_message_dialog_option)
    @return_message_dialog.set_message("タイトルに戻りますか？", "",
                                       @return_message_dialog.height * 0.15, C_BROWN, "みかちゃん")
    @return_message_dialog.set_pos((Window.width - @return_message_dialog.width) * 0.5,
                                   (Window.height - @return_message_dialog.height) * 0.5)

    @return_message_dialog.ok_button.font_color = C_DARK_BLUE
    @return_message_dialog.ok_button.font_name = "07ラノベPOP"
    @return_message_dialog.ok_button.name = "return_message_ok_button"

    @return_message_dialog.cancel_button.font_color = C_DARK_BLUE
    @return_message_dialog.cancel_button.font_name = "07ラノベPOP"
    @return_message_dialog.cancel_button.name = "return_message_cancel_button"

    ok_button_image = Image.load(OK_BUTTON_IMAGE)
    @return_message_dialog.ok_button.set_image(
      Images.fit_resize(ok_button_image, @return_message_dialog.ok_button.width,
                        @return_message_dialog.ok_button.height))

    cancel_button_image = Image.load(CANCEL_BUTTON_IMAGE)
    @return_message_dialog.cancel_button.set_image(Images.fit_resize(
      cancel_button_image, @return_message_dialog.cancel_button.width, @return_message_dialog.cancel_button.height))

    @is_returnable = false

    @buttons = [@ok_button, @return_button, @window_mode_button,
                @return_message_dialog.ok_button, @return_message_dialog.cancel_button]

    if $scores[:technical_point] >= COMMENDATION_POINT then

      confetti_size_min = Window.width * 0.0169
      confetti_size_max = confetti_size_min * 3
      confetti_accel_min = 0.02
      confetti_accel_max = confetti_accel_min * 4
      confetti_amp_min = Window.width * 0.0028
      confetti_amp_max = confetti_amp_min * 2
      confetti_rot_speed_min = 0.5
      confetti_rot_speed_max = confetti_rot_speed_min * 15
      confetti_angular_velo_min = 0.5
      confetti_angular_velo_max = confetti_angular_velo_min * 10

      @confettis = []
      CONFETTI_MAX_NUMBER.times do
        confetti = Confetti.new(Window.height, [0, 0], [0, 0], [confetti_size_min, confetti_size_max],
                                [confetti_accel_min, confetti_accel_max], [confetti_amp_min, confetti_amp_max],
                                [confetti_rot_speed_min, confetti_rot_speed_max],
                                [confetti_angular_velo_min, confetti_angular_velo_max])
        confetti.set_x([-1 * confetti.width * Math.sqrt(2), Window.width + (confetti.width * Math.sqrt(2))])
        confetti.set_y([-1 * confetti.height * Math.sqrt(2), -1 * Window.height + confetti.height * Math.sqrt(2)])
        @confettis.push(confetti)
      end
      @congratulations_se.play
    end

    @cover_layer = Image.new(Window.width, Window.height).box_fill(0, 0,
                                                                   Window.width, Window.height, [164, 128, 128, 128])
    @mouse = Sprite.new
    @mouse.collision = [0, 0]

    @poi = Poi.new(0, 0, nil, Window.width * POI_WIDTH_SIZE_RATIO, @mouse,
                   MAX_GAZE_COUNT, self, nil, {:max_count_in_window=>MAX_COUNT_IN_WINDOW,
                                               :gaze_radius_ratio=>POI_GAZE_RADIUS_RATIO,
                                               :max_count_in_gaze_area=>MAX_COUNT_IN_GAZE_AREA})
    @poi.set_pos((Window.width - @poi.width) * 0.5, (Window.height - @poi.height) * 0.5)
  end

  def update

    if @confettis and not @confettis.empty? then
      @confettis.each do |confetti|
        confetti.update
      end
    end

    if @window_mode_button and not @is_returnable and (@window_mode_button.pushed? or @window_mode_button.is_gazed) then
      @window_mode_button.is_gazed = false
      if Window.windowed? then
        Window.windowed = false
      else
        Window.windowed = true
      end
      @click_se.play if @click_se
    end

    if (@return_button and not @is_returnable and
      (@return_button.pushed? or @return_button.is_gazed)) or Input.key_push?(K_ESCAPE) then
      @return_button.is_gazed = false

      @click_se.play if @click_se
      @is_returnable = true
    end

    if @ok_button and not @is_returnable and (@ok_button.pushed? or @ok_button.is_gazed) then
      @click_se.play if @click_se
      if $scores[:technical_point] >= COMMENDATION_POINT then
        self.next_scene = EndingScene
      else
        self.next_scene = NameEntryScene
      end
    end

    if @buttons and not @buttons.empty? then
      @buttons.each do |button|
        if @is_returnable and (button.name == "return_message_ok_button" or
          button.name == "return_message_cancel_button") then
          button.hovered?
        elsif not @is_returnable and
          not (button.name == "return_message_ok_button" or button.name == "return_message_cancel_button") then
          button.hovered?
        end
      end
    end

    if @return_message_dialog and @is_returnable and
      (@return_message_dialog.ok_button.pushed? or @return_message_dialog.ok_button.is_gazed) then
      @return_message_dialog.ok_button.is_gazed = false

      @click_se.play if @click_se
      self.next_scene = TitleScene
      @is_returnable = false
    end

    if @return_message_dialog and @is_returnable and
      (@return_message_dialog.cancel_button.pushed? or @return_message_dialog.cancel_button.is_gazed) then
      @return_message_dialog.cancel_button.is_gazed = false

      @click_se.play if @click_se
      @is_returnable = false
    end

    @mouse.x, @mouse.y = Input.mouse_pos_x, Input.mouse_pos_y if @mouse

    @poi.update if @poi
  end

  def gazed(x, y, center_x, center_y)

    if @buttons and not @buttons.empty? then
      @buttons.each do |button|
        if x + center_x >= button.x and x + center_x <= button.x + button.width and
          y + center_y >= button.y and y + center_y <= button.y + button.height then

          if @is_returnable and (button.name == "return_message_ok_button" or
            button.name == "return_message_cancel_button") then
            button.is_gazed = true
          elsif not @is_returnable and
            not (button.name == "return_message_ok_button" or button.name == "return_message_cancel_button") then
            button.is_gazed = true
          end
        end
      end
    end
    @poi.mode = :search
  end

  def render

    Window.draw(0, 0, @background) if @background

    if @confettis and not @confettis.empty? then
      @confettis.each do |confetti|
        confetti.draw
      end
    end

    @titleLabel.draw if @titleLabel
    @score_label.draw if @score_label
    @catched_kingyo_number_label.draw if @catched_kingyo_number_label
    @catched_boss_number_label.draw if @catched_boss_number_label
    @max_combo_label.draw if @max_combo_label
    @technical_point_label.draw if @technical_point_label
    @cognomen_label.draw if @cognomen_label

    @ok_button.draw if @ok_button
    @return_button.draw if @return_button
    @window_mode_button.draw if @window_mode_button

    Window.draw(0, 0, @cover_layer) if @cover_layer and @is_returnable
    @return_message_dialog.draw if @return_message_dialog and @is_returnable

    @poi.draw if @poi
  end

  def will_disappear

  end
end


class NameEntryScene < Scene::Base

  require "net/http"
  require "./lib/dxruby/images"
  require "./lib/dxruby/color"
  require "./lib/common"

  require "./scripts/name_entry"
  require "./scripts/message_dialog"
  require "./scripts/loading_anime"

  include Color
  include Common

  CLICK_SE = "./sounds/meka_ge_mouse_s02.wav"
  NAME_ENTRY_BGM = "./sounds/yuugure.mp3"

  NAME_ENTRY_BUTTON_IMAGE = "./images/942037.png"
  FLOOR_IMAGE = "./images/floor1.jpg"
  RESET_BUTTON_IMAGE = "./images/m_1.png"
  DECITION_BUTTON_IMAGE = "./images/m_2.png"
  DELETE_BUTTON_IMAGE = "./images/m_3.png"
  RETURN_BUTTON_IMAGE = "./images/s_3.png"
  WINDOW_MODE_BUTTON_IMAGE = "./images/s_2.png"
  OK_BUTTON_IMAGE = "./images/m_4.png"
  CANCEL_BUTTON_IMAGE = "./images/m_1.png"

  MAX_NAME_INPUT_NUMBER = 8
  HIRA_GANA_SIZE = [17, 5]

  MAX_COUNT_IN_WINDOW = 40
  MAX_COUNT_IN_GAZE_AREA = 30

  POI_WIDTH_SIZE_RATIO = 0.13
  MAX_GAZE_COUNT = 15
  POI_GAZE_RADIUS_RATIO = 0.8

  RETRY_MAX_COUNT = 2 # 回
  RETRY_WAIT_TIME = 3 # 秒
  REQUEST_TIMEOUT = 5 # 秒

  def init

    @click_se = Sound.new(CLICK_SE)
    @bgm = Bass.loadSample(NAME_ENTRY_BGM)

    floor_image = Image.load(FLOOR_IMAGE)
    floor_image_scale = Window.width * 0.2 / floor_image.width.to_f
    floor_src_image = Images.scale_resize(floor_image, floor_image_scale, floor_image_scale)
    floor_rt = RenderTarget.new(Window.width, Window.height)
    floor_rt.drawTile(0, 0, [[0]], [floor_src_image], nil, nil, nil, nil)
    @floor_image = floor_rt.to_image
    floor_src_image.dispose
    floor_rt.dispose

    @title_label = Fonts.new(0, 0, "名前の入力", Window.height * 0.05, C_ORANGE, {:font_name=>"07ラノベPOP"})
    @title_label.set_pos((Window.width - @title_label.width) * 0.5, (Window.height - @title_label.height) * 0.02)

    @score_label = Fonts.new(0, 0, "SCORE : #{$scores[:score]}点", Window.height * 0.05, C_GREEN,
                             {:font_name=>"自由の翼フォント"})

    @cognomen_label = Fonts.new(0, 0, "称号 : #{$scores[:cognomen]}",
                                Window.height * 0.05, $scores[:color], {:font_name=>"たぬき油性マジック"})
    @cognomen_label.set_weight = true

    interval_margin = Window.width * 0.03
    @score_label.set_pos((Window.width - (@score_label.width + @cognomen_label.width + interval_margin)) * 0.5,
                         (Window.height - @score_label.height) * 0.1)
    @cognomen_label.set_pos(@score_label.x + @score_label.width + interval_margin,
                            (Window.height - @cognomen_label.height) * 0.1)

    input_box_height = Window.height * 0.1
    @input_box = Images.new(0, 0, input_box_height * (MAX_NAME_INPUT_NUMBER - 1),
                            input_box_height, "", input_box_height * 0.85)
    @input_box.set_pos((Window.width - @input_box.width) * 0.5, (Window.height - @input_box.height) * 0.185)
    @input_box.set_string_pos((@input_box.width - (@input_box.font_size * MAX_NAME_INPUT_NUMBER)) * 0.5,
                              (@input_box.height - @input_box.font_size) * 0.5)

    @input_box.font_name = "AR教科書体M"
    @input_box.frame(C_BROWN, @input_box.width * 0.01)

    return_button_image = Image.load(RETURN_BUTTON_IMAGE)
    return_button_scale = Window.width * 0.065 / return_button_image.width
    return_button_converted_image = Images.scale_resize(return_button_image, return_button_scale, return_button_scale)
    @return_button = Button.new
    @return_button.set_image(return_button_converted_image)
    @return_button.set_string("Return", return_button_converted_image.height * 0.6,
                              "07ラノベPOP", {:color=>C_DARK_BLUE})
    @return_button.set_pos(Window.width - @return_button.width, 0)

    window_mode_button_image = Image.load(WINDOW_MODE_BUTTON_IMAGE)
    window_mode_button_scale = Window.width * 0.065 / window_mode_button_image.width
    window_mode_button_converted_image = Images.scale_resize(window_mode_button_image,
                                                             window_mode_button_scale, window_mode_button_scale)
    @window_mode_button = Button.new
    @window_mode_button.set_image(window_mode_button_converted_image)
    @window_mode_button.set_string("Full/Win", window_mode_button_converted_image.height * 0.5,
                                   "07ラノベPOP", {:color=>C_DARK_BLUE})
    @window_mode_button.set_pos(Window.width - (@return_button.width + @window_mode_button.width), 0)

    decision_button_image = Image.load(DECITION_BUTTON_IMAGE)
    @decision_button = Button.new(Window.width * 0.4, Window.height * 0.85, Window.width * 0.2, Window.height * 0.1,
                                  "決定", Window.height * 0.065, {:str_color=>C_DARK_BLUE, :font_name=>"07ラノベPOP"})
    @decision_button.set_image(Images.fit_resize(decision_button_image, Window.width * 0.2, Window.height * 0.1))

    reset_button_image = Image.load(RESET_BUTTON_IMAGE)
    @reset_button = Button.new(Window.width * 0.2, Window.height * 0.85, Window.width * 0.2, Window.height * 0.1,
                               "リセット", Window.height * 0.065, {:str_color=>C_DARK_BLUE, :font_name=>"07ラノベPOP"})
    @reset_button.set_image(Images.fit_resize(reset_button_image, Window.width * 0.2, Window.height * 0.1))

    delete_button_image = Image.load(DELETE_BUTTON_IMAGE)
    @delete_button = Button.new(Window.width * 0.6, Window.height * 0.85, Window.width * 0.2, Window.height * 0.1,
                                "一文字消す", Window.height * 0.065, {:str_color=>C_DARK_BLUE, :font_name=>"07ラノベPOP"})
    @delete_button.set_image(Images.fit_resize(delete_button_image, Window.width * 0.2, Window.height * 0.1))

    name_entry_pre_width = Window.width * 0.96
    name_entry_button_width = name_entry_pre_width / HIRA_GANA_SIZE[0]
    name_entry_button_height = name_entry_button_width
    name_entry_button_image = Image.load(NAME_ENTRY_BUTTON_IMAGE)
    name_entry_button_x_scale =  name_entry_button_width / name_entry_button_image.width
    name_entry_button_y_scale = name_entry_button_height / name_entry_button_image.height
    name_entry_button_coverted_image = Images.scale_resize(name_entry_button_image,
                                                           name_entry_button_x_scale, name_entry_button_y_scale)
    name_entry_buttons_font_size = name_entry_button_height * 0.8

    @name_entry = NameEntry.new(0, 0, name_entry_button_width, name_entry_button_height, name_entry_buttons_font_size,
                               C_BROWN, C_WHITE, {:font_name=>"みかちゃん"})
    @name_entry.set_pos((Window.width - @name_entry.width) * 0.5 - HIRA_GANA_SIZE[0] * 0.5,
                        (Window.height - @name_entry.height) * 0.6 - HIRA_GANA_SIZE[1] * 0.5)
    @name_entry.set_image(name_entry_button_coverted_image)

    @input_box.string = $scores[:name]

    @mouse = Sprite.new
    @mouse.collision = [0, 0]

    @poi = Poi.new(0, 0, nil, Window.width * POI_WIDTH_SIZE_RATIO, @mouse,
                   MAX_GAZE_COUNT, self, nil, {:max_count_in_window=>MAX_COUNT_IN_WINDOW,
                                               :gaze_radius_ratio=>POI_GAZE_RADIUS_RATIO,
                                               :max_count_in_gaze_area=>MAX_COUNT_IN_GAZE_AREA})
    @poi.set_pos((Window.width - @poi.width) * 0.5, (Window.height - @poi.height) * 0.5)

    @bgm.play(:loop=>true, :volume=>0.5)

    @cover_layer = Image.new(Window.width, Window.height).box_fill(0, 0,
                                                                   Window.width, Window.height, [164, 128, 128, 128])

    @is_connect_error = false
    @loading_kingyo = LoadingAnime.new(0, 0, nil, Window.width * 0.2)
    @loading_kingyo.set_pos(0, Window.height - @loading_kingyo.height)

    connect_error_message_dialog_width = Window.width * 0.5
    connect_error_message_dialog_height = connect_error_message_dialog_width * 0.5
    connect_error_message_dialog_option = {:frame_thickness=>(connect_error_message_dialog_width * 0.02).round,
                                           :radius=>connect_error_message_dialog_width * 0.03,
                             :bg_color=>C_CREAM, :frame_color=>C_YELLOW}
    @connect_error_message_dialog = MessageDialog.new(0, 0, connect_error_message_dialog_width,
                                                      connect_error_message_dialog_height,
                                                      0, connect_error_message_dialog_option)
    @connect_error_message_dialog.set_message("通信エラー…", "タイトルに戻ります。",
                                              @connect_error_message_dialog.height * 0.25, C_RED, "みかちゃん")
    @connect_error_message_dialog.set_pos((Window.width - @connect_error_message_dialog.width) * 0.5,
                                          (Window.height - @connect_error_message_dialog.height) * 0.5)

    @connect_error_message_dialog.ok_button.font_color = C_DARK_BLUE
    @connect_error_message_dialog.ok_button.font_name = "07ラノベPOP"
    @connect_error_message_dialog.ok_button.name = "connect_error_message_ok_button"

    ok_button_image = Image.load(OK_BUTTON_IMAGE)
    @connect_error_message_dialog.ok_button.set_image(Images.fit_resize(ok_button_image,
                                                                        @connect_error_message_dialog.ok_button.width,
                                                                        @connect_error_message_dialog.ok_button.height))

    return_message_dialog_width = Window.width * 0.5
    return_message_dialog_height = return_message_dialog_width * 0.5
    return_message_dialog_option = {:frame_thickness=>(return_message_dialog_width * 0.02).round,
                             :radius=>return_message_dialog_width * 0.03,
                             :bg_color=>C_CREAM, :frame_color=>C_CYAN}
    @return_message_dialog = MessageDialog.new(0, 0, return_message_dialog_width, return_message_dialog_height,
                                        1, return_message_dialog_option)
    @return_message_dialog.set_message("タイトルに戻りますか？", "",
                                @return_message_dialog.height * 0.15, C_BROWN, "みかちゃん")
    @return_message_dialog.set_pos((Window.width - @return_message_dialog.width) * 0.5,
                            (Window.height - @return_message_dialog.height) * 0.5)

    @return_message_dialog.ok_button.font_color = C_DARK_BLUE
    @return_message_dialog.ok_button.font_name = "07ラノベPOP"
    @return_message_dialog.ok_button.name = "return_message_ok_button"

    @return_message_dialog.cancel_button.font_color = C_DARK_BLUE
    @return_message_dialog.cancel_button.font_name = "07ラノベPOP"
    @return_message_dialog.cancel_button.name = "return_message_cancel_button"

    ok_button_image = Image.load(OK_BUTTON_IMAGE)
    @return_message_dialog.ok_button.set_image(
      Images.fit_resize(ok_button_image, @return_message_dialog.ok_button.width,
                        @return_message_dialog.ok_button.height))

    cancel_button_image = Image.load(CANCEL_BUTTON_IMAGE)
    @return_message_dialog.cancel_button.set_image(Images.fit_resize(
      cancel_button_image, @return_message_dialog.cancel_button.width, @return_message_dialog.cancel_button.height))

    @is_returnable = false

    @buttons = [@window_mode_button, @return_button, @decision_button,
                @reset_button, @delete_button, @connect_error_message_dialog.ok_button,
                @return_message_dialog.ok_button, @return_message_dialog.cancel_button]
  end

  def update

    if @window_mode_button and not @is_connect_error and not @loading_kingyo.is_anime and not @is_returnable and
      (@window_mode_button.pushed? or @window_mode_button.is_gazed) then
      @window_mode_button.is_gazed = false
      if Window.windowed? then
        Window.windowed = false
      else
        Window.windowed = true
      end
      @click_se.play if @click_se
    end

    if (@return_button and not @is_connect_error and not @loading_kingyo.is_anime and not @is_returnable and
      (@return_button.pushed? or @return_button.is_gazed)) or Input.key_push?(K_ESCAPE) then
      @return_button.is_gazed = false

      @click_se.play if @click_se
      @is_returnable = true
    end

    if @name_entry and not @is_connect_error and not @loading_kingyo.is_anime and not @is_returnable then
      @name_entry.word_buttons.each do |word_button|
        if word_button.pushed? or word_button.is_gazed then
          word_button.is_gazed = false
          @click_se.play if @click_se
          if $scores[:name].size < MAX_NAME_INPUT_NUMBER * 2 then
            $scores[:name] += word_button.string
            @input_box.string = $scores[:name]
          end
        end
        word_button.hovered?
      end
    end

    if @decision_button and not @is_connect_error and not @loading_kingyo.is_anime and not @is_returnable and
      (@decision_button.pushed? or @decision_button.is_gazed) then
      @decision_button.is_gazed = false
      @click_se.play if @click_se

      Thread.new do
        @loading_kingyo.is_anime = true

        retry_count = 0
        begin
          self.send_to_database
          @loading_kingyo.is_anime = false
          self.next_scene = RankingScene
          self.will_disappear
        rescue
          if retry_count < RETRY_MAX_COUNT
            sleep RETRY_WAIT_TIME
            retry_count += 1
            retry
          else
            @is_connect_error = true
            @loading_kingyo.is_anime = false
            self.will_disappear
            false
          end
        end
      end
    end

    if @reset_button and not @is_connect_error and not @loading_kingyo.is_anime and not @is_returnable and
      (@reset_button.pushed? or @reset_button.is_gazed) then
      @reset_button.is_gazed = false
      @click_se.play if @click_se
      $scores[:name] = ""
      @input_box.string = $scores[:name]
    end

    if @delete_button and not @is_connect_error and not @loading_kingyo.is_anime and not @is_returnable and
      (@delete_button.pushed? or @delete_button.is_gazed) then
      @delete_button.is_gazed = false
      @click_se.play if @click_se
      if $scores[:name].size > 0 then
        $scores[:name].chop!
        @input_box.string = $scores[:name]
      end
    end

    if @buttons and not @buttons.empty? then
      @buttons.each do |button|
        if @is_connect_error or @loading_kingyo.is_anime or @is_returnable and
          (button.name == "connect_error_message_ok_button" or button.name == "return_message_ok_button" or
            button.name == "return_message_cancel_button") then
          button.hovered?
        elsif not @is_connect_error and not @loading_kingyo.is_anime and not @is_returnable and
          not (button.name == "connect_error_message_ok_button" or button.name == "return_message_ok_button" or
            button.name == "return_message_cancel_button") then
          button.hovered?
        end
      end
    end

    if @connect_error_message_dialog and @is_connect_error and (@connect_error_message_dialog.ok_button.pushed? or
      @connect_error_message_dialog.ok_button.is_gazed) then
      @connect_error_message_dialog.ok_button.is_gazed = false
      @click_se.play if @click_se
      self.next_scene = TitleScene
    end

    if @return_message_dialog and @is_returnable and
      (@return_message_dialog.ok_button.pushed? or @return_message_dialog.ok_button.is_gazed) then
      @return_message_dialog.ok_button.is_gazed = false

      @click_se.play if @click_se
      @bgm.stop
      @bgm = nil
      self.next_scene = TitleScene
      @is_returnable = false
    end

    if @return_message_dialog and @is_returnable and
      (@return_message_dialog.cancel_button.pushed? or @return_message_dialog.cancel_button.is_gazed) then
      @return_message_dialog.cancel_button.is_gazed = false

      @click_se.play if @click_se
      @is_returnable = false
    end

    @mouse.x, @mouse.y = Input.mouse_pos_x, Input.mouse_pos_y

    @poi.update if @poi

    @loading_kingyo.update if @loading_kingyo.is_anime
  end

  def gazed(x, y, center_x, center_y)

    if @buttons and not @buttons.empty? then
      @buttons.each do |button|
        if button and x + center_x >= button.x and x + center_x <= button.x + button.width and
          y + center_y >= button.y and y + center_y <= button.y + button.height then

          if @is_connect_error or @loading_kingyo.is_anime or @is_returnable and
            (button.name == "connect_error_message_ok_button" or button.name == "return_message_ok_button" or
              button.name == "return_message_cancel_button") then
            button.is_gazed = true
          elsif not @is_connect_error and not @loading_kingyo.is_anime and not @is_returnable and
            not (button.name == "connect_error_message_ok_button" or button.name == "return_message_ok_button" or
              button.name == "return_message_cancel_button") then
            button.is_gazed = true
          end
        end
      end
    end

    if @name_entry and not @is_connect_error and not @loading_kingyo.is_anime and not @is_returnable then
      @name_entry.word_buttons.each do |word_button|
        if x + center_x >= word_button.x and x + center_x <= word_button.x + word_button.width and
          y + center_y >= word_button.y and y + center_y <= word_button.y + word_button.height then
          word_button.is_gazed = true
        end
      end
    end

    @poi.mode = :search
  end

  def send_to_database

    uri = URI.parse($config.post_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = REQUEST_TIMEOUT

    req = Net::HTTP::Post.new(uri.path)
    req.set_form_data({:name=>$scores[:name].encode("UTF-8"), :score=>$scores[:score],
                       :cognomen=>$scores[:cognomen].encode("UTF-8")})

    http.request(req)
  end

  def render

    Window.draw(0, 0, @floor_image) if @floor_image

    @title_label.draw if @title_label
    @score_label.draw if @score_label
    @cognomen_label.draw if @cognomen_label

    @return_button.draw if @return_button
    @window_mode_button.draw if @window_mode_button
    @name_entry.draw if @name_entry
    @input_box.draw if @input_box

    @decision_button.draw if @decision_button
    @reset_button.draw if @reset_button
    @delete_button.draw if @delete_button

    @loading_kingyo.draw if @loading_kingyo.is_anime

    Window.draw(0, 0, @cover_layer) if @cover_layer and (@is_connect_error or @is_returnable)

    @return_message_dialog.draw if @return_message_dialog and @is_returnable
    @connect_error_message_dialog.draw if @connect_error_message_dialog and @is_connect_error

    @poi.draw if @poi
  end

  def will_disappear
    if @bgm then
      @bgm.stop
      @bgm = nil
    end
  end
end


class RankingScene < Scene::Base

  require "rubygems"
  require "json" # gem install json -v 1.8.6

  require "net/http"
  require "time"

  require "./lib/common"
  require "./lib/encode" # 文字コード変換
  require "./lib/dxruby/color"
  require "./lib/dxruby/images"

  require "./scripts/message_dialog"
  require "./scripts/loading_anime"

  require "./scripts/score_list_box"
  require "./scripts/bubble"

  include Common
  include Color

  CLICK_SE = "./sounds/meka_ge_mouse_s02.wav"
  PAGE_UP_BUTTON = "./images/1396945_up.png"
  PAGE_DOWN_BUTTON = "./images/1396945_down.png"
  WINDOW_MODE_BUTTON_IMAGE = "./images/s_2.png"
  OK_BUTTON_IMAGE = "./images/m_4.png"
  RETURN_BUTTON_IMAGE = "./images/m_1.png"

  MAX_COUNT_IN_WINDOW = 40
  MAX_COUNT_IN_GAZE_AREA = 30

  POI_WIDTH_SIZE_RATIO = 0.13
  MAX_GAZE_COUNT = 15
  POI_GAZE_RADIUS_RATIO = 0.8

  RETRY_MAX_COUNT = 2 # 回
  RETRY_WAIT_TIME = 3 # 秒

  SCROLL_SPEED_RATIO = 0.015

  def init

    @background = Image.new(Window.width, Window.height).box_fill(0, 0, Window.width, Window.height, C_AQUA_MARINE)

    @title_label = Fonts.new(0, 0, "ランキング TOP100", Window.height * 0.07, C_DARK_BLUE,
                             {:font_name=>"チェックポイントフォント"})
    @title_label.set_pos((Window.width - @title_label.width) * 0.5, (Window.height - @title_label.height) * 0.04)

    window_mode_button_image = Image.load(WINDOW_MODE_BUTTON_IMAGE)
    window_mode_button_scale = Window.width * 0.065 / window_mode_button_image.width
    window_mode_button_converted_image = Images.scale_resize(window_mode_button_image,
                                                             window_mode_button_scale, window_mode_button_scale)
    @window_mode_button = Button.new
    @window_mode_button.set_image(window_mode_button_converted_image)
    @window_mode_button.set_string("Full/Win", window_mode_button_converted_image.height * 0.5,
                                   "07ラノベPOP", {:color=>C_DARK_BLUE})
    @window_mode_button.set_pos(Window.width - @window_mode_button.width, 0)

    return_button_image = Image.load(RETURN_BUTTON_IMAGE)
    @return_button = Button.new(Window.width * 0.4, Window.height * 0.85, Window.width * 0.2,
                                Window.height * 0.1, "タイトルに戻る",
                                Window.height * 0.045, {:str_color=>C_DARK_BLUE, :font_name=>"07ラノベPOP"})
    @return_button.set_image(Images.fit_resize(return_button_image, Window.width * 0.2, Window.height * 0.1))

    page_up_button_image = Image.load(PAGE_UP_BUTTON)
    page_up_button_scale = Window.width * 0.07 / page_up_button_image.width
    page_up_button_converted_image = Images.scale_resize(page_up_button_image,
                                                         page_up_button_scale, page_up_button_scale)
    @page_up_button = Button.new
    @page_up_button.set_image(page_up_button_converted_image)
    @page_up_button.set_pos((Window.width - @page_up_button.width) * 0.953,
                            (Window.height - @page_up_button.height) * 0.35)

    page_down_button_image = Image.load(PAGE_DOWN_BUTTON)
    page_down_button_scale = Window.width * 0.07 / page_down_button_image.width
    page_down_button_converted_image = Images.scale_resize(page_down_button_image,
                                                           page_down_button_scale, page_down_button_scale)
    @page_down_button = Button.new()
    @page_down_button.set_image(page_down_button_converted_image)
    @page_down_button.set_pos((Window.width - @page_down_button.width) * 0.95,
                              (Window.height - @page_down_button.height) * 0.65)

    @buttons = [@window_mode_button, @return_button, @page_up_button, @page_down_button]

    @click_se = Sound.new(CLICK_SE)

    bubble_scale_up_speed_min = 1
    bubble_scale_up_speed_max = bubble_scale_up_speed_min * 1.004
    bubble_accel_min = 0.005
    bubble_accel_max = bubble_accel_min * 10
    bubble_amplification_speed_min = 1
    bubble_amplification_speed_max = bubble_amplification_speed_min * 10
    bubble_angular_velo_up_speed_min = 1
    bubble_angular_velo_up_speed_max = bubble_angular_velo_up_speed_min * 10

    @bubbles = []
    800.times do
      bubble = Bubble.new(-1 * Window.height * 0.5, [0, 0], [0, 0],
                          [bubble_scale_up_speed_min, bubble_scale_up_speed_max],
                          [bubble_accel_min, bubble_accel_max],
                          [bubble_amplification_speed_min, bubble_amplification_speed_max],
                          [bubble_angular_velo_up_speed_min, bubble_angular_velo_up_speed_max])
      bubble.set_x([-1 * bubble.width * Math.sqrt(2), Window.width + (bubble.width * Math.sqrt(2))])
      bubble.set_y([Window.height + bubble.height, Window.height * 1.1])
      @bubbles.push(bubble)
    end

    @mouse = Sprite.new
    @mouse.collision = [0, 0]

    @poi = Poi.new(0, 0, nil, Window.width * POI_WIDTH_SIZE_RATIO, @mouse,
                   MAX_GAZE_COUNT, self, nil, {:max_count_in_window=>MAX_COUNT_IN_WINDOW,
                                               :gaze_radius_ratio=>POI_GAZE_RADIUS_RATIO,
                                               :max_count_in_gaze_area=>MAX_COUNT_IN_GAZE_AREA})
    @poi.set_pos((Window.width - @poi.width) * 0.5, (Window.height - @poi.height) * 0.5)

    @cover_layer = Image.new(Window.width, Window.height).box_fill(0, 0,
                                                                   Window.width, Window.height, [164, 128, 128, 128])

    @is_connect_error = false
    @loading_kingyo = LoadingAnime.new(0, 0, nil, Window.width * 0.2)
    @loading_kingyo.set_pos(0, Window.height - @loading_kingyo.height)

    message_dialog_width = Window.width * 0.5
    message_dialog_height = message_dialog_width * 0.5
    message_dialog_option = {:frame_thickness=>(message_dialog_width * 0.02).round,
                             :radius=>message_dialog_width * 0.03,
                             :bg_color=>C_CREAM, :frame_color=>C_YELLOW}
    @message_dialog = MessageDialog.new(0, 0, message_dialog_width, message_dialog_height,
                                        0, message_dialog_option)
    @message_dialog.set_message("通信エラー…", "タイトルに戻ります。",
                                @message_dialog.height * 0.25, C_RED, "みかちゃん")
    @message_dialog.set_pos((Window.width - @message_dialog.width) * 0.5,
                            (Window.height - @message_dialog.height) * 0.5)

    @message_dialog.ok_button.font_color = C_DARK_BLUE
    @message_dialog.ok_button.font_name = "07ラノベPOP"
    @message_dialog.ok_button.name = "message_ok_button"

    ok_button_image = Image.load(OK_BUTTON_IMAGE)
    @message_dialog.ok_button.
      set_image(Images.fit_resize(ok_button_image, @message_dialog.ok_button.width, @message_dialog.ok_button.height))

    @buttons.push(@message_dialog.ok_button)

    Thread.new do
      @loading_kingyo.is_anime = true

      retry_count = 0
      begin
        results = self.load_from_database

        items = []
        colors = []

        results.each_with_index do |result, index|

          result.unshift("#{index + 1}位")
          result[2] += "点"
          items.push(result)

          color = C_BROWN if result[3] == "ウンコちゃん"
          color = C_CYAN if result[3] == "ザコりん"
          color = C_YELLOW if result[3] == "初心者ペー"
          color = C_GREEN if result[3] == "普通ヲタ"
          color = C_ORANGE if result[3] == "良しヲくん"
          color = C_MAGENTA if result[3] == "スーパーカブ"
          color = C_BLUE if result[3] == "レジェンドン"
          color = C_PURPLE if result[3] == "金魚人"
          color = C_RED if result[3] == "金魚神"
          colors.push(color)
        end

        self.make_list_box(items, colors)
        @loading_kingyo.is_anime = false
      rescue => e
        p e
        if retry_count < RETRY_MAX_COUNT
          sleep RETRY_WAIT_TIME
          retry_count += 1
          retry
        else
          @is_connect_error = true
          @loading_kingyo.is_anime = false
          false
        end
      end
    end
  end

  def load_from_database

    uri = URI.parse($config.get_url)

    # 第2引数にHashを指定することでPOSTする際のデータを指定出来る
    response = Net::HTTP.post_form(uri, {})

    jsons = JSON.parse(response.body)

    raws = []
    results = []

    for json in jsons do
      raws << json["name"].to_s.encode("Shift_JIS")
      raws << json["score"].to_s
      raws << json["cognomen"].to_s.encode("Shift_JIS")
      raws << Time.parse(json["created_at"]).strftime("%Y年%m月%d日 %H時%M分%S秒")
      results << raws
      raws = []
    end

    return results
  end

  def make_list_box(items, colors)
    @list_box = ScoreListBox.new(0, 0, Window.width * 0.74, Window.height * 0.68,
                                 Window.height * SCROLL_SPEED_RATIO)
    @list_box.set_pos((Window.width - @list_box.width) * 0.5, (Window.height - @list_box.height) * 0.42)
    @list_box.set_items(items, [2, 5, 4, 3, 5], C_ROYAL_BLUE,
                        colors, 3, "みかちゃん")
  end

  def update

    if @window_mode_button and not @is_connect_error and not @loading_kingyo.is_anime  and
      (@window_mode_button.pushed? or @window_mode_button.is_gazed) then

      @window_mode_button.is_gazed = false
      if Window.windowed? then
        Window.windowed = false
      else
        Window.windowed = true
      end
      @click_se.play if @click_se
    end

    if @return_button and not @is_connect_error and not @loading_kingyo.is_anime and
      (@return_button.pushed? or @return_button.is_gazed) then

      @return_button.is_gazed = false
      @click_se.play
      self.next_scene = TitleScene
    end

    if @page_up_button and not @is_connect_error and not @loading_kingyo.is_anime and
      (@page_up_button.pushed? or @page_up_button.is_gazed) then

      @page_up_button.is_gazed = false
      @click_se.play
      @list_box.scroll_up
    end

    if @page_down_button and not @is_connect_error and not @loading_kingyo.is_anime and
      (@page_down_button.pushed? or @page_down_button.is_gazed) then

      @page_down_button.is_gazed = false
      @click_se.play
      @list_box.scroll_down
    end


    if @buttons and not @buttons.empty? then
      @buttons.each do |button|
        if @is_connect_error or @loading_kingyo.is_anime and button.name == "message_ok_button" then
          button.hovered?
        elsif not @is_connect_error and not @loading_kingyo.is_anime and not button.name == "message_ok_button" then
          button.hovered?
        end
      end
    end

    if @message_dialog and @is_connect_error and
      (@message_dialog.ok_button.pushed? or @message_dialog.ok_button.is_gazed) then
      @message_dialog.ok_button.is_gazed = false

      @click_se.play if @click_se
      self.next_scene = TitleScene
    end

    @mouse.x, @mouse.y = Input.mouse_pos_x, Input.mouse_pos_y

    @poi.update if @poi

    @loading_kingyo.update if @loading_kingyo.is_anime

    @list_box.update if @list_box

    @bubbles.each do |bubble|
      bubble.update
    end
  end

  def gazed(x, y, center_x, center_y)

    if @buttons and not @buttons.empty? then
      @buttons.each do |button|

        if button and x + center_x >= button.x and x + center_x <= button.x + button.width and
          y + center_y >= button.y and y + center_y <= button.y + button.height then

          if @is_connect_error or @loading_kingyo.is_anime and button.name == "message_ok_button" then
            button.is_gazed = true
          elsif not @is_connect_error and not @loading_kingyo.is_anime and not button.name == "message_ok_button" then
            button.is_gazed = true
          end
        end
      end
    end
    @poi.mode = :search
  end

  def render

    Window.draw(0, 0, @background) if @background

    if @bubbles and not @bubbles.empty? then
      @bubbles.each do |bubble|
        bubble.draw
      end
    end

    @list_box.draw if @list_box

    @title_label.draw if @title_label
    @window_mode_button.draw if @window_mode_button
    @return_button.draw if @return_button

    @page_up_button.draw if @page_up_button
    @page_down_button.draw if @page_down_button

    @loading_kingyo.draw if @loading_kingyo.is_anime

    Window.draw(0, 0, @cover_layer) if @cover_layer and @is_connect_error
    @message_dialog.draw if @message_dialog and @is_connect_error

    @poi.draw if @poi
  end

  def will_disappear

  end
end


class EndingScene < Scene::Base

  require "./lib/common"
  require "./lib/files"
  require "./lib/dxruby/images"
  require "./lib/dxruby/color"

  require "./scripts/sprite_font"
  require "./scripts/illust"

  include Common
  include Files
  include Color

  BACKGROUND_IMAGE = "./images/BG00a1_80a.jpg"
  STAFF_DATA_FILE = "./data/staff.csv"
  ENDING_BGM = "./sounds/itsuka_miagete_ta_tooi_sora.mp3"
  CLICK_SE = "./sounds/meka_ge_mouse_s02.wav"

  RETURN_BUTTON_IMAGE = "./images/s_3.png"
  WINDOW_MODE_BUTTON_IMAGE = "./images/s_2.png"

  OK_BUTTON_IMAGE = "./images/m_4.png"
  CANCEL_BUTTON_IMAGE = "./images/m_1.png"

  BASE_FONT_SIZE_RATIO = 0.04
  FONT_SHADOW_OFF_SET_X = 3
  FONT_SHADOW_OFF_SET_Y = 3
  BASE_Y_INTERVAL = 100

  BGM_TIME = 89
  MAX_NEXT_SCENE_WAIT_COUNT = 240
  ILLUST_RELATIVE_SCALES = [0.12, 0.09, 0.12, 0.16, 0.25, 0.14]
  ILLUST_MAX_NUMBER = 15
  NUMBER_OF_ILLUST = 6

  MAX_COUNT_IN_WINDOW = 40
  MAX_COUNT_IN_GAZE_AREA = 30

  POI_WIDTH_SIZE_RATIO = 0.13
  MAX_GAZE_COUNT = 15
  POI_GAZE_RADIUS_RATIO = 0.8

  POI_CATCH_ADJUST_RANGE_RATIO = 1.0

  def init

    @click_se = Sound.new(CLICK_SE)

    staff_datas = csvReadArray(STAFF_DATA_FILE)

    @sprite_fonts = []
    sum_interval = 0

    staff_datas.each do |staff_data|
      sprite_font = SpriteFont.new(0, 0, staff_data[0], Window.width * BASE_FONT_SIZE_RATIO * staff_data[1].to_f,
                                   hex_to_rgb(staff_data[2].hex).values, C_DEFAULT,
                                   {:font_name=>staff_data[3], :shadow=>true, :shadow_color=>C_SHADOW,
                                    :shadow_x=>FONT_SHADOW_OFF_SET_X, :shadow_y=>FONT_SHADOW_OFF_SET_Y})
      sum_interval += BASE_Y_INTERVAL * staff_data[4].to_f
      sprite_font.set_pos((Window.width - sprite_font.width) * 0.5, Window.height + sum_interval)
      @sprite_fonts.push(sprite_font)
    end

    max_scroll_range = @sprite_fonts[-1].y + (Window.height + @sprite_fonts[-1].height) * 0.6
    @scroll_speed = max_scroll_range / BGM_TIME / 60

    background_image = Image.load(BACKGROUND_IMAGE)
    @background_image = Images.fit_resize(background_image, Window.width, Window.height)

    @mouse = Sprite.new
    @mouse.collision = [0, 0]

    @poi = Poi.new(0, 0, nil, Window.width * POI_WIDTH_SIZE_RATIO, @mouse,
                   MAX_GAZE_COUNT, self, nil, {:max_count_in_window=>MAX_COUNT_IN_WINDOW,
                                               :gaze_radius_ratio=>POI_GAZE_RADIUS_RATIO,
                                               :max_count_in_gaze_area=>MAX_COUNT_IN_GAZE_AREA})
    @poi.set_pos((Window.width - @poi.width) * 0.5, (Window.height - @poi.height) * 0.5)

    @illusts = []
    ILLUST_MAX_NUMBER.times do
      illust_number = rand(NUMBER_OF_ILLUST)
      relative_size = Window.width * ILLUST_RELATIVE_SCALES[illust_number]
      illust = Illust.new(illust_number, relative_size, [0, 0, Window.width, Window.height], @poi)
      @illusts.push(illust)
    end

    return_button_image = Image.load(RETURN_BUTTON_IMAGE)
    return_button_scale = Window.width * 0.065 / return_button_image.width
    return_button_converted_image = Images.scale_resize(return_button_image, return_button_scale, return_button_scale)

    @return_button = Button.new
    @return_button.set_image(return_button_converted_image)
    @return_button.set_string("Return", return_button_converted_image.height * 0.6,
                            "07ラノベPOP", {:color=>C_DARK_BLUE})
    @return_button.set_pos(Window.width - @return_button.width, 0)

    window_mode_button_image = Image.load(WINDOW_MODE_BUTTON_IMAGE)
    window_mode_button_scale = Window.width * 0.065 / window_mode_button_image.width
    window_mode_button_converted_image = Images.scale_resize(window_mode_button_image, window_mode_button_scale,
                                                             window_mode_button_scale)
    @window_mode_button = Button.new
    @window_mode_button.set_image(window_mode_button_converted_image)
    @window_mode_button.set_string("Full/Win", window_mode_button_converted_image.height * 0.5,
                                   "07ラノベPOP", {:color=>C_DARK_BLUE})
    @window_mode_button.set_pos(Window.width - (@return_button.width + @window_mode_button.width), 0)

    @cover_layer = Image.new(Window.width, Window.height).box_fill(
      0, 0, Window.width, Window.height, [164, 128, 128, 128])

    message_dialog_width = Window.width * 0.5
    message_dialog_height = message_dialog_width * 0.5
    message_dialog_option = {:frame_thickness=>(message_dialog_width * 0.02).round,
                             :radius=>message_dialog_width * 0.03,
                             :bg_color=>C_CREAM, :frame_color=>C_CYAN}
    @message_dialog = MessageDialog.new(0, 0, message_dialog_width, message_dialog_height,
                                        1, message_dialog_option)
    @message_dialog.set_message("タイトルに戻りますか？", "",
                                @message_dialog.height * 0.15, C_BROWN, "みかちゃん")
    @message_dialog.set_pos((Window.width - @message_dialog.width) * 0.5,
                            (Window.height - @message_dialog.height) * 0.5)

    @message_dialog.ok_button.font_color = C_DARK_BLUE
    @message_dialog.ok_button.font_name = "07ラノベPOP"
    @message_dialog.ok_button.name = "message_ok_button"

    @message_dialog.cancel_button.font_color = C_DARK_BLUE
    @message_dialog.cancel_button.font_name = "07ラノベPOP"
    @message_dialog.cancel_button.name = "message_cancel_button"

    ok_button_image = Image.load(OK_BUTTON_IMAGE)
    @message_dialog.ok_button.set_image(
      Images.fit_resize(ok_button_image, @message_dialog.ok_button.width, @message_dialog.ok_button.height))

    cancel_button_image = Image.load(CANCEL_BUTTON_IMAGE)
    @message_dialog.cancel_button.set_image(Images.fit_resize(
      cancel_button_image, @message_dialog.cancel_button.width, @message_dialog.cancel_button.height))

    @buttons = [@return_button, @window_mode_button, @message_dialog.ok_button, @message_dialog.cancel_button]

    @bgm = Bass.loadSample(ENDING_BGM)
    @bgm.play(:loop=>false, :volume=>0.7)

    @next_scene_wait_count = 0
    @is_returnable = false
  end

  def update

    if @sprite_fonts and not @sprite_fonts.empty? and @sprite_fonts[-1].y <=
      (Window.height - @sprite_fonts[-1].height) * 0.6 then

      if @next_scene_wait_count < MAX_NEXT_SCENE_WAIT_COUNT then
        @next_scene_wait_count += 1
      else
        @next_scene_wait_count = 0
        self.next_scene = NameEntryScene
      end
    else
      @sprite_fonts.each do |sprite_font|
        sprite_font.y -= @scroll_speed
      end
    end

    if @illusts and not @illusts.empty? then
      @illusts.each do |illust|
        illust.update
      end
    end

    if @window_mode_button and not @is_returnable and
      (@window_mode_button.pushed? or @window_mode_button.is_gazed) then
      @window_mode_button.is_gazed = false

      if Window.windowed? then
        Window.windowed = false
      else
        Window.windowed = true
      end
      @click_se.play if @click_se
    end

    if (@return_button and not @is_returnable and
      (@return_button.pushed? or @return_button.is_gazed)) or Input.key_push?(K_ESCAPE) then
      @return_button.is_gazed = false

      @click_se.play if @click_se
      @is_returnable = true
    end

    if @buttons and not @buttons.empty? then
      @buttons.each do |button|
        if @is_returnable and (button.name == "message_ok_button" or button.name == "message_cancel_button") then
          button.hovered?
        elsif not @is_returnable and
          not (button.name == "message_ok_button" or button.name == "message_cancel_button") then
          button.hovered?
        end
      end
    end

    if @message_dialog and
      (@message_dialog.ok_button.pushed? or @message_dialog.ok_button.is_gazed) and @is_returnable then
      @message_dialog.ok_button.is_gazed = false

      @click_se.play if @click_se
      @bgm.stop
      @bgm = nil
      self.next_scene = TitleScene
      @is_returnable = false
    end

    if @message_dialog and
      (@message_dialog.cancel_button.pushed? or @message_dialog.cancel_button.is_gazed) and @is_returnable then
      @message_dialog.cancel_button.is_gazed = false

      @click_se.play if @click_se
      @is_returnable = false
    end

    @mouse.x, @mouse.y = Input.mouse_pos_x, Input.mouse_pos_y if @mouse

    @poi.update if @poi

    Sprite.check(@illusts + [@poi]) if @illusts and not @illusts.empty? and @poi
  end

  def gazed(x, y, center_x, center_y)

    if @buttons and not @buttons.empty? then
      @buttons.each do |button|
        if x + center_x >= button.x and x + center_x <= button.x + button.width and
          y + center_y >= button.y and y + center_y <= button.y + button.height then

          if @is_returnable and (button.name == "message_ok_button" or button.name == "message_cancel_button") then
            button.is_gazed = true
          elsif not @is_returnable and
            not (button.name == "message_ok_button" or button.name == "message_cancel_button") then
            button.is_gazed = true
          end
        end
      end
    end
    @poi.mode = :search
  end

  def render

    Window.draw(0, 0, @background_image) if @background_image

    if @illusts and not @illusts.empty? then
      @illusts.each do |illust|
        illust.draw
      end
    end

    if @sprite_fonts and not @sprite_fonts.empty? then
      @sprite_fonts.each do |sprite_font|
        sprite_font.draw
      end
    end

    @return_button.draw if @return_button
    @window_mode_button.draw if @window_mode_button

    Window.draw(0, 0, @cover_layer) if @cover_layer and @is_returnable
    @message_dialog.draw if @message_dialog and @is_returnable

    @poi.draw if @poi
  end

  def will_disappear

  end
end


Scene.main_loop SplashScene, $config.fps, $config.frame_step
