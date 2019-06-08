# karlsquell maintenance scripts: demo of rom-rb and dry-rb

This is real production code ... spiced up with [dry-rb](https://dry-rb.org/) and [rom-rb](https://rom-rb.org) :)

The task was to write a maintenance script to clean up the database of legacy system, running ruby 1.8.6 and mysql 5.0.17. So unfortunately I couldn't use neither `dry-rb` nor `rom-rb`. But I tried to mimic some of the patterns I've developed using these gems. So I ended up with a `lib` directory ... at least: I've also learned a lot about the garbage collector of ruby 1.8.6. This was great fun!

After I was done, I decided to use my docker setup and upgrade the code `dry-rb` and `rom-rb`. As one can see, the structure of the files hasn't changed that much, but they are more terse and easier to grasp ... at least if you like monads.

## Setup

```
git clone https://github.com/yuszuv/karlsquell.git
mkdir private
cp /path/to/database_dump.sql ./private
```

Then run docker setup (see below), login to docker container and import dump with `db.sh < /private/database_dump.sql`

## Usage

### Development

Run docker shell (see below) and then run `bin/karlsquell <command-of-choice>`

For available subcommands and further help, see `bin/karlsquell --help`.

Log files are saved at `log/`.

### Production

Copy `code/` to the server, run the script `bin/karlsquell` providing the database credentials as environment variables:

```
USER=<user> PASSWORD=<password> HOST=<host> bin/karlsquell <subcommand> [OPTIONS]
```

## Docker setup

You should have `docker` and `docker-compose` resp installed.

```
$ cd docker/
$ docker-compose build # bundle ruby-2.6.1 and mysql-5.0.11
```

After that, you can get a shell and play around:

```
$ docker-compose run shell
```

* Your working directory is `/app`. This directory contains all the ruby code
* There is directory at `/private`. This is supposed to hold private data like a database dump

You can import database data by copying a dump (locally) to the directory `private/`. After that can run (at the docker shell):
```
$ db.sh < /private/<filename>
```
