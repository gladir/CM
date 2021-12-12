Unit CMEcran;

(*******************************************)
		 Interface
(*******************************************)

Function XPosition:Byte;
Function YPosition:Byte;

Procedure Localise(X,Y:Byte);
Procedure BoiteCaractere(X1,Y1,X2,Y2,Couleur:Byte);
Procedure EcritUnCaractere(X,Y,Caractere,Couleur:Byte);
Procedure Ecrit(X,Y:Byte;Phrase:String;Couleur:Byte);
Procedure EcritChoix(X,Y:Byte;Phrase:String;Couleur1,Couleur2:Byte);
Procedure TurboEcrit(Phrase:String);
Procedure CentreEcriture(Y:Byte;Phrase:String;Couleur:Byte);
Procedure CadreVide(X1,Y1,X2,Y2,Couleur:Byte);
Procedure CadrePlain(X1,Y1,X2,Y2,Couleur:Byte);
Procedure ClaireColonne(Colonne,Caractere,Couleur:Byte);
Procedure ClaireLigne(Ligne,Caractere,Couleur:Byte);
Procedure ClaireLigneTrans(Ligne,Caractere:Byte);
Procedure ClaireSuite(Ligne,Colonne,Longeur,Caractere,Couleur:Byte);
Procedure MouveFenetre(X1,Y1,X2,Y2,Couleur:Byte;Direction:Integer);
Procedure CadreChoix(X1,Y1,X2,Y2:Byte;Chaine:String);

(*******************************************)
	       Implementation
(*******************************************)

Uses DOS;

Var Registre : Registers;
    Compteur : Word;
    Colonne  : Word Absolute $0040 : $4A;

Function XPosition:Byte;
Begin
 Registre.AH := $03;
 Registre.BH := $00;
 Intr($10,Registre);
 XPosition := Registre.DL;
End;

Function YPosition:Byte;
Begin
 Registre.AH := $03;
 Registre.BH := $00;
 Intr($10,Registre);
 YPosition := Registre.DH;
End;

Procedure Localise(X,Y:Byte);
Begin
 Registre.AH := $02;
 Registre.BH := $00;
 Registre.DL := X;
 Registre.DH := Y;
 Intr($10,Registre);
End;

Procedure BoiteCaractere(X1,Y1,X2,Y2,Couleur:Byte);
Var X,Y : Byte;
Begin
 For Y := Y1 to Y2 do For X := X1 to X2 do
 Begin
  MemW[$B800:(X+Y*80)*2] := Couleur * 256;
 End;
End;

Procedure EcritUnCaractere(X,Y,Caractere,Couleur:Byte);
Begin
 MemW[$B800:(X+Y*80)*2] := Caractere + Couleur * 256;
End;

Procedure Ecrit(X,Y:Byte;Phrase:String;Couleur:Byte);
Var Compteur : Byte;
Begin
 For Compteur := 0 to Length(Phrase)-1 do
 Begin
  MemW[$B800:(X+Compteur+Y*Colonne)*2] := Ord(Phrase[Compteur+1]) + Couleur * 256;
 End;
End;

Procedure EcritChoix(X,Y:Byte;Phrase:String;Couleur1,Couleur2:Byte);
Var Compteur : Byte;
Begin
 EcritUnCaractere(X,Y,Ord(Phrase[1]),Couleur1);
 For Compteur := 1 to Length(Phrase)-1 do
 Begin
  EcritUnCaractere(X+Compteur,Y,Ord(Phrase[Compteur+1]),Couleur2);
 End;
End;

Procedure TurboEcrit(Phrase:String);
Var Compteur,Position : Byte;
Begin
 Position := XPosition;
 For Compteur := 0 to Length(Phrase)-1 do
 Begin
  Localise(Position+Compteur,YPosition);
  Registre.AL := Ord(Phrase[Compteur+1]);
  Registre.AH := $0A;
  Registre.BH := $00;
  Registre.CX := $0001;
  Intr($10,Registre);
 End;
 Localise(Position+Compteur+1,YPosition);
End;

Procedure CentreEcriture(Y:Byte;Phrase:String;Couleur:Byte);
Begin
 Ecrit(40 - Length(Phrase) div 2,Y,Phrase,Couleur);
End;

