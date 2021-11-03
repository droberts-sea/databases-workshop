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