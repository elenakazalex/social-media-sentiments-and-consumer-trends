# How Media Attention Translates into Demand: An Event-Based Analysis of Brand Discussion Online

The project investigates whether expressive social discussion of a brand, particularly unusually high-attention periods (denoted as peaks of mentions on social media), is associated with increased brand demand. The findings were further used to inform targeted crowd marketing strategies (injection of discussion surrounding the brand or its organic stimulation) for enterprise clients of a marketing organization. 

**Main business objective of the project**: Examine whether generating high-volume sentiment-driven online discussion around a brand creates commercially meaningful consumer interest and whether more expression necessarily produces more demand. The analysis was designed to support data-driven crowd-marketing decisions by distinguishing between attention that simply generates online buzz and attention that is associated with measurable changes in consumer search behavior.  

**Main business outcome**: The analysis established **Peak to Demand Response metric** (the percentage change in brand search demand following an expressive social media attention peak measured against the pre-event baseline) as the primary commercial outcome used to evaluate whether attention generated through crowd marketing corresponded with immediate or delayed consumer interest, while the newly proposed **Expression Intensity segmentation** helped identify whether maximizing sentiments is actually optimal for driving purchasing consideration.

**Tools used**: Excel for data cleaning; R for data validation, statistical analysis and data visualization; social media monitoring platform (SCAN) and Google search query trafficking platform (KeyWordTool) for raw data sourcing 

## Table of contents

