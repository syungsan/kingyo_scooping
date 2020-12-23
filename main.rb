#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

# exerbで固めたexeから起動するときカレントディレクトリをexeのパスにするネ！
if defined?(ExerbRuntime)
  Dir.chdir(File.dirname(ExerbRuntime.filepath))
end

# この実行スクリプトのあるディレクトリに移動
Dir.chdir(File.expand_path("..", __FILE__))

require "dxruby" # DXRuby本体
require "./lib/dxruby/scene" # 画面遷移

# require "./lib/encode" # 文字コード変換
# require "./lib/json/pure" # JSON

# require "./scripts/name_entry"
# require "./scripts/confetti"
# require "./scripts/score_list_box"
# require "./scripts/bubble"

# require "net/http"
# require "time"

# 音
CONGRATULATIONS_SE = "./sounds/nc134713.wav"
NAME_ENTRY_BGM = "./sounds/yuugure.mp3"

# 画像
NAME_ENTRY_BUTTON_IMAGE = "./images/942037.png"

FLOOR_IMAGE = "./images/floor1.jpg"
RESET_BUTTON_IMAGE = "./images/m_1.png"
DECITION_BUTTON_IMAGE = "./images/m_2.png"
DELETE_BUTTON_IMAGE = "./images/m_3.png"
OK_BUTTON_IMAGE = "./images/m_4.png"
PAGE_UP_BUTTON = "./images/1396945_up.png"
PAGE_DOWN_BUTTON = "./images/1396945_down.png"

MAX_NAME_INPUT_NUMBER = 8

COMMENDATION_POINT = 0
CONFETTI_MAX_NUMBER = 800

# データベース POST URL
POST_URL = "http://localhost:3000/kingyo_scoopings/record"

# データベース GET URL
GET_URL = "http://localhost:3000/kingyo_scoopings/show"


# インストールするフォント ###
# たぬき油性マジック
# 自由の翼フォント
# チェックポイントフォント
# 07ラノベPOP
# AR教科書体M
# みかちゃん
# 07にくまるフォント
# Ballpark


class Config

  attr_reader :fps, :frame_step, :app_name, :app_sub_title, :copyright, :ver_number, :default_name

  require "./lib/display" # ディスプレイ情報取得

  include Display

  # アプリケーション設定
  APPLICATION_NAME = "金魚すくい"
  APPLICATION_SUB_TITLE = "視線入力対応版"
  COPYRIGHT = "Powered by Ruby & DXRuby."
  VERSION_NUMBER = "0.8"
  APPLICATION_ICON = "./images/icon.ico"

  FPS = 60
  FRAME_STEP = 1
  FRAME_SKIP = true
  WINDOWED = true

  # 初期のウィンドウカラー
  DEFAULT_BACK_GROUND_COLER = C_WHITE

  # 最大で表示できるウィンドウサイズ
  WINDOW_SIZE = FHD

  # 起動時にウィンドウを画面中央に表示する
  IS_WINDOW_CENTER = true

  DEFAULT_NAME = "ななしさん"

  TANUKI_MAGIC_FONT = "./fonts/TanukiMagic.ttf"
  JIYUNO_TSUBASA_FONT = "./fonts/JiyunoTsubasa.ttf"
  CHECK_POINT_FONT = "./fonts/CP Font.ttf"
  LIGHT_NOVEL_POP_FONT = "./fonts/ラノベPOP.otf"
  AR_KYOUKASYOTAI_M_FONT = "./fonts/JTST00M.TTC"
  MIKACHAN_FONT = "./fonts/mikachanALL.ttc"
  NIKUMARU_FONT = "./fonts/07にくまるフォント.otf"
  BALL_PARK_FONT = "./fonts/BALLW___.TTF"

  def initialize

    $scores = {:name=>DEFAULT_NAME, :score=>0, :technical_point=>0, :max_combo=>0, :catched_kingyo_number=>0, :catched_boss_number=>0,
               :total_move_distance=>0, :cognomen=>nil, :color=>nil}

    @fps = FPS
    @frame_step = FRAME_STEP

    @app_name = APPLICATION_NAME
    @app_sub_title = APPLICATION_SUB_TITLE
    @copyright = COPYRIGHT
    @ver_number = VERSION_NUMBER

    @default_name = DEFAULT_NAME

    # フォントのインストール
    Font.install(TANUKI_MAGIC_FONT)
    Font.install(JIYUNO_TSUBASA_FONT)
    Font.install(CHECK_POINT_FONT)
    Font.install(LIGHT_NOVEL_POP_FONT)
    Font.install(AR_KYOUKASYOTAI_M_FONT)
    Font.install(MIKACHAN_FONT)
    Font.install(NIKUMARU_FONT)
    Font.install(BALL_PARK_FONT)

    initWindowRect = setDisplayFixWindow(WINDOW_SIZE, IS_WINDOW_CENTER)
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
    Window.windowed = WINDOWED
  end
end

# mp3などを鳴らすため
Dir.chdir("./lib/dxruby") do
  require "Bass"
end
Bass.init(Window.hWnd)

$config = Config.new


