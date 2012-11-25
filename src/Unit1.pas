{
  Explor3r
  x1nixmzeng/WRS
}
unit Unit1;

interface

{$DEFINE OPENILTEST}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Menus, ExtCtrls
  {$IFDEF OPENILTEST}
  , OpenIL, OpenILUT
  {$ENDIF}
  ;
type
  MagicSig = array[0..3] of char;

  BlockHeader = packed record
    magic  : MagicSig;
    unknown: longword; // $00000003 (file version?)
    chunks : longword;
    ver    : longword;
  end;

  ChunkHeader = packed record
    magic  : MagicSig;
    offset : longword;
    un1    : longword; // maybe chunk flags
    size   : longword;
  end;

const
  BLOCKMAGIC = 'CHNK';

  // Various chunk headers (TODO)

  CHUNK_MISSINGMAGIC = '';
  CHUNK_MODELPACKAGE = 'MDPC';
  CHUNK_DUMMY        = 'PCSL';
  CHUNK_SUPERREGION  = 'GESR';
  CHUNK_GLOBALREGION = 'GRGR';
  CHUNK_INTERIORREGION='GEIR';
  CHUNK_MISSIONEDITOR= 'PINF';
  CHUNK_MENUPACKAGE  = 'RMDP'; 

type  
  TForm1 = class(TForm)
    ListView1: TListView;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Load1: TMenuItem;
    TreeView1: TTreeView;
    About1: TMenuItem;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    Panel2: TPanel;
    Image1: TImage;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    PaintBox1: TPaintBox;
    Button1: TButton;
    Resources1: TMenuItem;
    SaveAll1: TMenuItem;
    N1: TMenuItem;
    SelectAll1: TMenuItem;
    SelectNone1: TMenuItem;
    SelectInverse1: TMenuItem;
    SelectOnly1: TMenuItem;
    Chunks1: TMenuItem;
    extures1: TMenuItem;
    Include1: TMenuItem;
    Chunks2: TMenuItem;
    extures2: TMenuItem;
    procedure Load1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure SaveAll1Click(Sender: TObject);
    procedure SelectAll1Click(Sender: TObject);
    procedure SelectNone1Click(Sender: TObject);
    procedure SelectInverse1Click(Sender: TObject);
    procedure Chunks1Click(Sender: TObject);
    procedure extures1Click(Sender: TObject);
    procedure Chunks2Click(Sender: TObject);
    procedure extures2Click(Sender: TObject);
  private
    imgCount : longword;
    imgData  : longword;
    lastFile : string;
    procedure imagePass(F:TFileStream;size:longword; node:TTreeNode);
    procedure parseChunk(F:TFileStream; offset:integer; var cheader:ChunkHeader; node:TTreeNode);
    procedure parseBlock(F:TFileStream; offset:integer; node:TTreeNode; name:string);
    procedure loadFile();
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

{
  Horrible method to get any chunk descriptions
  Memory is allocated and filled with 4 bytes
  and the descriptions are not null-terminated (!)
}
function ReadComment( f: TFileStream ): String;
var
  i: longword; b:byte;
const
  mem_fill : array[0..3] of byte = ( $A1,$15,$C0,$DE );
begin
  result := '';

  i := 0;

  while f.Position<f.Size do
  begin
    f.Read(b,1);
    if b = 0 then break; // new - may be null terminated
    if ( b xor mem_fill[i and 3] ) = 0 then break;
    inc(i);
    if b >= $80 then break;// new - try to stop reading invalid characters
    result:=result+chr(b);
  end;

  // remove trailing spacing
  result := trimright( result );

end;

procedure TForm1.loadFile();
var
  f  : TFileStream;
begin

  if opendialog1.Execute() then
  begin
    f := TFileStream.Create( opendialog1.Files[0], fmOpenRead );

    listview1.Clear;
    treeview1.Items.Clear;
    imgCount := 0;
    imgData  := 0;
    lastFile := '';
    try
      parseBlock( f, 0, treeview1.Items.GetFirstNode, extractfilename( opendialog1.Files[0] ) );
    finally
      lastFile := opendialog1.files[0];
      label2.Caption := inttostr(imgCount);
      caption := opendialog1.Files[0] + ' - Explor3r';
    end;
    
    f.Destroy;

  end;

end;

{
  filecount 
}
procedure TForm1.imagePass(F:TFileStream;size:longword; node:TTreeNode);
const
  CHUNK_PCMP = 'PCMP';
type
  PCMPHeader = packed record
    magic  : MagicSig;
    un1,               // not game version ($3)
    un2,               //
    mySize : longword; // OFFSET 56 (to end of PCMPHeader)
    un3,               //
    un4,               // OFFSET mySize + (un1*24)
    un5,               //
    un6,               // OFFSET un4 + (un3*8)
    un7,               //
    un8,               //
    files  : longword; // number we use for # of files
    offset : longword; //
    dataOff: longword; // pointer (from PCMP header) to start of data
    un9    : longword;
  end;

  // 32 bytes
  PCMPInfo = packed record
    un1   : longword; // sometimes = $01010101
    un2   : longword; // crc32 of texture data or 0
    offset: longword;
    size  : longword;
    un3   : longword; // not dxt version
    width,
    height: word;
    unpad : array[0..7] of byte;
  end;
