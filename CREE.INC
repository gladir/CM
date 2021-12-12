{ Sous-Programme Cree Autoexec/Config }

Procedure Cree;
Const Choix : Array[0..1] of String[8]=('Autoexec','Config');
Var Tableau1 : Array[0..3999] of Byte;
    Position : 0..1;
    Compteur : Byte;
    OK       : Byte;
  Procedure Autoexec.Bat;
  Begin
  End;

  Procedure Config.Sys;
  Const Choix : Array[0..9] of String[9]=(
		 'Arret',                { Break              }
		 'Dernier disque',       { LastDriv           }
		 'Maximum de fichier',   { Files              }
		 'Nombre de fichier',    { FCBS               }
		 'Nombre Tampon-disque', { Buffers            }
		 'Parametre du disque',  { DrivParm           }
		 'Pays',                 { Country            }
		 'Programme depart',     { Shell              }
		 'Option',               { Device             }
		 'Commande manuel');
  Begin
  End;

Begin
 Move(Mem[$B800:$00],Tableau,4000);
 CadrePlein(6,15,19,20,Config[10]);
 For Compteur := 0 to 1 do
 Begin
  Ecrit(8,17+Compteur,Choix[Compteur],Config[2]);
 End;
 Position := 0;
 OK       := 1;
 Repeat
  For Compteur := 0 to 9 do
  Begin
   Mem[$B800:(Compteur+(17+Position)*80)*2] := Config[14];
  End;
  Touche := LectureClavier;
  If(EtatTouche = $FF)Then
  Begin
   Touche := LectureClavier;
   Case Touche of
    FlecheHaut : Position := (Position - 1)and 1;
    FlecheBas  : Position := (Position + 1)and 1;
    Escape     : OK := 0;
    Enter      : Begin
		  Case Position of
		   0 : Autoexec.Bat;
		   1 : Config.Sys;
		  End;
		  OK := 0;
		 End;
		 else Beep;
   End;
  End;
 Until OK = 0;
 Move(Tableau,Mem[$B800:$00],4000);
End;
