Uses Crt,Dos;
{$S-}

Type ca_01       = String[01];
     ca_03       = String[03];
     ca_06       = String[06];
     ca_08       = String[08];
     ca_12       = String[12];
     ca_76       = String[76];
     ca_80       = String[80];
     asignatura  = Record
                     grup :Char;
                     asig : String[02];
                     nomb : String[20];
                     preg : Integer;
                   End;
     tema_prgta    = Record
                     grup : Char;
                     asig : String[02];
                     preg : String[02];
                     resp : Char;
                   End;
     texto_prgta = Record
                     grup : Char;
                     asig : String[02];
                     lect : String[02];
                     preg : String[02];
                     lini : Integer;
                     lfin : Integer;
                   End;
     texto_lectu = Record
                     codi : String[02];
                     copi : Char;
                     lini : Integer;
                     lfin : Integer;
                   End;
     ve_100_ca_76 = Array [1..100] Of ca_76;
     ve_20_as     = Array [1..20] Of asignatura;
     ve_60_te     = Array [1..40] Of tema_prgta;
     ve_62_tx_pr  = Array [0..41] Of texto_prgta;
     ve_10_tx_le  = Array [1..10] Of texto_lectu;

{********* Tipos de Datos Globales ********************************************}
Var asig_a,asig_b,
    asig_c,asig_d,
    asig           : ve_20_as;
    preg_a,preg_b,
    preg_c,preg_d  : ve_60_te;
    exam           : ve_62_tx_pr;
    lect           : ve_10_tx_le;
    to_as          : Integer;
    x_area         : Char;

{********* Apaga Cursor *******************************************************}
Procedure CURSOR_OFF;
  Var registro : Registers;
  Begin registro.AX := $0100; registro.CX := $1000; Intr(16,registro) End;

{********* Prende Cursor ******************************************************}
Procedure CURSOR_ON;
  Var registro : Registers;
  Begin registro.AX := $0100; registro.CX := $8B8C; Intr(16,registro) End;

{********* Genera Sonido ******************************************************}
Procedure BEEP(frecuencia,duracion:Integer);
  Begin Sound(frecuencia); Delay(duracion); NoSound End;

{********* Detiene Ejecusion **************************************************}
Procedure PAUSA(tiempo:Integer);
   Var  x : Char;
   Begin
     Case tiempo of
        -1 : Repeat x := ReadKey Until Ord(x) <> 0;
         0 : Repeat x := ReadKey Until Ord(x) = 13;
        Else Delay(tiempo * 1000);
     End;
   End;

{********* Retorna Cadena de Caracteres ***************************************}
Function CADENA(n:Integer; c:Char) : ca_80;
  Var x : ca_80; i : Integer;
  Begin x := ''; For i := 1 To n Do x := x + c; cadena := x End;

{********* Escribe Mensaje ****************************************************}
Procedure MENSAJE(mensaje:ca_80; fondo:Char; color:ca_06; fila:Byte);
   Begin
      GotoXY(02,fila); Write(CADENA(78,fondo));
      If color = 'w+'  Then Begin TextColor(10); TextBackGround(01); End;
      If color = 'w*'  Then Begin TextColor(23); TextBackGround(01); End;
      If color = 'w+*' Then Begin TextColor(26); TextBackGround(01); End;
      If color = 'u'   Then Begin TextColor(01); TextBackGround(07); End;
      If color = 'u+'  Then Begin TextColor(01); TextBackGround(07); End;
      If color = 'u*'  Then Begin TextColor(01); TextBackGround(07); End;
      If color = 'u+*' Then Begin TextColor(01); TextBackGround(07); End;
      If color = '/w'  Then Begin TextColor(01); TextBackGround(07); End;
      If color = '/w*' Then Begin TextColor(12); TextBackGround(07); End;
      GotoXY(40 - round(Length(mensaje) / 2),fila);
      Write(mensaje);
      TextColor(07); TextBackGround(01);
   End;

{********* Imprime Linea Vertical *********************************************}
Procedure LINEA_V(n:Byte; c:Char);
  Var i,j,k : Integer;
  Begin
    k := WhereX; j := WhereY;
    For i := j To j + n Do Begin GotoXY(k,i); Write(c) End;
  End;

{********* Imprime Marco ******************************************************}
Procedure MARCO(x1,y1,x2,y2:Integer ; t:char);
  Var h,v,e1,e2,e3,e4 : char;
  Begin
    If UpCase(t)='D' Then
      Begin h:='Í'; v:='º'; e1:='É'; e2:='»'; e3:='¼'; e4:='È'; End
    Else
      Begin h:='Ä'; v:='³'; e1:='Ú'; e2:='¿'; e3:='Ù'; e4:='À'; End;
    GotoXY(x1,y1); Write(CADENA(x2-x1,h)); GotoXY(x1,y2); Write(CADENA(x2-x1,h));
    GotoXY(x1,y1); LINEA_V(y2-y1,v); GotoXY(x2,y1); LINEA_V(y2-y1,v);
    GotoXY(x1,y1); Write(e1); GotoXY(x2,y1); Write(e2);
    GotoXY(x2,y2); Write(e3); GotoXY(x1,y2); Write(e4);
  End;

{********* Limpia Sector de la pantalla ***************************************}
Procedure CLRSCR_X(x1,y1,x2,y2 : Integer);
  Var i : Integer;
  Begin
    For i := y1 To y2 Do Begin
       GotoXY(x1,i); Write(CADENA(x2 - x1 + 1,' ')) End;
  End;

