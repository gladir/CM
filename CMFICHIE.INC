		 (* Manipulation des fichier *)

Const ErreurFichier : Word = 0;

Procedure ReelEnDoubleMot(Reel : LongInt; Var Grand,Petit : Word);
Var Temporaire : LongInt;
Begin
 Grand := Trunc( Reel / 65536 );
 Temporaire := Reel - ( Grand * 65536 );
 Petit := Trunc(Temporaire);
End;

Function DoubleMotEnReel(Grand,Petit : Word) : LongInt;
Var Temporaire : LongInt;
Begin
 Temporaire := Petit;
 If(Temporaire < 0)Then Temporaire := Temporaire + 65536;
 DoubleMotEnReel := (Grand * 65536) + Temporaire;
End;

Procedure Positionne(Handle : Integer; RecNum : LongInt; Taille : Word);
Var Grand,Petit : Word;
    Position    : LongInt;
Begin
 Position := RecNum * Taille;
 ReelEnDoubleMot(Position,Grand,Petit);
 Registre.AX := $4200;
 Registre.BX := Handle;
 Registre.CX := Grand;
 Registre.DX := Petit;
 MsDos(Registre);
 If((Registre.Flags and 1) <> 0)Then ErreurFichier := Registre.AX
				Else ErreurFichier := 0;
End;

Function TailleFichier(Handle : Integer) : LongInt;
Begin
 Registre.AX := $4202;
 Registre.BX := Handle;
 Registre.CX := $0000;
 Registre.DX := $0000;
 MsDos(Registre);
 If((Registre.Flags And 1) <> 0)Then
 Begin
  TailleFichier := -1;
  ErreurFichier := Registre.AX;
 End
  Else
 Begin
  TailleFichier := DoubleMotEnReel(Registre.DX,Registre.AX);
  ErreurFichier := 0;
 End;
End;

Function Ferme(Handle : Integer) : Integer;
Begin
 Registre.AX := $3E00;
 Registre.BX := Handle;
 MsDos(Registre);
 If((Registre.Flags and 1) <> 0)Then
 Begin
  Ferme := Registre.AX;
  ErreurFichier := Registre.AX;
 End
  Else
 Begin
  Ferme         := 0;
  ErreurFichier := 0;
 End;
End;

Function Ouvre(Nom : Chemin;Mode:Byte) : Integer;
Var Temporaire : Chemin;
Begin
 Temporaire := Nom + #00;
 Registre.AH := $3D;
 Registre.AL := $40+Mode;
 Registre.DS := Seg(Temporaire[1]);
 Registre.DX := Ofs(Temporaire[1]);
 MsDos(Registre);
 If((Registre.Flags and 1) <> 0)Then
 Begin
  Ouvre         := -1;
  ErreurFichier := Registre.AX;
 End
  else
 Begin
  Ouvre         := Registre.AX;
  ErreurFichier := 0;
 End;
End;

Function Cree(Nom : Chemin) : Integer;
Var Temporaire : Chemin;
Begin
 Move(Nom[1],Temporaire,Length(Nom));
 Temporaire:= Nom + #00;
 Registre.AH := $3C;
 Registre.DS := Seg(Temporaire[1]);
 Registre.DX := Ofs(Temporaire[1]);
 Registre.CX := $0000;
 MsDos(Registre);
 If((Registre.Flags and 1)<>0)Then
 Begin
  Cree          := -1;
  ErreurFichier := Registre.AX;
 End
  Else
 Begin
  Cree          := Registre.AX;
  ErreurFichier := 0;
 End;
End;

Function Efface(Nom : Chemin) : Integer;
Var Temporaire : Chemin;
Begin
 Temporaire := Nom + #00;
 Registre.AX := $4100;
 Registre.DS := Seg(Temporaire[1]);
 Registre.DX := Ofs(Temporaire[1]);
 MsDos(Registre);
 If((Registre.Flags and 1) <> 0)Then
 Begin
  Efface        := Registre.AX;
  ErreurFichier := Registre.AX;
 End
  else
 Begin
  Efface        := 0;
  ErreurFichier := 0;
 End;
End;

Procedure LitEnregistrement(Handle : Integer; RecNum : LongInt; Taille : Word; Var Buffer);
Begin
 Positionne(Handle,RecNum,Taille);
 Registre.AX := $3F00;
 Registre.BX := Handle;
 Registre.CX := Taille;
 Registre.DS := Seg(Buffer);
 Registre.DX := Ofs(Buffer);
 MsDos(Registre);
 If((Registre.Flags and 1) <> 0)Then ErreurFichier := Registre.AX
				Else ErreurFichier := 0;
End;

Procedure ModifieEnregistrement(Handle : Integer; RecNum : LongInt; Taille : Word; Var Buffer);
Begin
 Positionne(Handle,RecNum,Taille);
 Registre.AX := $4000;
 Registre.BX := Handle;
 Registre.CX := Taille;
 Registre.DS := Seg(Buffer);
 Registre.DX := Ofs(Buffer);
 MsDos(Registre);
 If((Registre.Flags and 1) <> 0)Then ErreurFichier := Registre.AX
				Else ErreurFichier := 0;
End;

Procedure AjouteEnregistrement(Handle : Integer; RecNum : LongInt; Taille : Word; Var Buffer);
Begin
 RecNum := Trunc((TailleFichier(Handle))/Taille);
 ModifieEnregistrement(Handle,RecNum,Taille,Buffer);
End;

Function MajDirectoire(Handle : Integer) : Integer;
Begin
 Registre.AX := $4500;
 Registre.BX := Handle;
 MsDos(Registre);
 If((Registre.Flags and 1) <> 0)Then
 Begin
  MajDirectoire := Registre.AX;
  ErreurFichier := Registre.AX;
 End
  Else
 Begin
  MajDirectoire := Ferme(Registre.AX);
  ErreurFichier := 0;
 End;
End;
