		(* Indique le materiel d'ordinateur *)

Function CoprosseurMathematique : Binaire;
Begin
 CoprosseurMathematique:=(Equipe and $0002)shr 1;
End;

Function HardWare : Byte;
Var SwitchEGA,Info : Byte;
Begin
 Registre.AH := $12;
 Registre.BL := $10;
 Intr($10,Registre);
 Info      := Registre.BH;
 SwitchEGA := Registre.CL;
 If(Mem[$FFFF:$000E]=$FD)Then HardWare := $0A Else
 If((Equipe and 48)in [16,32])or(((Equipe and 52)=4)and(SwitchEGA in[4,5,10,11]))Then HardWare := $0C
  else
 If((Equipe and 52)in [0,16,32])and(Info=0)Then HardWare := $0E Else
 HardWare := $00;
End;

Function Model : Byte;
Begin
 Model:=(Equipe and $2000)shr 13;
End;

Function ModeVideo : Byte;
Begin
 ModeVideo:=(Equipe and $0030)shr 4;
End;

Function NombreDisque : Byte;
Label 10;
Var Original,Position : 0..26;
Begin
 Registre.AH := $19;
 MsDos(Registre);
 Original := Registre.AL;
 Position := 1;
 10 : Registre.AH := $0E;
      Registre.DL := Position;
      MsDos(Registre);
      Registre.AH := $19;
      MsDos(Registre);
      If(Registre.AL = Position)Then
      Begin
       Position := Position+1;
       Goto 10;
      End;
 NombreDisque := Position;
 Registre.AH := $0E;
 Registre.DL := Original;
 MsDos(Registre);
End;

Function NombreDMA : Binaire;
Begin
 NombreDMA:=(Equipe and $0100)shr 8;
End;

Function NombreImprimante : Byte;
Begin
 NombreImprimante := (Equipe and $C000) shr 14;
End;

Function NombreManetteJeu : Binaire;
Begin
 NombreManetteJeu := (Equipe and $1000)shr 12
End;

Function NombreRS232 : Byte;
Begin
 NombreRS232:=(Equipe and $0E00)shr 9;
End;

Function TailleRAM : Real;
Begin
 Intr($12,Registre);
 TailleRAM := Registre.AX*1024.0;
End;

Function MemoireLibre : Real;
Begin
 Registre.AH := $48;
 Registre.BX := $FFFF;
 MsDos(Registre);
 MemoireLibre := Registre.BX * 16.0;
End;

Function TypeDisque(Drive:Byte) : Byte;
Begin
 Registre.AH := $1C;
 Registre.DL := Drive;
 MsDos(Registre);
 If(Registre.AL = $FF)Then TypeDisque := $03
		  Else TypeDisque := Mem[Registre.DS:Registre.BX];
End;

Function Souris : Binaire;
Begin
 InLine($B8/$01/$00/ { MOV AX,0001 }
	$CD/$33);    { INT 33      }
 Registre.AH := $00;
 Intr($33,Registre);
 If Registre.AX = $FFFF Then Souris := 0
		    Else Souris := 1;
 InLine($B8/$02/$00/ { MOV AX,0002 }
	$CD/$33);    { INT 33      }
End;

Function Bouton : Byte;
Begin
 Registre.AH := $00;
 Intr($33,Registre);
 If Registre.AX = 0 Then Bouton := Registre.BX
		Else Bouton := 0;
End;


