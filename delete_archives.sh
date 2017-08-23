#!/bin/bash
#"script to delete postgres archive files on primary, run this script on primary db"
PGDATADIR=/var/untd/pgsql/data
PGARCHIVEDIR=/var/untd/pgsql/archive
#"we are going to delete archives 1 day older than current replay_location on standby db"
THRESHOLD=1

#"Use min(replay_location) if more than one standby is configured"
CURRLOGFILE=`psql -h "localhost" -U "postgres" -At -c "select pg_xlogfile_name(replay_location) from pg_stat_replication;" postgres`

if [ -z "$CURRLOGFILE" ]
then
echo "Standby is down or not yet configured"
else
ls -lrt $PGARCHIVEDIR/$CURRLOGFILE > /dev/null 2>&1
        if [ $? -eq 0 ]
        then
        #"archive found in archive_dir"
        LOGFILEDATE=`date -r $PGARCHIVEDIR/$CURRLOGFILE`
        DELETEDATE=`date -d "$LOGFILEDATE - $THRESHOLD days" +%Y%m%d%H%M.%S`
                if [ -f $PGARCHIVEDIR/delete.file ]
                then
                rm $PGARCHIVEDIR/delete.file
                touch -t $DELETEDATE $PGARCHIVEDIR/delete.file
                else
                touch -t $DELETEDATE $PGARCHIVEDIR/delete.file
                fi
        find $PGARCHIVEDIR/000* ! -newer $PGARCHIVEDIR/delete.file -type f -exec /bin/rm {} \;
        else
        #"archive not found in archive_dir"
        ls -lrt $PGDATADIR/pg_xlog/$CURRLOGFILE > /dev/null 2>&1
                if [ $? -eq 0 ]
                then
                #"archive found in data_dir"
                LOGFILEDATE=`date -r $PGDATADIR/pg_xlog/$CURRLOGFILE`
                DELETEDATE=`date -d "$LOGFILEDATE - $THRESHOLD days" +%Y%m%d%H%M.%S`
                        if [ -f $PGARCHIVEDIR/delete.file ]
                        then
                        rm $PGARCHIVEDIR/delete.file
                        touch -t $DELETEDATE $PGARCHIVEDIR/delete.file
                        else
                        touch -t $DELETEDATE $PGARCHIVEDIR/delete.file
                        fi
                find $PGARCHIVEDIR/000* ! -newer $PGARCHIVEDIR/delete.file -type f -exec /bin/rm {} \;
                fi
        fi
fi
