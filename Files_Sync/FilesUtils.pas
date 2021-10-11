{
==============================================================================
|                                                                            |
|  Unit         : FilesUtils.pas                                             |
|                                                                            |
|  Description  : Fonctions utilitaires pour la gestion des fichiers.        |
|                                                                            |
==============================================================================
}
unit FilesUtils;


interface

uses
  Windows, Forms, ComCtrls , SysUtils, Registry, ShellApi;

type

  TFiles = class
    procedure Trace (const sText: string; const bCRLF: boolean);
    // Méthodes pour le travail dans les répertoires
    function  IsChildDir (const lpData: TWin32FindData): boolean; overload;
    function  IsChildDir (const SearchRec: TSearchRec): boolean; overload;
    function  DirCount (const sDir: string; const bRecurse, bFirst: boolean): Integer;
    // Méthodes pour le travail sur les fichiers
    function  CopyFile (const sSrc, sDest: string; Progress: TProgressBar): boolean;
    function  DeleteFileToRecycleBin(sFileName: string): boolean;
    function  GetFileSize(const sFileName: string): cardinal;
    function  GetVersionOfFile(const sFileName: string) : string;
    function  GetAssociatedIcons(const sExtension: string; const bSmall: Boolean): HIcon;
    function  FilesCount (const sDir, sFilter: string; const bRecurse, bFirst: boolean): Integer;
    procedure EnumFiles(const sDir, sFilter: string);   // -- DOIT ETRE APPELEE PAR LA FONCTION GetFiles --
    function  GetFiles(const sDir, sFilter: string): integer;
    // Méthodes pour le travail sur les disques
    function  DiskFreeSpace (const sDisk: string): int64;
  public
    // Pour le comtrôle de la procédure Trace
    bTraceActive : boolean;  // Si TRUE, autorise les opérations de traçage
    sTraceFileName  : string;   // Nom du fichier pour le traçage
    // Pour recherche de fichiers
    nCount    : integer;
    sFiles    : array of string;
    //Pour taille du disque
    nDiskSize   : int64;
    nDiskFree   : int64;
    nDiskFiled  : int64;
  end;

var

  Files : TFiles;


implementation


{
===========================================================
|  Permet de sauver des information dans un fichier pour  |
|  suivre à la trace le focntionnement du programme       |
|---------------------------------------------------------|                                              |
|  Paramètres :                                           |
|  - Text   : Texte qui va être ajouté au fichier         |
|  - bCRLF  : Si TRUE nouvelle ligne sinon sur même ligne |
|---------------------------------------------------------|                                              |
|  La variable bTraceActive autorise ou non l'exécution   |
|  de la procédure de traçage                             |
|  pour effacer le contenu dufichier de traçage, il faut  |
|  passer le texte '-New-' en paramêtre                   |
===========================================================
}
procedure TFiles.Trace (const sText: string; const bCRLF: boolean);
var
  ASCIIFile : TextFile;
  sFileName : String;
begin
  if not bTraceActive then
    Exit;
  try
    sFileName := GetCurrentDir + '\' + sTraceFileName;
    {$I-}
    AssignFile(ASCIIFile, sFileName);
    if not FileExists (sFileName) then
      ReWrite(ASCIIFile);
    if sText = '-New-' then
      Erase (ASCIIFile);
//    else begin
      Append(ASCIIFile);
      if bCRLF then
        Writeln(ASCIIFile, sText)  // Ajoute avec un saut de ligne
      else
        Write(ASCIIFile, sText + '; ');   // Ajoute sur la même ligne avec un séparateur "; "
//    end;
    Flush (ASCIIFile);
    CloseFile(ASCIIFile);
    {$I+}
    IOResult;
  except
    {$I-}
    Flush (ASCIIFile);
    CloseFile(ASCIIFile);
    {$I+}
  end;
end;

