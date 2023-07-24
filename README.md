# Employee Monorepo

This application acts as a read and write API for employee records.

## Instructions

### Prerequisites

#### Clone the repository

If you want to use ssh and have not already enabled it, follow these
[instructions](https://docs.github.com/en/authentication/connecting-to-github-with-ssh).

Then open a terminal, navigate to the directory of your choice, and type:

```bash
git clone git@github.com:vancourtj/employee_monorepo.git
```

#### rbenv

Make sure you have rbenv installed. This project used 1.1.1.

Type in the same terminal:

```bash
rbenv -v
```

If you do not have rbenv installed, follow these [instructions](https://github.com/rbenv/rbenv#installation).

#### Ruby

This project used Ruby [3.1.4](https://www.ruby-lang.org/en/news/2023/03/30/ruby-3-1-4-released/).

Check your Ruby installation:

```bash
ruby -v
```

If you do not have ruby installed or the correct version, type:

```bash
rbenv install 3.1.4
rbenv local 3.1.4
```

#### Bundler

Make sure you have bundler installed. This project used 2.4.17.

Type:

```bash
bundler -v
```

If you do not have bundler installed, use this command:

```bash
gem install bundler
```

Install the gems for this project:

```bash
bundle install
```

#### npm

Make sure you have npm installed. This project used 8.19.2.

Type:

```bash
npm -v
```

If you do not have npm installed, follow these [instructions](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm).

#### yarn

Make sure you have yarn installed. This project used 1.22.19.

Type:

```bash
yarn -v
```

If you do not have yarn installed, use this command:

```bash
npm install --global yarn
```

Then run:

```bash
yarn install
```

#### PostgreSQL

Make sure you have PostgreSQL installed. This project used 12.15 on Ubuntu.

Type in the same terminal:

```bash
psql --version
```

If you do not have PostgreSQL installed, follow these [instructions](https://www.postgresql.org/download/).

### Running the Application

#### Setting the database environment variables

Depending on your local PostgreSQL setup, you may need a username and password to connect to the database.

Those can be set in the `.env` file with `POSTGRES_USERNAME` and `POSTGRES_PASSWORD`. If you do not need them set,
you can go to `config/database.yml` and remove the username and password configuration.

#### Setting up the database encryption

You need to be able to decrypt `config/credentials.yml.enc`. Rails will use the master key in `config/master.key`.

This repository already has a credentials file, so you'll need the correct master key to use it unless you would
like to remake the credentials file.

You can do that by:

Running the following to generate keys for encryption:

```bash
bin/rails db:encryption:init
```

Those keys need placed in `config/credentials.yml.enc`.

Running the following will create a credentials file if one does not exist.
It will also create config/master.key if no master key is defined.

```bash
./bin/rails credentials:edit
```

Read more from the official docs [here](https://guides.rubyonrails.org/active_record_encryption.html)
and [here](https://guides.rubyonrails.org/security.html#custom-credentials).

Note: you may be prompted to run the command as: `EDITOR="code --wait" bin/rails credentials:edit` instead.

#### Setting up the database

```bash
./bin/rails db:create
./bin/rails db:migrate
```

#### Seeding the database with test data

```bash
./bin/rails db:seed
```

#### Running the server

```bash
./bin/dev
```

### Running the test suite

```bash
bundle exec rspec
```

## API routes and params

I recommend using a tool like [Postman](https://www.postman.com/) to submit requests. You'll need the desktop client to hit localhost.

- GET `http://localhost:3000/api/v1/employees` to query all employee records
  - no params will query all of the employee records
  - the default sort is `date_of_employment asc`
  - allowed params for filtering the data. Must be nested under keyword `query`
    - `department_eq` an exact match on an employee's department
    - `title_eq` an exact match on an employee's title
    - `salary_cents_eq` an exact match on an employee's salary in cents
    - `salary_cents_lt` employees with a salary in cents less than the specified value
    - `salary_cents_gt` employees with a salary in cents greater than the specified value
    - `salary_cents_lteq` employees with a salary in cents less than or equal to the specified value
    - `salary_cents_gteq` employees with a salary in cents greater than or equal to the specified value
  - allowed params for sorting the data. Must be nested under keyword `sort`
    - `date_of_employment` accepts either `asc` or `desc`
    - `salary_cents` accepts either `asc` or `desc`
  - example param structure
    ```json
    {
      "query": {
        "department_eq": "Operations",
        "salary_cents_lteq": 2500000,
        "salary_cents_gteq": 5000000
      },
      "sort": {
        "date_of_employment": "desc"
      }
    }
    ```

    This will return all employees in the "Operations" department with "$25,000.00 <= salary <= $50,000.00" sorted by date of employment descending.

- POST `http://localhost:3000/api/v1/employees` to create new employees
  - required creation params. Must be nested under keyword `data`
    - `first_name`
    - `last_name`
    - `title`
    - `department`
    - `date_of_employment`
    - `date_of_birth`
    - `salary_cents`
  - example param structure
    ```json
    {
      "data": {
        "first_name": "George",
        "last_name": "Washington",
        "title": "POTUS",
        "department": "Executive Branch",
        "date_of_birth": "1732-02-22",
        "date_of_employment": "1789-04-30",
        "salary_cents": 2500000
      }
    }
    ```
- GET `http://localhost:3000/api/v1/employees/<id>` to query a specific employee
- PUT/PATCH `http://localhost:3000/api/v1/employees/<id>` to update a specific employee
    - allowed params. Must be nested under keyword `data`
      - `first_name`
      - `last_name`
      - `title`
      - `department`
      - `date_of_employment`
      - `date_of_birth`
      - `salary_cents`
    - example param structure
      ```json
      {
        "data": {
          "first_name": "Bob"
        }
      }
      ```

      This will update the specified employee's name to "Bob"
- DELETE `http://localhost:3000/api/v1/employees/<id>` to destroy a specific employee