Intro to R - Relational Data
================
A.Kirkham
10/02/2020

# Introduction

This guide to relational data has been built following slides from the
NHS-R community at:  
<https://github.com/nhs-r-community/intro_r/blob/master/07-workshopv2_joins.pdf>

The below code and output are generated from following these slides.

All of the resources used here are found on the NHS-R Community Github
pages: <https://github.com/nhs-r-community/intro_r>

**Now follows a workthrough of the slides.**

## Relational Data

It is rare to find all of the data you require for an analysis within a
single table.

Typically you will have to link two (or more) tables together by
matching on common “key” variables.  
\- Joins in SQL.

The main focus here will be on left (outer) joins.  
The syntax is similar for other types of joins.

## Left Join

``` r
table_1 %>%
  left_join(table_2, by = "x")
```

Where we:  
1: Keep the structure of table\_1  
2: … and match to observations in table\_2  
3: With a “key” variable (common to both tables).

We’re going to join two tables - one with cases of tuberculosis by
country, one with population by country.  
From this new table we can derive a rate.

Import: `tb_cases.csv`, and `tb_pop.csv`.

``` r
library(tidyverse)
library(readr)
tb_cases <- read_csv("tb_cases.csv")
tb_popul <- read_csv("tb_pop.csv")
```

Then we can do the following, whilst ensuring that we:  
1: Keep the structure of the `tb_cases` data frame;  
2: Match to rows in `tb_popul`;  
3: Based on “country”

``` r
tb_cases %>%
  left_join(tb_popul, by = "country")
```

    ## # A tibble: 64 x 5
    ##    country     year.x  cases year.y        pop
    ##    <chr>        <dbl>  <dbl>  <dbl>      <dbl>
    ##  1 Afghanistan   1999    745   1999   19987071
    ##  2 Afghanistan   1999    745   2000   20595360
    ##  3 Afghanistan   1999    745   2001   21347782
    ##  4 Afghanistan   1999    745   2002   22202806
    ##  5 Brazil        1999  37737   1999  172006362
    ##  6 Brazil        1999  37737   2000  174504898
    ##  7 Brazil        1999  37737   2001  176968205
    ##  8 Brazil        1999  37737   2002  179393768
    ##  9 China         1999 212258   1999 1272915272
    ## 10 China         1999 212258   2000 1280428583
    ## # ... with 54 more rows

**But, oh no\! Duplicates\!**  
For every value of Brazil in tb\_cases there are four in `tb_popul`…

### Join on multiple rows

Using the vector syntax that we discussed in the Addendum of
Intro\_to\_R\_dplyr we can combine multiple matching variables for the
join.

``` r
tb_cases %>%
  left_join(tb_popul, by = c("country", "year"))
```

    ## # A tibble: 16 x 4
    ##    country      year  cases        pop
    ##    <chr>       <dbl>  <dbl>      <dbl>
    ##  1 Afghanistan  1999    745   19987071
    ##  2 Brazil       1999  37737  172006362
    ##  3 China        1999 212258 1272915272
    ##  4 Denmark      1999    170    5319410
    ##  5 Afghanistan  2000   2666   20595360
    ##  6 Brazil       2000  80488  174504898
    ##  7 China        2000 213766 1280428583
    ##  8 Denmark      2000    171    5338283
    ##  9 Afghanistan  2001   4639   21347782
    ## 10 Brazil       2001  37491  176968205
    ## 11 China        2001 212766 1287890449
    ## 12 Denmark      2001    124    5354684
    ## 13 Afghanistan  2002   6509   22202806
    ## 14 Brazil       2002  40723  179393768
    ## 15 China        2002 194972 1295322020
    ## 16 Denmark      2002    135    5368994

### Joining with different names

If two tables have **different names** for the **same variable**:

``` r
tb_cases %>%
  left_join(bad_names, by = c("country" = "Place", "Year" = "yr"))
# This won't run of course - it is fictional data. The left side of the = is the originating table (cases), whereas the right side of the = relates to the joining table (bad_names).
```

## Other dplyr joins

Some other dplyr joins include:

  - dplyr::right\_join(a,b,by=“x1”)
      - Join matching rows from a to b.
  - dplyr::inner\_join(a,b,by=“x1”)
      - Join data. Retain only rows in both sets.
  - dplyr::full\_join(a,b,by=“x1”)
      - Join data. Retain all values, all rows.
