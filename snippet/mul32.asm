; Multiply HL * DE giving result in HLDE
; Input: HL, DE as factors
; Output: HLDE  as product
; registers A,B, C and A' are corrupted.
; 
; This is the concept:
;    HL 
;    DE
;  ----  
;    Ww      Ww:=E*L   
;   Xx      Xx:=E*H      
;   Yy      Yy:=D*L  cTt:=Xx+Yy   cSs:=Xx+Yy+0W 
;  Zz      Zz:=D*H   A:=Z+c       Uu:=Az+S 
;  ----
;  Uusw
                                ;                         a bc de hl a' 
                                ;                         - -- -- -- -
Mul32:          ld      c,e     ; E                          E DE HL
                ld      b,d     ; D                         DE DE HL 
                ld      d,l     ; de is LE                  DE LE HL
                mul             ; de is E*L                 DE Ww HL
                ld      a,e     ; final E                 w DE W. HL 
                ex      af,af'  ;                           DE W. HL w       
                ld      a,h     ; H                       H DE W. HL w 
                ld      e,c     ; E                       H D. WE HL w
                ld      c,d     ; save W                  H DW .E HL w
                ld      d,h     ; de is HE                H DW HE HL w
                ld      h,b     ; hl is DL                H DW HE DL w
                mul             ; H*E                     H DW Xx DL w
                ex      de,hl   ;                         H DW DL Xx w
                mul             ; D*L                     H DW Yy Xx w 
                add     hl,de   ; H*E + D*L + carryf     cH DW .. Tt w
                ld      e,c     ; restore                cH D. .W Tt w
                ld      d,00    ;                        cH D. 0W Tt w
                ex      af,af'  ;                         w D. 0W Tt Hc
                ld      c,a     ;                         . Dw 0W Tt Hc
                add     hl,de   ; H*E + D*L + W           . Dw .. Ss Hc
                ex      af,af'  ;                        cH Dw .. Ss .
                ld      e,a     ; H                      cH Dw .H Ss .   
                ld      d,b     ; D                      c. .w DH Ss . 
                mul             ;                        c. .w Zz Ss .
                ld      a,0     ;                        c0 .w Zz Ss .
                adc     a,d     ;                        cZ .w Zz Ss .
                ld      d,a     ;                         A .w Az Ss .
                ld      b,l     ;                         . sw Az S. .         
                ld      l,h     ;                         . sw Az .S .
                ld      h,00    ;                         . sw Az 0S . 
                add     hl,de   ;                         . sw .. Uu .
                ld      d,b     ;                         . .w .s Uu .
                ld      e,c     ; final E                 . .. sw Uu .
                
                ret
                
                
                
                
                
                
                
