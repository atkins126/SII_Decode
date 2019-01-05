{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
unit SII_Decode_ValueNode_00000004;

{$INCLUDE '.\SII_Decode_defs.inc'}

interface

uses
  Classes,
  SII_Decode_Common, SII_Decode_ValueNode;

{===============================================================================
--------------------------------------------------------------------------------
                           TSIIBin_ValueNode_00000004
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSIIBin_ValueNode_00000004 - declaration
===============================================================================}
type
  TSIIBin_ValueNode_00000004 = class(TSIIBin_ValueNode)
  // array of encoded string (UInt64)
  private
    fValue:     array of UInt64;
    fValueStr:  array of AnsiString;
  protected
    procedure Initialize; override;
    Function GetValueType: TSIIBin_ValueType; override;
    procedure Load(Stream: TStream); override;
  public
    Function AsString: AnsiString; override;
    Function AsLine(IndentCount: Integer = 0): AnsiString; override;
  end;

implementation

uses
  SysUtils,
  BinaryStreaming, StrRect, ExplicitStringLists,
  SII_Decode_Utils;

{===============================================================================
--------------------------------------------------------------------------------
                           TSIIBin_ValueNode_00000004
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TSIIBin_ValueNode_00000004 - implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TSIIBin_ValueNode_00000004 - protected methods
-------------------------------------------------------------------------------}

procedure TSIIBin_ValueNode_00000004.Initialize;
var
  i:  Integer;
begin
SetLength(fValueStr,Length(fValue));
For i := Low(fValueStr) to High(fValueStr) do
  fValueStr[i] := SIIBin_DecodeID(fValue[i]);
end;

//------------------------------------------------------------------------------

Function TSIIBin_ValueNode_00000004.GetValueType: TSIIBin_ValueType;
begin
Result := $00000004;
end;

//------------------------------------------------------------------------------

procedure TSIIBin_ValueNode_00000004.Load(Stream: TStream);
var
  i:  Integer;
begin
SetLength(fValue,Stream_ReadUInt32(Stream));
For i := Low(fValue) to High(fValue) do
  fValue[i] := Stream_ReadUInt64(Stream);
end;

{-------------------------------------------------------------------------------
    TSIIBin_ValueNode_00000004 - public methods
-------------------------------------------------------------------------------}

Function TSIIBin_ValueNode_00000004.AsString: AnsiString;
begin
Result := StrToAnsi(Format('%d',[Length(fValue)]));
end;

//------------------------------------------------------------------------------

Function TSIIBin_ValueNode_00000004.AsLine(IndentCount: Integer = 0): AnsiString;
var
  i:  Integer;
begin
If Length(fValue) >= TSIIBin_LargeArrayThreshold then
  begin
    with TAnsiStringList.Create do
    try
      TrailingLineBreak := False;
      AddDef(StringOfChar(' ',IndentCount) + Format('%s: %d',[Name,Length(fValue)]));
      For i := Low(fValue) to High(fValue) do
        If fValue[i] <> 0 then
          AddDef(StringOfChar(' ',IndentCount) + Format('%s[%d]: %s',[Name,i,fValueStr[i]]))
        else
          AddDef(StringOfChar(' ',IndentCount) + Format('%s[%d]: ""',[Name,i]));
      Result := Text;
    finally
      Free;
    end;
  end
else
  begin
    Result := StrToAnsi(StringOfChar(' ',IndentCount) + Format('%s: %d',[Name,Length(fValue)]));
    For i := Low(fValue) to High(fValue) do
      If fValue[i] <> 0 then
        Result := Result + StrToAnsi(sLineBreak + StringOfChar(' ',IndentCount) +
                  Format('%s[%d]: %s',[Name,i,fValueStr[i]]))
      else
        Result := Result + StrToAnsi(sLineBreak + StringOfChar(' ',IndentCount) +
                  Format('%s[%d]: ""',[Name,i]));
  end;
end;

end.
