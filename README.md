A small Rails app that handles encryption keys for Oase.

## Running with Docker (preferred)

```
docker network create oase-network
docker compose -f docker-compose.dev.yaml up -d
```

The KMS will now be available on http://localhost:4000 and should be able to reach the mainframe on the docker network `oase-network`.

## Installation

You need a working Ruby environment with Ruby on Rails installed. You also need a working PostgreSQL database.

In the database, create a role with create database privileges.

Now run

```
bundle install
rake db:create
rake db:migrate
```

## How it works

An encryption key is tied to an oase.

When the client needs to encrypt or decrypt, it fetches a key directly from the KMS.

In order to validate if the user actually has access to a given key, it first has to get a signed _key request_ from the mainframe.

The mainframe will validate if the user is allowed to get a key for the given oase, and if so, it return a signed key request in the form of af JWT.

This JWT is then sent to the KMS, which will validate the JWT with well knowns from the mainframe, and return the key.

## Gotchas in dev

Because of this setup, we need to know the IP or hostname of both the mainframe and the KMS. In development, we can't use localhost, because when we need to develop on device they won't be able to reach mainframe or KMS.

For now, this is solved by running the mainframe and KMS tied to your computer's IP address. This is not ideal, and really annoying when you change WiFi as you get a new IP, which means you have to update some cols in the db as the IP of the mainframe is stored along with the keys.

A better solution would be very appreciated.
