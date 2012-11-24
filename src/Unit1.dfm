object Form1: TForm1
  Left = 255
  Top = 224
  Width = 865
  Height = 573
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
  object Panel1: TPanel
    Left = 273
    Top = 0
    Width = 584
    Height = 527
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object ListView1: TListView
      Left = 0
      Top = 0
      Width = 584
      Height = 472
      Align = alClient
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
        end
        item
          Caption = 'Ends'
          Width = 80
        end>
      GridLines = True
      ReadOnly = True
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
    end
    object GroupBox1: TGroupBox
      Left = 0
      Top = 472
      Width = 584
      Height = 55
      Align = alBottom
      Caption = 'Properties'
      TabOrder = 1
      DesignSize = (
        584
        55)
      object Label1: TLabel
        Left = 16
        Top = 24
        Width = 34
        Height = 13
        Caption = 'Images'
      end
      object Label2: TLabel
        Left = 80
        Top = 24
        Width = 6
        Height = 13
        Caption = '0'
      end
      object Button1: TButton
        Left = 256
        Top = 16
        Width = 305
        Height = 25
        Anchors = [akLeft, akRight]
        Caption = 'Preview'
        TabOrder = 0
        OnClick = Button1Click
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 273
    Height = 527
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 1
    object Image1: TImage
      Left = 8
      Top = 264
      Width = 256
      Height = 256
      Center = True
    end
    object PaintBox1: TPaintBox
      Left = 232
      Top = 208
      Width = 25
      Height = 41
    end
    object TreeView1: TTreeView
      Left = 0
      Top = 0
      Width = 273
      Height = 257
      Align = alTop
      AutoExpand = True
      Indent = 19
      ReadOnly = True
      RowSelect = True
      TabOrder = 0
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
