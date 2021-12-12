Program Commandeur_Maltais;

{$M 40000,0,80000}
{$A+}
{$B-}
{$D-}
{$I-}
{$L+}
{$S-}
{$E+,N+}

Uses CRT,DOS,CMECRAN,CMEQUIPE,PARQUE;

Const LargeurMenu : Array[0..7] of Byte = (9,16,26,7,14,15,9,10);

      NombreMenu  : Array[0..7] of Byte = (15,11,10,2,4,1,15,11);

      Choix       : Array[0..7]of String[9]=(
		     'Gauche',
		     'Fichiers',
		     'Commande',
		     'Visuel',
		     'Option',
		     'Recherche',
		     'Droite',
		     'Aide'
		    );

      ChoixDG     : Array[0..15] of String[9]=(
		     'Arbre',
		     'Bref',
		     'Info',
		     'Link',
		     'Plein',
		     'Regard',
		     'Ouvert',
		     'Fermer',

		     'Nom',
		     'Extension',
		     'Heure',
		     'Taille',
		     'Desorde',

		     'Relire',
		     'Filtre',
		     'Disque'
		    );

      ChoixFichier : Array[0..11] of String[16]=(
		      'Aide',
		      'Menu Maison',
		      'Regarde',
		      'Editeur',
		      'Copier',
		      'Renome',
		      'Cree directoire',
		      'Efface',
		      'Attribut fichier',
		      'Selecte Group',
		      'ReSelecte Group',
		      'Quitter'
		     );

      ChoixCommande : Array[0..10] of String[26]=(
		   'CMD arbre',
		   'Prompt',
		   'Histoire',
		   'Ligne EGA',
		   'Change tableau',
		   'Tableau ouvert/fermer',
		   'Compare directoire',
		   'Copie Disquette',
		   'Commande',
		   'Menu fichier editeur',
		   'Extension editeur fichier'
		  );

      ChoixVisuel : Array[0..2] of String[7]=(
		     'Taille',
		     'Ouvert',
		     'Fermer'
		    );

      ChoixRecherche : Array[0..1] of String[10]=(
		    'Fichier',
		    'Repertoire'
		   );

      ChoixOption : Array[0..4] of String[15]=(
		 'Configuration',
		 'Equipement',
		 'Parametre Video',
		 'Stationne d.dur',
		 'Temps'
		);

      ChoixAide : Array[0..11] of String[10]=(
		 'Commande',
		 'Droite',
		 'Equipement',
		 'Fichiers',
		 'Gauche',
		 'Histoire',
		 'Info-CM',
		 'Option',
		 'Principal',
		 'Recherche',
		 'Souris',
		 'Visuel'
		);

      LongeurCote : Array[0..1] of Byte = (15,15);

      HexData : Array[0..15] of Char='0123456789ABCDEF';

Type Chemin       = PathStr;
     String2      = String[2];
     String4      = String[4];
     String12     = String[12];
     String64     = String[64];
     String255    = String[255];
     Binaire      = 0..1;
     Quadrinaire  = 0..3;

Var Nombre           : Array[0..1] of 0..511;
    PositionX        : Array[0..1] of 0..511;
    YPos             : Array[0..1] of 0..17;
    PathX            : Array[0..1] of PathStr;
    TabX             : Array[0..1] of 0..7;
    PathTem          : PathStr;
    Vd               : String[64];
    Tem              : String[4];
    Compteur         : 0..511;
    PositionCur      : 0..79;
    XP               : 0..79;
    YP               : 0..24;
    Xa               : 0..63;
    Ya               : 0..15;
    PosMenu          : 0..7;
    Cote             : 0..1;
    Vg               : 0..1;
    Menu             : 0..1;
    BreakOriginal    : 0..1;
    Colonne	     : Word Absolute $0040 : $4A;
    TypeOrdinateur   : Byte Absolute $FFFF : $0E;
    Registre         : Registers;
    Tableau,Tableau2,
    TableauOutPut    : Pointer;
    CompteurX        : Word;
    Touche           : Char;
    Position         : LongInt;
    Longeur          : LongInt;
    Handle           : Integer;
    HandleTemporaire : Integer;
    Segment,OffSet   : Word;
    PositionBar      : 0..15;
    KeyBar           : 0..1;
    ChaineExtension  : PathStr;
    ErreurCritique   : Byte;
    Date_Time	     : DateTime;
    TableauInterruption : Pointer;
    TableauTemporaire   : Pointer;
    ChaineTemporaire    : String[64];
    Numerique           : Word;
    XS,YS               : Word;
    BS                  : Word;

Procedure OuvreCurseur;
Assembler;
ASM Push AX;
    Push CX;
    Mov  AH,$01;
    Mov  CX,$0007;
    Int  $10;
    Pop  CX;
    Pop  AX;
END;

Procedure FermeCurseur;
Assembler;
ASM Push AX
    Push CX
    Mov  AH,$01
    Mov  CH,$20
    Int  $10
    Pop  CX;
    Pop  AX
END;

Procedure OuvreSouris;
Assembler;
ASM Push AX;
    Mov  AH,$01;
    Int  $33;
    Pop  AX;
END;

Procedure FermeSouris;
Assembler;
ASM Push AX;
    Mov  AH,$02;
    Int  $33;
    Pop  AX;
END;

Procedure InitSouris;
Assembler;
ASM Push AX;
    Mov  AH,$00;
    Int  $33;
    Pop  AX;
END;

Procedure TexteC80;
Assembler;
ASM Push AX;
    Mov  AX,$0003
    Int  $10;
    Pop  AX;
END;

Procedure BreakOff;
Assembler;
ASM Push AX;
    Push DX;
    Mov  AX,$3301;
    Mov  DL,$00;
    Int  $21;
    Pop  DX;
    Pop  AX;
END;

Procedure ProcedureErreurCritique(Var Flags,CS,IP,AX,BX,CX,DX,SI,DI,DS,ES,BP:Word);
Assembler;
ASM Mov  AX,DI;
    Inc  AL;
    Mov  ErreurCritique,AL
    Mov  AL,$00;
    Mov  SP,BP;
    Pop  BP;
    IRet;
END;

Procedure InfoSouris(Var CX { XPosition },
                         DX { YPosition },
                         BX { Bouton }:Word);
Assembler;
{ Retourne CX = XPosition div 8,
           DX = YPosition div 8,
           BX = Bouton }
ASM Push AX;
    Mov  AX,$03;
    Int  $33;
    Push BX;
    Mov  BX,$08;
    Inc  CX;
    Mov  AX,CX;
    {Div  BX;}
	SHR  AX,1
	SHR  AX,1
	SHR  AX,1
    Mov  CX,AX;
    Dec  CX;
    Inc  DX;
    Mov  AX,DX;
{    Div  BX;}
	SHR  AX,1
	SHR  AX,1
	SHR  AX,1
    Mov  DX,AX;
    Dec  DX;
    Pop  BX;
    Pop  AX;
END;

Function SauvegardeData(Var Tableau:Pointer) : Byte;
Begin
 If(MaxAvail>4002)Then
 Begin
  SauvegardeData := 0;
  FermeCurseur;
  GetMem(Tableau,4002);
  Move(Mem[$B800:$00],Tableau^,4000);
  Move(Mem[$0040:$50],Mem[Seg(Tableau^):4000],2);
 End
  else
 SauvegardeData := 1;
End;

Procedure RestorationData(Var Tableau:Pointer);
Begin
 Move(Tableau^,Mem[$B800:$00],4000);
 Move(Mem[Seg(Tableau^):4000],Mem[$0040:$50],2);
 Localise(Mem[$0040:$50],Mem[$0040:$51]);
 FreeMem(Tableau,4002);
 OuvreCurseur;
 Touche := #00;
End;

{$I CMFiles.PAS }
{$I CMResid.Inc }

Function Ctrl : Quadrinaire;
Begin
 Ctrl := 0;
 If((Mem[$0041:$07] and $04) <> 0)Then Ctrl := 1;
End;

Function Hex2(Byt : Byte) : String2;
Begin
 Hex2 := HexData[Byt shr 4] +
	 HexData[Byt and 15];
End;

Function Hex(Byt : Integer) : String4;
Begin
 Hex := HexData[(Byt Shr 12)and 15]+
	HexData[(Byt Shr 8)and 15]+
	HexData[(Byt Shr 4)and 15]+
	HexData[Byt and 15];
End;

Function ChaineZero(Nombre:Byte) : String255;
Var Temporaire : String255;
Begin
 FillChar(Temporaire,255,$30);
 Temporaire[0] := Chr(Nombre);
 ChaineZero := Temporaire;
End;

Function ChaineEspace(Nombre:Byte) : String255;
Var Temporaire : String255;
Begin
 FillChar(Temporaire,255,32);
 Temporaire[0] := Chr(Nombre);
 ChaineEspace := Temporaire;
End;

{$I CMFichie.Inc }
{$I CMDir.Inc    }

Procedure ErreurAide;
Begin
 FermeCurseur;
 CadrePlain(10,9,70,15,$4F);
 CentreEcriture(12,'Impossible d''obtenir de l''aide ...',$4E);
 Write(^G);
End;

Procedure AfficheLigne(Y:Byte;Ligne:Word;Cote:Binaire);
Var TemporaireA : String[31];
    TemporaireB : String[31];
    NumeriqueA  : Byte;
    NumeriqueB  : Byte;
    Date_Time	: DateTime;
    Couleur     : Byte;
    Compteur    : Byte;
    Chaine      : String;
Begin
 NumeriqueA := Cote * 40;
 Inc(NumeriqueA,13);
 NumeriqueB := Y + 6;
 EcritUnCaractere(NumeriqueA,NumeriqueB,179,31);
 For Compteur := Cote * 40 + 1 to Cote * 40 + 12 do
 Begin
  EcritUnCaractere(Compteur,NumeriqueB,32,31);
 End;
 For Compteur := COte * 40 + 14 to Cote * 40 + 21 do
 Begin
  EcritUnCaractere(Compteur,NumeriqueB,32,31);
 End;
 For Compteur := Cote * 40 + 23 to Cote * 40 + 32 do
 Begin
  EcritUnCaractere(Compteur,NumeriqueB,32,31);
 End;
 For Compteur := Cote * 40 + 34 to Cote * 40 + 38 do
 Begin
  EcritUnCaractere(Compteur,NumeriqueB,32,31);
 End;
 EcritUnCaractere(NumeriqueA+9,NumeriqueB,179,31);
 EcritUnCaractere(NumeriqueA+20,NumeriqueB,179,31);
 EcritUnCaractere(NumeriqueA+26,NumeriqueB,179,31);
 Inc(Ligne);
 If(Ligne <= NombreFichierX[Cote])Then
 Begin
  If(Accepte[Cote,Ligne] = 0)Then Couleur := 31 else Couleur := 30;
  Ecrit(Cote*40+1,Y+6,Nom[Cote,Ligne],Couleur);
  If(Attribt[Cote,Ligne] < 16)Then
  Begin
   Str(Taille[Cote,Ligne]:8,Chaine);
   Ecrit(Cote*40+14,Y+6,Chaine,Couleur);
  End
   else
  If(Attribt[Cote,Ligne]=16)Then
  Begin
   If(Nom[Cote,Ligne]='..')Then
   Begin
    Ecrit(Cote*40+14,Y+6,'Sous-Rep',Couleur);
   End
    Else
   Begin
    Ecrit(Cote*40+14,Y+6,'Sur-Rep',Couleur);
   End;
  End;
  UnPackTime(Temps[Cote,Ligne],Date_Time);
  Str(Date_Time.Month,TemporaireA);
  Str(Date_Time.Day,TemporaireB);
  Str(Date_Time.Year:4,Chaine);
  Ecrit(Cote*40+22,Y+6,'³'+Chaine+'-'+
        ChaineZero(2-Length(TemporaireA))+TemporaireA+'-'+
        ChaineZero(2-Length(TemporaireB))+TemporaireB,Couleur);
  Str(Date_Time.Min,TemporaireA);
  Str(Date_Time.Hour:2,Chaine);
  Ecrit(Cote*40+33,Y+6,'³'+Chaine+':'+ChaineZero(2-Length(TemporaireA))+TemporaireA,Couleur);
 End;
End;

Procedure Debut(Cote:Binaire);
Var Compteur : Byte;
Begin
{ BoiteCaractere(40*Cote+1,6,40*Cote+38,6+LongeurCote[Cote],31);}
 PositionX[Cote] := 0;
 YPos[Cote]      := 0;
 For Compteur := 0 to LongeurCote[Cote] do
 Begin
  AfficheLigne(Compteur,Compteur,Cote);
 End;
