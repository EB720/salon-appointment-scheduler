#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo "Welcome to My Salon, how can I help you?"
APPOINTMENT_MENU() {
  #get available services
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id,name FROM services ORDER BY service_id")
  #if no services available
  if [[ -z $AVAILABLE_SERVICES ]] 
  then
   #send to main menu
   APPOINTMENT_MENU "Sorry, we don't have any services available right now."
  else
   #display list of services
   echo -e "\nHere are the services we have available:"
   echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
   do
    echo "$SERVICE_ID) $(echo $NAME | sed -E 's/^ *| *$//g')"
   done
   #ask for service to avail
   echo -e "\nWhich service would you like to avail?"
   read SERVICE_ID_SELECTED
   if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]] #service ID selected is not a number
   then
    # send to appointment menu
    APPOINTMENT_MENU "Please select a valid option."
   else
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    SERVICE_NAME=$(echo $SERVICE_NAME | sed -E 's/^ *| *$//g')  # trim
    if [[ -z $SERVICE_NAME ]]  #if service is not available
    then
     # send to appointment menu
     APPOINTMENT_MENU "That service is not available. Please enter a valid choice"
    else
     #get customer info
     echo -e "\nWhat's your phone number?"
     read CUSTOMER_PHONE
     CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
     CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')  # trim
     #if customer doesn't exist
     if [[ -z $CUSTOMER_NAME ]]
     then
     #get new customer name
     echo -e "\nWhat's your name?"
     read CUSTOMER_NAME
     #insert new customer
     INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
     fi
     CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
     CUSTOMER_ID=$(echo $CUSTOMER_ID | sed -E 's/^ *| *$//g')
     echo -e "\nWhat time would you like your $SERVICE_NAME appointment, $CUSTOMER_NAME?"
     read SERVICE_TIME
     INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
     echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
   fi
  fi 
}

APPOINTMENT_MENU
