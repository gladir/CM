Program Editeur;

{$M 16384,0,655360 }

Uses Crt,DOS;

Const UpDn     : Byte = 0;
      Attribut : Byte = 31;

Type KeyQuestionType = Array[0..25] of Record
					Alt    : String[31];
					Ctrl   : String[31];
					Action : Byte; { Ctrl seulement }
				       End;

Var Adresse : Word;
    YPos    : Word;
    Colonne : Word Absolute $0040:$4A;

Function AdresseEcran:Word;
Begin
 If(MemW[$0040:$63] = $3B4)Then AdresseEcran := $B000
			   Else AdresseEcran := $B800;
End;

Procedure Ecrit1C(X,Y,Caractere:Byte);
Begin
 MemW[Adresse:(X+Y*Colonne)*2] := Caractere + Attribut * 256;
End;

Procedure Ecrit(X,Y:Byte;Chaine:String);
Var Compteur : Byte;
Begin
 If(Chaine <> '')Then
 Begin
  For Compteur := 0 to Length(Chaine)-1 do
  Begin
   Ecrit1C(X+Compteur,Y,Ord(Chaine[Compteur+1]));
  End;
 End;
End;

Procedure Localise(X,Y:Byte);
Var Registre : Registers;
Begin
 With Registre do
 Begin
  AH := $02;
  BH := $00;
  DL := X;
  DH := Y;
  Intr($10,Registre);
 End;
End;

