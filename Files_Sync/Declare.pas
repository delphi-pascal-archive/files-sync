{
==============================================================================
|
|  Programme    : FileSync
|
|  Unit         : Declare.pas
|
|  Description  : D�claration des constantes et variables
|
=============================================================================
}
unit Declare;

interface

uses
  Graphics, SysUtils, Classes, Types;

const
  // Info sur l'auteur et la version du programme
  sAUTHOR_NAME  = 'Tigris';
  sAUTHOR_EMAIL = 'Tigris@Delphifr.com';
  sPROG_VERS    = ' 1.0  (05.03.2008)';

  // Constantes retour � la ligne et saut de ligne
  sCR     = #13;
  sLF     = #10;
  sCRLF   = #13#10;

  // Pour redimensionnement de la fen�tre principale
  nWIDTH_MIN        = 520;  // Largeur minimum de la fen�tre
  nHEIGHT_MIN       = 200;  // Hauteur minimum de la fen�tre
  nSIZE_SOURCEPATH  = 30;   // \
  nSIZE_TARGETPATH  = 30;   //  | Dimensions en % de la largeur de la fen�tre
  nSIZE_FILETYPE    = 15;   // /

  // Identification des champs sFields de la liste de comparaison
  nCOL_CHECKED    = 0;
  nCOL_SOURCENAME = 1;
  nCOL_SOURCESIZE = 2;
  nCOL_SOURCEDATE = 3;
  nCOL_SYNC       = 4;
  nCOL_TARGETDATE = 5;
  nCOL_TARGETSIZE = 6;
  nCOL_TARGETNAME = 7;
  nCOL_TYPE       = 8; // colonne absente de la liste mais utiis� par sFields[]

  // Types d'entr�e de la liste de comparaison
  sTYPE_FILE  = 'F';
  sTYPE_DIR   = 'D';

  // Type du contenu de la liste de comparaison
  nCONTENT_ALL        = 1;
  nCONTENT_SYNCHRO    = 2;
  nCONTENT_TOTARGET   = 3;
  nCONTENT_TOSOURCE   = 4;
  nCONTENT_IDENTICAL  = 5;

  // Pour recherche du chemin d'un fichier
  nSOURCE   = 1;
  nTARGET   = 2;

  // Pour la mise � jour de la barre d'�tat
  nSTAT_CLEAR   = 0;
  nSTAT_SOURCE  = 1;
  nSTAT_TARGET  = 2;
  nSTAT_BOTH    = 3;


type

  TRecFile = record
    bChecked      : boolean;    // S�lectionn� si TRUE;
    sSourceName   : string;     // Nom et extension du fichier source
    nSourceSize   : int64;      // Taille du ficher source
    dtSourceDate  : TDateTime;  // Date du fichier source
    sSync         : string;     // '<', '=', '>', '!', '?'
    dtTargetDate  : TDateTime;  // Date du fichier cible
    nTargetSize   : int64;      // Taille du ficher cible
    sTargetName   : string;     // Nom et extension du fichier cible
    sType         : string;     // sTYPE_FILE pour fichier, sTYPE_DIR pour dossier
  end;

  // Classe des donn�es globales du programme
  TAppliData = class
    // Divers
    bScanActive       : boolean;    // TRUE si scan active, sinon FALSE
    sCurrDir          : string;     // R�pertoire courant
    // Barre de s�lection
    bSubFolder        : boolean;    // Si TRUE, inclu les sous-r�pertoires
    nAttrib           : integer;    // Attributs des fichiers
    sSourcePath       : string;     // R�pertoire source initial
    sTargetPath       : string;     // R�pertoire cible initial
    sFileFilter       : string;     // Filtre choisi pour la recherche des fichiers
    // Pour informations des fichiers
    nNbrFilesSource   : longint;    // Nombre de fichiers du c�t� source
    nNbrTaggedSource  : longint;    // Nombre de fichiers s�lectionn�s c�t� source
    nSizeSelSource    : int64;      // Espace utilis� par les fichiers s�lectionn�s c�t� source
    nFreeDiskSource   : int64;      // Espace libre sur le disque source
    //
    nNbrFilesTarget   : longint;    // Nombre de fichiers du c�t� cible
    nNbrTaggedTarget  : longint;    // Nombre de fichiers s�lectionn�es c�t� cible
    nSizeSelTarget    : int64;      // Espace utilis� par les fichiers s�lectionn�s cot� cible
    nFreeDiskTarget   : int64;      // Espace libre sur le disque cible
    // M�morisaton pour les fichiers
    sListFiles        : TStringList;  // M�morisaton de la liste des fichiers
    sErrorFiles       : TStringList;  // Liste des fichiers s�lectionn�s c�t� cible
    RecFile           : TRecFile;     // Record pour information d'un �l�ment de la liste
    //=== Options g�n�rales du programme
    // Options (historique) - contenu des combobox de choix
    sSourcePathList   : TStringList;  // Liste des r�pertoires source
    sTargetPathList   : TStringList;  // Liste des r�pertoires de destination
    sFileFilterList   : TStringList;  // Liste des filtres pour la recherche des fichiers
    // Options pour l'affichage
    bColon_Auto       : Boolean;      // Si TRUE dimensionnement automatique des colonnes
    ColorPair         : TColor;       // Couleur pour les lignes paires
    ColorImpair       : TColor;       // Couleur pour les lignes impaires
    // Options diveres (comparaison)
    bIgnore2s         : boolean;      // pour diff�rence FAT - NTFS
    nShiftTimeZone    : integer;      // Valeur du d�calage horaire pour les fichiers cibles
    //=== Options du dialogue de suppression des fichiers
    bDelConfirm       : boolean;      // Si TRUE, demande de confirmation pour suppression des fichers
    bDelMoveRecycle   : boolean;      // Si TRUE, d�placement des fichiers dans la corbeille
    bDelConfirm2      : boolean;      // Si TRUE, demande de confirmation pour suppression des fichers
    bDelMoveRecycle2  : boolean;      // Si TRUE, d�placement des r�pertoires dans la corbeille
    //=== Options du dialogue de synchronisation des fichiers
    bSyncSource       : boolean;      // Si TRUE, synchronise les fichiers de la source vers la cible
    bSyncTarget       : boolean;      // Si TRUE, synchronise les fichiers de la cible vers la source
    //
    procedure Init;         // Initialisation des variables globales
    procedure Free;         // Lib�ration des instances
  end;


var
  sLanguage   : string;       // Contient le language actif (que le fran�ais pour ce programme)
  AppliData   : TAppliData;   // Instance de la classe des donn�es globales du programme

implementation

uses
  Colors;


{
========================================================
|  Initialisation de la classe des variables globales  |
========================================================
}
procedure TAppliData.Init;
begin
  with AppliData do begin
    nAttrib := faAnyFile;
    sCurrDir := GetCurrentDir;
  end;
  // Cr�ation des TStringList
  sListFiles := TStringList.Create;
  sSourcePathList := TStringList.Create;
  sTargetPathList := TStringList.Create;
  sFileFilterList := TStringList.Create;
end;

{
==============================
|  Lib�ration des instances  |
==============================
}
procedure TAppliData.Free;
begin
  sListFiles.Free;
  sSourcePathList.Free;
  sTargetPathList.Free;
  sFileFilterList.Free;
  Inherited;
end;


end.
