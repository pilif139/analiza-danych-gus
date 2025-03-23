# Enhanced Analysis of Working Population by Age and Gender
# Load necessary packages
library(tidyverse)  # For data manipulation and visualization
library(readr)      # For reading CSV files
library(scales)     # For better axis formatting
library(ggthemes)   # For enhanced themes
library(patchwork)  # For combining multiple plots

# Import the data
population_data <- read_csv("data/working_people_ages.csv")

# Inspect the data
head(population_data)
summary(population_data)
str(population_data)

# Basic data cleaning and preparation
population_clean <- population_data %>%
  # Convert Age to factor for better handling of the "85+" category
  mutate(Age = factor(Age, levels = c(as.character(15:84), "85+"))) %>%
  # Add Total and Gender Ratio columns
  mutate(
    Total = Men + Women,
    Gender_Ratio = (Men / Women) * 100
  )

# Print summary statistics
cat("Total working men:", sum(population_clean$Men), "thousand\n")
cat("Total working women:", sum(population_clean$Women), "thousand\n")
cat("Total working population:", sum(population_clean$Total), "thousand\n")
cat("Overall gender ratio:", (sum(population_clean$Men) / sum(population_clean$Women) * 100), "men per 100 women\n")

# Convert to long format for some visualizations
population_long <- population_clean %>%
  pivot_longer(cols = c(Men, Women), 
               names_to = "Gender", 
               values_to = "Population")

# Set a common theme with white background for all plots
white_theme <- theme_minimal() +
  theme(
    panel.background = element_rect(fill = "white", color = NA),
    plot.background = element_rect(fill = "white", color = NA),
    panel.grid.minor = element_blank(),
    legend.background = element_rect(fill = "white", color = NA),
    plot.title = element_text(face = "bold"),
    plot.subtitle = element_text(face = "italic")
  )

# VISUALIZATIONS

# 1. Enhanced Population Pyramid
pyramid_plot <- ggplot(population_clean) +
  geom_bar(aes(x = Age, y = Men, fill = "Men"), stat = "identity") +
  geom_bar(aes(x = Age, y = -Women, fill = "Women"), stat = "identity") +
  coord_flip() +
  scale_fill_manual(values = c("Men" = "#4169E1", "Women" = "#FF69B4")) +
  labs(
    title = "Population Pyramid by Age and Gender",
    subtitle = "Working Population (in thousands)",
    x = "Age",
    y = "Population (thousands)",
    fill = "Gender"
  ) +
  scale_y_continuous(
    labels = function(x) paste0(abs(x)),
    breaks = seq(-250, 250, 50)
  ) +
  white_theme +
  theme(legend.position = "bottom")

# Save the pyramid plot
ggsave("plots/population_pyramid.png", pyramid_plot, width = 10, height = 12, bg = "white")

# 2. Age Distribution - Smoothed Population Curves
smoothed_curves <- ggplot(population_long, aes(x = as.integer(as.character(Age)), y = Population, color = Gender)) +
  geom_point(alpha = 0.6) +
  geom_smooth(aes(group = Gender), se = FALSE, span = 0.3) +
  scale_color_manual(values = c("Men" = "#4169E1", "Women" = "#FF69B4")) +
  labs(
    title = "Age Distribution of Working Population",
    subtitle = "Smoothed population curves showing trends by gender",
    x = "Age",
    y = "Population (thousands)"
  ) +
  white_theme +
  theme(legend.position = "bottom")

# Save the smoothed curves plot
ggsave("plots/age_distribution_smoothed.png", smoothed_curves, width = 10, height = 8, bg = "white")

# 3. Gender Ratio by Age - Enhanced
gender_ratio_plot <- ggplot(population_clean, aes(x = as.integer(as.character(Age)), y = Gender_Ratio)) +
  geom_line(size = 1, color = "purple") +
  geom_point(color = "purple", alpha = 0.7) +
  geom_smooth(method = "loess", se = TRUE, color = "darkred", span = 0.3, alpha = 0.2) +
  geom_hline(yintercept = 100, linetype = "dashed", color = "gray50", size = 0.8) +
  annotate("text", x = 80, y = 105, label = "Equal ratio (100)", color = "gray50") +
  labs(
    title = "Gender Ratio by Age in Working Population",
    subtitle = "Men per 100 Women (Values > 100 indicate more men than women)",
    x = "Age",
    y = "Men per 100 Women"
  ) +
  scale_y_continuous(breaks = seq(80, 180, 20)) +
  scale_x_continuous(breaks = seq(15, 85, 5)) +
  white_theme

# Save the gender ratio plot
ggsave("plots/gender_ratio_by_age.png", gender_ratio_plot, width = 10, height = 8, bg = "white")

# 4. Age Group Analysis
# Create age groups
population_age_groups <- population_clean %>%
  mutate(
    Age_Group = case_when(
      Age %in% as.character(15:24) ~ "15-24",
      Age %in% as.character(25:34) ~ "25-34",
      Age %in% as.character(35:44) ~ "35-44",
      Age %in% as.character(45:54) ~ "45-54",
      Age %in% as.character(55:64) ~ "55-64",
      Age %in% as.character(65:74) ~ "65-74",
      Age %in% c(as.character(75:84), "85+") ~ "75+",
      TRUE ~ "Other"
    )
  ) %>%
  group_by(Age_Group) %>%
  summarize(
    Total_Men = sum(Men),
    Total_Women = sum(Women),
    Total = Total_Men + Total_Women,
    Gender_Ratio = (Total_Men / Total_Women) * 100,
    Percent_of_Workforce = (Total / sum(population_clean$Total)) * 100
  ) %>%
  ungroup() %>%
  arrange(factor(Age_Group, levels = c("15-24", "25-34", "35-44", "45-54", "55-64", "65-74", "75+")))

