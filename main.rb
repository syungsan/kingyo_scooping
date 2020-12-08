#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

# Templete Project main.rb Ver 1.2

# exerb�Ōł߂�exe����N������Ƃ��J�����g�f�B���N�g����exe�̃p�X�ɂ���l�I
if defined?(ExerbRuntime)
  Dir.chdir(File.dirname(ExerbRuntime.filepath))
end

# ���̎��s�X�N���v�g�̂���f�B���N�g���Ɉړ�
Dir.chdir(File.expand_path("..", __FILE__))

# �e�탉�C�u�����̏ꏊ�ꊇ�ݒ�
$LOAD_PATH.push("./lib", "./scripts", "./lib/dxruby", "./lib/audio")

# �g�p���Ȃ����C�u�����̓R�����g�A�E�g
require "dxruby" # DXRuby�{��
require "display" # �f�B�X�v���C���擾
require "scene" # ��ʑJ��
require "fonts" # ���x���쐬
require "button" # �{�^���쐬
require "color" # �J���[���i���W���[���Ȃ̂ŗvinclude�j
require "ui" # ���̑��̃��[�U�C���^�t�F�[�X
require "files" # �t�@�C������i���W���[���Ȃ̂ŗvinclude�j log.rb���g���Ƃ����K�v
# require "images" # �摜�I�u�W�F�N�g���
# require "common" # Ruby�ėp���C�u�����i���W���[���Ȃ̂ŗvinclude�j
# require "excel" # Excel����p
# require "sqlite3" # �f�[�^�x�[�X
# require "weighted_randomizer" # �d�ݕt������
# require "encode" # �����R�[�h�ϊ�
# require "json/pure" # JSON
# require "linear_algebra" # ���`�㐔
# require "win32/open3" # �O���R�}���h���s

# Audio��͊֘A
# require "wav-file"
# require "mciver3"
# require "wav_analyze"

# mp3�Ȃǂ�炷����
=begin
Dir.chdir("./lib/dxruby") do
  require "Bass"
end
=end

# �V�X�e���E�p�����[�^ #################################################################################################
# �A�v���P�[�V�����ݒ�
APPLICATION_NAME = "���̃A�v���P�[�V����"
COPYLIGHT = "Powered by Ruby & DXRuby."
VERSION_NUMBER = "0.8"
# APPLICATION_ICON =

FPS = 60
FRAME_STEP = 1
FRAME_SKIP = true
WINDOWED = true

# �����̃E�B���h�E�J���[�icolor.rb�Q�Ɓj
include Color
DEFAULT_BACK_GROUND_COLER = C_WHITE

# ��ʃT�C�Y�̃��C�h���ƃX�N�G�A���̑I�����idisplay.rb�Q�Ɓj
include Display
WINDOW_WIDE_SIZE = HD
WINDOW_SQUARE_SIZE = XGA

# �N�����ɃE�B���h�E����ʒ����ɕ\������
IS_WINDOW_CENTER = true

# ���O���L�^���邩�ǂ���
IS_LOG = false

if IS_LOG then
  require "log"

  # ���O���^�t�H���_�̏ꏊ
  LOG_DIR = "./log"
end
########################################################################################################################
# ���O���̓_�C�A���O�\�� ##################################################################################################
IS_NAME_INPUT = false

if IS_NAME_INPUT then
  require "input_dialog"
  mes = VRLocalScreen.modalform(nil, nil, InputDialog)

  exit if not mes or mes == "Cancel"
else
  $user_name = "noname"
end
########################################################################################################################
# �Q�[���E�p�����[�^ ###################################################################################################
# ��
CLICK_SE = "./sounds/push13.wav"

# �摜
# IMAGE = ""

# �t�H���g
# FONT = ""

# �t�H���g�̃C���X�g�[��
# Font.install(FONT)
########################################################################################################################
########################################################################################################################
initWindowRect = setDisplay(WINDOW_WIDE_SIZE, WINDOW_SQUARE_SIZE, IS_WINDOW_CENTER)
if initWindowRect[:windowX] and initWindowRect[:windowY] then
  windowX, windowY = initWindowRect[:windowX], initWindowRect[:windowY]
  Window.x = windowX
  Window.y = windowY
end
$is_square = initWindowRect[:isSquare]

Window.width  = initWindowRect[:windowWidth]
Window.height = initWindowRect[:windowHeight]
Window.caption = "#{APPLICATION_NAME} Ver#{VERSION_NUMBER}"
# Window.loadIcon(APPLICATION_ICON)
Window.bgcolor = DEFAULT_BACK_GROUND_COLER
Window.frameskip = FRAME_SKIP
Window.windowed = WINDOWED
########################################################################################################################


