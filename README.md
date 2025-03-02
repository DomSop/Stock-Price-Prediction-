📈 Stock Price Prediction using ARIMA, Prophet, and XGBoost
This project uses historical stock data from Yahoo Finance to predict stock prices using ARIMA, Prophet, and XGBoost models. 
The results are visualized using ggplot2 for easy comparison.


🔹 Features
✅ Fetches stock data from Yahoo Finance using quantmod
✅ Implements three forecasting models:


ARIMA (AutoRegressive Integrated Moving Average)
Prophet (developed by Facebook for time-series forecasting)
XGBoost (Extreme Gradient Boosting for machine learning-based prediction)

✅ Data Preprocessing: Missing values are handled using interpolation
✅ Train-Test Split: First 3 years for training, last 2 years for testing
✅ Visualizes the actual and predicted stock prices
📂 Dependencies
Ensure you have the following R libraries installed:

install.packages(c("quantmod", "forecast", "prophet", "xgboost", "ggplot2", "lubridate", "dplyr", "zoo"))

🚀 How to Run
1️⃣ Set the stock symbol, start date, and end date
2️⃣ Fetch stock data using get_stock_data()
3️⃣ Train ARIMA, Prophet, and XGBoost models
4️⃣ Compare predictions with actual stock prices using ggplot2
