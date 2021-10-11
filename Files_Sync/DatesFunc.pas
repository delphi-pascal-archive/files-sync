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
|  Contr�le si date valide                          |
|---------------------------------------------------|                                              |
|  Param�tre :                                      |
|  - sDate  : Date � contr�ler au format string     |
|  - Date   : R�cup�ration au format TDate          |
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
|  Contr�le si heure valide                         |
|---------------------------------------------------|                                              |
|  Param�tre :                                      |
|  - sTime  : Heure � contr�ler au format string    |
|  - Time   : R�cup�ration au format TTime          |
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
|  Contr�le si date et heure valide                 |
|---------------------------------------------------|                                              |
|  Param�tre :                                      |
|  - sDateTime  : Date et heure en format sting     |
|  - DateTime   : R�cup�rastion au format TDateTime |
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
|  Contr�le de la date limite d'utilisation         |
|---------------------------------------------------|                                              |
|  Param�tres :                                     |
|  - dtDate     : Date pour contr�le d'utilisation  |
|  - sLimitDate : Date limite pour contr�le         |
|---------------------------------------------------|                                              |
|  Valeur de retour :                               |
|  - boolean     : TRUE si autorisation accord�e    |
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
|  Incr�ment d'un nombre de mois une date          |
|--------------------------------------------------|                                              |
|  Param�tres :                                    |
|  - pDate  : Date � manipuler                     |
|  - pNbr   : Nombre de jours � ajouter � la date  |
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
|  D�cr�ment d'un nombre de mois une date          |
|--------------------------------------------------|                                              |
|  Param�tres :                                    |
|  - pDate  : Date � manipuler                     |
|  - pNbr   : Nombre de jours � enlever � la date  |
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
|  D�fini la date du d�but du mois relatif � une date  |
|------------------------------------------------------|                                              |
|  Param�tre :                                         |
|  - pDate  : Date � manipuler                         |
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
