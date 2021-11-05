# Databases 102

Tips, Tricks and Theory for the Working Professional

## Running This Code

Prerequisites

- Python 3 / pip
- Docker / docker-compose v2
- Git

Steps:

1. Clone this repo

    ```
    $ git clone git@github.com:droberts-sea/databases-workshop.git
    $ cd databases-workshop
    ```

1. Run the database via docker-compose

    ```
    $ docker-compose up
    ```

    This will eat the terminal tab - keep it running in the background forever

    If you want to connect to the DB directly, you can do so with:

    ```
    $ PGPASSWORD=password psql -h localhost -p 5432 -U postgres -d star-engine
    ```

1. (In a new terminal tab) Spin up a virtual environment and install Python dependencies

    ```
    $ python3 -m venv venv
    $ source venv/bin/activate
    $ pip install requirements.txt
    ```

1. Apply database migrations via [yoyo migrations](https://ollycope.com/software/yoyo/latest/)

    ```
    $ yoyo apply --batch
    ```

1. Populate DB with test data

    ```
    $ python src/populate_db.py
    ```

## Legal

This workshop was developed by Dan Roberts in November 2021.

It is based on a modified version of a project I worked on while employed at Remitly. While some of the algorithms and approaches demonstrated here may be partially inspired by the design we implemented at Remitly, I have been extremely careful about keeping this project separate from Remitly's IP:

- I did not access code owned by Remitly while working on this project
- I did the work on equipment owned by me
- I did not use any of Remitly's data, systems, software, or other digital assets while working on this project
- An examination of the codebases, tables, queries, etc of the two projects will show them to be extremely different

The code in this repository is governed by the MIT license (see [LICENSE](./LICENSE)).

The [accompanying slide deck](https://docs.google.com/presentation/d/1pYIafgco8wUiHcvu7AhHHaOo8Q1GdbmpRPG641uyhJ0) is [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/).
