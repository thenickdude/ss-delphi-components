object Form1: TForm1
  Left = 385
  Top = 206
  Width = 870
  Height = 674
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object drwgrd1: TDrawGrid
    Left = 8
    Top = 16
    Width = 353
    Height = 297
    FixedCols = 0
    FixedRows = 0
    TabOrder = 0
    OnDrawCell = drwgrd1DrawCell
  end
  object grd32: TDrawGrid32
    Left = 384
    Top = 16
    Width = 433
    Height = 257
    Color = -1
    OnDrawCell = grd32DrawCell
    FixedRows = 0
    FixedCols = 0
    RowCount = 5
    ColCount = 5
    GridLineColor = -4210753
    DefaultRowHeight = 80
    DefaultColWidth = 120
  end
  object img1: TImgView32
    Left = 56
    Top = 384
    Width = 281
    Height = 161
    Bitmap.ResamplerClassName = 'TNearestResampler'
    Scale = 1
    ScrollBars.ShowHandleGrip = True
    ScrollBars.Style = rbsDefault
    OverSize = 0
    TabOrder = 2
  end
  object ItemGrid321: TItemGrid32
    Left = 384
    Top = 280
    Width = 441
    Height = 321
    Color = -1
    GridLineColor = -1
    GridLineWidth = 2
    DefaultColWidth = 120
    DefaultRowHeight = 80
    ItemCount = 8
    OnDrawItem = ItemGrid321DrawItem
  end
end
