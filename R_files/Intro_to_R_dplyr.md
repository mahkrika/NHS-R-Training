Intro to R - Wrangling with dplyr
================
A.Kirkham
10/02/2020

# Introduction

This is a guide to wrangling data uing the dplyr() \[dee-ply-r\]
package.

This guide to wrangling with dplyr() has been built following slides
from the NHS-R community at:  
<https://github.com/nhs-r-community/intro_r/blob/master/05-workshopv2_dplyr.pdf>

The below code and output are generated from following these slides.

All of the resources used here are found on the NHS-R Community Github
pages: <https://github.com/nhs-r-community/intro_r>

**Now follows a workthrough of the slides.**

Wrangling data means reshaping or transforming data into a format which
is easier to work with (for later visualisation, modelling, or computing
of statistics).

## Tidyverse

Tidyverse is a group of packages that work in tandem to make processing
and assessing data easier.

Tidyverse functions work best with tidy data:  
1\. Each variable forms a column  
2\. Each observation forms a row  
(Broadly, this means long rather than wide tables)

## The tool: dplyr()

dplyr is a function for data manipulation within the Tidyverse.

Most wrangling can be solved with 5 dplyr verbs:  
**Arrange;**  
**Filter;**  
**Mutate;**  
**Group\_By;**  
**Summarise.**

## Exploring mental health (MH) inpatient capacity

Imagine the situation: We have been asked to conduct an analysis of
Mental Health inpatient capacity in England.

The data: KH03 returns (bed numbers and occupancy) by organisation.  
Published by NHSE:
<https://www.england.nhs.uk/statistics/statistical-work-areas/bed-availability-and-occupancy/bed-data-overnight/>

We will be looking at the changes in the number (and occupancy) of MH
beds available in recent years.

**Background**  
Maintaining clinical effectiveness and safety when a ward is fully
occupied is a serious challenge for staff.

Inappropriate out of area placements mean individuals are separated from
their social networks for the duration of their care.

**Start the data process**

``` r
library(tidyverse)
```

Load the data; **but** use the Import Dataset tool (Environment \>
Import Dataset \> From Text (readr))- this data is not tidy\!

Problem with the data: There is metadata above the data we want as the
headers (“KH03 returns”).  
*Solution is to skip 3 rows*

But, we also note that the data column is currently set as a character.
This needs to be changed to date (%d/%m/%y):

``` r
library(readr)
beds_data <- read_csv("beds_data.csv", col_types = cols(date = col_date(format = "%d/%m/%Y")), 
                      skip = 3)
View(beds_data)
beds_data
```

    ## # A tibble: 4,558 x 5
    ##    date       org_code org_name                              beds_av occ_av
    ##    <date>     <chr>    <chr>                                   <dbl>  <dbl>
    ##  1 2013-09-01 R1A      Worcestershire Health And Care            129    117
    ##  2 2013-09-01 R1C      Solent                                    105     82
    ##  3 2013-09-01 R1E      Staffordshire And Stoke On Trent Par~      NA     NA
    ##  4 2013-09-01 R1F      Isle Of Wight                              54     42
    ##  5 2013-09-01 R1H      Barts Health                               NA     NA
    ##  6 2013-09-01 R1J      Gloucestershire Care Services              NA     NA
    ##  7 2013-09-01 RA2      Royal Surrey County Hospital               NA     NA
    ##  8 2013-09-01 RA3      Weston Area Health                         NA     NA
    ##  9 2013-09-01 RA4      Yeovil District Hospital                   NA     NA
    ## 10 2013-09-01 RA7      University Hospitals Bristol               NA     NA
    ## # ... with 4,548 more rows

(note: `view(beds_data)` loads the dataset and presents it in a new
window for interrogation - not shown here.)

It is worth mentioning at this point that the dataset is “real” in that
it contains data quality issues galore. These are retained, and we will
work with them.

Observations are quarterly.  
*beds\_av* == mean number of beds available at midnight over the 3-month
period.  
*beds\_oc* == as above, occupied.  
Real data - there are problems (NA, etc.)

### Operating dplyr (and tidyverse)

The slides at this point go into greater depth around how a tidyverse
syntax is structured. These probably work better in person than in text;
therefore I will summarise. (Thankfully this is something that I was
already aware of, so it makes it easier to describe).

