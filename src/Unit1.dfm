object Form1: TForm1
  Left = 284
  Top = 141
  Width = 800
  Height = 556
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
    Width = 519
    Height = 510
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object ListView1: TListView
      Left = 0
      Top = 0
      Width = 552
      Height = 455
      Align = alClient
      Checkboxes = True
      Columns = <
        item
          Caption = 'Resource Details'
          Width = 350
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
      HideSelection = False
      ReadOnly = True
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
    end
    object GroupBox1: TGroupBox
      Left = 0
      Top = 455
      Width = 552
      Height = 55
      Align = alBottom
      Caption = 'Properties'
      TabOrder = 1
      object Label1: TLabel
        Left = 16
        Top = 24
        Width = 44
        Height = 13
        Caption = 'Textures:'
      end
      object Label2: TLabel
        Left = 72
        Top = 24
        Width = 17
        Height = 13
        Caption = '0'
      end
      object Button1: TButton
        Left = 280
        Top = 16
        Width = 129
        Height = 25
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
    Height = 510
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      273
      510)
    object Image1: TImage
      Left = 8
      Top = 251
      Width = 256
      Height = 256
      Anchors = [akLeft, akRight, akBottom]
      Center = True
    end
    object PaintBox1: TPaintBox
      Left = 200
      Top = 200
      Width = 25
      Height = 41
    end
    object TreeView1: TTreeView
      Left = 0
      Top = 0
      Width = 273
      Height = 244
      Align = alTop
      Anchors = [akLeft, akTop, akRight, akBottom]
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
    object Resources1: TMenuItem
      Caption = '&Resources'
      object SaveAll1: TMenuItem
        Caption = '&Save Selected'
        OnClick = SaveAll1Click
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object SelectAll1: TMenuItem
        Caption = 'Select &All'
        OnClick = SelectAll1Click
      end
      object SelectNone1: TMenuItem
        Caption = 'Select &None'
        OnClick = SelectNone1Click
      end
      object SelectInverse1: TMenuItem
        Caption = 'Select &Inverse'
        OnClick = SelectInverse1Click
      end
      object SelectOnly1: TMenuItem
        Caption = 'Select &Only'
        object Chunks1: TMenuItem
          Caption = '&Chunks'
          OnClick = Chunks1Click
        end
        object extures1: TMenuItem
          Caption = '&Textures'
          OnClick = extures1Click
        end
      end
      object Include1: TMenuItem
        Caption = 'Include &Selection'
        object Chunks2: TMenuItem
          Caption = '&Chunks'
          OnClick = Chunks2Click
        end
        object extures2: TMenuItem
          Caption = '&Textures'
          OnClick = extures2Click
        end
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
      'd3s;*.mec;font.bnk;*.vvs;*.vvv;*.vgt|Cities|*.d3c;*.pcs|Guns|*.c' +
      'pr|Missions|*.dam;*.mpc|Overlays|*.map;*.gfx|Music|*.pmu|Skies|*' +
      '.d3s|Territory|*.mec;font.bnk|Vehicles|*.vvs;*.vvv;*.vgt|All Fil' +
      'es|*.*'
    Title = 'Driv3r'
    Left = 64
    Top = 24
  end
end
