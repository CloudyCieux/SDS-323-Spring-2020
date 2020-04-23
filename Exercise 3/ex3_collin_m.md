Exercise 3
================

## Predictive Model Building

The price of housing is complex, influenced by many features specific to
the property itself, as well as features from the surrounding
envinronment. However, building a predictive model for price is useful,
because a good model would help give agents and potential clients an
estimate of the price of new or unpriced properties based on their
features.

<p>

 

</p>

Using the data on 7,894 commercial rental properties from across the
United States, we will attempt to build a predictive model of rent based
on several different features, such as age of the property or its status
as a green building.

<img src="ex3_collin_m_files/figure-gfm/unnamed-chunk-2-1.png" style="display: block; margin: auto;" />

When building the model, log(rent) will be predicted as rent is highly
positively skewed in the data. This transformation with the log function
normalizes the rent which improves the effectiveness of the regression
methods. A basic exploratory linear regression model of rent on green
rating alone produces a model that says on average, the rental income
per square foot is 9% higher for a green certified building compared to
a normal building. However, this model fails to capture the effect of
other features that could influence rent, so a more complex model is
needed to more accurately capture the impact of green certification on
rent holding other features constant.

<p>

 

</p>

To build a more complex predictive model for rent, I have chosen a set
of main effects from the data’s many different features that appear to
be related to rent graphically. Additionally, I have narrowed down the
set to features that I believe intuitively would be critical in
predicting the rent of a property accurately. The main effects I have
chosen for building my model include green rating, age, renovation
status, class\_a classification, and whether utilities are included or
not in the rent.

<img src="ex3_collin_m_files/figure-gfm/unnamed-chunk-3-1.png" style="display: block; margin: auto;" /><img src="ex3_collin_m_files/figure-gfm/unnamed-chunk-3-2.png" style="display: block; margin: auto;" />

Now that a set of main effects has been chosen, I will fit a lasso
regression over all the features in the data, except for a few features
that I deemed redundant, such as two features that specified which type
of green certification a building received. The reason I believe that a
lasso regression is appropriate for this situation is because there are
many features that could potentially predict price, but I am not sure if
including them would fit the model to noise, or improve its accuracy. By
using lasso regression, redundant factors can be selected by shrinking
their coefficients to 0, leaving only the relevant features in the
model. The lasso regression predicts rent and includes all the features
of the data as well as interactions between clusters and the main
effects I highlighted earlier as predictors. I will not penalize the
main effects in my lasso regression model, as I am fairly confident that
they are good predictors for rent from the analysis earlier.

    ## 6 x 1 sparse Matrix of class "dgCMatrix"
    ##                     seg67
    ## intercept     2.458612180
    ## green_rating  0.029156798
    ## age          -0.001109418
    ## renovated     0.015521249
    ## class_a       0.107180105
    ## net          -0.066965914

Out of the 3447 coefficients in the lasso regression model handling all
the features in the data as well as many interactions, 44 of them ending
up being non-zero and used in predicting rent. Above are the results
from the lasso regression, showing the first 5 coefficients for the
unpenalized main effects that I chose. From this more complex model, we
can conclude that on average, the rental income per square foot is 2.9%
higher for a green certified building compared to a normal building
holding other features constant. While this isn’t as much of a
difference compared to the first model, 2.9% is still a pretty
significant difference and should be kept in mind by those looking into
green buildings. In conclusion, lasso regression helped create a pretty
good predictive model for rent from data that consisted of many noisy
features and interactions, helping us hone in on the specific features
and interactions that are the most useful in predicting the rent of a
property.

<p>

 

</p>

## What Causes What?

1.  Why can’t I just get data from a few different cities and run the
    regression of “Crime” on “Police” to understand how more cops in the
    streets affect crime? (“Crime” refers to some measure of crime rate
    and “Police” measures the number of cops in a city.)  

Finding a causal relationship between crime rate and number of cops in a
city is not as simple as sampling data from a few different cities and
running a regression to predict “Crime” based on “Police”. First, cities
with a high crime rate are likely to employ a larger police force.
Additionally, expectation or observation that crime rates are rising in
a city would lead the jurisdictions to increase the size of their police
forces. Therefore, it can be said that variations in crime causes
variations in police presence, but it is difficult to prove the
opposite.  
Additionally, in experimental studies, randomization and controlling for
the effects of confounding variables are both important methods for
reducing bias and providing more reliable estimates. Different cities
have different situations, and these hidden factors could potentially
have an effect on crime rate independent of police force. It is
important these are controlled to isolate the effect of police force
size on crime rate.

2.  How were the researchers from UPenn able to isolate this effect?
    Briefly describe their approach and discuss their result in the
    “Table 2” below, from the researchers’ paper.
    ![](ex3_collin_m_files/ex3table2.jpg)