The slides give a good example, using the cooking of mashed potato:  
We don’t just ‘get’ mashed potato, there are steps involved in the
production of it. A recipe, if you will:  
Get potato \> peel it \> slice it into medium pieces \> boil it for 25
minutes \> mash it.

This is exactly how tidyverse syntax works: We take the data \> do
something with it \> do something else with it \> and finally do
something else with it again.

`data_frame THEN #input do_this(rules) THEN #dplyr verb do_this(rules)
THEN #dplyr verb do_this(rules) #output (new dataframe)`

However, in tidyverse syntax we don’t write THEN we write **%\>%** which
is known as a **pipe**.

This means that we can combine simple pieces to solve complex issues.

The below questions will help to work through the verbs used in dplyr.

### Q1: Which organisation provided the highest number of MH beds?

1.  **arrange** - reorder rows based on a selected variable

<!-- end list -->

``` r
beds_data %>%
  arrange(desc(beds_av)) #defaults to asc like SQL
```

    ## # A tibble: 4,558 x 5
    ##    date       org_code org_name                   beds_av occ_av
    ##    <date>     <chr>    <chr>                        <dbl>  <dbl>
    ##  1 2013-09-01 RHA      Nottinghamshire Healthcare    1050    929
    ##  2 2013-12-01 RHA      Nottinghamshire Healthcare    1002    888
    ##  3 2014-03-01 RHA      Nottinghamshire Healthcare     993    875
    ##  4 2014-06-01 RHA      Nottinghamshire Healthcare     991    857
    ##  5 2015-03-01 RHA      Nottinghamshire Healthcare     977    821
    ##  6 2014-09-01 RHA      Nottinghamshire Healthcare     971    844
    ##  7 2014-12-01 RHA      Nottinghamshire Healthcare     939    829
    ##  8 2015-12-01 RWK      East London                    925    757
    ##  9 2015-09-01 RWK      East London                    919    762
    ## 10 2016-09-01 RWK      East London                    916    770
    ## # ... with 4,548 more rows

### Q2: Which organisations provided the highest number of MH beds in Sept. 2018?

We’ll use **arrange** as in Q1, but also **filter** in order to select
the appropriate data that we need to answer the question.  
Firstly we will take the dataset (beds\_data), then we will filter this
to only examine where the date is Sept. 2018, and finally arrange it by
the availability of beds (mean):

``` r
beds_data %>%
  filter(date == "2018-09-01") %>%
  arrange(desc(beds_av))
```

    ## # A tibble: 207 x 5
    ##    date       org_code org_name                              beds_av occ_av
    ##    <date>     <chr>    <chr>                                   <dbl>  <dbl>
    ##  1 2018-09-01 RWK      East London                               883    753
    ##  2 2018-09-01 RHA      Nottinghamshire Healthcare                831    759
    ##  3 2018-09-01 RV3      Central And North West London             752    679
    ##  4 2018-09-01 RKL      West London                               747    644
    ##  5 2018-09-01 RX3      Tees, Esk And Wear Valleys                722    644
    ##  6 2018-09-01 RXT      Birmingham And Solihull Mental Health     679    658
    ##  7 2018-09-01 RW4      Mersey Care                               603    552
    ##  8 2018-09-01 RX4      Northumberland, Tyne And Wear             594    503
    ##  9 2018-09-01 R1L      Essex Partnership University              585    547
    ## 10 2018-09-01 RX2      Sussex Partnership                        565    547
    ## # ... with 197 more rows

### Q3: Which 5 organisations had the highest percentage occupancy in Sept. 2018?

As above we will continue to use **arrange** and **filter**, but we do
not have all of the necessary information to answer this question. We
require another new verb: **mutate**.

**Mutate** serves to create a new variable by mutating other variables.
In this instance we do not have the percentage occupancy within the
dataset; therefore we will use **mutate** to create it. It is just the
same as creating a new value within SQL. To calculate this figure we
shall have to divide the occupancy average by the average number of
beds. Doing so (using **mutate**) means that we will create a new column
(perc\_occ) which we can then later use in the same query:

