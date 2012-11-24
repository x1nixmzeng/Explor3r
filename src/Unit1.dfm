object Form1: TForm1
  Left = 255
  Top = 224
  Width = 865
  Height = 546
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  Caption = 'Explor3r'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object TreeView1: TTreeView
    Left = 0
    Top = 0
    Width = 249
    Height = 500
    Align = alLeft
    AutoExpand = True
    HideSelection = False
    Indent = 19
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 249
    Top = 0
    Width = 608
    Height = 500
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object Label1: TLabel
      Left = 8
      Top = 480
      Width = 37
      Height = 13
      Caption = 'Images:'
    end
    object Label2: TLabel
      Left = 56
      Top = 480
      Width = 32
      Height = 13
      Caption = 'Label2'
    end
    object ListView1: TListView
      Left = 0
      Top = 0
      Width = 608
      Height = 465
      Align = alTop
      Checkboxes = True
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
