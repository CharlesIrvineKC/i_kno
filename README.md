# IKno

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Copy Database to Fly.io 

### Copy Local Database

```
pg_dump -c -F t i_kno_dev > ikno.db
```

### Open Proxy to Database

```
 fly proxy 15432:5432 -a i-kno-db
```

### Copy Database to Fly.ikno

```
pg_restore -U postgres -h localhost -p 15432 -d i_kno < ikno.db
```