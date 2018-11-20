unit SSCollapsePanelEditor;

interface

uses sysutils, windows, classes, DsgnIntf,contnrs, menus,
 sscollapsepanelgroup,dialogs;

type TSSCollapsePanelEditor = class(TComponentEditor)
  public
    function GetVerbCount: Integer; override;
    function GetVerb(Index: Integer): string; override;
    procedure ExecuteVerb(Index: Integer); override;
    procedure PrepareItem(Index: Integer; const AItem: TMenuItem); override;
  end;

implementation

function TSSCollapsePanelEditor.GetVerbCount: Integer;
begin
  result := 1;
end;

function TSSCollapsePanelEditor.GetVerb(Index: Integer): string;
begin
  result := 'Add';
end;

procedure TSSCollapsePanelEditor.ExecuteVerb(Index: Integer);
begin
case index of
 0:tsscollapsepanelgroup(component).addpanel;
 end;
end;

procedure TSSCollapsePanelEditor.PrepareItem(Index: Integer; const AItem: TMenuItem);
begin
    //nop
end;

end.

