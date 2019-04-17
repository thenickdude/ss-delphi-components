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
    FXOffset, FYOffset: integer;
    FViewableX, FViewableY: integer;

    FColor: tcolor32;

    FRowCount, FColCount: integer;

    FFixedRows, FFixedCols: integer;

    FGridlineWidth: integer;
    FGridlineColor: TColor32;

    FDefaultRowHeight, FDefaultColWidth: integer;

    FColWidths, FRowHeights: array of integer;

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

    procedure WheelMoved(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);

    function CellRect(col, row: integer): TRect;

    procedure SelectCell(col, row: integer); virtual;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;

    procedure Changed; virtual;
    procedure DoPaintBuffer; override;
    procedure UpdateScrollBars; virtual;
    procedure DrawCell(col, row: Integer; cellrect: Trect; state: TDrawState32); virtual;

    property DefaultColWidth: integer read FDefaultColWidth write FDefaultColWidth;
    property DefaultRowHeight: integer read FDefaultRowHeight write FDefaultRowHeight;

    property GridLineWidth: integer read FGridlineWidth write setgridlinewidth;
    property GridLineColor: TColor32 read FGridlineColor write setgridlinecolor;

    property FixedRows: integer read FFixedRows write setfixedrows;
    property FixedCols: integer read FFixedCols write setfixedcols;
    property RowCount: integer read FRowCount write setrowcount;
    property ColCount: integer read FColCount write setcolcount;

    property ColWidths[index: integer]: integer read getcolwidth write setcolwidth;
    property RowHeights[index: integer]: integer read getrowheight write setrowheight;
  public
    function GetViewportRect: TRect; override;
    procedure Resize; override;
    constructor Create(aOwner: Tcomponent); override;
  published
    property Constraints;
    property Align;
    property Anchors;
    property Enabled;
    property Color: TColor32 read FColor write SetColor;
  end;

  TItemGrid32 = class(TCustomDrawGrid32)
  private
    FSelIndex: integer;
    FItemCount: integer;

    FOnDrawItem: TDrawItem32Event;
    FOnSelectCell: TSelectItem32Event;

    procedure SetItemCount(value: integer);
    procedure SetSelIndex(value: integer);
  protected
    procedure SelectCell(col, row: integer); override;
    procedure DrawCell(col, row: Integer; cellrect: Trect; state: TDrawState32); override;
  public
    procedure Resize; override;
    constructor Create(aOwner: Tcomponent); override;
  published
    property SelIndex: integer read FSelIndex write SetSelIndex;
    property GridLineColor;
    property GridLineWidth default 0;
    property DefaultColWidth;
    property DefaultRowHeight;
    property ItemCount: integer read FItemCount write SetItemCount nodefault;
    property OnDrawItem: TDrawItem32Event read FOnDrawItem write FOnDrawItem;
    property OnSelectCell: TSelectItem32Event read FOnSelectCell write FOnSelectCell;
  end;

  TDrawGrid32 = class(TCustomDrawGrid32)
  private
    FOnDrawCell: TDrawCell32Event;
  protected
    procedure DrawCell(col, row: Integer; cellrect: Trect; state: TDrawState32); override;
  public
    property ColWidths;
    property RowHeights;
    constructor Create(aOwner: Tcomponent); override;
  published
    property OnDrawCell: TDrawCell32Event read FOnDrawCell write FOnDrawCell;
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

procedure TItemGrid32.SetSelIndex(value: integer);
var oldrect, newrect: trect;
begin
  if value < 0 then value := -1; //Normalize

  if FSelIndex <> value then begin

    if FSelIndex <> -1 then begin
      oldrect := cellrect(FSelIndex mod ColCount, FSelIndex div ColCount);
      InvalidateRect(Handle, @oldrect, true);
    end;

    if value <> -1 then begin
      newrect := cellrect(value mod ColCount, value div ColCount);
      InvalidateRect(Handle, @newrect, true);
    end;

    FSelIndex := value;

  end;
end;

procedure TItemGrid32.SetItemCount(value: integer);
begin
  if FItemCount <> value then begin
    FItemCount := value;
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
    if FSelIndex = cellindex then
      Include(state, dsSelected);
    OnDrawItem(buffer, cellindex, cellrect, state);
  end;
end;

function TCustomDrawGrid32.GetViewPortRect: TRect;
begin
  result.Left :=0;
  result.top :=0;
  result.Right := Max(Width - SCROLLBARSIZE, 0);
  result.Bottom := Max(Height - SCROLLBARSIZE, 0);
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
var
  x, y: integer;
  accx, accy: integer;
begin
  accx := -FXOffset;

  for x := 0 to col - 1 do
    accx := accx + ColWidths[x] + GridLineWidth;

  accy := -FYOffset;

  for y := 0 to row - 1 do
    accy := accy + RowHeights[y] + GridLineWidth;

  result := rect(accx, accy, accx + ColWidths[col], accy + rowheights[row]);
end;

procedure TCustomDrawGrid32.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  col, row: integer;
  accx, accy: integer;
begin
  if PtInRect(GetViewPortRect, point(x, y)) then begin
    x := x + FXOffset;
    y := y + FYOffset;

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
  FXOffset := round(HScroll.position);
  FYOffset := round(VScroll.position);
  invalidate;
end;

