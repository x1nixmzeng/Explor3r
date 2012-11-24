object Form1: TForm1
  Left = 346
  Top = 193
  Width = 783
  Height = 540
  Caption = 'Explor3r'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object ListView1: TListView
    Left = 193
    Top = 0
    Width = 582
    Height = 494
    Align = alClient
    Columns = <
      item
        Caption = 'Resource Details'
        Width = 400
      end
      item
        Caption = 'Offset'
        Width = 80
      end
      item
        Caption = 'Size'
        Width = 80
      end>
    GridLines = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
  end
  object TreeView1: TTreeView
    Left = 0
    Top = 0
    Width = 193
    Height = 494
    Align = alLeft
    AutoExpand = True
    HideSelection = False
    Indent = 19
    ReadOnly = True
    RowSelect = True
    TabOrder = 1
  end
  object MainMenu1: TMainMenu
    Left = 8
    Top = 16
    object File1: TMenuItem
      Caption = '&File'
      object Load1: TMenuItem
        Caption = '&Load..'
        OnClick = Load1Click
      end
    end
    object About1: TMenuItem
      Caption = '&About'
      OnClick = About1Click
    end
  end
  object OpenDialog1: TOpenDialog
    Filter = 
      'All Supported|*.d3c;*.pcs;*.cpr;*.dam;*.mpc;*.map;*.gfx;*.pmu;*.' +
      'd3s;*.mec;*.vvs;*.vvv;*.vgt|Cities|*.d3c;*.pcs|Guns|*.cpr|Missio' +
      'ns|*.dam;*.mpc|Overlays|*.map;*.gfx|Music|*.pmu|Skies|*.d3s|Terr' +
      'itory|*.mec|Vehicles|*.vvs;*.vvv;*.vgt|All Files|*.*'
    Title = 'Driv3r'
    Left = 64
    Top = 24
  end
end