{********* Selecciona Opcion **************************************************}
   Procedure MENU(opciones:ve_100_ca_76; to_op,x1,y1,op_pa:Integer; Var opcion:Integer);
   Var tecla         : Char;
       t,i,l,ancho,fila : Byte;
   Begin
      ancho := Length(opciones[1]) + 2;
      Window(x1,y1,x1 + ancho - 1,y1 + op_pa - 1);
      If opcion > op_pa Then Begin
         i := opcion - 1; fila := 1; End
      Else Begin
         i := 0; fila := opcion;
      End;
      l := 0;
      Repeat
         i := i + 1; l := l + 1;GotoXY(2,l); Write(opciones[i]);
      Until (i = op_pa) Or (i = to_op);
      While i < op_pa Do Begin
         i := i + 1; GotoXY(2,i); Write(CADENA(ancho - 2,' '));
      End;
      GotoXY(2,fila);
      TextColor(00); TextBackGround(07);
      Write(opciones[opcion]);
      TextColor(07); TextBackGround(01);
      Repeat
         t := Ord(ReadKey);
         If t = 0 Then Begin
            t := Ord(ReadKey);
            GotoXY(2,fila);
            Write(opciones[opcion]);
            Case t Of
               72 : If opcion > 1 Then Begin
                       If fila = 1 Then Begin
                          InsLine;
                       End;
                       opcion := opcion - 1;
                       fila := fila - 1;
                       if fila < 1  Then fila := 1;
                    End;
               80 : If opcion < to_op Then Begin
                       If fila = op_pa Then Begin
                          Writeln;
                       End;
                       opcion := opcion + 1;
                       fila := fila + 1;
                       if fila > op_pa  Then fila := op_pa;
                    End;
            End;
            GotoXY(2,fila);
            TextColor(00); TextBackGround(07);
            Write(opciones[opcion]);
            TextColor(07); TextBackGround(01)
         End;
      Until t = 13;
      Window(1,1,80,25);
   End;

{********* Verifica si Existe Archivo *****************************************}
Function EXISTE_ARCHIVO(archivo:ca_12):Boolean;
  Var arch : File;
  Begin
    Assign(arch,archivo);
    {$I-} Reset(arch); Close(arch); {$I+}
    existe_archivo := (IOresult=0);
  End;

{********* Lee Archivo de Asignaturas *****************************************}
   Procedure LEER_ASIG;
   Var archivo     : Text;
       registro,tm : String[50];
       np,x        : Integer;
   Begin
      MENSAJE('  LEYENDO ARCHIVO EXASIGNA.TXT  ',' ','w+*',23);
      Assign(archivo,'exasigna.txt');
      Reset(archivo); to_as := 0;
      While Not Eof(archivo) Do
      Begin
         Readln(archivo,registro);
         to_as := to_as + 1;
         asig[to_as].grup := registro[1];
         asig[to_as].asig := Copy(registro,02,02);
         asig[to_as].nomb := Copy(registro,04,20);
         Case x_area Of
            'B' : Val(Copy(registro,24,02),np,x);
            'F' : Val(Copy(registro,26,02),np,x);
            'S' : Val(Copy(registro,28,02),np,x);
         End;
         asig[to_as].preg := np;
      End;
      Close(archivo);
   End;

{********* Muestra Orden De Asignaturas ***************************************}
Procedure REVI_ASIG(asig_x:ve_20_as);
   Var as_x      : ve_100_ca_76;
       pr_x      : String[02];
       as,t,ta,z : Integer;
   Begin
      ta := 0;
      For as := 1 To to_as Do Begin
         ta := ta + asig_x[as].preg;
         Str(asig_x[as].preg,pr_x);
         If asig_x[as].preg < 10 Then pr_x := ' ' + pr_x;
         as_x[as] := asig_x[as].grup + '  ³ ' + asig_x[as].asig + ' ³ ';
         as_x[as] := as_x[as] + asig_x[as].nomb + ' ³ ' + pr_x;
      End;
      If ta <> 40 Then Begin
         MENSAJE(' Error en N£mero de Preguntas CORREGIR ASIGNATU.TXT  ',' ','w+*',23);
         BEEP(1500,4000); x_area := ' '; Exit;
      End;
      Str(ta,pr_x);
      as_x[as + 1 ] := 'TOTAL =========================> ' + pr_x;
      t := to_as + 1;
      If t > 8 Then t:= 9;
      CLRSCR_X(21,07,59,10+t); MARCO(21,07,59,10+t,'S');
      GotoXY(22,08); Write(' Gr ³ Co ³     Asignatura       ³ Pr ');
      GotoXY(22,09); Write(CADENA(37,'Ä'));
      MENSAJE('  ['+Chr(24)+'] ['+Chr(25)+'] Revisar    [Enter] Continuar  ','P','w+',23);
      z := 1;
      MENU(as_x,to_as + 1,22,10,t,z);
      CLRSCR_X(21,07,59,10+t); BEEP(1000,100);
   End;

{********* Genera Tema Original ***********************************************}
Procedure TEMA_ORIG(Var preg_x:ve_60_te; Var asig_x:ve_20_as);
   Var as,pr,pa : Integer;
       pa_st   : String[2];
   Begin
      asig_x := asig;
      pr := 0;
      For as := 1 To to_as Do
         For pa := 1 To asig[as].preg Do Begin
            pr := pr + 1; Str(pa,pa_st);
            If pa < 10 Then pa_st := '0' + pa_st;
            preg_x[pr].grup := asig[as].grup;
            preg_x[pr].asig := asig[as].asig;
            preg_x[pr].preg := pa_st;
            preg_x[pr].resp := 'A';
         End;
   End;

