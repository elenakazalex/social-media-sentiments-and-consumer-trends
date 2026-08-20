# When Buzz Turns Into Business: How Social Media Sentiments Shape Consumer Demand

The project investigates whether **expressive social discussion of a brand, particularly unusually high-attention periods (denoted as peaks of mentions on social media), is associated with increased brand demand**. The findings were further used to **inform targeted crowd marketing strategies (injection of discussion surrounding the brand or its organic stimulation) for enterprise clients of a marketing organization**.

**Main business objective of the project**: determine whether the volume and expressive charactertiristics of online brand discussion contain actionable signals of consumer interest and whether these signals can inform more targeted digital marketing strategies.   

**Tools used**: Excel for data cleaning; R for data validation, statistical analysis and data visualization; social media monitoring platform (SCAN) and Google search query trafficking platform (KeyWorldTool) for raw data sourcing 

## Project background and business problem

This project forms part of a larger mixed methods research program examining how online brand discussions relate to consumer demand. The analysis is built upon a longitudinal, lagged research design and combines monthly social media sentiment data and Google search volume across 38 brands over two years, covering more than 270 million social media mentions.  

The central business problem was identifying whether unusually expressive online attention represents a commercially meaningful signal and whether brands should actively manage and stimulate expressive online discussion rather than simply seeking high volumes of social media mentions - all the results are directly applicable to refining choice of strategic tools of an undisclosed B2B marketing organization.

The analysis addressed four business-specific questions:
* **Does expressive online attention generate commercially relevant consumer interest?** -> When a brand experiences an unusually expressive peak in online discussion, does this attention correspond to a measurable increase in consumer search activity?
* **Does expressive attention generate immediate demand or informational curiosity or both over time??** -> Does media attention produce only immediate spikes in demand or can it be a prolonged or lagged response?
* **Can brands underdo or overdo expressive media attention?** -> Can combinations of sentiment characteristics be identified that are more closely associated with demand yet do not lead to sentiment overheating? 
* **How can brand's crowd marketing strategies be improved via sentiment injection?** -> Can brands' crowd-marketing strategies move beyond simply maximizing mention volume toward deliberately creating and managing specific levels of attention for potential consumer demand?


## Executive summary
The analysis of 270 million social media mentions of 38 brands in a 2-year period from 2023 to 2025 indicated that not simply large volumes of social media attention, but _highly expressive discussion events_ truly generate measurable consumer interest, which can be roughly approximated by informational curiosity and purchasing intent. Particularly important is the fact that generating any social media buzz is only the first half of the problem as once attention moves consumers from social platforms into search, the brand's search environment becomes part of the conversion pathway. As a result, a strategic funnel for digital marketing endeavors can be constructed: 

Social media noticeable presence (volume of mentions) → social media buzz (expressiveness of mentions) → informational search → brand evaluation (what is this brand?) → commercial consideration 

If someone sees a highly expressive discussion about a brand, becomes curious, searches the brand and then encounters negative reviews, poor search results, misleading information or unfavorable third-party content, the attention-generation strategy may have created the opportunity while the search environment destroyed the commercial value of that opportunity. The main takeaway is that it is essential for brands to consider not only the discussion surrounding it on social media (to capture initial attention), but go beyond that to ensure its entire online reputation (search engine output, review platforms, forums, etc.) retains this attention and can instigate actual purchase rather discourage it. 

**Sentiments drive differention in online visibility of a brand:** Out of 273 million mentions processed for a 2-year period, only roughly 96% are sentiment-driven, meaning emotions are expressed rarely by users on social media overall, making non-neutral textual discussions a critical factor for brands to stand out in saturated markets and activate demand for its product or services. 

* High volume of brand discussion online is important but useless without user-driven sentiments:
The emotional character of discussion provides additional information about its potential relationship with consumer demand

* User-driven expression-intensive online discussions are more important for driving informational curiosity towards brands and demand for their goods or services than neutral discussions, such as ads 


## Insights deep-dive 

### Analytical workflow

<img width="1286" height="177" alt="image" src="https://github.com/user-attachments/assets/66d3a3c3-db05-4e67-b444-c319064306ff" />

1. Raw mentions: 270M+ records
2. Detection of media buzz events: detection of "peak" of mentions based on statistical normalization (Z statistic and standard deviation, mathematically derived as higher than >1 stdev from the baseline level of each brand's mention)
3. Event-based transformation of Google search volume as a proxy for demand:
4. Panel dataset: peak-based longitudinal dataset with 89 records
5. Validation: OLS 
