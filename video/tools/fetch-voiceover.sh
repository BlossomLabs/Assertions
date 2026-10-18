#!/bin/sh
# Download the narration clips pinned on IPFS (voiceover/CID) and check them
# against voiceover/SHA256SUMS. Clips already present are kept.
#   sh tools/fetch-voiceover.sh
set -e
cd "$(dirname "$0")/../voiceover"
cid=$(cat CID)
for n in 01 02 03 04 05 06 07 08 09 10; do
  [ -f "$n.mp3" ] && continue
  for gateway in https://gateway.pinata.cloud https://dweb.link https://ipfs.io; do
    curl -sfL --max-time 120 -o "$n.mp3" "$gateway/ipfs/$cid/$n.mp3" && break
    rm -f "$n.mp3"
  done
  [ -f "$n.mp3" ] || { echo "could not fetch $n.mp3 from $cid" >&2; exit 1; }
done
sha256sum --quiet -c SHA256SUMS