``` r
beds_data %>%
  mutate(perc_occ = occ_av / beds_av) %>% # Create new variable perc_occ
  filter(date == "2018-09-01") %>%
    arrange(desc(perc_occ)) # Sort by newly created variable
```

    ## # A tibble: 207 x 6
    ##    date       org_code org_name                     beds_av occ_av perc_occ
    ##    <date>     <chr>    <chr>                          <dbl>  <dbl>    <dbl>
    ##  1 2018-09-01 RAL      Royal Free London                  2      2    1    
    ##  2 2018-09-01 RPG      Oxleas                           384    384    1    
    ##  3 2018-09-01 RRP      Barnet, Enfield And Haringe~     476    468    0.983
    ##  4 2018-09-01 RWV      Devon Partnership                281    276    0.982
    ##  5 2018-09-01 RXT      Birmingham And Solihull Men~     679    658    0.969
    ##  6 2018-09-01 RX2      Sussex Partnership               565    547    0.968
    ##  7 2018-09-01 RP1      Northamptonshire Healthcare      190    183    0.963
    ##  8 2018-09-01 RJ8      Cornwall Partnership             128    123    0.961
    ##  9 2018-09-01 RQ3      Birmingham Women's And Chil~      24     23    0.958
    ## 10 2018-09-01 TAF      Camden And Islington             187    178    0.952
    ## # ... with 197 more rows

Note: Within the above code you will notice that there are multiple
routes of using ‘=’. In the instance of **filter** we are assessing for
equality (we are only choosing rows where this expression is TRUE). In
the instance of **mutate** this is not an assessment of equality but
instead we are stating that the new column is equal to the calculation
rather than obtaining a TRUE/FALSE outcome only.

### Q4: What was the mean number of beds (across all trusts) for each date of value?

A new verb here: **summarise**. We can use **summarise** to produce
summary statistics (like mean), and in doing so collapse many values
into a single summary value.  
It has similar syntax to **mutate** but we are not producing any new
calculations (mutations), we are going to use data that already exists.
We will however still create a new column - again this does not require
**mutate**, we can call a new column/variable at any time without
**mutate** if the data exists in the required form.

``` r
beds_data %>%
  summarise(mean_beds = mean(beds_av)) # Problem! There are NA so this would just produce NA
```

    ## # A tibble: 1 x 1
    ##   mean_beds
    ##       <dbl>
    ## 1        NA

The above code clearly does not work\! This is because there are NA
values within the dataset (the aforementioned data quality issues).
Therefore we need to remove these within the syntax. This is wrangling
of data. We use the command `na.rm = TRUE` (we could just write T
instead of TRUE, it does the same thing) to request that *na* values be
*removed*. Essentially “remove NA? True/False”.

``` r
beds_data %>%
  summarise(mean_beds = mean(beds_av, na.rm = TRUE)) # So we remove the NA
```

    ## # A tibble: 1 x 1
    ##   mean_beds
    ##       <dbl>
    ## 1      300.

The above has given a mean overall, a single summary. Now we need to
group for the each date element. The question specifically asked for the
mean number of beds **for each date**.

The next verb: **group by**. Using the **group by** verb does not
directly do anything to the dataframe, but it does change settings
behind the scenes. In this case we are wanting to group the data by
date, hence we use the syntax `group_by(date)`.

This will result in an output where a value (mean\_beds) is shown for
each date (a row for each unique value of date).

The slides detail that it is best to `ungroup()` after you have
performed the required operation; I don’t know why but I have little
reason to not believe this…

``` r
beds_data %>%
  group_by(date) %>%
  summarise(mean_beds = mean(beds_av, na.rm = T)) %>%
  ungroup() # Safest to ungroup after use
```

    ## # A tibble: 21 x 2
    ##    date       mean_beds
    ##    <date>         <dbl>
    ##  1 2013-09-01      324.
    ##  2 2013-12-01      322.
    ##  3 2014-03-01      319.
    ##  4 2014-06-01      320.
    ##  5 2014-09-01      318.
    ##  6 2014-12-01      315.
    ##  7 2015-03-01      314.
    ##  8 2015-06-01      294.
    ##  9 2015-09-01      296.
    ## 10 2015-12-01      296.
    ## # ... with 11 more rows

# Q5: Which 5 organisations have the highest mean % bed occupancy? (over the 5 year period)

