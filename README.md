Run in PowerShell.

It will download the latest nightly to your system Downloads folder, then extract the zip to the portable software folder you choose at the top of the script. The one I use is simply C:\Software-Portable
Edit line 4 of the script to your prefered location:
$portableDir = "C:\Software-Portable"  # Change to your preferred folder


Example:
PS C:\PS_Scripts .\getOrcaBeta.ps1
Latest Orca Slicer nightly release: OrcaSlicer Nightly Builds
Latest asset: OrcaSlicer_Windows_nightly_portable.zip
WARNING: Could not parse build identifier from filename. Falling back to date-based version.
New build detected (nightly-20251230). Downloading OrcaSlicer_Windows_nightly_portable.zip...
Extracting to C:\Software-Portable\OrcaSlicer-nightly-20251230...
Update complete! Orca Slicer nightly (nightly-20251230) ready.
Shortcut: C:\Software-Portable\OrcaSlicer.lnk
