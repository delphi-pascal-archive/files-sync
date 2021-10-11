{
==============================================================================
|
|  Unit         : FormAbout.pas
|
|  Description  : Gestion de la fen�tre A propos...
|                                                                            
==============================================================================
}
unit FormAbout;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Colors;


const
  nDISPMODE_NORMAL  = 1;
  nDISPMODE_SPLASH  = 2;


type
  // Classe pour la gestion de la bo�te de dialogue A propos...
  TFrmAbout = class(TForm)
    Panel: TPanel;
    ImageLogo: TImage;
    ButtonQuit: TButton;
    LabelProg: TLabel;
    LabelDevName: TLabel;
    LabelVersion: TLabel;
    labelAuthorName: TLabel;
    TimerEffect: TTimer;
    procedure FormShow(const Sender: TObject);
    procedure ButQuitClick(const Sender: TObject);
    procedure TimerEffectTimer(const Sender: TObject);
  private
    { Private declarations }
    nFormDisp : integer;
  public
    { Public declarations }
  end;

// Proc�dure d'appel de la b�te de dialogue
procedure AboutBox (const sTitle,     // Titre de la bo�te de dialogue
                          sProg,      // Nom du programme
                          sDev,       // Texte pour label auteur
                          sAuthor,    // Nom de l'auteur du programme
                          sVer,       // Num�ro de version du programme
                          sEmail,     // Adresse email de l'auteur
                          sEobj,      // Contenu du champ "Objet" de l'email
                          sBut: String;     // Le texte du bouton
                    const bmpAbout: TBitmap;  // La bitmap pour la bo�te de dialogue
                    const nDispMode,          // Mode d'affichage de la bo�te de dialogue
                          nDelay: integer);   // Delai en millisecondes pour le temps d'affichage


var
  FrmAbout: TFrmAbout;

implementation

{$R *.dfm}

{
===========================================================================
|  Gestion de la bo�te de dialogue A propos...                            |
|-------------------------------------------------------------------------|                                              |
|  Param�tres : Voir les decriptions dans la d�claration de la proc�dure  |                                                                |
===========================================================================
}
procedure AboutBox (const sTitle, sProg, sDev, sAuthor, sVer, sEmail, sEobj, sBut: String;
                    const bmpAbout: TBitmap; const nDispMode, nDelay: integer);
begin
  if FrmAbout = nil then
    Application.CreateForm(TFrmAbout, FrmAbout);
  with FrmAbout do begin
    nFormDisp := nDispMode;
    Caption := sTitle;
    LabelProg.Caption := sProg;
    LabelDevName.Caption  := sDev;
    labelAuthorName.Caption := sAuthor;
    LabelVersion.Caption := sVer;
    ButtonQuit.Caption := sBut;
    ImageLogo.Picture.Bitmap := bmpAbout;
    ImageLogo.Picture.Bitmap.TransparentColor := clWhite;
    ImageLogo.Picture.Bitmap.TransparentMode := tmFixed;
    ImageLogo.Picture.Bitmap.Transparent := TRUE;
    // Position de l'image pour le logo
    case bmpAbout.Height of
      32  : begin
              ImageLogo.Left := 146;
              ImageLogo.Top := 14;
            end;
      48  : begin
              ImageLogo.Left := 140;
              ImageLogo.Top := 8;
            end;
    else
      ImageLogo.Stretch := FALSE;
    end;
  end;
  // Mode d'affichage "Splash"
  if nDispMode = nDISPMODE_SPLASH then begin
    with FrmAbout, TimerEffect do begin
      ClientHeight := Panel.Height + (2 * Panel.Top);
      Interval := nDelay;
      Enabled := TRUE;
    end;
  end;
  // Affichage et attente de la fermeture
  FrmAbout.ShowModal;
  // Fermeture de la fen�tre
  if FrmAbout <> nil then begin
    FrmAbout.Free;
    FrmAbout := nil;
  end;
end;

{
====================================================================
|  Gestion de la fen�tre lors de son affichage                     |
|------------------------------------------------------------------|                                              |
|  Param�tre :                                                     |
|  - Sender : Identification de l'object qui a g�n�r� l'�v�nement  |
====================================================================
}
procedure TFrmAbout.FormShow(const Sender: TObject);
var
  Style : LongInt;
begin
  // Mode d'affichage "Splash"
  if nFormDisp = nDISPMODE_SPLASH then begin
    Style := GetWindowLong(Handle, GWL_STYLE);  // M�morise le style courant
    Style := Style and not WS_CAPTION;          // Retire au Style courant l'affichage de la barre de titre
    SetWindowLong(Handle, GWL_STYLE, Style);      // Effectue la modification
    SetWindowPos(Handle, 0, 0, 0, 0, 0, SWP_FRAMECHANGED or SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER);  // Mise � jour de la fen�tre
    // Ajuste les dimensions du panneau
    ClientHeight := Panel.Height + (2 * Panel.Top) - 1;
    ClientWidth := Panel.Width + (2 * Panel.Left) - 1;
    // D�finition de la couleur de la fen�tre (provoque le bord dor�)
    Color := ColorsList.clDarkGoldenRod;
  end;
end;

{
====================================================================
|  Fermeture de la fen�tre                                         |
|------------------------------------------------------------------|                                              |
|  Param�tre :                                                     |
|  - Sender : Identification de l'object qui a g�n�r� l'�v�nement  |
====================================================================
}
procedure TFrmAbout.ButQuitClick(const Sender: TObject);
begin
  Close;
end;

{
====================================================================
|  Gestion des tics du timer                                       |
|------------------------------------------------------------------|                                              |
|  Param�tre :                                                     |
|  - Sender : Identification de l'object qui a g�n�r� l'�v�nement  |
====================================================================
}
procedure TFrmAbout.TimerEffectTimer(const Sender: TObject);
begin
  Close;
end;

end.
