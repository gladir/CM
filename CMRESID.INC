
Var CodeClavier : Byte;
    AncienCode1 : Byte;
    AncienCode2 : Byte;
    AncienCode3 : Byte;

Procedure Interruption09;
Interrupt;
Begin
 InLine($FA);
 CodeClavier := Port[$60];
{ WriteLn(CodeClavier);}
 If(CodeClavier = 197)and(AncienCode1 = 157)Then WriteLn('Pause');
 InLine($FB/
	$CD/$66);
 AncienCode3 := AncienCode2;
 AncienCode2 := AncienCode1;
 AncienCode1 := CodeClavier;
End;

Procedure AdaptationClavier;
Var Segment : Word;
    OffSet  : Word;
Begin
 Registre.AH := $35;
 Registre.AL := $09;
 MsDos(Registre);
 Segment := Registre.ES;
 OffSet  := Registre.BX;
 InLine($FA);
 Registre.AH := $25;
 Registre.AL := $66;
 Registre.DS := Segment;
 Registre.DX := OffSet;
 MsDos(Registre);
 Registre.AH := $25;
 Registre.AL := $09;
 Registre.DS := Seg(Interruption09);
 Registre.DX := Ofs(Interruption09);
 MsDos(Registre);
 InLine($FB);
End;
