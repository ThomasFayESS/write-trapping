# Epics control access
A simple example to test control access on epics

# testAccess.sh script
Provides a simple test script to test that write trapping for a given pv list.
For each supported EPICS record type a pre-defined set of fields that are interesting for protection purposes.
This script will check for each of the PVs in the input list file whether each predefined field has write trapped or free write access.
The specific implementation is that the current value of the field is fetched and the written back down to the PV field using both 'Channel Access' and 'PV Access' protocols.
 A message is flagged to the user for each instance (CA or PVA) where write access is trapped.
