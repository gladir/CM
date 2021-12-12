Procedure LectureDirecteDisque(NombreSecteurLire,NumeroSecteur,NumeroCylindre,NumeroTete,NumeroDisque:Byte;Var Buffer);
Begin
 Registre.AL := NombreSecteurLire;
 Registre.AH := $02;
 Registre.BX := Ofs(Buffer);
 Registre.CL := NumeroSecteur;
 Registre.CH := NumeroCylindre;
 Registre.DL := NumeroDisque;
 Registre.DH := NumeroTete;
 Registre.ES := Seg(Buffer);
 Intr($13,Registre);
End;

Procedure Int25(Drive:Byte;LSN,Secteur:Integer;Var Buffer;Var Erreur:Integer);
 InLine($55/         { Push BP         }
	$1E/         { Push DS         }
	$8A/$46/$10/ { Mov AL,[BP+10h] }
	$8B/$56/$0E/ { Mov DX,[BP+0Eh] }
	$8B/$4E/$0C/ { Mov CX,[BP+0Ch] }
        $C5/$5E/$08/ { Mov BX,[BP+08h] }
	$CD/$25/     { Int 25h         }
	$72/$02/     { JB Suite        }
	$31/$C0/     { Xor AX,AX       }
	$9D/         { Suite : POPF    }
	$1F/         { Pop DS          }
	$5D/         { Pop BP          }
	$C4/$7E/$04/ { Les DI,[BP+04h] }
	$26/         { ES:             }
	$89/$05);    { Mov [DI],AX     }

Procedure BootSector;
Const Root          : Boolean = True;
      NoRoot 	    : Boolean = False;
      TailleSecteur : Word    = 512;
Var Buffer          : Array[0..29] of Byte;
    Disque          : Byte;
    Erreur          : Integer;
    TableauSecteur  : Pointer;
    Tableau         : Pointer;
    Chaine          : String[10];
    ErreurData      : Byte;
Begin
 ErreurData := SauvegardeData(Tableau);
 If(ErreurData=0)Then
 Begin
  Erreur := 0;
  GetMem(TableauSecteur,TailleSecteur);
  Int25(Ord(PathTem[1])-64,0,1,TableauSecteur^,Erreur);
  FreeMem(TableauSecteur,TailleSecteur);
  Move(TableauSecteur^,Buffer,30);
  If(Erreur <> 0)Then
  Begin
   CadrePlain(10,10,70,14,79);
   CentreEcriture(12,'Erreur de lecture sur le BOOT Sector',78);
   Write(^G);
  End
   else
  Begin
   CadrePlain(10,0,70,24,47);
   CentreEcriture(3,'Boot Sector',46);
   Str(Buffer[12] * 256 + Buffer[11],Chaine);
   Ecrit(15,5,'Nombre d''octet par secteur  :'+Chaine,43);
   Str(Buffer[13],Chaine);
   Ecrit(15,6,'Nombre de secteur cluster   :'+Chaine,43);
   Str(Buffer[15] * 256 + Buffer[14],Chaine);
   Ecrit(15,7,'Nombre de secteur reserves  :'+Chaine,43);
   Str(Buffer[16],Chaine);
   Ecrit(15,8,'Nombre de FATs              :'+Chaine,43);
   Str(Buffer[18] * 256 + Buffer[17],Chaine);
   Ecrit(15,9,'Nombre d''entree dans le "\" :'+Chaine,43);
   Str(Buffer[20] * 256 + Buffer[19],Chaine);
   Ecrit(15,10,'Nombre total de secteurs    :'+Chaine,43);
   Str(Buffer[23] * 256 + Buffer[22],Chaine);
   Ecrit(15,11,'Nombre de secteur par FAT   :'+Chaine,43);
   Str(Buffer[25] * 256 + Buffer[24],Chaine);
   Ecrit(15,12,'Nombre de secteur par piste :'+Chaine,43);
   Str(Buffer[27] * 256 + Buffer[26],Chaine);
   Ecrit(15,13,'Nombre de tetes (faces)     :'+Chaine,43);
   Str(Buffer[15] * 256 + Buffer[14],Chaine);
   Ecrit(15,14,'Premier secteur de la FAT   :'+Chaine,43);
   Str(Buffer[15] * 256 + Buffer[14] + (Buffer[16] *
      (Buffer[23] * 256 + Buffer[22])),Chaine);
   Ecrit(15,15,'Premier secteur de "\"      :'+Chaine,43);
   If((Buffer[18] = 0)and(Buffer[17] = 0))or
     ((Buffer[12] = 0)and(Buffer[11] = 0))Then Chaine := 'Erreur'
    else
   Begin
    Str(((Buffer[18] * 256 + Buffer[17]) * 32) div
         (Buffer[12] * 256 + Buffer[11]),Chaine);
   End;
   Ecrit(15,16,'Nombre de secteur de "\"    :'+Chaine,43);
  End;
  Touche := ReadKey;
  If(KeyPressed)Then Touche := ReadKey;
  RestorationData(Tableau);
 End
  else
 Write(^G);