For this it is best to break it down into portions:  
1: Create a new variable **mutate** to determine the ‘% bed
occupancy’.  
2: Then, for each of the organisations **group by**.  
3: Then, produce the summary stat (mean) using **summarise**.  
4: Then, use **arrange** to order the output and find the ‘highest’.  
Tip: Run the code after each new line to check it returns the output
you’d expect.

``` r
beds_data %>%
  mutate(bed_occ = occ_av / beds_av) %>%
  group_by(org_name) %>%
  summarise(mean_bed_occ = mean(bed_occ, na.rm = T)) %>%
  arrange(desc(mean_bed_occ))  %>%
  ungroup()
```

    ## # A tibble: 255 x 2
    ##    org_name                                       mean_bed_occ
    ##    <chr>                                                 <dbl>
    ##  1 Barnet, Enfield And Haringey Mental Health            0.982
    ##  2 Bradford District Care Trust                          0.972
    ##  3 Camden And Islington                                  0.953
    ##  4 Hertfordshire Partnership University                  0.953
    ##  5 North Essex Partnership University                    0.945
    ##  6 Devon Partnership                                     0.945
    ##  7 Sussex Partnership                                    0.942
    ##  8 Essex Partnership University                          0.942
    ##  9 Manchester Mental Health And Social Care Trust        0.940
    ## 10 Birmingham And Solihull Mental Health                 0.935
    ## # ... with 245 more rows

# Extension:

### How many columns associated with each observation?

The question posed means that we need an extra column within out summary
output. This is not a problem; we can add many extra measures to our
summary values. `summarise(number = n())` will count the number of rows
associated with each group.

This can be pushed into the summarise syntax (along with the mean).

``` r
beds_data %>%
  mutate(bed_occ = occ_av / beds_av) %>%
  group_by(org_name) %>%
  summarise(mean_bed_occ = mean(bed_occ, na.rm = T),
            number = n()) %>%
  arrange(desc(mean_bed_occ)) %>%
  ungroup()
```

    ## # A tibble: 255 x 3
    ##    org_name                                       mean_bed_occ number
    ##    <chr>                                                 <dbl>  <int>
    ##  1 Barnet, Enfield And Haringey Mental Health            0.982     21
    ##  2 Bradford District Care Trust                          0.972      3
    ##  3 Camden And Islington                                  0.953     21
    ##  4 Hertfordshire Partnership University                  0.953      9
    ##  5 North Essex Partnership University                    0.945     15
    ##  6 Devon Partnership                                     0.945     21
    ##  7 Sussex Partnership                                    0.942     21
    ##  8 Essex Partnership University                          0.942      6
    ##  9 Manchester Mental Health And Social Care Trust        0.940     14
    ## 10 Birmingham And Solihull Mental Health                 0.935     21
    ## # ... with 245 more rows

## Also a sixth verb: select()

### Select a subset of variables from existing dataset

This **select** verb ensures that we only **select** the data that we
are interested in - very much like SELECT in SQL.

For example, the below will return just the fields \[org\_code\] and
\[org\_name\]:

``` r
beds_data %>%
  select(org_code, org_name)
```

    ## # A tibble: 4,558 x 2
    ##    org_code org_name                                    
    ##    <chr>    <chr>                                       
    ##  1 R1A      Worcestershire Health And Care              
    ##  2 R1C      Solent                                      
    ##  3 R1E      Staffordshire And Stoke On Trent Partnership
    ##  4 R1F      Isle Of Wight                               
    ##  5 R1H      Barts Health                                
    ##  6 R1J      Gloucestershire Care Services               
    ##  7 RA2      Royal Surrey County Hospital                
    ##  8 RA3      Weston Area Health                          
    ##  9 RA4      Yeovil District Hospital                    
    ## 10 RA7      University Hospitals Bristol                
    ## # ... with 4,548 more rows

Similarly, we can return all of the fields *except* for \[org\_code\]
using the below:

``` r
# Select a subset of variables from existing dataset:
beds_data %>%
  select(-org_code) # To remove a column
```

    ## # A tibble: 4,558 x 4
    ##    date       org_name                                     beds_av occ_av
    ##    <date>     <chr>                                          <dbl>  <dbl>
    ##  1 2013-09-01 Worcestershire Health And Care                   129    117
    ##  2 2013-09-01 Solent                                           105     82
    ##  3 2013-09-01 Staffordshire And Stoke On Trent Partnership      NA     NA
    ##  4 2013-09-01 Isle Of Wight                                     54     42
    ##  5 2013-09-01 Barts Health                                      NA     NA
    ##  6 2013-09-01 Gloucestershire Care Services                     NA     NA
    ##  7 2013-09-01 Royal Surrey County Hospital                      NA     NA
    ##  8 2013-09-01 Weston Area Health                                NA     NA
    ##  9 2013-09-01 Yeovil District Hospital                          NA     NA
    ## 10 2013-09-01 University Hospitals Bristol                      NA     NA
    ## # ... with 4,548 more rows

Or, just the first three columns (variables) from the dataset:

``` r
beds_data %>%
  select(1:3) # Columns 1 to 3
```

    ## # A tibble: 4,558 x 3
    ##    date       org_code org_name                                    
    ##    <date>     <chr>    <chr>                                       
    ##  1 2013-09-01 R1A      Worcestershire Health And Care              
    ##  2 2013-09-01 R1C      Solent                                      
    ##  3 2013-09-01 R1E      Staffordshire And Stoke On Trent Partnership
    ##  4 2013-09-01 R1F      Isle Of Wight                               
    ##  5 2013-09-01 R1H      Barts Health                                
    ##  6 2013-09-01 R1J      Gloucestershire Care Services               
    ##  7 2013-09-01 RA2      Royal Surrey County Hospital                
    ##  8 2013-09-01 RA3      Weston Area Health                          
    ##  9 2013-09-01 RA4      Yeovil District Hospital                    
    ## 10 2013-09-01 RA7      University Hospitals Bristol                
    ## # ... with 4,548 more rows

Or, we can return everything but put the \[org\_name\] at the start of
the data that is returned:

``` r
beds_data %>%
  select(org_name, everything()) # Put org_name at the start of the data frame
```

    ## # A tibble: 4,558 x 5
    ##    org_name                              date       org_code beds_av occ_av
    ##    <chr>                                 <date>     <chr>      <dbl>  <dbl>
    ##  1 Worcestershire Health And Care        2013-09-01 R1A          129    117
    ##  2 Solent                                2013-09-01 R1C          105     82
    ##  3 Staffordshire And Stoke On Trent Par~ 2013-09-01 R1E           NA     NA
    ##  4 Isle Of Wight                         2013-09-01 R1F           54     42
    ##  5 Barts Health                          2013-09-01 R1H           NA     NA
    ##  6 Gloucestershire Care Services         2013-09-01 R1J           NA     NA
    ##  7 Royal Surrey County Hospital          2013-09-01 RA2           NA     NA
    ##  8 Weston Area Health                    2013-09-01 RA3           NA     NA
    ##  9 Yeovil District Hospital              2013-09-01 RA4           NA     NA
    ## 10 University Hospitals Bristol          2013-09-01 RA7           NA     NA
    ## # ... with 4,548 more rows

A couple of pointers that I have observed here:

  - You can combine any number of verbs within the query syntax. For
    example, in these final points where **select** was used I could
    have selected only the data that I was interested in, *and then*
    also performed various other manipulations on the subsequent data.
    There appears to be no limits.

  - Any manipulations (possibly with the exception of `group_by()` which
    means it is especially important to use `ungroup()`) are kept within
    the framework of that particular syntax/query. A pipe function
    appears to only be applicable within the single environment where it
    is used. For example, if I did a **select** on `beds_data` then that
    subsequent data frame would only be applicable within that usage
    environment. If I called `beds_data` within another query/syntax
    then the **select** manipulation would not be presented. It is
    almost *non-destructive*, to coin a photography phrase.

# Addendum

## Data frames

In both this portion (dplyr) and other slides (ggplot) we have worked
with data frames.

Within a data frame variables are stored in columns, and dataframes are
a series of columns bound together by an invisible “data frame”
structure.

If we were to remove the data frame structure we can look at the columns
in isolation. These isolated columns can be thought of as vectors.

You can create a vector using code like this:

``` r
c(100, 80, 200) #c stands for "combine"
```

    ## [1] 100  80 200
