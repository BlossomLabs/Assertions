#!/usr/bin/env python3
"""Fresh selected module only after actual predecessor terminal completion."""
import datetime,json,subprocess,time
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
WAIT=ROOT/'formal/bytecode/word-fold/raw-closure-repair-v9/development/closure-native-v9/manifest.json'
OUT=HERE/'development/confirmation-after-v9-v1'
def main():
 OUT.mkdir(parents=True,exist_ok=False);m=dict(status='waiting-for-actual-v9-native-terminal-no-restart',startedAt=datetime.datetime.now(datetime.timezone.utc).isoformat(),predecessor=str(WAIT.relative_to(ROOT)),scope='Fresh complete same-source raw-window confirmation; no active process changed and no public credit.')
 def save():(OUT/'results.json').write_text(json.dumps(m,indent=2)+'\n')
 def stop(reason):m.update(status='preserved-required-gate-failure',failure=reason,completedAt=datetime.datetime.now(datetime.timezone.utc).isoformat());save();raise SystemExit(reason)
 save()
 while True:
  try:prior=json.loads(WAIT.read_text())
  except (FileNotFoundError,json.JSONDecodeError):time.sleep(10);continue
  if prior.get('completedAt'):break
  time.sleep(10)
 if not prior['inputsUnchanged']or not prior['toolsUnchanged']:stop('Predecessor source or tool drift; do not reuse')
 native=HERE/'development/native-v1';assert not native.exists(),'Preserve every previous native output';command=['python3','-B',str(HERE/'development-run.py'),'--dafny','/tmp/assertions-dafny-4.11.0/dafny/dafny','--output',str(native),'--workers','1'];m.update(status='fresh-whole-current-window-native-running',command=command);save()
 with (OUT/'native.log').open('w')as stream:
  process=subprocess.Popen(command,cwd=ROOT,stdout=stream,stderr=subprocess.STDOUT);code=process.wait()
 result=json.loads((native/'manifest.json').read_text());m.update(exitCode=code,manifest=str((native/'manifest.json').relative_to(ROOT)),nativeStatus=result['status'],nativeObligations=result.get('nativeObligations'));save()
 if code!=0 or result['status']!='development-native-passed-not-retained':stop('Fresh whole native window confirmation failed; structural repair required')
 m.update(status='fresh-whole-current-window-native-passed-not-retained',completedAt=datetime.datetime.now(datetime.timezone.utc).isoformat());save();print(m['status'],flush=True)
if __name__=='__main__':main()
