#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE = "s"
require "jcode"

# log.rb Ver 1.0

require "dxruby"


class Log

  attr_reader :start_date, :start_date_time
  attr_accessor :parent_dir

  if __FILE__ == $0
    require "../lib/files"
  else
    require "./lib/files"
  end

  include Files

  def initialize
    @start_date = Time.now.strftime("%Y.%m.%d")
    @start_date_time = Time.now.strftime("%Y.%m.%d_%H.%M.%S")
    @parent_dir = ""
  end

  # 記録の前にログファイルを設定することを忘れずに
  def set_log(dir, file="")
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
  def screen_shot(dir=@dir, file="test.png", target=Window)
    makeDirNotExist(dir)
    path = "#{dir}/#{file}"
    target.get_Screen_shot(path)
  end
end