procedure TCustomDrawGrid32.Changed;
var t1: integer;
begin
  //our contained size could have changed (rows/cols). Update scrollbars and viewable
  FViewableX := 0;
  for t1 := 0 to colcount - 1 do
    FViewableX := FViewableX + colwidths[t1] + GridLineWidth;

  HScroll.Range := FViewableX;

  FViewableY := 0;
  for t1 := 0 to rowcount - 1 do
    FViewableY := FViewableY + rowheights[t1] + GridLineWidth;

  VScroll.Range := FViewableY;

  HScroll.enabled := FViewableX > Width;
  VScroll.enabled := FViewableY > Height;

  if not vscroll.enabled then vscroll.position := 0 else
    VScroll.position := Min(VScroll.position, FViewableY);

  scrollmoved(nil);

  Invalidate;
end;

function TCustomDrawGrid32.getrowheight(index: integer): integer;
begin
  result := FRowHeights[index];
end;

function TCustomDrawGrid32.getcolwidth(index: integer): integer;
begin
  result := FColWidths[index];
end;

procedure TCustomDrawGrid32.setrowheight(index: integer; value: integer);
begin
  FRowHeights[index] := value;
end;

procedure TCustomDrawGrid32.setcolwidth(index: integer; value: integer);
begin
  FColWidths[index] := value;
end;

procedure TCustomDrawGrid32.SetGridLineColor(value: Tcolor32);
begin
  if value <> FGridlineColor then begin
    FGridlineColor := value;
    changed;
  end;
end;

procedure TCustomDrawGrid32.SetGridLineWidth(value: integer);
begin
  if value < 0 then
    value := 0;

  if value <> FGridlineWidth then begin
    FGridlineWidth := value;
    Changed;
  end;
end;

procedure TCustomDrawGrid32.SetFixedRows(value: integer);
begin
  FFixedRows := value;
  Changed;
end;

procedure TCustomDrawGrid32.SetFixedCols(value: integer);
begin
  FFixedCols := value;
  Changed;
end;

procedure TCustomDrawGrid32.SetRowCount(value: integer);
var y: integer;
begin
  setlength(FRowHeights, value);

  if value > FRowCount then //we need to initialize some new col widths
    for y := FRowCount to value - 1 do
      FRowHeights[y] := DefaultRowHeight;
  FRowCount := value;

  Changed;
end;

procedure TCustomDrawGrid32.SetColCount(value: integer);
var x: integer;
begin
  setlength(FColWidths, value);

  if value > FColCount then //we need to initialize some new col widths
    for x := FColCount to value - 1 do
      FColWidths[x] := DefaultColWidth;

  FColCount := value;
  Changed;
end;

procedure TCustomDrawGrid32.SetColor(value: TColor32);
begin
  FColor := value;
  Changed;
end;

procedure TCustomDrawGrid32.UpdateScrollBars;
begin
end;

procedure TCustomDrawGrid32.DrawCell(col, row: Integer; cellrect: Trect; state: TDrawState32);
begin
  //Do nothing. Descendants should choose how to draw cells
end;

procedure TCustomDrawGrid32.WheelMoved(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  Handled := true;
  VScroll.position := VScroll.position - wheeldelta div 2;
end;


procedure TCustomDrawGrid32.DoPaintBuffer;
var leftx, topy, x, y: integer;
begin
  buffer.Clear(Color);

  if ((FRowCount = 0) and (FColCount = 0)) or (buffer.width = 0) then exit;
  canvas.Brush.color := clBtnFace;
  canvas.FillRect(rect(width - VScroll.width, height - hscroll.height, width, height));

//  buffer.FillRect();

  leftx := 0;

  for x := 0 to ColCount - 1 do begin

    //will this column actually be visible?
    if not ((leftx - FXOffset > width - 1) or (leftx + FColWidths[x] + FGridlineWidth - FXOffset < 0)) then begin

      buffer.FillRectS(leftx - FXOffset + FColWidths[x], 0, leftx - FXOffset + FColWidths[x] + FGridlineWidth, FViewableY - FYOffset, GridLineColor);

      topy := 0;
      for y := 0 to RowCount - 1 do begin
      //will this row be visible?
        if (not ((topy - FYOffset > height - 1) or (topy + FRowHeights[y] + FGridlineWidth - FYOffset < 0))) then begin
          buffer.FillRectS(0, topy - FYOffset + FRowHeights[y], FViewableX - FXOffset, topy - FYOffset + FRowHeights[y] + FGridlineWidth, GridLineColor);
          //cell is at least partially visible
          drawcell(x, y, rect(leftx - FXOffset, topy - FYOffset, leftx - FXOffset + FColWidths[x], topy - FYOffset + FRowHeights[y]), []);

        end;
        inc(topy, FRowHeights[y] + FGridlineWidth);
      end;
    end;
    inc(leftx, FColWidths[x] + FGridlineWidth); //move to next column
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

  OnMouseWheel := WheelMoved;

  Color := clWhite32;
  GridLineColor := clLightGray32;

  FGridlineWidth := 1;

  DefaultColWidth := 120;
  DefaultRowHeight := 80;
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

  // We'll need to reshuffle our items to fit
  if DefaultColWidth = 0 then colcount := 0 else
    colcount := min((Width - VScroll.width) div DefaultColWidth, FItemCount);

  if ColCount = 0 then rowcount := 0 else
    rowcount := ceil(ItemCount / ColCount);
end;

constructor TItemGrid32.Create(aOwner: Tcomponent);
begin
  inherited create(aowner);

  FSelIndex := -1;
  FGridlineWidth := 0;
  ItemCount := 5;
end;

procedure Register;
begin
  RegisterComponents('Sherlock Software', [TDrawGrid32, TItemGrid32]);
end;

end.

