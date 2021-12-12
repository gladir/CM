Unit Fichier;

(**********************************************************************)
                               Interface
(**********************************************************************)

Const ErreurFichier : Word = 0;

Type Chemin = String[79];

Procedure AjouteEnregistrement(Handle:Integer;RecNum:LongInt;Taille:Word;Var Buffer);
Procedure LitEnregistrement(Handle:Integer;RecNum:LongInt;Taille:Word;Var Buffer);
Procedure ModifieEnregistrement(Handle:Integer;RecNum:LongInt;Taille:Word;Var Buffer);
Procedure Positionne(Handle:Integer;RecNum:LongInt;Taille:Word);

Function Cree(Nom:Chemin):Integer;
Function Efface(Nom:Chemin):Integer;
{$IFDEF VER60}
 Procedure Ferme(Handle:Word);
 Procedure MajDirectoire(Handle:Word);
{$ELSE}
 Function Ferme(Handle:Integer):Integer;
 Function MajDirectoire(Handle:Integer):Integer;
{$ENDIF}
Function Ouvre(Nom:Chemin;Mode:Byte):Integer;
Function TailleFichier(Handle:Integer):LongInt;

(**********************************************************************)
                             Implementation
(**********************************************************************)

Uses DOS;

Var
    Registre : Registers;

Procedure __ReelEnDoubleMot(Reel:LongInt;Var Grand,Petit:Word);
Begin
 Grand := Reel div 65536;
 Petit := Reel - (Grand * 65536);
End;

Function __DoubleMotEnReel(Grand,Petit:Word):LongInt;
Var Temporaire : LongInt;
Begin
 Temporaire := Petit;
 If(Temporaire < 0)Then Inc(Temporaire,65536);
 __DoubleMotEnReel := (Grand * 65536) + Temporaire;
End;

{$IFOPT I+}

 {$I-}

 Procedure Positionne(Handle:Integer;RecNum:LongInt;Taille:Word);
 Var Grand,Petit : Word;
     Position    : LongInt;
 Begin
  Position := RecNum * Taille;
  __ReelEnDoubleMot(Position,Grand,Petit);
  With Registre do
  Begin
   AH := $42;
   AL := $00;
   BX := Handle;
   CX := Grand;
   DX := Petit;
   MsDos(Registre);
   If((Flags and 1) <> 0)Then ErreurFichier := AX
                         Else ErreurFichier := 0;
  End;
 End;

 Function TailleFichier(Handle : Integer) : LongInt;
 Begin
  With Registre do
  Begin
   AH := $42;
   AL := $02;
   BX := Handle;
   CX := $00;
   DX := $00;
   MsDos(Registre);
   If((Flags And 1) <> 0)Then
   Begin
    TailleFichier := -1;
    ErreurFichier := AX;
   End
    Else
   Begin
    TailleFichier := __DoubleMotEnReel(DX,AX);
    ErreurFichier := 0;
   End;
  End;
 End;

{$IFDEF VER60}

 Procedure Ferme(Handle : Word);
 Assembler;
 Label Nor,Fin;
 ASM Push AX;
     Push BX;
     Mov  AX,$3E00;
     Mov  BX,Handle;
     Int  $21;
     JNC  Nor;
     Mov  ErreurFichier,AX;
     JMP  Fin;
 Nor:Mov  ErreurFichier,$00;
 Fin:Pop  BX;
     Pop  AX;
 END;

 Procedure MajDirectoire(Handle : Word);
 Assembler;
 Label Err,NF,Nor,Fin;
 ASM Push AX;
     Push BX;
     Mov  AX,$4500;
     Mov  BX,Handle;
     Int  $21;
     JNC  Nor;
 Err:Mov  ErreurFichier,AX;
     JMP  Fin;
 Nor:Mov  AX,$3E00;
     Int  $21;
     JNC  NF;
     JMP  Err;
 NF :Mov  ErreurFichier,$00;
 Fin:Pop  BX;
     Pop  AX;
 END;

{$ELSE}

 Function Ferme(Handle : Integer);
 Begin
  With Registre do
  Begin
   AX := $3E00;
   BX := Handle;
   MsDos(Registre);
   If((Flags and 1) <> 0)Then
   Begin
    Ferme := AX;
    ErreurFichier := AX;
   End
    Else
   Begin
    Ferme := 0;
    ErreurFichier := 0;
   End;
  End;
 End;

 Function MajDirectoire(Handle:Integer);
 Begin
  With Registre do
  Begin
   AX := $4500;
   BX := Handle;
   MsDos(Registre);
   If((Flags and 1) <> 0)Then
   Begin
    MajDirectoire := AX;
    ErreurFichier := AX;
   End
    Else
   Begin
    MajDirectoire := Ferme(AX);
    ErreurFichier := 0;
   End;
  End;
 End;