{********* Codifica Texto de Examen *******************************************}
Procedure CODI_TEXT;
   Var examen         : Text;
       texto          : ve_100_ca_76;
       x_line         : String[255];
       n_examen,
       x_curs         : String[12];
       l_lect,l_preg,
       f_erro         : Boolean;
       n_lect,n_preg,
       n_line,t_line,
       x_code,x_preg,
       x_asig,x_pras,
       x_posc         : Integer;

   Procedure LEER_PREGUNTA;
   Begin
      n_line := 1; texto[n_line] := x_line;
      While Not(Eof(examen)) Do Begin
         n_line := n_line + 1;
         ReadLn(examen,texto[n_line]);
         texto[n_line] := texto[n_line] + CADENA(76 - Length(texto[n_line]),' ');
         If Copy(texto[n_line],1,1) = '%' Then Begin
            x_line := texto[n_line]; texto[n_line] := CADENA(76,' '); Exit;
         End
      End;
   End;

   Function EXI_RES(rpta:Char):Boolean;
   Begin
      x_posc := 0;
      EXI_RES := False;
      Repeat
         x_posc := x_posc + 1;
         If pos('\item [' + rpta + '.]',texto[x_posc]) > 0 Then Begin
            EXI_RES := True; Exit;
         End;
      Until x_posc = n_line;
   End;

   Procedure EVALUAR_PREGUNTA;
   Begin
      x_posc := 0;
      Repeat
         x_posc := x_posc + 1;
         if x_posc = 101 Then Exit;
      Until texto[x_posc][01] = '%';
      If Copy(texto[x_posc],03,01) = 'T' Then Begin
         n_lect := n_lect + 1;
         lect[n_lect].codi := Copy(texto[x_posc],03,02);
         lect[n_lect].lini := t_line;
         lect[n_lect].lfin := t_line + n_line;
         lect[n_lect].copi := 'N';
         GotoXY(02,21);
         Write('[________]  [__]  [_]  [__]  [__]  [__]  [_][_][_][_][_]  [____][____]  [___]');
         TextColor(16); TextBackGround(07);
         GotoXY(03,21); Write('COMP.LEC');
         TextColor(10); TextBackGround(01);
         GotoXY(15,21); Write(n_lect:2);
         GotoXY(61,21); Write(lect[n_lect].lini:4);
         GotoXY(67,21); Write(lect[n_lect].lfin:4);
         TextColor(07);
         BEEP(2000,400);
      End;
      Val(Copy(texto[x_posc],03,02),x_preg,x_code);
      If (x_code = 0) And (x_preg = n_preg + 1) Then Begin
         n_preg := n_preg + 1;
         exam[n_preg].grup := texto[x_posc,6];
         exam[n_preg].asig := Copy(texto[x_posc],08,02);
         exam[n_preg].preg := Copy(texto[x_posc],11,02);
         exam[n_preg].lect := Copy(texto[x_posc],14,02);
         exam[n_preg].lini := t_line;
         exam[n_preg].lfin := t_line + n_line;
         TextColor(00); TextBackGround(07);
         GotoXY(03,21); Write('PREGUNTA');
         TextColor(10); TextBackGround(01);
         GotoXY(15,21); Write(n_preg:2);
         GotoXY(21,21); Write(exam[n_preg].grup);
         GotoXY(26,21); Write(exam[n_preg].asig);
         GotoXY(32,21); Write(exam[n_preg].preg);
         GotoXY(38,21); Write(exam[n_preg].lect);
         GotoXY(44,21); Write('û');
         GotoXY(47,21); Write('û');
         GotoXY(50,21); Write('û');
         GotoXY(53,21); Write('û');
         GotoXY(56,21); Write('û');
         GotoXY(61,21); Write(exam[n_preg].lini:4);
         GotoXY(67,21); Write(exam[n_preg].lfin:4);
         GotoXY(75,21); Write('OKû');
         TextColor(26);
         x_pras := x_pras + 1;
         If x_pras > asig[x_asig].preg Then Begin
            x_asig := x_asig + 1; x_pras := 1;
         End;
         f_erro := False;
         If exam[n_preg].grup <> asig[x_asig].grup Then Begin
            GotoXY(21,21); Write('*'); f_erro := True;
         End;
         If exam[n_preg].asig <> asig[x_asig].asig Then Begin
            GotoXY(26,21); Write('**'); f_erro := True;
         End;
         Val(exam[n_preg].preg,x_preg,x_code);
         If x_pras <> x_preg Then Begin
            GotoXY(32,21); Write('**'); f_erro := True;
         End;
         If Not(EXI_RES('A')) Then Begin
            GotoXY(44,21); Write('*'); f_erro := True;
         End;
         If Not(EXI_RES('B')) Then Begin
            GotoXY(47,21); Write('*'); f_erro := True;
         End;
         If Not(EXI_RES('C')) Then Begin
            GotoXY(50,21); Write('*'); f_erro := True;
         End;
         If Not(EXI_RES('D')) Then Begin
            GotoXY(53,21); Write('*'); f_erro := True;
         End;
         If Not(EXI_RES('E')) Then Begin
            GotoXY(56,21); Write('*'); f_erro := True;
         End;
         If f_erro Then Begin
            TextColor(16); TextBackGround(07);
            GotoXY(75,21); Write('ER!');
            TextColor(10); TextBackGround(01);
            BEEP(1000,400); Delay(200);
            BEEP(1000,400); Delay(200);
            BEEP(1000,400);
            x_area := ' ';
         End;
         TextColor(07);
      End;
   End;

   Begin
      n_examen := 'EXAMEN_' + x_area + '.TEX';
      If Not(EXISTE_ARCHIVO(n_examen)) Then Begin
         MENSAJE('  No Existe El archivo Fuente  ',' ','/w',23);
         BEEP(900,1000); Delay(3000); x_area := ' '; Exit;
      End;
      MENSAJE('  VERIFICACION DE CODIGOS  ','²','/w',4);
      MENSAJE('  ['+Chr(24)+'] ['+Chr(25)+'] Revisar    [Enter] Continuar  ','V','w+',23);
      GotoXY(02,19); Write(CADENA(78,'Ä'));
      CLRSCR_X(02,06,79,18);
      GotoXY(02,20);
      Write(' Texto       N§   Gru  Asig  Orde  CmLc   A  B  C  D  E    Lini  Lfin   Chek');
      GotoXY(02,21);
      Write('[________]  [__]  [_]  [__]  [__]  [__]  [_][_][_][_][_]  [____][____]  [___]');
      l_lect := False; n_lect := 0;
      l_preg := False; n_preg := 0;
      x_pras := 0;
      Assign(examen,n_examen);
      Reset(examen);
      ReadLn(examen,x_line);
      x_line := x_line + CADENA(76 - Length(x_line),' ');
      t_line := 0;
      x_asig := 1;
      Repeat
         fillChar(texto,SizeOf(texto),' ');
         LEER_PREGUNTA;
         n_line := n_line - 1;
               Writeln('lineas : ',n_line);
         EVALUAR_PREGUNTA;
         x_code := 1;
         MENU(texto,n_line,02,06,13,x_code);
         t_line := t_line + n_line
      Until Eof(examen);
      Close(examen);
      MENSAJE('  Presione Barra Espaciadora Para Continuar  ','!','w+',23);
      BEEP(900,100); Repeat Until ReadKey = chr(32);
      If x_area <> ' ' Then; Begin
         TEMA_ORIG(preg_a,asig_a);
         asig_b := asig_a; asig_c := asig_a; asig_d := asig_a;
         preg_b := preg_a; preg_c := preg_a; preg_d := preg_a;
      End;
   End;

