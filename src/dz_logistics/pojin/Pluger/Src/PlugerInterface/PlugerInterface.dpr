library PlugerInterface;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }



uses
  Windows,
  Forms,
  SysUtils,
  Classes,
  PIExport in 'PIExport.pas',
  SyncMsg in 'SyncMsg.pas' {frmSyncMsg},
  GlobalDefine in '..\Public\GlobalDefine.pas';

{$R *.RES}

Exports
  InitPluger,
  FreePluger,  
  inv_reset,
  inv_open,
  inv_close,
  inv_lock,
  inv_unlock,
  inv_taxinfo,
  inv_create,
  inv_cancel,
  inv_getinfo,
  inv_getinfo_all,
  inv_getinfo_all2,
  inv_print;

begin
  AdjustProcessPrivilege(SeDebugPrivilege, True);
end.
