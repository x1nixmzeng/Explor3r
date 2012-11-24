{
  Explor3r
  x1nixmzeng/WRS
}
unit Unit1;

interface

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
    magic : MagicSig;
    size  : longword;
    chunks: longword;
    ver   : longword;
  end;

  ChunkHeader = packed record
    magic : MagicSig;
    offset: longword;
    flags : longword;
    size  : longword;
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
    Label1: TLabel;
    Label2: TLabel;
    procedure Load1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    imgCount : longword;
    imgData  : longword;
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
  began, val, i: longword; b:byte;
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
    try
      parseBlock( f, 0, treeview1.Items.GetFirstNode, extractfilename( opendialog1.Files[0] ) );
    finally
      label2.Caption := inttostr(imgCount) + ' ' + inttostr(imgData) + ' (bytes)';
      caption := opendialog1.Files[0] + ' - Explor3r';
    end;
    
    f.Destroy;

  end;

end;

procedure TForm1.imagePass(F:TFileStream;size:longword; node:TTreeNode);
const
  CHUNK_PCMP = 'PCMP';
type
  PCMPHeader = packed record
    magic : MagicSig;
    ver   : longword;
    files : longword;
    unknown:longword; // new
    file2 : longword; // new - there are MORE dds headers
    unknown2:longword;
    file3 : longword; // actual filecount?
    unknown3:longword;
    file4:longword;
    unknown4:longword;
    file5:longword;
    offset: longword;

    // NEW!
    dataOff: longword; // pointer (from PCMP header) to start of data
  end;

  // 32 bytes
  PCMPInfo = packed record
    un_pad: longword; // value of '01010101'
    crc32 : longword; // checksum of dds data
    offset: longword;
    size  : longword;
//    un_pad2: array[0..15] of byte; // texture size and other stuff maybe?
    ver   : longword; // dxt[ver] ex 3 is DXT3?
    width,
    height: word; // assumed
    unpad2: array[0..7] of byte;
  end;
var
  i,pos: longword;
  pheader : PCMPHeader;
  dheader : PCMPInfo;
  img:tmemorystream;
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

      treeview1.Items.AddChild(node, inttostr(pheader.file5)+' images');

      for i := 1 to ( pheader.file5) do
      begin
        f.Read( dheader, sizeof( PCMPInfo ) );

        with listview1.Items.Add do
        begin
          checked := true;
          caption := ' Texture: '+inttostr(dheader.width)+'x'+inttostr(dheader.height)+' (CRC32='+inttohex(dheader.crc32,8)+')';
          subitems.Add(inttostr(pos+dheader.offset));
          subitems.Add(inttostr(dheader.size));
        end;

        inc( imgCount );
        inc( imgData, dheader.size );

      end;

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

  test:longword;
  j,w: word;

  li:TListItem;
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

   // Image1.Picture.Bitmap.Handle :=
     //   OpenILUT.ilutWinLoadImage('explor3_tmp.dds', image1.Canvas.Handle);


end.
