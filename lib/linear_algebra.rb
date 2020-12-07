class Vector
  def initialize(*v)
    @vec = v
  end

  def rotate(angle)
    x = @vec[0] * Math.cos(Math::PI / 180 * angle) - @vec[1] * Math.sin(Math::PI / 180 * angle)
    y = @vec[0] * Math.sin(Math::PI / 180 * angle) + @vec[1] * Math.cos(Math::PI / 180 * angle)
    temp = @vec.dup
    temp[0] = x
    temp[1] = y
    Vector.new(*temp)
  end

  def +(v)
    case v
    when Vector
      Vector.new(*@vec.map.with_index{|s,i|s+v[i]})
    when Array
      Vector.new(*@vec.map.with_index{|s,i|s+v[i]})
    when Numeric
      Vector.new(*@vec.map{|s|s+v})
    else
      nil
    end
  end

  def *(matrix)
    result = []
    for i in 0..(matrix.size-1)
      data = 0
      for j in 0..(@vec.size-1)
        data += @vec[j] * matrix[j][i]
      end
      result.push(data)
    end
    return Vector.new(*result)
  end

  def [](i)
    @vec[i]
  end

  def size
    @vec.size
  end

  def to_a
    @vec
  end

  def x
    @vec[0]
  end
  def y
    @vec[1]
  end
  def z
    @vec[2]
  end
  def w
    @vec[3]
  end
end

class Matrix
  def initialize(*arr)
    @arr = Array.new(4) {|i| Vector.new(*arr[i])}
  end

  def *(a)
    result = []
    for i in 0..(a.size-1)
      result.push(@arr[i] * a)
    end
    return Matrix.new(*result)
  end

  def [](i)
    @arr[i]
  end

  def size
    @arr.size
  end

  def self.create_rotation_z(angle)
    cos = Math.cos(Math::PI/180 * angle)
    sin = Math.sin(Math::PI/180 * angle)
    return Matrix.new(
        [ cos, sin, 0, 0],
        [-sin, cos, 0, 0],
        [   0,   0, 1, 0],
        [   0,   0, 0, 1]
    )
  end

  def self.create_rotation_x(angle)
    cos = Math.cos(Math::PI/180 * angle)
    sin = Math.sin(Math::PI/180 * angle)
    return Matrix.new(
        [   1,   0,   0, 0],
        [   0, cos, sin, 0],
        [   0,-sin, cos, 0],
        [   0,   0,   0, 1]
    )
  end

  def self.create_rotation_y(angle)
    cos = Math.cos(Math::PI/180 * angle)
    sin = Math.sin(Math::PI/180 * angle)
    return Matrix.new(
        [ cos,   0,-sin, 0],
        [   0,   1,   0, 0],
        [ sin,   0, cos, 0],
        [   0,   0,   0, 1]
    )
  end

  def self.create_transration(x, y, z)
    return Matrix.new(
        [   1,   0,   0,   0],
        [   0,   1,   0,   0],
        [   0,   0,   1,   0],
        [   x,   y,   z,   1]
    )
  end

  def to_a
    @arr.map {|v|v.to_a}.flatten
  end
end
