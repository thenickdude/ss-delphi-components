unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, GR32_Image, DrawGrid32, ExtCtrls, gr32, math;

type
  TForm1 = class(TForm)
    drwgrd1: TDrawGrid;
    grd32: TDrawGrid32;
    img1: TImgView32;
    ItemGrid321: TItemGrid32;
    procedure drwgrd1DrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure grd32DrawCell(buffer: TBitmap32; col, row: Integer;
      cellrect: TRect; state: TDrawState32);
    procedure ItemGrid321DrawItem(buffer: TBitmap32; itemindex: Integer;
      cellrect: TRect; state: TDrawState32);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.drwgrd1DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
  drwgrd1.Canvas.Brush.Color := Random($FFFFFF);
  drwgrd1.Canvas.FillRect(rect);
end;

procedure TForm1.grd32DrawCell(buffer: TBitmap32; col, row: Integer;
  cellrect: TRect; state: TDrawState32);
begin
  buffer.FillRectS(cellrect, 255 - min(col * row * 20, 255));
end;

procedure TForm1.ItemGrid321DrawItem(buffer: TBitmap32; itemindex: Integer;
  cellrect: TRect; state: TDrawState32);
begin
//  buffer.fillrects(cellrect, clwhite32);
  if dsSelected in state then
    buffer.FillRectS(cellrect, (255 - min(itemindex * 20, 255)) shl 8) else

    buffer.FillRectS(cellrect, 255 - min(itemindex * 20, 255));

  buffer.font.color := clWhite;
  buffer.Textout(cellrect.left, cellrect.top, inttostr(itemindex));
end;

end.