# �^�C�g���E�V�[��
class TitleScene < Scene::Base

  @@clickSE = Sound.new(CLICK_SE)

  def init

    # �K�v�ŏ����̃O���[�o���ϐ���������
    # $score, $userName�Ȃǁc

    # IS_LOG�t���O�̓��O���L�^���邷�ׂĂ̏ꏊ�ɕt����
    if IS_LOG then
      $log = Log.new # ���O�I�u�W�F�N�g����

      # ���ɓ`���I�ȃ��O�t�@�C���̃p�X��ݒ肷��ƂƂ��Ƀ��O�t�H���_�̍쐬�i�����ŔC�ӂ̃t�H���_�ƃt�@�C�������w��j
      $log.setLog("#{LOG_DIR}/#{$log.startDate}", "#{APPLICATION_NAME}_#{$log.startDatetime}.csv")

      # $log.parent_dir = "#{LOG_DIR}/#{$log.startDate}/#{APPLICATION_NAME}_Ver#{VERSION_NUMBER}_#{$user_name}_#{$log.startDatetime}"
      # $log.setLog($log.parent_dir)
    end
    # ���O�t�@�C����path�̍쐬�Ƀ��O�N���X�̃����o�ϐ�startDate, startDateTime, parent_dir���Q�Ƃł���

    @titleLabel = Fonts.new(0, 0, APPLICATION_NAME, Window.height * 0.1, C_BLACK)
    @versionNumberLabel = Fonts.new(0, 0, "Version #{VERSION_NUMBER}", @titleLabel.get_height * 0.3, C_BLACK)
    @copyLightLabel = Fonts.new(0, 0, COPYLIGHT, Window.height * 0.05, C_BLACK)

    startButtonText = "�X�^�[�g"
    startButtonHeight = Window.height * 0.05
    @startButton = Button.new(0, 0, startButtonHeight * startButtonText.size * 0.5, startButtonHeight, startButtonText, startButtonHeight)

    exitButtonText = "Exit"
    exitButtonHeight = Window.height * 0.03
    @exitButton = Button.new(0, 0, exitButtonHeight * exitButtonText.size * 0.5, exitButtonHeight, exitButtonText, exitButtonHeight)

    windowModeButtonText = "Full/Window"
    windowModeButtonHeight = Window.height * 0.03
    @windowModeButton = Button.new(0, 0, windowModeButtonHeight * windowModeButtonText.size * 0.5, windowModeButtonHeight, windowModeButtonText, windowModeButtonHeight)

    changeWindowSizeTexts = ["���C�h���", "�X�N�E�F�A���"]
    @changeWindowSizeLabels = []
    @radioButtons = []

    2.times do |index|
      changeWindowSizeLabel = Fonts.new(0, 0, changeWindowSizeTexts[index], Window.height * 0.03, C_BLACK)
      @changeWindowSizeLabels << changeWindowSizeLabel
      radioButton = RadioButton.new(0, 0, index)
      @radioButtons << radioButton
    end
    @radioButtons[$is_square].setCheck(true)

    # Write your code...

    self.setPosition
  end

  def setPosition

    @titleLabel.set_pos((Window.width - @titleLabel.get_width) * 0.5, (Window.height - @titleLabel.get_height) * 0.2)
    @versionNumberLabel.set_pos(@titleLabel.x + @titleLabel.get_width - @versionNumberLabel.get_width, @titleLabel.y + @titleLabel.get_height)
    @copyLightLabel.set_pos((Window.width - @copyLightLabel.get_width) * 0.5, (Window.height - @copyLightLabel.get_height) * 0.9)
    @startButton.set_pos((Window.width - @startButton.w) * 0.5, (Window.height - @startButton.h) * 0.7)
    @exitButton.set_pos(Window.width - @exitButton.w, 0)
    @windowModeButton.set_pos(Window.width - (@exitButton.w + @windowModeButton.w), 0)

    2.times do |index|
      @changeWindowSizeLabels[index].set_pos(Window.width * 0.03, Window.height * 0.9 + (Window.height * 0.05 * index))
      @radioButtons[index].setPos(Window.width * 0.01, Window.height * 0.9 + (Window.height * 0.05 * index))
    end

    # Write your code...
  end

  def update

    if @startButton.pushed?
      @@clickSE.play
      self.next_scene = GameScene
    end

    if @windowModeButton.pushed? then
      if Window.windowed? then
        Window.windowed = false
      else
        Window.windowed = true
      end
      @@clickSE.play
    end

    if @exitButton.pushed? or Input.key_push?(K_ESCAPE) then
      exit
    end

    # ���W�I�{�^���̔r������ ##########
    checkID = nil
    for radioButton in @radioButtons do
      if radioButton.checked? then
        @@clickSE.play
        checkID = radioButton.id

        case checkID
        when 0 then
          Window.resize(WINDOW_WIDE_SIZE[0], WINDOW_WIDE_SIZE[1])
          $is_square = 0
          self.setPosition
        when 1 then
          Window.resize(WINDOW_SQUARE_SIZE[0], WINDOW_SQUARE_SIZE[1])
          $is_square = 1
          self.setPosition
        end
      end
    end

    if checkID then
      for radioButton in @radioButtons do
        unless radioButton.id == checkID then
          radioButton.setCheck(false)
        end
      end
    end
    ###################################

    # Write your code...
  end

  def render
    @titleLabel.render
    @versionNumberLabel.render
    @copyLightLabel.render
    @startButton.render
    @exitButton.render
    @windowModeButton.render

    2.times do |index|
      @radioButtons[index].draw
      @changeWindowSizeLabels[index].render
    end

    # Write your code...
  end