{$ENDIF}

 Function Ouvre(Nom : Chemin;Mode:Byte) : Integer;
 Var Temporaire : Chemin;
 Begin
  With Registre do
  Begin
   Temporaire := Nom + #00;
   AH := $3D;
   AL := $40+Mode;
   DS := Seg(Temporaire[1]);
   DX := Ofs(Temporaire[1]);
   MsDos(Registre);
   If((Flags and 1) <> 0)Then
   Begin
    Ouvre := -1;
    ErreurFichier := AX;
   End
    else
   Begin
    Ouvre         := AX;
    ErreurFichier := 0;
   End;
  End;
 End;

 Function Cree(Nom : Chemin) : Integer;
 Var Temporaire : Chemin;
 Begin
  With Registre do
  Begin
   Move(Nom[1],Temporaire,Length(Nom));
   Temporaire:= Nom + #00;
   AH := $3C;
   DS := Seg(Temporaire[1]);
   DX := Ofs(Temporaire[1]);
   CX := $0000;
   MsDos(Registre);
   If((Flags and 1)<>0)Then
   Begin
    Cree := -1;
    ErreurFichier := AX;
   End
    Else
   Begin
    Cree          := AX;
    ErreurFichier := 0;
   End;
  End;
 End;

 Function Efface(Nom:Chemin):Integer;
 Var Temporaire : Chemin;
 Begin
  With Registre do
  Begin
   Temporaire := Nom + #00;
   AX := $4100;
   DS := Seg(Temporaire[1]);
   DX := Ofs(Temporaire[1]);
   MsDos(Registre);
   If((Flags and 1) <> 0)Then
   Begin
    Efface := AX;
    ErreurFichier := AX;
   End
    else
   Begin
    Efface := 0;
    ErreurFichier := 0;
   End;
  End;
 End;

 Procedure LitEnregistrement(Handle:Integer;RecNum:LongInt;Taille:Word;Var Buffer);
 Begin
  With Registre do
  Begin
   Positionne(Handle,RecNum,Taille);
   AX := $3F00;
   BX := Handle;
   CX := Taille;
   DS := Seg(Buffer);
   DX := Ofs(Buffer);
   MsDos(Registre);
   If((Flags and 1) <> 0)Then ErreurFichier := AX
                         Else ErreurFichier := 0;
  End;
 End;

 Procedure ModifieEnregistrement(Handle:Integer;RecNum:LongInt;Taille:Word;Var Buffer);
 Begin
  With Registre do
  Begin
   Positionne(Handle,RecNum,Taille);
   AX := $4000;
   BX := Handle;
   CX := Taille;
   DS := Seg(Buffer);
   DX := Ofs(Buffer);
   MsDos(Registre);
   If((Flags and 1) <> 0)Then ErreurFichier := AX
                         Else ErreurFichier := 0;
  End;
 End;

 Procedure AjouteEnregistrement(Handle:Integer;RecNum:LongInt;Taille:Word;Var Buffer);
 Begin
  RecNum := TailleFichier(Handle) div Taille;
  ModifieEnregistrement(Handle,RecNum,Taille,Buffer);
 End;

 {$I+}

{$ELSE}

 Procedure Positionne(Handle:Integer;RecNum:LongInt;Taille:Word);
 Var Grand,Petit : Word;
     Position    : LongInt;
 Begin
  Position := RecNum * Taille;
  __ReelEnDoubleMot(Position,Grand,Petit);
  With Registre do
  Begin
   AH := $42;
   AL := $00;
   BX := Handle;
   CX := Grand;
   DX := Petit;
   MsDos(Registre);
   If((Flags and 1) <> 0)Then ErreurFichier := AX
                         Else ErreurFichier := 0;
  End;
 End;

 Function TailleFichier(Handle : Integer) : LongInt;
 Begin
  With Registre do
  Begin
   AH := $42;
   AL := $02;
   BX := Handle;
   CX := $00;
   DX := $00;
   MsDos(Registre);
   If((Flags And 1) <> 0)Then
   Begin
    TailleFichier := -1;
    ErreurFichier := AX;
   End
    Else
   Begin
    TailleFichier := __DoubleMotEnReel(DX,AX);
    ErreurFichier := 0;
   End;
  End;
 End;

