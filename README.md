# README

A very simple but quick CSV parser which currently transforms dates from
dd-mm-yyyy into yyyy-mm-dd in CSV files with this structure: EMAIL;DATE;DATE.
With a bit of Elixir knowledge it can easily be rewritten to do other (one time)
CSV parsing tasks.

## Usage

### Show help

```shell
./csv_parser [-h | --help]
```

### Parse a file

```shell
./csv_parser data/in/input.csv
```
