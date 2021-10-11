{
==============================================================================
|
|  Unit         : DatesFunc.pas
|
|  Description  : Diverses functions de traitement des dates
|
==============================================================================
}
unit DatesFunc;


interface

uses
  SysUtils, Controls, DateUtils;

type
  // Classe des fuctions de gtraitement des dates
  TDates  = class
    function  IsValidDate (const sDate: string; var Date: TDate): boolean;
    function  IsValidTime (const sTime: string; var Time: TTime): boolean;
    function  IsValidDateTime (const sDateTime: string; var DateTime: TDateTime): boolean;
    function  CtrlDateForUse (const dtDate: TDate; const sLimitDate: string): boolean;
    function  IncMonth (const pDate: TDate; const pNbr: word): TDate;
    function  DecMonth (const pDate: TDate; const pNbr: word): TDate;
    function  SetBeginMonth (const pDate: TDate): TDate;
  end;


var
  Dates : TDates;

implementation


{
=====================================================
|  Contrôle si date valide                          |
|---------------------------------------------------|                                              |
|  Paramètre :                                      |
|  - sDate  : Date à contrôler au format string     |
|  - Date   : Récupération au format TDate          |
|---------------------------------------------------|                                              |
|  Valeur de retour :                               |
|  - boolean  : TRUE si date valide                 |
=====================================================
}
function TDates.IsValidDate (const sDate: string; var Date: TDate): boolean;
begin
  Result := TRUE;
  try
    Date := StrToDate (sDAte);
  except
    Date := 0;
    Result := FALSE;
  end;
end;

{
=====================================================
|  Contrôle si heure valide                         |
|---------------------------------------------------|                                              |
|  Paramètre :                                      |
|  - sTime  : Heure à contrôler au format string    |
|  - Time   : Récupération au format TTime          |
|---------------------------------------------------|                                              |
|  Valeur de retour :                               |
|  - boolean  : TRUE si Heure valide                |
=====================================================
}
function TDates.IsValidTime (const sTime: string; var Time: TTime): boolean;
begin
  Result := TRUE;
  try
    Time := StrToTime (sTime);
  except
    Time := 0;
    Result := FALSE;
  end;
end;

{
=====================================================
|  Contrôle si date et heure valide                 |
|---------------------------------------------------|                                              |
|  Paramètre :                                      |
|  - sDateTime  : Date et heure en format sting     |
|  - DateTime   : Récupérastion au format TDateTime |
|---------------------------------------------------|                                              |
|  Valeur de retour :                               |
|  - boolean  : TRUE si date et heure valide        |
=====================================================
}
function TDates.IsValidDateTime (const sDateTime: string; var DateTime: TDateTime): boolean;
begin
  Result := TRUE;
  try
    DateTime := StrToDateTime (sDateTime);
  except
    DateTime := 0;
    Result := FALSE;
  end;
end;

{
=====================================================
|  Contrôle de la date limite d'utilisation         |
|---------------------------------------------------|                                              |
|  Paramètres :                                     |
|  - dtDate     : Date pour contrôle d'utilisation  |
|  - sLimitDate : Date limite pour contrôle         |
|---------------------------------------------------|                                              |
|  Valeur de retour :                               |
|  - boolean     : TRUE si autorisation accordée    |
=====================================================
}
function TDates.CtrlDateForUse (const dtDate: TDate; const sLimitDate: string): boolean;
begin
  if dtDate > StrToDate (sLimitDate) then
    Result := FALSE
  else
    Result := TRUE
end;

{
====================================================
|  Incrément d'un nombre de mois une date          |
|--------------------------------------------------|                                              |
|  Paramètres :                                    |
|  - pDate  : Date à manipuler                     |
|  - pNbr   : Nombre de jours à ajouter à la date  |
====================================================
}
function TDates.IncMonth (const pDate: TDate; const pNbr: word): TDate;
var
  Year, Month, Day  : Word;
begin
  DecodeDate (pDate, Year, Month, Day);
  IncAMonth (Year, Month, Day, pNbr);
  result := EncodeDate (Year, Month, Day);
end;

{
====================================================
|  Décrément d'un nombre de mois une date          |
|--------------------------------------------------|                                              |
|  Paramètres :                                    |
|  - pDate  : Date à manipuler                     |
|  - pNbr   : Nombre de jours à enlever à la date  |
====================================================
}
function TDates.DecMonth (const pDate: TDate; const pNbr: word): TDate;
var
  Year, Month, Day  : Word;
begin
  DecodeDate (pDate, Year, Month, Day);
  IncAMonth (Year, Month, Day, -pNbr);
  result := EncodeDate (Year, Month, Day);
end;

{
========================================================
|  Défini la date du début du mois relatif à une date  |
|------------------------------------------------------|                                              |
|  Paramètre :                                         |
|  - pDate  : Date à manipuler                         |
========================================================
}
function TDates.SetBeginMonth (const pDate: TDate): TDate;
var
  Year, Month, Day  : Word;
begin
  DecodeDate (pDate, Year, Month, Day);
  result := EncodeDate (Year, Month, 1);
end;


end.
