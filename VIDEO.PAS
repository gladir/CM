Uses Dos;

Const HexString : Array[0..15] of Char = '0123456789ABCDEF';

Type String2 = String[2];

Var Registre : Registers;

Function Hex2(Byt:Byte) : String2;
Begin
 Hex2 := HexString[Byt shr 4] + HexString[Byt and 15];
End;

Procedure ParametreVideo;
Var Segment,OffSet      : Word;
    Compteur            : Byte;
Begin
 Registre.AH := $35;
 Registre.AL := $1D;
 MsDos(Registre);
 Segment := Registre.ES;
 OffSet  := Registre.BX;
 WriteLn('OffSet 40x25 80x25 Graphique Monochrome Caracteristique');
 WriteLn('------ ----- ----- --------- ---------- ------------------------------');
 WriteLn;
 For Compteur := $00 to $0B do
 Begin
 Write('  ',Hex2(Compteur),'h   ',
       Hex2(Mem[Segment:OffSet+Compteur]),'h   ',
       Hex2(Mem[Segment+$01:OffSet+Compteur]),'h       ',
       Hex2(Mem[Segment+$02:OffSet+Compteur]),'h        ',
       Hex2(Mem[Segment+$03:OffSet+Compteur]),'h  ');
 Case Compteur of
  $00 : Write('Nombre de colonnes affichables');
  $01 : Write('Nombre de colonnes affich‚es');
  $02 : Write('Nombre de caractere entre SSH');
  $03 : Write('Duree du signal');
  $04 : Write('Nombre de lignes affichables');
  $05 : Write('Nombre de ligne ajuste');
  $06 : Write('Nombre de lignes affich‚es');
  $07 : Write('Nombre de caractere entre SSV');
  $08 : Write('Mode d''entrelacement');
  $09 : Write('Nombre de pixels par ligne');
  $0A : Write('Ligne de depart du curseur');
  $0B : Write('Ligne de fin du curseur');
 End;
 WriteLn;
 End;
 WriteLn('$C-$Dh ',Hex2(Mem[Segment:OffSet+$0C]),Hex2(Mem[Segment:OffSet+$0D]),'h ',
	         Hex2(Mem[Segment+$01:OffSet+$0C]),Hex2(Mem[Segment+$01:OffSet+$0D]),'h    ',
	         Hex2(Mem[Segment+$02:OffSet+$0C]),Hex2(Mem[Segment+$02:OffSet+$0D]),'h      ',
	         Hex2(Mem[Segment+$03:OffSet+$0C]),Hex2(Mem[Segment+$03:OffSet+$0D]),
	         'h  Adresse de la page affich‚e');
 WriteLn('$E-$Fh ',Hex2(Mem[Segment:OffSet+$0E]),Hex2(Mem[Segment:OffSet+$0F]),'h ',
	         Hex2(Mem[Segment+$01:OffSet+$0E]),Hex2(Mem[Segment+$01:OffSet+$0F]),'h    ',
	         Hex2(Mem[Segment+$02:OffSet+$0E]),Hex2(Mem[Segment+$02:OffSet+$0F]),'h      ',
	         Hex2(Mem[Segment+$03:OffSet+$0E]),Hex2(Mem[Segment+$03:OffSet+$0F]),
	         'h  Adresse du curseur');
 WriteLn;
 WriteLn('------ ----- ----- --------- ---------- ------------------------------');
End;

Begin
 InLine($B8/$03/$00/$CD/$10);
 ParametreVideo;
End.
