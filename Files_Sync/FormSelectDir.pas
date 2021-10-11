{
==============================================================================
|
|  Unit         : FormSelectDir.pas
|
|  Description  : Bo�te de dialogue qui permet de s�lectionner un r�pertoire
|                                                                            
==============================================================================
}
unit FormSelectDir;

interface

uses
  Windows, Forms, StdCtrls, SysUtils, Classes, Controls, ComCtrls,
  ShellCtrls;

type
  // Classe de gestion de la s�lection d'un r�pertoire
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
    { D�clarations priv�es }
  public
    { D�clarations publiques }
    sPathName : string;
  end;

var
  FrmSelDir: TFrmSelDir;

implementation

{$R *.dfm}


{
===============================================================
|  Initialisation des textes de la fen�tre                    |
|-------------------------------------------------------------|                                              |
|  Param�tres :                                               |
|  - sTitle     : Titre de la bo�te de dialogue               |
|  - sLabel     : Texte d'information pour la liste affich�e  |
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
|  Traitement au changement de s�lection du TShellTreeViewChange  |
|-----------------------------------------------------------------|                                              |
|  Param�tres :                                                   |
|  - Sender : Identification de l'object qui a g�n�r� l'�v�nement |
|  - Node   : Identification de l'�l�ment s�lectionn�             |
===================================================================
}
procedure TFrmSelDir.ShellTreeViewChange(const Sender: TObject; const Node: TTreeNode);
begin
  if DirectoryExists(ShellTreeView.Path) then begin
    // R�cup�ration du r�pertoire s�llectionn�
    ButtonAccept.Enabled := TRUE;   // Rend accessible la s�lection
    sPathName := ShellTreeView.Path;
    if sPathName[Length(sPathName)] <> '\' then
      sPathName := sPathName+'\';
    LabelDir.Caption := sPathName;
  end else
    // Ce n'est pas un r�pertoire qui est s�lectionn�
    ButtonAccept.Enabled := FALSE;  // Rend inaccessible la s�lection
end;

{
===================================================================
|  Acceptation r�pertoire s�lectionn�                             |
|-----------------------------------------------------------------|                                              |
|  Param�tre :                                                    |
|  - Sender : Identification de l'object qui a g�n�r� l'�v�nement |
===================================================================
}
procedure TFrmSelDir.ButtonAcceptClick(const Sender: TObject);
begin
  ModalResult := mrOk;
end;

{
===================================================================
|  Abandon de la bo�te de dialogue                                |
|-----------------------------------------------------------------|                                              |
|  Param�tre :                                                    |
|  - Sender : Identification de l'object qui a g�n�r� l'�v�nement |
===================================================================
}
procedure TFrmSelDir.ButtonCancelClick(const Sender: TObject);
begin
  ModalResult := mrCancel;
end;

end.
