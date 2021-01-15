#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

# files.rb Ver 1.0
# 汎用ファイル・オペレーション・モジュール

require "fileutils"
require "csv"


# 追記をサポートするように改造。
class << CSV
  alias_method( :open_org, :open )

  def open( path, mode, fs=nil, rs=nil, &block )
    if mode == "a" || mode == "ab"
      open_writer( path, mode, fs, rs, &block)
    else
      open_org( path, mode, fs=nil, rs=nil, &block )
    end
  end
end


module Files

  # ==========普通のファイル関係（文字列読み書き）==========

  # fileを作成（既存のfileに上書きしたいとき）
  def file_write(filename, data)
    f = File::open("#{filename}","w")
    f.puts "#{data}"
    f.close
  end
  
  # 既存のfileに追加したいとき
  def file_add(filename, data)
    f = File::open("#{filename}", "a")
    f.puts "#{data}"
    f.close
  end
  
  # 既存のfileを読み込み配列を返す
  def file_read(filename, num=0)
    array = []
    open(filename) do |file|
      while l = file.gets
        array.push l.chomp.split(",") if num == 0 # 1行を1配列とし2重配列を作成（基本はこれ）
        array.push l.chomp if num == 1 # 1行に1文字列しかない場合はこれ
        array.push l.chomp.split(//s) if num == 2 # 1行に1文字列しかなく一文字ごとに分けたい場合はこれ
      end
    end
    return array
  end
  
  # 既存のfileを読み込み指定した要素の数を返す
  def file_search(filename, data)
    array = []
    open(filename) do |file|
      while l = file.gets
        array.push l.chomp.split(",")
      end
    end
    
    element=0
    for i in 0...array.size
      if array[i].include?(data)
        element += 1
      end
      # 二重配列で書く場合は「どの配列の何番目にあるのか」を知りたいとき
      # for j in 0...array[i].size
      #   if array[i][j] == images
      #     element += 1
      #   end
      # end
    end
    return element
  end
  
  # 既存のfileを読み込み指定の行の平均値を返す（数字の文字列を取得する場合）
  def file_mean(filename, line)
    array = []
    open(filename) do |file|
      while l = file.gets
        array.push l.chomp.split(",")
      end
    end
    
    mean = 0.000
    for i in 0...array.size
      mean = mean + array[i][line].to_i * 1.000
    end
    mean = mean * 1.000 / array.size * 1.000
    return mean
  end

  # ファイルが空かどうか調べる
  def fileIsEmpty?(filename)
    file = open(filename) do |file|
      if file.gets == nil then
        empty = true
      else
        empty = false
      end
      return empty
    end
    file.close
  end

  # ファイルの中身を消去する
  def fileClear(filename)
    File.open(filename,'w') do |file|
      file = nil
    end
  end

  # 深い階層のフォルダも一気に作成
  def makeDirNotExist(dirPath)
    FileUtils.mkdir_p(dirPath) unless FileTest.exist?(dirPath)
  end

  # ==========CSV操作関連（配列読み書き）==========

  # CSVファイルに一次元配列をカンマ区切りで一行上書き入力
  def csvWriteArray(filename, array)
    CSV.open(filename, "w") do |csv|
      csv << array
    end
  end

  # CSVファイルに一次元配列をカンマ区切りで一行追加入力
  def csvAddArray(filename, array)
    CSV.open(filename, "a") do |csv|
      csv << array
    end
  end

  # CSVファイル全体を読み込んで二次元配列を返す
  def csvReadArray(filename)
    dataList = CSV.read(filename)
    return dataList
  end

  # CSVファイルからインデックスで指定して全体の任意の行を取り出す
  def csvReadIndexArray(filename, first, last)
    dataList = CSV.read(filename).map{ |raw| raw[first, last]}
    return dataList
  end
end
