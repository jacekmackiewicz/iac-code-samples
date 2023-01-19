### Build status
Development
[![Build Status](https://yourbuildpipeline.com)

# Overview of building and running project

## Settings and local development
To run this project please set environment variables:

RUN_ENVIRONMENT: Development_local
HOST_ENVIRONMENT: LocalHost

Or add this line: -RUN_ENVIRONMENT:Development_local -HOST_ENVIRONMENT:LocalHost

To run this project with your own local development variables please set
RUN_ENVIRONMENT: Development_{yourNameShortcut} example: appsettings.Development_arsu.json
Then create appsettings.Development_{yourNameShortcut}.json file in "settings" folder. In Properties of created file change "Copy To Output Directory" option to "Copy Always". 

In this file add settings which you want to overwrite.
Variables which you have to change are avaiable in file appsettings.Development_example.json

## Compiling the project needs Compaq Visual Fortran
Extract DF98.zip from docker/Binaries into C:\Program Files (x86)\Microsoft Visual Studio

## Server requirements for running compiled code
You need to install Visual C++ 2015 Redistributable for x86. You can find it here:
https://www.microsoft.com/en-us/download/details.aspx?id=52685

# Overview of directories, pipeline.ymls and how thery're connected
 1. ops directory contains scripts required to deploy infrastructure as code. This is the point where you start, go to README.md!
    
 2. docker directory contains files reqiured to build images used in the project:
    - Dockerfile-buildtools contains instructions on how to build image required to build/compile the project.
    - Dockerfile contains instructions on how to build image required to run the executables.
    - Everything else are binaries or tools used inside the docker images.
 3. manifests contains manifests used in AKS.
 4. CICDPipeline$Environment.yml files contain steps used to build and deploy docker images to AKS:
    - variables$Environment.yml are referenced in the mentioned pipelines and contain variables used in the pipeline.
    - During replace tokens tasks variables like #{variableName}# are replaced inside yml, ps1 or other files specified in task.