{$IFDEF VER60}

 Procedure Ferme(Handle : Word);
 Assembler;
 Label Nor,Fin;
 ASM Push AX;
     Push BX;
     Mov  AX,$3E00;
     Mov  BX,Handle;
     Int  $21;
     JNC  Nor;
     Mov  ErreurFichier,AX;
     JMP  Fin;
 Nor:Mov  ErreurFichier,$00;
 Fin:Pop  BX;
     Pop  AX;
 END;

 Procedure MajDirectoire(Handle : Word);
 Assembler;
 Label Err,NF,Nor,Fin;
 ASM Push AX;
     Push BX;
     Mov  AX,$4500;
     Mov  BX,Handle;
     Int  $21;
     JNC  Nor;
 Err:Mov  ErreurFichier,AX;
     JMP  Fin;
 Nor:Mov  AX,$3E00;
     Int  $21;
     JNC  NF;
     JMP  Err;
 NF :Mov  ErreurFichier,$00;
 Fin:Pop  BX;
     Pop  AX;
 END;

{$ELSE}

 Function Ferme(Handle : Integer);
 Begin
  With Registre do
  Begin
   AX := $3E00;
   BX := Handle;
   MsDos(Registre);
   If((Flags and 1) <> 0)Then
   Begin
    Ferme := AX;
    ErreurFichier := AX;
   End
    Else
   Begin
    Ferme := 0;
    ErreurFichier := 0;
   End;
  End;
 End;

 Function MajDirectoire(Handle:Integer);
 Begin
  With Registre do
  Begin
   AX := $4500;
   BX := Handle;
   MsDos(Registre);
   If((Flags and 1) <> 0)Then
   Begin
    MajDirectoire := AX;
    ErreurFichier := AX;
   End
    Else
   Begin
    MajDirectoire := Ferme(AX);
    ErreurFichier := 0;
   End;
  End;
 End;

{$ENDIF}

 Function Ouvre(Nom : Chemin;Mode:Byte) : Integer;
 Var Temporaire : Chemin;
 Begin
  With Registre do
  Begin
   Temporaire := Nom + #00;
   AH := $3D;
   AL := $40+Mode;
   DS := Seg(Temporaire[1]);
   DX := Ofs(Temporaire[1]);
   MsDos(Registre);
   If((Flags and 1) <> 0)Then
   Begin
    Ouvre := -1;
    ErreurFichier := AX;
   End
    else
   Begin
    Ouvre         := AX;
    ErreurFichier := 0;
   End;
  End;
 End;

 Function Cree(Nom : Chemin) : Integer;
 Var Temporaire : Chemin;
 Begin
  With Registre do
  Begin
   Move(Nom[1],Temporaire,Length(Nom));
   Temporaire:= Nom + #00;
   AH := $3C;
   DS := Seg(Temporaire[1]);
   DX := Ofs(Temporaire[1]);
   CX := $0000;
   MsDos(Registre);
   If((Flags and 1)<>0)Then
   Begin
    Cree := -1;
    ErreurFichier := AX;
   End
    Else
   Begin
    Cree          := AX;
    ErreurFichier := 0;
   End;
  End;
 End;

 Function Efface(Nom:Chemin):Integer;
 Var Temporaire : Chemin;
 Begin
  With Registre do
  Begin
   Temporaire := Nom + #00;
   AX := $4100;
   DS := Seg(Temporaire[1]);
   DX := Ofs(Temporaire[1]);
   MsDos(Registre);
   If((Flags and 1) <> 0)Then
   Begin
    Efface := AX;
    ErreurFichier := AX;
   End
    else
   Begin
    Efface := 0;
    ErreurFichier := 0;
   End;
  End;
 End;

 Procedure LitEnregistrement(Handle:Integer;RecNum:LongInt;Taille:Word;Var Buffer);
 Begin
  With Registre do
  Begin
   Positionne(Handle,RecNum,Taille);
   AX := $3F00;
   BX := Handle;
   CX := Taille;
   DS := Seg(Buffer);
   DX := Ofs(Buffer);
   MsDos(Registre);
   If((Flags and 1) <> 0)Then ErreurFichier := AX
                         Else ErreurFichier := 0;
  End;
 End;

 Procedure ModifieEnregistrement(Handle:Integer;RecNum:LongInt;Taille:Word;Var Buffer);
 Begin
  With Registre do
  Begin
   Positionne(Handle,RecNum,Taille);
   AX := $4000;
   BX := Handle;
   CX := Taille;
   DS := Seg(Buffer);
   DX := Ofs(Buffer);
   MsDos(Registre);
   If((Flags and 1) <> 0)Then ErreurFichier := AX
                         Else ErreurFichier := 0;
  End;
 End;

 Procedure AjouteEnregistrement(Handle:Integer;RecNum:LongInt;Taille:Word;Var Buffer);
 Begin
  RecNum := Trunc((TailleFichier(Handle))/Taille);
  ModifieEnregistrement(Handle,RecNum,Taille,Buffer);
 End;

{$ENDIF}

End.