end


# �Q�[���E�V�[��
class GameScene < Scene::Base

  @@clickSE = Sound.new(CLICK_SE)

  def init

    exitButtonText = "Exit"
    exitButtonHeight = Window.height * 0.03
    @exitButton = Button.new(0, 0, exitButtonHeight * exitButtonText.size * 0.5, exitButtonHeight, exitButtonText, exitButtonHeight)
    @exitButton.set_pos(Window.width - @exitButton.w, 0)

    windowModeButtonText = "Full/Window"
    windowModeButtonHeight = Window.height * 0.03
    @windowModeButton = Button.new(0, 0, windowModeButtonHeight * windowModeButtonText.size * 0.5, windowModeButtonHeight, windowModeButtonText, windowModeButtonHeight)
    @windowModeButton.set_pos(Window.width - (@exitButton.w + @windowModeButton.w), 0)

    # �L�����N�^�E�X�v���C�g�̃}�E�X�C�x���g����������ꍇ�̓R�����g�O��
=begin
    # ���܃}�E�X�Œ͂�ł�I�u�W�F�N�g
    @item = nil

    # �L�����N�^���I�u�W�F�N�g�z��ɒǉ�
    @charas = []

    # �}�E�X�J�[�\���̏Փ˔���p�X�v���C�g
    @mouse = Sprite.new
    @mouse.collision = [0, 0]
=end
=begin
    # ���O�̏������݂Ɠǂݍ��݂̃e�X�g
    if IS_LOG then
      data = [1, 2, 3, 4]
      $log.write(data)
      $log.setLog("#{LOG_DIR}/#{$log.startDate}/sub", "test.csv")
      $log.write(data)
      $log.screenShot
      $log.add(data)
      p $log.read
    end
=end

    # Write your code...
  end

  def update

    if @windowModeButton.pushed? then
      if Window.windowed? then
        Window.windowed = false
      else
        Window.windowed = true
      end
      @@clickSE.play
    end

    if @exitButton.pushed? or Input.key_push?(K_ESCAPE) then
      exit
    end

    # �L�����N�^�E�X�v���C�g�̃}�E�X�C�x���g����������ꍇ�̓R�����g�O��
=begin
    self.mouseProcess

    Sprite.update(@charas)
    Sprite.check(@charas)

    Sprite.check(@item, @charas) if @item
=end

    # Write your code...
  end

  def render

    @exitButton.render
    @windowModeButton.render

    # �L�����N�^�E�X�v���C�g�̃}�E�X�C�x���g����������ꍇ�̓R�����g�O��
=begin
     # �L�����N�^�E�X�v���C�g�̃}�E�X�C�x���g����������ꍇ�̓R�����g�O��
    if not @charas.empty? then
      @charas.reverse.each do |obj|
        obj.draw if not obj.nil?
      end
    end

    Sprite.draw(@item) if @item
=end

    # Write your code...
  end

  # �L�����N�^�E�X�v���C�g�̃}�E�X�C�x���g����������ꍇ�̓R�����g�O��
=begin
  def mouseProcess

    oldX, oldY = @mouse.x, @mouse.y
    @mouse.x, @mouse.y = Input.mouse_pos_x, Input.mouse_pos_y

    # �{�^�����������画��
    if Input.mouse_push?(M_LBUTTON)
      @charas.each_with_index do |obj, i|
        if @mouse === obj

          # Write your code. when mouse push. #####

          # �I�u�W�F�N�g���N���b�N�ł�������בւ���item�ݒ�
          @charas.delete_at(i)
          @item = obj
          break
        end
      end
    end

    # �{�^���������Ă���Ԃ̏���
    if Input.mouse_down?(M_LBUTTON)
      if @item then

        # Write your code. when mouse down. #####

        if @item.isDrag then
          @item.x += @mouse.x - oldX
          @item.y += @mouse.y - oldY
        end
      end
    else
      if @item then
        if @mouse === @item then

          # Write your code. when mouse release. #####

        end
        # �{�^���������ꂽ��I�u�W�F�N�g�����
        @charas.unshift(@item)
        @item = nil
      end
    end
  end
=end
end

Scene.main_loop TitleScene, FPS, FRAME_STEP

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
