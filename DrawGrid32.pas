unit DrawGrid32;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  GR32_Image, gr32, GR32_RangeBars, math;

const SCROLLBARSIZE = 18;

type
  TDrawState32 = set of (dsSelected, dsFocused, dsFixed);

  TDrawCell32Event = procedure(buffer: TBitmap32; col, row: Integer; cellrect: Trect; state: TDrawState32) of object;
  TDrawItem32Event = procedure(buffer: TBitmap32; itemindex: integer; cellrect: TRect; state: TDrawState32) of object;

  TSelectItem32Event = procedure(sender: TObject; itemindex: Integer) of object;

  TCustomDrawGrid32 = class(TCustomPaintBox32)
  private
    fxoffset, fyoffset: integer;
    fviewablex, fviewabley: integer;

    fcolor: tcolor32;

    frowcount, fcolcount: integer;

    ffixedrows, ffixedcols: integer;

    fgridlinewidth: integer;

    fdefaultrowheight, fdefaultcolwidth: integer;

    fgridlinecolor: TColor32;

    fcolwidths, frowheights: array of integer;
    procedure SetGridLineColor(value: Tcolor32);
    procedure SetGridLineWidth(value: integer);
    procedure SetFixedRows(value: integer);
    procedure SetFixedCols(value: integer);
    procedure SetRowCount(value: integer);
    procedure SetColCount(value: integer);
    procedure SetColor(value: TColor32);
    procedure scrollmoved(sender: Tobject);
    function getrowheight(index: integer): integer;
    function getcolwidth(index: integer): integer;
    procedure setrowheight(index: integer; value: integer);
    procedure setcolwidth(index: integer; value: integer);
  protected
    HScroll, VScroll: TRangeBar;

    procedure wheelmoved(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);

    function CellRect(col, row: integer): TRect;

    procedure SelectCell(col, row: integer); virtual;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;

    procedure Changed; virtual;
    procedure DoPaintBuffer; override;
    procedure UpdateScrollBars; virtual;
    procedure DrawCell(col, row: Integer; cellrect: Trect; state: TDrawState32); virtual;

    property DefaultColWidth: integer read fdefaultcolwidth write fdefaultcolwidth;
    property DefaultRowHeight: integer read fdefaultrowheight write fdefaultrowheight;

    property GridLineWidth: integer read fgridlinewidth write setgridlinewidth;
    property GridLineColor: TColor32 read fgridlinecolor write setgridlinecolor;

    property FixedRows: integer read ffixedrows write setfixedrows;
    property FixedCols: integer read ffixedcols write setfixedcols;
    property RowCount: integer read frowcount write setrowcount;
    property ColCount: integer read fcolcount write setcolcount;

    property ColWidths[index: integer]: integer read getcolwidth write setcolwidth;
    property RowHeights[index: integer]: integer read getrowheight write setrowheight;
  public
    function GetViewPortRect: TRect; override;
    procedure Resize; override;
    constructor Create(aOwner: Tcomponent); override;
  published
    property Constraints;
    property Align;
    property Anchors;
    property Enabled;
    property Color: TColor32 read fcolor write setcolor;
  end;

  TItemGrid32 = class(TCustomDrawGrid32)
  private
    fselindex: integer;

    fitemcount: integer;
    fondrawitem: TDrawItem32Event;
    fonselectcell: TSelectItem32Event;
    procedure setitemcount(value: integer);
    procedure setSelIndex(value: integer);
  protected
    procedure SelectCell(col, row: integer); override;
    procedure DrawCell(col, row: Integer; cellrect: Trect; state: TDrawState32); override;
  public
    procedure Resize; override;
    constructor Create(aOwner: Tcomponent); override;
  published
    property SelIndex: integer read fselindex write setselindex;
    property GridLineColor;
    property GridLineWidth default 0;
    property DefaultColWidth;
    property DefaultRowHeight;
    property ItemCount: integer read fitemcount write setitemcount nodefault;
    property OnDrawItem: TDrawItem32Event read fondrawitem write fondrawitem;
    property OnSelectCell: TSelectItem32Event read fonselectcell write fonselectcell;
  end;

  TDrawGrid32 = class(TCustomDrawGrid32)
  private
    fondrawcell: tdrawcell32event;
  protected
    procedure DrawCell(col, row: Integer; cellrect: Trect; state: TDrawState32); override;
  public
    property ColWidths;
    property RowHeights;
    constructor Create(aOwner: Tcomponent); override;
  published
    property OnDrawCell: TDrawCell32Event read fondrawcell write fondrawcell;
    property FixedRows;
    property FixedCols;
    property RowCount;
    property ColCount;
    property GridLineColor;
    property GridLineWidth default 1;
    property DefaultRowHeight;
    property DefaultColWidth;
  end;

procedure Register;

implementation

procedure TDrawGrid32.DrawCell(col, row: Integer; cellrect: Trect; state: TDrawState32);
begin
  if assigned(ondrawcell) then
    OnDrawCell(Buffer, col, row, cellrect, state);
end;

