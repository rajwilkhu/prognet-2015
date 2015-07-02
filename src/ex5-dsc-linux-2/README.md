# Powershell DSC and Docker

## Overview
In this excercise, we will use Powershell DSC for LINUX to install docker and link two containers - a database (mongodb) and a web container ()

## Get the ip address of the MongoDb container

sudo docker inspect --format="{{ .NetworkSettings.IPAddress }}" db