- [Project background and business problem](#project-background-and-business-problem)
- 

## Project background and business problem

This project forms part of a larger mixed methods research program examining how online brand discussions relate to consumer demand. The analysis is built upon an event-study research design and combines monthly social media sentiment data and Google search volume across 38 brands over 2 years, covering more than 270 million social media mentions.  

The central business problem was identifying whether unusually expressive online attention represents a commercially meaningful signal and whether brands should actively manage and stimulate expressive online discussion rather than simply seeking high volumes of social media mentions - all the results are directly applicable to refining choice of strategic crowd marketing approaches of an undisclosed B2B digital marketing organization. 

**The analysis addressed 4 business-specific questions**:
* **Does social media buzz generate commercially relevant consumer interest?** -> When a brand experiences an unusually high jump in online discussion volumes, does this attention correspond to a measurable increase in consumer search activity?
* **Should brands' crowd marketing strategies be extremely sentiment-driven?** -> Can purely neutral postings create the same amount of informational curiosity and purchasing consideration as extremely positive postings?
* **Can brands' social media presence be overheated in sentiment?** -> Are there optimal levels of sentiment that are associated with both informational curiosity and purchasing intent? 
* **Is the translation of social media buzz into informational curiosity and purchasing consideration immediate and can be seen in the same month?** -> Does media attention produce only immediate spikes in demand or can it be a lagged and sustained response?

## Executive summary

Analysis of 38 brands over 2 years based on 270M+ social media mentions shows that the commercial value of online attention cannot be evaluated by mention volume alone. Extremely sentiment-driven media attention (e.g., intense positvity) was also revealed to not be significantly associated with the most commercially optimal outcomes, meaning that carefully weighted injection of sentiments in crowd marketing posts is better translated into informational curiosity and purchasing consideration.  

From the perspective of brand's online reputation management, the findings also suggest that once sentiment-driven social attention prompts consumers to investigate a brand, the search environment becomes part of the conversion pathway. Generating attention therefore creates an opportunity but the information users encounter afterward can determine whether that curiosity develops into meaningful commercial interest. As a result, a strategic funnel can be constructed: 

Social media buzz (volume and expressiveness of mentions) → informational curiosity → brand evaluation (what is this brand?) → commercial consideration 

The resulting framework shifts crowd marketing from simply generating as much buzz as possible toward obtaining the right volume and share of expressiveness of attention. The analysis consequently provides both an actionable framework for attention-generation and ORM strategy and a foundation for further research into how different forms of expressive discussion influence the progression from online attention to consumer demand.


## Analytical workflow

<img width="965" height="134" alt="image" src="https://github.com/user-attachments/assets/66d3a3c3-db05-4e67-b444-c319064306ff" />

1. Raw mentions: 270M+ records
2. Detection of media buzz events: detection of "peak" of mentions based on statistical normalization (Z statistic and standard deviation, mathematically derived as higher than >1 stdev from the baseline level of each brand's mention)
3. Event-based transformation of Google **search volume as a proxy for consumer demand**: informational search queries (e.g., SKIMS reviews, Balenciaga products) for informational curiosity approximation and transactional search queries (e.g., SKIMS buy) for purchasing intent approximation    
4. Final dataframe: peak-based event dataset with 84 records of search change spanning t-1 to t+2 (pre-peak baseline to 2 months after the peak)
5. Validation: OLS 

### 1. Data and relationships

The analysis was based on a total of 4 connected tables derived from raw data of over 270 million social media mentions. Join key: composite key of brand and month of the peak of mentions, both attributes are individually non-unique but their combination identifies the corresponding observation. 

<img width="454" height="354" alt="image" src="https://github.com/user-attachments/assets/64bc535e-ab17-4306-940c-e2bc032b7126" />

The pre-hoc industry segmentation served as a structural control for brand selection, ensuring that further patterns identified were not driven by isolated or non-comparable brand cases: minimum of 2 structurally similar brands per segment. For each brand number of social media mentions and search frequency volumes were collected for the period of Dec 2023 – Nov 2025 (24 months). 

<details>
  <summary> Overview of the brands included in the sample: </summary> 

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

</details>

### 2. Initial exploratory analysis 

Preliminary correlation analysis of search volume and social media mentions volume revealed diverse dynamics between the two variables. While some "jumps" in mentions appeared to be correlated either at the same month (t0) or next month (t+1) with search frequency jumps, some others appear to be almost obsolete: 

<img width="499" height="374" alt="image" src="https://github.com/user-attachments/assets/9a54365b-2865-4bcb-8c7d-968aa4164429" />

Moreover, the raw volumes of mentions for brands was largely incomparable due to the presence of largely discussed brands on average (e.g., Spotify) and brands with less than noticeable average social media presence (e.g., VeriSource).

<img width="1918" height="453" alt="image" src="https://github.com/user-attachments/assets/d0dba95c-52f3-43ba-a44f-2f8e3955cfd4" />

The EDA demonstrated two major insights: all of the brands in the sample have _distinctly vivid outliers_ in social media mentions volumes with _incomparable raw values_. The need for normalization of variables was identified.

### 3. Standardization, identification of peaks and event table construction

Peaks of mentions were determined based on Z standardization as Z scores above 1 standard deviation from the mean of the brand’s average monthly mentions volume. Values outside ±1 st. dev were considered meaningful deviations from the baseline behavior, indicating media events that may require special attention or response from the brand. As a result of peak identification, a new dataframe with 84 records of "media peaks" was constructed. 

<details>
  <summary> <i>Snippet of the peak table:</i> </summary>  

<img width="212" height="205" alt="image" src="https://github.com/user-attachments/assets/cf923dcc-30d1-4b97-8790-25a27f927cb7" />

</details>
  
In order to understand the demand outcome of such media events, an event study approach was used to construct a full social media peak to search response dataset:
consolidating data for 84 mention peaks with search frequency changes from a month before the peak (t-1) to the month of the media peak (t0), the following month (t+1) and 2 months after (t+2). Notably, the search volume change for each event was calculated from the pre-peak month (t-1) as the baseline equal to 0, so that change_t0 was a percentage change in the search volume at the month of the peak from t-1, change_t1 as a percentage change in the following month from t-1 and so on for aggregate search volumes, as well as informational and transactional search queries separately.

<details>
  <summary> <i>Snippet of the event table:</i> </summary>

<img width="356" height="203" alt="image" src="https://github.com/user-attachments/assets/1dd5981f-4495-4e15-b3da-a3651b9a1750" />
</details>

### 4. Expression intensity segments

Early within the analysis it was found that not every peak of brand mentions in social media is equally effective in influencing search activity. 

Mentions may contain explicit expression (positive like "I absolutely love -brand-!" or negative like "Nothing worse than -brand-") or they may simply consist of neutral product descriptions, which is often formulated by the company itself. The first major finding was that **around 96% of the 273 million collected brand mentions over a two-year period were neutral in sentiment, making expressiveness a rare, highly differentiating factor of the media peak**. 

A proprietary variable called expression intensity was constructed as the proportion of the sum of positive and negative mentions to the number of mentions in total stored as a percentage. The main question expression intensity variable is supposed to answer is _how loud in sentiment the peak of mentions is_? Based on this variable, it was possible to see that "loud" expressiveness is rare even in the events of media peaks.

<img width="243" height="298" alt="image" src="https://github.com/user-attachments/assets/eed8679c-77eb-4a69-860b-0dc4d5478a55" />

Based on the boxplot of this variable, it is possible to see that most media peaks have a very low expresiveness with a median of roughly 5%, meaning that in most events only 5% of all mentions in peaks are sentiment-driven. Most of the peaks have the share of expression intensity ranging between roughly 2% and 12%.

The final segment scale for the original variable was designed to align with the identified distribution shape while providing additional granularity in zones of higher density and behavioral relevance. Lower ranges of expression intensity were split to distinguish between incidental and recurring expression presence, while the upper tail was subdivided to capture escalation effects that are not adequately represented by quartile-based grouping alone. 

Overall, 6 segments of expression intensity were identified ranging from Non-expressive to Extremely expressive: 
| Segment        | % of expressive mentions           | # of peaks in the sample  |
| ------------- |-------------| :-------------:|
| Non-expressive      | 0% | 11 |
| Minimally expressive      | 1%-3%      |   23 |
| Weakly expressive | 4%-9%     |    25 |
| Moderately expressive      | 10%-19%      |   14 |
| Highly expressive | 20%-39%      |    4 |
| Extremely expressive | 40% and more      |    7 |

This granular segmentation allowed for the detection of substantially different response patterns that would remain hidden under a simpler classification such as "high", "medium" and "low" intensity.

## Insights deep-dive

### General insights

<img width="1882" height="442" alt="image" src="https://github.com/user-attachments/assets/689d7e19-b8e2-4815-94c1-335cd8446eee" />

**1. Social media buzz with no expressive share does not translate into search demand:** The absence of emotional expression in brand mentions does not produce a consistent effect on conversion into search activity. This suggests that purely neutral informational mentions are generally insufficient to stimulate a systematic behavioral response from audiences. Potential explanation behind such trend could be that Non-Expressive content tends to be informational and self-contained leaving little informational uncertainty that would motivate follow-up searches. 

**2. Moderate Expression intensity (10-19% of expressive share) can be marked as the threshold where search becomes more responsive to social media buzz:** Moderate expressiveness is clearly distinguished from the lower segments, meaning that such social media peaks demonstrate a more visible conversion path from buzz to search about brands and products.

**3. High levels of expression (at least every 5th posting is sentiment-driven) is associated with an immediate large jump in search activity:** Highly sentimentally-harged attention spikes in social media generate visible and persistent search responses extending at least 1 month into the peak. This segment shows the most dramatic drop in the search frequency at t+1, meaning that search activity needs to be stimulated constantly rather than episodically to be sustained at extreme levels.

**4. Extreme levels of expression (above 40% of sentiment-driven postings) reveal a somewhat lagged search activation:** Such mentions peaks demonstrate slower decay patterns associated with sustained rather than explosive attention suggesting prolonged search interest rather than its immediate amplification. Extremely sentimental media buzz may prioritize social validation and opinion alignment on social media over factual exploration, which shifts attention from search engines to peer discourse but can be translated into informational curiosity and purchasing intent with a lag. 

### Segment-wise analysis

After introducing categories of search queries and dividing them into informational (proxy for informational curiosity) and transactional (purchasing consideration), prior insights were further expanded:

<img width="1917" height="481" alt="image" src="https://github.com/user-attachments/assets/b546c32e-9b57-41b4-9d0b-f26dd314efa9" />

<img width="1912" height="442" alt="image" src="https://github.com/user-attachments/assets/9528950f-ff6e-40a4-bac3-36b6561304c0" />

**1. Non-expressive media peaks are the least optimal for driving both informational curiosity about the brand and transactional intent:** In comparison to higher levels of expression, they produce negligible search activity. The lack of expressive component in media buzz can be seen as a detrimental factor for driving demand.
 
**2.  The Moderate intensity pattern contributes to identifying the conditions under which media events generate more sustained longer-term effects, enabling brands to enhance awareness and build equity:** Although the 3 expression levels exhibit broadly similar dynamics across both search types with a predominantly immediate response at the month of the peak of mentions (t0), the decline in subsequent months is less prominent for Moderately expressive peaks.

<img width="1918" height="492" alt="image" src="https://github.com/user-attachments/assets/4638d1f6-d844-47dd-a2ec-2ebac2c59e88" />

**3. Extremely expressive media buzz is likely to be associated with prominent informational curiosity but does not demonstrate acceleration in purchasing intent among users:** Sentiments can be overheated (at least every 3rd posting on social media is sentiment-driven) when users' informational curiosity overrides transactional intent. Possible premise behind such behavior could be that overheated sentiments on social media could be seen as deviant, thus, requiring informational check on the brand and products. As a result, informational outputs in search engines become another stage in the customer journey where it is essential for brands to demonstrate their advantages.

**4. High expression intensity (20-39% share of sentiments) can be viewed as the optimal sentiment injection level, where informational curiosity drives consequential purchasing intent:** Informational activity skyrockets at the same time as the peak of media visibility occurs but transactional intent continues accelerating beyond the month of the media buzz, creating a sustained commercial effect. 

## Recommendations

**1. Use expression intensity segmentation to move from generic crowd marketing to event-specific intervention**
Teams can classify emerging or historical peaks by expression intensity and expected demand response, adjust intervention accordingly by amplifying under-expressive events where additional expressive discussion may be beneficial, maintaining commercially productive high-expression levels and avoiding unnecessary escalation toward extreme expressiveness when the objective is purchasing consideration. This transforms crowd marketing from a volume-generation tactic into a measurable segment-based optimization process.

**2. Social media buzz should be optimized for commercially productivity and not simply maximum visibility or loudest sentiments**
Crowdmarketing strategies should avoid treating maximum expressiveness as the default objective. The segmentation indicates that high expression intensity (20–39% expressive mentions) provides a more commercially favorable balance between generating informational curiosity and stimulating subsequent transactional search activity, whereas extremely expressive peaks can generate substantial attention without a comparable increase in purchasing consideration. 

**3. Treat media attention peak as the beginning of the consumer journey**
Social media attention can produce different responses across time: informational curiosity may emerge around the attention peak, while commercially oriented search behavior can develop later. 

**4. Stimulate the conversion from media buzz to purchasing intent**
Once sentiment-driven buzz helps users initiate search about the brand, the search results they encounter become a critical downstream touchpoint. Crowd marketing and search output should be thus treated as a funnel: generate attention -> stimulate curiosity -> ensure favorable search visibility -> support commercial consideration. Campaign planning should incorporate simultaneous monitoring of search results, reviews, third-party content and other high-visibility information that could strengthen or undermine the demand response generated by social attention.