# タイトル・シーン
class TitleScene < Scene::Base

  require "./lib/dxruby/images"
  require "./lib/dxruby/fonts"
  require "./lib/dxruby/button"
  require "./lib/dxruby/color"

  require "./scripts/poi"

  include Color

  CLICK_SE = "./sounds/push13.wav"
  START_GAME_SE = "./sounds/decision27.wav"
  BACK_GROUND_IMAGE = "./images/VectorNaturalGreenBackground_S.png"
  START_BUTTON_IMAGE = "./images/start_button.png"
  EXIT_BUTTON_IMAGE = "./images/s_3.png"
  WINDOW_MODE_BUTTON_IMAGE = "./images/s_2.png"

  MAX_COUNT_IN_WINDOW = 40
  MAX_COUNT_IN_GAZE_AREA = 30

  POI_HEIGHT_SIZE = Window.height * 0.2
  MAX_GAZE_COUNT = 15
  POI_GAZE_RADIUS_RATIO = 0.8
  
  def init

    # 必要最小限のグローバル変数を初期化
    $scores = {:name=>$config.default_name, :score=>0, :technical_point=>0, :max_combo=>0, :catched_kingyo_number=>0, :catched_boss_number=>0,
               :total_move_distance=>0, :cognomen=>nil, :color=>nil}

    @click_se = Sound.new(CLICK_SE)
    @start_game_se = Sound.new(START_GAME_SE)

    background_image = Image.load(BACK_GROUND_IMAGE)
    @background_image = Images.fit_resize(background_image, Window.width, Window.height)

    @title_label = Fonts.new(0, 0, $config.app_name, Window.height * 0.2, C_RED,
                            {:font_name=>"チェックポイントフォント"})
    @title_label.set_pos((Window.width - @title_label.width) * 0.5, (Window.height - @title_label.height) * 0.3)

    @sub_title_label = Fonts.new(0, 0, $config.app_sub_title, Window.height * 0.1, C_ORANGE,
                                 {:font_name=>"AR教科書体M"})
    @sub_title_label.set_pos((Window.width - @sub_title_label.width) * 0.5, (Window.height - @sub_title_label.height) * 0.12)

    @version_number_label = Fonts.new(0, 0, "Version #{$config.ver_number}", @title_label.height * 0.3, C_GREEN,
                                    {:font_name=>"自由の翼フォント"})
    @version_number_label.set_pos(@title_label.x + @title_label.width - @version_number_label.width, @title_label.y + @title_label.height)

    @copyright_label = Fonts.new(0, 0, $config.copyright, Window.height * 0.08, C_BLACK,
                                {:font_name=>"07ラノベPOP"})
    @copyright_label.set_pos((Window.width - @copyright_label.width) * 0.5, (Window.height - @copyright_label.height) * 0.9)

    start_button_image = Image.load(START_BUTTON_IMAGE)
    start_button_scale = Window.height * 0.06 / start_button_image.height
    start_button_converted_image = Images.scale_resize(start_button_image, start_button_scale, start_button_scale)
    @start_button = Button.new
    @start_button.set_image(start_button_converted_image)
    @start_button.set_pos((Window.width - @start_button.width) * 0.5, (Window.height - @start_button.height) * 0.7)

    exit_button_image = Image.load(EXIT_BUTTON_IMAGE)
    exit_button_scale = Window.height * 0.05 / exit_button_image.height
    exit_button_converted_image = Images.scale_resize(exit_button_image, exit_button_scale, exit_button_scale)
    @exit_button = Button.new
    @exit_button.set_image(exit_button_converted_image)
    @exit_button.set_string("Exit", exit_button_converted_image.height * 0.7, "07ラノベPOP", {:color=>C_DARK_BLUE})
    @exit_button.set_pos(Window.width - @exit_button.width, 0)

    window_mode_button_image = Image.load(WINDOW_MODE_BUTTON_IMAGE)
    window_mode_button_scale = Window.height * 0.05 / window_mode_button_image.height
    window_mode_button_converted_image = Images.scale_resize(window_mode_button_image, window_mode_button_scale, window_mode_button_scale)
    @window_mode_button = Button.new
    @window_mode_button.set_image(window_mode_button_converted_image)
    @window_mode_button.set_string("Full/Win", window_mode_button_converted_image.height * 0.5,
                                   "07ラノベPOP", {:color=>C_DARK_BLUE})
    @window_mode_button.set_pos(Window.width - (@exit_button.width + @window_mode_button.width), 0)

    @buttons = [@start_button, @exit_button, @window_mode_button]

    @is_start_button_blink = false
    @start_button_blink_count = 0
    @wait_stage_change_count = 0

    @mouse = Sprite.new
    @mouse.collision = [0, 0]

    @poi = Poi.new(0, 0, nil, POI_HEIGHT_SIZE, @mouse,
                   MAX_GAZE_COUNT, self, nil, {:max_count_in_window=>MAX_COUNT_IN_WINDOW,
                                               :gaze_radius_ratio=>POI_GAZE_RADIUS_RATIO, :max_count_in_gaze_area=>MAX_COUNT_IN_GAZE_AREA})
    @poi.set_pos((Window.width - @poi.width) * 0.5, (Window.height - @poi.height) * 0.5)
  end

  def update

    if @start_button and (@start_button.pushed? or @start_button.is_gazed) then
      @start_button.is_gazed = false
      @is_start_button_blink = true unless @is_start_button_blink
      @start_button.hover = false if @start_button.is_hoverable
      @start_game_se.play
      @wait_stage_change_count = 0
    end

    if @window_mode_button and (@window_mode_button.pushed? or @window_mode_button.is_gazed) then
      @window_mode_button.is_gazed = false
      if Window.windowed? then
        Window.windowed = false
      else
        Window.windowed = true
      end
      @click_se.play
    end

    if (@exit_button and (@exit_button.pushed? or @exit_button.is_gazed)) or Input.key_push?(K_ESCAPE) then
      @exit_button.is_gazed = false
      self.did_disappear
      exit
    end

    if @buttons and not @buttons.empty? then
      @buttons.each do |button|
        button.hovered?
      end
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
          button.is_gazed = true
        end
      end
    end
    @poi.mode = :search
  end

  def render

    Window.draw(0, 0, @background_image)

    @title_label.draw if @title_label
    @sub_title_label.draw if @sub_title_label
    @version_number_label.draw if @version_number_label
    @copyright_label.draw if @copyright_label

    @start_button.draw if @start_button
    @exit_button.draw if @exit_button
    @window_mode_button.draw if @window_mode_button

    @poi.draw if @poi
  end

  def did_disappear

  end
end


