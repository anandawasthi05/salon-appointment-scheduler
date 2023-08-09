#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

# $($PSQL "TRUNCATE TABLE customers, appointments")

echo -e "\nWelcome to Salon\n"
echo -e "\nHere are the list of services we offer:\n"

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  if [[ -z $AVAILABLE_SERVICES ]]
  then
    echo "Sorry, currently we have no services"
  else
    echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done
    read SERVICE_ID_SELECTED
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      MAIN_MENU "This is not a number."
    else
      SERVICE_AVAILABLE=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
      if [[ -z $SERVICE_AVAILABLE ]]
      then
        MAIN_MENU "Please enter a valid service id."
      else
        echo "What's your phone number?"
        read CUSTOMER_PHONE
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
        if [[ -z $CUSTOMER_NAME ]]
        then
          echo "I don't have a record for that phone number, what's your name?"
          read CUSTOMER_NAME
          CUSTOMER_ADDED=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
          CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
          SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_AVAILABLE")
          echo "What time would you like your$SERVICE_NAME, $CUSTOMER_NAME?"
          read SERVICE_TIME
          APPOINTMENT_CONFIRMATION=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
          if [[ ! -z $APPOINTMENT_CONFIRMATION ]]
          then
            echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
          fi
        fi
      fi
    fi
  fi
}

MAIN_MENU