var
  loop:boolean;
  i,pos: longword;
  pheader : PCMPHeader;
  dheader : PCMPInfo;
begin

// just search for the inner PCMP chunk
  while size > (4096) do
  begin
    f.Read(pheader,sizeof(PCMPHeader));

    if pheader.magic = CHUNK_PCMP then
    begin
      // start of data
      pos := (f.position - sizeof( PCMPHeader )) + pheader.dataOff;
      f.Seek( pheader.offset - sizeof( PCMPHeader ), soCurrent );

      treeview1.Items.AddChild(node, inttostr(pheader.files)+' images');

      //for i := 1 to ( pheader.file5) do
      i:=0; loop:= true;
      while loop do
      begin
        f.Read( dheader, sizeof( PCMPInfo ) );
        if dheader.un1 = 0{<> $01010101 } then
        begin
          loop:= false;
          continue;
        end;
        inc(i);

        with listview1.Items.Add do
        begin
          checked := true;
          caption := ' Texture: '+inttostr(dheader.width)+' x '+inttostr(dheader.height);
          //+' (CRC32='+inttohex(dheader.crc32,8)+')';
          subitems.Add(inttostr(pos+dheader.offset));
          subitems.Add(inttostr(dheader.size));
        end;

        inc( imgCount );
        inc( imgData, dheader.size );

      end;

      // 
      if  i <> pheader.files then
        showmessage('Warning: Unexpected filecount'#13#10+
        Format('(expected %d got %d)',[pheader.files,i])    );

      // success! cleanexit
      exit;

    end ;

    size := size - 4096;
    f.Seek( 4096 - sizeof(PCMPHeader), soCurrent );
  end;
  
end;

{
  generic chunk handler
}
procedure TForm1.parseChunk(F:TFileStream; offset:integer; var cheader:ChunkHeader; node:TTreeNode);
var
  magic : MagicSig;
  notBlock : boolean;
begin

    notBlock := true;

    if cheader.size > (sizeof( ChunkHeader ) + sizeof(MagicSig)) then
    begin
      f.Read(magic, sizeof(MagicSig));
      f.Seek(-sizeof(MagicSig), soCurrent);

      if magic = BLOCKMAGIC then
      begin
        // quickly rename invalid blocks
        if cheader.magic = '' then
          parseBlock( f, offset, node, '<unnamed>' )
        else
        if cheader.magic[1] = #0 then
          parseBlock( f, offset, node, '<'+inttostr(byte(cheader.magic[0]))+'>' )
        else
          parseBlock( f, offset, node, cheader.magic );

        notBlock := false;  
      end;
            
    end;


  if notBlock then
  begin
    // attempt an image pass
    node := treeview1.Items.AddChild(node, cheader.magic);

    imagePass(f, cheader.size, node);
  end;


end;

{
  recursive function to each out each chunk
  also attempts to read the descriptions at the end of the chunk
}
procedure TForm1.parseBlock(F:TFileStream; offset:integer; node:TTreeNode; name:String);
var
  header : BlockHeader;
  cheader: ChunkHeader;
  
  pos : longword;
  i: longword;

begin
  f.Read( header, sizeof( BlockHeader ) );

  if header.magic <> BLOCKMAGIC then
  begin
    showmessage('Unknown block type');
    exit;
  end;

  node := treeview1.Items.AddChild( node, name );  

  if name = CHUNK_MISSIONEDITOR then
  begin
  {
    2 expected chunks:
      PIND and PINS
    PINS contains:
      null-terminated string table
    PIND contains:
      OFFSET : longword  // PINS string offset
      INDEX  : word      // Just the string index (0-x)
      unknown: word      // Flags or string type      
  }
  end;

  for i := 1 to header.chunks do
  begin
    f.read( cheader, sizeof( ChunkHeader ) );

    pos := f.Position;
    f.Seek( offset + cheader.offset + cheader.size, soBeginning );

    with listview1.Items.Add do
    begin
     // caption := cheader.magic;
      caption := 'Chunk: ' + ReadComment( f );
      subitems.add( inttostr( offset + cheader.offset ) );
      subitems.add( inttostr( cheader.size ) );

      // new: end of chunk
      // bugfix: actually this is the description pointer! +4096
      subitems.Add( inttostr( offset + cheader.offset + cheader.size +4096 ) );
    end;

    f.Seek( offset + cheader.offset, soBeginning );

    parseChunk( f, f.Position, cheader, node );

    f.Seek( pos, soBeginning );
  end;
end;

procedure TForm1.Load1Click(Sender: TObject);
begin
  loadFile();
end;

procedure TForm1.About1Click(Sender: TObject);
begin
  showmessage('Load chunked data from Driv3r (PC)');
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
{$IFDEF OPENILTEST}
  OpenIL.ilInit;
  OpenILUT.ilutInit;
{$ENDIF}
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  off,size:longword;
  fs:tfilestream;
  ms:tmemorystream;