# ゲーム・シーン
class GameScene < Scene::Base

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

  CLICK_SE = "./sounds/push13.wav"
  MAIN_BGM = "./sounds/minamo.mp3"
  ALERT_BGM = "./sounds/nc40157.wav"
  BOSS_BGM = "./sounds/boss_panic_big_march.mp3"
  SPLASH_SMALL_SE = "./sounds/water-drop3.wav"
  SPLASH_RARGE_SE = "./sounds/water-throw-stone2.wav"
  CHANGE_STAGE_SE = "./sounds/sei_ge_bubble06.wav"

  EXIT_BUTTON_IMAGE = "./images/s_3.png"
  WINDOW_MODE_BUTTON_IMAGE = "./images/s_2.png"
  STONE_TILE_IMAGE = "./images/stone_tile.png"
  AQUARIUM_BACK_IMAGE = "./images/seamless-water.jpg"
  SPLASH_IMAGE = "./images/water_splash.png"

  MAX_COUNT_IN_WINDOW = 60
  MAX_COUNT_IN_GAZE_AREA = 30

  POI_HEIGHT_SIZE = Window.height * 0.35
  MAX_GAZE_COUNT = 60
  POI_GAZE_RADIUS_RATIO = 0.5

  FIRST_STAGE_NUMBER = 1
  FIRST_MODE = :start

  KINGYO_NUMBERS = [20]
  KINGYO_SCALE_RANGES = [[0.5, 1]]
  KINGYO_SPEED_RANGES = [{:wait=>[0, 1], :move=>[1, 5], :escape=>[1, 5]}]
  KINGYO_MODE_RANGES = [{:wait=>[0, 100], :move=>[0, 100], :escape=>[0, 100]}]
  KIND_OF_KINGYOS = ["red", "black"]

  BOSS_NUMBERS = 3
  BOSS_SCALE_RANGES = [0.5, 1]
  BOSS_SPEED_RANGES = {:wait=>[0, 1], :move=>[1, 3], :against=>[1, 3]}
  BOSS_MODE_RANGES = {:wait=>[0, 200], :move=>[0, 100], :against=>[0, 200]}

  WEED_NUMBERS = [10]
  WEED_SCALE_RANGES = [[0.2, 0.5]]

  BASE_SCORES = {"red_kingyo"=>100, "black_kingyo"=>50, "weed"=>-150, "boss"=>1000}

  CHALLENGE_POINT_UP_RANGE = 200
  MAX_POI_GAUGE_NUMBER = 5

  TILDE =  "\x81\x60".encode("BINARY")
  MAIN_BGM_DATE = ["水面", "Composed by iPad", "しゅんじ" + TILDE]
  BOSS_BGM_DATE = ["ボス・パニック大行進", "Composed by iPad", "しゅんじ" + TILDE]
  MAIN_ALERT_STRING = "警告！ ボス金魚出現！"
  SUB_ALERT_STRING = "WARNING!"

  Z_POSITION_TOP = 300
  Z_POSITION_UP = 200
  Z_POSITION_DOWN = 100
  Z_POSITION_BOTTOM = 0

  POI_CATCH_ADJUST_RANGE_RATIO = 1.0
  CONTAINER_CONTACT_ADJUST_RANGE_RATIO = 1.2
  CONTAINER_RESERVE_ADJUST_RANGE_RATIO = 0.55

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

    exit_button_image = Image.load(EXIT_BUTTON_IMAGE)
    exit_button_scale = Window.height * 0.05 / exit_button_image.height
    exit_button_converted_image = Images.scale_resize(exit_button_image, exit_button_scale, exit_button_scale)
    @exit_button = Button.new
    @exit_button.set_image(exit_button_converted_image)
    @exit_button.set_string("Exit", exit_button_converted_image.height * 0.7, "07ラノベPOP", {:color=>C_DARK_BLUE})
    @exit_button.set_pos(Window.width - @exit_button.width, 0)

    window_mode_button_image = Image.load(WINDOW_MODE_BUTTON_IMAGE)
    window_mode_button_scale = Window.height * 0.05 / window_mode_button_image.height
    window_mode_button_converted_image = Images.scale_resize(window_mode_button_image, window_mode_button_scale, window_mode_button_scale)
    @window_mode_button = Button.new
    @window_mode_button.set_image(window_mode_button_converted_image)
    @window_mode_button.set_string("Full/Win", window_mode_button_converted_image.height * 0.5,
                                   "07ラノベPOP", {:color=>C_DARK_BLUE})
    @window_mode_button.set_pos(Window.width - (@exit_button.width + @window_mode_button.width), 0)

    @buttons = [@exit_button, @window_mode_button]

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
    aquarium_back_converted_image = Images.scale_resize(aquarium_back_image, aquarium_back_image_scale, aquarium_back_image_scale)
    aquarium_back_rt = RenderTarget.new(Window.width, Window.height)
    aquarium_back_rt.drawTile(0, 0, [[0]], [aquarium_back_converted_image], nil, nil, nil, nil)
    @aquarium_back_image = aquarium_back_rt.to_image
    aquarium_back_converted_image.dispose
    aquarium_back_rt.dispose

    @wave_shader = SampleMappingShader.new
    @shader_rt = RenderTarget.new(Window.width, Window.height)

    @stage_info_label = Fonts.new(0, 0, "", Window.height * 0.2, C_BROWN, {:font_name=>"07ラノベPOP"})

    @score_label = Fonts.new(0, 0, "SCORE : #{$scores[:score]}点", Window.height * 0.05, C_GREEN,
                             {:font_name=>"自由の翼フォント"})
    @score_label.z = Z_POSITION_TOP

    @border = Border.new(0, 0, Window.width, Window.height)

    @container = Container.new(0, 0, nil, Window.height * 0.37)
    @container.set_pos(rand_float(@border.x, @border.x + @border.width - @container.width),
                       rand_float(@border.y, @border.y + @border.height - @container.height))
    @container.z = Z_POSITION_DOWN

    @mouse = Sprite.new
    @mouse.collision = [0, 0]

    @poi = Poi.new(0, 0, nil, POI_HEIGHT_SIZE, @mouse,
                   MAX_GAZE_COUNT, self, @container, {:max_count_in_window=>MAX_COUNT_IN_WINDOW,
                                         :gaze_radius_ratio=>POI_GAZE_RADIUS_RATIO, :max_count_in_gaze_area=>MAX_COUNT_IN_GAZE_AREA})
    @poi.set_pos((Window.width - @poi.width) * 0.5, (Window.height - @poi.height) * 0.5)
    @poi.z = Z_POSITION_TOP

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
    @life_continueble = false

    poi_gauge_height_size = Window.height * 0.1
    poi_gauge_interval = Window.width * 0.023

    @poi_gauges = []
    MAX_POI_GAUGE_NUMBER.times do |index|
      poi_gauge = PoiGage.new(nil, poi_gauge_height_size)
      poi_gauge.set_pos((Window.width - poi_gauge.width) * 0.85 + (poi_gauge_interval * index), (Window.height - poi_gauge.height) * 0.96)
      poi_gauge.z = Z_POSITION_UP
      @poi_gauges.push(poi_gauge)
    end
    @poi_gauges.reverse!

    @alert = Alert.new(0, 0, Window.width, Window.height)
    @alert.z = Z_POSITION_TOP
    @alert.make_sub_alert(SUB_ALERT_STRING, "07ラノベPOP")
    @alert.make_main_alert(MAIN_ALERT_STRING, "チェックポイントフォント")
    @alert.main_alert_speed = -1 * Math.sqrt(Window.height * 0.1)
    @alert.sub_alert_speed = Math.sqrt(Window.height * 0.1)

    @windows = []
    @swimers = []
    @splashs = []
    @catch_objects = []

    @challenge_point = 0
    @start_count = 0

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
        @stage_info_label.set_pos((Window.width - @stage_info_label.width) * 0.5, (Window.height - @stage_info_label.height) * 0.5)
      end

    when :normal

      if @bgm then
        @bgm.stop
      end
      if @main_bgm then
        @bgm = @main_bgm
        @bgm.play(:loop=>true, :volume=>0.5)
      end
      if @bgm_info then
        @bgm_info.set_info({:title=>MAIN_BGM_DATE[0], :data=>MAIN_BGM_DATE[1], :copyright=>MAIN_BGM_DATE[2]},
                           {:title=>"たぬき油性マジック", :data=>"たぬき油性マジック", :copyright=>"たぬき油性マジック"},
                           {:title=>@bgm_info.height * 0.3, :data=>@bgm_info.height * 0.2, :copyright=>@bgm_info.height * 0.25})
        @bgm_info.mode = :run
      end

    when :alert

      @alert.mode = :run if @alert

      if @bgm then
        @bgm.stop
      end
      if @alert_bgm then
        @bgm = @alert_bgm
        @bgm.play(:loop=>true, :volume=>0.5)
      end

      self.boss_init

    when :boss

      if @bgm then
        @bgm.stop
      end
      if @boss_bgm then
        @bgm = @boss_bgm
        @bgm.play(:loop=>true, :volume=>0.5)
      end
      if @bgm_info then
        @bgm_info.set_info({:title=>BOSS_BGM_DATE[0], :data=>BOSS_BGM_DATE[1], :copyright=>BOSS_BGM_DATE[2]},
                           {:title=>"たぬき油性マジック", :data=>"たぬき油性マジック", :copyright=>"たぬき油性マジック"},
                           {:title=>@bgm_info.height * 0.3, :data=>@bgm_info.height * 0.2, :copyright=>@bgm_info.height * 0.25})
        @bgm_info.mode = :run
      end
    end

    @mode = mode
  end

  def stage_init

    weeds = []
    WEED_NUMBERS[@stage_number - 1].times do |index|
      weed_height = Window.height * rand_float(WEED_SCALE_RANGES[@stage_number - 1][0], WEED_SCALE_RANGES[@stage_number - 1][1])
      weed = Weed.new(0, 0, nil, weed_height, rand(360), index)
      weed.set_pos(random_int(@border.x, @border.x + @border.width - weed.width),
                   random_int(@border.y, @border.y + @border.height - weed.height)) if @border
      weed.z = Z_POSITION_TOP
      weeds.push(weed)
    end

    kingyos = []
    KINGYO_NUMBERS[@stage_number - 1].times do |index|
      kingyo_height = Window.height * rand_float(0.1, 0.2)
      kingyo = Kingyo.new(0, 0, nil, kingyo_height, KIND_OF_KINGYOS[rand(2)], rand(360),
                          index, {:wait=>[0, Math.sqrt(Window.height * 0.001)],
                                  :move=>[Math.sqrt(Window.height * 0.001), Math.sqrt(Window.height * 0.024)],
                                  :escape=>[Math.sqrt(Window.height * 0.001), Math.sqrt(Window.height * 0.024)]})
      kingyo.set_pos(random_int(@border.x, @border.x + @border.width - kingyo.width),
                     random_int(@border.y, @border.y + @border.height - kingyo.height)) if @border
      kingyo.z = Z_POSITION_TOP
      kingyos.push(kingyo)
    end

    @swimers = weeds + kingyos
    fisher_yates(@swimers)
  end

  def boss_init

    bosss = []
    BOSS_NUMBERS.times do |index|
      boss_height = Window.height * rand_float(0.3, 0.6)
      boss = Boss.new(0, 0, nil, boss_height, rand(360), index,
                      {:wait=>[0, Math.sqrt(Window.height * 0.001)],
                       :move=>[Math.sqrt(Window.height * 0.001), Math.sqrt(Window.height * 0.009)],
                       :escape=>[Math.sqrt(Window.height * 0.001), Math.sqrt(Window.height * 0.009)]})
      boss.set_pos(random_int(@border.x, @border.x + @border.width - boss.width),
                   random_int(@border.y, @border.y + @border.height - boss.height)) if @border
      boss.z = Z_POSITION_TOP
      bosss.push(boss)
    end

    @swimers += bosss
    fisher_yates(@swimers)
  end

  def update

    if @window_mode_button and (@window_mode_button.pushed? or @window_mode_button.is_gazed) then
      @window_mode_button.is_gazed = false
      if Window.windowed? then
        Window.windowed = false
      else
        Window.windowed = true
      end
      @click_se.play
    end

    if @exit_button and (@exit_button.pushed? or @exit_button.is_gazed) or Input.key_push?(K_ESCAPE) then
      @exit_button.is_gazed = false
      self.did_disappear
      exit
    end

    if @buttons and not @buttons.empty? then
      @buttons.each do |button|
        button.hovered?
      end
    end

    @mouse.x, @mouse.y = Input.mouse_pos_x, Input.mouse_pos_y if @mouse

    if @mode == :start then
      if @start_count <= START_MAX_COUNT then
        @wave_shader.update if @wave_shader
        @start_count += 1
      else
        self.change_mode(:normal)
      end
    end





    # swimerに対するメインループ
    if @swimers and not @swimers.empty? and not @mode == :start
    @swimers.each do |swimer|
        if not swimer.mode == :catched and not swimer.is_reserved then
          if (swimer.x + swimer.center_x - (@container.x + (@container.width * 0.5))) ** 2 + ((swimer.y + swimer.center_y - (@container.y + (@container.height * 0.5))) ** 2) <= (@container.width * 0.5 * CONTAINER_CONTACT_ADJUST_RANGE_RATIO) ** 2 then
            swimer.z = Z_POSITION_BOTTOM
          else
            swimer.z = Z_POSITION_TOP
          end
        end

        if swimer.mode == :reserved then
          splash = Splash.new(SPLASH_IMAGE, 10, 1)
          splash.run(swimer.x + swimer.center_x - (splash.width * 0.5), swimer.y + swimer.center_y - (splash.height * 0.5), swimer, swimer.height * 2.0, 0.8)
          if swimer.name == "boss" then
            @splash_rarge_se.play
          else
            @splash_small_se.play
          end
          @splashs.push(splash)
        end

        if swimer.is_reserved then
          max_radius = @container.width * 0.5 * CONTAINER_RESERVE_ADJUST_RANGE_RATIO
          obj_radius = Math.sqrt((swimer.x + swimer.center_x - (@container.x + @container.center_x)) ** 2 + ((swimer.y + swimer.center_y - (@container.y + @container.center_y)) ** 2))

          if obj_radius >= max_radius then
            angle = Math.atan2(swimer.y + swimer.center_y - (@container.y + @container.center_y), swimer.x + swimer.center_x - (@container.x + @container.center_x))
            swimer.x = @container.x + @container.center_x - (swimer.width * 0.5) + (max_radius * Math.cos(angle))
            swimer.y = @container.y + @container.center_y - (swimer.height * 0.5) + (max_radius * Math.sin(angle))
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

    @bgm_info.update if @bgm_info and @bgm_info.mode == :run and not @mode == :start

    if @alert and @alert.mode == :run and not @mode == :start then
      @alert.update
    elsif @alert and @alert.mode == :finish
      @alert.mode = :wait
      self.change_mode(:boss)
    end

    if @swimers and not @swimers.empty? and not @mode == :start then
      @swimers.each do |swimer|
        swimer.update
      end
    end

    @poi.update if @poi

    @life_gauge.update

    if @life_gauge.has_out_of_life and not @life_continueble then
      @poi_gauges[-1].vanish
      @poi_gauges.delete_at(-1)
      @life_continueble = true
    end

    @point_label.update if @point_label
    @point_label = nil if @point_label and @point_label.vanished?

    Sprite.check(@border.blocks + @swimers + [@container]) if
      @border and @swimers and not @swimers.empty? and @container and not @mode == :start


    if @poi and @poi.mode == :transport then
      @catch_objects.each do |catch_object|
        catch_object[0].set_pos(@poi.x + catch_object[1][0], @poi.y + catch_object[1][1])

        damage_unit = 0.0005 if catch_object[0].name.include?("kingyo")
        damage_unit = 0.001 if catch_object[0].name == "weed"

        @life_gauge.change_life(-1 * catch_object[0].height * damage_unit)
      end
    elsif @poi and @poi.mode == :reserve then
      @catch_objects.clear

    end
  end

  def gazed(x, y, center_x, center_y)

    if @buttons and not @buttons.empty? and not @mode == :start then
      @buttons.each do |button|
        if x + center_x >= button.x and x + center_x <= button.x + button.width and
          y + center_y >= button.y and y + center_y <= button.y + button.height then
          button.is_gazed = true
        end
      end
    end

    if @poi and not @mode == :start then
      @catch_objects = []
      if @swimers and not @swimers.empty? then

        @swimers.each do |swimer|
          unless swimer.z == Z_POSITION_BOTTOM then
            if (swimer.x + swimer.center_x - (x + center_x)) ** 2 +
              ((swimer.y + swimer.center_y - (y + center_y)) ** 2) <=
              (@poi.width * 0.5 * POI_CATCH_ADJUST_RANGE_RATIO) ** 2 then

              swimer.mode = :catched
              @catch_objects.push([swimer, [swimer.x - x, swimer.y - y]])
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

  def render

    Window.draw(0, 0, @stone_tile_image) if @stone_tile_image
    Window.draw_ex(0, 0, @aquarium_back_image, :alpha=>180) if @aquarium_back_image

    @border.draw if @border and @mode == :start

    @shader_rt.draw(0, 0, @aquarium_back_image) if @mode == :start
    Window.draw_shader(0, 0, @shader_rt, @wave_shader) if @mode == :start

    @stage_info_label.draw if @mode == :start

    @container.draw if @container and not @mode == :start
    @poi.draw if @poi

    if @swimers and not @swimers.empty? and not @mode == :start then
      @swimers.each do |swimer|
        swimer.draw if not swimer.name == "boss" or not @mode == :alert
      end
    end

    if @splashs and not @splashs.empty? and not @mode == :start
      @splashs.each do |splash|
        splash.draw
      end
    end

    @exit_button.draw
    @window_mode_button.draw

    @score_label.draw if @score_label and not @mode == :start
    @bgm_info.draw if @bgm_info and @bgm_info.mode == :run and not @mode == :start

    @life_gauge.draw unless @mode == :start

    unless @mode == :start then
      @poi_gauges.each do |poi_gauge|
        poi_gauge.draw
      end
    end

    @point_label.draw if @point_label

    @alert.draw if @alert and @alert.mode == :run and not @mode == :start
  end

  def scoring(targets)

    score_diff = 0
    technical_point_diff = 0

    target_center_xs = []
    target_center_ys = []

    targets.each do |target|
      score_diff += (BASE_SCORES[target.name] * target.height * 0.01).round
      target_center_xs.push(target.x + target.center_x)
      target_center_ys.push(target.y + target.center_y)
    end

    point = score_diff * targets.size
    $scores[:score] += point
    @score_label.string = "SCORE : #{$scores[:score]}点"

    original_points = [@container.x + @container.center_x, @container.y + @container.center_y]
    geometric_centers = calc_geometric_center(target_center_xs, target_center_ys)
    diff_vector = [geometric_centers[0] - original_points[0], geometric_centers[1] - original_points[1]]
    v_changes = [diff_vector[0] * POINT_LABEL_MOVE_SCALE, diff_vector[1] * POINT_LABEL_MOVE_SCALE]
    weight_ratio = 1 - (1 / (1 + (point.abs * 0.01)))

    @point_label = SpriteFont.new(0, 0, "#{point}点", 128, C_RED, C_DEFAULT,
                                  {:font_name=>MIKACHAN_FONT_TYPE, :shadow=>true, :shadow_color=>[128, 128, 128, 128]})
    @point_label.z = Z_POSITION_TOP
    @point_label.fade_move(geometric_centers, v_changes, weight_ratio, [0, 0, Window.width, Window.height])

    @life_continueble = false

    technical_point_diff += 50
    $scores[:technical_point] += technical_point_diff

    @challenge_point += technical_point_diff
    boss_remaind_numbes = @swimers.select { |obj| obj.name == "boss" and not obj.is_reserved}
    if @challenge_point >= CHALLENGE_POINT_UP_RANGE and not @mode == :alert and boss_remaind_numbes.empty? then
      self.change_mode(:alert)
      @challenge_point = 0
    end

    if @swimers.select { |obj| not obj.is_reserved and not obj.name == "weed"}.empty? then
      @mode = :game_over
      $scores[:max_combo] = 0
      $scores[:catched_kingyo_number] = 0
      $scores[:catched_boss_number] = 0
      $scores[:total_move_distance] = 0
      self.did_disappear
      self.next_scene = ResultScene
    end

  end

  def did_disappear
    if @bgm then
      @bgm.stop
      @bgm.free
      # Bass.free
    end
  end
