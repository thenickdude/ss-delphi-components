unit SSCollapsePanelReg;

interface

uses sysutils,classes,SSCollapsePanelEditor,SSCollapsePanelGroup,dsgnintf;

procedure Register;

implementation

procedure Register;
begin
 RegisterComponents('Standard',[TSSCollapsePanelGroup,TSSCollapsePanel]);
 RegisterComponenteditor(TSSCollapsePanelGroup,TSSCollapsePanelEditor);
end;

end.
