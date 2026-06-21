# Cardiovascular Disease (CVD) Rate Analysis

**Tools:** R · tidyverse · ggplot2 · Linear Regression · Correlation Analysis  
**Domain:** Public Health · Epidemiology · Socioeconomic Analytics  
**Context:** Individual Assignment — Business Statistics (IB94X0), University of Warwick MSc Business Analytics  
**Status:**  Complete

---

##  Project Overview

This project analyses cardiovascular disease (CVD) rates across different UK areas, examining the relationships between CVD prevalence and key health and socioeconomic factors including poverty, smoking rates, overweight percentage, and wellbeing scores.

**Business Question:** Which factors most significantly predict CVD rates across regions, and what do these relationships tell us about public health strategy?

---

##  Key Findings

| Predictor | Relationship with CVD | Coefficient | Significance |
|---|---|---|---|
| Overweight | Positive | +0.11 per 1% increase | p < 0.001 |
| Smokers | Positive | +0.12 per 1% increase | p < 0.001 |
| Poverty | **Negative** | -0.18 per 1% increase | p < 0.001 |
| Wellbeing | Positive | +1.80 per 1 unit increase | p < 0.001 |

**Correlation with CVD:**
- Overweight: **+0.319** (moderate positive)
- Smokers: **+0.178** (weak positive)
- Poverty: **-0.248** (weak negative)
- Wellbeing: **+0.245** (weak positive)

---

##  Repository Structure

```
cvd-analysis/
│
├── notebooks/
│   └── cvd_analysis.R       # Full R analysis: EDA, correlation, regression
│
└── README.md
```

---

##  Methodology

### 1. Data Cleaning
- Imported CVD dataset and checked structure using `str()` and `summary()`
- Identified and removed rows with missing CVD values (critical dependent variable)
- Checked for duplicates — none found
- Detected outliers using IQR method: poverty (6), smokers (5), wellbeing (12) had outliers

### 2. Exploratory Data Analysis
- Histograms with normal distribution overlay for all key variables
- Boxplots highlighting outliers in red
- Correlation line charts showing individual predictor relationships with CVD

### 3. Correlation Analysis
- Computed correlation matrix for CVD vs all predictors
- Overweight showed strongest positive correlation (0.319)
- Poverty showed negative correlation (-0.248) — unexpected finding worth investigating

### 4. Regression Analysis
- **Individual linear regressions** for each predictor vs CVD
- **Multiple linear regression** combining all predictors
- All four predictors statistically significant in the multiple model

---

##  Key Insight — The Poverty Paradox

One of the most interesting findings was a **negative relationship between poverty and CVD rates**. Areas with higher poverty had *lower* detected CVD rates. Possible explanations:

- Poorer individuals may have less access to healthcare, leading to underdiagnosis
- Wealthier individuals more likely to undergo regular health screenings
- Dietary differences — processed/fast food consumption patterns vary by income
- Better healthcare infrastructure in wealthier areas detecting more cases

This highlights the importance of considering **socioeconomic context** when interpreting public health data.

---

##  Sample Code

```r
# Multiple Linear Regression
multi_model <- lm(CVD ~ overweight + smokers + Poverty + wellbeing,
                  data = cleaned_data)
summary(multi_model)

# Correlation with CVD
correlation_with_cvd <- cleaned_data %>%
  select(CVD, overweight, smokers, Poverty, wellbeing) %>%
  cor(use = "complete.obs") %>%
  .["CVD", ]

print(correlation_with_cvd)
```

---

##  Business / Policy Implications

1. **Overweight is the strongest predictor** — public health campaigns targeting obesity could have the highest impact on reducing CVD rates
2. **Smoking interventions** remain relevant, though effect is smaller than overweight
3. **The poverty-CVD paradox** suggests healthcare access inequality needs addressing — poorer areas may have higher *actual* CVD but lower *detected* CVD
4. **Wellbeing's positive association** with CVD likely reflects better healthcare reporting in high-wellbeing areas, not that wellbeing causes CVD

---

##  Tools & Packages

```r
library(tidyverse)    # Data manipulation
library(ggplot2)      # Visualisation
library(gridExtra)    # Multi-panel plots
library(naniar)       # Missing value analysis
library(car)          # VIF and regression diagnostics
library(dplyr)        # Data wrangling
```

---

##  Contact

**Bishal Ranjan Bora**  
[LinkedIn](https://linkedin.com/in/bishalbora) | [Email](mailto:bora.vishal.15@gmail.com) | [GitHub](https://github.com/bishalbora1998)
