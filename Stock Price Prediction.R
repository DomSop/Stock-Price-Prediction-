#Libraries 
library(quantmod)
library(forecast)
library(prophet)
library(xgboost)
library(ggplot2)
library(lubridate)
library(dplyr)
library(zoo)

#----

# Function to fetch stock data from Yahoo Finance
get_stock_data <- function(symbol, start_date, end_date) {
  stock_data <- tryCatch({
    getSymbols(symbol, src = "yahoo", from = start_date, to = end_date, auto.assign = FALSE)
  }, error = function(e) {
    stop("Error fetching data: ", conditionMessage(e))
  })
  
  # Convert to data frame
  stock_data <- data.frame(Date = index(stock_data), Close = Cl(stock_data))
  
  # Check for missing values and interpolate if necessary
  if (any(is.na(stock_data$Close))) {
    stock_data$Close <- na.approx(stock_data$Close, na.rm = FALSE)
  }
  
  return(stock_data)
}

# Set date range
start_date <- as.Date("2019-01-01")
end_date <- as.Date("2024-01-01")

# Load Apple stock data
stock_data <- get_stock_data("AAPL", start_date, end_date)

# View first rows
head(stock_data)


# Split into train and test (first 3 years for training, last 2 years for testing)-----
split_date <- as.Date("2022-01-01")
train_data <- stock_data %>% filter(Date < split_date)
test_data <- stock_data %>% filter(Date >= split_date)

# Ensure training data is not empty
if (nrow(train_data) == 0) {
  stop("Training dataset is empty. Check data loading and filtering.")
}

# --- ARIMA Model ----
arima_model <- auto.arima(train_data$AAPL.Close)
arima_forecast <- forecast(arima_model, h = nrow(test_data))

# --- Prophet Model ----
prophet_data <- train_data %>% rename(ds = Date, y = AAPL.Close)  # Rename columns for Prophet
prophet_model <- prophet(prophet_data , daily.seasonality=TRUE)
future <- make_future_dataframe(prophet_model, periods = nrow(test_data))
prophet_forecast <- predict(prophet_model, future)

# --- XGBoost Model ----
train_matrix <- as.matrix(train_data$AAPL.Close)
test_matrix <- as.matrix(test_data$AAPL.Close)

dmatrix_train <- xgb.DMatrix(data = train_matrix, label = train_matrix)

dmatrix_test <- xgb.DMatrix(data = test_matrix)

xgb_model <- xgboost(data = dmatrix_train, nrounds = 100, objective = "reg:squarederror", verbose = 0)
xgb_pred <- predict(xgb_model, dmatrix_test)

# Plot results----


# Ensure dates are in Date format
stock_data$Date <- as.Date(stock_data$Date)
test_data$Date <- as.Date(test_data$Date)
prophet_forecast$ds <- as.Date(prophet_forecast$ds)

# Create ggplot visualization
ggplot() +
  geom_line(data = stock_data, aes(x = Date, y = `AAPL.Close`, color = "Actual Price"), linewidth = 0.5) +
  geom_line(data = test_data, aes(x = Date, y = arima_forecast$mean, color = "ARIMA Forecast"), linetype = "dashed") +
  geom_line(data = prophet_forecast, aes(x = ds, y = yhat, color = "Prophet Forecast"), linetype = "dotted") +
  geom_line(data = test_data, aes(x = Date, y = xgb_pred, color = "XGBoost Forecast"), linetype = "dotdash") +
  labs(title = "Stock Price Prediction Comparison",
       x = "Date", y = "Stock Price (USD)") +
  scale_color_manual(values = c("Actual Price" = "black",
                                "ARIMA Forecast" = "red",
                                "Prophet Forecast" = "blue",
                                "XGBoost Forecast" = "green")) +
  theme_minimal() +
  theme(legend.position = "top")
