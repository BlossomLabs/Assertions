#!/usr/bin/env python3
"""Generate complete actual fold callback receipt controls before flag dispatch."""
import argparse,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args()
 for name in ('nonempty','empty'):subprocess.run([sys.executable,'-B',HERE/('generate-'+name+'.py'),'--output',a.output],check=True)
