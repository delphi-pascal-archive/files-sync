{
==============================================================================
|
|  Unit         : StringUtils.pas
|
|  Description  : Diff�rentes fonctions et proc�dures pour le traitements
|                 sur les cha�nes de caract�res.
|
==============================================================================
}
unit StringUtils;


interface

uses
  Windows, Controls, SysUtils, Graphics;


type

  TCharSet = set of Char;

  // Classe pour regrouper les fonctions de travail sur les 'String'
  TStr = class
    // M�thodes de conversion
    function  ColorToHex(const Color: TColor): string;
    function  HexToColor(const sColor: string): TColor;
    // M�thodes pour tokens
    function  GetToken(const sLine, sSepar: string; nTokenNum: byte): string;
    // M�thodes pour des "string" simples
    function  ReductPathname (const sPath: string): string;
    procedure SplitString (const sPath: string; var sLeft, sRight: string;
                           const Separators: TCharSet; const bRight: boolean = TRUE);
    function  ThousandSep (const nVal: int64): string;
    // M�thodes pour des "string array" simples
    procedure StrSort(var aStr: array of string);
    // M�thodes pour v�riques
    function  IsNumeric (const sVal: ShortString): boolean;
    function  FileSizeAutoStr (const nSize: int64): string; overload;
    function  FileSizeAutoStr (const sSize: string): string; overload;
  end;

var

  Str : TStr;

implementation

{
==============================================
|  Conversion d'un TColor en string          |
|--------------------------------------------|                                              |
|  Param�tres :                              |
|  - Color  : Le TColor a convertir          |
|--------------------------------------------|                                              |
|  Valeur de retour:                         |
|  - String : Le string contenant le Tcolor  |
==============================================
}
function TStr.ColorToHex (const Color: TColor): string;
begin
  Result := IntToHex (GetRValue (Color), 2) +   { Valeur pour le rouge }
            IntToHex (GetGValue (Color), 2) +   { Valeur pour le vert }
            IntToHex (GetBValue (Color), 2);    { Valeur pour le bleu }
end;

{
==============================================
|  Conversion d'un String en TColor          |
|--------------------------------------------|                                              |
|  Param�tres :                              |
|  - sColor  : Le string a convertir         |
|--------------------------------------------|                                              |
|  Valeur de retour:                         |
|  - TColor : Le TColor � partir d'un string |
==============================================
}
function TStr.HexToColor(const sColor: string): TColor;
begin
  Result := RGB (StrToInt('$' + Copy(sColor, 1, 2)),  { Valeur pour le rouge }
                 StrToInt('$' + Copy(sColor, 3, 2)),   { Valeur pour le vert }
                 StrToInt('$' + Copy(sColor, 5, 2)));  { Valeur pour le bleu }
end;

{
==============================================================================
========================  M�thodes pour tokens  ==============================
==============================================================================
}

{
=================================================
|  Extraction d'un token � partir d'une string  |
|  Le s�parateur de tokens doit �tre ';'        |
|-----------------------------------------------|
|  Param�tres :                                 |
|  - sLine      : ligne contenant les tokens    |
|  - sSepar     : caract�re de s�paration       |
|  - nTokenNum  : num�ro d'ordre du token       |
|-----------------------------------------------|
|  Valeur de retour :                           |
|  - string : le token trouv�                   |
=================================================
}
function TStr.GetToken (const sLine, sSepar: string; nTokenNum: byte): String;
var
  nNum        : Integer;
  nStrLen     : Integer;
  nEndOfToken : Integer;
  sText       : string;
  sToken      : string;
begin
  sText := sLine;
  nStrLen := Length(sText);
  nNum := 1;
  nEndofToken := nStrLen;
  while ((nNum <= nTokenNum) and (nEndofToken <> 0)) do begin
    nEndofToken := Pos(sSepar, sText);
    if nEndofToken <> 0 then begin
      sToken := Copy(sText, 1, nEndofToken - 1);
      Delete(sText, 1, nEndofToken);
      Inc(nNum);
    end else
      sToken := sLine;
  end; 
  if nNum > nTokenNum then
    Result := sToken
  else 
    Result := '';
end;

