# Excel操作ライブラリ
# 参照元 : https://www.trail4you.com/TechNote/Ruby/excel_ole.html

#! ruby -Ks            # ← Ruby 1.9系では -ESJIS
require 'jcode'        # ← Ruby 1.9系では不要
require 'kconv'        # ← Ruby 1.9系では不要
$KCODE='s'             # ← Ruby 1.9系では不要

require 'win32ole'

##----- Excel module -------------------------------
module Worksheet

  def [] y,x
    cell = self.Cells.Item(y,x)
    if cell.MergeCells
      cell.MergeArea.Item(1,1).Value
    else
      cell.Value
    end
  end

  def []= y,x,value
    cell = self.Cells.Item(y,x)
    if cell.MergeCells
      cell.MergeArea.Item(1,1).Value = value
    else
      cell.Value = value
    end
  end

  def color(y,x)
    self.Cells.Item(y,x).interior.colorindex
  end

  def set_color(y,x,color)
    self.Cells.Item(y,x).interior.colorindex = color
  end

  def set_range_color(y1,x1,y2,x2,color)
    r = r_str(y1,x1)+':'+r_str(y2,x2)
    self.Range(r).interior.colorindex = color
  end

  def font_color(y,x)
    self.Cells.Item(y,x).Font.colorindex
  end

  def set_font_color(y,x,color)
    self.Cells.Item(y,x).Font.colorindex = color
  end

  def set_range_font_color(y1,x1,y2,x2,color)
    r = r_str(y1,x1)+':'+r_str(y2,x2)
    self.Range(r).Font.colorindex = color
  end

  def set_width(y,x,width)
    self.Cells.Item(y,x).ColumnWidth = width
  end

  def r_str(y,x)
    self.Cells.Item(y,x).address('RowAbsolute'=>false,'ColumnAbsolute'=>false)
  end

  def formula( y,x,f)
    r = r_str(y,x)
    self.Range(r).Formula = f
  end

  def group_row(y1,y2)
    r = r_str(y1,1)+':'+r_str(y2,1)
    self.Range(r).Rows.Group
  end

  def group_column(x1,x2)
    r = r_str(1,x1)+':'+r_str(1,x2)
    self.Range(r).Columns.Group
  end

  def merge(y1,x1,y2,x2)
    r = r_str(y1,x1)+':'+r_str(y2,x2)
    self.Range(r).MergeCells = true
  end

  def box(y1,x1,y2,x2)
    r = r_str(y1,x1)+':'+r_str(y2,x2)
    self.Range(r).Borders.LineStyle = 1
  end

  def wrap(y1,x1,y2,x2)
    r = r_str(y1,x1)+':'+r_str(y2,x2)
    self.Range(r).HorizontalAlignment = 1
    self.Range(r).WrapText = true
  end

  def v_top(y1,x1,y2,x2)
    r = r_str(y1,x1)+':'+r_str(y2,x2)
    self.Range(r).VerticalAlignment = -4160
  end

  def center(y1,x1,y2,x2)
    r = r_str(y1,x1)+':'+r_str(y2,x2)
    self.Range(r).HorizontalAlignment = -4108
  end

  def format_copy(y1,x1,y2,x2,y3,x3)
    r2 = r_str(y3,x3)
    r = r_str(y1,x1)+':'+r_str(y2,x2)
    self.Range(r2).Copy
    self.Range(r).PasteSpecial('Paste' => -4122)
  end

  def format_copy1(y1,x1,y2,x2)
    r2 = r_str(y2,x2)
    r = r_str(y1,x1)
    self.Range(r2).Copy
    self.Range(r).PasteSpecial('Paste' => -4122)
  end

  def copy(y1,x1,y2,x2,y3,x3)
    r2 = r_str(y3,x3)
    r = r_str(y1,x1)+':'+r_str(y2,x2)
    self.Range(r2).Copy
    self.Range(r).PasteSpecial('Paste' => -4104)
  end

  def insert_row(n)
    self.Rows("#{n}:#{n}").Insert('Shift' => -4121)
  end

end

def getAbsolutePath filename
  fso = WIN32OLE.new('Scripting.FileSystemObject')
  return fso.GetAbsolutePathName(filename)
end

def openExcelWorkbook filename
  filename = getAbsolutePath(filename)
  xl = WIN32OLE.new('Excel.Application')
  xl.Visible = false
  xl.DisplayAlerts = false
  book = xl.Workbooks.Open(filename)
  begin
    yield book
  ensure
    xl.Workbooks.Close
    xl.Quit
  end
end

def createExcelWorkbook
  xl = WIN32OLE.new('Excel.Application')
  xl.Visible = false
  xl.DisplayAlerts = false
  book = xl.Workbooks.Add()
  begin
    yield book
  ensure
    xl.Workbooks.Close
    xl.Quit
  end
end

##----- End of Excel module -------------------------------
