Uses CMEcran;

Procedure EditeFile(Name:String);
Var Tableau : Pointer;
    Fichier : Text;
    Chaine  : String;
Begin
 Assign(Fichier,Name);
 {$I-} Reset(Fichier); {$I+}
 If(IOResult <> 0)Then Exit;
 While Not Eof(Fichier) do
 Begin
  ReadLn(Fichier,Chaine);
  WriteLn(Chaine);
 End;
 Close(Fichier);
End;

Begin
 EditeFile('C:\Langage\QP\Source\Budget3.PAS');
End.
