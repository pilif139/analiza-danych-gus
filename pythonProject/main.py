import pandas as pd
import matplotlib.pyplot as plt

# to show available styles
# print(plt.style.available)
plt.style.use("ggplot")

data = pd.read_csv("../dane_demograficzne_2024.csv", skipinitialspace=True)

data.replace('X', pd.NA, inplace=True)
data.dropna(subset='Population', inplace=True)
data['Population'] = data['Population'].astype(float)

# men and woman death comparison
pivot_table = data.pivot_table(index='Category', values='Deaths', aggfunc='sum')
comparison = pivot_table.loc[['Men', 'Women']]

ax = comparison.plot(kind='bar', stacked=False)
plt.title('Comparison of Deaths between Men and Women')
plt.ylabel('Number of Deaths')
plt.xlabel('Gender')
plt.xticks(rotation=0)
plt.tight_layout()
for p in ax.patches:
    ax.annotate(str(int(p.get_height())), (p.get_x() * 1.01, p.get_height() * 1.01))
plt.savefig('comparison_deaths_men_women.png')
plt.show()

# population in diffrent areas comparison

pivot_table = data.pivot_table(index='Category', values='Population', aggfunc='sum')
comparison = pivot_table.loc[['Cities', 'Villages', 'Urban-Rural Municipalities']] # Urban-Rural Municipalities - Gminy miejsko wiejskie
ax = comparison.plot(kind='bar', stacked=True, edgecolor='black')
plt.title('Comparison of Population in Different Areas')
plt.ylabel('Number of People')
plt.xlabel('Area')
plt.xticks(rotation=0)
plt.tight_layout()
for p in ax.patches:
    ax.annotate(f"{int(p.get_height()):,}".replace(",", " "), (p.get_x() * 1.01, p.get_height() * 1.01))
plt.savefig('comparison_population_areas.png')
plt.show()

