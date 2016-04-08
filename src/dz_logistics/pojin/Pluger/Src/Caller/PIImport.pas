unit PIImport;

interface

uses Windows;

function InitPluger: Integer; stdcall;
function FreePluger: Integer; stdcall;

function inv_reset: Integer; stdcall;
function inv_open: Integer; stdcall;
function inv_close: Integer; stdcall;
function inv_lock: Integer; stdcall;
function inv_unlock: Integer; stdcall;
function inv_taxinfo(invoice_type: Integer; code, number, stock, taxcode, limit: PChar): Integer; stdcall;
function inv_create(invoice_type, tax_flag, mode, ntype: Integer; discount: Single;
  bill: PChar; bill_bufsize: Integer;
  invoice_code, invoice_number, date, amount, tax: PChar): Integer; stdcall;
function inv_cancel(invoice_type: Integer; invoice_number, invoice_code: PChar): Integer; stdcall;
function inv_getinfo(invoice_type: Integer; invoice_number, invoice_code, buff: PChar; bufsize: PInteger): Integer; stdcall;
function inv_getinfo_all(buff: PChar; bufsize: PInteger): Integer; stdcall;
function inv_getinfo_all2(list: PChar; buff: PChar; bufsize: PInteger; startdate, enddate: PChar; flag: Integer): Integer; stdcall;
function inv_print(list, invoice_number, invoice_code: PChar; ntype: Integer): Integer; stdcall;

implementation

const
  PlugerInterface = 'PlugerInterface.dll';

function InitPluger; external PlugerInterface name 'InitPluger';
function FreePluger; external PlugerInterface name 'FreePluger';   
function inv_reset; external PlugerInterface name 'inv_reset';
function inv_open; external PlugerInterface name 'inv_open';
function inv_close; external PlugerInterface name 'inv_close';
function inv_lock; external PlugerInterface name 'inv_lock';
function inv_unlock; external PlugerInterface name 'inv_unlock';
function inv_taxinfo; external PlugerInterface name 'inv_taxinfo';
function inv_create; external PlugerInterface name 'inv_create';
function inv_cancel; external PlugerInterface name 'inv_cancel';
function inv_getinfo; external PlugerInterface name 'inv_getinfo';
function inv_getinfo_all; external PlugerInterface name 'inv_getinfo_all';
function inv_getinfo_all2; external PlugerInterface name 'inv_getinfo_all2';
function inv_print; external PlugerInterface name 'inv_print';

end.
