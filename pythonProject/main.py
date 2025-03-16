import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Load data
data = pd.read_csv('population_2019.csv')

# Total population by voivodeship
total_by_voivodeship = data.groupby('voivodeship')['n_people'].sum().sort_values(ascending=False)
print("Total Population by Voivodeship:\n", total_by_voivodeship)

# Plot total population by voivodeship
plt.figure(figsize=(12, 10))
total_by_voivodeship.plot(kind='bar')
plt.title('Total Population by Voivodeship (2019)')
plt.ylabel('Population')
plt.xticks(rotation=45)
plt.tight_layout()
plt.savefig('total_population_by_voivodeship.png') # saving plot as image
plt.show()

# Gender distribution
gender_distribution = data.groupby('sex')['n_people'].sum()
print("\nGender Distribution:\n", gender_distribution)

# Plot gender distribution
sns.barplot(x=gender_distribution.index, y=gender_distribution.values)
plt.title('Gender Distribution (2019)')
plt.ylabel('Population')
plt.savefig('gender_distribution.png')
plt.show()

# Population by age group
age_group_distribution = data.groupby('age_group')['n_people'].sum().sort_index()
print("\nPopulation by Age Group:\n", age_group_distribution)

# Plot population by age group
plt.figure(figsize=(12, 6))
age_group_distribution.plot(kind='bar')
plt.title('Population by Age Group (2019)')
plt.ylabel('Population')
plt.xticks(rotation=45)
plt.tight_layout()
plt.savefig('population_by_age_group.png')
plt.show()

# Urban vs Rural population
area_distribution = data.groupby('area_type')['n_people'].sum()
print("\nUrban vs Rural Population:\n", area_distribution)

# Plot urban vs rural distribution
sns.barplot(x=area_distribution.index, y=area_distribution.values)
plt.title('Urban vs Rural Population (2019)')
plt.ylabel('Population')
plt.savefig('urban_vs_rural_population.png')
plt.show()