# ============================================================
# Cardiovascular Disease (CVD) Rate Analysis
# Author: Bishal Ranjan Bora
# University of Warwick — MSc Business Analytics
# ============================================================

# ── 1. Load Libraries ────────────────────────────────────────
library(tidyverse)
library(ggplot2)
library(gridExtra)
library(naniar)
library(car)
library(dplyr)

# ── 2. Load & Inspect Data ───────────────────────────────────
cvd_data <- read.csv("data/Cardio_Vascular_Disease.csv")

str(cvd_data)
summary(cvd_data)

# ── 3. Data Cleaning ─────────────────────────────────────────

# Check missing values before cleaning
cat("Missing values before cleaning:\n")
print(colSums(is.na(cvd_data)))

# Remove rows where CVD is missing (critical dependent variable)
cleaned_data <- cvd_data %>%
  drop_na(CVD)

# Confirm missing values after cleaning
cat("\nMissing values after cleaning:\n")
print(colSums(is.na(cleaned_data)))

# Check for duplicate rows
duplicate_rows <- sum(duplicated(cleaned_data))
cat("\nDuplicate rows:", duplicate_rows, "\n")

cat("\nRecords after cleaning:", nrow(cleaned_data), "\n")

# ── 4. Outlier Detection ─────────────────────────────────────
numeric_columns <- c("CVD", "Poverty", "overweight", "smokers", "wellbeing")

# Count outliers per variable using IQR method
outlier_summary <- map_df(numeric_columns, function(col) {
  Q1 <- quantile(cleaned_data[[col]], 0.25, na.rm = TRUE)
  Q3 <- quantile(cleaned_data[[col]], 0.75, na.rm = TRUE)
  IQR_value <- Q3 - Q1
  data.frame(
    Variable = col,
    Outliers = sum(
      cleaned_data[[col]] > Q3 + 1.5 * IQR_value |
      cleaned_data[[col]] < Q1 - 1.5 * IQR_value,
      na.rm = TRUE
    )
  )
})

cat("\nOutlier Summary:\n")
print(outlier_summary)

# Boxplots to visualise outliers
boxplots <- lapply(numeric_columns, function(col) {
  ggplot(cleaned_data, aes(x = "", y = .data[[col]])) +
    geom_boxplot(outlier.color = "red", outlier.shape = 19, fill = "#93c5fd") +
    labs(title = paste("Boxplot of", col), x = "", y = col) +
    theme_minimal()
})

do.call(grid.arrange, c(boxplots, ncol = 3))

# ── 5. Distribution Plots ────────────────────────────────────
hist_plots <- lapply(numeric_columns, function(col) {
  ggplot(cleaned_data, aes(x = .data[[col]])) +
    geom_histogram(aes(y = ..density..), bins = 30,
                   fill = "#1B3A5C", color = "white", alpha = 0.8) +
    stat_function(
      fun  = dnorm,
      args = list(mean = mean(cleaned_data[[col]], na.rm = TRUE),
                  sd   = sd(cleaned_data[[col]], na.rm = TRUE)),
      color = "red", linewidth = 1
    ) +
    labs(title = paste("Distribution of", col), x = col, y = "Density") +
    theme_minimal()
})

do.call(grid.arrange, c(hist_plots, ncol = 3))

# ── 6. Correlation Analysis ──────────────────────────────────

# Correlation of all predictors with CVD
correlation_with_cvd <- cleaned_data %>%
  select(CVD, overweight, smokers, Poverty, wellbeing) %>%
  cor(use = "complete.obs") %>%
  .["CVD", ]

cat("\nCorrelation with CVD:\n")
print(round(correlation_with_cvd, 3))

# Scatter plots with regression lines
predictors <- c("overweight", "smokers", "Poverty", "wellbeing")

scatter_plots <- lapply(predictors, function(var) {
  ggplot(cleaned_data, aes_string(x = var, y = "CVD")) +
    geom_point(alpha = 0.5, color = "#2E7D8C") +
    geom_smooth(method = "lm", color = "red", se = TRUE) +
    labs(title = paste(var, "vs CVD"), x = var, y = "CVD Rate") +
    theme_minimal()
})

do.call(grid.arrange, c(scatter_plots, ncol = 2))

# ── 7. Individual Linear Regressions ─────────────────────────
cat("\n══ INDIVIDUAL LINEAR REGRESSIONS ══\n")

for (var in predictors) {
  formula <- as.formula(paste("CVD ~", var))
  model   <- lm(formula, data = cleaned_data)
  cat(paste0("\nCVD ~ ", var, ":\n"))
  print(summary(model)$coefficients)
  cat(sprintf("R-squared: %.3f\n", summary(model)$r.squared))
}

# ── 8. Multiple Linear Regression ────────────────────────────
cat("\n══ MULTIPLE LINEAR REGRESSION ══\n")

multi_model <- lm(CVD ~ overweight + smokers + Poverty + wellbeing,
                  data = cleaned_data)
print(summary(multi_model))

# VIF — check for multicollinearity
cat("\nVariance Inflation Factors (VIF):\n")
print(vif(multi_model))

# ── 9. Poverty vs CVD — Key Relationship Plot ────────────────
ggplot(cleaned_data, aes(x = Poverty, y = CVD)) +
  geom_point(alpha = 0.6, color = "#2E7D8C") +
  geom_smooth(method = "lm", se = TRUE, color = "red") +
  labs(
    title    = "Effect of Poverty on CVD Prevalence",
    subtitle = "Negative relationship — wealthier areas show higher detected CVD rates",
    x        = "Poverty Level (%)",
    y        = "CVD Prevalence (%)"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title    = element_text(hjust = 0.5, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5, color = "gray50")
  )

# ── 10. Summary ──────────────────────────────────────────────
cat("\n════════════════════════════════════════════════════════\n")
cat("SUMMARY OF FINDINGS\n")
cat("════════════════════════════════════════════════════════\n")
cat("Correlations with CVD:\n")
cat(sprintf("  Overweight:  +%.3f (moderate positive)\n", correlation_with_cvd["overweight"]))
cat(sprintf("  Smokers:     +%.3f (weak positive)\n",    correlation_with_cvd["smokers"]))
cat(sprintf("  Poverty:     %.3f  (weak negative)\n",    correlation_with_cvd["Poverty"]))
cat(sprintf("  Wellbeing:   +%.3f (weak positive)\n",    correlation_with_cvd["wellbeing"]))
cat("\nMultiple Regression R-squared:", round(summary(multi_model)$r.squared, 3), "\n")
cat("\nKey insight: Poverty shows a negative relationship with CVD —\n")
cat("likely due to lower healthcare access and underdiagnosis in poorer areas.\n")
cat("════════════════════════════════════════════════════════\n")
