A small Rails app that handles encryption keys for Oase.

## Installation

You need a working Ruby environment with Ruby on Rails installed. You also need a working PostgreSQL database.

In the database, create a role with create database privileges.

Now run

```
bundle install
rake db:create
rake db:migrate
```
