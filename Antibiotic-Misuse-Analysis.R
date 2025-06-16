# Libraries
library(MASS)        
library(ggplot2)     
library(dplyr)       

# Set seed for reproducibility
set.seed(123)

# Simulate dataset
n <- 704
df <- data.frame(
  age = sample(c("<25", "25-35", "36-45", ">45"), n, prob = c(0.1, 0.3, 0.3, 0.3), replace = TRUE),
  sex = sample(c("Male", "Female"), n, prob = c(0.22, 0.78), replace = TRUE),
  education = sample(c("Primary", "Secondary", "Higher"), n, prob = c(0.2, 0.22, 0.58), replace = TRUE),
  employment = sample(c("Employed", "Unemployed"), n, prob = c(0.6, 0.4), replace = TRUE),
  income = sample(c("Low", "Middle", "High"), n, prob = c(0.3, 0.4, 0.3), replace = TRUE),
  child_age = sample(5:15, n, replace = TRUE),
  family_type = sample(c("Nuclear", "Extended"), n, replace = TRUE)
)

# Create numeric knowledge score
df$knowledge_score <- round(rnorm(n, mean = ifelse(df$education == "Higher", 7, 5), sd = 1.5))

# Categorize knowledge
df$knowledge_cat <- cut(df$knowledge_score,
                        breaks = c(-Inf, 4, 7, Inf),
                        labels = c("Poor", "Moderate", "Good"),
                        right = TRUE)

# Create attitude score (based on knowledge + randomness)
df$attitude_score <- round(rnorm(n, mean = ifelse(df$knowledge_cat == "Good", 7, 5), sd = 1.2))

# Categorize attitude
df$attitude_cat <- cut(df$attitude_score,
                       breaks = c(-Inf, 4, 7, Inf),
                       labels = c("Negative", "Uncertain", "Positive"),
                       right = TRUE)

# Simulate misuse based on attitude and income
logit_p <- -1 + 
  0.5 * (df$attitude_cat == "Positive") + 
  0.3 * (df$income == "High") -
  0.4 * (df$knowledge_cat == "Good")

df$misuse <- rbinom(n, 1, plogis(logit_p))


# Run Regression Models


# 1. Linear Regression: Predicting knowledge_score
lm_knowledge <- lm(knowledge_score ~ age + sex + education + income, data = df)
summary(lm_knowledge)

# 2. Ordinal Logistic Regression for attitude_cat
model_attitude <- polr(attitude_cat ~ age + sex + education + income + knowledge_cat, data = df, Hess = TRUE)
summary(model_attitude)

# Odds Ratios + 95% CI
exp(cbind(OR = coef(model_attitude), confint(model_attitude)))

# 3. Binary Logistic Regression: Predicting misuse
glm_practice <- glm(misuse ~ age + sex + education + income + knowledge_cat + attitude_cat,
                    family = binomial, data = df)
summary(glm_practice)

# Odds Ratios + CI
exp(cbind(OR = coef(glm_practice), confint(glm_practice)))

