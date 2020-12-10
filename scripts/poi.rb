#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

require "dxruby"

if __FILE__ == $0 then
  POI_FRAME_IMAGE = "../images/poi_frame.png"
  POI_SHADOW_IMAGE = "../images/poi_frame_shadow.png"
  POI_PAPER_NORMAL_IMAGE = "../images/poi_paper_0.png"
  POI_PAPER_BREAK_IMAGE = "../images/poi_paper_1.png"
else
  POI_FRAME_IMAGE = "./images/poi_frame.png"
  POI_SHADOW_IMAGE = "./images/poi_frame_shadow.png"
  POI_PAPER_NORMAL_IMAGE = "./images/poi_paper_0.png"
  POI_PAPER_BREAK_IMAGE = "./images/poi_paper_1.png"
end

POI_SHADOW_OFFSET_X = 5
POI_SHADOW_OFFSET_Y = 5

POI_PAPER_OFFSET_RATIO_X = 0.03
POI_PAPER_OFFSET_RATIO_Y = 0.03


class Poi <Sprite

  attr_accessor :id, :name, :is_drag
  attr_reader :width, :height

  def initialize(x, y, scale=1, id=0, target=Window, is_drag=true)
    super()

    poi_frame_image = Image.load(POI_FRAME_IMAGE)
    poi_shadow_image0 = Image.load(POI_SHADOW_IMAGE)
    poi_shadow_image = poi_shadow_image0.flush([64, 0, 0, 0])
    poi_paper_normal_image = Image.load(POI_PAPER_NORMAL_IMAGE)
    poi_paper_break_image = Image.load(POI_PAPER_BREAK_IMAGE)

    poi_images = [poi_frame_image, poi_shadow_image, poi_paper_normal_image, poi_paper_break_image]

    @poi_images = []
    poi_images.each do |poi_image|
      render_target = RenderTarget.new(poi_image.width * scale, poi_image.height * scale)
      render_target.draw_scale(poi_image.width * (scale - 1.0) * 0.5, poi_image.height * (scale - 1.0) * 0.5, poi_image, scale, scale)
      @poi_images.push(render_target.to_image)
      render_target.dispose
    end

    self.x = x
    self.y = y
    self.image = @poi_images[2]
    @width = self.image.width
    @height = self.image.height
    # self.collision = [0, 0, @width, @height]
    self.target = target
    @id = id
    @name = "poi"
    @is_drag = is_drag
  end

  def draw
    self.target.draw(self.x + POI_SHADOW_OFFSET_X, self.y + POI_SHADOW_OFFSET_Y, @poi_images[1])
    self.target.draw_ex(self.x + (@poi_images[0].width * POI_PAPER_OFFSET_RATIO_X), self.y + (@poi_images[0].height * POI_PAPER_OFFSET_RATIO_Y), self.image, :alpha=>128)
    self.target.draw(self.x, self.y, @poi_images[0])
  end
end


if __FILE__ == $0 then

  def mouseProcess

    oldX, oldY = @mouse.x, @mouse.y
    @mouse.x, @mouse.y = Input.mouse_pos_x, Input.mouse_pos_y

    # ボタンを押したら判定
    if Input.mouse_push?(M_LBUTTON)
      @charas.each_with_index do |obj, i|
        if @mouse === obj

          # Write your code. when mouse push. #####

          # オブジェクトをクリックできたら並べ替えとitem設定
          @charas.delete_at(i)
          @item = obj
          break
        end
      end
    end

    # ボタンを押している間の処理
    if Input.mouse_down?(M_LBUTTON)
      if @item then

        # Write your code. when mouse down. #####

        if @item.is_drag then
          @item.x += @mouse.x - oldX
          @item.y += @mouse.y - oldY
        end
      end
    else
      if @item then
        if @mouse === @item then

          # Write your code. when mouse release. #####

        end
        # ボタンが離されたらオブジェクトを解放
        @charas.unshift(@item)
        @item = nil
      end
    end
  end

  Window.width = 1920
  Window.height = 1080

  poi = Poi.new(0, 0, 0.5)

  @item = nil
  @charas = [poi]

  @mouse = Sprite.new
  @mouse.collision = [0, 0]

  Window.bgcolor = C_GREEN
  Window.loop do

    mouseProcess

    Sprite.update(@charas)
    Sprite.check(@charas)
    Sprite.check(@item, @charas) if @item

    if not @charas.empty? then
      @charas.reverse.each do |obj|
        obj.draw if not obj.nil?
      end
    end
    Sprite.draw(@item) if @item
  end
end
