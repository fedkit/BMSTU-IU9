% Лабораторная работа № 1.1. Раскрутка самоприменимого компилятора
% 17 февраля 2026 г.
% Фёдор Китанин, ИУ9-61Б

# Цель работы
Целью данной работы является ознакомление с 
раскруткой самоприменимых компиляторов на примере модельного компилятора.

# Индивидуальный вариант
Компилятор BeRo. Заменить ключевые слова begin 
и end на {{ и }} соответственно. При этом ключевые слова begin и end остаются допустимыми.


# Реализация

Различие между файлами `btpc64.pas` и `btpc64-2.pas`:

```diff
783,784c783,796
<   while (CurrentChar<>'}') and (CurrentChar<>#0) do begin
<    ReadChar;
---
>   ReadChar;                     {отредактированный код}
>   if CurrentChar='{' then begin 
>    CurrentSymbol:=SymBEGIN;
>    ReadChar;                   
>   end else begin                
>    while (CurrentChar<>'}') and (CurrentChar<>#0) do ReadChar;
>    if CurrentChar='}' then ReadChar;
>    GetSymbol;                   
>   end;
>  end else if CurrentChar='}' then begin
>   ReadChar;                     
>   if CurrentChar='}' then begin 
>    CurrentSymbol:=SymEND;
>    ReadChar;                    
786,787d797
<   ReadChar;
<   GetSymbol;
795,796d804
<   end else begin
<    Error(102);
798,799d805
<  end else begin
<   Error(102);

```

Различие между файлами `btpc64-2.pas` и `btpc64-3.pas`:

```diff
48c48
< program BTPC; {{ BeRoTinyPascalCompiler }
---
> program BTPC; 
311c311
<   end;
---
>   }};
371c371
<   end;
---
>   }};
431c431
<   end;
---
>   }};
491c491
<   end;
---
>   }};
551c551
<   end;
---
>   }};
615c615
<  end;
---
>  }};
632c632
<         (CurrentChar='_') do begin
---
>         (CurrentChar='_') do {{
684c684
<  end else if CurrentChar='.' then begin
---
>  }} else if CurrentChar='.' then begin
692c692
<  end else if (CurrentChar='''') or (CurrentChar='#') then begin
---
>  end else if (CurrentChar='''') or (CurrentChar='#') then {{
744c744
<  end else if CurrentChar='-' then begin
---
>  }} else if CurrentChar='-' then begin
752c752
<   if CurrentChar='*' then begin
---
>   if CurrentChar='*' then {{
807c807
< end;
---
> }};
825c825
<  if IdentifierPosition=MaximalIdentifiers then begin
---
>  if IdentifierPosition=MaximalIdentifiers then {{
900c900
<   end;
---
>   }};
926c926
<   end else if (LastOpcode=OPLdA) and (Opcode=OPLoad) then begin
---
>   end else if (LastOpcode=OPLdA) and (Opcode=OPLoad) then {{
959c959
<  end else begin
---
>  }} else begin
1001c1001
<   while (CurrentSymbol=TokPeriod) or (CurrentSymbol=TokLBracket) do begin
---
>   while (CurrentSymbol=TokPeriod) or (CurrentSymbol=TokLBracket) do {{
1053c1053
<  end;
---
>  }};
1117c1117
<    if CurrentSymbol=TokLParent then begin
---
>    if CurrentSymbol=TokLParent then {{
1130c1130
<    end;
---
>    }};
1192c1192
<   if p<>Identifiers[i].LastParameter then begin
---
>   if p<>Identifiers[i].LastParameter then {{
1194c1194
<   end;
---
>   }};
1261c1261
<  end;
---
>  }};
1303c1303
<  if CurrentSymbol=TokPlus then begin
---
>  if CurrentSymbol=TokPlus then {{
1340c1340
<  end;
---
>  }};
1418c1418
<    end;
---
>    }};
1438c1438
<  end else if CurrentSymbol=SymCASE then begin
---
>  end else if CurrentSymbol=SymCASE then {{
1528c1528
<    end else if CurrentSymbol=sYMdownto then begin
---
>    }} else if CurrentSymbol=sYMdownto then begin
1536c1536
<    if i=0 then begin
---
>    if i=0 then {{
1625c1625
<   end  else if CurrentSymbol=TokMinus then begin
---
>   }}  else if CurrentSymbol=TokMinus then begin
1633c1633
<    if Identifiers[i].Kind<>IdCONST then begin
---
>    if Identifiers[i].Kind<>IdCONST then {{
1717c1717
<    end;
---
>    }};
1743c1743
<     end else begin
---
>     end else {{
1859c1859
<  end;
---
>  }};
1876c1876
<   if Types[Identifiers[f].TypeDefinition].Kind<>KindSIMPLE then begin
---
>   if Types[Identifiers[f].TypeDefinition].Kind<>KindSIMPLE then {{
1940c1940
<   end else if CurrentSymbol=SymVAR then begin
---
>   }} else if CurrentSymbol=SymVAR then begin
1950c1950
<  if L+1=CodeLabel then begin
---
>  if L+1=CodeLabel then {{
2016c2016
<  end else begin
---
>  }} else begin
2039c2039
< begin
---
> {{
2327c2327
<   end;
---
>   }};
2345c2345
< begin
---
> {{
2388d2387
< {{http://stackoverflow.com/questions/20730731/syntax-of-short-jmp-instruction}
2435c2434
< end;
---
> }};
2451c2450
<  EmitByte($48); EmitByte($85); EmitByte($c0); {{ TEST EAX,EAX }
---
>  EmitByte($48); EmitByte($85); EmitByte($c0); 
2469c2468
< begin
---
> {{
2598c2597
<    end;
---
>    }};
2692c2691
<     end else if (Value>=-128) and (Value<=127) then begin
---
>     }} else if (Value>=-128) and (Value<=127) then begin
2751c2750
<     end else begin
---
>     end else {{
2767c2766
<     end;
---
>     }};
2866c2865
<     end;
---
>     }};

```

# Тестирование

Тестовый пример:

```pascal
program Hello;

begin
  WriteLn('Hello, student!');
end.
```

Вывод тестового примера на `stdout`

```
Hello, student!
```

# Вывод
В ходе выполнения лабораторной работы я освоил принципы раскрутки самоприменимых компиляторов 
на примере компилятора BeRo Tiny Pascal. Были успешно внесены изменения в исходный код компилятора
 для поддержки альтернативного синтаксиса с заменой ключевых слов begin и end на {{ и }}, 
после чего проведён полный цикл раскрутки, подтвердивший корректность внесённых изменений. 
Полученные навыки позволяют глубже понять архитектуру компиляторов
 и методологию их развития через механизм самоприменения.
