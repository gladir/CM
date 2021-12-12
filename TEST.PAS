Program TestEquipement;

Uses Dos;

Const HexData : Array[0..15] of Char = '0123456789ABCDEF';

Type String2 = String[2];
     String4 = String[4];
     String8 = String[8];
     Binaire = 0..1;

Var Registre                : Registers;
    Segment,OffSet,Compteur : Word;
    Equipe                  : Word Absolute $0041 : $00;

Function HexB(Nombre : Byte) : String2;
Begin
 HexB := HexData[Nombre shr 4] +
	 HexData[Nombre and 15];
End;

Function HexW(Nombre : Word) : String4;
Begin
 HexW := HexData[(Nombre shr 12)and 15] +
	 HexData[(Nombre shr 8)and 15] +
	 HexData[(Nombre shr 4)and 15] +
	 HexData[Nombre and 15];
End;

Function HexL(Nombre : LongInt) : String8;
Begin
 HexL := HexData[(Nombre shr 28)and 15] +
	 HexData[(Nombre shr 24)and 15] +
	 HexData[(Nombre shr 20)and 15] +
	 HexData[(Nombre shr 16)and 15] +
	 HexData[(Nombre shr 12)and 15] +
	 HexData[(Nombre shr 8)and 15] +
	 HexData[(Nombre shr 4)and 15] +
	 HexData[Nombre and 15];
End;

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
 If((Equipe and 52)in [0,16,32])and(Info=0)Then HardWare := $0E
  else
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

Function NombreManetteJeu : Byte;
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

Function VersionDos : Real;
Begin
 Registre.AH := $30;
 MsDos(Registre);
 VersionDos := 1.0 * Registre.AL + Registre.AH/100;
End;

Begin
 WriteLn;
 WriteLn('Systeme - Information');
 For Compteur := 0 to 79 do Write('-');
 WriteLn;
 Registre.AX := $1500;
 Registre.BX := $0000;
 Intr($2F,Registre);
 Write('            Driver CD-ROM : ');
 If(Registre.BX = $0000)Then WriteLn('Non-Install‚')
			Else WriteLn('Install‚');
 Registre.AX := $4300;
 Intr($2F,Registre);
 Write('Driver Memoire Etendu XMS : ');
 If(Registre.AL = $80)Then WriteLn('Install‚')
		      Else WriteLn('Non-Install‚');
 Write('           Manette de jeu : ');
 Case NombreManetteJeu of
  0 : WriteLn('Non-Install‚');
  1 : WriteLn('Install‚');
 End;
 Registre.AL := $33;
 Registre.AH := $35;
 MsDos(Registre);
 Write('            Driver Souris : ');
 If(Mem[Registre.ES:Registre.BX] = $CF)Then WriteLn('Non-Install‚')
				       Else WriteLn('Install‚');
 Write('              Carte Video : ');
 Case HardWare of
  $00 : WriteLn('Carte video Absent (BW)');
  $0A : WriteLn('Carte PcJunior');
  $0C : WriteLn('Color Graphics Adaptor (CGA)');
  $0E : WriteLn('Enhanced Graphics Adaptor (EGA)');
 End;
 Write('      Mode video initiale : ');
 Case ModeVideo of
  0 : WriteLn('Mode inconnue');
  1 : WriteLn('Couleur 40x25');
  2 : WriteLn('Couleur 80x25');
  3 : WriteLn('Monochrome');
 End;
 Registre.AL := $41;
 Registre.AH := $35;
 MsDos(Registre);
 Segment := Registre.ES;
 OffSet  := Registre.BX;
 WriteLn;
 Write('RAM   : ',TailleRAM:6:0,' Octets (',HexW(0),'h:',HexW(0),'h-');
 WriteLn(Copy(HexL(Trunc(TailleRAM)*4096),1,4),'h:',Copy(HexL(Trunc(TailleRAM)*4096),5,4),'h)');
 Write('Ecran : ');
 Case HardWare of
  $00 : Begin
	 WriteLn(' 32767 Octets (B000h:0000h-B7FFh:0000h)');
	End;
  $0A : Begin
	 WriteLn(' 65536 Octets (B000h:0000h-BFFFh:0000h)');
	End;
  $0C : Begin
	 WriteLn(' 32767 Octets (B800h:0000h-BFFFh:0000h)');
	End;
  $0E : Begin
	 Registre.AH := $12;
	 Registre.BL := $10;
	 Intr($10,Registre);
	 Segment := Registre.BL;
	 Case Segment of
	  0 : WriteLn(' 65536 Octets (A000h:0000h-AFFFh:0000h)');
	  1 : WriteLn('131072 Octets (A000h:0000h-BFFFh:0000h)');
	  2 : WriteLn('196608 Octets (A000h:0000h-C7FFh:0000h)');
	  3 : WriteLn('262144 Octets (A000h:0000h-CFFFh:0000h)');
	 End;
	End;
 End;
 WriteLn('Adresse Extension BIOS-ROM : ',HexW(Segment),'h:',HexW(OffSet),'h');
 If(Port[$60] <> 0)Then
 Begin
  Write(HexB(Port[$60]),' ',HexB(Port[$63]),' ',HexB(Port[$64]),' ',HexB(Port[$67]));
 End;
 WriteLn;
 For Compteur := $200 to $20F do Write(HexB(Port[Compteur]),' ');
End.
