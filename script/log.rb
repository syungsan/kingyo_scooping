#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

# log.rb Ver 1.0

require "dxruby"

if __FILE__ == $0
  Dir.chdir("#{Dir.pwd}/../")
  require "./lib/files"
end


class Log

  attr_reader :startDate, :startDatetime
  attr_accessor :parent_dir

  include Files

  def initialize
    @startDate = Time.now.strftime("%Y.%m.%d")
    @startDatetime = Time.now.strftime("%Y.%m.%d_%H.%M.%S")
    @parent_dir = ""
  end

  # 記録の前にログファイルを設定することを忘れずに
  def setLog(dir, file="")
    @dir = dir
    @file = file
    makeDirNotExist(@dir)
    @path = "#{@dir}/#{@file}"
  end

  def write(data)
    csvWriteArray(@path, data) if data.class == Array
    file_write(@path, data) if data.class == String
  end

  def add(data)
    csvAddArray(@path, data) if data.class == Array
    file_add(@path, data) if data.class == String
  end

  def read(dir=@dir, file=@file)
    path = "#{dir}/#{file}"
    csvReadArray(path)
  end

  # スクリーンショット保存
  def screenShot(dir=@dir, file="test.png", target=Window)
    makeDirNotExist(dir)
    path = "#{dir}/#{file}"
    target.getScreenShot(path)
  end
end
