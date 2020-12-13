class Image

  def roundbox(x1, y1, x2, y2, r, c)
    image = Image.new(r * 2, r * 2).circle(r, r, r, c)
    self.draw(x1, y1, image, 0, 0, r, r)
    self.draw(x2 - r, y1, image, r, 0, r, r)
    self.draw(x1, y2 - r, image, 0, r, r, r)
    self.draw(x2 - r, y2 - r, image, r, r, r, r)
    self.line(x1 + r, y1, x2 - r, y1, c)
    self.line(x2, y1 + r, x2, y2 - r, c)
    self.line(x2 - r, y2, x1 + r, y2, c)
    self.line(x1, y1 + r, x1, y2 - r, c)
    image.dispose
    self
  end

  def roundbox_fill(x1, y1, x2, y2, r, c)
    image = Image.new(r * 2, r * 2).circle_fill(r, r, r, c)
    self.draw(x1, y1, image, 0, 0, r, r)
    self.draw(x2 - r, y1, image, r, 0, r, r)
    self.draw(x1, y2 - r, image, 0, r, r, r)
    self.draw(x2 - r, y2 - r, image, r, r, r, r)
    self.box_fill(x1 + r, y1, x2 - r, y2, c)
    self.box_fill(x1, y1 + r, x2, y2 - r, c)
    image.dispose
    self
  end
end