{********* Imprime Temas ******************************************************}
Procedure REVI_TEMAS;
   Var ts : ve_100_ca_76;
       x  : Integer;
       n  : ca_12;
   Begin
      For x := 1 To 40 Do Begin
         Str(x,n);
         if x < 10 Then n := '0' + n;
         ts[x] := ' ' + n + ' º '+ preg_a[x].grup + ' ³ ' + preg_a[x].asig;
         ts[x] := ts[x] + ' ³ ' + preg_a[x].preg + ' ³ ' + preg_a[x].resp;
         ts[x] := ts[x] + ' º ' + preg_b[x].grup + ' ³ ' + preg_b[x].asig;
         ts[x] := ts[x] + ' ³ ' + preg_b[x].preg + ' ³ ' + preg_b[x].resp;
         ts[x] := ts[x] + ' º ' + preg_c[x].grup + ' ³ ' + preg_c[x].asig;
         ts[x] := ts[x] + ' ³ ' + preg_c[x].preg + ' ³ ' + preg_c[x].resp;
         ts[x] := ts[x] + ' º ' + preg_d[x].grup + ' ³ ' + preg_d[x].asig;
         ts[x] := ts[x] + ' ³ ' + preg_d[x].preg + ' ³ ' + preg_d[x].resp + ' ';
      End;
      GotoXY(02,06);
      Write('     º                 º                 º                 º                 ');
      GotoXY(02,07);
      Write('  N§ ºGru³Asig³PgN§³ResºGru³Asig³PgN§³ResºGru³Asig³PgN§³ResºGru³Asig³PgN§³Res');
      TextColor(00); TextBackGround(07);
      GotoXY(03,06); Write(' Pg ');
      GotoXY(10,06); Write('   Tema  A   ');
      GotoXY(28,06); Write('   Tema  B   ');
      GotoXY(46,06); Write('   Tema  C   ');
      GotoXY(64,06); Write('   Tema  D   ');
      TextColor(07); TextBackGround(01);
      MENSAJE('  ['+Chr(24)+'] ['+Chr(25)+'] Revisar    [Enter] Salir  ',' ','w+',23);
      x := 1;
      MENU(ts,60,02,08,14,x);
      x := Ord(readKey)
  End;

{********* Sortea Grupos ******************************************************}
Procedure SORT_GRUP(Var preg:ve_60_te; Var asig:ve_20_as);
  Var as,nc,nf,g,ga,gr,gi,gf,gt,pa,p,pr,n,x : Integer;
      flag                : Boolean;
      gx                  : Char;
      preg_t              : ve_60_te;
      asig_t              : ve_20_as;
      grupos              : String[4];
  Begin
    preg_t := preg; asig_t := asig;
    For as := 1 To to_as Do asig[as].grup := '*';
    grupos := '1234'; nc := 0; nf := 0; as := 0; pr := 0;
    For gr:= 1 To 4 Do
      Begin
        Repeat
          x := Random(4) + 1; gx := grupos[x]; flag := True;
          For n := 1 To to_as Do If asig[n].grup = gx Then flag := False;
        Until flag;
        g := 1;
        While gx <> asig_t[g].grup Do g := g + 1;
        gi := g;
        Repeat g := g + 1;
        Until (gx <> asig_t[g].grup) Or (g = to_as);
        If g < to_as Then gf := g - 1 Else gf := g;
        For ga := gi To gf Do
          Begin
            as := as + 1; asig[as] := asig_t[ga]; p := 0;
            Repeat p := p + 1;
            Until (preg_t[p].asig = asig[as].asig) Or (p = 40);
            p := p - 1;
            For pa := 1 To asig[as].preg Do
              Begin
                pr := pr + 1; p := p  + 1; preg[pr] := preg_t[p];
                nf := nf + 1;
                If nf = 13 Then Begin nc := nc + 1; nf := 1 End;
                TextColor(00); TextBackGround(07);
                GotoXY(8 + nc * 15, 7 + nf);
                Write(preg[pr].grup,' ',preg[pr].asig,' ',preg[pr].preg,' ',preg[pr].resp,' ');
                BEEP(3600,10);
                TextColor(07); TextBackGround(01);
                GotoXY(8 + nc * 15, 7 + nf);
                Write(preg[pr].grup,' ',preg[pr].asig,' ',preg[pr].preg,' ',preg[pr].resp,' ');
              End;
          End;
      End
  End;

