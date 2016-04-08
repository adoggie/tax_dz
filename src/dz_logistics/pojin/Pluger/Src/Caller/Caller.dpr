program Caller;



uses
  Forms,
  Main in 'Main.pas' {frmMain},
  PIImport in 'PIImport.pas',
  GlobalDefine in '..\Public\GlobalDefine.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
