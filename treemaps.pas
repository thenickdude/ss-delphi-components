unit treemaps;

interface

uses sysutils, windows, classes, contnrs, controls, gr32, gr32_image, math;

type
  TTreeNode = class
  protected
    function getcaption: string; virtual;
    procedure setcaption(const value: string); virtual;
  public
    r: tfloatrect;
    function Size: integer; virtual; abstract;
    procedure Click; virtual;
    property Caption: string read getcaption write setcaption;
  end;

  TTreeIntegerNode = class(TTreenode)
  protected
    fsize: integer;
  public
    constructor create(size: integer);
    function Size: integer; override;
  end;

  TTreeStringNode = class(TTreeIntegerNode)
  protected
    fcaption: string;
    function getcaption: string; override;
    procedure setcaption(const value: string); override;
  public
    constructor create(size: integer; const caption: string); reintroduce;
  end;

  TTreeNodeArray = array of TTreenode;

  TOnNodeClickEvent = procedure(sender: tobject; node: ttreenode) of object;

  TTreeMap = class(tcustompaintbox32)
  private
    function Getnode(index: integer): ttreenode;
    procedure Setnode(index: integer; value: ttreenode);
    function Sum(nodes: TTreeNodeArray): integer;
  protected
    fnodes: tobjectlist;
    fonnodeclick: tonnodeclickevent;
    procedure DoPaintBuffer; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(aowner: tcomponent); override;
    destructor Destroy; override;
    procedure Build; virtual; abstract;
    procedure Sort;
    procedure Clear;
    procedure Resize; override;
    function Count: integer;
    procedure Add(node: ttreenode);
    property Nodes[index: integer]: ttreenode read getnode write setnode;
  published
    property Align;
    property Anchors;
  end;

  TSquarifiedTreeMap = class(TTreemap)
  private
    totalsum:integer;
    availrect: TFloatRect;
    function worst(const list: TTreeNodeArray; length: single; new: integer = 0): single;
    procedure Layoutrow(row: TTreenodearray);
  public
    procedure Build; override;
  end;

procedure Register;

implementation

function tsquarifiedtreemap.worst(const list: TTreeNodeArray; length: single; new: integer = 0): single;
var t1, total, lowest, highest: integer;
begin
  total := 0;
  lowest := list[0].size;
  highest := list[0].size;
  for t1 := 0 to high(list) do begin
    total := total + list[t1].size;
    lowest := min(list[t1].size, lowest);
    highest := max(list[t1].size, highest);
  end;
  if new <> 0 then begin
    total := total + new;
    lowest := min(new, lowest);
    highest := max(new, highest);
  end;

  result := max((sqr(length) * highest) / sqr(total), sqr(total) / (sqr(length) * lowest));
end;

procedure tsquarifiedtreemap.Layoutrow(row: ttreenodearray);
var height, width: single;
  t1: integer;
  acc,total,sf:single;
begin
  total := 0;
  for t1 := 0 to high(row) do
    total := total + row[t1].size;

  sf:=((self.width*self.height)/totalsum);
  total:=total*sf;

  if availrect.bottom - availrect.top > availrect.right - availrect.left then begin
   //lay out vertically
   { xxxxxx
     |----|
     ||||||
     ||||||
     |----|
     }
    width := availrect.right - availrect.left;
    height := total / width;
    if height = 0 then
      exit; //insignificant
    acc := 0;
    for t1 := 0 to high(row) do begin
      row[t1].r := FloatRect(availrect.left + acc / height, availrect.bottom - height, availrect.left + (acc + row[t1].size*sf) / height, availrect.bottom);
      acc := acc + row[t1].size*sf;
    end;
    availrect.bottom := availrect.bottom - height;
  end else begin
    // lay out horizontally
    {
     |----|xxxx
     |----|xxxx
     |----|xxxx
     |----|xxxx
    }
    height := availrect.bottom - availrect.top;
    width := total / height;
    if width = 0 then
      exit;
    acc := 0;
    for t1 := 0 to high(row) do begin
      row[t1].r := floatrect(availrect.left, availrect.bottom - (acc + row[t1].size*sf) / width, availrect.left + width, availrect.bottom - (acc / width));
      acc := acc + row[t1].size*sf;
    end;
    availrect.left := availrect.left + width;
  end;

{  if (availrect.right - availrect.left <= 0) or
    (availrect.bottom - availrect.top <= 0) then
    raise exception.create('Out of space');}

end;

procedure ttreemap.Sort;
var i, j: integer;
  done: boolean;
