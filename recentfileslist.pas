unit recentfileslist;

interface
uses sysutils, windows, classes, contnrs, menus, registry, nickstream,
  graphics,forms;

type
  TOnrecentfileclick = procedure(filename: string) of object;
  TRecentfiles = class(tcomponent)
  private
    fhandler: tonrecentfileclick;
    fmenu: tmenuitem;
    fcanvas: tform;
    procedure onitemclick(sender: tobject);
    procedure buildmenu;
    procedure setcanvas(value:tform);
  public
    list: tstringlist;
    procedure add(filename: string);
    procedure savetokey(key: string);
    procedure loadfromkey(key: string);
    constructor create(aowner:tcomponent); override;
    destructor destroy; override;
  published
    property FontCanvas:tform read fcanvas write setcanvas;
    property ParentMenuItem:Tmenuitem read fmenu write fmenu;
    property onRecentFileClick:TOnrecentfileclick read fhandler write fhandler;
  end;

procedure Register;

function PathCompactPath(hDC: hDC; lpszPath: PChar; dx: UInt): Bool; stdcall; external 'shlwapi.dll' name 'PathCompactPathA';

implementation

procedure trecentfiles.setcanvas(value:tform);
begin
 fcanvas:=value;
end;

procedure trecentfiles.onitemclick(sender: tobject);
begin
 if assigned(onrecentfileclick) then
  onrecentfileclick(list[tcomponent(sender).tag]);
end;

procedure trecentfiles.buildmenu;
var item: tmenuitem;
  t1: integer;
  namein: array[0..500] of Char;
begin
  fmenu.Clear;
  for t1 := list.count - 1 downto 0 do
   if length(list[t1])<500 then begin
    item := tmenuitem.create(fmenu);

     StrPCopy(namein, list[t1]);
      if fcanvas<>nil then
      if PathCompactPath(fcanvas.canvas.handle, namein, 300) then
        item.caption := namein
      else
        item.caption := list[t1];
    item.OnClick := onitemclick;
    item.Tag := t1;
    fmenu.add(item);
  end;
  fmenu.Enabled := (list.count > 0);
end;

procedure trecentfiles.add(filename: string);
var t1: integer;
begin
  for t1 := list.count - 1 downto 0 do
    if ansicomparetext(list[t1], filename) = 0 then begin
      list.Delete(t1);
      break;
    end;
  list.Add(filename);
  while list.count > 8 do list.delete(0);
  buildmenu;
end;

procedure trecentfiles.savetokey(key: string);
var reg: tregistry;
  stream: tmemorystream;
  t1: integer;
begin
  stream := tmemorystream.create;
  try
    tnickstream(stream).writeinteger(list.count);
    for t1 := 0 to list.count - 1 do
      tnickstream(stream).writestring(list[t1]);
    reg := tregistry.create;
    try
      reg.RootKey := HKEY_CURRENT_USER;
      reg.OpenKey(key, true);
      reg.WriteBinaryData('RecentFiles', stream.memory^, stream.size);
    finally
      reg.free;
    end;
  finally
    stream.free;
  end;
end;

procedure trecentfiles.loadfromkey(key: string);
var reg: tregistry;
  stream: tmemorystream;
  count, t1: integer;
begin
  list.Clear;
  reg := tregistry.create;
  try
    reg.rootkey := HKEY_CURRENT_USER;
    if reg.OpenKey(key, false) and reg.ValueExists('RecentFiles') then begin
      stream := tmemorystream.create;
      try
        stream.SetSize(10000);
        stream.setsize(reg.ReadBinaryData('RecentFiles', stream.memory^, stream.size));
        stream.seek(0, sofrombeginning);
        count := tnickstream(stream).readinteger;
        for t1 := 0 to count - 1 do
          list.add(tnickstream(stream).readstring);
      finally
        stream.free;
      end;
    end;
  finally
    reg.free;
  end;
  buildmenu;
end;

constructor trecentfiles.create(aowner:tcomponent);
begin
  inherited;
  list := tstringlist.create;
  fcanvas:=nil;
end;

destructor trecentfiles.destroy;
begin
  list.free;
  inherited;
end;

procedure Register;
begin
 registercomponents('Sherlock Software',[trecentfiles]);
end;

end.
