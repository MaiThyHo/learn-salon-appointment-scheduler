#!/bin/bash

# Display services
echo "Please choose a service:"
PSQL="psql -U postgres -d salon -t -c"  # PSQL connection variable

# Display services in a numbered list
SERVICES=$($PSQL "SELECT service_id, name FROM services;")
echo "$SERVICES" | while IFS='|' read SERVICE_ID SERVICE_NAME
do
  echo "$SERVICE_ID) $SERVICE_NAME"
done

# User input for service, phone, name, time
read -p "Enter service ID: " SERVICE_ID_SELECTED
read -p "Enter phone number: " CUSTOMER_PHONE

# Check if customer already exists
CUSTOMER_EXISTS=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")

# If customer does not exist, prompt for name and insert customer
if [[ -z $CUSTOMER_EXISTS ]]; then
  read -p "Enter your name: " CUSTOMER_NAME
  # Insert customer into the database
  $PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME');"
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
else
  CUSTOMER_ID=$CUSTOMER_EXISTS
fi

# Prompt for appointment time
read -p "Enter appointment time: " SERVICE_TIME

# Insert appointment into the appointments table
$PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');"

# Confirm with the user
SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
CUSTOMER_NAME_SELECTED=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID;")
echo "I have put you down for a $SERVICE_NAME_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME_SELECTED."