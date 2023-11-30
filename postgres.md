# PostgreSQL

This is for Ubuntu

## Basic Install Steps

```
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql.service
```

## Create DB, add user to DB

First, we add a user into Postgres itself:;

```
sudo -i -u postgres

# now logged in to ubuntu as postgres
createuser --interactive
```

To create a DB

```
createdb my_database_name
```

We also need to add the user in Linux. As the original user (i.e. NOT `postgres`). Replace `kiryuu` with whatever you want.

```
sudo adduser kiryuu
```

Update password for user in Postgres

```
sudo -i -u kiryuu
psql
\password
```

### Misc

Reload prometheus via:

```
kill -s SIGHUP (PID)
```

### References

https://www.digitalocean.com/community/tutorials/how-to-install-postgresql-on-ubuntu-20-04-quickstart