{
==============================================================================
=============  Méthodes pour le travail dans les répertoires  ================
==============================================================================
}
{
========================================================
|  Teste si c'est un sous-répertoire et élimine  les   |
|  les références aux répertoires parents "." et ".."  |
|------------------------------------------------------|                                              |
|  Paramètres :                                        |
|  - lpData : Pointeur sur les données du fichier      |
|------------------------------------------------------|                                              |
|  Valeur de retour :                                  |
|  - Boolean : TRUE si enfant, FALSE si parent         |
========================================================
}
function TFiles.IsChildDir (const lpData: TWin32FindData): boolean;
var
	bTest : boolean;
begin
	Result := ((lpData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) <> 0);
	bTest := (lpData.cFileName[0] <> '.');
	Result := (Result and bTest);
end;

{
========================================================
|  Teste si c'est un sous-répertoire et élimine  les   |
|  les références aux répertoires parents "." et ".."  |
|------------------------------------------------------|
|  Paramètres :                                        |
|  - SearchRec : Pointeur sur les données du fichier   |
|------------------------------------------------------|
|  Valeur de retour :                                  |
|  - Boolean : TRUE si enfant, FALSE si parent         |
========================================================
}
function TFiles.IsChildDir (const SearchRec: TSearchRec): boolean;
var
	bTest : boolean;
begin
  Result := ((SearchRec.Attr and faDirectory) > 0);
	bTest := ((SearchRec.Name <> '.') and (SearchRec.Name <> '..'));
	Result := (Result and bTest);
end;

{
=================================================================
|  Recherche le nombre de sous-répertoires contenu              |
|  dans un répertoire. (sans wildcard)                          |
|---------------------------------------------------------------|                                              |
|  Paramètres :                                                 |
|  - sDir     : Nom du répertoire sans wildcard                 |
|  - bRecurse : Si TRUE: recherche dans les sous-répertoires    |
|  - bFirst   : Si TRUE: termine la recherche au 1er répertoire |
|---------------------------------------------------------------|                                              |
|  Valeur de retour :                                           |
|  - Integer  : Nombre de sous-répertoires trouvés              |
=================================================================
}
function TFiles.DirCount(const sDir: string; const bRecurse, bFirst: boolean): Integer;
var
  bLoop     : boolean;
	nCount    : integer;
	hFile     : THandle;
	sDirTemp  : string;
	FindData  : TWin32FindData;
Begin
  bLoop := FALSE;
	nCount := 0;
	Result := 0;
	sDirTemp := IncludeTrailingPathDelimiter (sDir) + '*.*';
	hFile := Windows.FindFirstFile (PChar (sDirTemp),  FindData);
	if hFile <> INVALID_HANDLE_VALUE then
  repeat
		if (Files.IsChildDir (FindData)) then begin
			nCount := nCount + 1;
      // Reherche dans les sous-répertoires
			if bRecurse then begin
				sDirTemp := IncludeTrailingPathDelimiter (sDir) + FindData.cFileName;
				nCount := nCount + DirCount (sDirTemp, bRecurse, TRUE);
			end;
		end;
    if (bFirst = TRUE) and (nCount > 0) then
      bLoop := FALSE;
	until (not Windows.FindNextFile (hFile, FindData)) or (bLoop = FALSE);
	Windows.FindClose (hFile);
	Result := nCount;
end;

{
==============================================================================
===============  Méthodes pour le travail sur les fichiers  ==================
==============================================================================
}

