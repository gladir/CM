Procedure AfficheGrille(TailleBuffer:Word);
Var X : Byte;
    Y : Byte;
Begin
 If(TailleBuffer = 256)Then
 Begin
  For Y := 0 to 15 do
  Begin
   For X := 0 to 15 do
   Begin
    Mem[$B800:(X*3+Y*80)*2+1146]:=Ord(HexData[(Mem[$B900:Y*16+X])Shr 4]);
    Mem[$B800:(X*3+Y*80)*2+1148]:=Ord(HexData[(Mem[$B900:Y*16+X])And 15]);
    Mem[$B800:(X+Y*80)*2+1244]:=Mem[$B900:Y*16+X];
   End;
  End;
 End
  else
 Begin
  For Y := 0 to 15 do
  Begin
   For X := 0 to 63 do
   Begin
    Mem[$B800:(X+Y*80)*2+1148]:=Mem[$B900:Y*64+X];
   End;
  End;
 End;
End;

Procedure AideRegardeFichier;
Var Tableau : Pointer;
    Handle  : Integer;
    Erreur : Byte;
Begin
 Erreur := SauvegardeData(Tableau);
 If(Erreur=0)Then
 Begin
  Handle := Ouvre('CM.HLP',0);
  If(Handle = - 1)Then ErreurAide
   else
  Begin
   LitEnregistrement(Handle,0,4000,Mem[$B800:$00]);
   If(ErreurFichier<>0)Then
   Begin
    BoiteCaractere(11,12,68,14,$4F);
    CadreVide(10,11,69,15,$4F);
    CentreEcriture(12,'Erreur : Dans lecture du fichier d''aide',$4F);
    CentreEcriture(13,'Impossible d''obtenir de l''aide',$4F);
    CentreEcriture(14,'Presse une touche pour retourner...',$4E);
    Write(^G);
   End;
   Handle := Ferme(Handle);
  End;
  Repeat Until KeyPressed;
  Touche := ReadKey;
  If KeyPressed Then Touche := ReadKey;
  RestorationData(Tableau);
 End
  else
 Write(^G);
End;

Procedure RegardeFichier;
Var Tableau : Pointer;
    Erreur  : Byte;