end


class ResultScene < Scene::Base

  # include Common

  def init

    @clickSE = Sound.new(CLICK_SE)
    ok_button_image = Image.load(OK_BUTTON_IMAGE)

    @congratulations_se = Sound.new(CONGRATULATIONS_SE)
    @background = Image.new(Window.width, Window.height).box_fill(0, 0, Window.width, Window.height, C_MISTY_ROSE)

    $cognomens[:cognomen], $cognomens[:color] = "ウンコちゃん", "A52A2A" if $scores[:technical_point] < 500
    $cognomens[:cognomen], $cognomens[:color] = "ザコりん", "00FFFF" if $scores[:technical_point] >= 500 and $scores[:technical_point] < 1000
    $cognomens[:cognomen], $cognomens[:color] = "初心者ペー", "FFFF00" if $scores[:technical_point] >= 1000 and $scores[:technical_point] < 2000
    $cognomens[:cognomen], $cognomens[:color] = "普通ヲタ", "008000" if $scores[:technical_point] >= 2000 and $scores[:technical_point] < 3000
    $cognomens[:cognomen], $cognomens[:color] = "良しヲくん", "FFA500" if $scores[:technical_point] >= 3000 and $scores[:technical_point] < 4000
    $cognomens[:cognomen], $cognomens[:color] = "スーパーカブ", "ff00ff" if $scores[:technical_point] >= 4000 and $scores[:technical_point] < 5000
    $cognomens[:cognomen], $cognomens[:color] = "レジェンドン", "0000FF" if $scores[:technical_point] >= 5000 and $scores[:technical_point] < 6000
    $cognomens[:cognomen], $cognomens[:color] = "金魚人", "800080" if $scores[:technical_point] >= 6000 and $scores[:technical_point] < 7000
    $cognomens[:cognomen], $cognomens[:color] = "金魚神", "FF0000" if $scores[:technical_point] >= 7000

    @titleLabel = Fonts.new(0, 0, "結果", Window.height * 0.1, C_PURPLE, 0, "title_label", {:fontType=>CHECK_POINT_FONT_TYPE})
    @titleLabel.set_pos((Window.width - @titleLabel.get_width) * 0.5, Window.height * 0.03)

    @score_label = Fonts.new(0, 0, "SCORE : #{$scores[:score]}点", Window.height * 0.05, C_GREEN, 0, "score_label", {:fontType=>JIYUNO_TSUBASA_FONT_TYPE})
    @score_label.set_pos((Window.width - @score_label.get_width) * 0.5, Window.height * 0.15)

    @catched_kingyo_number_label = Fonts.new(0, 0, "金魚捕獲数 : #{$scores[:catched_kingyo_number]}匹", Window.height * 0.07, C_RED, 0, "catched_kingyo_number_label", {:fontType=>JIYUNO_TSUBASA_FONT_TYPE})
    @catched_kingyo_number_label.set_pos((Window.width - @catched_kingyo_number_label.get_width) * 0.5, Window.height * 0.23)

    @catched_boss_number_label = Fonts.new(0, 0, "ボス捕獲数 : #{$scores[:catched_boss_number]}匹", Window.height * 0.07, C_RED, 0, "catched_boss_number_label", {:fontType=>JIYUNO_TSUBASA_FONT_TYPE})
    @catched_boss_number_label.set_pos((Window.width - @catched_boss_number_label.get_width) * 0.5, Window.height * 0.33)

    @max_combo_label = Fonts.new(0, 0, "MAXコンボ : #{$scores[:max_combo]}", Window.height * 0.07, C_ORANGE, 0, "max_combo_label", {:fontType=>JIYUNO_TSUBASA_FONT_TYPE})
    @max_combo_label.set_pos((Window.width - @max_combo_label.get_width) * 0.5, Window.height * 0.43)

    @total_move_distance_label = Fonts.new(0, 0, "総移動距離 : #{$scores[:total_move_distance]}m", Window.height * 0.07, C_GRAY, 0, "total_move_distance_label", {:fontType=>JIYUNO_TSUBASA_FONT_TYPE})
    @total_move_distance_label.set_pos((Window.width - @total_move_distance_label.get_width) * 0.5, Window.height * 0.53)

    @technical_point_label = Fonts.new(0, 0, "テクニカルポイント : #{$scores[:technical_point]}", Window.height * 0.05, C_DARK_BLUE, 0, "technical_point_label", {:fontType=>JIYUNO_TSUBASA_FONT_TYPE})
    @technical_point_label.set_pos((Window.width - @technical_point_label.get_width) * 0.5, Window.height * 0.63)

    @cognomen_label = Fonts.new(0, 0, "称号 : #{$cognomens[:cognomen]}", Window.height * 0.1, hex_to_rgb($cognomens[:color].hex).values, 0, "cognomen_label", {:fontType=>TANUKI_MAGIC_FONT_TYPE})
    @cognomen_label.set_pos((Window.width - @cognomen_label.get_width) * 0.5, Window.height * 0.71)
    @cognomen_label.isBold = true

    ok_button_width_scale = Window.width * 0.2 / ok_button_image.width
    ok_button_height_scale = Window.height * 0.1 / ok_button_image.height
    @ok_button = Button.new(Window.width * 0.4, Window.height * 0.85)
    @ok_button.name = "ok_button"
    ok_button_converted_image = RenderTarget.new(Window.width * 0.2, Window.height * 0.1).draw_scale(0, 0, ok_button_image, ok_button_width_scale, ok_button_height_scale, 0, 0).to_image
    @ok_button.set_image_and_text(ok_button_converted_image, text="OK", ok_button_converted_image.height * 0.8, C_MIKUSAN, LIGHT_NOVEL_POP_FONT_TYPE)
    ok_button_image.dispose

    if $scores[:technical_point] >= COMMENDATION_POINT then
      confetti_size_min = Window.height * 0.03
      confetti_size_max = confetti_size_min * 3
      confetti_accel_min = 0.02
      confetti_accel_max = confetti_accel_min * 4
      confetti_amp_min = Window.height * 0.005
      confetti_amp_max = confetti_amp_min * 2
      confetti_rot_speed_min = 0.5
      confetti_rot_speed_max = confetti_rot_speed_min * 15
      confetti_angular_velo_min = 0.5
      confetti_angular_velo_max = confetti_angular_velo_min * 10

      @confettis = []
      CONFETTI_MAX_NUMBER.times do
        confetti = Confetti.new(Window.height, [0, 0], [0, 0], [confetti_size_min, confetti_size_max],
                                [confetti_accel_min, confetti_accel_max], [confetti_amp_min, confetti_amp_max],
                                [confetti_rot_speed_min, confetti_rot_speed_max], [confetti_angular_velo_min, confetti_angular_velo_max])
        confetti.set_x([-1 * confetti.width * Math.sqrt(2), Window.width + (confetti.width * Math.sqrt(2))])
        confetti.set_y([-1 * confetti.height * Math.sqrt(2), -1 * Window.height + confetti.height * Math.sqrt(2)])
        @confettis.push(confetti)
      end
      @congratulations_se.play
    end
  end

  def update

    if @confettis and not @confettis.empty? then
      @confettis.each do |confetti|
        confetti.update
      end
    end

    if @ok_button.pushed? then
      @clickSE.play
      if $scores[:technical_point] >= COMMENDATION_POINT then
        self.next_scene = EndingScene
      else
        self.next_scene = NameEntryScene
      end
    end
    @ok_button.hovered?
  end

  def render

    Window.draw(0, 0, @background) if @background

    if @confettis and not @confettis.empty? then
      @confettis.each do |confetti|
        confetti.draw
      end
    end

    @titleLabel.render
    @score_label.render
    @catched_kingyo_number_label.render
    @catched_boss_number_label.render
    @max_combo_label.render
    @total_move_distance_label.render
    @technical_point_label.render
    @cognomen_label.render
    @ok_button.render
  end