{
====================================================================
|  Copie d'un fichier                                              |
|------------------------------------------------------------------|                                              |
|  Paramètres :                                                    |
|  - sSrc   : Chemin et nom du fichier à copier                    |
|  - sDest  : Chemin et nom du fichier de destination              |
|------------------------------------------------------------------|                                              |
|  Valeur de retour :                                              |
|  - boolean  : TRUE si opération exécutée, sinon FALSE            |
====================================================================
}
function TFiles.CopyFile (const sSrc, sDest: string; Progress: TProgressBar): boolean;
var
  bSetAttrib  : boolean;  // Coontrôle de la gestion des attributs
  nFileDate   : integer;  // Entier représentatnt la date et l'heure du fichier
  nAttributs  : integer;  // Pour atributs fichier
  nSize       : int64;    // Taille du fichier;
  nSizeCount  : int64;    // Taille copiàe du fichier;
  sFileSrc    : string;   // Chemin et nom du fichier source
  sFileDest   : string;   // Chemin et nom du fichier destination
  FSrc        : File;     // Structure pour fichier source
  FDest       : File;     // Structure pour fichier destination
  nSizeRead   : integer;  // Taille lue du fichier
  nSizeWrite  : integer;  // Taille écrite du fichier
  cBuffer     : array [1..8192] of Pchar; // Taille du buffer 32Ko


        {---------------------------------------------------------------
        |  Gestion si fichier occupé par un programme ou autre erreur  |
        ---------------------------------------------------------------}
        procedure TestAttrib;
        begin
          if nAttributs > faAnyFile then begin
            Result := FALSE;
            {$I+}
            IOResult;
            {$I-}
            Exit;
          end;
        end;

  begin
  sFileSrc := sSrc;
  sFileDest := sDest;
  try
    {$I-}
    // Gestion des attributs du fichier destination
    nAttributs := FileGetAttr(sFileDest);
    TestAttrib;
    if (nAttributs and faReadOnly) <> 0 then
      FileSetAttr(sFileDest, nAttributs - faReadOnly);  // Pour permettre l'écrasement d'un fichier en lecture seule
    // Acquisition et mémoristion des attributs du fichier source
    nAttributs := FileGetAttr(sFileSrc);
    TestAttrib;
    bSetAttrib := FALSE;
    if (nAttributs and faReadOnly) <> 0 then begin
      bSetAttrib := TRUE;
      FileSetAttr(sFileSrc, nAttributs - faReadOnly);
    end;
    // Gestion de la copie du fichier
    AssignFile (FSrc, sFileSrc);    // Ouverture du fichier source
    AssignFile (FDest, sFileDest);  // Ouverture du fichier destination
    Reset (FSrc, 1);
    Rewrite (FDest, 1);
    // Pour gestion de la barre de progression
    nSize := 1;   // Protection pour division par zéro
    if Progress <> nil then begin
      nSize := FileSize (FSrc);
      if nSize = 0 then
        nSize := 1;   // Protection pour division par zéro
      Progress.Position := 0;
    end;
    //
    nSizeCount := 0;
    repeat
      BlockRead (FSrc, cBuffer, SizeOf (cBuffer), nSizeRead);  // Lecture du fichier
      BlockWrite (FDest, cBuffer, nSizeRead, nSizeWrite); // Ecriture du fichier
      // Pour gestion de la barre de progression
      if Progress <> nil then begin
        nSizeCount := nSizeCount + nSizeRead;
        if nSizeCount >= nSize then
          Progress.Position := 100
        else
          Progress.Position := (nSizeCount * 100) div nSize;
        Progress.Repaint;
        Application.ProcessMessages;
      end;
    until (nSizeRead = 0) or (nSizeWrite <> nSizeRead); // Teste la fin de la copie
    CloseFile (FSrc);   // Fermeture du fichier source
    CloseFile (FDest);  // Fermeture du fichier destination
    // Mise à jour de la date du fichier de destination
    nFileDate := FileAge (sFileSrc);
    FileSetDate (sFileDest, nFileDate);
    // Ajuste les attributs fichiers
    if bSetAttrib then begin
      FileSetAttr (sFileSrc, nAttributs);
      FileSetAttr (sFileDest, nAttributs);
    end;
    Result := TRUE;
    {$I+}
    IOResult;
  except
    CloseFile(FSrc);
    CloseFile(FDest);
    Result := FALSE;
  end;
end;

{
====================================================================
|  Déplace un fichier dans la poubelle                             |
|------------------------------------------------------------------|                                              |
|  Paramètre :                                                     |
|  - sFileName  : Fichier à déplacer dans la poubelle              |
|------------------------------------------------------------------|                                              |
|  Valeur de retour :                                              |
|  - boolean  : TRUE si opération exécutée, sinon FALSE            |
====================================================================
}
function TFiles.DeleteFileToRecycleBin(sFileName: string): boolean;
var
  FileOpStr : TSHFileOpStruct;
