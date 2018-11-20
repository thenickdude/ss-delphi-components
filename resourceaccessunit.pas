unit resourceaccessunit;

interface
uses sysutils, windows,contnrs;

type
  TResIdentType = (riString, riNumbered);

  TResourceIDRec = record
    ident: TResIdentType;
    id: integer;
    name: string;
  end;

  TResourceTypeNameRec = record
    id: integer;
    name: string;
  end;

  TResourceIdentifier = class
  public
    restype, resname: TResourceIDRec;
    lang: word;
  end;


const ResourceTypeNames: array[0..18] of TResourceTypeNameRec = (
    (id: integer(rt_rcdata); name: 'RCData'),
    (id: integer(rt_accelerator); name: 'Accelerators'),
    (id: integer(rt_string); name: 'String list'),
    (id: integer(rt_cursor); name: 'Cursor'),
    (id: integer(rt_bitmap); name: 'Bitmap'),
    (id: integer(rt_icon); name: 'Icon'),
    (id: integer(rt_menu); name: 'Menu'),
    (id: integer(rt_dialog); name: 'Dialog'),
    (id: integer(rt_fontdir); name: 'Font directory'),
    (id: integer(rt_font); name: 'Font'),
    (id: integer(rt_messagetable); name: 'Message table'),
    (id: integer(rt_group_cursor); name: 'Cursor group'),
    (id: integer(rt_group_icon); name: 'Icon group'),
    (id: integer(rt_version); name: 'Version information'),
    (id: integer(rt_dlginclude); name: 'Dialog include'),
    (id: integer(rt_plugplay); name: 'Plug and play descriptor'),
    (id: integer(rt_vxd); name: 'VXD descriptor'),
    (id: integer(rt_anicursor); name: 'Animated cursor'),
    (id: integer(rt_aniicon); name: 'Animated icon')
    );

function findresbytype(const filename: string; list: tobjectlist; const restype: string): boolean;
function resourcetypetostring(i: integer): string;
function stringtoresourcetype(const s: string): integer;
function isintresource(p: pchar): boolean;
function resourceid(i: integer): TResourceIDRec; overload;
function resourceid(const s: string): TResourceIDRec; overload;
function texttoresid(const s: string): tresourceidrec;
function restoid(res:pchar):TResourceIDRec;

implementation

var findingtype:string;
findinglist:tobjectlist;

function FindResByTypeCallback(handle: THandle; ResType: PChar; ResName: Pchar; long: Lparam): bool; stdcall;
var id:TResourceIdentifier;
begin
  if ansicomparetext(findingtype,restype)=0 then begin
    id:=TResourceIdentifier.Create;
    id.restype:=restoid(restype);
    id.resname:=restoid(resname);
    findinglist.add(id);
    result := true;
  end;
end;

function findresbytype(const filename: string; list: tobjectlist; const restype: string): boolean;
var h: hinst;
begin
  result:=false;

  h := LoadLibraryEX(pchar(filename), 0, LOAD_LIBRARY_AS_DATAFILE);
  if h=0 then exit;
  try
    findingtype:=restype;
    findinglist:=list;
    EnumResourceNames(h, pchar(restype), @FindResByTypeCallback, 0);
    result:=list.count>0;
  finally
    FreeLibrary(h);
  end;
end;

function texttoresid(const s: string): tresourceidrec;
var i: integer;
begin

  try
    i := strtoint(s);
    result := resourceid(i);
  except
    i := stringtoresourcetype(s);
    if i = 0 then result := resourceid(uppercase(s)) else
      result := resourceid(i);
  end;
end;

function resourceid(i: integer): TResourceIDRec;
begin
  result.ident := riNumbered;
  result.id := i;
  result.name := '';
end;

function resourceid(const s: string): TResourceIDRec;
begin
  result.ident := riString;
  result.id := 0;
  result.name := s;
end;


function stringtoresourcetype(const s: string): integer;
var t1: integer;
begin
  result := 0;
  for t1 := low(resourcetypenames) to high(resourcetypenames) do
    if ansicomparetext(resourcetypenames[t1].name, s) = 0 then begin
      result := resourcetypenames[t1].id;
      exit;
    end;
end;

function resourcetypetostring(i: integer): string;
var t1: integer;
begin
  result := 'RT' + inttostr(i);
  for t1 := low(resourcetypenames) to high(resourcetypenames) do
    if resourcetypenames[t1].id = i then begin
      result := resourcetypenames[t1].name;
      exit;
    end;
end;

function isintresource(p: pchar): boolean;
begin
  result := longword(p) and (not $FFFF) = 0;
end;

function restoid(res:pchar):TResourceIDRec;
begin
  if isintresource(res) then begin
   result.ident:=riNumbered;
   result.id:=cardinal(res) and $FFFF;
   end else begin
      result.ident:=riString;
      result.name:=res;
   end;
end;


end.