End;

Procedure AideDisque;
Var Tableau : Pointer;
    Handle  : Integer;
    Erreur  : Byte;
Begin
 Erreur := SauvegardeData(Tableau);
 If(Erreur=0)Then
 Begin
  Handle := Ouvre('CM.HLP',0);
  If(Handle = -1)Then
  Begin
   CadrePlain(10,9,70,15,$4F);
   CentreEcriture(12,'Impossible d''obtenir de l''aide ...',$4E);
   Write(^G);
  End
   else
  Begin
   LitEnregistrement(Handle,0,4000,Mem[$B800:$00]);
   Handle := Ferme(Handle);
  End;
  Touche := ReadKey;
  If KeyPressed Then Touche := ReadKey;
  RestorationData(Tableau);
 End
  else
 Write(^G);
End;

Procedure ParamDisque;
Var Tableau : Pointer;
    Erreur  : Byte;
    Chaine  : String;
Begin
 Erreur := SauvegardeData(Tableau);
 If(Erreur=0)Then
 Begin
  CadrePlain(10,5,70,24,47);
  CentreEcriture(8,'ParamŠtre du Disque',46);
  With Registre do
  Begin
   AH := $35;
   AL := $1E;
   MsDos(Registre);
   Segment := ES;
   OffSet  := BX;
  End;
  Str(Mem[Segment:OffSet] shr 4,Chaine);
  Ecrit(15,10,'Temps piste a l''autre          : '+Chaine,43);
  Str(Mem[Segment:OffSet] and 15,Chaine);
  Ecrit(15,11,'Tˆte de levee                  : '+Chaine,43);
  If(Mem[Segment:OffSet+1] and 15=0)Then Chaine := 'Baisser'
                                    Else Chaine := 'Lever';
  Ecrit(15,12,'Tete lecture/criture          : '+Chaine,43);
  Str(Mem[Segment:OffSet+2],Chaine);
  Ecrit(15,13,'Temps d''allumage               : '+Chaine,43);
  Case Mem[Segment:OffSet+3] of
   0 : Chaine := '128';
   1 : Chaine := '256';
   2 : Chaine := '512';
   3 : Chaine := '1024';
   4 : Chaine := '2048';
   5 : Chaine := '4096';
   6 : Chaine := '8192';
   7 : Chaine := '16384';
   8 : Chaine := '65536';
    else
   Chaine := 'Erreur de Taille';
  End;
  Ecrit(15,14,'Nombre octet par secteur       : '+Chaine,43);
  Str(Mem[Segment:OffSet+4],Chaine);
  Ecrit(15,15,'Numero du dernier secteur      : '+Chaine,43);
  Ecrit(15,16,'Espace entre secteur (gap)     : '+Hex2(Mem[Segment:OffSet+5])+'h',43);
  If(Mem[Segment:OffSet+6] = $FF)Then Chaine := 'Inconnue'
   else
  Str(Mem[Segment:OffSet+6],Chaine);
  Ecrit(15,17,'Longeur donnee                 : '+Chaine,43);
  Str(Mem[Segment:OffSet+7],Chaine);
  Ecrit(15,18,'Espace entre secteur (formate) : '+Chaine,43);
  Ecrit(15,19,'Valeur d''un secteur inutilis‚  : '+Hex2(Mem[Segment:OffSet+8])+'h',43);
  Str(Mem[Segment:OffSet+9],Chaine);
  Ecrit(15,20,'Temps de stabilisation de tete : '+Chaine,43);
  Str(Mem[Segment:OffSet+$0A],Chaine);
  Ecrit(15,21,'Temps de d‚marrage du moteur   : '+Chaine,43);
  Touche := ReadKey;
  If(KeyPressed)Then Touche := ReadKey;
  RestorationData(Tableau);
 End
  else
 Write(^G);