Procedure Question(X,Y:Byte;Var Chaine:String;
		   Longeur,Attribut:Byte;Key:KeyQuestionType;
		   UpDown:Boolean;Var Escape:Byte);
 { Retourne 0 dans Escape s'il y a terminaison par <ENTER>,
   retourne 1 dans Escape s'il y a terminaison par <ESC>,
   retourne 2 dans Escape s'il y a terminaison par <UP>,
   retourne 3 dans Escape s'il y a terminaison par <DOWN>,
   retourne 254 dans Escape s'il y a un erreur de donn‚ ou
   retourne 255 dans Escape s'il y a terminaison annormale. }
Var Phrase   : String;
    Temp     : String;
    XPos     : Byte;
    LonPhr   : Byte;
    SegPhr   : Word;
    OfsPhr   : Word;
    Compteur : Byte;
    ToucheBy : Byte;
    Touche   : Char;
    OK       : Boolean;
    Registre : Registers;
    Colonne  : Byte;
    Quitter  : Boolean;

 { Ecrit un seul caractŠre }

 Procedure ClaireBoard;
 Var Compteur : Byte;
 Begin
  For Compteur := 0 to Longeur-1 do
  Begin
   Ecrit1C(X+Compteur,Y,$20);
  End;
 End;

 Procedure AutoInsert;
 Var Registre : Registers;
 Begin
  With Registre do
  Begin
   AH := $02;
   Intr($16,Registre);
   If((AL and $80)<>0)Then { Insert On ? }
   Begin
    AH := $01;
    If(Adresse = $B800)Then
    Begin
     CH := 4;
     CL := 7;
    End
     else
    Begin
     CH := 6;
     CL := 12;
    End;
   End
    else
   Begin
    AH := $01;
    If(Adresse = $B800)Then
    Begin
     CH := 6;
     CL := 7;
    End
     else
    Begin
     CH := 11;
     CL := 12;
    End;
   End;
   Intr($10,Registre);
  End;
 End;

 { Initiation }

 Procedure Init;
 Var Compteur : Byte;
     Carac    : Char;
 Begin
  ClaireBoard;
  Phrase := '';
  If(Chaine <> '')Then
  Begin
   For Compteur := 0 to Length(Chaine)-1 do
   Begin
    Carac := Chaine[Compteur+1];
    If(Carac > #32)Then Phrase := Phrase + Carac;
   End;
  End;
  If(Phrase <> '')Then
  Begin
   Ecrit(X,Y,Phrase);
   LonPhr := Length(Phrase);
   XPos   := LonPhr;
  End
   else
  Begin
   LonPhr := 0;
   XPos   := 0;
  End;
 End;

 { Insertion d'un mots dans la phrase }

 Procedure Insertion(Mots:Char);
 Var Chaine : String;
     LonChr : Byte;
 Begin
  If(Mots<#32)Then Chaine := Key[Ord(Mots)].Ctrl
	      Else Chaine := Key[Ord(Mots)-65].Alt;
  LonChr := Length(Chaine);
  If((Chaine <> '')and(LonChr<Longeur))Then
  Begin
   If(Longeur > LonPhr + LonChr)Then
   Begin
    With Registre do
    Begin
     AH := $02;
     Intr($16,Registre);
     If((AL and $80)<>0)Then { Insert On ? }
     Begin
      If(XPos < LonPhr)Then
      Begin
       Move(Phrase[XPos],Phrase[XPos+LonChr],LonPhr-XPos+1);
       Move(Chaine[1],Phrase[XPos+1],LonChr);
       Mem[SegPhr:OfsPhr] := LonPhr + 1;
      End
       else
      Begin
       Move(Chaine[1],Phrase[XPos+1],LonChr);
       Mem[SegPhr:OfsPhr] := LonPhr + LonChr;
      End;
      Ecrit(X,Y,Phrase);
      Inc(XPos,LonChr);
     End
      else
     Begin
      Move(Chaine[1],Phrase[XPos+1],LonChr);
      If(XPos + LonChr > LonPhr)Then
      Begin
       Mem[SegPhr:OfsPhr] := XPos + LonChr;
      End;
      Ecrit(X,Y,Phrase);
      Inc(XPos,LonChr);
     End;
     LonPhr := Length(Phrase);
    End;
   End
    else
   Write(^G);
  End
   else
  Write(^G);
 End;

 Procedure Delete1;
 Begin
  Delete(Phrase,XPos+1,1);
  Dec(LonPhr);
 End;

 { Commande d'‚dition }

 Procedure CtrlLeftKey;
 Begin
  Ok       := False;
  Compteur := XPos;
  Repeat
   Dec(Compteur);
   ToucheBy := Ord(Phrase[Compteur]);
   If(ToucheBy < 42)or(ToucheBy in [91,93])Then
   Begin
    XPos := Compteur;
    Ok   := True;
   End
    else
   If(Compteur < 1)Then
   Begin
    XPos := 0;
    OK   := True;
   End;
  Until Ok;
 End;

 Procedure CtrlRightKey;
 Begin
  Ok       := False;
  Compteur := XPos;
  Repeat
   Inc(Compteur);
   ToucheBy := Ord(Phrase[Compteur]);
   If(ToucheBy < 42)or(ToucheBy in [91,93])Then
   Begin
    XPos := Compteur;
    Ok   := True;
   End
    else
   If(Compteur > LonPhr)Then
   Begin
    XPos := LonPhr;
    OK   := True;
   End;
  Until Ok;
 End;

 Procedure DeleteLineKey;
 Begin
  ClaireBoard;
  Phrase := '';
  LonPhr := 0;
  XPos   := 0;
 End;

 Procedure BackSpaceKey;
 Begin
  If(LonPhr > 1)Then
  Begin
   Delete(Phrase,XPos,1);
   Dec(XPos);
   Ecrit(X+XPos,Y,Copy(Phrase,XPos+1,255) + ' ');
   LonPhr := Length(Phrase);
  End
   else
  If(LonPhr = 1)Then DeleteLineKey
		Else Write(^G);
 End;

 Procedure DeleteKey;
 Begin
  If(LonPhr > 1)Then
  Begin
   Delete(Phrase,XPos+1,1);
   Ecrit(X+XPos,Y,Copy(Phrase,XPos+1,255) + ' ');
   LonPhr := Length(Phrase);
  End
   else
  If(LonPhr = 1)Then DeleteLineKey
		Else Write(^G);
 End;

 Procedure DeleteEOLKey;
 Var Compteur : Byte;
 Begin
  Delete(Phrase,XPos,255);
  For Compteur := XPos to LonPhr do
  Begin
   Ecrit1C(X+Compteur,Y,32);
  End;
  LonPhr := Length(Phrase);
 End;

 Procedure DeleteMotsKey;
 Begin
  If(XPos+1<LonPhr)Then
  Begin
   Ok := False;
   ToucheBy := LonPhr;
   Repeat
    If(Phrase[XPos+1] in [#32,#65..#90,#97..#122])and(XPos+1<LonPhr)Then Delete1
     Else Ok := True;
    If(XPos>=LonPhr)Then Ok := True;
   Until Ok;
   If(LonPhr = 1)Then DeleteLineKey
    else
   If(LonPhr = XPos + 1)Then
   Begin
    Phrase := Copy(Phrase,1,XPos);
    Dec(LonPhr);
   End;
   If(ToucheBy = LonPhr)Then Delete1;
  End;
  ClaireBoard;
  Ecrit(X,Y,Phrase);
 End;

 Procedure LeftKey;
 Begin
  If(XPos > 0)Then Dec(XPos)
	      Else Write(^G);
 End;

 Procedure RightKey;
 Begin
  If(XPos < LonPhr)Then Inc(XPos)
		   Else Write(^G);
 End;

 { Insertion d'un caractŠre dans un phrase }

 Procedure EntreCar;
 Begin
  If(Longeur > LonPhr)Then
  Begin
   With Registre do
   Begin
    AH := $02;
    Intr($16,Registre);
    If((AL and $80)<>0)Then { Insert On ? }
    Begin
     If(XPos < LonPhr)Then
     Begin
      Move(Phrase[XPos],Phrase[XPos+1],LonPhr-XPos+1);
      Mem[Seg(Phrase[XPos+1]):Ofs(Phrase[XPos+1])] := Ord(Touche);
      Mem[SegPhr:OfsPhr] := LonPhr + 1;
      Ecrit(X,Y,Phrase);
     End
      else
     Begin
      Mem[Seg(Phrase[XPos+1]):Ofs(Phrase[XPos+1])] := Ord(Touche);
      Mem[SegPhr:OfsPhr] := LonPhr + 1;
     End;
     Ecrit1C(X+XPos,Y,Ord(Touche));
     Inc(XPos);
     LonPhr := Length(Phrase);
    End
     else
    Begin
     Mem[Seg(Phrase[XPos+1]):Ofs(Phrase[XPos+1])] := Ord(Touche);
     If(XPos >= LonPhr)Then
     Begin
      Mem[SegPhr:OfsPhr] := LonPhr + 1;
     End;
     Ecrit1C(X+XPos,Y,Ord(Touche));
     Inc(XPos);
     LonPhr := Length(Phrase);
    End;
   End;
  End
   else
  Write(^G);
 End;

 { Traite le(s) Scan(s) Code(s) }

 Procedure TraiteScanCode;
 Begin
  Touche := ReadKey;
  Case Touche of
 {Alt-Q} #16 : Insertion('Q');
 {Alt-W} #17 : Insertion('W');
 {Alt-E} #18 : Insertion('E');
 {Alt-R} #19 : Insertion('R');
 {Alt-T} #20 : Insertion('T');
 {Alt-Y} #21 : Insertion('Y');
 {Alt-U} #22 : Insertion('U');
 {Alt-I} #23 : Insertion('I');
 {Alt-O} #24 : Insertion('O');
 {Alt-P} #25 : Insertion('P');
 {Alt-A} #30 : Insertion('A');
 {Alt-S} #31 : Insertion('S');
 {Alt-D} #32 : Insertion('D');
 {Alt-F} #33 : Insertion('F');
 {Alt-G} #34 : Insertion('G');
 {Alt-H} #35 : Insertion('H');
 {Alt-J} #36 : Insertion('J');
 {Alt-K} #37 : Insertion('K');
 {Alt-L} #38 : Insertion('L');
 {Alt-Z} #44 : Insertion('Z');
 {Alt-X} #45 : Insertion('X');
 {Alt-C} #46 : Insertion('C');
 {Alt-V} #47 : Insertion('V');
 {Alt-B} #48 : Insertion('B');
 {Alt-N} #49 : Insertion('N');
 {Alt-M} #50 : Insertion('M');
	 #71 : XPos := 0;
     #72,#80 : Begin
		If(UpDown)Then
		Begin
		 If(Touche = #72)Then Escape := 2
				 Else Escape := 3;
		 Chaine  := Phrase;
		 Touche  := #27;
		 Quitter := True;
		 Exit;
		End
		 else
		Begin
		 Insertion(Chr(UpDn+65));
		 If(Touche=#80)Then
		 Begin
		  If(UpDn < 25)Then Inc(UpDn)
			       Else UpDn := 0;
		 End
		  else
		 Begin
		  If(UpDn > 0)Then Dec(UpDn)
			      Else UpDn := 25;
		 End;
		End;
	       End;
	 #75 : LeftKey;
	 #77 : RightKey;
	 #79 : XPos := LonPhr;
	 #82 : AutoInsert;
	 #83 : DeleteKey;
	#115 : CtrlLeftKey;
	#116 : CtrlRightKey;
    else
   Write(^G);
  End;
  Touche := #00;
 End;

Begin { Main Question }
 Quitter := False;
 Escape  := 255;
 With Registre do
 Begin
  AH := Mem[$40:$4A];
  If(AH>0)Then Colonne := AH
	  Else Colonne := 80;
 End;
 SegPhr := Seg(Phrase[0]);
 OfsPhr := Ofs(Phrase[0]);
 If(Attribut = 0)Then Attribut := 7;
 If(Adresse < $B000)Then Adresse := $B800;
 Init;
 AutoInsert;
 Repeat
  Str(XPos:3,Temp);
  Ecrit(10,0,Temp);
  Str(YPos:5,Temp);
  Ecrit(20,0,Temp);
  Localise(X+XPos,Y);
  Touche := ReadKey;
  If(KeyPressed)Then TraiteScanCode
   else
  Begin
   ToucheBy := Ord(Touche);
   If(ToucheBy < 25)and(Not(ToucheBy in [8,13,17,20]))and
     (Key[ToucheBy].Action <> 0)and(Mem[$0040:$17] and 4=0)Then
   Begin
    Case Key[ToucheBy].Action of
      0 : Write(^G);
      1 : Insertion(Touche);
      2 : DeleteKey;
      3 : DeleteEOLKey;
      4 : DeleteLineKey;
      5 : DeleteMotsKey;
      6 : BackSpaceKey;
      7 : CtrlLeftKey;
      8 : CtrlRightKey;
      9 : LeftKey;
     10 : RightKey;
     11 : XPos := 0;
     12 : XPos := LonPhr;
     13 : Begin
	   Insertion(Touche);
	   Chaine := Phrase;
	   Escape := 0;
	   Exit;
	  End;
     14 : Init;
      else
     Begin
      Write(^G);
      Escape := 254;
      Exit;
     End;
    End;
   End
    else
   Case Touche of
	   #8 : BackSpaceKey;
	   ^Q : Begin
		 Touche := ReadKey;
		 If(KeyPressed)Then TraiteScanCode
		  else
		 Case Touche of
		  ^B : XPos := 0;
		  ^K : XPos := LonPhr;
		  ^L : Init;
		  ^Y : DeleteEOLKey;
	   #32..#255 : EntreCar;
		   else
		  Write(^G);
		 End;
		 Touche := #0;
		End;
	   ^T : DeleteMotsKey;
	   ^Y : DeleteLineKey;
      #13,#27 : Begin End;
    #32..#255 : EntreCar;
     else
    Write(^G);
   End;
  End;
 Until (Touche in [#13,#27]);
 If(Touche = #13)Then
 Begin
  Chaine := Phrase;
  Escape := 0;
 End
  else
 If(Quitter = False)Then Escape := 1;
End;

Procedure Edite;
Const Nouveau : Byte = 0;
Var Data    : Pointer;
    Phrase  : String;
    Longeur : Byte;
    Escape  : Byte;
    UpDown  : Boolean;
    Key     : KeyQuestionType;
    TailleData : LongInt;
    TempPtr : Pointer;
    Segment : Word;
    OffSet  : Word;
    Compteur : Byte;

 Function AgranditData : Byte;
 Begin
  If(MaxAvail > TailleData + 4)Then
  Begin
   AgranditData := 0;
   GetMem(TempPtr,TailleData);
   Move(Data^,TempPtr^,TailleData);
   FreeMem(Data,TailleData);
   Inc(TailleData,4);
   GetMem(Data,TailleData);
   Move(TempPtr^,Data^,TailleData);
   FreeMem(Data,TailleData-4);
   MemW[Seg(Data^):Ofs(Data^)+TailleData-2] := 0; { Segment }
   MemW[Seg(Data^):Ofs(Data^)+TailleData-4] := 0; { OffSet  }
  End
   else
  AgranditData := 255
 End;

 Procedure FixeData(Phrase:String;Position:Word);
 Var Segment : Word;
     OffSet  : Word;
 Begin
  Segment := Seg(Data^);
  OffSet  := Ofs(Data^);
  If(Phrase <> '')Then
  Begin
   TempPtr := Ptr(MemW[Segment:OffSet+Position*4+2],
		  MemW[Segment:OffSet+Position*4]);
   If(TempPtr <> Ptr(0,0))Then
   Begin
    FreeMem(TempPtr,Mem[Segment:OffSet+Position*4]+1);
   End;
   TempPtr := Ptr(0,0);
   GetMem(TempPtr,Ord(Phrase[0])+1);
   GotoXY(70,1);Write(Seg(TempPtr^),':',Ofs(TempPtr^));
   Move(Phrase[0],TempPtr^,Ord(Phrase[0])+1);
   MemW[Segment:OffSet+Position * 4] := Ofs(TempPtr^);
   MemW[Segment:OffSet+Position * 4+2] := Seg(TempPtr^);
  End
   else
  Begin
   MemW[Segment:OffSet+Position * 4+2] := 0; { Segment }
   MemW[Segment:OffSet+Position * 4] := 0;   { OffSet }
  End;
 End;

 Function InsertionData(Phrase:String;Position:Word):Byte;
 Var Segment : Word;
     OffSet  : Word;
     TempPtr : Pointer;
 Begin
  If(MaxAvail > Ord(Phrase[0])+1)Then
  Begin
   InsertionData := 0;
   Segment := Seg(Data^);
   OffSet  := Ofs(Data^);
   Move(Mem[Segment:OffSet+Position * 4],     { Source }
	Mem[Segment:OffSet+(Position+1) * 4], { Target }
	TailleData - Position * 4);
   MemW[Segment:OffSet+Position * 4] := 0;     { OffSet  }
   MemW[Segment:OffSet+Position * 4 + 2] := 0; { Segment }
   FixeData(Phrase,Position);
  End
   else
  InsertionData := 255;
 End;

 Function PhraseLigne(YPos:Word) : String;
 Var Phrase  : String;
     Segment : Word;
     OffSet  : Word;
 Begin
  Phrase := '';
  If(TailleData div 4 >= YPos)Then
  Begin
   Segment := MemW[Seg(Data^):Ofs(Data^)+YPos * 4+2];
   OffSet  := MemW[Seg(Data^):Ofs(Data^)+YPos * 4];
   If(Mem[Segment:OffSet] <> 0)and(Segment <> 0)Then For Compteur := 1 to Mem[Segment:OffSet] do
   Begin
    Phrase := Phrase + Chr(Mem[Segment:OffSet+Compteur]);
   End;
  End;
  PhraseLigne := Phrase;
 End;

 {$F+}
 Function HeapErreur(Erreur:Word):Integer;
 {$F-}
 Begin
  HeapErreur := 1;
 End;

Begin
 HeapError := Addr(HeapErreur);
 YPos    := 0;
 Longeur := 80;
 TailleData := 0;
 GetMem(Data,2);
 MemW[Seg(Data^):Ofs(Data^)] := 0;
 MemW[Seg(Data^):Ofs(Data^)+2] := 0;
 Repeat
  Phrase := PhraseLigne(YPos);
  Question(0,YPos+1,Phrase,Longeur,31,Key,UpDown,Escape);
  If(Escape = 0)Then
  Begin
   If(AgranditData = 255)Then Write(^G)
    else
   Begin
    If(InsertionData(Phrase,YPos)=0)Then Inc(YPos)
				    Else Write(^G);
   End;
  End
   else
  If(Escape = 3)Then
  Begin
   FixeData(Phrase,YPos);
   If(TailleData div 4 > YPos)Then Inc(YPos)
			      Else Write(^G);
  End
   else
  If(Escape=2)Then
  Begin
   FixeData(Phrase,YPos);
   If(YPos > 0)Then Dec(YPos)
	       Else Write(^G);
  End;
 Until (Escape = 1);
End;

BEGIN
 Adresse := AdresseEcran;
 Edite;
END.