procedure TItemGrid32.setSelIndex(value: integer);
var oldrect, newrect: trect;
begin
  if value < 0 then value := -1; //Normalize

  if fselindex <> value then begin

    if fselindex <> -1 then begin
      oldrect := cellrect(fselindex mod ColCount, fselindex div ColCount);
      InvalidateRect(Handle, @oldrect, true);
    end;

    if value <> -1 then begin
      newrect := cellrect(value mod ColCount, value div ColCount);
      InvalidateRect(Handle, @newrect, true);
    end;

    fselindex := value;

  end;
end;

procedure TItemGrid32.setitemcount(value: integer);
begin
  if fitemcount <> value then begin
    fitemcount := value;
    changed;
  end;
end;

procedure TItemGrid32.SelectCell(col, row: integer);
var cellindex: integer;
begin
  cellindex := row * ColCount + col;

  if cellindex < ItemCount then begin

    selindex := cellindex;

    if assigned(onselectcell) then
      onSelectCell(self, cellindex);
  end;
end;

procedure TItemGrid32.DrawCell(col, row: Integer; cellrect: Trect; state: TDrawState32);
var cellindex: integer;
begin
  cellindex := row * ColCount + col;

  if assigned(ondrawitem) and (cellindex < ItemCount) then begin
    if fselindex = cellindex then
      Include(state, dsSelected);
    OnDrawItem(buffer, cellindex, cellrect, state);
  end;
end;

function TCustomDrawGrid32.GetViewPortRect: TRect;
begin
  with Result do
  begin
    Left := 0;
    Top := 0;
    Right := Width - SCROLLBARSIZE;
    Bottom := Height - SCROLLBARSIZE;
  end;
end;

procedure TCustomDrawGrid32.Resize;
begin
  inherited;
  VScroll.left := width - vscroll.width;
  VScroll.height := height - hscroll.Height;

  HScroll.top := height - HScroll.height;
  HScroll.width := width - vscroll.width;
end;

procedure TCustomDrawGrid32.SelectCell(col, row: integer);
begin
  //do nothing. Children can implement this if they desire..
end;

function TCustomDrawGrid32.CellRect(col, row: integer): TRect;
var x, y: integer;
  accx, accy: integer;
begin
  accx := -fxoffset;

  for x := 0 to col - 1 do
    accx := accx + ColWidths[x] + GridLineWidth;

  accy := -fyoffset;

  for y := 0 to row - 1 do
    accy := accy + RowHeights[y] + GridLineWidth;

  result := rect(accx, accy, accx + ColWidths[col], accy + rowheights[row]);
end;

procedure TCustomDrawGrid32.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var col, row: integer;
  accx, accy: integer;
begin
  if PtInRect(GetViewPortRect, point(x, y)) then begin
    x := x + fxoffset;
    y := y + fyoffset;

    accx := 0;

    for col := 0 to ColCount - 1 do begin
      accx := accx + ColWidths[col] + GridLineWidth;
      if x < accx then begin //point is in this column

        accy := 0;
        for row := 0 to RowCount - 1 do begin
          accy := accy + RowHeights[row] + GridLineWidth;
          if y < accy then begin //We found our cell!
            SelectCell(col, row);
            exit; //we're done here
          end;
        end;
        break; //Finished searching cols
      end;
    end;
  end;
end;

procedure TCustomDrawGrid32.scrollmoved(sender: Tobject);
begin
  fxoffset := round(HScroll.position);
  fyoffset := round(VScroll.position);
  invalidate;
end;

procedure TCustomDrawGrid32.Changed;
var t1: integer;
begin
  //our contained size could have changed (rows/cols). Update scrollbars and viewable
  fviewablex := 0;
  for t1 := 0 to colcount - 1 do
    fviewablex := fviewablex + colwidths[t1] + GridLineWidth;

  HScroll.Range := fviewablex;

  fviewabley := 0;
  for t1 := 0 to rowcount - 1 do
    fviewabley := fviewabley + rowheights[t1] + GridLineWidth;

  VScroll.Range := fviewabley;

  HScroll.enabled := fviewablex > Width;
  VScroll.enabled := fviewabley > Height;

  if not vscroll.enabled then vscroll.position := 0 else
    VScroll.position := Min(VScroll.position, fviewabley);

  scrollmoved(nil);

  Invalidate;
end;

function TCustomDrawGrid32.getrowheight(index: integer): integer;
begin
  result := frowheights[index];
end;

function TCustomDrawGrid32.getcolwidth(index: integer): integer;
begin
  result := fcolwidths[index];
end;

procedure TCustomDrawGrid32.setrowheight(index: integer; value: integer);
begin
  frowheights[index] := value;
end;

procedure TCustomDrawGrid32.setcolwidth(index: integer; value: integer);
begin
  fcolwidths[index] := value;
end;

procedure TCustomDrawGrid32.SetGridLineColor(value: Tcolor32);
begin
  if value <> fgridlinecolor then begin
    fgridlinecolor := value;
    changed;
  end;
end;

procedure TCustomDrawGrid32.SetGridLineWidth(value: integer);
begin
  if value < 0 then
    value := 0;

  if value <> fgridlinewidth then begin
    fgridlinewidth := value;
    Changed;
  end;
