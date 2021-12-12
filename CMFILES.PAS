Const MinCote  = 0;
      MaxCote  = 1;
      MaxFiles = 511;

Type StrName = String[12];

Var Nom              : Array[MinCote..MaxCote,0..MaxFiles] of StrName;
    Temps            : Array[MinCote..MaxCote,0..MaxFiles] of LongInt;
    Taille           : Array[MinCote..MaxCote,0..MaxFiles] of LongInt;
    Attribt          : Array[MinCote..MaxCote,0..MaxFiles] of Byte;
    Accepte          : Array[MinCote..MaxCote,0..MaxFiles] of 0..1;
    NombreFichierX   : Array[MinCote..MaxCote] of 0..MaxFiles;
    TypeTri          : Array[MinCote..MaxCote] of 0..4;

Procedure DisqueNonPret(Disque:Byte);
Var Tableau : Pointer;
    OK      : Boolean;
Begin
 OK := False;
 GetMem(Tableau,4000);
 Repeat
  FermeCurseur;
  Move(Mem[$B800:00],Tableau^,4000);
  BoiteCaractere(11,11,68,12,$4F);
  CadreVide(10,10,69,13,$4F);
  CentreEcriture(11,'Disque '+Chr(Disque+65)+' pas prˆte',$4F);
  CentreEcriture(12,'Mettre la disquette et presse une touche',$4E);
  Touche := UpCase(ReadKey);
  If(KeyPressed)Then
  Begin
   Touche := ReadKey;
   Touche := #0;
  End;
  Move(Tableau^,Mem[$B800:00],4000);
  Registre.AH := $1C;
  Registre.DL := Disque + 1;
  MsDos(registre);
  If(Registre.AL<>$FF)Then OK := True;
  OuvreCurseur;
 Until OK;
 FreeMem(Tableau,4000);
End;

Function Volume(Drive:Char):PathStr;
Var Palette : SearchRec;
    Erreur  : Integer;
Begin
 Volume := 'Aucun';
 FindFirst(Drive + ':\*.*',VolumeID,Palette);
 Erreur := DosError;
 If(Erreur = 0)Then Volume := Palette.Name
  else
 If(ERREUR=152)Then
 Begin
  Repeat
   DisqueNonPret(Ord(Drive)-65);
   FindFirst(Drive + ':\*.*',VolumeID,Palette);
   Erreur := DosError;
   If(Erreur = 0)Then Volume := Palette.Name;
  Until (Erreur <> 152);
 End;
End;

Function NombreFichiers(Chaine:PathStr;Attribut:Word):Word;
Var Palette  : SearchRec;
    Nombre   : Word;
    Erreur   : Word;
Begin
 Nombre := 0;
 FindFirst(Chaine,Attribut,Palette);
 Erreur := DOSERROR;
 While ((Erreur = 0)or(Erreur=152)) do
 Begin
  If(Erreur=152)Then DisqueNonPret(Ord(Chaine[1])-65);
  If((Palette.Name <> '.')and(Erreur=0))Then Inc(Nombre);
  If(Erreur<>0)Then FindFirst(Chaine,Attribut,Palette)
               Else FindNext(Palette);
  Erreur := DOSERROR;
 End;
 NombreFichiers := Nombre;
End;