end


class NameEntryScene < Scene::Base

  def init

    @clickSE = Sound.new(CLICK_SE)
    @bgm = Bass.loadSample(NAME_ENTRY_BGM)

    floor_image = Image.load(FLOOR_IMAGE)
    reset_button_image = Image.load(RESET_BUTTON_IMAGE)
    decision_button_image = Image.load(DECITION_BUTTON_IMAGE)
    delete_button_image = Image.load(DELETE_BUTTON_IMAGE)
    name_entry_button_image = Image.load(NAME_ENTRY_BUTTON_IMAGE)

    exit_button_image = Image.load(EXIT_BUTTON_IMAGE)
    window_mode_button_image = Image.load(WINDOW_MODE_BUTTON_IMAGE)

    floor_image_scale = 1.0
    floor_src_rt = RenderTarget.new(floor_image.width * floor_image_scale, floor_image.height * floor_image_scale)
    floor_src_rt.draw_scale(0, 0, floor_image, floor_image_scale, floor_image_scale)
    floor_src_image = floor_src_rt.to_image
    floor_image.dispose
    floor_src_rt.dispose
    floor_rt = RenderTarget.new(Window.width, Window.height)
    floor_rt.drawTile(0, 0, [[0]], [floor_src_image], nil, nil, nil, nil)
    @floor_image = floor_rt.to_image
    floor_src_image.dispose
    floor_rt.dispose

    @titleLabel = Fonts.new(0, 0, "名前の入力", Window.height * 0.05, C_BLACK)
    @titleLabel.set_pos((Window.width - @titleLabel.get_width) * 0.5, Window.height * 0.06 - (@titleLabel.get_height * 0.5))
    @titleLabel.fontType = LIGHT_NOVEL_POP_FONT_TYPE

    @scoreLabel = Fonts.new(0, 0, "SCORE : #{$scores[:score]}点", Window.height * 0.07, C_GREEN)
    @scoreLabel.set_pos((Window.width - @scoreLabel.get_width) * 0.5, Window.height * 0.13 - (@scoreLabel.get_height * 0.5))
    @scoreLabel.fontType = JIYUNO_TSUBASA_FONT_TYPE

    @inputBox = Images.new(Window.width * 0.3, Window.height * 0.18, Window.width * 0.4, Window.height * 0.13, "")
    @inputBox.fontSize = @inputBox.w * 0.12
    @inputBox.string_pos("", @inputBox.font_size, (@inputBox.w - (@inputBox.font_size * MAX_NAME_INPUT_NUMBER)) * 0.5, (@inputBox.h - @inputBox.font_size) * 0.5, C_BLACK)
    @inputBox.fontType = AR_KYOUKASYOTAI_M_FONT_TYPE
    @inputBox.frame(C_BROWN, @inputBox.h * 0.05)

    exitButtonHeight = Window.height * 0.05
    exit_button_scale = exitButtonHeight / exit_button_image.height
    exit_button_converted_image = RenderTarget.new(exit_button_image.width * exit_button_scale, exit_button_image.height * exit_button_scale).draw_scale(0, 0, exit_button_image, exit_button_scale, exit_button_scale, 0, 0).to_image
    @exitButton = Button.new()
    @exitButton.name = "exit_button"
    @exitButton.set_image_and_text(exit_button_converted_image, "Exit", exit_button_converted_image.height * 0.7, C_DARK_BLUE, LIGHT_NOVEL_POP_FONT_TYPE)
    exit_button_image.dispose
    @exitButton.set_pos(Window.width - @exitButton.w, 0)

    windowModeButtonHeight = Window.height * 0.05
    window_mode_button_scale = windowModeButtonHeight / window_mode_button_image.height
    window_mode_button_converted_image = RenderTarget.new(window_mode_button_image.width * window_mode_button_scale, window_mode_button_image.height * window_mode_button_scale).draw_scale(0, 0, window_mode_button_image, window_mode_button_scale, window_mode_button_scale, 0, 0).to_image
    @windowModeButton = Button.new()
    @windowModeButton.name = "window_mode_button"
    @windowModeButton.set_image_and_text(window_mode_button_converted_image, "Full/Win", window_mode_button_converted_image.height * 0.5, C_DARK_BLUE, LIGHT_NOVEL_POP_FONT_TYPE)
    window_mode_button_image.dispose
    @windowModeButton.set_pos(Window.width - (@exitButton.w + @windowModeButton.w), 0)

    name_entry_buttons_size = Window.height * 0.1
    name_entry_buttons_font_size = name_entry_buttons_size * 0.8
    name_entry_button_width_scale = name_entry_buttons_size / name_entry_button_image.width
    name_entry_button_height_scale = name_entry_buttons_size / name_entry_button_image.height
    name_entry_button_coverted_image = RenderTarget.new(name_entry_buttons_size, name_entry_buttons_size).draw_scale(0, 0, name_entry_button_image, name_entry_button_width_scale, name_entry_button_height_scale, 0, 0).to_image
    @nameEntry = NameEntry.new(0, 0, name_entry_buttons_size, name_entry_buttons_size, name_entry_buttons_font_size, C_BROWN, C_WHITE, {:fontType=>MIKACHAN_FONT_TYPE})
    @nameEntry.setPos((Window.width - @nameEntry.width) * 0.5, (Window.height - @nameEntry.height) * 0.65)
    @nameEntry.set_image_object(name_entry_button_coverted_image)
    name_entry_button_image.dispose

    decision_button_width_scale = Window.width * 0.2 / decision_button_image.width
    decision_button_height_scale = Window.height * 0.1 / decision_button_image.height
    @decisionButton = Button.new(Window.width * 0.4, Window.height * 0.85)
    @decisionButton.name = "decision_button"
    decision_button_converted_image = RenderTarget.new(Window.width * 0.2, Window.height * 0.1).draw_scale(0, 0, decision_button_image, decision_button_width_scale, decision_button_height_scale, 0, 0).to_image
    @decisionButton.set_image_and_text(decision_button_converted_image, text="決定", decision_button_converted_image.height * 0.8, C_BLACK, LIGHT_NOVEL_POP_FONT_TYPE)
    decision_button_image.dispose

    reset_button_width_scale = Window.width * 0.2 / reset_button_image.width
    reset_button_height_scale = Window.height * 0.1 / reset_button_image.height
    @resetButton = Button.new(Window.width * 0.2, Window.height * 0.85, Window.width * 0.2)
    @resetButton.name = "reset_button"
    reset_button_converted_image = RenderTarget.new(Window.width * 0.2, Window.height * 0.1).draw_scale(0, 0, reset_button_image, reset_button_width_scale, reset_button_height_scale, 0, 0).to_image
    @resetButton.set_image_and_text(reset_button_converted_image, text="リセット", reset_button_converted_image.height * 0.8, C_BLACK, LIGHT_NOVEL_POP_FONT_TYPE)

    delete_button_width_scale = Window.width * 0.2 / delete_button_image.width
    delete_button_height_scale = Window.height * 0.1 / delete_button_image.height
    @deleteButton = Button.new(Window.width * 0.6, Window.height * 0.85, Window.width * 0.2)
    @deleteButton.name = "delete_button"
    delete_button_converted_image = RenderTarget.new(Window.width * 0.2, Window.height * 0.1).draw_scale(0, 0, delete_button_image, delete_button_width_scale, delete_button_height_scale, 0, 0).to_image
    @deleteButton.set_image_and_text(delete_button_converted_image, text="一文字消す",delete_button_converted_image.height * 0.8, C_BLACK, LIGHT_NOVEL_POP_FONT_TYPE)

    @buttons = [@windowModeButton, @exitButton, @decisionButton, @resetButton, @deleteButton]

    @inputBox.string = $name

    @mouse = Sprite.new
    @mouse.collision = [0, 0]

    @poi = Poi.new(0, 0, 0.5, @mouse, nil, self)
    @poi.catch_count = POI_POINT_COUNT

    @windows = []

    @bgm.play(:loop=>true, :volume=>0.5)
  end

  def update

    if @windowModeButton.pushed? then
      if Window.windowed? then
        Window.windowed = false
      else
        Window.windowed = true
      end
      @clickSE.play
    end

    if @exitButton.pushed? then
      exit
    end

    @nameEntry.kanaButtons.each do |kanaButton|
      if kanaButton.pushed? then
        @clickSE.play
        if $name.size < MAX_NAME_INPUT_NUMBER * 2 then
          $name += kanaButton.text
          @inputBox.string = $name
        end
      end
      kanaButton.hovered?
    end

    if @decisionButton.pushed? then
      @clickSE.play
      self.did_disappear
      self.sendToDatabase
      self.next_scene = RankingScene
    end

    if @resetButton.pushed? then
      @clickSE.play
      $name = ""
      @inputBox.string = $name
    end

    if @deleteButton.pushed? then
      @clickSE.play
      if $name.size > 0 then
        $name.chop!
        @inputBox.string = $name
      end
    end

    if @buttons and not @buttons.empty? then
      @buttons.each do |button|
        button.hovered?
      end
    end

    @mouse.x, @mouse.y = Input.mouse_pos_x, Input.mouse_pos_y

    if @poi and @poi.is_drag then
      @poi.x = @mouse.x - (@poi.width * 0.5)
      @poi.y = @mouse.y - (@poi.height * 0.5)
    end

    if @poi and @poi.mode != :try_gaze then
      if (@windows.size <= POINT_COUNT_IN_WINDOW) then
        mouse_x = @poi.x + (@poi.width * 0.5)
        mouse_y = @poi.y + (@poi.width * 0.5)
        @windows.push([mouse_x, mouse_y])
      else
        @windows.shift(1)
      end

      if @windows.size >= POINT_COUNT_IN_WINDOW then
        if @poi.search_gaze_point(@windows) then
          @windows.clear
          @poi.mode = :try_gaze
          @poi.is_drag = false
        end
      end
    end

    if @poi and @poi.mode == :try_catch then
      if @nameEntry and not @nameEntry.kanaButtons.empty? then
        @nameEntry.kanaButtons.each do |kanaButton|
          if @mouse.x >= kanaButton.x and @mouse.x <= kanaButton.x + kanaButton.w and @mouse.y >= kanaButton.y and @mouse.y <= kanaButton.y + kanaButton.h then
            @clickSE.play
            if $name.size < MAX_NAME_INPUT_NUMBER * 2 then
              $name += kanaButton.text
              @inputBox.string = $name
            end
          end
        end
      end

      if @buttons and not @buttons.empty? then
        @buttons.each do |button|
          if @mouse.x >= button.x and @mouse.x <= button.x + button.w and @mouse.y >= button.y and @mouse.y <= button.y + button.h then

            case button.name

            when "exit_button"
              self.did_disappear
              exit

            when "window_mode_button"
              if Window.windowed? then
                Window.windowed = false
              else
                Window.windowed = true
              end
              @clickSE.play
              @poi.mode = :normal

            when "decision_button"
              @clickSE.play
              self.did_disappear
              # self.sendToDatabase
              self.next_scene = RankingScene

            when "reset_button"
              @clickSE.play
              $name = ""
              @inputBox.string = $name

            when "delete_button"
              @clickSE.play
              if $name.size > 0 then
                $name.chop!
                @inputBox.string = $name
              end
            end
          end
        end
      end
      @poi.mode = :normal
    end

    @poi.update if @poi
  end

  def render
    Window.draw(0, 0, @floor_image) if @floor_image
    @titleLabel.render
    @scoreLabel.render
    @exitButton.render
    @windowModeButton.render
    @nameEntry.draw
    @inputBox.render
    @decisionButton.render
    @resetButton.render
    @deleteButton.render

    @poi.draw if @poi
  end

  def sendToDatabase

    uri = URI.parse(POST_URL)
    http = Net::HTTP.new(uri.host, uri.port)

    req = Net::HTTP::Post.new(uri.path)
    req.set_form_data({:name=>$name.encode("UTF-8"), :score=>$scores[:score],
                       :cognomen=>$cognomens[:cognomen], :cognomen_color=>$cognomens[:color]})

    http.request(req)
  end

  def did_disappear
    if @bgm then
      @bgm.stop
      @bgm.free
    end
  end
