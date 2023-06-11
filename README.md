# IKno

## Copy Database to Fly.io 

### Copy Local Database
```
cd priv/repo
pg_dump -a -Fc -t subjects -t topics -t prereq_topics -t subject_admins i_kno_dev > ikno.db
```

### Open Proxy to Database
```
 fly proxy 15432:5432 -a irvine-i-kno-db
```

### Login to Fly.io DB and Set Replication Role
```
fly postgres connect -a irvine-i-kno-db

\c irvine_i_kno
SET session_replication_role = 'replica';
delete from topics; delete from subjects; delete from prereq_topics; delete from subject_admins;
```

### Copy Database to Fly.ikno
```
KiHg7zWMbiiUhvJ
pg_restore -U postgres -h localhost -p 15432 -d irvine_i_kno < ikno.db
```

### Set Replication Role Back to Origin
```
SET session_replication_role = 'origin';
```