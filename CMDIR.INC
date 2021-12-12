		 (* Manipulations des Repertoires *)

Function SupressionRepertoire(Nom:String64) : Word;
Begin
 Nom := Nom + #0;
 Registre.AH := $3A;
 Registre.DS := Seg(Nom[1]);
 Registre.DX := Ofs(Nom[1]);
 MSDos(Registre);
 SupressionRepertoire := Registre.AX;
End;

Function CreationRepertoire(Nom:String64) : Word;
Begin
 Nom := Nom + #0;
 Registre.AH := $39;
 Registre.DS := Seg(Nom[1]);
 Registre.DX := Ofs(Nom[1]);
 MSDos(Registre);
 If(Registre.Flags and 1<>0)Then CreationRepertoire := Registre.AX
                            Else CreationRepertoire := 0;
End;

Function ChangeRepertoire(Nom:String64) : Word;
Begin
 Nom := Nom + #0;
 Registre.AH := $3B;
 Registre.DS := Seg(Nom[1]);
 Registre.DX := Ofs(Nom[1]);
 MSDos(Registre);
 If(Registre.Flags and 1<>0)Then ChangeRepertoire := Registre.AX
                            Else ChangeRepertoire := 0;
End;