end;

procedure TCustomDrawGrid32.SetFixedRows(value: integer);
begin
  ffixedrows := value;
  Changed;
end;

procedure TCustomDrawGrid32.SetFixedCols(value: integer);
begin
  ffixedcols := value;
  Changed;
end;

procedure TCustomDrawGrid32.SetRowCount(value: integer);
var y: integer;
begin
  setlength(frowheights, value);

  if value > frowcount then //we need to initialize some new col widths
    for y := frowcount to value - 1 do
      frowheights[y] := DefaultRowHeight;
  frowcount := value;

  Changed;
end;

procedure TCustomDrawGrid32.SetColCount(value: integer);
var x: integer;
begin
  setlength(fcolwidths, value);

  if value > fcolcount then //we need to initialize some new col widths
    for x := fcolcount to value - 1 do
      fcolwidths[x] := DefaultColWidth;

  fcolcount := value;
  Changed;
end;

procedure TCustomDrawGrid32.SetColor(value: TColor32);
begin
  fcolor := value;
  Changed;
end;

procedure TCustomDrawGrid32.UpdateScrollBars;
begin
end;

procedure TCustomDrawGrid32.DrawCell(col, row: Integer; cellrect: Trect; state: TDrawState32);
begin
  //Do nothing. Descendants should choose how to draw cells
end;

procedure TCustomDrawGrid32.wheelmoved(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  Handled := true;
  VScroll.position := VScroll.position - wheeldelta div 2;
end;


procedure TCustomDrawGrid32.DoPaintBuffer;
var leftx, topy, x, y: integer;
begin
  buffer.Clear(Color);

  if ((frowcount = 0) and (fcolcount = 0)) or (buffer.width = 0) then exit;
  canvas.Brush.color := clBtnFace;
  canvas.FillRect(rect(width - VScroll.width, height - hscroll.height, width, height));

//  buffer.FillRect();

  leftx := 0;

  for x := 0 to ColCount - 1 do begin

    //will this column actually be visible?
    if not ((leftx - fxoffset > width - 1) or (leftx + fcolwidths[x] + fgridlinewidth - fxoffset < 0)) then begin

      buffer.FillRectS(leftx - fxoffset + fcolwidths[x], 0, leftx - fxoffset + fcolwidths[x] + fgridlinewidth, fviewabley - fyoffset, GridLineColor);

      topy := 0;
      for y := 0 to RowCount - 1 do begin
      //will this row be visible?
        if (not ((topy - fyoffset > height - 1) or (topy + frowheights[y] + fgridlinewidth - fyoffset < 0))) then begin
          buffer.FillRectS(0, topy - fyoffset + frowheights[y], fviewablex - fxoffset, topy - fyoffset + frowheights[y] + fgridlinewidth, GridLineColor);
          //cell is at least partially visible
          drawcell(x, y, rect(leftx - fxoffset, topy - fyoffset, leftx - fxoffset + fcolwidths[x], topy - fyoffset + frowheights[y]), []);

        end;
        inc(topy, frowheights[y] + fgridlinewidth);
      end;
    end;
    inc(leftx, fcolwidths[x] + fgridlinewidth); //move to next column
  end;

end;

constructor TCustomDrawGrid32.create(aOwner: Tcomponent);
begin
  inherited create(aOwner);
  HScroll := TRangeBar.Create(self);
  VScroll := TRangeBar.Create(self);

  HScroll.BorderStyle := bsNone;
  HScroll.Kind := sbHorizontal;
  HScroll.OnUserChange := scrollmoved;
  HScroll.left := 0;
  HScroll.height := SCROLLBARSIZE;
  HScroll.parent := self;

  VScroll.BorderStyle := bsNone;
  VScroll.Kind := sbVertical;
  VScroll.OnUserChange := scrollmoved;
  VScroll.parent := self;
  VScroll.top := 0;
  vscroll.width := SCROLLBARSIZE;

  OnMouseWheel := wheelmoved;

  Color := clWhite32;
  GridLineColor := clLightGray32;

  fgridlinewidth := 1;

  DefaultColWidth := 120;
  DefaultRowHeight := 80;

  Resize;
end;

constructor TDrawGrid32.Create(aOwner: Tcomponent);
begin
  inherited create(aowner);
  ColCount := 5;
  RowCount := 5;
end;

procedure TItemGrid32.resize;
begin
  inherited;
  //we'll need to reshuffle our items to fit
  if DefaultColWidth = 0 then colcount := 0 else
    colcount := min((Width - VScroll.width) div DefaultColWidth, fitemcount);

  if ColCount = 0 then rowcount := 0 else
    rowcount := ceil(ItemCount / ColCount);
end;

constructor TItemGrid32.Create(aOwner: Tcomponent);
begin
  inherited create(aowner);

  fselindex := -1;
  fgridlinewidth := 0;
  ItemCount := 5;
end;

procedure Register;
begin
  RegisterComponents('Standard', [TDrawGrid32, TItemGrid32]);
end;

end.

