# Inventory Rollup

## Contents

- [Description](#description)
- [Requirements](#requirements)
- [Version Numbers](#version-numbers)
- [Installation](#installation)
- [Usage](#usage)
- [Copyright and License](#copyright-and-license)


## Description

A Perl script for processing an exported usage report to populate/update a database to allow viewing the data in multiple ways.

Like as not this will be of value to nobody, and in time not even to myself.

On Monday I'm expected to place a restocking order for my warehouse. I've no clue what usage levels exist, or have existed, leading to being clueless as to how much to order. The system software has very few reports, at my access level anyway, and only one way to view them. One report which can hold, after a few runs, all the data I think I need is able to be exported to Excel. This is a step in digesting that Excel data and placing it in a MySQL database.

[TOP](#contents)

## Requirements

- Working install of Perl
- Access to a MySQL/MariaDB database, including the ability to create new databases
- Excel or any spreadsheet program able to read `.xlsx` files
- Probably a GNU/Linux system, as this has not been tried in Windows or Mac


[TOP](#contents)

## Version Numbers

Inventory Roller uses [Semantic Versioning v2.0.0](https://semver.org/spec/v2.0.0.html) as created by [Tom Preston-Werner](http://tom.preston-werner.com/), inventor of Gravatars and cofounder of GitHub.

Version numbers take the form `X.Y.Z` where `X` is the major version, `Y` is the minor version and `Z` is the patch version. The meaning of the different levels are:

- Major version increases indicates that there is some kind of change in the API (how this program works as seen by the user) or the program features which is incompatible with previous version

- Minor version increases indicates that there is some kind of change in the API (how this program works as seen by the user) or the program features which might be new, while still being compatible with all other versions of the same major version

- Patch version increases indicate that there is some internal change, bug fixes, changes in logic, or other internal changes which do not create any incompatible changes within the same major version, and which do not add any features to the program operations or functionality

[TOP](#contents)

## Installation

Without the need to link to any system libraries, or install any, the program can be "installed" anywhere, including the user's home directory. A simple option is to make a new folder in the user's home directory and place all the files there. The `rollup.pl` file, of course, needs to be set as executable, `chmod u+x rollup.pl` for it to be used as a command.

The `startup.sql` file can be executed from within the MySQL command line client, using the `source` command or directly from the shell using redirection

```
MariaDB [(none)]> source startup.sql
```

or

```
> mysql -u root -p <startup.sql
```

[TOP](#contents)

---

## Usage

The basic usage is:
```
> rollup <filename.csv>
```
run at least twice, or in multiples of two times. The available reports group the inventory into a pair of categories, each with their own report, and report versions. The report tool is also limited to 45 days and I wanted a larger window, requiring the pair of reports twice, as well as a couple pair of targeted reports for out-of-office techs.

Once all the official reports have been processed all that remains is to read the database. The `summary_report.sql` file has a good, for me, return set. Using it could be done:
```
mysql -u inventory -p -DINVENTORY_USAGE <summary_report.sql >summary_report.csv
```

The actual work, for the user, is preparing the reports for Perl to read. It's actually a simple, if manual, process. Being to lazy to use the Perl modules for reading Excel files for what I expect to be a one-off or short-lived project I used Excel itself to convert the files. The only tricky part is finding a character for separating the fields which is reasonably unlikely to be in the source data. The commma, as normally used, is almost guaranteed to be in the data. I settled on `þ`, and that's what is in the script. If a different character is used, the script needs to be updated in one place, line 82, with the new character.

The process is (using LibreOffice setting, Excel might be differently labeled while being the same):

1.  Export the report using the official tool
2.  Load the report in Excel
   -  Make sure that the dates are displayed in` MM/DD/YYYY` or `[M]M/[D]D/[YY]YY` format
3.  Save a copy in Text CSV (.csv) format
   -  Set the 'Field delimiter' as choosen
   -  Ignore the 'String delimiter' (it won't be used)
   -  Check 'Save cell content as shown'
   -  Clear 'Save cell formulas instead of calculated values'
   -  Clear 'Quote all text cells'  !! **Important** !!
   -  Clear 'Fixed column width'
4.  Run import against the saved `.csv` file
5.  Repeat for each report needed (Each report can be processed in steps 1 - 4, or step 1 for all reports then step 2 for each, etc.)
6.  Read the database, using any tool you like, to get the data needed.
  -  The `summary-report.sql` file is the one that works for me.
7.  (Optional) Import the data (from the ouput command above) into Excel to sort and shuffle
  -  Importing the CSV from the MySql output requires changing the Excel import options so that the `TAB` is the only separator and all other options are off.
  -  Saving the import as an Excel file `.xls` or `.xlsx` will avoid having to import it again.

[TOP](#contents)

## Configuration

The only configuration possible is to change the separator character for fields in the `.csv` file. Use the same character when saving as `Text CSV(.csv)` in Excel and in the `rollup.pl` file at line 82.


[TOP](#contents)

## Copyright and License

Copyright © 2022 Chindraba (Ronald Lamoreaux)
                 <[projects@chindraba.work](mailto:projects@chindraba.work?subject=Inventory%20Rollup)>
- All Rights Reserved

### The MIT License

    Permission is hereby granted, free of charge, to any person
    obtaining a copy of this software and associated documentation
    files (the "Software"), to deal in the Software without restriction,
    including without limitation the rights to use, copy, modify, merge,
    publish, distribute, sublicense, and/or sell copies of the Software,
    and to permit persons to whom the Software is furnished to do so,
    subject to the following conditions:

    The above copyright notice and this permission notice shall be
    included in all copies or substantial portions of the Software

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGE-
    MENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
    FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
    CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
    WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

[TOP](#contents)
