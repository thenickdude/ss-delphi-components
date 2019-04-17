unit SSCollapsePanelReg;

interface

uses sysutils,classes,SSCollapsePanelEditor,SSCollapsePanelGroup,dsgnintf;

procedure Register;

implementation

procedure Register;
begin
 RegisterComponents('Sherlock Software',[TSSCollapsePanelGroup,TSSCollapsePanel]);
 RegisterComponentEditor(TSSCollapsePanelGroup,TSSCollapsePanelEditor);
end;

end.