{********* Sortea Asignaturas *************************************************}
Procedure SORT_ASIG(Var preg:ve_60_te; Var asig:ve_20_as);
  Var as,nc,nf,g,ga,gr,gi,gf,gt,pa,p,pr,n,x : Integer;
      flag                : Boolean;
      gx                  : Char;
      preg_t              : ve_60_te;
      asig_t              : ve_20_as;
  Begin
    preg_t := preg; asig_t := asig;
    For as := 1 To to_as Do asig[as].asig := '**';
    nc := 0; nf := 0; as := 0; pr := 0; g := 1;
    For gr:= 1 To 4 Do
      Begin
        gx := asig_t[g].grup;
        While asig_t[g].grup = gx Do
          Begin
            Repeat
              flag := True;
              Repeat
                x := Random(to_as) + 1;
              Until asig[x].grup = gx;
              For n := 1 To to_as Do
                If asig_t[x].asig = asig[n].asig Then flag := False;
            Until Flag;
            as := as + 1; asig[as] := asig_t[x]; p := 0;
            Repeat p := p + 1;
            Until preg_t[p].asig = asig[as].asig;
            p := p - 1;
            For pa := 1 To asig[as].preg Do
              Begin
                pr := pr + 1; p := p + 1; preg[pr] := preg_t[p];
                nf := nf + 1;
                If nf = 13 Then Begin nc := nc + 1; nf := 1 End;
                TextColor(00); TextBackGround(07);
                GotoXY(9 + nc * 15, 7 + nf);
                Write(' ',preg[pr].asig,' ',preg[pr].preg,' ',preg[pr].resp,' ');
                BEEP(3800,10);
                TextColor(07); TextBackGround(01);
                GotoXY(9 + nc * 15, 7 + nf);
                Write(' ',preg[pr].asig,' ',preg[pr].preg,' ',preg[pr].resp,' ');
              End;
            g := g + 1;
            If g > to_as Then Exit
          End;
      End;
  End;

{********* Sortear Preguntas **************************************************}
Procedure SORT_PREG(Var preg:ve_60_te; asig:ve_20_as);
  Var as,i,n,nc,nf,tc,tp,pa,pr,x : Integer;
      pr_x                       : String[2];
      flag                       : Boolean;
  Begin
    For pr := 1 To 40 Do preg[pr].preg :=  '**';
    nc := 0; nf := 0; pr := 1;
    For as := 1 To to_as Do
      Begin
        i := pr;
        For pa := 1 To asig[as].preg Do
          Begin
            Repeat
              x := Random(asig[as].preg) + 1;
              Str(x,pr_x);
              If x < 10 Then pr_x := '0' + pr_x;
              flag := True;
              n := 0;
              While n < asig[as].preg Do
                Begin
                  If pr_x = preg[i + n].preg Then flag := False;
                  n := n + 1;
                End;
            Until flag;
            preg[pr].preg := pr_x;
            nf := nf + 1;
            If nf = 13 Then Begin nc := nc + 1; nf := 1 End;
            TextColor(00); TextBackGround(07);
            GotoXY(12 + nc * 15, 7 + nf);
            Write(' ',preg[pr].preg,' ',preg[pr].resp,' ');
            BEEP(4000,10);
            TextColor(07); TextBackGround(01);
            GotoXY(12 + nc * 15, 7 + nf);
            Write(' ',preg[pr].preg,' ',preg[pr].resp,' ');
            pr := pr + 1;
          End;
      End;
  End;

{********* Sortea Respuestas **************************************************}
Procedure SORT_RESP(Var preg:ve_60_te);
  Var a,b,c,d,e,nc,nf,pr,x : Integer;
      rpts                : String[5];
  Begin
    rpts := 'ABCDE';
    nc := 0; nf := 0; a := 0; b := 0; c := 0; d := 0; e := 0;
    For pr := 1 To 40 Do
      Begin
        x := Random(5) + 1; preg[pr].resp := rpts[x];
        Case rpts[x] Of
          'A' : a := a + 1;
          'B' : b := b + 1;
          'C' : c := c + 1;
          'D' : d := d + 1;
          'E' : e := e + 1;
        End;
        nf := nf + 1;
        If nf = 13 Then Begin nc := nc + 1; nf := 1 End;
        TextColor(00); TextBackGround(07);
        GotoXY(15 + nc * 15, 7 + nf);
        Write(' ',preg[pr].resp,' ');
        BEEP(4100,10);
        TextColor(07); TextBackGround(01);
        GotoXY(15 + nc * 15, 7 + nf);
        Write(' ',preg[pr].resp,' ');
      End;
    TextColor(10);
    GotoXY(06,21); Write('"A" = ',a:2);
    GotoXY(21,21); Write('"B" = ',b:2);
    GotoXY(36,21); Write('"C" = ',c:2);
    GotoXY(51,21); Write('"D" = ',d:2);
    GotoXY(66,21); Write('"E" = ',e:2);
    TextColor(7)
  End;