The researchers from UPenn were able to isolate the effect of size of
police force on crime rate by focusing on crime rates in Washington D.C
during high-alert days based on the terrorism alert system. High-alert
days increase the size of the police force in a way unrelated to crime,
therefore the effect of police force size on crime rate can be better
isolated. Based on table 2, they found that on high alert days, the
total daily number of crimes in D.C. decreased on average by 7.316.
Controlling for METRO ridership, they found that total daily number of
crimes in D.C. on high alert days decreased on average by 6.046. Both of
these were statistically significant with alpha = 0.05, showing a
significant decrease in crime rate caused by the increase in police
force size.

3.  Why did they have to control for Metro ridership? What was that
    trying to capture?  

It was necessary to control for METRO ridership because they were trying
to capture the potential effect of less people on the streets on crime
rate. The experimenters believed that high-alert days could potentially
lead less people to be out on the streets, acting as a confounding
variable on crime rate since less victims could mean less crime.
Regardless, controlling for METRO ridership still showed a significant
decrease in crime rate caused by the increased police force on
high-alert days as seen in table 2 above.

4.  Below I am showing you “Table 4” from the researchers’ paper. Just
    focus on the first column of the table. Can you describe the model
    being estimated here? What is the conclusion?
    ![](ex3_collin_m_files/ex3table4.jpg)

The model being estimated in table 4 is the crime rate on high alert
days by district continuing to control for METRO ridership. It is found
that on high-alert days in District 1, the daily total number of crimes
decreased on average by -2.621, while on high-alert days in other
districts, the daily total number of crimes decreased by only -.571. A
potential conclusion that could be drawn from this is that increased
police force on high-alert days in D.C. District 1 did not disrupt the
police force of other districts, as they still had some decrease in
crime rate too, even if it was not as large as in District 1.

<p>

 

</p>

## Clustering and PCA

Our showcase of PCA and clustering methods will work with data on 11
chemical properties of 6500 different bottles of vinho verde (green
wine) from Northern Portugal. Additionally, two categorical variables,
whether the wine is red or white, and the quality of the wine on a 1-10
scale, will be used to determine whether these unsupervised techniques
can summarize this high-dimensional, complex space down so that the
different categories of wine can be distinguished from each other.  
As a minor, I am no expert on wine, so the first dimensionality
reduction method I will utilize is PCA to simplify the data and try to
find relationships between these various chemcial property variables.

<div class="figure" style="text-align: center">

<img src="ex3_collin_m_files/figure-gfm/unnamed-chunk-6-1.png" alt="Figure 3: Correlations of Wine Chemical Properties"  />

<p class="caption">

Figure 3: Correlations of Wine Chemical Properties

</p>

</div>

Looking at this correlation plot of the various chemical properties of
wine, there appears to be a strong positive corrleation between free and
total sulfur dioxide, as well as density and residual sugar as well as
fixed acidity. There is a strong negative correlation between density
and alcohol. In general, there are quite a few moderately strong
correlations in these pairs of chemical properties, so PCA will likely
be effective in helping summarize these properties more succinctly.

<img src="ex3_collin_m_files/figure-gfm/unnamed-chunk-7-1.png" style="display: block; margin: auto;" />

The figure above shows the results of performing PCA on the 11 different
wine features after they were scaled by their z-scores. This
dimensionality reduction reveals two relatively well defined clusters in
this plot, where the majority of red wine is in one cluster and the
majority of white wine is in the other cluster. Because of this, using
k-means clustering and then PCA to summarize the results and simplify
the visualization would likely be a very effective method of
distinguishing between red and white wine.

<img src="ex3_collin_m_files/figure-gfm/unnamed-chunk-8-1.png" style="display: block; margin: auto;" />

Though the PCA from earlier shows two relatively well defined clusters,
it does not hurt to use a computational method that chooses k for
k-means to corroborate with these observations. In Figure 5, the results
of the CH Index show that using k = 2 for our k-means clustering would
be appropriate, agreeing with our visual insepction of the PCA
scatterplot from Figure 4.

<img src="ex3_collin_m_files/figure-gfm/unnamed-chunk-9-1.png" style="display: block; margin: auto;" /><img src="ex3_collin_m_files/figure-gfm/unnamed-chunk-9-2.png" style="display: block; margin: auto;" /><img src="ex3_collin_m_files/figure-gfm/unnamed-chunk-9-3.png" style="display: block; margin: auto;" />

