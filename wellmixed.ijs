NB. Mixing a set of items so that any contiguous sample contains the most representative possible sample

NB. Statistical Definitions
SampleVariance =: (+/@(*:@(] - +/ % #)) % #)"1
StandardDeviation =: %:@SampleVariance"1
Mean =: +/%#
Normalize =: StandardDeviation %~ ] - Mean NB. normalTable =: Normalize"1 idTable

NB. Sample Data Set
NB. Name	Age	Sex	Rank
itemTraits =: ;: ;._2 noun define
Andy	18	M	5
Bob	18	M	7
Carl	21	M	9
Don	29	M	2
Ed	30	M	4
Frank	31	M	12
Zelda	20	F	11
Yvette	21	F	10
Xanthippe	21	F	8
Wendy	25	F	6
Violet	30	F	3
Uma	35	F	1
)

NB. Convert to numeric array
itemNames =: 0 {"1 itemTraits
itemAges =: ". > 1 {"1 itemTraits
itemSexes =: (i.~ ~.) 2 {"1 itemTraits
itemRanks =: ". > 3 {"1 itemTraits
idTable =: itemAges , itemSexes ,: itemRanks

NB. Find mean and standard deviation for comparison
populationMean =: (+/ % #)"1 idTable
populationSTD =: StandardDeviation idTable

NB. Verbs for analyzing how well-mixed the set is
Range =: 3 : '2 }. i. <: # y' NB. The list of integers between 2 and list length minus 2

Samples =: 1 : 0
NB. This adverb will apply the verb to every size x contiguous sample of y, wrapping as necessary.
(# y) u Samples y
:
x u;._3 y , y {.~ <: x
)

MeanScore =: 3 : '+/ , *: (Range y) Mean Samples"(0 _) y' NB. use with rank 1 on a normalized table, such as meanScore"1 normalTable
StdScore =: 3 : '+/ , *: <: (Range y) StandardDeviation Samples"(0 _) y' NB. use with rank 1 on a normalized table, such as stdScore"1 normalTable
Scores =: MeanScore"1 ,. StdScore"1

NB. Calculate worst score
WorstScores =: Scores /:~"1 Normalize"1 NB. sort each variable independently before scoring
NB. compare to interleved sample
interlevedTable =: (0 6 1 7 2 8 3 9 4 10 5 11) {"1 idTable
bestSexTable =: Scores Normalize"1 interlevedTable
percentOfWorst =: bestSexTable % WorstScores idTable


NB. Repulsion table
QualitativeRepulsion =: =/~
QuantitativeRepulsion =: 0 >. 6 %~ 6 - [: | [: -/~ Normalize
repulsionSex =: QualitativeRepulsion itemSexes
repulsionAge =: QuantitativeRepulsion itemAges NB. Repulsion is 0 for differences of six sigma or greater. Three sigma difference is 0.5 repulsion.
repulsionRanks =: QuantitativeRepulsion itemRanks NB. Repulsion is 0 for differences of six sigma or greater. Three sigma difference is 0.5 repulsion.
repulsionTable =: 3 %~ repulsionSex + repulsionAge + repulsionRanks

NB. Field calculations
PolygonRadius =: 3 : '% 2 * 1&o. o. % y' NB. http://www.mathopenref.com/polygonradius.html
ringRadius =: PolygonRadius 1 { $ repulsionTable

NB. Iteration Steps
STEPSIZE =: 1 NB. Multiplier for the various field effects.
RINGTHRESHHOLD =: 100 NB. Number of steps until the ring pulls with equal force to an identical mote
CORETHRESHHOLD =: 200 NB. Number of steps until the CoreBump reaches full power
MoteFieldPush =: 4 : '+/"1 x * STEPSIZE * (%&*:&| * *) -/~ y' NB. Repulsion Weight (x) * STEPSIZE * inverse of magnitude squared * direction
RingPull =: 4 : 'STEPSIZE * (x % RINGTHRESHHOLD) * (* y) * (* |) ringRadius - | y' NB. x is the step number which increases the power of the ring's pull
CoreBump =: 4 : '+/"1 STEPSIZE * (%&*:&*:&| * *) -/~ (1 >. CORETHRESHHOLD % x) * y' NB. core bump strongly repulses motes that are closer than 1 to each other

NB. WhiteNoise =: 3 : 'j./ 0.01 * 0.5 - ? 0 $~ 2 , $ y' NB. White noise solves the problem of identical motes in identical positions
WhiteNoise =: 3 : '0.01 * 0.5j0.5 - (? j. ?) 0"0 y' NB. White noise solves the problem of identical motes in identical positions

OneStep =: 4 : 'y + (repulsionTable MoteFieldPush y) + (x RingPull y) + (x CoreBump y) + (WhiteNoise y)' NB. y is the current possitions and x is the step number to pass to RingPull


NB. Visualization
load 'plot'

Mixer =: 4 : 0
positions =: j./ ringRadius * 4 * 0.5 - ? 0 $~ 2,# repulsionTable NB. Initial positions
for_j. 1 + i. x do.
'marker' plot positions
6!:3 (0.01) NB. Sleep for a tenth of a second. Fails in Unix but works in Windows. More precise delays are not reliable.
positions =. j OneStep positions
end.
positions
)