End;

Procedure Tab;
Begin
 Move(Mem[Seg(TableauOutPut^):798],Mem[$B800:798],3042);
 ClaireLigne(4,196,31);
 Mem[$B800:(Colonne*4)*2]    := 192;
 Mem[$B800:(Colonne*4+79)*2] := 217;
 If(TabX[0] = 4)Then
 Begin
  BoiteCaractere(1,5,38,6+LongeurCote[0],31);
  CadreVide(0,4,39,7+LongeurCote[0],31);
  Mem[$B800:(Colonne*4)*2] := 195;
  Mem[$B800:(Colonne*4+39)*2] := 194;
  Ecrit(4,5,'Nom   Ext³ Taille ³   Date   ³Heure',30);
  Mem[$B800:(Colonne*5+13)*2+1] := 31;
  Mem[$B800:(Colonne*5+22)*2+1] := 31;
  Mem[$B800:(Colonne*5+33)*2+1] := 31;
  Mem[$B800:(Colonne*4+13)*2] := 194;
  Mem[$B800:(Colonne*4+22)*2] := 194;
  Mem[$B800:(Colonne*4+33)*2] := 194;
  Mem[$B800:(Colonne*(LongeurCote[0]+7)+13)*2] := 193;
  Mem[$B800:(Colonne*(LongeurCote[0]+7)+22)*2] := 193;
  Mem[$B800:(Colonne*(LongeurCote[0]+7)+33)*2] := 193;
  If(PathX[0,Length(PathX[0])]<>'\')Then PathTem := PathX[0] + '\' else PathTem := PathX[0];
  Fichiers(PathTem+'*.*',$FFFF,0);
  Debut(0);
  Ecrit(20-((Length(PathX[0])+2) div 2),4,' '+PathX[0]+' ',31);
 End;
 If(TabX[1] = 4)Then
 Begin
  BoiteCaractere(41,5,78,6+LongeurCote[1],31);
  CadreVide(40,4,79,7+LongeurCote[1],31);
  Mem[$B800:(Colonne*4+79)*2] := 180;
  Mem[$B800:(Colonne*4+40)*2] := 194;
  Ecrit(44,5,'Nom   Ext³ Taille ³   Date   ³Heure',30);
  Mem[$B800:(Colonne*5+53)*2+1] := 31;
  Mem[$B800:(Colonne*5+62)*2+1] := 31;
  Mem[$B800:(Colonne*5+73)*2+1] := 31;
  Mem[$B800:(Colonne*4+53)*2] := 194;
  Mem[$B800:(Colonne*4+62)*2] := 194;
  Mem[$B800:(Colonne*4+73)*2] := 194;
  Mem[$B800:(Colonne*(LongeurCote[1]+7)+53)*2] := 193;
  Mem[$B800:(Colonne*(LongeurCote[1]+7)+62)*2] := 193;
  Mem[$B800:(Colonne*(LongeurCote[1]+7)+73)*2] := 193;
  If(PathX[1,Length(PathX[1])]<>'\')Then PathTem := PathX[1] + '\' else PathTem := PathX[1];
  Fichiers(PathTem+'*.*',$FFFF,1);
  Debut(1);
  Ecrit(60-((Length(PathX[1])+2) div 2),4,' '+PathX[1]+' ',31);
 End;
 If(TabX[0] = 2)Then
 Begin
  BoiteCaractere(1,5,38,21,31);
  CadreVide(0,4,39,22,31);
  Mem[$B800:(Colonne*4)*2] := 195;
  Mem[$B800:(Colonne*4+39)*2] := 194;
  Ecrit(13,5,'ÛßßßßßßßßßßßÛ',31);
  Ecrit(13,6,'Û Info - SM Û',31);
  Ecrit(13,7,'ÛÜÜÜÜÜÜÜÜÜÜÜÛ',31);
  Ecrit(2,9,'Repertoire :',31);
  Ecrit(2,11,PathX[1],30);
  TextBackGround(1);
  TextColor(11);
  Ecrit(2,14,'Nombre de Fichier :',31);
  Localise(22,14);
  Write(NombreFichierX[1]:7,' Fichiers');
  Ecrit(2,13,'Volume            :',31);
  Localise(22,13);
  Write(Volume(PathX[1,1]));
  Ecrit(2,15,'Taille disque     :',31);
  Localise(22,15);
  Write(DiskSize(Ord(PathX[1,1])-64):9,' Octets');
  Ecrit(2,16,'Espace libre      :',31);
  Localise(22,16);
  Write(DiskFree(Ord(PathX[1,1])-64):9,' Octets');
  Ecrit(2,18,'Version du MS-DOS :',31);
  Localise(22,18);
  Write(Lo(DosVersion),'.',Hi(DosVersion));
  Ecrit(2,19,'M‚moire total     :',31);
  Localise(22,19);
  Write(TailleRAM:9:0,' Octets');
  Ecrit(2,20,'M‚moire libre     :',31);
  Localise(22,20);
  Write(MemoireLibre:9:0,' Octets');
 End;
 If(TabX[1] = 2)Then
 Begin
  BoiteCaractere(41,5,78,21,31);
  CadreVide(40,4,79,22,31);
  Mem[$B800:(Colonne*4+79)*2] := 180;
  Mem[$B800:(Colonne*4+40)*2] := 194;
  Ecrit(53,5,'ÛßßßßßßßßßßßÛ',31);
  Ecrit(53,6,'Û Info - SM Û',31);
  Ecrit(53,7,'ÛÜÜÜÜÜÜÜÜÜÜÜÛ',31);
  Ecrit(42,9,'Repertoire :',31);
  Ecrit(42,11,PathX[0],30);
  TextBackGround(1);
  TextColor(11);
  Ecrit(42,14,'Nombre de Fichier :',31);
  Localise(62,14);
  Write(NombreFichierX[0]:7,' Fichiers');
  Ecrit(42,13,'Volume            :',31);
  Localise(62,13);
  Write(Volume(PathX[0,1]));
  Ecrit(42,15,'Taille disque     :',31);
  Localise(62,15);
  Write(DiskSize(Ord(PathX[0,1])-64):9,' Octets');
  Ecrit(42,16,'Espace libre      :',31);
  Localise(62,16);
  Write(DiskFree(Ord(PathX[0,1])-64):9,' Octets');
  Ecrit(42,18,'Version du MS-DOS :',31);
  Localise(62,18);
  Write(Lo(DosVersion),'.',Hi(DosVersion));
  Ecrit(42,19,'M‚moire total     :',31);
  Localise(62,19);
  Write(TailleRAM:9:0,' Octets');
  Ecrit(42,20,'M‚moire libre     :',31);
  Localise(62,20);
  Write(MemoireLibre:9:0,' Octets');
 End;
 Nombre[0] := 0;
 Nombre[1] := 0;
 ClaireLigne(23,32,Mem[Seg(TableauOutPut^):1]);
 Localise(0,23);
 TurboEcrit(PathX[Cote]+'>');
 Handle := ChangeRepertoire(PathX[Cote]);
 PositionCur := Mem[$0045:$00];
 ChaineExtension := '';
 OuvreCurseur;
End;

Procedure StationnerDisqueDur;
Var Tableau  : Pointer;
    Erreur   : Byte;
    Nombre   : Byte;
    Chaine   : String;
Begin
 Erreur := SauvegardeData(Tableau);
 If(Erreur = 0)Then
 Begin
  CadrePlain(10,5,70,20,63);
  CentreEcriture(9,'Stationnement du/des disque(s) dur(s)',62);
  With Registre do
  Begin
   AH := $08;
   DL := $80;
   Intr($13,Registre);
   If(Flags and 1=0)Then
   Begin
    Nombre := DL;
    Str(Nombre,Chaine);
    Ecrit(15,12,'Nombre de disque dur : '+Chaine,63);
    Erreur := ParqueToutHardDisk;
    If(Erreur > 0)Then
    Begin
     CadrePlain(10,8,70,16,$4F);
     CentreEcriture(12,ErreurMessage(Erreur),79);
     CentreEcriture(13,'Presse une touche pour quitter',79);
    End
     else
    Begin
     Ecrit(15,14,'Op‚ration r‚ussit',63);
     Ecrit(15,15,'Tu peux fermer l''ordinateur ou presse une',63);
     Ecrit(15,16,'touche pour retourner au PRINCIPAL.',63);
    End;
   End
    else
   Begin
    CadrePlain(10,8,70,16,$4F);
    CentreEcriture(12,ErreurMessage(Erreur),79);
    CentreEcriture(13,'Presse une touche pour quitter',79);
   End;
   Repeat
    If(KeyPressed)Then Touche := ReadKey;
   Until Not(KeyPressed);
   Touche := ReadKey;
   If(KeyPressed)Then Touche := ReadKey;
  End;
  RestorationData(Tableau);
 End
  else
 Write(^G);
End;

Procedure Change(Cote:Binaire);
Var Nombre   : 0..26;
    Compteur : Byte;
    Position : -26..26;
    OK       : 0..1;
    Erreur   : Byte;
Begin
 Erreur := SauvegardeData(Tableau);
 If(Erreur=0)Then
 Begin
  Position := Ord(PathX[Cote,1])-64;
  Nombre := NombreDisque;
  OK := 0;
  GetMem(Tableau,4000);
  Move(Mem[$B800:$00],Tableau^,4000);
  CadrePlain(Cote*40+10,8,Cote*40+30,13+Nombre,63);
  Ecrit(Cote*40+14,10,'Change disque',62);
  For Compteur := 1 to Nombre do EcritUnCaractere(Cote*40+20,11+Compteur,Compteur+64,62);
  Repeat
   For Compteur := 19 to 21 do Mem[$B800:(Cote*40+Compteur+(11+Position)*80)*2+1] := 94;
   Repeat Until KeyPressed;
   For Compteur := 19 to 21 do Mem[$B800:(Cote*40+Compteur+(11+Position)*80)*2+1] := 62;
   Touche := ReadKey;
   If(KeyPressed)Then
   Begin
    Touche := ReadKey;
    Case Touche of
     'H' : Dec(Position);
     'P' : Inc(Position);
    End;
    If(Position>Nombre)Then Position := 1;
    If(Position = 0)Then Position := Nombre;
   End;
   If(Touche = #13)Then
   Begin
    PathX[Cote] := Chr(Position + 64)+':\';
    OK          := 1;
    TabX[Cote]  := 4;
   End;
   If(Touche = #27)Then OK := 1;
  Until (OK=1);
  Erreur := Ord(Touche);
  RestorationData(Tableau);
  If(Erreur = 13)Then Tab;
 End
  else
 Write(^G);
End;

Procedure CrossNextGeneration;
Begin
 CentreEcriture(14,'Oui  Non',$4F);
 OuvreSouris;
 Compteur := 0;
 Repeat
  CompteurX := (CompteurX + 1) and $FFF;
  If(CompteurX = $001)Then
  Begin
   FermeSouris;
   Ecrit(34,14,' Oui ',94);
   OuvreSouris;
  End;
  If(CompteurX = $444)Then
  Begin
   FermeSouris;
   Ecrit(34,14,' Oui ',87);
   OuvreSouris;
  End;
  If(CompteurX = $888)Then
  Begin
   FermeSouris;
   Ecrit(34,14,' Oui ',92);
   OuvreSouris;
  End;
  If(CompteurX = $CCC)Then
  Begin
   FermeSouris;
   Ecrit(34,14,' Oui ',91);
   OuvreSouris;
  End;
  InfoSouris(XS,YS,BS);
  If(BS<>0)Then
  Begin
   If(XS in [34..38])and(YS=14)Then
   Begin
    Touche := 'O';
    Exit;
   End;
   If(XS in [39..43])and(YS=14)Then
   Begin
    Touche := 'N';
    Exit;
   End;
  End;
 Until KeyPressed;
 FermeSouris;
 Touche := ReadKey;
 If(KeyPressed)Then Touche := ReadKey;
End;

Procedure ParametreVideo;
Var Tableau : Pointer;
    Erreur  : Byte;
Begin
 Erreur := SauvegardeData(Tableau);
 If(Erreur=0)Then
 Begin
  Segment := 256 * Mem[$00:119] + Mem[$00:118];
  OffSet  := 256 * Mem[$00:117] + Mem[$00:116];
  CadrePlain(1,1,77,23,63);
  CentreEcriture(3,'Parametre Video',62);
  Ecrit(5,5,'OffSet 40x25 80x25 Graphique Monochrome Caracteristique',62);
  Ecrit(5,6,'------ ----- ----- --------- ---------- ------------------------------',63);
  For Compteur := $00 to $0B do
  Begin
   Ecrit(7,7+Compteur,Hex2(Compteur)+'h   '+
 	 Hex2(Mem[Segment:OffSet+Compteur])+'h   '+
	 Hex2(Mem[Segment+$01:OffSet+Compteur])+'h       '+
	 Hex2(Mem[Segment+$02:OffSet+Compteur])+'h        '+
	 Hex2(Mem[Segment+$03:OffSet+Compteur])+'h',59);
  End;
  Ecrit(45,7,'Nombre de colonnes affichables',59);
  Ecrit(45,8,'Nombre de colonnes affich‚es',59);
  Ecrit(45,9,'Nombre de caractere entre SSH',59);
  Ecrit(45,10,'Duree du signal',59);
  Ecrit(45,11,'Nombre de lignes affichables',59);
  Ecrit(45,12,'Nombre de ligne ajuste',59);
  Ecrit(45,13,'Nombre de lignes affich‚es',59);
  Ecrit(45,14,'Nombre de caractere entre SSV',59);
  Ecrit(45,15,'Mode d''entrelacement',59);
  Ecrit(45,16,'Nombre de pixels par ligne',59);
  Ecrit(45,17,'Ligne de depart du curseur',59);
  Ecrit(45,18,'Ligne de fin du curseur',59);
  Ecrit(7,19,'0Ch  '+Hex(MemW[Segment:OffSet+$0C])+'h '+
 		     Hex(MemW[Segment+1:OffSet+$0C])+'h    '+
		     Hex(MemW[Segment+2:OffSet+$0C])+'h      '+
		     Hex(MemW[Segment+3:OffSet+$0C])+
		  'h  Adresse de la page affich‚e',59);
  Ecrit(7,20,'0Eh  '+Hex(MemW[Segment:OffSet+$0E])+'h '+
 		     Hex(MemW[Segment+1:OffSet+$0E])+'h    '+
		     Hex(MemW[Segment+2:OffSet+$0E])+'h      '+
		     Hex(MemW[Segment+3:OffSet+$0E])+
		  'h  Adresse du curseur',59);
  Ecrit(5,21,'------ ----- ----- --------- ---------- ------------------------------',63);
  Repeat Until KeyPressed;
  Touche := ReadKey;
  If(KeyPressed)Then Touche := ReadKey;
  RestorationData(Tableau);
 End
  else
 Write(^G);
End;

Procedure InfoCM;
Var Tableau : Pointer;
    Erreur  : Byte;
Begin
 Erreur := SauvegardeData(Tableau);
 If(Erreur=0)Then
 Begin
  CadrePlain(8,4,72,22,63);
  CentreEcriture(7,'Info - CM',62);
  Ecrit(14,9,'Concepteur et programmeur :',63);
  Ecrit(18,11,'Sylvain Maltais',62);
  Ecrit(14,13,'Propri‚t‚ :',63);
  CentreEcriture(16,'Commandeur Maltais version 1.02',62);
  CentreEcriture(18,'Copyright (C) 1991 par',62);
  CentreEcriture(19,'Les Chevaliers de Malte International',62);
  Repeat Until KeyPressed;
  Touche := ReadKey;
  If(KeyPressed)Then Touche := ReadKey;
  RestorationData(Tableau);
 End
  else
 Write(^G);
End;

Procedure Equipement;
Var Tableau : Pointer;
    Erreur  : Byte;
    Chaine  : String;

 Procedure EA(X,Y,Etat:Byte);
 Begin
  Localise(X,Y);
  Case Etat of
   0 : Write('Absent');
   1 : Write('Existant');
    else
   Write('Annormale');
  End;
 End;

 Procedure CrossNewGeneration(Y,Posibilite:Byte);
 Begin
  EcritUnCaractere(30,Y,58,63);
  Localise(32,Y);
  Case Posibilite of
   0 : Write('Aucun');
   1 : Write('Un');
   2 : Write('Deux');
   3 : Write('Trois');
   4 : Write('Quatre');
   5 : Write('Cinq');
   6 : Write('Six');
   7 : Write('Sept');
    else
   Write('Inconnue');
  End;
 End;

Begin
 Erreur := SauvegardeData(Tableau);
 If(Erreur=0)Then
 Begin
  CadrePlain(10,1,70,22,63);
  TextColor(14);
  TextBackGround(3);
  CentreEcriture(4,'Equipement',62);
  Ecrit(15,6,'Compatible IBM :',63);
  Localise(32,6);
  Case TypeOrdinateur of
   248 : Write('PS/2 modŠle 80');
   249 : Write('PC Convertible');
   250 : Write('PS/2 modŠle 30');
   252 : Write('AT');
   253 : Write('PC Junior');
   254 : Write('XT');
   255 : Write('PC');
    else
   Write('Inconnu');
  End;
  Ecrit(15,7,'Mode Initiale  :',63);
  Localise(32,7);
  Case ModeVideo of
   $00 : Write('Inconnue');
   $01 : Write('Couleur 40 x 25');
   $02 : Write('Couleur 80 x 25');
   $03 : Write('Monochrome 80 x 25');
  End;
  Ecrit(15,8,'Type moniteur  :',63);
  Localise(32,8);
  Case HardWare of
   $00 : Write('Inexistant');
   $0A : Write('PC Junior');
   $0C : Write('Color Graphique Adaptor');
   $0E : Write('Enhanced Graphique Adaptor');
  End;
  Ecrit(15,9,'Coprocesseur   :',63);
  EA(32,9,CoprosseurMathematique);
  Ecrit(15,10,'Manette de jeu :',63);
  EA(32,10,NombreManetteJeu);
  Ecrit(15,11,'Souris         :',63);
  Localise(32,11);
  Case Souris of
   0 : Write('Absent');
   1 : Begin
        Write('Existant');
        Ecrit(15,12,'Bouton Souris  :',63);
        Localise(32,12);
        Case Bouton of
 	1 : Write('Un');
 	3 : Write('Trois')
 	 else
 	Write('Deux');
        End;
       End;
  End;
  Ecrit(15,13,'Imprimante',63);
  CrossNewGeneration(13,NombreImprimante);
  Ecrit(15,14,'DMA            :',63);
  EA(32,14,NombreDMA);
  Ecrit(15,15,'Nombre RS-232',63);
  CrossNewGeneration(15,NombreRS232);
  Ecrit(15,16,'Nombre disque',63);
  CrossNewGeneration(16,NombreDisque);
  Compteur := 0;
  Chaine   := ' secteurs/piste';
  Repeat
   Ecrit(15,17+Compteur,'Type disque '+Chr(65+Compteur)+'  :',63);
   Localise(32,17+Compteur);
   Case TypeDisque(Compteur + 1) of
    $03 : Write('Pas prˆte');
    $F0 : Write('3 «, Double face, 9'+Chaine);
    $F9 : Write('3 «, Double face, 8'+Chaine);
    $FC : Write('5 ¬, Simple face, 9'+Chaine);
    $FD : Write('5 ¬, Double face, 9'+Chaine);
    $FE : Write('5 ¬, Simple face, 8'+Chaine);
    $FF : Write('5 ¬, Double face, 8'+Chaine);
    $F8 : Write('Disque Dur')
     else
    Write('Disque Virtuel');
   End;
   Inc(Compteur);
  Until Compteur = NombreDisque;
  FermeCurseur;
  OuvreSouris;
  Repeat Until keyPressed;
  FermeSouris;
  Touche := Readkey;
  If(KeyPressed)Then Touche := ReadKey;
  RestorationData(Tableau);
 End
  else
 Write(^G);
End;

{$I CMDisque.inc }
{$I CMFiche.pas  }

Procedure EffacePrincipal;
Var Tableau : Pointer;
    Erreur  : Byte;
    Changement : Byte;
Begin
 Erreur := SauvegardeData(Tableau);
 Changement := 0;
 If(Erreur=0)Then
 Begin
  If(Nombre[Cote] = 0)And(Attribt[Cote,PositionX[Cote]+1] = 16)Then
  Begin
   GetDir(0,Vd);
   Chdir(PathX[Cote]);
   CompteurX := SupressionRepertoire(Nom[Cote,PositionX[Cote]+1]);
   ChDir(Vd);
   Changement := 1;
  End
   Else
  If(Nombre[Cote] = 0)And(Attribt[Cote,PositionX[Cote]+1] < 16)Then
  Begin
   BoiteCaractere(11,12,68,14,$4F);
   CadreVide(10,11,69,15,$4F);
   CentreEcriture(12,'Es-tu certain de vouloir effacer :',$4F);
   CentreEcriture(13,Nom[Cote,PositionX[Cote]+1],$4F);
   CentreEcriture(14,'Presse <ESC> pour retourner',$4E);
   Repeat
    Touche := ReadKey;
    If(KeyPressed)Then
    Begin
     Touche := ReadKey;
     Touche := #0;
    End;
   Until (Touche in [#13,#27]);
   If(Touche <> #27)Then
   Begin
    PathTem := PathX[Cote];
    If(PathX[Cote,Length(PathX[Cote])]<>'\')Then PathTem := PathX[Cote] + '\';
    PathTem := PathTem + Nom[Cote,PositionX[Cote]+1];
    HandleTemporaire := Efface(PathTem);
    If(HandleTemporaire <> -1)Then Changement := 1;
   End;
  End
   else
  Begin
   CadrePlain(19,8,59,17,$4F);
   Str(Nombre[Cote],PathTem);
   CentreEcriture(11,'Es-tu certain de vouloir',$4E);
   CentreEcriture(12,'effacer '+PathTem+' fichier(s)',$4E);
   CrossNextGeneration;
   If(Touche in ['O','o','Y','y',#13])Then
   Begin
    Move(Tableau^,Mem[$B800:$00],4000);
    For CompteurX := 0 to NombreFichierX[Cote]-1 do
    Begin
     If(Accepte[Cote,CompteurX+1]=1)Then
     Begin
      PathTem := PathX[Cote];
      If(PathX[Cote,Length(PathX[Cote])]<>'\')Then PathTem := PathX[Cote] + '\';
      PathTem := PathTem + Nom[Cote,CompteurX+1];
      CadrePlain(35-(Length(PathTem) div 2),8,43+(Length(PathTem) div 2),17,$70);
      CentreEcriture(11,'J''‚fface le fichier :',$7E);
      CentreEcriture(13,PathTem,$7E);
      HandleTemporaire := Efface(PathTem);
      If(HandleTemporaire <> 1)Then Changement := 1;
      Move(Tableau^,Mem[$B800:$00],4000);
     End;
    End;
   End;
  End;
  RestorationData(Tableau);
  If(Changement=1)Then Tab;
 End
  else
 Write(^G);
End;

Procedure AffichageMenu(Position:Byte);
Begin
 If(Position = 7)Then CadreChoix(64,2,77,18,'Aide')
  else
 CadreChoix(Position*10,2,Position*10+4+LargeurMenu[Position],NombreMenu[Position]+7,Choix[Position]);
 Case Position of
  $00 : Begin
	 If(TabX[0]<6)Then EcritUnCaractere(1,5+TabX[0],16,27);
	 If(TabX[0]>5)Then EcritUnCaractere(1,12,16,27)
		      Else EcritUnCaractere(1,11,16,27);
	 EcritUnCaractere(1,13+TypeTri[0],16,27);
	 EcritUnCaractere(12,5,191,30);
	 For Compteur := 0 to 3 do EcritUnCaractere(12,6+Compteur,179,30);
	 EcritUnCaractere(12,10,217,30);
	 EcritUnCaractere(12,11,191,30);
	 EcritUnCaractere(12,12,217,30);
	 EcritUnCaractere(12,13,191,30);
	 For Compteur := 0 to 2 do EcritUnCaractere(12,14+Compteur,179,30);
	 EcritUnCaractere(12,17,217,30);
	End;
  $06 : Begin
	 If(TabX[1]<6)Then EcritUnCaractere(61,5+TabX[1],16,27);
	 If(TabX[1]>5)Then EcritUnCaractere(61,12,16,27)
		      Else EcritUnCaractere(61,11,16,27);
	 EcritUnCaractere(61,13+TypeTri[1],16,27);
	 EcritUnCaractere(72,5,191,30);
	 For Compteur := 0 to 3 do EcritUnCaractere(72,6+Compteur,179,30);
	 EcritUnCaractere(72,10,217,30);
	 EcritUnCaractere(72,11,191,30);
	 EcritUnCaractere(72,12,217,30);
	 EcritUnCaractere(72,13,191,30);
	 For Compteur := 0 to 2 do EcritUnCaractere(72,14+Compteur,179,30);
	 EcritUnCaractere(72,17,217,30);
	End;
 End;
 For Compteur := 0 to NombreMenu[Position] do
 Begin
  Case Position of
   $00 : Ecrit(2,5+Compteur,ChoixDG[Compteur],31);
   $01 : Ecrit(12,5+Compteur,ChoixFichier[Compteur],31);
   $02 : Ecrit(22,5+Compteur,ChoixCommande[Compteur],31);
   $03 : Ecrit(32,5+Compteur,ChoixVisuel[Compteur],31);
   $04 : Ecrit(42,5+Compteur,ChoixOption[Compteur],31);
   $05 : Ecrit(52,5+Compteur,ChoixRecherche[Compteur],31);
   $06 : Ecrit(62,5+Compteur,ChoixDG[Compteur],31);
   $07 : Ecrit(66,5+Compteur,ChoixAide[Compteur],31);
  End;
 End;
End;

Procedure AidePrincipal;
Var Tableau : Pointer;
    Handle  : Integer;
    Erreur  : Byte;
Begin
 Erreur := SauvegardeData(Tableau);
 If(Erreur=0)Then
 Begin
  Compteur := 1;
  Handle := Ouvre('CM.HLP',0);
  If(Handle = - 1)Then
  Begin
   ErreurAide;
   Repeat Until KeyPressed;
   Touche := ReadKey;
   If(KeyPressed)Then Touche := ReadKey;
  End
   else
  Begin
   Repeat
    LitEnregistrement(Handle,Compteur,4000,Mem[$B800:4000]);
    If(ErreurFichier=0)Then
    Begin
     Move(Mem[$B800:4000],Mem[$B800:0],4000);
     Repeat Until KeyPressed;
     Touche := ReadKey;
     If(KeyPressed)Then
     Begin
      Touche := ReadKey;
      Case Touche of
       #71 : Compteur := 1;
       #73 : Begin
    	      If(Compteur > 1)Then Dec(Compteur);
    	     End;
       #79 : Compteur := 5;
       #81 : Begin
  	      If(Compteur < 5)Then Inc(Compteur);
   	     End;
      End;
      Touche := #00;
     End;
    End
     else
    Begin
     BoiteCaractere(11,12,68,14,$4F);
     CadreVide(10,11,69,15,$4F);
     CentreEcriture(12,'Erreur : De lecture d''aide',$4F);
     CentreEcriture(13,'Impossible d''obtenir de l''aide',$4F);
     CentreEcriture(14,'Presse une touche pour retourner',$4E);
     Touche := ReadKey;
     If(KeyPressed)Then Touche := ReadKey;
     Touche := #27;
    End;
   Until (Touche = #27);
   Handle := Ferme(Handle);
  End;
  RestorationData(Tableau);
 End
  else
 Write(^G);
End;

Procedure PrincipalCreeRepertoire;
Var Chaine8    : PathStr;
    Position   : Byte;
    Erreur     : Word;
    Tableau    : Pointer;
    Changement : Byte;

 Procedure Aide;
 Var Tableau : Pointer;
     Erreur  : Byte;
     Handle  : Integer;
 Begin
  Erreur := SauvegardeData(Tableau);
  If(Erreur=0)Then
  Begin
   Handle := Ouvre('CM.HLP',0);
   If(Handle = -1)Then ErreurAide
    else
   Begin
    LitEnregistrement(Handle,6,4000,Mem[$B800:$00]);
    If(ErreurFichier<>0)Then ErreurAide;
    Handle := Ferme(Handle);
   End;
   Repeat Until KeyPressed;
   Touche := ReadKey;
   If(KeyPressed)Then Touche := ReadKey;
   RestorationData(Tableau);
  End
   else
  Write(^G);
 End;

Begin
 Changement := 0;
 Erreur := SauvegardeData(Tableau);
 If(Erreur=0)Then
 Begin
  CadrePlain(8,5,71,18,63);
  CentreEcriture(8,'Cr‚ation d''un R‚pertoire',62);
  Ecrit(12,10,'Nom du R‚pertoire … Cr‚er :',62);
  EcritUnCaractere(31,12,91,63);
  EcritUnCaractere(49,12,93,63);
  For Position := 0 to 7 do
  Begin
   EcritUnCaractere(33+Position*2,12,32,15);
   EcritUnCaractere(33+Position*2,13,196,63);
  End;
  Ecrit(12,15,'Longeur :',63);
  Ecrit(39,15,'Disque :',63);
  Ecrit(48,15,Copy(PathX[Cote],1,1),62);
  Position := 0;
  Erreur   := 0;
  Chaine8  := '';
  PathTem  := '';
  Repeat
   Str(Position+1,PathTem);
   Ecrit(22,15,PathTem,62);
   Localise(33+Position*2,12);
   OuvreCurseur;
   Touche := ReadKey;
   FermeCurseur;
   If KeyPressed Then
   Begin
    Touche := ReadKey;
    Case Touche of
     #59 : Begin
   	    Move(Mem[$B800:0],Tableau2^,4000);
   	    HandleTemporaire := Ouvre('CM.HLP',0);
	    If(HandleTemporaire = -1)Then ErreurAide
	     else
	    Begin
	     LitEnregistrement(HandleTemporaire,6,4000,Mem[$B800:0]);
	     HandleTemporaire := Ferme(HandleTemporaire);
	    End;
	    Repeat Until KeyPressed;
	    Touche := ReadKey;
	    If(KeyPressed)Then Touche := ReadKey;
	    Move(Tableau2^,Mem[$B800:0],4000);
	    Touche := #00;
	   End;
     #71 : Position := 0;
     #75 : Position := (Position - 1) and 7;
     #77 : Position := (Position + 1) and 7;
    End;
    Touche := #00;
   End;
   Case Touche of
    #08 : Begin
  	   If(Position > 0)Then
	   Begin
	    Dec(Position);
	    Chaine8[Position] := #32;
	    EcritUnCaractere(33+Position*2,12,32,15);
	   End;
	  End;
    #13 : Begin
	   PathTem := PathX[Cote];
	   If(PathTem[Length(PathTem)] <> '\')Then PathTem := PathTem + '\';
	   PathTem := PathTem + Chaine8 + #00;
	   Erreur := CreationRepertoire(PathTem);
           If(Erreur<>0)Then
           Begin
            BoiteCaractere(11,12,68,14,$4F);
            CadreVide(10,11,69,15,$4F);
            CentreEcriture(12,'Erreur : De r‚pertoire',$4F);
            CentreEcriture(13,'Impossible de cr‚e le r‚pertoire',$4F);
            CentreEcriture(14,'Presse une touche pour retourner',$4E);
            Write(^G);
            Touche := ReadKey;
            If(KeyPressed)Then Touche := ReadKey;
           End
            else
           Changement := 1;
	   Touche := #27;
	  End;
   End;
   If(Touche > #31)and(Not(Touche in ['?','*']))and(Position < 8)Then
   Begin
    Chaine8 := Copy(Chaine8,1,Position) + UpCase(Touche) + Copy(Chaine8,Position + 1,8);
    EcritUnCaractere(33+Position*2,12,Ord(UpCase(Touche)),15);
    If(Position < 7)Then Inc(Position);
   End
    else
   If(Touche > #31)Then Write(^G);
  Until (Touche = #27);
  RestorationData(Tableau);
  If(Changement = 1)Then Tab;
 End
  else
 Write(^G);
End;

Procedure RenomePrincipal;
Var Tableau    : Pointer;
    Erreur     : Byte;
    Changement : Byte;
Begin
 Changement := 0;
 Erreur := SauvegardeData(Tableau);
 If(Erreur=0)Then
 Begin
  CadrePlain(8,5,71,18,63);
  RestorationData(Tableau);
  If(Changement = 1)Then Tab;
 End
  else
 Write(^G);
End;

Procedure CreeAutoexec;
Var Handle  : Integer;
    Tableau : Pointer;
    Erreur  : Byte;
Begin
 PathTem := PathX[Cote];
 If(PathTem[Length(PathTem)] <> '\')Then PathTem := PathTem + '\';
 Handle := Ouvre(PathTem+'AUTOEXEC.BAT',0);
 If(Handle = -1)Then Handle := Cree(PathTem+'AUTOEXEC.BAT')
  Else
 Begin
  Handle := Ferme(Handle);
  Exit;
 End;
 If(Handle = -1)Then
 Begin
  Erreur := SauvegardeData(Tableau);
  If(Erreur=0)Then
  Begin
   CadrePlain(10,10,69,18,79);
   CentreEcriture(13,'Erreur de creation de fichier...',78);
   CentreEcriture(15,' Correct ',94);
   Repeat Touche := ReadKey Until (Touche = #13);
   RestorationData(Tableau);
  End
   else
  Write(^G);
 End
  else
 Tab;
End;

Procedure AfficheKeyBar;

 Procedure EcritunCaractere(X,Y,Caractere:Byte);
 Begin
  Mem[$B800:(X+Y*80)*2] := Caractere;
 End;

Begin
 If(KeyBar = 1)Then
 Begin
  If((Mem[$0040:96] and $10)=0)Then
  Begin
   Mem[$B800:3840] := $31;
   Ecrit(1,24,'Aide',48);EcritUnCaractere(5,24,$32);
   Ecrit(6,24,'Menu',48);EcritUnCaractere(10,24,$33);
   Ecrit(11,24,'Regard',48);EcritUnCaractere(17,24,$34);
   Ecrit(18,24,'Edite',48);EcritUnCaractere(23,24,$35);
   Ecrit(24,24,'Copie',48);EcritUnCaractere(29,24,$36);
   Ecrit(30,24,'Renome',48);EcritUnCaractere(36,24,$37);
   Ecrit(37,24,'CrDir',48);EcritUnCaractere(42,24,$38);
   Ecrit(43,24,'Efface',48);EcritUnCaractere(49,24,$39);
   Ecrit(50,24,'Equipe',48);EcritUnCaractere(56,24,$31);
   Ecrit(58,24,'Quitter',48);EcritUnCaractere(57,24,$30);
   EcritUnCaractere(65,24,$31);
   EcritUnCaractere(66,24,$31);
   Ecrit(67,24,'Ouvre',48);
   EcritUnCaractere(72,24,$31);
   EcritUnCaractere(73,24,$32);
   Ecrit(74,24,'Fermer',48);
  End
   else
  Begin
   Mem[$B800:3840] := $31;
   Ecrit(1,24,'Aide  ',48);EcritUnCaractere(8,24,$32);
   Ecrit(9,24,'Menu  ',48);EcritUnCaractere(16,24,$33);
   Ecrit(17,24,'Regard',48);EcritUnCaractere(24,24,$34);
   Ecrit(25,24,'Edite ',48);EcritUnCaractere(32,24,$35);
   Ecrit(33,24,'Copie ',48);EcritUnCaractere(40,24,$36);
   Ecrit(41,24,'Renome',48);EcritUnCaractere(48,24,$37);
   Ecrit(49,24,'CrDir ',48);EcritUnCaractere(56,24,$38);
   Ecrit(57,24,'Efface',48);EcritUnCaractere(64,24,$39);
   Ecrit(65,24,'Equipe',48);EcritUnCaractere(71,24,$31);
   Ecrit(73,24,'Quitter',48);EcritUnCaractere(72,24,$30);
  End;
 End;
End;

Procedure InverseTab;
Var TabTem  : Byte;
    Tableau : Pointer;
Begin
 If(MaxAvail>798)Then
 Begin
  GetMem(Tableau,798);
  Move(Mem[$B800:$00],Tableau^,798);
  Move(TableauOutPut^,Mem[$B800:$00],4000);
  Move(Tableau^,Mem[$B800:$00],798);
  FreeMem(Tableau,798);
  PathTem  := PathX[0];
  PathX[0] := PathX[1];
  PathX[1] := PathTem;
  Cote := (Cote + 1) and 1;
  TabTem  := TabX[0];
  TabX[0] := TabX[1];
  TabX[1] := TabTem;
  AfficheKeyBar;
  Tab;
 End
  else
 Write(^G);
End;

Procedure HauteCouleur(Couleur:Byte);
Begin
 Registre.AH := $0B;
 Registre.BH := $00;
 Registre.BL := Couleur;
 Intr($10,Registre);
End;

Procedure EffaceBarMenu;
Begin
 For Compteur := 2+PosMenu*10 to 2+PosMenu*10+LargeurMenu[PosMenu]
  do Mem[$B800:(Compteur-Segment+(5+PositionBar)*Colonne)*2+1] := 31;
End;

Procedure ReAfficheBarMenu;
Begin
 If(PosMenu = 7)Then Segment := 6 else Segment := 0;
 For Compteur := 2+PosMenu*10 to 2+PosMenu*10+LargeurMenu[PosMenu]
 do Mem[$B800:(Compteur-Segment+(5+PositionBar)*Colonne)*2+1] := 94;
End;

Procedure HomeMenu;
Begin
 EffaceBarMenu;
 PositionBar := 0;
 ReAfficheBarMenu;
End;

Procedure EndMenu;
Begin
 EffaceBarMenu;
 PositionBar := NombreMenu[PosMenu];
 ReAfficheBarMenu;
End;

Procedure BasMenu;
Begin
 EffaceBarMenu;
 If(PositionBar = NombreMenu[PosMenu])Then PositionBar := 0
				      Else Inc(PositionBar);
 ReAfficheBarMenu;
End;

Procedure HautMenu;
Begin
 EffacebarMenu;
 If(PositionBar = 0)Then PositionBar := NombreMenu[PosMenu]
		    Else Dec(PositionBar);
 ReAfficheBarMenu;
End;

Procedure QuitterP;
Begin
 Move(TableauOutPut^,Mem[$B800:0],4000);
 FreeMem(TableauOutPut,4000);
 Localise(XP,YP);
 Registre.AH := $33;
 Registre.AL := $01;
 Registre.DL := BreakOriginal;
 MsDos(Registre);
 InLine($FA);
 Move(TableauInterruption^,Mem[0:0],1024);
 InLine($FB);
 Halt;
End;

Procedure CertainQuitter;
Var Tableau : Pointer;
    Quitte  : Boolean;
    Erreur  : Byte;
Begin
 Erreur := SauvegardeData(Tableau);
 If(Erreur=0)Then
 Begin
  CadrePlain(10,9,70,16,$4F);
  CentreEcriture(12,'Est-tu certain de vouloir quitter ?',$4E);
  CrossNextGeneration;
  If(Touche in [#13,'Y','y','o','O'])Then Quitte := True
 				     Else Quitte := False;
  If(KeyPressed)Then Touche := ReadKey;
  RestorationData(Tableau);
  If(Quitte)Then QuitterP;
 End
  else
 QuitterP;
End;

Procedure CopyFile(Source,Target:String);
Var Source_File : File;
    Target_File : File;
    Num_Read    : Word;
    Num_Write   : Word;
    Buffer	: Array[0..32767] of Char;
Begin
 CadrePlain(10,8,69,16,63);
 CentreEcriture(11,'Copie fichier '+Source,62);
 CentreEcriture(12,'…',62);
 CentreEcriture(13,Target+Source,62);
 Assign(Source_File,Source);
 Reset(Source_File,1);
 If(IOResult <> 0)Then Exit;
 If(Pos('\',Target[Length(target)])<>1)Then Target := Target + '\';
 Assign(Target_File,Target + Source);
 Rewrite(Target_File,1);
 If(IOResult<>0)Then Exit;
 Repeat
  BlockRead(Source_File,Buffer,32768,Num_Read);
  BlockWrite(Target_File,Buffer,Num_Read,Num_Write);
  If(Num_Read<>Num_Write)Then
  Begin
   WriteLn('Impossible de copier le fichier : ',Source:13);
   Close(Source_File);
   Erase(Target_File);
   Close(Target_File);
   Exit
  End;
 Until Num_Read = 0;
 Close(Source_File);
 Close(Target_File);
End;

Procedure Copie;
Var Source  : PathStr;
    Target  : PathStr;
    Boucle  : Word;
    Direct  : Boolean;
    Tableau : Pointer;
    Erreur  : Byte;
Begin
 If(TabX[0] in [4])and(TabX[1] in [4])Then
 Begin
  Erreur := SauvegardeData(Tableau);
  If(Erreur=0)Then
  Begin
   Direct := True;
   Target := PathX[(Cote + 1) and 1];
   For Boucle := 0 to NombreFichierX[Cote] - 1 do
   Begin
    If(Accepte[Cote,Boucle] = 1)Then Direct := False;
   End;
   If(Direct)Then CopyFile(Nom[Cote,PositionX[Cote]+1],Target)
    else
   Begin
    For Boucle := 0 to NombreFichierX[Cote] - 1 do
    Begin
     If(Accepte[Cote,Boucle] = 1)Then CopyFile(Nom[Cote,Boucle],Target);
    End;
   End;
   RestorationData(Tableau);
   Tab;
  End
   else
  Write(^G);
 End
  else
 Write(^G);
End;

Procedure MenuMaison;
Var Tableau  : Pointer;
    Position : Byte;
    Compteur : Word;
    Ok       : Boolean;
    Erreur   : Byte;

 Procedure Resultat;
 Begin
  Case DosError of
   2  : WriteLn('Fichier non-trouv‚');
   8  : WriteLn('Memoire insuffisante');
   10 : WriteLn('Environnement Invalide');
   11 : WriteLn('Format Invalide');
    else
   WriteLn('Execution normal');
  End;
  Touche := ReadKey;
  If(KeyPressed)Then Touche := ReadKey;
 End;

 Procedure BudgetSMIII;
 Var Tableau : Pointer;
     Erreur  : Byte;
 Begin
  Erreur := SauvegardeData(Tableau);
  If(Erreur = 0)Then
  Begin
   Exec('BUDGETSM.EXE','');
   Resultat;
   RestorationData(Tableau);
  End
   else
  Write(^G);
 End;

 Procedure Debug;
 Var Tableau : Pointer;
     Erreur  : Byte;
 Begin
  Erreur := SauvegardeData(Tableau);
  If(Erreur = 0)Then
  Begin
   Exec('DEBUG.EXE','');
   Resultat;
   RestorationData(Tableau);
  End
   else
  Write(^G);
 End;

 Procedure Lotus;
 Var Tableau : Pointer;
     Erreur  : Byte;
 Begin
  Erreur := SauvegardeData(Tableau);
  If(Erreur=0)Then
  Begin
   Exec('LOTUS.EXE','');
   Resultat;
   RestorationData(Tableau);
  End
   else
  Write(^G);
 End;

Begin
 Erreur := SauvegardeData(Tableau);
 If(Erreur=0)Then
 Begin
  CadrePlain(20,7,59,17,47);
  CentreEcriture(10,'Menu Application',46);
  CentreEcriture(12,'Budget SM III',43);
  CentreEcriture(13,'Debug SM',43);
  CentreEcriture(14,'Lotus SM',43);
  Ok := False;
  Position := 0;
  Repeat
   For Compteur := 30 to 49 do Mem[$B800:(Compteur+(12+Position)*80)*2+1] := 94;
   Touche       := ReadKey;
   For Compteur := 30 to 49 do Mem[$B800:(Compteur+(12+Position)*80)*2+1] := 43;
   If(KeyPressed)Then
   Begin
    Touche := ReadKey;
    Case Touche of
     #71 : Position := 0;
     #72 : If(Position > 0)Then Dec(Position)
   			  Else Position := 2;
     #79 : Position := 2;
     #80 : If(Position < 2)Then Inc(Position)
   			  Else Position := 0;
    End;
   End
    else
   Case Touche of
    #13 : Begin
           Case Position of
  	    0 : BudgetSMIII;
  	    1 : Debug;
  	    2 : Lotus;
  	   End;
           FermeCurseur;
          End;
    #27 : Ok := True;
   End;
  Until Ok;
  RestorationData(Tableau);
 End
  else
 Write(^G);
End;

Procedure AjustementConfiguration;
Var Tableau  : Pointer;
    Position : Byte;
    Compteur : Word;
    Ok       : Boolean;
    Erreur   : Byte;

 Procedure Couleur;
 Begin
 End;

 Procedure Repertoire;
 Begin
 End;

 Procedure Initiation;
 Begin
 End;

Begin
 Erreur := SauvegardeData(Tableau);
 If(Erreur=0)Then
 Begin
  CadrePlain(20,7,59,17,47);
  CentreEcriture(10,'Configuration',46);
  CentreEcriture(12,'Couleur',43);
  CentreEcriture(13,'R‚pertoire',43);
  CentreEcriture(14,'Initiation',43);
  Ok := False;
  Position := 0;
  Repeat
   For Compteur := 30 to 49 do Mem[$B800:(Compteur+(12+Position)*80)*2+1] := 94;
   Touche       := ReadKey;
   For Compteur := 30 to 49 do Mem[$B800:(Compteur+(12+Position)*80)*2+1] := 43;
   If(KeyPressed)Then
   Begin
    Touche := ReadKey;
    Case Touche of
     #71 : Position := 0;
     #72 : If(Position > 0)Then Dec(Position)
 			  Else Position := 2;
     #79 : Position := 2;
     #80 : If(Position < 2)Then Inc(Position)
 			  Else Position := 0;
    End;
   End
    else
   Case Touche of
    #13 : Begin
           Case Position of
  	    0 : Couleur;
 	    1 : Repertoire;
 	    2 : Initiation;
 	   End;
           FermeCurseur;
          End;
    #27 : Ok := True;
   End;
  Until Ok;
  RestorationData(Tableau);
 End
  else
 Write(^G);
End;

Procedure FermeMenu;
Begin
 If((Ctrl = 0)and(BS = 0))and(Menu = 1)Then
 Begin
  FermeSouris;
  Move(Mem[$BA00:$00],Mem[$B800:$00],4000);
  Ecrit(2+PosMenu*10,3,Choix[PosMenu],94);
  Localise(PositionCur,23);
  OuvreCurseur;
  OuvreSouris;
  Menu := 0;
 End;
End;

Procedure EnterMenu;
Begin
  Case PosMenu of
   0 : Begin
	If Not(PositionBar in [13,15])Then
	Begin
	 GetMem(Tableau,798);
	 Move(Mem[$B800:$00],Tableau^,798);
	 Move(TableauOutPut^,Mem[$B800:$00],4000);
	 FreeMem(TableauOutPut,4000);
	End;
	Case PositionBar of
	 0  : TabX[0]    := 0;
	 1  : TabX[0]    := 1;
	 2  : TabX[0]    := 2;
	 3  : TabX[0]    := 3;
	 4  : TabX[0]    := 4;
	 5  : TabX[0]    := 5;
	 6  : TabX[0]    := 4;
	 7  : TabX[0]    := 6;
	 8  : TypeTri[0] := 0;
	 9  : TypeTri[0] := 1;
	 10 : TypeTri[0] := 2;
	 11 : TypeTri[0] := 3;
	 12 : TypeTri[0] := 4;
	 13 : Tab;
	 15 : Change(0);
	End;
	If Not(PositionBar in [13,15])Then
	Begin
	 GetMem(TableauOutPut,4000);
	 Move(Mem[$B800:$00],TableauOutPut^,4000);
	 Move(Tableau^,Mem[$B800:$00],798);
	 FreeMem(Tableau,798);
	 AfficheKeyBar;
	 Tab;
	End;
       End;
   1 : Case PositionBar of
	0  : AidePrincipal;
	1  : MenuMaison;
	2  : RegardeFichier;
	3  : RegardeEditeFichier;
	4  : Copie;
	5  : RenomePrincipal;
	6  : PrincipalCreeRepertoire;
	7  : EffacePrincipal;
	8  : Equipement;
	11 : CertainQuitter;
       End;
   2 : Begin
       End;
   3 : Begin
       End;
   4 : Case PositionBar of
        0 : AjustementConfiguration;
	1 : Equipement;
	2 : ParametreVideo;
	3 : StationnerDisqueDur;
       End;
   5 : Begin
       End;
   6 : Begin
	If Not(PositionBar in [13,15])Then
	Begin
	 GetMem(Tableau,798);
	 Move(Mem[$B800:$00],Tableau^,798);
	 Move(TableauOutPut^,Mem[$B800:$00],4000);
	 FreeMem(TableauOutPut,4000);
	End;
	Case PositionBar of
	 0  : TabX[1]    := 0;
	 1  : TabX[1]    := 1;
	 2  : TabX[1]    := 2;
	 3  : TabX[1]    := 3;
	 4  : TabX[1]    := 4;
	 5  : TabX[1]    := 5;
	 6  : TabX[1]    := 4;
	 7  : TabX[1]    := 6;
	 8  : TypeTri[1] := 0;
	 9  : TypeTri[1] := 1;
	 10 : TypeTri[1] := 2;
	 11 : TypeTri[1] := 3;
	 12 : TypeTri[1] := 4;
	 13 : Tab;
	 15 : Change(1);
	End;
	If Not(PositionBar in [13,15])Then
	Begin
	 GetMem(TableauOutPut,4000);
	 Move(Mem[$B800:$00],TableauOutPut^,4000);
	 Move(Tableau^,Mem[$B800:$00],798);
	 FreeMem(Tableau,798);
	 AfficheKeyBar;
	 Tab;
	End;
       End;
   7 : Case PositionBar of
	6 : InfoCM;
	8 : AidePrincipal;
       End;
  End;
End;

Procedure SelectionToutFichier;
Begin
End;

Procedure ToucheSpecial;
Begin
 If((CodeClavier > 0)and(Not(KeyPressed)))Then
    Begin
     FermeSouris;
     If(Ctrl=1)and(Menu=1)Then
     Begin
      If(CodeClavier=156)and(AncienCode2=28)Then
      Begin
       FermeMenu;
       Move(Mem[$BA00:$00],Mem[$B800:$00],4000);
       Menu        := 0;
       CodeClavier := 0;
       EnterMenu;
       Exit;
      End
       else
      Case CodeClavier of
       80 : Begin
             CodeClavier := 0;
             BasMenu;
            End;
       72 : Begin
	     CodeClavier := 0;
             HautMenu;
	    End;
      End;
     End;
     If(Mem[$0040:$17] and 31 = 0)Then
     Case CodeClavier of
      $D7 : Begin
	     KeyBar := 0;
	     ClaireLigne(24,32,Mem[Seg(TableauOutPut^):1]);
	     Localise(0,23);
	     TurboEcrit(PathX[Cote]+'>'+ChaineExtension);
	    End;
      $D8 : Begin
	     KeyBar := 1;
	     AfficheKeyBar;
	     Localise(0,23);
	     TurboEcrit(PathX[Cote]+'>'+ChaineExtension);
	    End;
     End;
     CodeClavier := 0;
    End;
End;

Procedure EnterExecute;
Label 90;
Var ChaineTemporaire : String;
    Tableau          : Pointer;

 Procedure TesteQuitte;
 Begin
  Write('D‚sirez-vous toujours continuer (O/N) ?');
  Repeat
   Touche := UpCase(ReadKey);
  Until (Touche in ['O','N']);
  If(Touche = 'N')Then
  Begin
   GetMem(TableauOutPut,4000);
   Move(Mem[$B800:$00],TableauOutPut^,4000);
   Move(Tableau^,Mem[$B800:$00],798);
   FreeMem(Tableau,798);
   QuitterP;
  End;
 End;

Begin
 TextColor(Mem[$B800:$01] mod 16);
 TextBackGround(Mem[$B800:$01] div 16);
 If(ChaineExtension <> '')Then
 Begin
  GetMem(Tableau,798);
  Move(Mem[$B800:$00],Tableau^,798);
  Move(TableauOutPut^,Mem[$B800:$00],4000);
  FreeMem(TableauOutPut,4000);
  PathTem := PathX[Cote];
  If(PathX[Cote,Length(PathX[Cote])]<>'\')Then PathTem := PathX[Cote] + '\';
  Dec(YP);
  {ClaireLigneTrans(YP,32);}
  Localise(0,YP);
  WriteLn(PathTem+'>'+ChaineExtension);
  ChaineTemporaire := ' TOUCHE PROGRAMMABLE';
  If(ChaineExtension = 'FERMER'+ChaineTemporaire)Then KeyBar := 0;
  If(ChaineExtension = 'OUVRIR'+ChaineTemporaire)Then KeyBar := 1;
  If(ChaineExtension = 'FERMER #1')Then TabX[0] := 2;
  If(ChaineExtension = 'FERMER #2')Then TabX[1] := 2;
  ChaineTemporaire := 'TABLEAU #';
  If(ChaineExtension = ChaineTemporaire+'1 PLEIN')Then TabX[0] := 0;
  If(ChaineExtension = ChaineTemporaire+'2 PLEIN')Then TabX[1] := 0;
  If(ChaineExtension = ChaineTemporaire+'1 INFO')Then TabX[0] := 1;
  If(ChaineExtension = ChaineTemporaire+'2 INFO')Then TabX[1] := 1;
  If(ChaineExtension = 'CLS')Then TexteC80
   else
  If(Copy(ChaineExtension,1,3) = 'CLS')and(ChaineExtension[4]>#47)and(ChaineExtension[4]<#56)Then
  Begin
   BoiteCaractere(0,0,79,24,(Ord(ChaineExtension[4])-48)*16+15);
   HauteCouleur(Ord(ChaineExtension[4])-48);
  End
   else
  If(ChaineExtension = 'CM AIDE')Then
  Begin
   TextColor(Mem[$B800:$01] mod 16);
   TextBackGround(Mem[$B800:$01] div 16);
   WriteLn;
   WriteLn;
   WriteLn(' ':36,'COMMANDE');
   For Compteur := 0 to 79 do Write('-');
   WriteLn;
   WriteLn('CM AIDE');
   WriteLn;
   ChaineTemporaire := ' TOUCHE PROGRAMMABLE';
   WriteLn('FERMER'+ChaineTemporaire);
   WriteLn('OUVRIR'+ChaineTemporaire);
   WriteLn;
   WriteLn('FERMER #1');
   WriteLn('FERMER #2');
   WriteLn;
   ChaineTemporaire := 'TABLEAU #';
   WriteLn(ChaineTemporaire+'1 PLEIN');
   WriteLn(ChaineTemporaire+'2 PLEIN');
   WriteLn(ChaineTemporaire+'1 INFO');
   WriteLn(ChaineTemporaire+'2 INFO');
   WriteLn;
  End
   else
  If(ChaineExtension='COMSPEC')Then WriteLn(GetEnv('COMSPEC'))
   else
  If(ChaineExtension<>'')Then
  Begin
   ChaineTemporaire := GetEnv('COMSPEC');
   Handle := Ouvre(ChaineTemporaire,0);
   If(Handle=-1)Then
   Begin
    WriteLn('Erreur : COMMAND.COM introuvable!');
    TesteQuitte;
   End
    else
   Handle := Ferme(Handle);
   Exec(ChaineTemporaire,'/C'+ChaineExtension);
   If(DosError=8)Then
   Begin
    WriteLn('Erreur : M‚moire insuffisante!');
    TesteQuitte;
   End
    else
   Case DosExitCode of
    1 : WriteLn('Interrompu par Ctrl - C');
    2 : WriteLn('Erreur de P‚riph‚rique');
    3 : WriteLn('Terminaison en mode r‚sidant');
   End;
  End;
  ChaineExtension := '';
  TextColor(Mem[$B800:$01] mod 16);
  TextBackGround(Mem[$B800:$01] div 16);
  Goto 90;
 End
  else
 If(TabX[Cote]=4)Then
 Begin
  If(Attribt[Cote,PositionX[Cote]+1]=16)Then
  Begin
   If(Nom[Cote,PositionX[Cote]+1]='..')Then
   Begin
    Delete(PathX[Cote],Length(PathX[Cote]),1);
    While(PathX[Cote,Length(PathX[Cote])] <> '\')do Delete(PathX[Cote],Length(PathX[Cote]),1);
    If(Length(PathX[Cote])<>3)Then Delete(PathX[Cote],Length(PathX[Cote]),1);
   End
    else
   Begin
    If Not(PathX[Cote,Length(PathX[Cote])]='\')Then PathX[Cote] := PathX[Cote] + '\';
    PathX[Cote] := PathX[Cote] + Nom[Cote,PositionX[Cote]+1];
   End;
   Tab;
  End
   else
  Begin
   If(MaxAvail>798)Then
   Begin
    GetMem(Tableau,798);
    Move(Mem[$B800:$00],Tableau^,798);
    FreeMem(TableauOutPut,4000);
    Move(TableauOutPut^,Mem[$B800:$00],4000);
    PathTem := PathX[Cote];
    If(PathX[Cote,Length(PathX[Cote])]<>'\')Then PathTem := PathX[Cote] + '\';
    {ClaireLigneTrans(YP,32);}
    Localise(0,YP);
    WriteLn;
    WriteLn(PathTem,'>',Nom[Cote,PositionX[Cote]+1]);
    WriteLn;
    WriteLn('Indication du Repertoire');
    For Compteur := 0 to 39 do Write('-');
    WriteLn;
    UnPackTime(Temps[Cote,PositionX[Cote]+1],Date_Time);
    WriteLn('Date   : ',Date_Time.Year:4,'-',
    		        Date_Time.Month:2,'-',
			Date_Time.Day:2);
    WriteLn('Heure  : ',Date_Time.Hour:2,':',
		        Date_Time.Min:2,':',
		        Date_Time.Sec:2);
    WriteLn('Taille : ',Taille[Cote,PositionX[Cote]+1]:8);
    ChaineTemporaire := Copy(Nom[Cote,PositionX[Cote]+1],9,4);
    If(ChaineTemporaire='.BAT')Then
    Begin
     ChaineTemporaire := GetEnv('COMSPEC');
     Handle := Ouvre(ChaineTemporaire,0);
     If(Handle=-1)Then
     Begin
      WriteLn('Erreur : COMMAND.COM introuvable!');
      TesteQuitte;
     End
      else
     Handle := Ferme(Handle);
     Exec(ChaineTemporaire,'/C'+PathTem+Nom[Cote,PositionX[Cote]+1]);
     If(DosError=8)Then
     Begin
      WriteLn('Erreur : M‚moire insuffisante!');
      TesteQuitte;
     End
      else
     Case DosExitCode of
      1 : WriteLn('Interrompu par Ctrl - C');
      2 : WriteLn('Erreur de P‚riph‚rique');
      3 : WriteLn('Terminaison en mode r‚sidant');
     End;
    End;
    If(ChaineTemporaire='.EXE')or
      (ChaineTemporaire='.COM')Then
    Begin
     Exec(PathTem+Nom[Cote,PositionX[Cote]+1],'');
     WriteLn;
     If(DosError>0)Then Write('Erreur ',DosError:4,' : ');
     Case DosError of
      $00 : Begin
    	     Case DosExitCode of
	      0 : Write('Operation Reussit');
	      1 : Write('Interrompu par Ctrl - C');
	      2 : Write('Erreur de P‚riph‚rique');
	      3 : Write('Terminaison en mode r‚sidant');
	     End;
	    End;
      $02 : WriteLn('Fichier non-trouv‚');
      $08 : WriteLn('Pas assez de m‚moire');
      $0A : WriteLn('Environnement invalide');
      $0B : WriteLn('Format invalide');
      $0F : WriteLn('Disque incorrect');
      $16 : WriteLn('Commande incorrect');
      $1A : WriteLn('Disque non-compatible au MS-DOS');
      $1E : WriteLn('Erreur de lecture');
      $57 : WriteLn('ParamŠtre incorrect');
       else
      WriteLn('Erreur : Inconnue');
     End;
    End
     else
    WriteLn('Erreur : Extension incorrect');
90 :WriteLn;
    WriteLn('Presse une touche pour retourner au Commandeur Maltais...');
    XP := XPosition;
    YP := YPosition;
    Touche := ReadKey;
    If(KeyPressed)Then Touche := ReadKey;
    Touche := #00;
    If Not(Mem[$0044:$09] in [$02,$03])Then TexteC80;
    OuvreCurseur;
    GetMem(TableauOutPut,4000);
    Move(Mem[$B800:$00],TableauOutPut^,4000);
    Move(Tableau^,Mem[$B800:$00],798);
    FreeMem(Tableau,798);
    AfficheKeyBar;
    Tab;
   End
    else
   Write(^G);
  End;
 End;
End;

Procedure QuitteIncorrect(Chaine:String);
Begin
 WriteLn(Chaine);
 WriteLn('Impossible de lancer l''execution du CM');
 Write(^G);
 Halt;
End;

Procedure Bidon;
Interrupt;
Begin
End;

Procedure Initiation;
Begin
 If(Lo(DOSVERSION)<3)Then
 Begin
  WriteLn('Erreur : Version DOS incorrecte!');
  QuitteIncorrect('Ce programme n‚cessite un MS-DOS version 3.XX ou plus');
 End;
 With Registre do
 Begin
  If(MaxAvail>1024)Then
  Begin
   GetMem(TableauInterruption,1024);
   InLine($FA);
   Move(Mem[0:0],TableauInterruption^,1024);
   InLine($FB);
   If(Mem[0:0] <> Mem[Seg(TableauInterruption^):0])Then
   Begin
    QuitteIncorrect('Erreur : Lecture des interruptions annormale!');
   End;
   SetIntVec($1B,Ptr(Seg(Bidon),Ofs(Bidon)));
   SetIntVec($23,Ptr(Seg(Bidon),Ofs(Bidon)));
  End
   else
  QuitteIncorrect('Erreur : M‚moire insuffisante!');
  AdaptationClavier;
  AH := $33;
  AL := $00;
  MsDos(Registre);
  BreakOriginal := DL;
  If(BreakOriginal>1)Then QuitteIncorrect('Erreur : Le DOS est incorrect ou annormale')
   else
  BreakOff;
  AH := $0F;
  Intr($10,Registre);
  If Not(AL in [$02,$03])Then
  Begin
   TexteC80;
   AH := $0F;
   Intr($10,Registre);
   If(AL <> 3)Then QuitteIncorrect('Erreur : Carte vid‚o incompatible');
  End;
 End;
 If(XPosition>0)Then WriteLn;
 WriteLn('Commandeur Maltais 1.02 Copyright (C) par Sylvain Maltais');
 WriteLn;
 FermeCurseur;
 InitSouris;
 ErreurCritique := 0;
 CodeClavier    := 0;
 Menu           := 0;
 Cote           := 1;
 TabX[0]        := 4;
 TabX[1]        := 4;
 KeyBar         := 1;
 TypeTri[0]     := 0;
 TypeTri[1]     := 0;
 XP 		:= 0;
 YP 		:= 23;
 Segment        := 0;
 ChaineExtension := '';
 AncienCode1 := 0;
 AncienCode2 := 0;
 AncienCode3 := 0;
 GetMem(TableauOutPut,4000);
 Move(Mem[$B800:$00],TableauOutPut^,4000);
 BoiteCaractere(0,0,79,4,31);
 CadreVide(0,0,79,4,31);
 ClaireLigne(2,196,31);
 Mem[$B800:44]  := 194;
 Mem[$B800:116] := 194;
 Mem[$B800:204] := 179;
 Mem[$B800:276] := 179;
 Mem[$B800:364] := 193;
 Mem[$B800:436] := 193;
 Mem[$B800:320] := 195;
 Mem[$B800:478] := 180;
 CentreEcriture(1,'Commandeur Maltais',30);
 PosMenu := 0;
 PositionBar := 0;
 For Compteur := 0 to 7 do
 EcritChoix(2+Compteur*10,3,Choix[Compteur],27,31);
 Ecrit(2+PosMenu*10,3,Choix[PosMenu],94);
 AfficheKeyBar;
 GetDir(0,PathX[0]);
 If(PathX[0] = '')Then QuitteIncorrect('Erreur : R‚pertoire incorrect');
 PathX[1] := PathX[0];
 Tab;
 Move(Mem[$B800:00],Mem[$BA00:00],4000);
 Registre.AX := $000A;
 Registre.BX := $0001;
 Registre.CX := 0;
 Registre.DX := 7;
 Intr($33,Registre);
End;

Procedure KeyFermer;
Begin
 KeyBar := 0;
 ClaireLigne(24,32,Mem[Seg(TableauOutPut^):1]);
 Localise(0,23);
 TurboEcrit(PathX[Cote]+'>'+ChaineExtension);
End;

Procedure KeyOuvert;
Begin
 KeyBar := 1;
 AfficheKeyBar;
 Localise(0,23);
 TurboEcrit(PathX[Cote]+'>'+ChaineExtension);
End;

Procedure Principal;
Label 20;
Var PosTem : Byte;
    SA     : Byte;
Begin
 Sa := 0;
 Repeat
  If(Menu=0)and(TabX[Cote]=4)Then
  Begin
   For Compteur := 1 to 38 do Mem[$B800:(Compteur+Cote*40+(6+YPos[Cote])*Colonne)*2+1] := 94;
  End;
  OuvreSouris;
  Repeat
   InfoSouris(XS,YS,BS);
   If(SA=1)and(BS=0)and(Menu=1)Then
   Begin
    SA := 0;
    FermeMenu;
    If(YS in [5..20])and(XS in [02..11])and(PosMenu=0)Then
    Begin
     PositionBar := YS - 5;
     EnterMenu;
    End;
    If(YS in [5..16])and(XS in [12..28])and(PosMenu=1)Then
    Begin
     PositionBar := YS - 5;
     EnterMenu;
    End;
    If(YS in [5..15])and(XS in [22..47])and(PosMenu=2)Then
    Begin
     PositionBar := YS - 5;
     EnterMenu;
    End;
    If(YS in [5..07])and(XS in [32..39])and(PosMenu=3)Then
    Begin
     PositionBar := YS - 5;
     EnterMenu;
    End;
    If(YS in [5..09])and(XS in [42..56])and(PosMenu=4)Then
    Begin
     PositionBar := YS - 5;
     EnterMenu;
    End;
    If(YS in [5..06])and(XS in [52..67])and(PosMenu=5)Then
    Begin
     PositionBar := YS - 5;
     EnterMenu;
    End;
    If(YS in [5..20])and(XS in [62..72])and(PosMenu=6)Then
    Begin
     PositionBar := YS - 5;
     EnterMenu;
    End;
    If(YS in [5..16])and(Xs in [66..76])and(PosMenu=7)Then
    Begin
     PositionBar := YS - 5;
     EnterMenu;
    End;
    If(TabX[Cote]=4)Then
    Begin
     For Compteur := 1 to 38 do
     Begin
      Mem[$B800:(Compteur+Cote*40+(6+YPos[Cote])*Colonne)*2+1] := 94;
     End;
    End;
   End;
   If(BS<>0)Then
   Begin
    If(Menu=1)Then
    Begin
     If(YS in [5..20])and(XS in [02..11])and(PosMenu=0)Then
     Begin
      EffaceBarMenu;
      PositionBar := YS - 5;
      ReAfficheBarMenu;
     End;
     If(YS in [5..16])and(XS in [12..28])and(PosMenu=1)Then
     Begin
      EffaceBarMenu;
      PositionBar := YS - 5;
      ReAfficheBarMenu;
     End;
     If(YS in [5..15])and(XS in [22..47])and(PosMenu=2)Then
     Begin
      EffaceBarMenu;
      PositionBar := YS - 5;
      ReAfficheBarMenu;
     End;
     If(YS in [5..07])and(XS in [32..39])and(PosMenu=3)Then
     Begin
      EffaceBarMenu;
      PositionBar := YS - 5;
      ReAfficheBarMenu;
     End;
     If(YS in [5..09])and(XS in [42..56])and(PosMenu=4)Then
     Begin
      EffaceBarMenu;
      PositionBar := YS - 5;
      ReAfficheBarMenu;
     End;
     If(YS in [5..06])and(XS in [52..67])and(PosMenu=5)Then
     Begin
      EffaceBarMenu;
      PositionBar := YS - 5;
      ReAfficheBarMenu;
     End;
     If(YS in [5..20])and(XS in [62..72])and(PosMenu=6)Then
     Begin
      EffaceBarMenu;
      PositionBar := YS - 5;
      ReAfficheBarMenu;
     End;
     If(YS in [5..16])and(Xs in [66..76])and(PosMenu=7)Then
     Begin
      EffaceBarMenu;
      PositionBar := YS - 5;
      ReAfficheBarMenu;
     End;
    End;
    If(YS = 3)Then
    Begin
     Case XS of
      2..7   : PosTem := 0;
      12..19 : PosTem := 1;
      22..29 : PosTem := 2;
      32..37 : PosTem := 3;
      42..47 : PosTem := 4;
      52..60 : PosTem := 5;
      62..68 : PosTem := 6;
      72..75 : PosTem := 7;
     End;
     If(Menu=0)THen
     Begin
      SA := 1;
      EcritChoix(2+PosMenu*10,3,Choix[PosMenu],27,31);
      PosMenu := PosTem;
      Ecrit(2+PosMenu*10,3,Choix[PosMenu],94);
      EcritChoix(2+PosMenu*10,3,Choix[PosMenu],27,31);
      Move(Mem[$B800:$00],Mem[$BA00:$00],4000);
      AffichageMenu(PosMenu);
      PositionBar := 0;
      If(PosMenu = 7)Then Numerique := 6 else Numerique := 0;
      For Compteur := 2 + PosMenu*10 to 2 + PosMenu*10 + LargeurMenu[PosMenu] do
      Begin
       Mem[$B800:(Compteur - Numerique + 5*Colonne)*2+1] := 94;
      End;
      Menu := 1;
     End
      else
     If(PosMenu<>PosTem)Then
     Begin
      Move(Mem[$BA00:$00],Mem[$B800:$00],4000);
      PosMenu := PosTem;
      AffichageMenu(PosMenu);
      PositionBar := 0;
      If(PosMenu = 7)Then Segment := 6
                     Else Segment := 0;
      For Compteur := 2+PosMenu*10 to 2+PosMenu*10+LargeurMenu[PosMenu]
       do Mem[$B800:(Compteur-Segment+5*80)*2+1] := 94;
     End;
    End;
    If(YS = 24)and(Menu=0)Then
    Begin
     If(Mem[$40:96] and $10=0)Then
     Begin
      Case XS of
       00..04 : AidePrincipal;
       05..09 : MenuMaison;
       10..16 : RegardeFichier;
       17..22 : RegardeEditeFichier;
       23..28 : Copie;
       29..35 : RenomePrincipal;
       36..41 : PrincipalCreeRepertoire;
       42..48 : EffacePrincipal;
       49..55 : Equipement;
       56..64 : CertainQuitter;
       65..71 : KeyFermer;
       72..79 : KeyOuvert;
      End;
     End
      else
     Begin
      Case XS of
       00..07 : AidePrincipal;
       08..15 : MenuMaison;
       16..23 : RegardeFichier;
       24..31 : RegardeEditeFichier;
       32..39 : Copie;
       40..47 : RenomePrincipal;
       48..55 : PrincipalCreeRepertoire;
       56..63 : EffacePrincipal;
       64..70 : Equipement;
       71..79 : CertainQuitter;
      End;
     End;
    End;
   End;
   CompteurX := (CompteurX + 1) and $FF;
   ToucheSpecial;
   FermeMenu;
   If(Ctrl = 1)and(Menu = 0)Then
   Begin
    FermeCurseur;
    EcritChoix(2+PosMenu*10,3,Choix[PosMenu],27,31);
    Move(Mem[$B800:$00],Mem[$BA00:$00],4000);
    AffichageMenu(PosMenu);
    PositionBar := 0;
    If(PosMenu = 7)Then Numerique := 6 else Numerique := 0;
    For Compteur := 2 + PosMenu*10 to 2 + PosMenu*10 + LargeurMenu[PosMenu] do
    Begin
     Mem[$B800:(Compteur - Numerique + 5*Colonne)*2+1] := 94;
    End;
    Menu := 1;
   End;
  Until KeyPressed;
  FermeMenu;
  If(Menu=0)and(TabX[Cote] = 4)Then
  Begin
   For Compteur := 1 to 38 do Mem[$B800:(Compteur+40*Cote+(6+YPos[Cote])*80)*2+1] := 31 - Accepte[Cote,PositionX[Cote]+1];
  End;
  Touche := ReadKey;
  CodeClavier := 0;
  If((Ord(Touche) in [0,5,9..14,16..17,19..21,23..31])and(Menu = 1)and(Not(KeyPressed)))Then
  Begin
   Move(Mem[$BA00:$00],Mem[$B800:$00],4000);
   Ecrit(2+PosMenu*10,3,Choix[PosMenu],94);
   OuvreCurseur;
   Localise(PositionCur,23);
   Menu := 0;
  End
   else
  If(KeyPressed)Then
  Begin
   Touche      := ReadKey;
   CodeClavier := 0;
   If(Touche > #93)and(Touche < #104)and(Menu = 1)Then
   Begin
    Move(Mem[$BA00:$00],Mem[$B800:$00],4000);
    Ecrit(2+PosMenu*10,3,Choix[PosMenu],94);
    OuvreCurseur;
    Localise(PositionCur,23);
    Menu := 0;
   End;
   Case Touche of
    #30  : CreeAutoexec;
    #31  : SelectionToutFichier;
    #59  : AidePrincipal;
    #60  : MenuMaison;
    #61  : RegardeFichier;
    #62  : RegardeEditeFichier;
    #63  : Copie;
    #64  : RenomePrincipal;
    #65  : PrincipalCreeRepertoire;
    #66  : EffacePrincipal;
    #67  : Equipement;
    #71  : If(TabX[Cote]=4)Then Debut(Cote);
    #72  : Begin
	    If(TabX[Cote]=4)Then
	    Begin
	     If(PositionX[Cote]>0)Then
	     Begin
	      Dec(PositionX[Cote]);
	      If(YPos[0]=0)And(Cote=0)Then
	      Begin
	       InLine($50/         { Push AX      }
		      $53/         { Push BX      }
		      $51/         { Push CX      }
		      $52/         { Push DX      }
		      $B4/$01/     { Mov AH,01h   }
		      $B9/$20/$20/ { Mov CX,2020h }
		      $CD/$10/     { Int 10h      }
		      $B8/$01/$07/ { Mov AX,0701h }
		      $B7/$1B/     { Mov BH,1Bh   }
		      $B9/$01/$06/ { Mov CX,0601h }
		      $BA/$26/$15/ { Mov DX,1426h }
		      $CD/$10/     { Int 10h      }
		      $58/         { Pop DX       }
		      $5B/  	   { Pop CX       }
		      $59/  	   { Pop BX       }
		      $5A); 	   { Pop AX       }
	       AfficheLigne(0,PositionX[0],0);
	       Localise(PositionCur,23);
	       OuvreCurseur;
	      End
	       Else
	      If(YPos[1]=0)And(Cote=1)Then
	      Begin
	       InLine($50/         { Push AX      }
		      $53/         { Push BX      }
		      $51/         { Push CX      }
		      $52/         { Push DX      }
		      $B4/$01/     { Mov AH,01h   }
		      $B9/$20/$20/ { Mov CX,2020h }
		      $CD/$10/     { Int 10h      }
		      $B8/$01/$07/ { Mov AX,0701h }
		      $B7/$1B/     { Mov BH,1Bh   }
		      $B9/$29/$06/ { Mov CX,0629h }
		      $BA/$4E/$15/ { Mov DX,144Eh }
		      $CD/$10/     { Int 10h      }
		      $58/         { Pop DX       }
		      $5B/  	   { Pop CX       }
		      $59/  	   { Pop BX       }
		      $5A);  	   { Pop AX       }
	       AfficheLigne(0,PositionX[1],1);
	       Localise(PositionCur,23);
	       OuvreCurseur;
	      End
	       else
	      If(YPos[Cote]>0)Then Dec(YPos[Cote]);
	     End;
	    End;
	   End;
    #75  : Begin
	    EcritChoix(2+PosMenu*10,3,Choix[PosMenu],27,31);
	    PosMenu := (PosMenu - 1) and 7;
	    Ecrit(2+PosMenu*10,3,Choix[PosMenu],94);
	   End;
    #77  : Begin
	    EcritChoix(2+PosMenu*10,3,Choix[PosMenu],27,31);
	    PosMenu := (PosMenu + 1) and 7;
	    Ecrit(2+PosMenu*10,3,Choix[PosMenu],94);
	   End;
    #80  : Begin
	    If(TabX[Cote]=4)Then
	    Begin
 20        : If(PositionX[Cote]<NombreFichierX[Cote]-1)Then
	     Begin
	      Inc(PositionX[Cote]);
	      If(YPos[Cote]=LongeurCote[Cote])Then
	      Begin
	       FermeCurseur;
	       Numerique := 40 * Cote;
	       MouveFenetre(Numerique+1,6,Numerique+38,6+LongeurCote[Cote],27,-1);
	       AfficheLigne(LongeurCote[Cote],PositionX[Cote],Cote);
	      End
	       else
	      If(YPos[Cote]<LongeurCote[Cote])Then Inc(YPos[Cote]);
	     End;
	    End;
	   End;
    #82  : Begin
	    If(Attribt[Cote,PositionX[Cote]+1]<16)and(TabX[Cote]=4)Then
	    Begin
	     If(Accepte[Cote,PositionX[Cote]+1] = 0)Then
	     Begin
	      Accepte[Cote,PositionX[Cote]+1] := 1;
	      Inc(Nombre[Cote]);
	     End
	      Else
	     Begin
	      Accepte[Cote,PositionX[Cote]+1] := 0;
	      Dec(Nombre[Cote]);
	     End;
	     AfficheLigne(YPos[Cote],PositionX[Cote],Cote);
	     Touche := #00;
	     Goto 20;
	    End;
	   End;
    #96  : RegardeDisque;
    #97  : ParametreVideo;
    #102 : Begin
	    KeyBar := 0;
	    ClaireLigne(24,32,Mem[Seg(TableauOutPut^):1]);
	    Localise(0,23);
	    TurboEcrit(PathX[Cote]+'>'+ChaineExtension);
	   End;
    #103 : Begin
	    KeyBar := 1;
	    AfficheKeyBar;
	    Localise(0,23);
	    TurboEcrit(PathX[Cote]+'>'+ChaineExtension);
	   End;
    #104 : Begin
	    Cote := 0;
	    Change(0);
	   End;
    #105 : Begin
	    Cote := 1;
	    Change(1);
	   End;
    #115 : If(Menu=1)Then
	   Begin
	    Move(Mem[$BA00:$00],Mem[$B800:$00],4000);
	    PosMenu := (PosMenu - 1) and 7;
	    AffichageMenu(PosMenu);
	    PositionBar := 0;
	    If(PosMenu = 7)Then Segment := 6
			   Else Segment := 0;
	    For Compteur := 2+PosMenu*10 to 2+PosMenu*10+LargeurMenu[PosMenu]
	     do Mem[$B800:(Compteur-Segment+5*80)*2+1] := 94;
	   End;
    #116 : If(Menu=1)Then
	   Begin
	    Move(Mem[$BA00:$00],Mem[$B800:$00],4000);
	    PosMenu := (PosMenu + 1) and 7;
	    AffichageMenu(PosMenu);
	    PositionBar := 0;
	    If(PosMenu = 7)Then Segment := 6
			   Else Segment := 0;
	    For Compteur := 2+PosMenu*10 to 2+PosMenu*10+LargeurMenu[PosMenu]
	     do Mem[$B800:(Compteur-Segment+5*80)*2+1] := 94;
	   End;
    #117 : EndMenu;
    #119 : HomeMenu;
   End;
   If(Touche = #68)Then Touche := #27 else Touche := #00;
  End;
  Case Touche of
   ^A  : If(Menu=1)Then
	 Begin
	  Move(Mem[$BA00:$00],Mem[$B800:$00],4000);
	  PosMenu := 7;
	  AffichageMenu(7);
	  PositionBar := 0;
	  Segment := 6;
	  For Compteur := 2+PosMenu*10 to 2+PosMenu*10+LargeurMenu[PosMenu]
	    do Mem[$B800:(Compteur-Segment+5*80)*2+1] := 94;
	 End;
   ^B  : BasMenu;
   ^C  : If(Menu=1)Then
	 Begin
	  Move(Mem[$BA00:$00],Mem[$B800:$00],4000);
	  PosMenu := 2;
	  AffichageMenu(2);
	  PositionBar := 0;
	  Segment := 0;
	  For Compteur := 2+PosMenu*10 to 2+PosMenu*10+LargeurMenu[PosMenu]
	    do Mem[$B800:(Compteur-Segment+5*80)*2+1] := 94;
	 End;
   ^D  : If(Menu=1)Then
	 Begin
	  Move(Mem[$BA00:$00],Mem[$B800:$00],4000);
	  PosMenu := 6;
	  AffichageMenu(6);
	  PositionBar := 0;
	  Segment := 0;
	  For Compteur := 2+PosMenu*10 to 2+PosMenu*10+LargeurMenu[PosMenu]
	    do Mem[$B800:(Compteur-Segment+5*80)*2+1] := 94;
	 End;
   ^E  : EnterMenu;
   ^F  : If(Menu=1)Then
	 Begin
	  Move(Mem[$BA00:$00],Mem[$B800:$00],4000);
	  PosMenu := 1;
	  AffichageMenu(1);
	  PositionBar := 0;
	  Segment := 0;
	  For Compteur := 2+PosMenu*10 to 2+PosMenu*10+LargeurMenu[PosMenu]
	    do Mem[$B800:(Compteur-Segment+5*80)*2+1] := 94;
	 End;
   ^G  : If(Menu=1)Then
	 Begin
	  Move(Mem[$BA00:$00],Mem[$B800:$00],4000);
	  PosMenu := 0;
	  AffichageMenu(0);
	  PositionBar := 0;
	  Segment := 0;
	  For Compteur := 2+PosMenu*10 to 2+PosMenu*10+LargeurMenu[PosMenu]
	    do Mem[$B800:(Compteur-Segment+5*80)*2+1] := 94;
	 End;
   ^H  : Begin
	  If(Menu = 0)Then
	  Begin
	   FermeCurseur;
	   Delete(ChaineExtension,Length(ChaineExtension),1);
	   Numerique := 79 - Length(PathX[Cote] + '>' + ChaineExtension);
	   Localise(0,23);
	   TurboEcrit(PathX[Cote]+'>'+ChaineExtension+ChaineEspace(Numerique));
	   Numerique := Length(PathX[Cote] + '>' + ChaineExtension);
	   Localise(Numerique,23);
	   OuvreCurseur;
	   PositionCur := Mem[$0045:$00];
	  End
	   else
	  HautMenu;
	 End;
   ^I  : Begin
	  FermeSouris;
	  Cote := (Cote + 1) and 1;
	  ClaireLigne(23,32,Mem[Seg(TableauOutPut^):1]);
	  Localise(0,23);
	  TurboEcrit(PathX[Cote]+'>'+ChaineExtension);
	  Handle := ChangeRepertoire(PathX[Cote]);
	  OuvreCurseur;
	  OuvreSouris;
	  PositionCur := Mem[$0045:$00];
	 End;
   ^M  : EnterExecute;
   ^O  : If(Menu=1)Then
	 Begin
	  Move(Mem[$BA00:$00],Mem[$B800:$00],4000);
	  PosMenu := 4;
	  AffichageMenu(4);
	  PositionBar := 0;
	  Segment := 0;
	  For Compteur := 2+PosMenu*10 to 2+PosMenu*10+LargeurMenu[PosMenu]
	    do Mem[$B800:(Compteur-Segment+5*80)*2+1] := 94;
	 End;
   ^P  : StationnerDisqueDur;
   ^R  : If(Menu=1)Then
	 Begin
	  Move(Mem[$BA00:$00],Mem[$B800:$00],4000);
	  PosMenu := 5;
	  AffichageMenu(5);
	  PositionBar := 0;
	  Segment := 0;
	  For Compteur := 2+PosMenu*10 to 2+PosMenu*10+LargeurMenu[PosMenu]
	    do Mem[$B800:(Compteur-Segment+5*80)*2+1] := 94;
	 End;
   ^U  : InverseTab;
   ^V  : If(Menu=1)Then
	 Begin
	  Move(Mem[$BA00:$00],Mem[$B800:$00],4000);
	  PosMenu := 3;
	  AffichageMenu(3);
	  PositionBar := 0;
	  Segment := 0;
	  For Compteur := 2+PosMenu*10 to 2+PosMenu*10+LargeurMenu[PosMenu]
	    do Mem[$B800:(Compteur-Segment+5*80)*2+1] := 94;
	 End;
   ^Z  : InfoCM;
   #27 : CertainQuitter;
  End;
  If(Touche > #31)And(PositionCur<79)Then
  Begin
   Touche := UpCase(Touche);
   ChaineExtension := ChaineExtension + Touche;
   Mem[$B800:(PositionCur+23*Colonne)*2]:= Ord(Touche);
   Inc(PositionCur);
   Localise(PositionCur,23);
  End;
 Until (Touche = #27);
End;

BEGIN
 Initiation;
 Principal;
 QuitterP;
END.