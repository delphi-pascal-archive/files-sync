{
==============================================================================
|
|  Unit         : FormSelectDir.pas
|
|  Description  : Boîte de dialogue qui permet de sélectionner un répertoire
|                                                                            
==============================================================================
}
unit FormSelectDir;

interface

uses
  Windows, Forms, StdCtrls, SysUtils, Classes, Controls, ComCtrls,
  ShellCtrls;

type
  // Classe de gestion de la sélection d'un répertoire
  TFrmSelDir = class(TForm)
    LabelDir: TLabel;
    ShellTreeView: TShellTreeView;
    ButtonAccept: TButton;
    ButtonCancel: TButton;
    procedure SetInformations (const sTitle, sLabel, sButAccept, sButCancel: string);
    procedure ShellTreeViewChange(const Sender: TObject; const Node: TTreeNode);
    procedure ButtonAcceptClick(const Sender: TObject);
    procedure ButtonCancelClick(const Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
    sPathName : string;
  end;

var
  FrmSelDir: TFrmSelDir;

implementation

{$R *.dfm}


{
===============================================================
|  Initialisation des textes de la fenêtre                    |
|-------------------------------------------------------------|                                              |
|  Paramètres :                                               |
|  - sTitle     : Titre de la boîte de dialogue               |
|  - sLabel     : Texte d'information pour la liste affichée  |
|  - sButAccept : Texte du bouton de validation               |
|  - sButCancel : Texte du bouton d'abandon                   |
===============================================================
}
procedure TFrmSelDir.SetInformations(const sTitle, sLabel, sButAccept, sButCancel: string);
begin
  Caption := sTitle;
  LabelDir.Caption := sLabel;
  ButtonAccept.Caption := sButAccept;
  ButtonCancel.Caption := sButCancel;
end;

{
===================================================================
|  Traitement au changement de sélection du TShellTreeViewChange  |
|-----------------------------------------------------------------|                                              |
|  Paramètres :                                                   |
|  - Sender : Identification de l'object qui a généré l'événement |
|  - Node   : Identification de l'élément sélectionné             |
===================================================================
}
procedure TFrmSelDir.ShellTreeViewChange(const Sender: TObject; const Node: TTreeNode);
begin
  if DirectoryExists(ShellTreeView.Path) then begin
    // Récupération du répertoire séllectionné
    ButtonAccept.Enabled := TRUE;   // Rend accessible la sélection
    sPathName := ShellTreeView.Path;
    if sPathName[Length(sPathName)] <> '\' then
      sPathName := sPathName+'\';
    LabelDir.Caption := sPathName;
  end else
    // Ce n'est pas un répertoire qui est sélectionné
    ButtonAccept.Enabled := FALSE;  // Rend inaccessible la sélection
end;

{
===================================================================
|  Acceptation répertoire sélectionné                             |
|-----------------------------------------------------------------|                                              |
|  Paramètre :                                                    |
|  - Sender : Identification de l'object qui a généré l'événement |
===================================================================
}
procedure TFrmSelDir.ButtonAcceptClick(const Sender: TObject);
begin
  ModalResult := mrOk;
end;

{
===================================================================
|  Abandon de la boîte de dialogue                                |
|-----------------------------------------------------------------|                                              |
|  Paramètre :                                                    |
|  - Sender : Identification de l'object qui a généré l'événement |
===================================================================
}
procedure TFrmSelDir.ButtonCancelClick(const Sender: TObject);
begin
  ModalResult := mrCancel;
end;

end.
