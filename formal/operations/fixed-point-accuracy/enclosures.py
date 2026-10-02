#!/usr/bin/env python3
"""Lightweight exact-fraction diagnostics for prepared analytic specifications.

Not a universal certificate and not native/formal or EVM verification. The
interpretation as real-function bounds needs the explicitly open series-limit
and normalized-log identity bridges. No floating point or Solidity parsing.
"""
import argparse,hashlib,importlib.util,json
from fractions import Fraction as F
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2];WAD=10**18

def exp_bounds(t,n):
    if 2*abs(t)>n+1:raise ValueError('Geometric exponential-tail domain')
    total=F(0);term=F(1)
    for i in range(n):total+=term;term=term*t/(i+1)
    radius=2*abs(term)
    return total-radius,total+radius

def ln_bounds(y,n):
    if y<=0:raise ValueError('Log domain')
    z=(y-1)/(y+1);term=z;total=F(0)
    for i in range(n):total+=2*term/(2*i+1);term*=z*z
    radius=2*abs(term)/((2*n+1)*(1-z*z))
    return total-radius,total+radius

def scale(k,b):return (k*b[0],k*b[1]) if k>=0 else (k*b[1],k*b[0])

def ln_input_bounds(entry,n):
    log=entry.bit_length()-1
    m=ln_bounds(F(entry,1<<log),n);w=ln_bounds(F(WAD,1<<59),n);two=scale(log-59,ln_bounds(F(2),n))
    return m[0]-w[1]+two[0],m[1]-w[0]+two[1]

def ratio(x):return {'numerator':str(x.numerator),'denominator':str(x.denominator)}

def ceil(x):return -(-x.numerator//x.denominator)

def main():
    p=argparse.ArgumentParser();p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);a=p.parse_args();oracle=a.root/'formal/operations/fixed-point/rational-oracle.py';spec=importlib.util.spec_from_file_location('retained_quantized_oracle',oracle);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
    result={'status':'diagnostic-only-native-not-run','publicCoverageAdded':0,'scope':'Eight concrete exact-fraction sanity diagnostics under open analytic series-limit/normalized-log identification obligations. Not a whole-domain certificate.','assumptions':['Prepared finite-series enclosures have not been native verified.','Series limit existence/identification with real exp/log and normalized logarithm addition/power laws remain open.','Retained quantized oracle supplies exact finite-word point evaluation only; no EVM job is run here.'],'oracleSha256':hashlib.sha256(oracle.read_bytes()).hexdigest(),'vectors':[]}
    for name,entries,terms in [('exp',[-WAD,0,WAD,2*WAD],128),('ln',[1,10**9,WAD,2*WAD],32)]:
        for entry in entries:
            bounds=exp_bounds(F(entry,WAD),terms) if name=='exp' else ln_input_bounds(entry,terms)
            actual=getattr(m,name)(entry)['value'];low=WAD*bounds[0];high=WAD*bounds[1];error=max(abs(F(actual)-low),abs(F(actual)-high))
            result['vectors'].append({'function':name,'entry':str(entry),'terms':terms,'quantizedOutput':str(actual),'conditionalRealOutputUnitsInterval':{'lower':ratio(low),'upper':ratio(high)},'conditionalAbsoluteErrorUnitsUpper':ratio(error),'ceilConditionalAbsoluteErrorUnitsUpper':str(ceil(error))})
    a.output.write_text(json.dumps(result,indent=2)+'\n');print('Prepared 8 exact-fraction point diagnostics; no formal/native/EVM coverage claimed')
if __name__=='__main__':main()
