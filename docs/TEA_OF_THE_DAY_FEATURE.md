# Tea of the Day Feature Design

## 1. Introduction

This document provides a detailed design for the "Tea of the Day" feature. The goal of this feature is to provide users with a daily recommendation for a tea from their collection. The recommendation will be based on a scoring system that takes into account multiple criteria, including the weather, the user's recent consumption history, and the expiration date of the tea.

## 2. Goals

The goals of the "Tea of the Day" feature are to:

*   Encourage users to explore their entire tea collection.
*   Provide personalized and relevant recommendations.
*   Create a more engaging and delightful user experience.

## 3. Scoring System

The "Tea of the Day" will be chosen using a scoring system. Each tea in the user's collection will be assigned a score based on how well it matches a set of criteria. The tea with the highest score will be chosen as the "Tea of the Day."

### 3.1. Criteria and Weights

The following criteria will be used to calculate the score for each tea:

*   **Weather:** +10 points
*   **Recent Consumption:** -5 points
*   **Expiration Date:** +5 points
*   **User Ratings:** 0 points (for now)
*   **Day of the Week:** +5 points

These weights can be adjusted to fine-tune the recommendation algorithm.

## 4. Criteria

### 4.1. Weather

The weather criterion will be based on the current weather conditions at the user's location. The app will use a weather API to get the current weather, and then it will assign a score to each tea based on how well it matches the weather.

**Example:**

*   If it is a cold and rainy day, a warm, spicy tea might get a high score.
*   If it is a hot and sunny day, a light, fruity tea might get a high score.

### 4.2. Recent Consumption

The recent consumption criterion will be used to encourage variety. The app will track the user's tea consumption history, and it will assign a negative score to teas that have been consumed recently.

**Example:**

*   A tea that was consumed yesterday might get a score of -5.
*   A tea that was consumed two days ago might get a score of -3.

### 4.3. Expiration Date

The expiration date criterion will be used to encourage users to drink teas that are about to expire. The app will assign a positive score to teas that are close to their expiration date.

**Example:**

*   A tea that expires in the next week might get a score of +5.
*   A tea that expires in the next month might get a score of +2.

### 4.4. User Ratings

The user ratings criterion will be used to recommend teas that the user is likely to enjoy. The app will allow users to rate their teas, and it will assign a positive score to teas that have a high rating.

**Note:** For the initial implementation, this criterion will have a weight of 0.

### 4.5. Day of the Week

The day of the week criterion will be used to provide themed recommendations. For example, the app could have a different theme for each day of the week.

**Example:**

*   **Motivation Monday:** An energizing tea.
*   **Wellness Wednesday:** A healthy herbal tea.
*   **Fruity Friday:** A fun, fruity tea.

## 5. Implementation Plan

### 5.1. Backend

*   **Update the `adviser` package:** The `adviser` package will need to be updated to implement the new scoring system.
*   **Update the `teaOfTheDay` resolver:** The `teaOfTheDay` resolver will need to be updated to call the new `TeaOfTheDay` function in the `adviser` package.

### 5.2. Frontend

*   **Update the `TeaOfTheDayWidget`:** The `TeaOfTheDayWidget` will need to be updated to use the new `teaOfTheDay` query.
*   **Add a weather service:** The app will need to be integrated with a weather API to get the current weather conditions.
