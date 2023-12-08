import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

# Define policy1 and policy2 with random values
policy1 = np.random.rand(10, 4)  # Assuming policy1 is a 10x4 matrix
policy2 = np.random.rand(10, 4)  # Assuming policy2 is also a 10x4 matrix


# Rest of the code...


# Assuming policy1 and policy2 are your policy matrices
# Normalize the matrices so that probabilities sum to 1 for each state
policy1 /= policy1.sum(axis=1, keepdims=True)
policy2 /= policy2.sum(axis=1, keepdims=True)

# Function to calculate entropy of probability distributions
def calculate_entropy(policy):
    return -np.sum(policy * np.log(policy + 1e-9), axis=1)

# Calculate entropy for both policies
entropy1 = calculate_entropy(policy1)
entropy2 = calculate_entropy(policy2)

# Calculate the difference in entropy
entropy_diff = np.abs(entropy1 - entropy2)

# Calculate preference-based differences
preference_diff = np.abs(policy1 - policy2)
overall_diff = np.sum(preference_diff)
avg_statewise_diff = np.mean(np.sum(preference_diff, axis=1))
avg_actionwise_diff = np.mean(preference_diff, axis=0)

# Plotting entropy differences
plt.figure(figsize=(12, 6))
plt.plot(entropy_diff, color='blue', label='Entropy Difference')
plt.title('Entropy Difference Between Two Policies')
plt.xlabel('State')
plt.ylabel('Entropy Difference')
plt.legend()
plt.show()

# Plotting the average action-wise difference
plt.figure(figsize=(8, 4))
sns.barplot(x=np.arange(4), y=avg_actionwise_diff, palette='viridis')
plt.title('Average Action-wise Preference Difference')
plt.xlabel('Action')
plt.ylabel('Average Difference in Probability')
plt.show()

# Output overall and average state-wise differences
print("Overall Preference Difference:", overall_diff)
print("Average State-wise Preference Difference:", avg_statewise_diff)