begin
  for i := 0 to count - 1 do begin
    done := true;
    for j := count - 1 downto 1 do
      if nodes[j].size > nodes[j - 1].size then begin
        fnodes.Exchange(j, j - 1);
        done := false;
      end;
  if done then break;
  end;
end;

procedure tsquarifiedtreemap.Build;
var w: single;
  nodesize, index: integer;
  row: TTreeNodeArray;
begin
  if count = 0 then exit;

  {Sort nodes}
  sort;

  {Need to normalize nodesize}
  totalsum:=0;
  for index:=0 to count-1 do
   totalsum:=totalsum+nodes[index].Size;

  setlength(row, 0);
  availrect := floatrect(0, 0, width, height);
  w := min(availrect.right - availrect.left, availrect.bottom - availrect.top);

  for index := 0 to count - 1 do begin
    nodesize := nodes[index].size; //Only ask once. We don't know the performance penalty attached to this method!
    if (length(row) = 0) or (worst(row, w) >= worst(row, w, nodesize)) then begin
      setlength(row, length(row) + 1);
      row[high(row)] := nodes[index];
    end else begin
      layoutrow(row); //we're done with this row
      setlength(row, 1);
      row[0] := nodes[index];
      w := min(availrect.right - availrect.left, availrect.bottom - availrect.top);
    end;
  end;
  if length(row) > 0 then
    layoutrow(row);
  invalidate;
end;

function ttreenode.getcaption: string;
begin
  result := '';
end;

procedure ttreenode.setcaption(const value: string);
begin
   //noop
end;



procedure ttreenode.Click;
begin
    //
end;

constructor ttreestringnode.create(size: integer; const caption: string);
begin
  fsize := size;
  fcaption := caption;
end;

function ttreestringnode.getcaption: string;
begin
  result := fcaption;
end;

procedure ttreestringnode.setcaption(const value: string);
begin
  fcaption := value;
end;


constructor ttreeintegernode.create(size: integer);
begin
  fsize := size;
end;

function ttreeintegernode.size: integer;
begin
  result := fsize;
end;

function ptinrect(r: tfloatrect; p: tpoint): boolean;
begin
  result := (p.x >= r.left) and (p.x <= r.right) and (p.y >= r.top) and (p.y <= r.bottom);
end;

function TTreemap.Sum(nodes: TTreeNodeArray): integer;
var t1: integer;
begin
  result := 0;
  for t1 := 0 to high(nodes) do
    result := result + nodes[t1].Size;
end;

procedure ttreemap.Resize;
begin
  inherited;
  Build;
end;

procedure TTreemap.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var t1: integer;
begin
  inherited;
  for t1 := 0 to count - 1 do
    if PtInRect(nodes[t1].r, point(x, y)) then begin
      Nodes[t1].Click;
      exit;
    end;
end;


function ttreemap.getnode(index: integer): ttreenode;
begin
  result := ttreenode(fnodes[index]);
end;

procedure ttreemap.setnode(index: integer; value: ttreenode);
begin
  fnodes[index] := value;
end;

procedure ttreemap.dopaintbuffer;
var t1: integer;
begin
  buffer.clear(clwhite32);
  for t1 := 0 to count - 1 do begin
    buffer.FillRectS(round(nodes[t1].r.left),
      round(nodes[t1].r.top),
      round(nodes[t1].r.right),
      round(nodes[t1].r.bottom),
      random($FFFFFF));
    if length(nodes[t1].caption) > 0 then begin
      if (Buffer.TextWidth(nodes[t1].caption) < nodes[t1].r.right - nodes[t1].r.left) and
        (Buffer.TextHeight(nodes[t1].caption) < nodes[t1].r.bottom - nodes[t1].r.top) then
        buffer.RenderText(round(nodes[t1].r.left), round(nodes[t1].r.top), nodes[t1].Caption, 0, clwhite32);
    end;
  end;
end;

constructor ttreemap.create(aowner: tcomponent);
begin
  inherited create(aowner);
  fnodes := tobjectlist.create;
end;

destructor ttreemap.destroy;
begin
  fnodes.free;
  inherited;
end;

procedure ttreemap.Clear;
begin
  fnodes.clear;
end;

function ttreemap.Count: integer;
begin
  result := fnodes.count;
end;

procedure ttreemap.Add(node: ttreenode);
begin
  fnodes.add(node);
end;

procedure Register;
begin
  RegisterComponents('Sherlock Software', [TSquarifiedTreeMap]);
end;

end.

