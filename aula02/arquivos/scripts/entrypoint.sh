#!/bin/bash

java -Dspring.profiles.active="$APP_PROFILE" -jar /opt/simplecrud/target/simplecrud-0.0.1-SNAPSHOT.jar 
