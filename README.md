# IKno

## Deploy to Fly.io

1. Launch
1. Remove node_modules from gitignore
1. Deploy

## Copy Database to Fly.io 

### Copy Local Database

```
pg_dump -F t i_kno_dev > ikno.db
```

### Open Proxy to Database

```
 fly proxy 15432:5432 -a irvine-i-kno-db
```

### Copy Database to Fly.ikno

```
pg_restore -c -U postgres -h localhost -p 15432 -d i_kno < ikno.db
```



## Log into Fly.io db
fly postgres connect -a irvine-i-kno-db