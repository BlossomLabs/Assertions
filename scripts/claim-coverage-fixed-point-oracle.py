#!/usr/bin/env python3
"""Independent finite-word quantized rational oracle; does not read Solidity or promise real-function accuracy."""
import json
WORD=1<<256;HALF=1<<255;Q=1<<96;LN2=54916777467707473351141471128
LOW=-42139678854452767551;HIGH=135305999368893231589
def unsigned(v):return v%WORD
def signed(v):v%=WORD;return v if v<HALF else v-WORD
def trunc(a,b):
    if b==0:raise ZeroDivisionError
    q=abs(a)//abs(b);return -q if (a<0)!=(b<0) else q
def left(v,n):return 0 if n>=256 else unsigned(v<<n)
def right(v,n):return 0 if n>=256 else unsigned(v)>>n
def sar(v,n):return (-1 if v<0 else 0) if n>=256 else v>>n
def horner(x,seed,coefficients):
    for c in coefficients:seed=signed(sar(signed(x*seed),96)+c)
    return seed
def exp(v):
    if v<=LOW:return {'value':0}
    if v>=HIGH:return {'panic':17}
    z=signed(trunc(signed(left(v,78)),5**18));k=sar(signed(trunc(signed(left(z,96)),LN2)+Q//2),96);x=signed(z-signed(k*LN2))
    y=horner(x,signed(x+1346386616545796478920950773328),[57155421227552351082224309758442])
    p=horner(y,signed(signed(y+x)-94201549194550492254356042504812),[28719021644029726153956944680412240]);p=signed(signed(p*x)+signed(left(4385272521454847904659076985693276,96)))
    q=horner(x,signed(x-2855989394907223263936484059900),[50020603652535783019961831881945,-533845033583426703283633433725380,3604857256930695427073651918091429,-14423608567350463180887372962807573,26449188498355588339934803723976023])
    if q==0:return {'panic':18}
    return {'value':signed(right(unsigned(signed(trunc(p,q)))*3822833074963236453042738258902158003155416615667,unsigned(signed(195-k))))}
def ln(v):
    if v<=0:return {'undefined':v}
    log=v.bit_length()-1;k=signed(log-96);x=signed(right(signed(left(v,unsigned(signed(159-k)))),159))
    p=horner(x,signed(x+3273285459638523848632254066296),[24828157081833163892658089445524,43456485725739037958740375743393,-11111509109440967052023855526967,-45023709667254063763336534515857,-14706773417378608786704636184526]);p=signed(signed(p*x)-signed(left(795164235651350426258249787498,96)))
    q=horner(x,signed(x+5573035233440673466300451813936),[71694874799317883764090561454958,283447036172924575727196451306956,401686690394027663651624208769553,204048457590392012362485061816622,31853899698501571402653359427138,909429971244387300277376558375])
    if q==0:return {'panic':18}
    r=signed(trunc(p,q));r=signed(r*1677202110996718588342820967067443963516166);r=signed(r+signed(16597577552685614221487285958193947469193820559219878177908093499208371*k));r=signed(r+600920179829731861736702779321621459595472258049074101567377883020018308)
    return {'value':sar(r,174)}