{
==============================================================================
==================  M�thodes pour des "string" simples  ======================
==============================================================================
}
{
=================================================================================
|  D�composition d'un chemin d'acc�s                                            |
|-------------------------------------------------------------------------------|                                              |
|  Param�tres :                                                                 |
|  - sPath      : chemin et nom de fichier � d�composer                         |
|-------------------------------------------------------------------------------|                                              |
|  Valeur de retour :                                                           |
|  - string  : nom du chemin du fichier tronqu� au milieu                       |
=================================================================================
}
function TStr.ReductPathname (const sPath: string): string;
var
  sStr : string;

      function ReverseString (sStr: string; nLen: integer): string;
        var nCount: integer;
      begin
        Result := '';
        if nLen > Length(sStr) then nLen := Length(sStr);
        for nCount := 1 to nLen do
          Result := sStr[nCount] + Result
      end;

begin
  sStr := sPath;
  Result := sStr;
  if Length(sStr) < 40 then
    Exit;
  sStr := ReverseString (sStr, 65535);
  Result := ReverseString (sStr, Pos('\', sStr));
  sStr := ReverseString (sStr, 65535);
  Result := ' . . . ' + Result;
  Result := Copy(sStr, 1, Pos('\', sStr))+ Result
end;

{
=================================================================================
|  D�composition d'un chemin d'acc�s                                            |
|-------------------------------------------------------------------------------|                                              |
|  Param�tres :                                                                 |
|  - sPath      : chemin et nom de fichier � d�composer                         |
|  - sLeft      : R�cup�re la partie gauche (le chemin du r�pertoire)           |
|  - sRight     : R�cup�re la partie droite (le nom du fichier + l'extension)   |
|  - Separators : Contient le ou les s�parateurs possibles                      |
|  - bRight     : Si TRUE s�paration � partir de la droite, sinon de la gauche  |
=================================================================================
}
procedure TStr.SplitString (const sPath: string; var sLeft, sRight: string;
                            const Separators: TCharSet; const bRight: boolean = TRUE);
var
  nLen  : integer;
begin
  // Traitement d'un string vide
  if sPath = '' then begin
    SLeft := '';
    SRight := '';
    Exit;
  end;
  //
  // S�paration de la string
  if bRight then begin
    // A partir de la droite
    nLen := Length(sPath);
    while (nLen > 0) and not (sPath[nLen] in Separators) do
      Dec(nLen);
    if nLen = 0 then begin
      SLeft := '';
      SRight := sPath;
    end else begin
      SLeft := Copy(sPath, 1, nLen - 1);
      SRight := Copy(sPath, nLen + 1, Length(sPath) - nLen);
    end;
  end else begin
    // A partir de la gauche
    nLen := 0;
    while (nLen <= Length(sPath)) and not (sPath[nLen] in Separators) do
      Inc(nLen);
    if nLen > Length(sPath) then begin
      SLeft := sPath;
      SRight := '';
    end else begin
      SLeft := Copy(sPath, 1, nLen - 1);
      SRight := Copy(sPath, nLen + 1,Length(sPath) - nLen);
    end;
  end;
end;

{
============================================================================
|  Retourne la valeur sous forme d'une string avec s�parateur des milliers |
|--------------------------------------------------------------------------|
|  Param�tre :                                                             |
|  - nVal : Valeur num�rique � transformer en string avec s�parateur       |
|--------------------------------------------------------------------------|
|  Valeur de retour :                                                      |
|  - string : Valeur cha�ne de caract�res format�e avec des s�parateurs    |
============================================================================
}
function TStr.ThousandSep(const nVal: int64): string;
var
  i       : integer;
  nLen    : integer;
  nCount  : integer;
  sValue  : string;
begin
  sValue := IntToStr(nVal);
  Result := Trim(sValue);
  // Si pas besoin de s�parateur
  if Length(sValue) < 4 then
    Exit;
  //
  // Ajout d'un ou des s�parateurs
  nLen := 0;
  nCount := 1;
  for i := length(sValue) downto 1 do begin
    if (nCount mod 3) = 0 then begin
      Insert(ThousandSeparator, Result, i - nLen);
      nCount := 1;
      inc(nLen);
    end;
    inc(nCount);
  end;
  // Correction si un s�parateur a �t� ajout� en d�but de string
  if Result[1] = ThousandSeparator then
    Result := Copy (Result, 2, Length (Result) - 1);
end;

{
==============================================================================
===============  M�thodes pour des "string array" simples  ===================
==============================================================================
}
{
=====================================================================
|  Proc�dure pour tri d'une liste de strings � une dimmension       |
|-------------------------------------------------------------------|
|  Param�tre :                                                      |
|  - aStr : Liste � trier / la liste est tri�e en fin de proc�dure  |
=====================================================================
}

procedure TStr.StrSort(var aStr: array of string);
var
  sTemp : string;

    {-------------------------------------
    |  Partitionnement en 2 sous-listes  |
    -------------------------------------}
    function Partition (const m, n: integer): integer;
    var
      i : integer;
      j : integer;
      v : string;
    begin
      v := aStr[m];
      i := m - 1;
      j := n + 1;
      while TRUE do begin
        repeat Dec(j) until aStr[j] <= v;
        repeat Inc(i) until aStr[i] >= v;
        if (i<j) then begin
          sTemp := aStr[i];
          aStr[i] := aStr[j];
          aStr[j] := sTemp;
        end
        else begin
          Result := j;
          Exit;
        end;
      end;
    end;

  {-------------------------------------------
  |  Gestion du partitionnement du quickSort |
  -------------------------------------------}
  procedure QuickSort (const m, n: integer);
  var
    nPivot: integer;
  begin
    if m < n then begin
      nPivot := partition (m, n);
      QuickSort (m, nPivot);
      QuickSort (nPivot + 1, n);
    end;
  end;

  begin
    QuickSort (Low (aStr), High (aStr));
end;


{
==============================================================================
=================  M�thodes pour la taille des fichiers  =====================
==============================================================================
}
{
=====================================================================
|  Teste si le contenu de la string ne cotient que des chiffres     |
|-------------------------------------------------------------------|
|  Param�tre :                                                      |
|  - sVal : String � contr�ler                                      |
|-------------------------------------------------------------------|
|  Valeur de retour :                                               |
|  - boolan : TRUE si num�rique, sinon FALSE                        |
=====================================================================
}
function TStr.IsNumeric (const sVal: ShortString): boolean;
var
   bNum : boolean;
   nInd	: integer;
   nLen	: integer;
begin
 	bNum := TRUE;
  nLen := Length (sVal);
  if nLen = 0 then
     bNum := False
  else begin
    {--- Teste si que des chiffres et point d�cimal ---}
    for nInd := 1 to nLen do begin
   	  if (sVal[nInd] < '0') or (sVal[nInd] > '9') then begin
        if (sVal[nInd] <> '.') then
          bNum := False;
      end;
    end;
  end;
  IsNumeric := bNum;
end;

{
=====================================================================
|  Conversion automatique en notation scientifique de la taille     |
|  d'un fichier avec arroondi � l'unit� sup�rieure                  |
|-------------------------------------------------------------------|
|  Param�tre :                                                      |
|  - nSize : taille du fichier au format int 64                     |
|-------------------------------------------------------------------|
|  Valeur de retour :                                               |
|  - string : Taille ajust�e suivie de l'unit�                      |
=====================================================================
}
function TStr.FileSizeAutoStr (const nSize: int64): string;
const
  i64GB = 1024 * 1024 * 1024;
  i64MB = 1024 * 1024;
  i64KB = 1024;
begin
  if nSize div i64GB > 0 then
    Result := Format('%.2f Go', [nSize / i64GB])
  else if nSize div i64MB > 0 then
    Result := Format('%.2f Mo', [nSize / i64MB])
  else {if nSize div i64KB > 0 then}
    Result := Format('%.2f Ko', [nSize / i64KB]);
end;

{
=====================================================================
|  Conversion automatique en notation scientifique de la taille     |
|  d'un fichier avec arroondi � l'unit� sup�rieure                  |
|-------------------------------------------------------------------|
|  Param�tre :                                                      |
|  - sSize : taille du fichier au format string                     |
|-------------------------------------------------------------------|
|  Valeur de retour :                                               |
|  - string : Taille ajust�e suivie de l'unit�                      |
=====================================================================
}
function TStr.FileSizeAutoStr (const sSize: string): string;
begin
  if IsNumeric (sSize) then
    Result := FileSizeAutoStr (StrToInt64Def (sSize, 0));
end;

end.