Begin
 If(TabX[Cote] = 4)And(Attribt[Cote,PositionX[Cote]+1] < 16)Then
 Begin
  PathTem := PathX[Cote];
  If(PathTem[Length(PathTem)] <> '\')Then PathTem := PathX[Cote] + '\';
  PathTem := PathTem + Nom[Cote,PositionX[Cote]+1];
  Handle := Ouvre(PathTem,0);
 End
  else
 Handle := -1;
 If(Handle <> -1)Then
 Begin
  Erreur := SauvegardeData(Tableau);
  If(Erreur=0)Then
  Begin
   Longeur := TailleFichier(Handle)-1;
   ClaireLigne(24,32,7);
   Position := 0;
   BoiteCaractere(0,1,79,23,31);
   CadreVide(0,1,79,4,31);
   CadreVide(0,5,79,25,31);
   ClaireLigne(0,219,15);
   MemW[$B800:3840] := $0731;
   Ecrit(1,24,'Aide  ',48);EcritUnCaractere(8,24,$32,7);
   Ecrit(9,24,'Texte ',48);EcritUnCaractere(16,24,$33,7);
   Ecrit(17,24,'Hex   ',48);EcritUnCaractere(24,24,$34,7);
   Ecrit(25,24,'      ',48);EcritUnCaractere(32,24,$35,7);
   Ecrit(33,24,'      ',48);EcritUnCaractere(40,24,$36,7);
   Ecrit(41,24,'      ',48);EcritUnCaractere(48,24,$37,7);
   Ecrit(49,24,'      ',48);EcritUnCaractere(56,24,$38,7);
   Ecrit(57,24,'      ',48);EcritUnCaractere(64,24,$39,7);
   Ecrit(65,24,'      ',48);Ecrit(71,24,'10',7);
   Ecrit(73,24,'Quitter',48);
   Ecrit(0,0,' Regarde Sylvain Maltais (CM) ',$4F);
   Ecrit(2,2,'Explore :',31);
   Ecrit(12,2,PathTem,27);
   Ecrit(2,3,'Secteur Relative :',31);
   Ecrit(21,3,ChaineZero(10),27);
   Ecrit(33,3,'Handle :',31);
   Localise(42,3);
   TextColor(11);
   TextBackGround(1);
   Write(Handle);
   Ecrit(46,3,'Taille :',31);
   Localise(55,3);
   Write(Longeur);
   Compteur  := 0;
   CompteurX := 256;
   Repeat
    Ecrit(6,7+Compteur,Hex(Compteur*16),27);
    Inc(Compteur);
   Until (Compteur = 16);
   VG := 0;
   Repeat
    FillChar(Mem[$B900:$00],CompteurX,0);
    LitEnregistrement(Handle,Position,CompteurX,Mem[$B900:$00]);
    AfficheGrille(CompteurX);
    Tem := Hex(Position div 2);
    Mem[$B800:534]:=ord(Tem[1]);
    Mem[$B800:536]:=ord(Tem[2]);
    Mem[$B800:538]:=ord(Tem[3]);
    Mem[$B800:540]:=ord(Tem[4]);
    Touche := ReadKey;
    IF KeyPressed Then
    Begin
     Touche := ReadKey;
     Case Touche Of
      #59 : AideRegardeFichier;
      #61 : Begin
     	     If(CompteurX = 1024)Then Position := Position * 4;
	     CompteurX := 256;
	     BoiteCaractere(10,6,78,23,31);
	    End;
      #60 : Begin
	     If(CompteurX = 256)Then Position := Position div 4;
	     CompteurX := 1024;
	     BoiteCaractere(10,6,78,23,31);
	    End;
      'I' : Begin
	     Dec(Position);
	     Vg:=(Vg-1)And 1;
	     If Position < 0 Then
	     Begin
	      Position := 0;
	      VG       := 0;
	     End;
	    End;
      'Q' : Begin
	     Inc(Position);
	     Vg:=(Vg+1)And 1;
	     If Position > Longeur div CompteurX Then
	     Begin
	      Position := Longeur div CompteurX;
	      VG       := 0;
	     End;
	    End;
      'G' : Begin
	     Position := 0;
	     Vg       := 0;
	    End;
      'O' : Begin
	     Position := Longeur div CompteurX;
	     If Odd(Trunc(Position)) = False Then Vg := 0 Else Vg := 1;
	    End;
     End;
     If(Touche = #68)Then Touche := #27 else Touche := #00;
    End;
   Until (Touche = #27);
   RestorationData(Tableau);
  End
   else
  Write(^G);
  Handle := Ferme(Handle);
 End
  else
 Begin
  Erreur := SauvegardeData(Tableau);
  If(Erreur=0)Then
  Begin
   BoiteCaractere(1,12,78,14,$4F);
   CadreVide(0,11,79,15,$4F);
   CentreEcriture(12,'Erreur : Fichier introuvable',$4F);
   CentreEcriture(13,'Impossible de visualiser le contenu',$4F);
   CentreEcriture(14,'Presse une touche pour retourner...',$4E);
   Write(^G);
   Touche := ReadKey;
   If(keyPressed)Then Touche := ReadKey;
   RestorationData(Tableau);
  End
   else
  Write(^G);
 End;
End;

Procedure RegardeEditeFichier;
Var Tableau      : Pointer;
    XTaille      : Byte;
    YTaille      : Byte;
    XPosition    : Byte;
    YPosition    : Byte;
    TypeEcran    : Byte;
    TailleBuffer : Word;
    CoteEcrit    : Byte;
    Resultat     : Byte;
    Couleur      : Byte;
    Reponse      : Byte;
    Modifier     : Boolean;
    Erreur       : Byte;

 Procedure Avance;
 Begin
  If(TypeEcran = 2)Then
  Begin
   If(CoteEcrit=0)Then CoteEcrit := 1
    else
   If(CoteEcrit=1)Then
   Begin
    CoteEcrit := 0;
    Inc(XPosition);
    If(XPosition > XTaille)Then
    Begin
     XPosition := 0;
     YPosition := (YPosition + 1) and 15;
    End;
   End;
  End
   else
  Begin
   Inc(XPosition);
   If(XPosition > XTaille)Then
   Begin
    XPosition := 0;
    YPosition := (YPosition + 1) and 15;
   End;
  End;
 End;

 Function TesteSauvegarde : Byte;
 Var Tableau  : Pointer;
     Position : Byte;
     Compteur : Byte;
     Ok       : Boolean;
     Erreur   : Byte;
 Begin
  TesteSauvegarde := 4;
  If(Modifier)Then
  Begin
   Erreur := SauvegardeData(Tableau);
   If(Erreur=0)Then
   Begin
    CadrePlain(20,7,59,17,63);
    CentreEcriture(10,'Menu Editeur',62);
    CentreEcriture(12,'Sauvegarde',59);
    CentreEcriture(13,'Continue',59);
    CentreEcriture(14,'Quitte',59);
    Ok 	    := False;
    Position := 0;
    Repeat
     For Compteur := 30 to 49 do Mem[$B800:(Compteur+(Position+12)*80)*2+1] := 94;
     Touche := ReadKey;
     For Compteur := 30 to 49 do Mem[$B800:(Compteur+(Position+12)*80)*2+1] := 59;
     Case Touche of
      #27 : Begin
    	    TesteSauvegarde := 1;
    	    Ok := True;
	   End;
     #13 : Begin
	    TesteSauvegarde := Position;
	    Ok := True;
	   End;
     End;
     If(KeyPressed)Then
     Begin
      Touche := ReadKey;
      Case Touche of
       #71 : Position := 0;
       #72 : If(Position>0)Then Dec(Position)
			   Else Position := 0;
       #79 : Position := 2;
       #80 : If(Position<2)Then Inc(Position)
			   Else Position := 2;
      End;
     End;
    Until Ok;
    RestorationData(Tableau);
   End
    else
   Write(^G);
  End;
  Modifier := False;
 End;

Begin
 If(TabX[Cote] = 4)And(Attribt[Cote,PositionX[Cote]+1] < 16)Then
 Begin
  PathTem := PathX[Cote];
  If(PathTem[Length(PathTem)] <> '\')Then PathTem := PathX[Cote] + '\';
  PathTem := PathTem + Nom[Cote,PositionX[Cote]+1];
  Handle := Ouvre(PathTem,2);
 End
  else
 Handle := -1;
 If(Handle <> -1)Then
 Begin
  Longeur := TailleFichier(Handle)-1;
  Erreur := SauvegardeData(Tableau);
  If(Erreur=0)Then
  Begin
   ClaireLigne(24,32,7);
   BoiteCaractere(0,1,79,23,31);
   CadreVide(0,1,79,4,31);
   CadreVide(0,5,79,25,31);
   ClaireLigne(0,219,15);
   MemW[$B800:3840] := $0731;
   Ecrit(1,24,'Aide  ',48);EcritUnCaractere(8,24,$32,7);
   Ecrit(9,24,'Texte ',48);EcritUnCaractere(16,24,$33,7);
   Ecrit(17,24,'Hex   ',48);EcritUnCaractere(24,24,$34,7);
   Ecrit(25,24,'      ',48);EcritUnCaractere(32,24,$35,7);
   Ecrit(33,24,'      ',48);EcritUnCaractere(40,24,$36,7);
   Ecrit(41,24,'Sauve ',48);EcritUnCaractere(48,24,$37,7);
   Ecrit(49,24,'      ',48);EcritUnCaractere(56,24,$38,7);
   Ecrit(57,24,'      ',48);EcritUnCaractere(64,24,$39,7);
   Ecrit(65,24,'      ',48);Ecrit(71,24,'10',7);
   Ecrit(73,24,'Quitter',48);
   Ecrit(0,0,' Regarde/Editeur Sylvain Maltais (CM) ',$4F);
   Ecrit(2,2,'Explore :',31);
   TextBackGround(1);
   TextColor(11);
   Localise(12,2);
   Write(PathTem);
   Ecrit(2,3,'Secteur Relative :',31);
   Localise(21,3);
   Write(ChaineZero(10));
   Ecrit(33,3,'Handle :',31);
   Localise(42,3);
   Write(Handle);
   Ecrit(46,3,'Taille :',31);
   Localise(55,3);
   Write(Longeur);
   Position     := 0;
   Compteur     := 0;
   TailleBuffer := 256;
   XPosition    := 0;
   YPosition    := 0;
   XTaille      := 15;
   YTaille      := 15;
   TypeEcran    := 0;
   CoteEcrit    := 0;
   Modifier     := False;
   Repeat
    Ecrit(6,7+Compteur,Hex(Compteur*16),27);
    Inc(Compteur);
   Until (Compteur = 16);
   VG := 0;
   FillChar(Mem[$B900:$00],TailleBuffer,0);
   LitEnregistrement(Handle,Position,TailleBuffer,Mem[$B900:$00]);
   AfficheGrille(TailleBuffer);
   OuvreCurseur;
   Repeat
    Tem := Hex(Position div 2);
    Mem[$B800:534]:=ord(Tem[1]);
    Mem[$B800:536]:=ord(Tem[2]);
    Mem[$B800:538]:=ord(Tem[3]);
    Mem[$B800:540]:=ord(Tem[4]);
    Case TypeEcran of
     0 : Begin
  	 Localise(62+XPosition,7+YPosition);
  	 Couleur := Mem[$B800:(13+XPosition * 3 + (7+YPosition)*80)*2+1];
 	 Mem[$B800:(13+XPosition * 3 + (7+YPosition)*80)*2+1] := 94;
 	 Mem[$B800:(14+XPosition * 3 + (7+YPosition)*80)*2+1] := 94;
         End;
     1 : Localise(14+XPosition,7+YPosition);
     2 : Begin
 	 Localise(13+XPosition * 3 + CoteEcrit,7+YPosition);
 	 Couleur := Mem[$B800:(62+XPosition+(7+YPosition)*80)*2+1];
 	 Mem[$B800:(62+XPosition+(7+YPosition)*80)*2+1] := 94;
         End;
    End;
    Touche := ReadKey;
    Case TypeEcran of
     0 : Begin
     	 Mem[$B800:(13+XPosition * 3 + (7+YPosition)*80)*2+1] := Couleur;
 	 Mem[$B800:(14+XPosition * 3 + (7+YPosition)*80)*2+1] := Couleur;
         End;
     2 : Mem[$B800:(62+XPosition+(7+YPosition)*80)*2+1] := Couleur;
    End;
    Case Touche of
     #9 : If(TailleBuffer=256)Then
    	 Begin
 	  If(TypeEcran = 0)Then TypeEcran := 2
  			   Else TypeEcran := 0;
   	 End;
    #13 : Begin
 	  XPosition := 0;
 	  YPosition := (YPosition + 1) and 15;
 	 End;
     else
    Begin
     If((Touche>#31)and(TypeEcran in [0,1]))Then
     Begin
      Mem[$B900:XPosition+YPosition*(XTaille+1)] := Ord(Touche);
      Modifier  := True;
      If(XTaille=63)Then Resultat := 14 + XPosition
 		   Else Resultat := 62 + XPosition;
      EcritUnCaractere(Resultat,7+YPosition,Ord(Touche),30);
      If(XTaille=15)Then
      Begin
       Ecrit(13+XPosition * 3,7+YPosition,Hex2(Ord(Touche)),30);
      End;
      Avance;
     End
      else
     If((UpCase(Touche) in ['0'..'9','A'..'F'])and(TypeEcran = 2))Then
     Begin
      Modifier  := True;
      Case UpCase(Touche) of
       '0' : Resultat := 0;
       '1' : Resultat := 1;
       '2' : Resultat := 2;
       '3' : Resultat := 3;
       '4' : Resultat := 4;
       '5' : Resultat := 5;
       '6' : Resultat := 6;
       '7' : Resultat := 7;
       '8' : Resultat := 8;
       '9' : Resultat := 9;
       'A' : Resultat := 10;
       'B' : Resultat := 11;
       'C' : Resultat := 12;
       'D' : Resultat := 13;
       'E' : Resultat := 14;
       'F' : Resultat := 15;
      End;
      Case CoteEcrit of
       1 : Mem[$B900:XPosition + YPosition * 16] :=
 	  (Mem[$B900:XPosition + YPosition * 16] shr 4) shl 4 +
  	  Resultat;
       0 : Mem[$B900:XPosition + YPosition * 16] :=
 	  (Mem[$B900:XPosition + YPosition * 16] and 15) +
 	  (Resultat shl 4);
      End;
      Mem[$B800:(13+XPosition * 3+(7+YPosition)*80)*2+1] := 30;
      Mem[$B800:(14+XPosition * 3+(7+YPosition)*80)*2+1] := 30;
      EcritUnCaractere(62+XPosition,YPosition+7,Mem[$B900:XPosition + YPosition * 16],30);
      EcritUnCaractere(13+XPosition * 3+CoteEcrit,7+YPosition,Ord(UpCase(Touche)),30);
      Avance;
     End;
    End;
   End;
   IF KeyPressed Then
   Begin
    Touche := ReadKey;
    Case Touche Of
     #59 : AideRegardeFichier;
     #61 : Begin
 	   Reponse := TesteSauvegarde;
 	   If(Reponse=0)Then
 	   Begin
 	    ModifieEnregistrement(Handle,Position,TailleBuffer,Mem[$B900:$00]);
 	    BoiteCaractere(10,6,78,23,31);
 	    AfficheGrille(TailleBuffer);
 	   End;
 	   If(Reponse=2)Then
           Begin
            RestorationData(Tableau);
            Exit;
           End;
 	   If(Reponse=4)Then
 	   Begin
 	    If(TailleBuffer = 1024)Then Position := Position * 4;
 	    TailleBuffer := 256;
 	    XTaille 	:= 15;
 	    YTaille 	:= 15;
 	    XPosition 	:= 0;
 	    YPosition 	:= 0;
 	    TypeEcran    := 0;
 	    BoiteCaractere(10,6,78,23,31);
 	    AfficheGrille(TailleBuffer);
 	   End;
 	  End;
     #60 : Begin
 	   Reponse := TesteSauvegarde;
 	   If(Reponse=0)Then
 	   Begin
 	    ModifieEnregistrement(Handle,Position,TailleBuffer,Mem[$B900:$00]);
 	    BoiteCaractere(10,6,78,23,31);
 	    AfficheGrille(TailleBuffer);
 	   End;
 	   If(Reponse=2)Then
           Begin
            RestorationData(Tableau);
            Exit;
           End;
 	   If(Reponse=4)Then
 	   Begin
 	    If(TailleBuffer = 256)Then Position := Position div 4;
 	    TailleBuffer := 1024;
 	    XTaille 	:= 63;
 	    YTaille 	:= 15;
 	    XPosition 	:= 0;
  	    YPosition 	:= 0;
 	    TypeEcran    := 1;
 	    BoiteCaractere(10,6,78,23,31);
 	    FillChar(Mem[$B900:$00],TailleBuffer,0);
 	    LitEnregistrement(Handle,Position,TailleBuffer,Mem[$B900:$00]);
 	    AfficheGrille(TailleBuffer);
 	   End;
 	  End;
     #64 : Begin
 	   Reponse := TesteSauvegarde;
 	   If(Reponse=0)Then
 	   Begin
 	    ModifieEnregistrement(Handle,Position,TailleBuffer,Mem[$B900:$00]);
 	    BoiteCaractere(10,6,78,23,31);
 	    AfficheGrille(TailleBuffer);
	   End;
           If(Reponse=2)Then
           Begin
            RestorationData(Tableau);
            Exit;
           End;
 	  End;
     #72 : YPosition := (YPosition - 1) and YTaille;
     #73 : Begin
 	   Reponse := TesteSauvegarde;
 	   If(Reponse=0)Then
 	   Begin
 	    ModifieEnregistrement(Handle,Position,TailleBuffer,Mem[$B900:$00]);
 	    BoiteCaractere(10,6,78,23,31);
 	    AfficheGrille(TailleBuffer);
 	   End;
 	   If(Reponse=2)Then
           Begin
            RestorationData(Tableau);
            Exit;
           End;
 	   If(Reponse=4)Then
 	   Begin
 	    Dec(Position);
 	    Vg:=(Vg-1)And 1;
 	    If Position < 0 Then
 	    Begin
 	     Position := 0;
 	     VG       := 0;
 	    End;
 	    FillChar(Mem[$B900:$00],TailleBuffer,0);
 	    LitEnregistrement(Handle,Position,TailleBuffer,Mem[$B900:$00]);
 	    AfficheGrille(TailleBuffer);
 	   End;
 	  End;
     #75 : If(TypeEcran = 2)Then
 	  Begin
 	   If(CoteEcrit=1)Then CoteEcrit := 0
 	    else
 	   If(CoteEcrit=0)Then
 	   Begin
 	    CoteEcrit := 1;
 	    XPosition := (XPosition - 1) and XTaille;
 	   End;
 	  End
 	   else
 	  XPosition := (XPosition - 1) and XTaille;
     #77 : Avance;
     #80 : YPosition := (YPosition + 1) and YTaille;
     #81 : Begin
 	   Reponse := TesteSauvegarde;
 	   If(Reponse=0)Then
 	   Begin
 	    ModifieEnregistrement(Handle,Position,TailleBuffer,Mem[$B900:$00]);
 	    BoiteCaractere(10,6,78,23,31);
 	    AfficheGrille(TailleBuffer);
 	   End;
 	   If(Reponse=2)Then
           Begin
            RestorationData(Tableau);
            Exit;
           End;
 	   If(Reponse=4)Then
 	   Begin
 	    Inc(Position);
 	    Vg:=(Vg+1)And 1;
 	    If Position > Longeur div CompteurX Then
 	    Begin
 	     Position := Longeur div CompteurX;
 	     VG       := 0;
 	    End;
 	    FillChar(Mem[$B900:$00],TailleBuffer,0);
 	    LitEnregistrement(Handle,Position,TailleBuffer,Mem[$B900:$00]);
 	    AfficheGrille(TailleBuffer);
 	   End;
 	  End;
     'G' : Begin
 	   XPosition := 0;
 	   YPosition := 0;
 	  End;
     'O' : Begin
  	   XPosition := XTaille;
  	   YPosition := YTaille;
  	  End;
     End;
     If(Touche = #68)Then Touche := #27 else Touche := #00;
    End;
   Until (Touche = #27);
   RestorationData(Tableau);
  End
   else
  Write(^G);
  Handle := Ferme(Handle);
 End
  else
 Begin
  Erreur := SauvegardeData(Tableau);
  If(Erreur=0)Then
  Begin
   BoiteCaractere(11,12,68,14,$4F);
   CadreVide(10,11,69,15,$4F);
   CentreEcriture(12,'Erreur : Fichier introuvable',$4F);
   CentreEcriture(13,'Impossible d''editer le contenu',$4F);
   CentreEcriture(14,'Presse une touche pour retourner...',$4E);
   Write(^G);
   Touche := ReadKey;
   If(keyPressed)Then Touche := ReadKey;
   RestorationData(Tableau);
  End
   else
  Write(^G);
 End;
End;