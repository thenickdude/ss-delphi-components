unit SSCollapsePanelGroup;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, contnrs, Forms, Dialogs,
  ExtCtrls;

type
  TSSCollapsePanel = class(TCustomPanel)
  private
    fcollapsed: Boolean;
    procedure setcollapsed(value: Boolean);
  public
    property Collapsed: boolean read fcollapsed write setcollapsed;
  published
  end;

  TSSCollapsePanelGroup = class(TCustomPanel)
  private
//    fpanels:TObjectList;
    procedure LayoutPanels;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    procedure Loaded; override;
    function GetChildOwner: TComponent; override;
    procedure WriteState(Writer: TWriter); override;
    procedure ReadState(Reader: TReader); override;
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    procedure AddPanel;
    constructor Create(aOwner: TComponent); override;
    destructor destroy; override;
  published
    property Align;
  end;

implementation

procedure TSSCollapsePanel.setcollapsed(value: Boolean);
begin
  fcollapsed := value;
end;

procedure TSSCollapsePanelGroup.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  LayoutPanels;
end;

procedure TSSCollapsePanelGroup.Loaded;
var i: integer;
begin
  for i := 0 to controlcount - 1 do
    controls[i].parent := self;

  inherited;
  LayoutPanels;
end;

procedure TSSCollapsePanelGroup.LayoutPanels;
var y, t1: integer;
  panel: TSSCollapsePanel;
begin
  if controlcount = 0 then exit; //dont resize
  y := 0;
  for t1 := 0 to controlcount - 1 do
    inc(y, TSSCollapsePanel(controls[t1]).Height);
  if (csDesigning in ComponentState) then
    y := y + 50; //Give the designer something to hold on to!
  height := y;

  y := 0;
  for t1 := 0 to controlcount - 1 do begin
    panel := TSSCollapsePanel(controls[t1]);
    panel.left := 0;
    panel.width := ClientWidth;
    panel.top := y;
    inc(y, panel.Height);
  end;

end;

procedure TSSCollapsePanelGroup.WriteState(Writer: TWriter);
begin
  if writer.Ancestor = nil then
    inherited WriteState(writer);
end;

procedure TSSCollapsePanelGroup.ReadState(Reader: TReader);
var i: integer;
begin
  for i := controlcount - 1 downto 0 do
    controls[i].free;
  inherited;
end;

function TSSCollapsePanelGroup.GetChildOwner: TComponent;
begin
  //set the child owner to the form as they are streamed in
  if owner = nil then
    result := self else
    result := owner;
end;

procedure TSSCollapsePanelGroup.GetChildren(Proc: TGetChildProc; Root: TComponent);
var t1: integer;
begin
  //Our children should be "owned" by us, even though they are really owned by the form
  for t1 := 0 to ControlCount - 1 do
    Proc(Controls[t1]);
end;

procedure TSSCollapsePanelGroup.AddPanel;
var panel: TSSCollapsePanel;
  t1: integer;
begin
  panel := TSSCollapsePanel.Create(parent); //Form should own our children

  {Note: from 0 to count. That's one more number than the amount of panels we\
  are holding. Guarantees that there is a gap in this range.}
  for t1 := 0 to ControlCount do
    if FindComponent('Panel' + inttostr(t1)) = nil then begin
      panel.name := 'Panel' + inttostr(t1);
      break;
    end;
  if panel.Name = '' then begin
    panel.Free; //we have failed in our mission... erase all evidence!
  end else begin
    panel.parent := self; //but they are our graphical children
    LayoutPanels;
  end;
end;

constructor TSSCollapsePanelGroup.Create(aOwner: TComponent);
begin
  inherited;
  ControlStyle := ControlStyle - [csAcceptsControls]; //we only want self managed panels on us
end;

destructor TSSCollapsePanelGroup.destroy;
begin
  inherited;
end;

end.

