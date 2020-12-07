#! ruby -Ks
# -*- mode:ruby; coding:shift_jis -*-
$KCODE= "s"
require "jcode"

# excel.rb Ver 1.0
# Excel操作ライブラリ

require "win32ole"


module Excel

  def open_excel_workbook(filename)

    filename = self.get_absolute_path(filename)

    xl = WIN32OLE.new("Excel.Application")

    xl.Visible = false

    # 上書きメッセージを抑制
    xl.displayAlerts = false

    book = xl.Workbooks.Open(filename)

    begin
      yield book
    ensure
      # puts "Excel内エラー発生"
      xl.Workbooks.Close
      xl.Quit
    end
  end

  def get_absolute_path(filename)

    fso = WIN32OLE.new("Scripting.FileSystemObject")
    return fso.GetAbsolutePathName(filename)
  end
end


module Worksheet

  def [] y, x

    cell = self.Cells.Item(y, x)

    if cell.MergeCells
      cell.MergeArea.Item(1, 1).Value
    else
      cell.Value
    end
  end

  def []= y, x, value

    cell = self.Cells.Item(y, x)

    if cell.MergeCells
      cell.MergeArea.Item(1, 1).Value = value
    else
      cell.Value = value
    end
  end
end