End;

Procedure RegardeDisque;
Var Tableau3       : Array[0..1024] of Byte;
    NombreSecteur  : Byte;
    NombreTete     : Byte;
    NombreCylindre : Word;
    NumeroDisque   : Byte;
    NumeroSecteur  : Byte;
    NumeroCylindre : Byte;
    NumeroTete     : Byte;
    Segment        : Word;
    OffSet         : Word;
    Tableau        : Pointer;
    Chaine	   : String;
    Erreur         : Byte;
Begin
 Erreur := SauvegardeData(Tableau);
 If(Erreur=0)Then
 Begin
  Longeur := DiskSize(Ord(PathTem[1])-64)-1;
  ClaireLigne(24,0,7);
  Position := 1;
  BoiteCaractere(0,1,79,23,31);
  CadreVide(0,1,79,4,31);
  CadreVide(0,5,79,25,31);
  ClaireLigne(0,219,15);
  MemW[$B800:3840] := $0731;
  Ecrit(1,24,'Aide  ',48);EcritUnCaractere(7,24,$32,7);
  Ecrit(9,24,'Texte ',48);EcritUnCaractere(15,24,$33,7);
  Ecrit(17,24,'Hex   ',48);EcritUnCaractere(23,24,$34,7);
  Ecrit(25,24,'      ',48);EcritUnCaractere(31,24,$35,7);
  Ecrit(33,24,'      ',48);EcritUnCaractere(39,24,$36,7);
  Ecrit(41,24,'      ',48);EcritUnCaractere(47,24,$37,7);
  Ecrit(49,24,'      ',48);EcritUnCaractere(55,24,$38,7);
  Ecrit(57,24,'Boot  ',48);EcritUnCaractere(63,24,$39,7);
  Ecrit(65,24,'Param.',48);Ecrit(71,24,'10',7);
  Ecrit(73,24,'Quitter',48);
  Ecrit(0,0,' Regarde Sylvain Maltais (CM) ',$4F);
  Ecrit(2,2,'Explore :',31);
  TextBackGround(1);
  TextColor(11);
  Localise(12,2);
  Write('Disque');
  Ecrit(2,3,'Secteur Relative :',31);
  Ecrit(21,3,ChaineZero(10),27);
  Ecrit(33,3,'Disque :',31);
  Localise(42,3);
  Write(PathTem[1]);
  Ecrit(46,3,'Taille :',31);
  Localise(55,3);
  Write(Longeur);
  Compteur       := 0;
  CompteurX      := 1024;
  NumeroSecteur  := 1;
  NumeroCylindre := 0;
  NumeroTete     := 0;
  NumeroDisque   := $80;
  Registre.AH    := $08;
  Registre.DL    := $00;
  Intr($13,Registre);
  NombreSecteur  := Registre.CL and 31;
  NombreCylindre := Registre.CH + (Registre.CL shr 6) shl 8;
  NombreTete     := Registre.DH;
  Repeat
   Ecrit(6,7+Compteur,Hex(Compteur*16),27);
   Inc(Compteur);
  Until (Compteur = 16);
  VG := 0;
  Repeat
   FillChar(Tableau3,CompteurX,0);
   LectureDirecteDisque(2,NumeroSecteur,NumeroCylindre,NumeroTete,NumeroDisque,Tableau3);
   If(CompteurX = 256)Then
   Begin
    For Ya := 0 to 15 do
    Begin
     Mem[$B800:(15+Ya*80)*2+1104] := $30 + VG;
     For Xa := 0 to 15 do
     Begin
      Mem[$B800:(Xa*3+Ya*80)*2+1146]:=Ord(HexData[(Tableau3[Ya*16+Xa])Shr 4]);
      Mem[$B800:(Xa*3+Ya*80)*2+1148]:=Ord(HexData[(Tableau3[Ya*16+Xa])And 15]);
      Mem[$B800:(Xa+Ya*80)*2+1244]:=Tableau3[Ya*16+Xa];
     End;
    End;
   End
    else
   Begin
    For Ya := 0 to 15 do
    Begin
     Mem[$B800:(15+Ya*80)*2+1104] := $30 + VG;
     For Xa := 0 to 63 do
     Begin
      Mem[$B800:(Xa+Ya*80)*2+1148]:=Tableau3[Ya*64+Xa];
     End;
    End;
   End;
   Tem := Hex2(NumeroTete);
   Mem[$B800:530]:=ord(Tem[1]);
   Mem[$B800:532]:=ord(Tem[2]);
   Tem := Hex2(NumeroCylindre);
   Mem[$B800:534]:=ord(Tem[1]);
   Mem[$B800:536]:=ord(Tem[2]);
   Tem := Hex2(NumeroSecteur);
   Mem[$B800:538]:=ord(Tem[1]);
   Mem[$B800:540]:=ord(Tem[2]);
   Touche := ReadKey;
   If KeyPressed Then
   Begin
    Touche := ReadKey;
    Case Touche of
     #59 : AideDisque;
     #61 : Begin
	    CompteurX := 256;
	    BoiteCaractere(10,6,78,23,31);
	   End;
     #60 : Begin
	    CompteurX := 1024;
	    BoiteCaractere(10,6,78,23,31);
	   End;
     #66 : BootSector;
     #67 : ParamDisque;
     'I' : Begin
	    If(NumeroSecteur > 1)Then Dec(NumeroSecteur)
	     else
	    Begin
	     NumeroSecteur := NombreSecteur;
	     If(NumeroCylindre > 0)Then Dec(NumeroCylindre)
	      else
	     Begin
	      NumeroCylindre := NombreCylindre;
	      If(NumeroTete > 0)Then Dec(NumeroTete)
	       else
	      Begin
	       NumeroTete     := NombreTete;
	       NumeroCylindre := NombreCylindre;
	       NumeroSecteur  := NombreSecteur;
	      End;
	     End;
	    End;
	   End;
     'Q' : Begin
	    If(NombreSecteur >= NumeroSecteur)Then Inc(NumeroSecteur)
	     else
	    Begin
	     NumeroSecteur := 1;
	     If(NombreCylindre >= NumeroCylindre)Then Inc(NumeroCylindre)
	      else
	     Begin
	      NumeroCylindre := 0;
	      If(NombreTete >= NumeroTete)Then Inc(NumeroTete)
	       else
	      Begin
	       NumeroSecteur  := 1;
	       NumeroCylindre := 0;
	       NumeroTete     := 0;
	      End;
	     End;
	    End;
	   End;
     'G' : Begin
	    NumeroSecteur  := 1;
	    NumeroCylindre := 0;
	    NumeroTete     := 0;
	    Vg             := 0;
	   End;
    End;
    If(Touche = #68)Then Touche := #27 else Touche := #00;
   End;
  Until (Touche = #27);
  Handle := Ferme(Handle);
  RestorationData(Tableau);
 End
  else
 Write(^G);
End;
