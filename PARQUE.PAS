Unit Parque;

(********************************************************************)
                               Interface
(********************************************************************)

Function ErreurMessage(Numero:Byte) : String;
Function ParqueHardDisk(Numero:Byte) : Byte;
Function ParqueToutHardDisk : Byte;

(********************************************************************)
                            Implementation
(********************************************************************)

Uses DOS;

Var Model     : Byte Absolute $FFFF : $0E;
    SousModel : Byte Absolute $FFFF : $0F;
    Registre  : Registers;

Function ErreurMessage(Numero:Byte) : String;
Var Chaine : String;
    Temp   : String;
Begin
 Case Numero of
  $00 : Chaine := 'Il n''y a pas d''erreur';
  $01 : Chaine := 'Commande invalide';
  $02 : Chaine := 'Marque d''adresse non trouvÇe';
  $03 : Chaine := 'Disque protÇgÇ';
  $04 : Chaine := 'Secteur non trouvÇ';
  $05 : Chaine := 'êchec de la rÇinitialisation';
  $06 : Chaine := 'Disquette absente';
  $07 : Chaine := 'Mauvaise table de paramätres';
  $08 : Chaine := 'DÇpassement du DMA';
  $09 : Chaine := 'DÇpassement d''une frontiäre de frontiäre de 64Ko DMA';
  $0A : Chaine := 'Indicateur de secteur dÇfectueux';
  $0B : Chaine := 'Indicateur de piste dÇfecteutueuse';
  $0C : Chaine := 'Type de mÇdium non trouvÇ';
  $0D : Chaine := 'Nombre de secteurs invalides';
  $0E : Chaine := 'Marque de contrìle dÇtectÇe';
  $0F : Chaine := 'Niveau de DMA interdit';
  $10 : Chaine := 'Erreur de CRC ou d''ECC˝';
  $11 : Chaine := 'Erreur de CRC corrigÇe';
  $20 : Chaine := 'Erreur de contrìleur';
  $40 : Chaine := 'Erreur lors d''un dÇplacement';
  $80 : Chaine := 'DÇpassement de temps (rÇponse non disponible)';
  $AA : Chaine := 'UnitÇ non pràte';
  $BB : Chaine := 'Erreur indefinie';
  $CC : Chaine := 'Erreur d''Çcriture';
  $E0 : Chaine := 'Erreur dans le registre d''Çtat';
  $FF : Chaine := 'Echec de l''opÇration de demande d''Çtat';
   else
  Chaine := 'Inconnue';
 End;
 Str(Numero,Temp);
 If(Numero > 0)Then Chaine := 'Erreur #'+Temp+' : ' + Chaine;
 ErreurMessage := Chaine;
End;

Function ParqueHardDisk(Numero:Byte) : Byte;
Begin
 With Registre do
 Begin
  If((Model=$FA)and(SousModel=$00))or { Si PS/2 modäle 30 }
    ((Model=$FC)and(SousModel=$04))or { Si PS/2 modäle 50 }
    ((Model=$FC)and(SousModel=$05))or { Si PS/2 modäle 60 }
    ((Model=$F8)and(SousModel=$00))or { Si PS/2 modäle 80 }
    ((Model=$F8)and(SousModel=$01))   { Si PS/2 modäle 80 }
  Then
  Begin
   AH := $19;
   DL := Numero;
   Intr($13,Registre);
   ParqueHardDisk := AH;
  End
   else
  Begin
   AH := $08;
   DL := Numero;
   Intr($13,Registre);
   If(Flags and 1<>0)Then
   Begin
    ParqueHardDisk := AH;
    Exit;
   End;
   AH := $0C;
   Dec(CX);
   DL := Numero;
   Intr($13,Registre);
   If((Flags and 1)<>0)Then ParqueHardDisk := AH;
  End;
 End;
End;

Function ParqueToutHardDisk : Byte;
Var Nombre   : Byte;
    Compteur : Byte;
    Result   : Byte;
Begin
 With Registre do
 Begin
  AH := $08;
  DL := $80;
  Intr($13,Registre);
  If(Flags and 1<>0)Then
  Nombre := AH;
  For Compteur := $80 to Nombre do
  Begin
   Result := ParqueHardDisk(Compteur);
   ParqueToutHardDisk := Result;
   If(Result>0)Then Exit;
  End;
 End;
End;

END.