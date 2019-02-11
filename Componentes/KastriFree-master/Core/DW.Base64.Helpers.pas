unit DW.Base64.Helpers;

{*******************************************************}
{                                                       }
{                    Kastri Free                        }
{                                                       }
{          DelphiWorlds Cross-Platform Library          }
{                                                       }
{*******************************************************}

{$I DW.GlobalDefines.inc}

interface

uses
  // RTL
  System.Classes;

type
  TBase64Helper = record
  public
    class function CompressEncode(const ASource: string): string; overload; static;
    class function CompressEncode(const AStream: TStream): string; overload; static;
    class function DecodeDecompress(const ASource: string): string; overload; static;
    class procedure DecodeDecompress(const ASource: string; const AStream: TStream); overload; static;
  end;

implementation

uses
  // RTL
  System.SysUtils, System.ZLib, System.NetEncoding;

{ TBase64Helper }

class function TBase64Helper.CompressEncode(const ASource: string): string;
var
  LStream: TStream;
begin
  LStream := TStringStream.Create(ASource);
  try
    Result := CompressEncode(LStream);
  finally
    LStream.Free;
  end;
end;

class function TBase64Helper.CompressEncode(const AStream: TStream): string;
var
  LCompressedStream: TStream;
  LBase64Stream: TStringStream;
begin
  AStream.Position := 0;
  LCompressedStream := TMemoryStream.Create;
  try
    ZCompressStream(AStream, LCompressedStream);
    LCompressedStream.Position := 0;
    LBase64Stream := TStringStream.Create('', TEncoding.ASCII);
    try
      TNetEncoding.Base64.Encode(LCompressedStream, LBase64Stream);
      Result := LBase64Stream.DataString;
    finally
      LBase64Stream.Free;
    end;
  finally
    LCompressedStream.Free;
  end;
end;

class function TBase64Helper.DecodeDecompress(const ASource: string): string;
var
  LStringStream: TStringStream;
begin
  LStringStream := TStringStream.Create;
  try
    DecodeDecompress(ASource, LStringStream);
    Result := LStringStream.DataString;
  finally
    LStringStream.Free;
  end;
end;

class procedure TBase64Helper.DecodeDecompress(const ASource: string; const AStream: TStream);
var
  LCompressedStream: TStream;
  LBase64Stream: TStream;
begin
  AStream.Position := 0;
  LCompressedStream := TMemoryStream.Create;
  try
    LBase64Stream := TStringStream.Create(ASource, TEncoding.ASCII);
    try
      TNetEncoding.Base64.Decode(LBase64Stream, LCompressedStream);
      LCompressedStream.Position := 0;
      ZDecompressStream(LCompressedStream, AStream);
    finally
      LBase64Stream.Free;
    end;
  finally
    LCompressedStream.Free;
  end;
end;

end.
