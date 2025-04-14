#!/bin/bash

# Set up PostgreSQL command shortcut
PSQL="psql -U postgres -d salon -t -c"

# Display services
echo "Welcome to the Salon!"
echo "Please choose a service:"
SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")

echo "$SERVICES" | while IFS='|' read SERVICE_ID SERVICE_NAME
do
  # Trim whitespace
  SERVICE_ID=$(echo $SERVICE_ID | xargs)
  SERVICE_NAME=$(echo $SERVICE_NAME | xargs)
  echo "$SERVICE_ID) $SERVICE_NAME"
done

# Read service ID
read -p "Enter service ID: " SERVICE_ID_SELECTED

# Read customer phone
read -p "Enter phone number: " CUSTOMER_PHONE

# Check if customer exists
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';" | xargs)

# If not, ask for name and add them
if [[ -z $CUSTOMER_ID ]]; then
  read -p "Enter your name: " CUSTOMER_NAME
  $PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME');"
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';" | xargs)
fi

# Ask for appointment time
read -p "Enter appointment time (e.g., 2025-04-14 14:00): " SERVICE_TIME

# If service is 'color', prompt for color option
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;" | xargs)

COLOR_OPTION=""
if [[ "$SERVICE_NAME" == "color" ]]; then
  echo "Choose a color option: brown, red, blonde, black"
  read -p "Enter color option: " COLOR_OPTION

  # Validate color
  if [[ ! "$COLOR_OPTION" =~ ^(brown|red|blonde|black)$ ]]; then
    echo "Invalid color option. Exiting."
    exit 1
  fi
fi

# Insert appointment
if [[ "$SERVICE_NAME" == "color" ]]; then
  $PSQL "INSERT INTO appointments (customer_id, service_id, time, color_option) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME', '$COLOR_OPTION');"
else
  $PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');"
fi

# Confirmation
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID;" | xargs)
echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."