{********* Imprime Tema *******************************************************}
Procedure IMPR_TEMA(preg:ve_60_te);
  Var  a,b,c,d,e,pr,nc,nf : Integer;
       t                 : String[1];
  Begin
    TextColor(10);
    GotoXY(05,06); Write('N§ G AA PP R');
    GotoXY(20,06); Write('N§ G AA PP R');
    GotoXY(35,06); Write('N§ G AA PP R');
    GotoXY(50,06); Write('N§ G AA PP R');
    GotoXY(65,06); Write('N§ G AA PP R');
    TextColor(07);
    GotoXY(18,06); LINEA_V(13,'³'); GotoXY(33,06); LINEA_V(13,'³');
    GotoXY(48,06); LINEA_V(13,'³'); GotoXY(63,06); LINEA_V(13,'³');
    GotoXY(02,20); Write(CADENA(78,'Ä'));
    nc := 0; nf := 0; a := 0;  b := 0; c := 0;  d := 0; e := 0;
    For pr := 1 To 40 Do
      Begin
        nf := nf + 1;
        If nf = 13 Then Begin nc := nc + 1; nf := 1 End;
        Case preg[pr].resp Of
          'A' : a := a + 1;
          'B' : b := b + 1;
          'C' : c := c + 1;
          'D' : d := d + 1;
          'E' : e := e + 1;
        End;
        GotoXY(5 + nc * 15, 7 + nf);
        TextColor(10);
        Write(pr:2,' ');
        TextColor(07);
        Write(preg[pr].grup,' ',preg[pr].asig,' ',preg[pr].preg,' ',preg[pr].resp);
      End;
    TextColor(10);
    GotoXY(06,21); Write('"A" = ',a:2);
    GotoXY(21,21); Write('"B" = ',b:2);
    GotoXY(36,21); Write('"C" = ',c:2);
    GotoXY(51,21); Write('"D" = ',d:2);
    GotoXY(66,21); Write('"E" = ',e:2);
    TextColor(07)
  End;

{********* Selecciona Sorteo **************************************************}
Procedure SORTEO(Var preg:ve_60_te; Var asig:ve_20_as);
  Var opx,op  : Char;
      n_gra   : Boolean;
      tx,t    : Byte;
  Begin
    IMPR_TEMA(preg);
    Repeat
      GotoXY(02,23);
      Write('[F5]S.Gru  [F6]S.Asi  [F7]S.Pre  [F8]S.Res  [F3]Ver.A  [F0]Nuevo.T  [Esc]Salir');
      TextColor(10);
      GotoXY(03,23); Write('F5');
      GotoXY(14,23); Write('F6');
      GotoXY(25,23); Write('F7');
      GotoXY(36,23); Write('F8');
      GotoXY(47,23); Write('F3');
      GotoXY(58,23); Write('F0');
      GotoXY(71,23); Write('Esc');
      TextColor(7);
      Repeat
        tx := Ord(ReadKey); t := 0;
        If tx = 0 Then t:= Ord(ReadKey)
      Until ((tx = 0) And (t in [61,63,64,65,66,68])) Or (tx = 27);
      BEEP(1000,100);
      MENSAJE('P  R  O  C  E  S  A  N  D  O',' ','w+*',23);
      Case t Of
        61 : Begin REVI_ASIG(asig); IMPR_TEMA(preg) End;
        63 : SORT_GRUP(preg,asig);
        64 : SORT_ASIG(preg,asig);
        65 : SORT_PREG(preg,asig);
        66 : SORT_RESP(preg);
        68 : Begin BEEP(400,800); TEMA_ORIG(preg,asig); IMPR_TEMA(preg) End;
      End;
    Until tx = 27;
    CLRSCR_X(02,06,79,21)
  End;