Figures 6-8 above were obtained by performing k-means++ with 25 restarts
and k = 2 on the 11 wine properties. As expected, Figure 6 shows that
k-means++ found the clusters that were expected from the visual analysis
of the principle components plot from Figure 4. Separating the plot of
the clusters by wine color, we see that the clusters picked out by
k-means++ and the visual clusters from the PCA align quite well, with
most of the red wine being in the first cluster and most of the white
wine being in the second cluster. The fact that the red and white wine
splits up in this way makes sense, as the chemical properties of
different red wines are probably more similar to each other than they
are to white wines and vice versa.  
However, separating the plot of the clusters by wine quality does not
provide as good results as with color. Regardless, the majority of the
high quality wine appears in the second cluster (7 - 9), while the
majority of the low quality wine appears in the first cluster (3 - 5).
The middle range of quality has relatively equal amounts of points from
the two clusters interestingly (5-7). This result leads me to believe
that good quality wine can be found over a wider array of chemical
properties. Additionally, it makes sense logically that these clusters
that discriminated red and white wine well, did not discriminate wine
quality as well because there is likely both low and high quality red
and white wine.

    ##   fixed.acidity volatile.acidity citric.acid residual.sugar  chlorides
    ## 1     0.8286464        1.1678795  -0.3378091     -0.5903919  0.9216848
    ## 2    -0.2804833       -0.3953082   0.1143429      0.1998380 -0.3119753
    ##   free.sulfur.dioxide total.sulfur.dioxide    density         pH  sulphates
    ## 1          -0.8316090           -1.1872380  0.6815493  0.5673286  0.8430523
    ## 2           0.2814861            0.4018607 -0.2306934 -0.1920315 -0.2853595
    ##       alcohol
    ## 1 -0.07569241
    ## 2  0.02562065

What general properties do the wines in each cluster share? Based on the
z-scaled centroids of the k-means++ clusters shown above, the first
cluster contains wines that are above average in acidity, chlorides,
density, pH, and sulphates. The second cluster contains wines that are
above average in citric acid, residual sugar, sulfur dioxide, and
alcohol. These match the correlations well from Figure 3, and
additionally reveal summaries of the characteristics of red and white
wine, as they were well discriminated by the two clusters.  

In conclusion, PCA alone did a great job at summarizing the many
different chemical properties of the wines and revealed two clusters
which we found to be quite good at distinguishing red from white wine.
However, the addition of k-means after performing PCA allowed us to be
sure that those clusters we saw visually were present in the reduced
data, showing how the combination of PCA and k-means clustering was very
powerful for making sense of this large data set on wine.

<p>

 

</p>

## Market Segmentation

Though one’s representation of themselves on social media is not a
perfectly accurate reflection of who they are as a person, their social
modia persona can be incredibly useful information to gain insight into
their interests and desires. For this reason, we will be analyzing data
on the followers of the Twitter account of a large consumer brand,
anonymously named “NutrientH20”, to find out information about its
markets segments so that it can more effectively market through
Twitter.  
The data contains information on the tweets of 7882 followers of the
company account. Each tweet the followers made was categorized based on
its content into one or more of 36 different categories by a human
annotator. Though spam and pornography bots were filtered, I further
cleaned the data by filtering out data entries where the number of spam
posts was greater than 1 and the number of adult posts was greater than
5 (based on Q3 of their categories distributions). This filtering
brought the dataset down to the tweets of 7633 followers, more than
sufficient for analysis. Finally, I finished cleaning the data by
removing the columns for chatter, uncategorized, spam, and adult tweets
as well as the 9-digit alphanumeric code used to label followers as they
are either unlikely to be relevant to a market segment, or unsuitable
for analysis.

<div class="figure" style="text-align: center">

<img src="ex3_collin_m_files/figure-gfm/unnamed-chunk-12-1.png" alt="Figure 9: Correlations of Tweet Categories"  />

<p class="caption">

Figure 9: Correlations of Tweet Categories

</p>

</div>

In search of market segments among the social media audience, I first
started by creating a correlation matrix to pick out any rough
relationships I can find. Some of the relatively strong correlations
that made practical sense were a correlation between the college/uni
category and the sports playing and online games categories. Those are
both activities that college students primarily do, so it makes sense
their tweets reflect that. Other correlations I found were between
fashion and beauty and personal fitness and health nutrition. These two
pairs of categories go well with each other, which likely explains why
they are correlated.  
As there are so many categories with potential relationships between
them, the approach I will take in analyzing this data will be performing
k-means clustering and PCA together to make the data easier to visualize
in order to try and pick the ideal k for clustering. These clusters will
be the market segments that represent summaries of the interests of
different groups of this company’s Twitter followers.

<img src="ex3_collin_m_files/figure-gfm/unnamed-chunk-13-1.png" style="display: block; margin: auto;" /><img src="ex3_collin_m_files/figure-gfm/unnamed-chunk-13-2.png" style="display: block; margin: auto;" />