end


class RankingScene < Scene::Base

  # include Common

  def init

    return_button_image = Image.load(OK_BUTTON_IMAGE)
    page_up_button_image = Image.load(PAGE_UP_BUTTON)
    page_down_button_image = Image.load(PAGE_DOWN_BUTTON)

    @background = Image.new(Window.width, Window.height).box_fill(0, 0, Window.width, Window.height, C_AQUA_MARINE)

    @titleLabel = Fonts.new(0, 0, "ランキング TOP100", Window.height * 0.07, C_DARK_BLUE)
    @titleLabel.set_pos((Window.width - @titleLabel.get_width) * 0.43, Window.height * 0.07 - (@titleLabel.get_height * 0.5))
    @titleLabel.fontType = CHECK_POINT_FONT_TYPE

    exitButtonText = "Exit"
    exitButtonHeight = Window.height * 0.03
    @exitButton = Button.new(0, 0, exitButtonHeight * exitButtonText.size * 0.5, exitButtonHeight, exitButtonText, exitButtonHeight)
    @exitButton.set_pos(Window.width - @exitButton.w, 0)

    windowModeButtonText = "Full/Window"
    windowModeButtonHeight = Window.height * 0.03
    @windowModeButton = Button.new(0, 0, windowModeButtonHeight * windowModeButtonText.size * 0.5, windowModeButtonHeight, windowModeButtonText, windowModeButtonHeight)
    @windowModeButton.set_pos(Window.width - (@exitButton.w + @windowModeButton.w), 0)

    return_button_width_scale = Window.width * 0.2 / return_button_image.width
    return_button_height_scale = Window.height * 0.1 / return_button_image.height
    @return_button = Button.new(Window.width * 0.4, Window.height * 0.85)
    @return_button.name = "return_button"
    return_button_converted_image = RenderTarget.new(Window.width * 0.2, Window.height * 0.1).draw_scale(0, 0, return_button_image, return_button_width_scale, return_button_height_scale, 0, 0).to_image
    @return_button.set_image_and_text(return_button_converted_image, text="タイトルに戻る", return_button_converted_image.height * 0.6, C_BLACK, LIGHT_NOVEL_POP_FONT_TYPE)
    return_button_image.dispose

    page_up_button_scale = Window.height * 0.15 / page_up_button_image.height
    @page_up_button = Button.new()
    @page_up_button.name = "page_up_button"
    page_up_button_converted_image = RenderTarget.new(page_up_button_image.width * page_up_button_scale, page_up_button_image.height * page_up_button_scale).draw_scale(0, 0, page_up_button_image, page_up_button_scale, page_up_button_scale, 0, 0).to_image
    @page_up_button.set_image_and_text(page_up_button_converted_image)
    @page_up_button.set_pos((Window.width - @page_up_button.w) * 0.953, (Window.height - @page_up_button.h) * 0.35)
    page_up_button_image.dispose

    page_down_button_scale = Window.height * 0.15 / page_down_button_image.height
    @page_down_button = Button.new()
    @page_down_button.name = "page_down_button"
    page_down_button_converted_image = RenderTarget.new(page_down_button_image.width * page_down_button_scale, page_down_button_image.height * page_down_button_scale).draw_scale(0, 0, page_down_button_image, page_down_button_scale, page_down_button_scale, 0, 0).to_image
    @page_down_button.set_image_and_text(page_down_button_converted_image)
    @page_down_button.set_pos((Window.width - @page_down_button.w) * 0.95, (Window.height - @page_down_button.h) * 0.65)
    page_down_button_image.dispose

    @clickSE = Sound.new(CLICK_SE)

    bubble_scale_up_speed_min = 1
    bubble_scale_up_speed_max = bubble_scale_up_speed_min * 1.004
    bubble_accel_min = 0.005
    bubble_accel_max = bubble_accel_min * 10
    bubble_amplification_speed_min = 1
    bubble_amplification_speed_max = bubble_amplification_speed_min * 10
    bubble_angular_velo_up_speed_min = 1
    bubble_angular_velo_up_speed_max = bubble_angular_velo_up_speed_min * 10

    @bubbles = []
    700.times do
      bubble = Bubble.new(-1 * Window.height * 0.5, [0, 0], [0, 0], [bubble_scale_up_speed_min, bubble_scale_up_speed_max],
                          [bubble_accel_min, bubble_accel_max], [bubble_amplification_speed_min, bubble_amplification_speed_max],
                          [bubble_angular_velo_up_speed_min, bubble_angular_velo_up_speed_max])
      bubble.set_x([-1 * bubble.width * Math.sqrt(2), Window.width + (bubble.width * Math.sqrt(2))])
      bubble.set_y([Window.height + bubble.height, Window.height * 1.5])
      @bubbles.push(bubble)
    end

    # self.makeResultLabel
    self.temp
  end

  def temp
    items = [["100位", "非常勤講師おなに", "100000点", "スーパーカブ", "2020年12月20日 21時36分19秒"], ["2位", "アルバイト募集", "1000点", "金魚人", "2020年12月20日 21時36分19秒"],
             ["3位", "ちづる?", "100点", "レジェンドン", "2020年12月20日 21時36分19秒"], ["4位", "神じゃね？", "10点", "スーパーカブ", "2020年12月20日 21時36分19秒"],
             ["5位", "落ちこぼれ野郎", "1点", "良しヲくん", "2020年12月20日 21時36分19秒"]]

    hex_codes = ["00FFFF", "FFFF00", "008000", "FFA500", "FFA500"]

    colors = []
    hex_codes.each do |hex_code|
      colors.push(hex_to_rgb(hex_code.hex).values)
    end

    @list_box = ScoreListBox.new(250, 150, Window.width - 500, Window.height - 350)
    @list_box.set_items(items, [2, 5, 4, 3, 5], C_ROYAL_BLUE, colors, 3, MIKACHAN_FONT_TYPE)
  end

  def loadFromDatabase

    uri = URI.parse(GET_URL)

    # 第2引数にHashを指定することでPOSTする際のデータを指定出来る
    response = Net::HTTP.post_form(uri, {})

    jsons = JSON.parse(response.body)

    raws = []
    results = []

    for json in jsons do
      raws << json["name"].to_s.encode("Shift_JIS")
      raws << json["score"].to_s
      raws << json["cognomen"].to_s.encode("Shift_JIS")
      raws << json["cognomen_color"].to_s
      raws << Time.parse(json["created_at"]).strftime("%Y年%m月%d日 %H時%M分%S秒")
      results << raws
      raws = []
    end
    return results
  end

  def update

    if @windowModeButton.pushed? then
      if Window.windowed? then
        Window.windowed = false
      else
        Window.windowed = true
      end
      @clickSE.play
    end

    if @exitButton.pushed? then
      exit
    end

    if @return_button.pushed? then
      @clickSE.play
      self.next_scene = TitleScene
    end
    @return_button.hovered?

    @list_box.update

    if @page_up_button.pushed? then
      @clickSE.play
      @list_box.scroll_up
    end
    @page_up_button.hovered?

    if @page_down_button.pushed? then
      @clickSE.play
      @list_box.scroll_down
    end
    @page_down_button.hovered?

    @bubbles.each do |bubble|
      bubble.update
    end
  end

  def render

    Window.draw(0, 0, @background) if @background

    @bubbles.each do |bubble|
      bubble.draw
    end

    @list_box.draw

    @titleLabel.render
    @exitButton.render
    @windowModeButton.render
    @return_button.render

    @page_up_button.render
    @page_down_button.render

    if @rankLabels and not @rankLabels.empty? then
      for rankLabel in @rankLabels do
        rankLabel.render
      end
    end

    if @nameLabels and not @nameLabels.empty? then
      for nameLabel in @nameLabels do
        nameLabel.render
      end
    end

    if @scoreLabels and not @scoreLabels.empty? then
      for scoreLabel in @scoreLabels do
        scoreLabel.render
      end
    end

    if @datetimeLabels and not @datetimeLabels.empty? then
      for datetimeLabel in @datetimeLabels do
        datetimeLabel.render
      end
    end
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

  BASE_FONT_SIZE = 64
  FONT_SHADOW_OFF_SET_X = 3
  FONT_SHADOW_OFF_SET_Y = 3
  BASE_Y_INTERVAL = 100

  BGM_TIME = 89
  MAX_NEXT_SCENE_WAIT_COUNT = 240
  ILLUST_RELATIVE_SCALES = [0.2, 0.15, 0.2, 0.25, 0.4, 0.27]
  ILLUST_MAX_NUMBER = 13
  NUMBER_OF_ILLUST = 6

  def init

    staff_datas = csvReadArray(STAFF_DATA_FILE)

    @sprite_fonts = []
    sum_interval = 0

    staff_datas.each do |staff_data|
      sprite_font = SpriteFont.new(0, 0, staff_data[0], BASE_FONT_SIZE * staff_data[1].to_f, hex_to_rgb(staff_data[2].hex).values,
                                   C_DEFAULT, {:font_name=>staff_data[3], :shadow=>true, :shadow_color=>C_SHADOW,
                                               :shadow_x=>FONT_SHADOW_OFF_SET_X, :shadow_y=>FONT_SHADOW_OFF_SET_Y})
      sum_interval += BASE_Y_INTERVAL * staff_data[4].to_f
      sprite_font.set_pos((Window.width - sprite_font.width) * 0.5, Window.height + sum_interval)
      @sprite_fonts.push(sprite_font)
    end

    max_scroll_range = @sprite_fonts[-1].y + (Window.height + @sprite_fonts[-1].height) * 0.6
    @scroll_speed = max_scroll_range / BGM_TIME / 60

    background_image = Image.load(BACKGROUND_IMAGE)
    @background_image = Images.fit_resize(background_image, Window.width, Window.height)

    @illusts = []
    ILLUST_MAX_NUMBER.times do
      illust_number = rand(NUMBER_OF_ILLUST)
      relative_size = Window.height * ILLUST_RELATIVE_SCALES[illust_number]
      illust = Illust.new(illust_number, relative_size, [0, 0, Window.width, Window.height])
      @illusts.push(illust)
    end

    @bgm = Bass.loadSample(ENDING_BGM)
    @bgm.play(:loop=>false, :volume=>0.8)

    @next_scene_wait_count = 0
  end

  def update

    if @sprite_fonts[-1].y <= (Window.height - @sprite_fonts[-1].height) * 0.6 then
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

    @illusts.each do |illust|
      illust.update
    end
  end

  def render

    Window.draw(0, 0, @background_image)

    @illusts.each do |illust|
      illust.draw
    end

    @sprite_fonts.each do |sprite_font|
      sprite_font.draw
    end
  end
end


Scene.main_loop TitleScene, $config.fps, $config.frame_step


=begin
# win32_open3 example
# Try each command as you like...
cmd = "dir /w"

Open3.popen3(cmd) do |io_in, io_out, io_err|
  error = io_err.read
  if error && error.length > 0
    puts 'Error: ' + error
    break
  else
    # puts io_in.write("hoge")
    output = io_out.read
    puts 'Output: ' + output if output
  end
end
=end