{********* Graba Temas de Examen **********************************************}
Procedure GRA_TEMA(preg:ve_60_te; destino:ca_12);
   Type linea_tx = Record
                      flag : Char;
                      lini : Integer;
                      lfin : Integer;
                   End;
   Var texto_p    : Array[1..100] Of String[255];
       texto_c    : Array[1..8] Of linea_tx;
       orig,sort  : Text;
       linea      : String[255];
       ps_n,po_n,
       cl_n,
       nl,tl,
       w,x,r      : Integer;
       rpts       : Char;
   Begin
      TextColor(10);
      Assign(orig,'examen_' + x_area + '.tex'); Assign(sort,destino);
      Reset(orig);                              Rewrite(sort);
      Repeat
          ReadLn(orig,linea);
          If linea[1] <> '%' Then WriteLn(sort,linea);
      Until linea[1] = '%';
      Close(orig);
      For ps_n := 1 To 40 Do Begin
         po_n := 1;
         While Not((preg[ps_n].asig = exam[po_n].asig) And
            (preg[ps_n].preg = exam[po_n].preg)) Do po_n := po_n + 1;
         GotoXY(36,13); Write(ps_n:2);
         GotoXY(57,13); Write(po_n:2);
         If Copy(exam[po_n].lect,01,01) = 'T' Then Begin
            cl_n := 1;
            While exam[po_n].lect <> lect[cl_n].codi Do cl_n := cl_n + 1;
            If lect[cl_n].copi = 'N' Then Begin
               Reset(orig);
               For nl := 1 To lect[cl_n].lini - 1 Do ReadLn(orig,linea);
                  For nl := lect[cl_n].lini To lect[cl_n].lfin Do
                     Begin ReadLn(orig,linea); WriteLn(sort,linea); End;
                  Close(orig);
               lect[cl_n].copi := 'S';
            End;
         End;
         Reset(orig);
         For nl := 1 To exam[po_n].lini - 1 Do ReadLn(orig,linea);
         tl := 0;
         texto_c[1].flag := 'N';
         texto_c[1].lini := 1;
         For nl := exam[po_n].lini To exam[po_n].lfin Do Begin
            tl := tl + 1;
            ReadLn(orig,texto_p[tl]);
            If Copy(texto_p[tl],01,19) = '\begin{description}' Then texto_c[1].lfin := tl;
            If Copy(texto_p[tl],01,07) = '\item [' Then
               Case texto_p[tl][8] Of
                  'A':Begin texto_c[2].flag:='N'; texto_c[2].lini:=tl; End;
                  'B':Begin texto_c[2].lfin:=tl-1; texto_c[3].flag:='N'; texto_c[3].lini:=tl; End;
                  'C':Begin texto_c[3].lfin:=tl-1; texto_c[4].flag:='N'; texto_c[4].lini:=tl; End;
                  'D':Begin texto_c[4].lfin:=tl-1; texto_c[5].flag:='N'; texto_c[5].lini:=tl; End;
                  'E':Begin texto_c[5].lfin:=tl-1; texto_c[6].flag:='N'; texto_c[6].lini:=tl; End;
               End;
            If Copy(texto_p[tl],01,17) = '\end{description}' Then Begin
               texto_c[6].lfin:=tl-1; texto_c[7].flag:='N'; texto_c[7].lini:=tl; End;
         End;
         texto_c[7].lfin := tl; Close(orig);
         For w := texto_c[1].lini To texto_c[1].lfin Do WriteLn(sort,texto_p[w]);
         r := 0;
         For rpts := 'A' To 'E' Do Begin
            If rpts = preg[ps_n].resp Then x := 2
            Else Begin
               Repeat x := Random(4) + 1; Until texto_c[2 + x].flag = 'N';
               x := x + 2;
            End;
            GotoXY(34 + 6 * r,19); Write(Copy(texto_p[texto_c[x].lini],08,01));
            r := r + 1;
            linea := Copy(texto_p[texto_c[x].lini],01,07) + rpts;
            linea := linea + Copy(texto_p[texto_c[x].lini],09,244);
            WriteLn(sort,linea);
            For w := texto_c[x].lini + 1 To texto_c[x].lfin Do WriteLn(sort,texto_p[w]);
            texto_c[x].flag := 'S';
         End;
         For w := texto_c[7].lini To texto_c[7].lfin Do WriteLn(sort,texto_p[w]);
      End;
      Reset(orig);
      For nl := 1 To exam[40].lfin Do ReadLn(orig,linea);
      While Not(Eof(Orig)) Do
         Begin ReadLn(orig,linea); WriteLn(sort,linea); End;
      Close(orig); Close(sort); TextColor(07);
      For cl_n := 1 to 10 Do lect[cl_n].copi := 'N';;
   End;

