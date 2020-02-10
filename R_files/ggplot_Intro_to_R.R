#########################################################################################
# NHS- Community
# ggplot Intro to R
# https://github.com/nhs-r-community/intro_r/blob/master/04-workshopv2_ggplot.pdf
#########################################################################################

# Load the relevant libraries:
library(tidyverse)

# Import the dataset. In this instance use Environment > Import Dataset > From text (readr) [for csv]:
# Look at the data in the import window: does it look reasonable? Do any changes need to be made? Headers on row 1?
# If so, copy out the read_csv line and paste below.
capacity_ae <- read_csv("capacity_ae.csv")


# First task: Explore the standard challenge for the NHS - Pressures in A&E.
# Data: Capacity in A&E
# The dataset shows the changes in capacity of A&E departments from 2017 to 2018.
# The object capacity_ae is a dataframe (or a 'tibble' in tidyverse)

# View the dataset/tibble: 
# fields include: the site, 
# number of attendances, 
# staff_increase (did # staff increase between 2017 and 2018?), 
# dcubicles & dwait (difference in average from 2017 to 2018).
capacity_ae

# Question: Is a change in the number of cubicles available in A&E 
#   associated with a change in the length of attendance?
# Always start with ggplot, then specify the dataset. Next add layers with a +
#   Decide what kind of data you want to show (geometric object): a point, bar, line? (always geom_ before it)
#   Next, what kind of aesthetics do we give to the geom? (position x, y, colour, size)
#     In the basic example below these are all set to default (non-declared)
ggplot(data = capacity_ae) +
  geom_point(aes(x = dcubicles, y = dwait))

# Functions:
#   ggplot(), geom_point(), and aes() are all functions
#   Running a function does something; functions are given zero or more inputs (arguments)
#     Arguments of a function are separated by a comma.
# 
#   You can explicitly name arguments, or not provided the arguments are in the correct order.
#     ggplot(data = capacity_ae) == ggplot(capacity_ae)

# In the graph we've just put together we declared the input dataset, and two aes arguments.
#   Within the aes x goes first, y goes second.
# ggplot(data = capacity_ae) +
#   geom_point(aes(x = dcubicles, y = dwait))
# Therefore ^ is the same as (though either are fine):
# ggplot(capacity_ae) +
#   geom_point(aes(dcubicles, dwait))

# There are various geoms available, and we describe plots in terms of the geom used:
#   geom_bar(); geom_line(); geom_boxplot(); geom_histogram()
# We can also add more than one geom in a plot, again using a + to add another layer.

# In the below we'll use the same graph as ^ but add a geom_smooth layer to help identify patterns:
ggplot(data = capacity_ae) +
  geom_point(aes(x = dcubicles, y = dwait)) +
  geom_smooth(aes(x = dcubicles, y = dwait))

# This ^ is fine, but we probably want to add a linear fit to the smooth, rather than a non-linear fit:
ggplot(data = capacity_ae) +
  geom_point(aes(x = dcubicles, y = dwait)) +
  geom_smooth(aes(x = dcubicles, y = dwait), method = "lm")


# Looking at the graph there are a couple of datapoints low down on the y axis compared to the others.
#   What's the deal with these?
# Hypothesis: The two sites have seen staffing increases.
#   We can map point colour to the staff increase variable to find out. Therefore, every point will be
#     coloured according to the value of staff_increase.

# Put an argument *inside* aes() if you want a visual attribute to change with different values of a variable:
ggplot(data = capacity_ae) +
  geom_point(aes(x = dcubicles, y = dwait, colour = staff_increase))

# Put an argument *outside* aes() if you want a visual attribute to be applied across a whole plot:
ggplot(data = capacity_ae) +
  geom_point(aes(x = dcubicles, y = dwait), colour = "red")
# Or...
ggplot(data = capacity_ae) +
  geom_point(aes(x = dcubicles, y = dwait), size = 4)
# Or even...
ggplot(data = capacity_ae) +
  geom_point(aes(x = dcubicles, y = dwait), colour = "red", size = 4)
# Or perhaps... both inside and outside?
ggplot(data = capacity_ae) +
  geom_point(aes(x = dcubicles, y = dwait, colour = staff_increase), size = 4)

# And then also apply the smoothing too...
ggplot(data = capacity_ae) +
  geom_point(aes(x = dcubicles, y = dwait, colour = staff_increase), size = 2) +
  geom_smooth(aes(x = dcubicles, y = dwait),
              method = "lm") # Fit a linear model rather than a non-linear
  


# Another way to visualise the relationship between multiple variables is with a facet_wrap() layer:
#   (facet_wrap() is used for categorical variables)
ggplot(data = capacity_ae) +
  geom_point(aes(dcubicles, dwait)) +
  # Then tell facet_wrap() you want a panel for each category of [staff_increase]
  facet_wrap(vars(staff_increase))

# This ^ presents each panel with a vertical split, if you want it splitting horizontally 
#   add an extra argument (number of columns = 1):

ggplot(data = capacity_ae) +
  geom_point(aes(x = dcubicles, y = dwait)) +
  facet_wrap(vars(staff_increase), ncol = 1)


# Further demonstrations of other types of geom:

# How are wait values distributed? - Histogram:
ggplot(data = capacity_ae) +
  geom_histogram(aes(dwait))
#   R advises that there are 30 bins using this ^ method, and suggests that we set a value for the number
#     of bins instead (binwidth):
ggplot(data = capacity_ae) +
  geom_histogram(aes(dwait),
                 binwidth = 10)


# Number of attendances by site? - Barplot
ggplot(data = capacity_ae) +
  geom_col(aes(x = site, 
               y = attendance2018))
# Again, this ^ is fine, but how about we reorder site by attendances?
ggplot(data = capacity_ae) +
  geom_col(aes(x = reorder(site, attendance2018), # We are still specifying site as x, just reordering them.
               y = attendance2018))


# Distribution of "wait" for each value of staff level? - Boxplot
ggplot(data = capacity_ae) +
  geom_boxplot(aes(staff_increase, dwait))


# These graphs are good but we need to add some labels to aid clarity. Add extra layer for labels:
ggplot(data = capacity_ae) +
  geom_boxplot(aes(staff_increase, dwait)) +
  labs(
    title = "Do changes in staffing affects wait times?",
    x = "Is there a staff increase?",
    y = "Waiting time"
  )


# Finally, we may want to save the graph for use elsewhere. We'll use the same graph, but add another layer:
#   By default ggsave() will save a plot using the same dimensions as the plot window. 
#   You can adjust these, e.g.:
#     ggsave(plot_name.png, units = "cm", height = 10, width = 8)

ggplot(data = capacity_ae) +
  geom_boxplot(aes(staff_increase, dwait)) +
  labs(
    title = "Do changes in staffing affects wait times?",
    x = "Is there a staff increase?",
    y = "Waiting time"
  ) +
  ggsave("ggplot_intro_example_save.png")



# One final point. Earlier we detailed the addition of a geom_smooth() to help identify patterns:
ggplot(data = capacity_ae) +
  geom_point(aes(x = dcubicles, y = dwait)) +
  geom_smooth(aes(x = dcubicles, y = dwait), method = "lm")
# Both geom_point() and geom_smooth() both use the same arguments. No problems but duplication of code...
#   There is a way around this when layering geoms.
#   To avoid duplication we can pass the common local aes() arguments to ggplot() to make them global:
#     Recall that arguments must be in the expected order to function.
#     In the ggplot() function, aes() is the standard second argument.
ggplot(data = capacity_ae, aes(x = dcubicles, y = dwait)) +
  geom_point() +
  geom_smooth(method = "lm")