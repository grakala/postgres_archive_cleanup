# postgres_archive_cleanup
==========================
``delete_archives.sh`` - Delete postgres archive logs on primary based on current xlog being applied on standby db.

Syntax
======

::

Usage:
delete_archives.sh

Set Variables *PGDATADIR*, *PGARCHIVEDIR*, *THRESHOLD* in the script.