Procedure CadreVide(X1,Y1,X2,Y2,Couleur:Byte);
Var Compteur : Byte;
Begin
 For Compteur := Y1+1 to Y2-1 do
 Begin
  EcritUnCaractere(X1,Compteur,$B3,Couleur);
  EcritUnCaractere(X2,Compteur,$B3,Couleur);
 End;
 For Compteur := X1+1 to X2-1 do
 Begin
  MemW[$B800:(Compteur+Y1*80)*2] := $C4 + Couleur * $100;
  MemW[$B800:(Compteur+Y2*80)*2] := $C4 + Couleur * $100;
 End;
 EcritUnCaractere(X1,Y1,218,Couleur);
 EcritUnCaractere(X1,Y2,192,Couleur);
 EcritUnCaractere(X2,Y1,191,Couleur);
 EcritUnCaractere(X2,Y2,217,Couleur);
End;

Procedure CadrePlain(X1,Y1,X2,Y2,Couleur:Byte);
Var Compteur : Byte;
Begin
 BoiteCaractere(X1,Y1,X2,Y2,Couleur);
 For Compteur := X1+2 to X2+2 do Mem[$B800:(Compteur+Y2*Colonne)*2+161] := 7;
 For Compteur := Y1+1 to Y2+1 do
 Begin
  Mem[$B800:(X2+Compteur*Colonne)*2+3]:=7;
  Mem[$B800:(X2+Compteur*Colonne)*2+5]:=7;
 End;
 CadreVide(X1+2,Y1+1,X2-2,Y2-1,Couleur);
End;

Procedure ClaireColonne(Colonne,Caractere,Couleur:Byte);
Var Compteur : Byte;
Begin
 For Compteur:=0 to 24 do EcritUnCaractere(Colonne,Compteur,Caractere,Couleur);
End;

Procedure ClaireLigne(Ligne,Caractere,Couleur:Byte);
Begin
 For Compteur := 0 to 79 do
 Begin
  MemW[$B800:(Ligne*80+Compteur)*2] := Caractere + Couleur * 256;
 End;
End;

Procedure ClaireLigneTrans(Ligne,Caractere:Byte);
Var Compteur : Byte;
Begin
 For Compteur := 0 to 79 do Mem[$B800:(Ligne*80+Compteur)*2] := Caractere;
End;

Procedure ClaireSuite(Ligne,Colonne,Longeur,Caractere,Couleur:Byte);
Begin
 Localise(Colonne,Ligne);
 Registre.AL := Caractere;
 Registre.AH := $09;
 Registre.BL := Couleur;
 Registre.BH := $00;
 Registre.CX := Longeur;
 Intr($10,Registre);
 Localise(Colonne,Ligne);
End;

Procedure MouveFenetre(X1,Y1,X2,Y2,Couleur:Byte;Direction:Integer);
Begin
 If(Direction < 0)Then Registre.AH := $06
  else
 If(Direction > 0)Then Registre.AH := $07;
 Registre.AL := Abs(Direction);
 Registre.CL := X1;
 Registre.CH := Y1;
 Registre.DL := X2;
 Registre.DH := Y2;
 Registre.BL := Couleur;
 Intr($10,Registre);
End;

Procedure CadreChoix(X1,Y1,X2,Y2:Byte;Chaine:String);

 Procedure EcritUnCaractere(X,Y,Caractere:Byte);
 Begin
  Mem[$B800:(X+Y*Colonne)*2] := Caractere;
 End;

Begin
 BoiteCaractere(X1,Y1,X2,Y2,31);
 EcritUnCaractere(X1,Y1,218);
 EcritUnCaractere(X1,Y2,192);
 EcritUnCaractere(X2,Y1,191);
 EcritUnCaractere(X2,Y2,217);
 EcritUnCaractere(X1,Y1+1,$B3);
 EcritUnCaractere(X2,Y1+1,$B3);
 EcritUnCaractere(X1,Y1+2,195);
 EcritUnCaractere(X2,Y1+2,180);
 For Compteur := X1+1 to X2-1 do
 Begin
  Mem[$B800:(Y1*80+Compteur)*2]     := $C4;
  Mem[$B800:((Y1+2)*80+Compteur)*2] := $C4;
  Mem[$B800:(Y2*80+Compteur)*2]     := $C4;
 End;
 For Compteur := Y1+3 to Y2-1 do
 Begin
  EcritUnCaractere(X1,Compteur,$B3);
  EcritUnCaractere(X2,Compteur,$B3);
 End;
 For Compteur := X1+2 to X2+2 do
  Mem[$B800:(Compteur+Y2*Colonne)*2+161] := 7;
 For Compteur := Y1+1 to Y2+1 do
 Begin
  Mem[$B800:(X2+Compteur*Colonne)*2+3] := 7;
  Mem[$B800:(X2+Compteur*Colonne)*2+5] := 7;
 End;
 Ecrit(X1+2,Y1+1,Chaine,94);
End;

End.
