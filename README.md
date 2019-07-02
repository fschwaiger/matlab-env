.env.matlab
===========

In web development, there used to be several configuration files installed on each production server.
With the advent of cloud services, a persistent file system might not be available. Small micro-services
can be deployed and configured from pre-packed images (e.g. Docker) to scale up horizontally in short time.
These services usually come with some sort of base configuration, but credentials for related services
(e.g. a shared database) cannot be stored in the images. They must be provided at run-time through
environment variables.

So, in a production environment you usually want to configure your application through the environment,
but during devlopment it is quicker to share a default configuration through a file (e.g. `.env`).
This utility presents an easy way to read environment variables from three different sources.


What it does
------------

This function allows to quickly access environment values and falls back to definitions in a local `.env` file.
This work is inspired by functionality common in web development.

It reads values from three sources in the following order:
1) System environment (getenv)
2) MATLAB preferences (getpref)
3) `.env` file on the path

Access to the `.env` file is cached, so subsequent calls do not impact performance as much.
The cache is invalidated whenever the `.env` file is modified on disk.


Example Usage
-------------

```matlab
dbHost = env('DATABASE_PATH', '127.0.0.1'); % fallback if undefined
dbUser = env('DATABASE_USER');              % fail if undefined
dbPass = env('DATABASE_PASS');              % fail if undefined
```

This will read the database host from either of the three sources, and if not specified, default to localhost.
With no defaults given for username and password, the subsequent calls will raise errors if there is no
value defined for username or password. This ensures you specify concisely whether you expect to be able to
continue if no value has been defined. Of course you can specify an empty default value.


Example `.env` file
-------------------

```ini
DATABASE_HOST = 127.0.0.1
DATABASE_USER = root
DATABASE_PASS = slw48r3qz5tq9zn8

THIS_BECOMES_A_LIST = {first,second,and third item}
THIS_BECOMES_A_DOUBLE = 42
THIS_STAYS_A_STRING = "42"
THIS_ALSO_STAYS_A_STRING = '42'
```