# Print the age group summary
print(population_age_groups)

# 5. Age Group Visualization - Stacked Bar Chart
age_group_plot <- ggplot(population_age_groups, aes(x = Age_Group)) +
  geom_col(aes(y = Total, fill = Age_Group)) +
  geom_text(aes(y = Total + 100, label = paste0(round(Total), "k")), 
            size = 3.5, fontface = "bold") +
  geom_text(aes(y = Total/2, 
                label = paste0(round(Percent_of_Workforce, 1), "%")),
            color = "white", fontface = "bold") +
  scale_fill_brewer(palette = "Set3") +
  labs(
    title = "Working Population by Age Group",
    subtitle = "Total in thousands with percentage of total workforce",
    x = "Age Group",
    y = "Population (thousands)"
  ) +
  white_theme +
  theme(
    legend.position = "none",
    axis.text.x = element_text(angle = 0)
  )

# Save the age group plot
ggsave("plots/age_groups.png", age_group_plot, width = 10, height = 8, bg = "white")

# 6. Gender Distribution by Age Group
age_group_gender <- population_age_groups %>%
  pivot_longer(cols = c(Total_Men, Total_Women),
               names_to = "Gender",
               values_to = "Population") %>%
  mutate(Gender = str_replace(Gender, "Total_", ""))

gender_by_age_group <- ggplot(age_group_gender, aes(x = Age_Group, y = Population, fill = Gender)) +
  geom_col(position = "dodge") +
  geom_text(aes(label = round(Population)),
            position = position_dodge(width = 0.9),
            vjust = -0.5, size = 3) +
  scale_fill_manual(values = c("Men" = "#4169E1", "Women" = "#FF69B4")) +
  labs(
    title = "Gender Distribution by Age Group",
    subtitle = "Working population in thousands",
    x = "Age Group",
    y = "Population (thousands)"
  ) +
  white_theme +
  theme(legend.position = "bottom")

# Save the gender by age group plot
ggsave("plots/gender_by_age_group.png", gender_by_age_group, width = 10, height = 8, bg = "white")

# 7. Gender Ratio by Age Group - Heatmap
ratio_heatmap <- ggplot(population_age_groups, aes(x = Age_Group, y = "Gender Ratio", fill = Gender_Ratio)) +
  geom_tile() +
  geom_text(aes(label = paste0(round(Gender_Ratio, 1))), color = "white", fontface = "bold") +
  scale_fill_gradient2(low = "pink", mid = "white", high = "steelblue", 
                       midpoint = 100,
                       limits = c(min(population_age_groups$Gender_Ratio) - 5, 
                                  max(population_age_groups$Gender_Ratio) + 5)) +
  labs(
    title = "Gender Ratio by Age Group",
    subtitle = "Men per 100 Women (Blue = more men, Pink = more women)",
    x = "Age Group",
    fill = "Ratio"
  ) +
  white_theme +
  theme(
    axis.title.y = element_blank(),
    axis.text.y = element_blank(),
    panel.grid = element_blank()
  )

# Save the ratio heatmap
ggsave("plots/ratio_heatmap.png", ratio_heatmap, width = 10, height = 4, bg = "white")

# 8. Combined Dashboard (using patchwork)
top_row <- pyramid_plot | gender_ratio_plot
bottom_row <- age_group_plot | gender_by_age_group
dashboard <- (top_row / bottom_row) + 
  plot_annotation(
    title = "Working Population Demographics Analysis",
    subtitle = "Analysis of population distribution by age and gender",
    theme = theme(
      plot.title = element_text(size = 18, face = "bold"),
      plot.subtitle = element_text(size = 12, face = "italic"),
      plot.background = element_rect(fill = "white", color = NA)
    )
  )

# Save the dashboard
ggsave("plots/demographics_dashboard.png", dashboard, width = 16, height = 14, bg = "white")

# Export the processed data
write_csv(population_clean, "processed_data/population_clean.csv")
write_csv(population_age_groups, "processed_data/population_age_groups.csv")

# Print final summary
cat("\nAnalysis completed! Key findings:\n")
cat("- Peak working age (highest population):", 
    population_clean %>% arrange(desc(Total)) %>% pull(Age) %>% head(1), "\n")
cat("- Age group with highest population:", 
    population_age_groups %>% arrange(desc(Total)) %>% pull(Age_Group) %>% head(1), "\n")
cat("- Age group with highest gender disparity:",
    population_age_groups %>% arrange(desc(abs(Gender_Ratio - 100))) %>% pull(Age_Group) %>% head(1), "\n")
cat("- The gender ratio shows a clear pattern by age, with", 
    ifelse(sum(population_clean$Gender_Ratio > 100) > sum(population_clean$Gender_Ratio < 100),
           "generally more men than women in the workforce.",
           "generally more women than men in the workforce."), "\n")