begin
  if ( listview1.SelCount > 0 ) and ( lastFile <> '' ) then
  begin
    with listview1.Selected do
    begin
      if checked then
      begin
        off := strtoint( listview1.Items.Item[index].SubItems[0] );
        size:= strtoint( listview1.Items.Item[index].SubItems[1] );

        // now read the file to get the dds data ?
        fs:=tfilestream.Create(lastFile,fmOpenRead);
        fs.Seek(off,soBeginning);
        ms:=tmemorystream.create;
        ms.CopyFrom(fs,size);
        fs.Destroy;
        setcurrentdirectory(pchar(Extractfiledir(paramstr(0))));
        ms.SaveToFile('ddscache');
        ms.Free;

        if image1.Picture.Bitmap.Handle <> 0 then
          image1.Picture.Bitmap.FreeImage;

        Image1.Picture.Bitmap.Handle :=

          OpenILUT.ilutWinLoadImage('ddscache', paintbox1.Canvas.Handle);

          deletefile('ddscache');

        // to save after loading an image, you can do this:
//        openil.ilSaveImage('test.png');
    
      end;
    end;

  end;
end;

procedure TForm1.SaveAll1Click(Sender: TObject);
var
  fs:tfilestream;
  i,e: longword;
  str: string;
  off,size:longword;
  ms:tmemorystream;
begin
  e:=0;
  if ( listview1.Items.Count > 0 ) and ( lastFile <> '' ) then
  begin
    // open file once
    fs:=tfilestream.Create(lastFile,fmOpenRead);

    setcurrentdirectory(pchar(Extractfiledir(paramstr(0))));
    createdir( 'extracted' );    
       

    for i:=1 to listview1.Items.Count do
    begin
      with listview1.Items.Item[i-1] do
      if checked then
      begin
        off := strtoint( SubItems[0] );
        size:= strtoint( SubItems[1] );

        fs.Seek(off,soBeginning);
        ms:=tmemorystream.create;
        ms.CopyFrom(fs,size);

        if strpos( pchar(caption), ('Texture') ) <> nil then
        begin
          ms.SaveToFile('ddscache');
          ms.Free;

          if image1.Picture.Bitmap.Handle <> 0 then
            image1.Picture.Bitmap.FreeImage;

          openil.ilLoadImage('ddscache');
//        OpenILUT.ilutWinLoadImage('e3tmp.dds', paintbox1.Canvas.Handle);

          openil.ilSaveImage(pchar('extracted/'+inttohex(off,8)+'.png'));
          deletefile('ddscache');
       end
       else
       begin
         ms.SaveToFile('extracted/chunk_'+inttohex(off,8)+'.dat');
         ms.Free;
       end;

       inc(e);
    
      end;
    end;

    fs.Destroy;

  end;

  showmessage(format('Extracted %d files',[e]));
end;

procedure TForm1.SelectAll1Click(Sender: TObject);
var i : longword;
begin
  for i:=1 to listview1.Items.Count do
    listview1.Items.Item[i-1].Checked:=true ; // select ALL
end;

procedure TForm1.SelectNone1Click(Sender: TObject);
var i : longword;
begin
  for i:=1 to listview1.Items.Count do
    listview1.Items.Item[i-1].Checked:=false ; //select NONE
end;

procedure TForm1.SelectInverse1Click(Sender: TObject);
var i : longword;
begin
  for i:=1 to listview1.Items.Count do // select INVERSE
    listview1.Items.Item[i-1].Checked:=not listview1.Items.Item[i-1].Checked;
end;

procedure TForm1.Chunks1Click(Sender: TObject);
var i : longword;
begin
  for i:=1 to listview1.Items.Count do // select ONLY CHUNKS
    listview1.Items.Item[i-1].Checked:=
      ( strpos( pchar(listview1.Items.Item[i-1].caption), ('Chunk: ') )<>nil );
end;

procedure TForm1.extures1Click(Sender: TObject);
var i : longword;
begin
  for i:=1 to listview1.Items.Count do // select ONLY TEXTURES
    listview1.Items.Item[i-1].Checked:=
      ( strpos( pchar(listview1.Items.Item[i-1].caption), ('Texture: ') )<>nil );
end;

procedure TForm1.Chunks2Click(Sender: TObject);
var i : longword;
begin
  for i:=1 to listview1.Items.Count do // select INC CHUNKS
    if strpos( pchar(listview1.Items.Item[i-1].caption), ('Chunk: ') )<>nil then
         listview1.Items.Item[i-1].Checked:=true;
end;

procedure TForm1.extures2Click(Sender: TObject);
var i : longword;
begin
  for i:=1 to listview1.Items.Count do // select INC TEXTURES
    if strpos( pchar(listview1.Items.Item[i-1].caption), ('Texture: ') )<>nil then
         listview1.Items.Item[i-1].Checked:=true;
end;

end.