begin
  FillChar (FileOpStr, SizeOf(FileOpStr), 0);
  with FileOpStr do
  begin
    wFunc  := FO_DELETE;
    pFrom  := PChar(sFileName + #0);
    fFlags := FOF_ALLOWUNDO or FOF_NOCONFIRMATION or FOF_SILENT;
  end;
  Result := (0 = ShFileOperation (FileOpStr));
end;

{
====================================================================
|  Retourne la taille du fichier                                   |
|------------------------------------------------------------------|                                              |
|  Paramètre :                                                     |
|  - sFileName  : Fichier concerné pour la recherche de la taille  |
|------------------------------------------------------------------|                                              |
|  Valeur de retour :                                              |
|  - Cardinal  : Taille du fichier spécifié                        |
====================================================================
}
function TFiles.GetFileSize(const sFileName: string): cardinal;
var
  Rec : TSearchRec;
begin
  try
    SysUtils.FindFirst(sFileName, faAnyFile, Rec);
    Result := Rec.Size;
  finally
    SysUtils.FindClose(Rec);
  end;
end;

{
====================================================================
|  Retourne la version du fichier                                  |
|------------------------------------------------------------------|                                              |
|  Paramètre :                                                     |
|  - sFileName  : Fichier concerné pour la recherche de la version |
|------------------------------------------------------------------|                                          |
|  Valeur de retour :                                              |
|  - String  : Version du fichier spécifié                         |
====================================================================
}
function TFiles.GetVersionOfFile(const sFileName: string) : string;
Var
  BSize   : Cardinal;
  QSize   : Cardinal;
  NullHD  : Cardinal;
  PData   : Pointer;
  PResult : Pointer;
Begin
  BSize := GetFileVersionInfoSize(PChar(sFileName), NullHD);
  if BSize = 0 then
    Exit;
  GetMem(PData, BSize);
  GetFileVersionInfo(PChar(sFileName), 0, BSize, PData);
  GetMem(PResult, 256);
  VerQueryValue(PData, PChar('\\StringFileInfo\\040C04E4\\FileVersion'),PResult, QSize);
  Result := StrPas(PResult);
end;

{
==================================================================
|  Récupère l'icône associée au fichier                          |
|----------------------------------------------------------------|                                              |
|  Paramètre :                                                   |
|  - sFileName  : Fichier concerné pour la recherche de l'icône  |
|----------------------------------------------------------------|                                          |
|  Valeur de retour :                                            |
|  - HIcon  : Handle de l'icône du fichier spécifié              |
==================================================================
}
function TFiles.GetAssociatedIcons(const sExtension: string; const bSmall: Boolean): HIcon;
var
  hInfo: TSHFileInfo;
  Flags: Cardinal;
begin
  if bSmall then
    Flags := SHGFI_ICON or SHGFI_SMALLICON or SHGFI_USEFILEATTRIBUTES
  else
    Flags := SHGFI_ICON or SHGFI_LARGEICON or SHGFI_USEFILEATTRIBUTES;
  //
  SHGetFileInfo(PChar(sExtension), FILE_ATTRIBUTE_NORMAL, hInfo, SizeOf(TSHFileInfo), Flags);
  Result := hInfo.hIcon;
end;

{
==========================================================
|  Recherche le nombre de fichiers contenu dans un       |
|  répertoire. (utilisation d'un wildcard)               |
|--------------------------------------------------------|                                              |
|  Paramètres :                                          |
|  - sDir     : Nom du répertoire sans wildcard          |
|  - sFilter  : Filtre sur les fichiers                  |
|  - bRecurse : Si TRUE, parcours les sous-répertoires   |
|  - bGirst   : Termine au 1er fichier trouvé            |
|--------------------------------------------------------|                                              |
|  Valeur de retour :                                    |
|  - Integer : Nombre de fichiers trouvés                |
==========================================================
}
function TFiles.FilesCount (const sDir, sFilter: string; const bRecurse, bFirst: boolean): Integer;
var
  bLoop     : boolean;      // Pour contrôle de boucle
  sDirTemp  : string;       // Stocke le répertoire en travail
  SearchRec : TSearchRec;   // Structure pour fichier
begin
  sDirTemp := IncludeTrailingPathDelimiter (sDir);
  Result:= 0;
  if FindFirst(sDirTemp + sFilter, faAnyFile, SearchRec) = 0 then begin
    bLoop := TRUE;
    repeat
      if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then begin
        if (SearchRec.Attr and faDirectory) = faDirectory then begin
          // Si répertoire, appel récursif
          if bRecurse then
            Result := Result + FilesCount (sDirTemp + SearchRec.FindData.cFileName, sFilter, bRecurse, bFirst)
        end else
          Inc(Result);
      end;
    // Recherche du suivant
    if (bFirst = TRUE) and (Result > 0) then
      bLoop := FALSE;
    until (FindNext (SearchRec) <> 0) or (bLoop = FALSE);
    FindClose (SearchRec);
  end;
end;

{
=======================================================
|  Recherche de fichiers en fonction d'un filtre à    |
|  partir d'un répertoire donné de manière récursive  |
|  -- DOIT ETRE APPELEE PAR LA FONCTION GetFiles --   |
|-----------------------------------------------------|                                              |
|  Paramètres :                                       |
|  - sDir     : Répertoire de départ pour la echerche |
|  - sFilter  : Filtre pour sélection des fichiers    |
=======================================================
}
procedure TFiles.EnumFiles(const sDir, sFilter: string);
var
  hFile     : integer;
  sDirTemp  : string;
  recFile   : TSearchRec;
  sSearch   : string;
begin
  sDirTemp := IncludeTrailingPathDelimiter (sDir);
  sSearch := sDirTemp + sFilter;
  hFile := FindFirst(sSearch, faAnyFile, recFile);
  // Parcours des fichiers dans le répertoire courant
  while hFile = 0 do begin
    if (recFile.Name <> '.') and (recFile.name <> '..') then begin
       Inc (nCount);
       SetLength (sFiles, nCount);
       sFiles[nCount-1] := sDirTemp + recFile.Name;
    end;
    hFile := FindNext(recFile);
  end;
  FindClose(recFile);
  // Parcours des sous-répertoires / recherche des fichiers dans ces répertoires
  sSearch := sDirTemp + '*.*';
  hFile := FindFirst(sSearch, faDirectory + faHidden, recFile);
  while hFile = 0 do begin
    if (recFile.Name <> '.') and (recFile.name <> '..') then begin
      // Recherche des fichiers dans le sous-répertoire (récursivité)
      EnumFiles(sDirTemp + recFile.Name, sFilter)
    end;
    hFile := FindNext(recFile);
  end;
  FindClose(recFile);
end;

{
========================================================
|  Recherche de fichiers dans un répertoire et ses     |
|  sous-répertoire en fonction d'un filtre             |
|------------------------------------------------------|                                              |
|  Paramètres :                                        |
|  - sDir     : Répertoire de départ pour la recherche |
|  - sFilter  : Filtre pour sélection des fichiers     |
|------------------------------------------------------|                                          |
|  Valeur de retour :                                  |
|  - Integer  : Nombre de fichiers trouvés             |
========================================================
}
function TFiles.GetFiles(const sDir, sFilter: string): integer;
begin
  nCount := 0;
  SetLength (sFiles, 0);
  Files.EnumFiles (sDir, sFilter);
  Result := nCount;
end;

{
==============================================================================
===============  Méthodes pour le travail sur les disques  ===================
==============================================================================
}
{
========================================================
|  Retourne l'espace libre su un disque.               |
|------------------------------------------------------|                                              |
|  Paramètres :                                        |
|  - sDisk   : indentification du disque. Peut aussi   |
|  être un chemin (seul 1er caractère pris en compte)  |
|------------------------------------------------------|                                          |
|  Valeur de retour :                                  |
|  - Int64     : espace libre du disque concerné       |
========================================================
}
function  TFiles.DiskFreeSpace (const sDisk: string): int64;
var
  bVal  : byte;
begin
  bVal := ord (sDisk[1]) - 64;
  Result := DiskFree (bVal);
end;

end.
