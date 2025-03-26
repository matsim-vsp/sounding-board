# Sounding Board Documentation

## About this project
This [GITHUB repository](https://github.com/matsim-vsp/sounding-board) provides a [Sounding Board](https://vsp.berlin/sounding-board), provided by the Transport Systems Planning and Transport Telematics group of TU Berlin. It displays a dashboard where a set of measures can be selected and the results of the chosen selection are displayed below. The VSP team used simulations and calculations to estimate how much CO2 emissions can be saved by different measures. This dashboard can be used to show the results of the selected set of different measures and to collect votes of people choosing a set of different transport related measures.

Sounding Board dashboard is live [here](https://vsp.berlin/sounding-board)
 
    https://vsp.berlin/sounding-board
    
Github repository can be found [here](https://github.com/matsim-vsp/sounding-board)
 
    https://github.com/matsim-vsp/sounding-board
    
The needed corresponding files are stored [here](https://svn.vsp.tu-berlin.de/repos/public-svn/shared/sounding-board)
   
    https://svn.vsp.tu-berlin.de/repos/public-svn/shared/sounding-board

## How to create your own

Add new boards on the VSP public-svn at

    https://svn.vsp.tu-berlin.de/repos/public-svn/shared/sounding-board/*new_folder*

Create a new dashboard by adding a **config.yaml** file and a **csv file** to an additional folder to https://svn.vsp.tu-berlin.de/repos/public-svn/shared/sounding-board. While the *yaml file* is providing the formatting and content (incl. descriptions) of the website, the *csv file* is needed for the numbers and specifications of the measures. You find your new dashboard live at `https://vsp.berlin/sounding-board/*your-new-folder*`.

Currently, there are multiple versions of the Sounding Board. Every folder is one version:
 - berlin-2035: [pathway options](https://vsp.berlin/sounding-board/berlin-2035)
 - berlin-2045: [final](https://vsp.berlin/sounding-board/berlin-2045)
 - ccc: created for ECCC workshop in 2023
 - current: this one is the [current](https://vsp.berlin/sounding-board) version [^1] 

[^1]: this is also the landing page if you enter https://vsp.berlin/sounding-board

### (a) yaml file

    Billy needs to fill this since I don't know what is important to know about the yamls
    
 - description of output
 - description of input
 - presets
 - output columns
 - input columns
 - button labels
 
In the yaml file, title and descriptions (of certain measures as well as the outcomes (e.g. costs)) can be set. The yaml file provides also the opportunity to set *presets* e.g. "2045 - ZeroEmissionsZone". For this to work, one specification of each category must be chosen. *COMMENT - I don't know how much we need to write here, but some explaination would be nice - MK*



### (b) csv file

In the csv file, the column headers are the different measures and the intended outcomes (e.g. costs, CO2 emission). The specifications of the individual measures must then be added to the respective columns. Then, the respective results should be calculated for the outputs.  

Therefore, the csv file consists of the specifications of the individual measures and the numerical result of the outcomes (e.g. costs in Euro, CO2 emission: percentage for reduction) for *every possible combinations*. You can use e.g. R to create the table with every combination you need (see these R-files as an [example](https://github.com/matsim-vsp/sounding-board/tree/master/sounding-board/src/R)). The yaml file points to the csv file, ideally, these files are stored in the same folder as shown [here](https://svn.vsp.tu-berlin.de/repos/public-svn/shared/sounding-board/). 

### (c) build instructions

Requires NodeJS 16.x and yarn: Install Node for your platform, and then npm install -g yarn

Clone the repo
yarn install
yarn serve to run a local dev server
Pushing to master branch automatically builds and deploys on URL above.
The code assumes the site prefix is set to /sounding-board, this is added to every URL. To move the site to a different prefix, edit two files:

public/404.html
vite.config.js

