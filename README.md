# Databases 102

Tips, Tricks and Theory for the Working Professional

## Running This Code

Prerequisites

- Python 3 / pip
- Docker / docker-compose v2
- Git

1. Clone this repo

    ```
    $ git clone git@github.com:droberts-sea/databases-workshop.git
    $ cd databases-workshop
    ```

2. Run the database via docker-compose

    ```
    $ docker-compose up
    ```

    This will eat the tab - keep it running in the background forever

3. Spin up a virtual environment and install Python dependencies

    ```
    $ python3 -m venv venv
    $ source venv/bin/activate
    $ pip install requirements.txt
    ```