{********* Graba Archivo de Temas *********************************************}
Procedure GRABAR;
   Var preg       : ve_60_te;
       tema,tecla : Char;
       destino    : ca_12;
   Begin
      GotoXY(19,08); Write('ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
      GotoXY(19,09); Write('³        T  E  M  A    ==>    [ _ ]       ³');
      GotoXY(19,10); Write('ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´');
      GotoXY(19,11); Write('³             P R E G U N T A             ³');
      GotoXY(19,12); Write('ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´');
      GotoXY(19,13); Write('³  Sorteado ==>  __  ³  Original ==>  __  ³');
      GotoXY(19,14); Write('ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´');
      GotoXY(19,15); Write('³           R E S P U E S T A S           ³');
      GotoXY(19,16); Write('ÃÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄ´');
      GotoXY(19,17); Write('³  Sorteado ³  A  ³  B  ³  C  ³  D  ³  E  ³');
      GotoXY(19,18); Write('ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÅÄÄÄÄÄÅÄÄÄÄÄÅÄÄÄÄÄÅÄÄÄÄÄ´');
      GotoXY(19,19); Write('³  Original ³  _  ³  _  ³  _  ³  _  ³  _  ³');
      GotoXY(19,20); Write('ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÙ');
      For tema := 'A' To 'D' Do  Begin
         Case tema Of
            'A' : preg := preg_a;
            'B' : preg := preg_b;
            'C' : preg := preg_c;
            'D' : preg := preg_d;
         End;
         TextColor(00); TextBackGround(07);
         GotoXY(50,09); Write(' ',tema,' ');
         TextColor(07); TextBackGround(01);
         destino := 'EXTM_' + x_area + '_' + tema + '.TEX';
         tecla := 'S';
         If EXISTE_ARCHIVO(destino) Then Begin
            MENSAJE('  El Archivo '+destino+' Existe ... ¨ SE REGRABA ?  [S/N]  ',' ','/w*',23);
            BEEP(1500,100);
            Repeat  tecla := UpCase(ReadKey) Until tecla In ['S','N'];
            BEEP(1000,100);
         End;
         If tecla = 'S' Then Begin
            MENSAJE('  GRABANDO ARCHIVO  ' + destino + '  ',tema,'w+*',23);
            GRA_TEMA(preg,destino); BEEP(100,1000);
         End;
      End;
   End;

{********* Selecciona Tema ****************************************************}
Procedure SELE_TEMA(Var o_tema:Integer);
  Var temas : ve_100_ca_76;
  Begin
    temas[1]:='  A  ';
    temas[2]:='  B  ';
    temas[3]:='  C  ';
    temas[4]:='  D  ';
    MARCO(35,09,45,16,'S');
    GotoXY(38,10); Write('Tema');
    GotoXY(36,11); Write(CADENA(9,'Ä'));
    MENSAJE('  ['+Chr(24)+'] ['+Chr(25)+'] Buscar    [Enter] Elegir  ','T','w+',23);
    MENU(temas,04,37,12,04,o_tema);
    BEEP(1000,100);
    CLRSCR_X(35,09,46,16)
  End;

{********* Selecciona Area ****************************************************}
Procedure SELE_AREA(Var o_area:Integer; Var x_area:Char);
   Var areas          : ve_100_ca_76;
       s_area,archivo : ca_76;
       i              : Integer;
   Begin
      If Not(EXISTE_ARCHIVO('exasigna.txt')) Then  Begin
         MENSAJE(' No  Exixte  Archivo  EXASIGNAT.TXT  ',' ','/w*',23);
         BEEP(1500,4000);
         x_area := ' ';
         Exit;
      End;
      areas[1] := ' cs. BIOLOGICAS ³ exam‚n_B.tex ';
      areas[2] := ' cs. FISICAS    ³ exam‚n_F.tex ';
      areas[3] := ' cs. SOCIALES   ³ exam‚n_S.tex ';
      MARCO(22,10,56,16,'S');
      GotoXY(24,11); Write('     Area       ³   Archivo    ');
      GotoXY(24,12); Write(CADENA(31,'Ä'));
      MENSAJE('  ['+Chr(24)+'] ['+Chr(25)+'] Buscar    [Enter] Elegir  ','A','w+',23);
      MENU(areas,03,23,13,03,o_area);
      BEEP(1000,100);
      s_area := areas[o_area];
      archivo := 'EXAMEN_' + s_area[6] + '.TEX';
      If Not(EXISTE_ARCHIVO(archivo)) Then  Begin
         MENSAJE('  NO  Existe  Archivo  ' + archivo + '  ',' ','/w*',23);
         BEEP(1500,4000);
         x_area := ' ';
         End
      Else Begin
         x_area := s_area[6]; TextColor(Yellow);
         GotoXY(70,05); Write('<',Copy(s_area,06,07),'>'); TextColor(07);
      End;
      CLRSCR_X(22,10,56,16);
   End;

{********* Selecciona Tarea ***************************************************}
   Procedure SELE_TAREA(Var o_tarea:Integer);
   Var x_menu   : ve_100_ca_76;
   Begin
      x_menu[1] := '    SELECCION DE AREA     ';
      x_menu[2] := '      SORTEO DE TEMA      ';
      x_menu[3] := '   COMPARACION DE TEMAS   ';
      x_menu[4] := '    GRABACION DE TEMAS    ';
      x_menu[5] := '        FINALIZAR         ';
      CLRSCR_X(02,06,79,21);
      MENSAJE('   MENU PRINCIPAL   ','²','/w',04);
      MENSAJE('  ['+Chr(24)+'] ['+Chr(25)+'] Seleccionar    [Enter] Ejecutar  ',' ','w+',23);
      MARCO(08,08,37,14,'S');
      MENU(x_menu,05,09,09,05,o_tarea);
      BEEP(1000,100);
      MENSAJE(x_menu[o_tarea],'²','/w',04);
      CLRSCR_X(02,06,79,21);
   End;

{********* P R I N C I P A L **************************************************}
Var o_tarea, o_area, o_tema : Integer;
    f_graba                 : Boolean;
    tecla                   : Char;
Begin
   TextColor(07); TextBackGround(01); Clrscr;
   CURSOR_OFF;
   MARCO(1,1,80,24,'D');
   GotoXY(01,03); Write('Ì',CADENA(78,'Í'),'¹');
   GotoXY(02,04); Write(CADENA(78,'²'));
   GotoXY(01,05); Write('Ç',CADENA(78,'Ä'),'¶');
   GotoXY(01,22); Write('Ì',CADENA(78,'Í'),'¹');
   TextColor(10); GotoXY(02,02);
   Write('UNSA-Inst.Inform tica             SORTEO DE PREGUNTAS PARA EXAMEN');
   TextColor(7);
   x_area  := ' ';
   f_graba := False;
   o_tarea := 1;
   o_area  := 1;
   o_tema  := 1;
   Repeat
      SELE_TAREA(o_tarea);
      Case o_tarea Of
         1 : Begin
                SELE_AREA(o_area,x_area);
                If x_area <> ' ' Then Begin
                   LEER_ASIG;
                   MENSAJE(' DISTRIBUCION DE PREGUNTAS x ASIGNATURAS x GRUPO ','²','/w',04);
                   REVI_ASIG(asig);
                   CODI_TEXT;
                   if x_area = ' ' Then Begin
                      GotoXY(70,05); Write('ÄÄÄÄÄÄÄÄÄ');
                   End;
                End;
             End;
         2 : If x_area <> ' ' Then Begin
                SELE_TEMA(o_tema);
                Case o_tema Of
                   1 : SORTEO(preg_a,asig_a);
                   2 : SORTEO(preg_b,asig_b);
                   3 : SORTEO(preg_c,asig_c);
                   4 : SORTEO(preg_d,asig_d);
                End;
                f_graba := True;
             End;
         3 : If x_area <> ' ' Then
                REVI_TEMAS;
         4 : If x_area <> ' ' Then Begin
                GRABAR; f_graba := False;
             End;
         5 : Begin
                If f_graba And (x_area <> ' ') Then Begin
                   MENSAJE(' Hay Temas Sorteados ¨ se GRABAN ? [S/N]  ',' ','/w',23);
                   Repeat  tecla := UpCase(ReadKey) Until tecla In ['S','N'];
                   BEEP(1000,100);
                   If tecla = 'S' Then GRABAR;
                End;
                ClrScr;
                CURSOR_ON;
                Halt;
             End;
      End;
   Until False;
End.