After scaling the scores for each category to z-scores, I performed
k-means++ with 25 restarts and k = 3 and 7. Then, I used PCA to
visualize the clusters easier. Though using k = 3 clusters divided up
the data nicely into 3 easily seen clusters as seen in Figure 10, I
discovered upon analysis of the cluster centroids that there were too
few clusters to yield interpretable market segments. After trying values
of k = 4 through 6, I found that k = 7 was the ideal number of clusters
to yield the most interpretable market segments. As seen in Figure 11,
this was at the cost of losing the nicely interpretable clusters, with
some of the clusters being hard to pick out.  

After analyzing the centroids of the clusters produced from k-means++, I
decided that 7 clusters was ideal for distinguishing the most
interpretable market segments from the data. I used the centroids to
interpret the clusters by taking the maximum of each cluster centroid’s
score for each category. For example, in the school category, cluster 1
had the highest score of 1.655, which meant that I interpreted cluster 1
as being characterized by the school category of tweets. I did this for
the rest of the categories and obtained summaries of the categories that
represent 6 market segments the best (cluster 4 had no category to
represent it best).

    ##         interest k
    ## 5  sports_fandom 1
    ## 7           food 1
    ## 8         family 1
    ## 25      religion 1
    ## 27     parenting 1
    ## 29        school 1

Cluster 1 is characterized by the parenting and family categories as
well as school and religion categories, two ideas that I would associate
with families who have children. Therefore, I feel this market segment
best represents parents, who can be marketed to effectively with
messaging that relates to family values or things that would improve
their children’s lives.

    ##           interest k
    ## 1   current_events 2
    ## 4          tv_film 2
    ## 9  home_and_garden 2
    ## 10           music 2
    ## 20        business 2
    ## 22          crafts 2
    ## 24             art 2
    ## 32  small_business 2

Cluster 2 has a wide array of interests, but the two main axes of
interests included in here are artistic and business-related. I could
see people in this cluster either being businesspeople with artistic
hobbies like arts and crafts, or as people trying to get by with a
business that specializes in the arts. Either way, these axes of
interest provide good points of interest when it comes to marketing to
this segment.

    ##          interest k
    ## 12  online_gaming 3
    ## 15    college_uni 3
    ## 16 sports_playing 3

Cluster 3 follows from the correlations that I pointed out from Figure
9. Individuals who tweet about college or university are likely college
age students, and individuals at this age are most likely to be into
online gaming or sports playing. The most important characteristic about
this cluster overall is that they are college students, which provides
great demographic information in terms of marketing.  

Cluster 4 had no categories to represent itself, which I found very
interesting because starting from k = 3 going up, there was always one
cluster that was like cluster 4. This cluster was also always the
cluster that was situated leftmost on the plot shown in Figures 10 and
11. I am not entirely sure why this cluster systematically did not stand
out, but further research could be done into it to see if there is
anything to be gained from their cluster’s information in terms of a
market segment.

    ##            interest k
    ## 14 health_nutrition 5
    ## 18              eco 5
    ## 21         outdoors 5
    ## 30 personal_fitness 5

Cluster 5 is all about health and wellbeing, with interest in health and
nutrition, the outdoors, and personal fitness. Considering the company
was anonymously labelled as “NutrientH20”, I would think that this would
be the primary market segment for them to direct their attention toward.
Regardless, individuals in this cluster have very clear interests shown
through the topics of their tweets which can be capitalized upon through
proper marketing.

    ##         interest k
    ## 3  photo_sharing 6
    ## 13      shopping 6
    ## 17       cooking 6
    ## 26        beauty 6
    ## 31       fashion 6

Cluster 6 reminds me of the social media term “influencers”, people who
have a purported expert level knowledge or social influence in their
field. The categories in this cluster like cooking, beauty, and fashion
are all potential fields that influencers have, and photo sharing is
definitely part of what they do. Marketing to these individuals could be
quite beneficial as by definition, influencers tend to have significant
social media presence and “clout”.

    ##      interest k
    ## 2      travel 7
    ## 6    politics 7
    ## 11       news 7
    ## 19  computers 7
    ## 23 automotive 7
    ## 28     dating 7

Cluster 7 is characterized by a more wide array of interests compared to
some of the other clusters, but I find a characteristic that could
describe individuals that fall in this cluster would be adventurous.
They like to travel, date, and drive fast cars. In reality though, this
segment has quite diverse interests that it could be hard to market to,
especially with their interest in news and politics, something that can
become very divisive.  

In conclusion, using k-means clustering followed by PCA with 7 clusters
provided a passably visualizable plot and very interpretable information
on different market segments that follow this company’s Twitter. Deeper
analysis into the interests and specifics of each of these clusters
would be very advantageous for the company’s marketing abilities as they
can learn more about the interests of the segment that can be
capitalized upon with the appeal of their company’s brand. In
particular, clusters such as 1, 3, and 5 which have very clear
relationships in their interests would be the best start for this
company to appeal to their different market segments. Regardless, with
their diverse audience, narrowing it down to 7 clusters should prove to
be helpful for giving future direction to their marketing endeavors.