Procedure Fichiers(Chaine:PathStr;Attribut:Word;Cote:Byte);
Var Compteur,Position : Word;
    OK                : Boolean;
    Ecart,I,J,K,M     : LongInt;
    Sortie            : Boolean;
    X                 : String[12];
    XTaille           : LongInt;
    XAttribt          : Byte;
    XSeconde          : 0..59;
    XMinute           : 0..59;
    XHeure            : 0..23;
    XJour             : 1..31;
    XMois             : 1..12;
    XAnnees           : Word;
    Date_TimeB	      : DateTime;
    Palette	      : SearchRec;
    Directory 	      : DirStr;
    FileName  	      : NameStr;
    Extension 	      : ExtStr;
    Erreur            : Word;

 Procedure SousTri;
 Begin
  UnpackTime(Temps[Cote,I],Date_Time);
  UnPackTime(Temps[Cote,M],Date_TimeB);
  X               := Nom[Cote,I];
  XTaille         := Taille[Cote,I];
  XAttribt        := Attribt[Cote,I];
  XSeconde        := Date_Time.Sec;
  XMinute         := Date_Time.Min;
  XHeure          := Date_Time.Hour;
  XJour           := Date_Time.Day;
  XMois           := Date_Time.Month;
  XAnnees  	  := Date_Time.Year;
  Nom[Cote,I]     := Nom[Cote,M];
  Taille[Cote,I]  := Taille[Cote,M];
  Attribt[Cote,I] := Attribt[Cote,M];
  Date_Time.Sec   := Date_TimeB.Sec;
  Date_Time.Min   := Date_TimeB.Min;
  Date_Time.Hour  := Date_TimeB.Hour;
  Date_Time.Day   := Date_TimeB.Day;
  Date_Time.Month := Date_TimeB.Month;
  Date_Time.Year  := Date_TimeB.Year;
  Nom[Cote,M]     := X;
  Taille[Cote,M]  := XTaille;
  Attribt[Cote,M] := XAttribt;
  Date_TimeB.Sec  := XSeconde;
  Date_TimeB.Min  := XMinute;
  Date_TimeB.Hour := XHeure;
  Date_TimeB.Day  := XJour;
  Date_TimeB.Month:= XMois;
  Date_TimeB.Year := XAnnees;
  PackTime(Date_Time,Temps[Cote,I]);
  PackTime(Date_TimeB,Temps[Cote,M]);
  Dec(I,Ecart);
 End;

 Procedure SousInit;
 Begin
  Ecart := Ecart div 2;
  J     := 1;
  K     := NombreFichierX[Cote] - Ecart;
 End;

 Procedure TriNom;
 Begin
  Ecart := NombreFichierX[Cote];
  If(Ecart>3)Then
  Repeat
   SousInit;
   Repeat
    I      := J;
    Sortie := False;
    Repeat
     M := I + Ecart;
     If Nom[Cote,I] > Nom[Cote,M] Then SousTri
				  Else Sortie := True;
    Until (I<1) or (Sortie = True);
    Inc(J);
   Until J>K;
  Until Ecart = 1;
 End;

 Procedure TriExtension;
 Begin
  Ecart := NombreFichierX[Cote];
  If(Ecart>3)Then
  Repeat
   SousInit;
   Repeat
    I      := J;
    Sortie := False;
    Repeat
     M := I + Ecart;
     If(Copy(Nom[Cote,I],10,3)+Copy(Nom[Cote,I],1,8) >
	Copy(Nom[Cote,M],10,3)+Copy(Nom[Cote,M],1,8))Then
     SousTri Else Sortie := True;
    Until (I<1) or (Sortie = True);
    Inc(J);
   Until J>K;
  Until Ecart = 1;
 End;

 Procedure TriHeure;
 Begin
  Ecart := NombreFichierX[Cote];
  If(Ecart>3)Then
  Repeat
   SousInit;
   Repeat
    I      := J;
    Sortie := False;
    Repeat
     M := I + Ecart;
     If(Temps[Cote,I]>Temps[Cote,M])Then
      SousTri
      Else
     Sortie := True;
    Until (I<1) or (Sortie = True);
    Inc(J);
   Until J>K;
  Until Ecart = 1;
 End;

 Procedure TriTaille;
 Begin
  Ecart := NombreFichierX[Cote];
  If(Ecart>3)Then
  Repeat
   SousInit;
   Repeat
    I      := J;
    Sortie := False;
    Repeat
     M := I + Ecart;
     If Taille[Cote,I] > Taille[Cote,M] Then SousTri
					Else Sortie := True;
    Until (I<1) or (Sortie = True);
    Inc(J);
   Until J>K;
  Until Ecart = 1;
 End;

Begin
 Position 	      := 1;
 FindFirst(Chaine,$FFF7,Palette);
 Erreur := DOSERROR;
 While ((Erreur = 0)or(Erreur = 152)) do
 Begin
  If(Erreur = 152)Then DisqueNonPret(Ord(Chaine[1])-65);
  If((Palette.Name <> '.')and(Erreur=0))Then
  Begin
   Accepte[Cote,Position] := 0;
   Attribt[Cote,Position] := Palette.Attr and 22;
   Temps[Cote,Position]   := Palette.Time;
   Taille[Cote,Position]  := Palette.Size;
   Nom[Cote,Position]     := Palette.Name;
   If(Attribt[Cote,Position]<>16)Then
   Begin
    FSplit(Palette.Name,Directory,FileName,Extension);
    Repeat
     FileName := FileName + ' ';
    Until (Length(FileName)=8);
    Nom[Cote,Position] := Filename + Extension;
    If((Attribt[Cote,Position] and 4)=4)Then
    Mem[Seg(Nom[Cote,Position]):Ofs(Nom[Cote,Position])+9] := 42;
   End
    else
   If(Attribt[Cote,Position]=16)Then
   Begin
    Nom[Cote,Position] := #1 + Nom[Cote,Position];
   End;
   Inc(Position);
  End;
  If(Erreur<>0)Then FindFirst(Chaine,$FFF7,Palette)
               Else FindNext(Palette);
  Erreur := DOSERROR;
 End;
 NombreFichierX[Cote] := Position - 1;
 Case TypeTri[Cote] of
  0 : TriNom;
  1 : TriExtension;
  2 : TriHeure;
  3 : TriTaille;
 End;
 For Compteur := 1 to NombreFichierX[Cote] do
 Begin
  If(Copy(Nom[Cote,Compteur],1,1)<#32)Then Nom[Cote,Compteur] := Copy(Nom[Cote,Compteur],2,11);
 End;
End;