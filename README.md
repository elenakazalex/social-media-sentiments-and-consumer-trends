# When Buzz Turns Into Business: How Social Media Sentiments Shape Consumer Demand

The project investigates whether **expressive social discussion of a brand, particularly unusually high-attention periods (denoted as peaks of mentions on social media), is associated with increased brand demand**. The findings were further used to **inform targeted crowd marketing strategies (injection of discussion surrounding the brand or its organic stimulation) for enterprise clients of a marketing organization**. ---This project examines whether generating high-volume, expressive online discussion around a brand creates commercially meaningful consumer interest and, critically, whether more expression necessarily produces more demand. The analysis was designed to support data-driven crowd-marketing decisions by distinguishing between attention that simply generates online buzz and attention that is associated with measurable changes in consumer search behavior.

**Main business objective of the project**: determine whether the volume and expressive charactertiristics of online brand discussion contain actionable signals of consumer interest and whether these signals can inform more targeted digital marketing strategies.  

**Main business outcome**: the analysis established **Peak to Demand Response metric** (the percentage change in brand search demand following an expressive social media attention peak, measured against the pre-event baseline) as the primary commercial outcome used to evaluate whether attention generated through crowd marketing corresponded with immediate or delayed consumer interest, while the newly proposed **Expression Intensity segmentation** helped identify whether maximizing sentiments is actually optimal for driving purchasing consideration.

**Tools used**: Excel for data cleaning; R for data validation, statistical analysis and data visualization; social media monitoring platform (SCAN) and Google search query trafficking platform (KeyWorldTool) for raw data sourcing 

## Project background and business problem

This project forms part of a larger mixed methods research program examining how online brand discussions relate to consumer demand. The analysis is built upon a longitudinal, lagged research design and combines monthly social media sentiment data and Google search volume across 38 brands over two years, covering more than 270 million social media mentions.  

The central business problem was identifying whether unusually expressive online attention represents a commercially meaningful signal and whether brands should actively manage and stimulate expressive online discussion rather than simply seeking high volumes of social media mentions - all the results are directly applicable to refining choice of strategic tools of an undisclosed B2B marketing organization. 

The analysis addressed 4 business-specific questions:
* **Does expressive online attention generate commercially relevant consumer interest?** -> When a brand experiences an unusually expressive peak in online discussion, does this attention correspond to a measurable increase in consumer search activity?
* **Does expressive attention generate immediate demand or informational curiosity or both over time??** -> Does media attention produce only immediate spikes in demand or can it be a prolonged or lagged response?
* **Can brands underdo or overdo expressive media attention?** -> Can combinations of sentiment characteristics be identified that are more closely associated with demand yet do not lead to sentiment overheating? 
* **How can brand's crowd marketing strategies be improved via sentiment injection?** -> Can brands' crowd-marketing strategies move beyond simply maximizing mention volume toward deliberately creating and managing specific levels of attention for potential consumer demand?


## Executive summary

Analysis of 38 brands over two years and 270M+ social media mentions shows that the commercial value of online attention cannot be evaluated by mention volume alone. Extremely emotional media attention was also revealed to not be significantly associated with the most commercially optimal outcomes. 

2 original metrics were developed to translate the relationship between media attention and purchasing consideration into actionable business measures:
1. Peak-to-Demand Response: measures the change in Google search demand following an expressive attention peak, relative to the pre-peak baseline, capturing whether generated attention is followed by measurable consumer interest.
2. Optimal Expression Intensity: identifies the level of expressive attention associated with the strongest demand response, testing whether increasing expression indefinitely is actually commercially optimal.

From the perspective of brand's online reputation management, the findings also suggest that once expressive social attention prompts consumers to investigate a brand, the search environment becomes part of the conversion pathway. Generating attention therefore creates an opportunity but the information consumers encounter afterward can determine whether that curiosity develops into meaningful commercial interest. As a result, a strategic funnel for digital marketing endeavors can be constructed: 

Social media noticeable presence (volume of mentions) → social media buzz (expressiveness of mentions) → informational search → brand evaluation (what is this brand?) → commercial consideration 

The resulting framework shifts crowd marketing from simply generating as much buzz as possible toward obtaining the right volume and expressiveness of attention. The newly proposed metrics provide measurable downstream outcome for evaluating attention-generation strategies and calibrating interventions rather than assuming that extreme positivity is optimal.

The analysis consequently provides both an actionable framework for attention-generation and ORM strategy and a foundation for further research into how different forms of expressive discussion influence the progression from online attention to consumer demand.


## Analytical workflow

<img width="965" height="134" alt="image" src="https://github.com/user-attachments/assets/66d3a3c3-db05-4e67-b444-c319064306ff" />

