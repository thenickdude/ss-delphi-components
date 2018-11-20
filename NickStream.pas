unit NickStream;

interface
uses sysutils, classes, contnrs;
type
  TNickStream = class(tstream)
  public
    procedure writeboolean(b: boolean);
    function readboolean: boolean;

    procedure writesmallint(i: smallint);
    function readsmallint: smallint;

    procedure writelongint(i: longint);
    function readlongint: longint;

    procedure writedouble(d: double);
    function readdouble: double;

    procedure writebyte(b: byte);
    function readbyte: byte;

    procedure writeword(w: word);
    function readword: word;

    procedure writestring(const s: string);
    function readstring: string;

    procedure writebytestring(const s: string);
    function readbytestring: string;

    procedure writewordstring(const s: string);
    function readwordstring: string;

    procedure writelongword(i: longword);
    function readlongword: longword;

    procedure writeinteger(i: integer);
    function readinteger: integer;
  end;

implementation

procedure tnickstream.writelongint(i: longint);
begin
  write(i, sizeof(longint));
end;

function tnickstream.readlongint: longint;
begin
  read(result, sizeof(longint));
end;

procedure tnickstream.writeboolean(b: boolean);
begin
  if b then writebyte(1) else writebyte(0);
end;

function tnickstream.readboolean: boolean;
var b: byte;
begin
  b := readbyte;
  result := (b = 1);
end;

procedure tnickstream.writesmallint(i: smallint);
begin
  write(i, sizeof(smallint));
end;

function tnickstream.readsmallint: smallint;
begin
  read(result, sizeof(smallint));
end;

procedure tnickstream.writedouble(d: double);
begin
  Write(d, SizeOf(Double));
end;

function tnickstream.readdouble: double;
begin
  Read(Result, SizeOf(Double));
end;

procedure tnickstream.writebyte(b: byte);
begin
  write(b, sizeof(byte));
end;

function tnickstream.readbyte: byte;
begin
  read(result, sizeof(byte));
end;

procedure tnickstream.writeword(w: word);
begin
  write(w, sizeof(word));
end;

function tnickstream.readword: word;
begin
  read(result, sizeof(word));
end;


procedure tnickstream.writelongword(i: longword);
begin
  Write(i, SizeOf(longword));
end;

function tnickstream.readlongword: longword;
begin
  Read(Result, SizeOf(longword));
end;


procedure tnickstream.writeinteger(i: integer);
begin
  Write(i, SizeOf(Integer));
end;

function tnickstream.readinteger: integer;
begin
  Read(Result, SizeOf(Integer));
end;

procedure tnickstream.writebytestring(const s: string);
var
  StrLen: byte;
begin
  StrLen := Length(s);
  writebyte(StrLen);
  if strlen > 0 then
    Write(s[1], StrLen);
end;

function tnickstream.readbytestring: string;
var
  StrLen: byte;
begin
  StrLen := Readbyte;
  SetLength(Result, StrLen);
  if strlen > 0 then
    Read(Result[1], StrLen);
end;

procedure tnickstream.writewordstring(const s: string);
var
  StrLen: word;
begin
  StrLen := Length(s);
  writeword(StrLen);
  if strlen > 0 then
    Write(s[1], StrLen);
end;

function tnickstream.readwordstring: string;
var
  StrLen: word;
begin
  StrLen := Readword;
  SetLength(Result, StrLen);
  if strlen > 0 then
    Read(Result[1], StrLen);
end;

procedure tnickstream.writestring(const s: string);
var
  StrLen: longword;
begin
  StrLen := Length(s);
  writelongword(StrLen);
  if strlen > 0 then
    Write(s[1], StrLen);
end;

function tnickstream.readstring: string;
var
  StrLen: longword;
begin
  StrLen := Readlongword;
  SetLength(Result, StrLen);
  if strlen > 0 then
    Read(Result[1], StrLen);
end;

end.