1. Raw mentions: 270M+ records
2. Detection of media buzz events: detection of "peak" of mentions based on statistical normalization (Z statistic and standard deviation, mathematically derived as higher than >1 stdev from the baseline level of each brand's mention)
3. Event-based transformation of Google search volume as a proxy for demand:
4. Panel dataset: peak-based longitudinal dataset with 89 records
5. Validation: OLS 

### 1. Data and relationships 

Overview of the brands included in the sample: 

| Segment        | Brand types           | # of brands  |
| ------------- |-------------| :-------------:|
| Entertainment      | Entertainment agency, Streaming service | 2 |
| Travel      | Hotel, Airline      |   3 |
| Food | Desserts, Pre-made food, Restaurant      |    4 |
| Service      | Marketplace, Data solution, Apps      |   4 |
| Electronics | Cooking appliance, Styling appliance      |    5 |
| Apparel | Underwear, Sportswear, Denim, Shoes      |    6 |
| Accessories & Decor      | Bag accessories, Eyewear, Toys/Decor, Watches, Jewelry  | 6 |
| Cosmetics      | Skincare, Makeup      |   8 |

The pre-hoc industry segmentation served as a structural control for brand selection, ensuring that further patterns identified were not driven by isolated or non-comparable brand cases: minimum of 2 structurally similar brands per segment. For each brand number of social media mentions and search frequency volumes were collected for the period of Dec 2023 – Nov 2025 (24 months). 

The analysis was based on a total of 4 connected tables derived from raw data of over 270 million social media mentions. Join key: composite key of brand and month of the peak of mentions, both attributes are individually non-unique but their combination identifies the corresponding observation. 

<img width="454" height="354" alt="image" src="https://github.com/user-attachments/assets/64bc535e-ab17-4306-940c-e2bc032b7126" />

### 2. Initial exploratory analysis 

Preliminary correlation analysis of search volume and social media mentions volume revealed diverse dynamics between the two variables. While some "jumps" in mentions appeared to be correlated either at the same month (t0) or next month (t+1) with search frequency jumps, some others appear to be almost obsolete: 

<img width="499" height="374" alt="image" src="https://github.com/user-attachments/assets/9a54365b-2865-4bcb-8c7d-968aa4164429" />

Moreover, the raw volumes of mentions for brands was largely incomparable due to the presence of largely discussed brands on average (e.g., Spotify) and brands with less than noticeable average social media presence (e.g., VeriSource).

<img width="352" height="156" alt="image" src="https://github.com/user-attachments/assets/39e133fe-abf3-4685-8fc8-cc147aca89c6" /> <img width="352" height="156" alt="image" src="https://github.com/user-attachments/assets/becb5e42-33b3-4b28-bb10-5f9bc20fb0d5" />

The EDA demonstrated two major insights: all of the brands in the sample have distinctly vivid outliers in social media mentions volumes with incomparable raw values. The need for normalization of variables was identified.

### 3. Standardization, identification of peaks and event table construction

Peaks of mentions were determined based on Z standardization as values above 1 standard deviation from the mean of the brand’s average monthly mentions volume. The qualitative premise behind this decision was that online media dynamics are driven by episodic spikes rather than stable distributions. Values outside ±1 st. dev were considered meaningful deviations from the baseline behavior, indicating media events that may require special attention or response from the brand. As a result of peak identification, a new dataframe with 84 records of "media peaks" was constructed. 

_Snippet of the media peaks table:_

<img width="212" height="205" alt="image" src="https://github.com/user-attachments/assets/cf923dcc-30d1-4b97-8790-25a27f927cb7" />

In order to understand the demand outcome of such media events, an event study approach was used to construct a full social media peak to search response dataset:
consolidating data for 84 mention peaks with search frequency changes from a month before the peak (t-1) to the month of the media peak (t0), the following month (t+1) and 2 months after (t+2). Notably, the search volume change for each event was calculated from the pre-peak month (t-1) as the baseline equal to 0, so that change_t0 was a percentage change in the search volume at the month of the peak from t-1, change_t1 as a percentage change in the following month from t-1 and so on.

_Snippet of the event table:_

<img width="356" height="203" alt="image" src="https://github.com/user-attachments/assets/1dd5981f-4495-4e15-b3da-a3651b9a1750" />

### 4. Expression intensity segments

Early within the analysis it was found that not every peak of brand mentions in social media is equally effective in influencing search activity. 

Mentions may contain explicit expression (positive like "I absolutely love -brand-!" or negative like "Nothing worse than -brand-") or they may simply consist of neutral product descriptions, which is often formulated by the company itself. The first major finding was that around 96% of the 273 million collected brand mentions over a two-year period were neutral in sentiment, making expressiveness a rare, highly differentiating factor of the media peak. 

A proprietary variable called expression intensity was constructed as the proportion of the sum of positive and negative mentions to the number of mentions in total stored as a percentage. The main question expression intensity variable is supposed to answer is _how loud in sentiment the peak of mentions is_? Based on this variable, it was possible to see that "loud" expressiveness is rare even in the events of media peaks.

<img width="243" height="298" alt="image" src="https://github.com/user-attachments/assets/eed8679c-77eb-4a69-860b-0dc4d5478a55" />

Based on the boxplot of this variable, it is possible to see that most media peaks have a very low expresiveness with a median of roughly 5%, meaning that in most events only 5% of all mentions in peaks are either positive or negative. Most of the peaks have the share of expression intensity ranging between roughly 2% and 12%.

The final segment scale for the original variable was designed to align with the identified distributional landmarks while providing additional granularity in zones of higher density and behavioral relevance. Lower ranges of expression intensity were split to distinguish between incidental and recurring expression presence, while the upper tail was subdivided to capture escalation effects that are not adequately represented by quartile-based grouping alone. 

Overall, 6 segments of expression intensity were identified ranging from Non-expressive to Extremely expressive: 
| Segment        | % of expressive mentions           | # of peaks in the sample  |
| ------------- |-------------| :-------------:|
| Non-expressive      | 0% | 11 |
| Minimally expressive      | 1%-3%      |   23 |
| Weakly expressive | 4%-9%     |    25 |
| Mildly expressive      | 10%-19%      |   14 |
| Highly expressive | 20%-39%      |    4 |
| Extremely expressive | 40% and more      |    7 |

This granular segmentation allowed for the detection of substantially different response patterns that would remain hidden under a simpler classification such as "high", "medium" and "low" intensity.

## Insights deep-dive: metrics construction and recommendations
