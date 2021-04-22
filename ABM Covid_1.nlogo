extensions [gis]       ;this creates a gis extension


globals[               ; defines the global variables
  cities-dataset       ; this creates a global varibal to store the gis dataset (shp) file
  %infected            ; this creates a global variable to hold what % of the population is infectious
  %antibodies          ; this creates a global variable to hold what % of the population have antibody with the virus
  %people-vaccinated   ; this creates a global varibale to hold what % of the populatino have vaccine
  nb-death             ; this creates a global varibale to hold the number of death occured
  nb-p-isolate         ; this creates a global varibale to hold the number of people in isolation
  nb-p-out-isolate     ; this creates a global varibale to hold the number of people out of isolation
  mortality-rate       ; this creates a global varibale to hold the percentage of mortality-rate
  recovery-cases       ; this creates a global variable to hold the number of recovery cases
  infect-rate          ; this creates a gloabl variable to monitor the rate of infection



]

patches-own [          ;defines the variables belonging to each patch
  random-n             ;create a new random number to use
  centroid             ;create a new variable name centroid to hold the contains of each location
  ID                   ;create the ID for centroid patchs
]

turtles-own            ; defines the variables belonging to each turtle.
[
  infected?            ; this creates a variable for the turles if true, the turtle is infectious
  infect-time          ; this creates a variable for turtles to hold the length of infection
  antibodies           ; this creates a variable for turtles to know if a turtle have antibody
  have-vac?            ; this creates a variable for turtles to know if a turtle have been vaccinated
  develop-anti-time    ; this variable is to store random time for turtles to develop antibodies
  isolation?           ; this creates a variable for the turles if true, the turtle is in isolation
  nb-isolation         ; this variable is to store random number of turtles will have to self isolation
  nb-infected          ; this to hold a variable to hold the number of infection
  nb-recovery          ; this creates a varibale to hold the number of recovery case from the virus
  nb-social-D          ; this creates a varibale to hold the number of people do social distancing
  socialD?             ; this creates a variable for the turles if true, the turtle is social Distancing

]

to setup_map                                                                                                    ; create a function called setup_map
  clear-all                                                                                                     ; clear the world
  set cities-dataset gis:load-dataset "data/Local_Authority_Districts__December_2019__Boundaries_UK_BFE.shp"    ;to assign the dataset to the previously defined global variable named cities-dataset
  gis:set-world-envelope (gis:envelope-of cities-dataset)                                                       ;defines a transformation between the NetLogo space and the GIS data space being used in the model.
  let i 1
  foreach gis:feature-list-of cities-dataset [ feature ->                                                       ;the feature list is the collection of all the polygons that make up the map and passed to the anonymous procedure inside the loop,
    ask patches gis:intersecting feature [                                                                      ;the patches intersecting the current feature in the list to overlay
     set centroid gis:location-of gis:centroid-of feature                                                       ;find the centroid of the polygon. The patch at the centroid will serve as a command center for that polygon.
      ask patch item 0 centroid item 1 centroid [                                                               ;patch will set its ID variable to the value of i
      set ID i
     ]
    ]
   set i i + 1                                                                                                  ;ID variable to the value of i assigned to it in the future.
  ]
  gis:set-drawing-color white                                                                                   ;drawn the line with white colour
  gis:draw cities-dataset 2                                                                                     ;2 pixels
  ask patches with [ID > 0] [                                                                                  ; Each centroid patch is asked to update the polygon it controls to the appropriate color.
    set random-n random-float 10                                                                               ; Using the random numbers
    ifelse random-n >= 5                                                                                       ; if random number > or = 5
    [
      gis:set-drawing-color blue                                                                               ; set drawing colour blue
    ]
    [
      gis:set-drawing-color green                                                                              ; set drawing colour green

    ]
    gis:fill item (ID - 1)                                                                                     ; fill the polygon
    gis:feature-list-of cities-dataset 2.0                                                                     ; filled with the appropriate color with a line thickness of 2.0 pixels.
  ]



end




to setup                                                                                                       ; create a function called setup


  ask n-of populationsofSTA patches with [centroid = [-65.72321670318439 -4.041488647942474]] [                ; ask number of patches in the polygon with centroid = [-65.72321670318439 -4.041488647942474] (in here is ST.Albans)
    sprout 1 [                                                                                                 ; Creates new turtles on the current patch.
      set color white set shape "circle"                                                                       ; set turtles's colour white and shape is circle
      healthy ]                                                                                                ; call function "heathy"
  ]
  ask n-of populationofWandH patches with [centroid = [62.025455888363126 -8.178828543510893]] [               ; ask number of patches in the polygon with centroid = [62.025455888363126 -8.178828543510893] (in here is W and Hatfields)
    sprout 1 [                                                                                                 ; Creates new turtles on the current patch.
      set color white set shape "x"                                                                            ; set turtles's colour white and shape is "X"
      healthy ]                                                                                                ; call function "heathy"
  ]
  ask n-of infect turtles                                                                                      ; create a number of infected turtles.
    [ get-infected ]                                                                                           ; call fuction get-infected
  ask n-of nb_people_vaccinated turtles                                                                        ; create a number of vaccinated turtles.
    [
      if vaccine?  [
        vaccinated]]                                                                                           ; call function vaccinated
  ask turtles [                                                                                                ; call all turtles to assigg random number of each turtle to develop antibody
    create-random                                                                                              ; call fucntion create-random to take a random of number of turtles

  ]
  reset-ticks                                                                                                  ; reset ticks counter

end

to go                                                                                                          ; create a function called go

  move                                                                                                         ; call the function move for turtles to wander around
  ask turtles [                                                                                                ; ask all turtles
   clear-count                                                                                                 ; clear count
   decrease                                                                                                    ; call fucntion decrease                                                                             ; if turtle is not infected then it can be tranfered the virus (function transmission)
   if infected? = true [recover-or-die]                                                                        ; if the turtle is infected then it can recovery or die
   if isolation? != true and infected? = true and (random 100 < nb-isolation) [                                ; if the isolation switch is on and the turtles is infected
      isolate                                                                                                  ; the turtle will self isolate
   ]
   if socialDistancing? and random 100 < nb-social-D [                                                         ; if the switch socialDistancing? of turtle is true then
      set socialD? true                                                                                        ; set the value socialD? of turtle to true

    ]
   if isolation? = true [unisolate]                                                                           ; if the turtle isolated, after 10 days it can unisolate
   if not stayLocal? and infected? != true and color != black [transmission]                                  ; if the stayLocal? switch is off turtles with shape "x" can infect turtles with shape "circle" and " circle" can infect "x"
   if stayLocal? [                                                                                            ; if the stayLocal? switch is on
      if shape = "x" and isolation? != true [transmission-welyn-H]                                            ; only "x" can infect "x"
      if shape = "circle" and isolation? != true [transmission-ST-alban]                                      ; only "circle" can infect "circle"
  ]
  ]
  update-display                                                                                               ; call fucntion update-display
  update-global-variables                                                                                      ; call function update-global-variable
  show count turtles
  ; show the number survivor
  tick                                                                                                         ; tick counter running
  if ticks >= 1440                                                                                             ; if tick greater than 1440 ticks (1440 hours = 2 month)
  [stop]                                                                                                       ; the model stop

end
to clear-count

  set nb-infected 0                                                                                            ; set to 0
  set nb-recovery 0                                                                                            ; set to 0
end


to move                                                                                                            ; create function call move
  ask turtles with [shape = "x" and isolation? != true ]                                                           ; ask turtle with shape "X" (in here is turtles in Welwyn and Hatfield) and they not in isolation
  [ forward 0.2 ]                                                                                                  ; move around with speed 0.2
  ask turtles with [shape = "x" and isolation? != true ]                                                           ; ask turtle with shape "X" (in here is turtles in Welwyn and Hatfield) and they not in isolation
  [if centroid != [62.025455888363126 -8.178828543510893] and centroid != [-65.72321670318439 -4.041488647942474]  ; if they reach the bondaries of 2 GIS patches they will
    [set heading heading - 100]]                                                                                   ; turn around 100 Degree
  ask turtles with [shape = "x" and isolation? != true]                                                            ; ask turtle with shape "X" (in here is turtles in Welwyn and Hatfield) and they not in isolation
  [if stayLocal? and centroid != [62.025455888363126 -8.178828543510893]                                           ; if the switch stayLocal? is on and turtle go outside the bondaries of polygon patch with centroid = [41.41899213807637 -5.461609758291327]
    [set heading heading - 100]]                                                                                   ; turn around 100 Degree
  ask turtles with [shape = "circle" and isolation? != true]                                                       ; ask turtle with shape "X" (in here is turtles in St. Albans patch) and they not in isolation
  [ forward 0.2]                                                                                                   ; move around with speed 0.2
  ask turtles with [shape = "circle" and isolation? != true]                                                       ; ask turtle with shape "X" (in here is turtles in St. Albans patch) and they not in isolation
  [if centroid != [62.025455888363126 -8.178828543510893] and centroid != [-65.72321670318439 -4.041488647942474]  ; if they reach the bondaries of 2 GIS patches they will
    [set heading heading - 100]]                                                                                   ; turn around 100 Degree
  ask turtles with [shape = "circle" and isolation? != true]                                                       ; ask turtle with shape "X" (in here is turtles in St. Albans patch) and they not in isolation
  [if stayLocal? and centroid != [-65.72321670318439 -4.041488647942474]                                           ; if the switch stayLocal? is on and turtle go outside the bondaries of polygon patch with centroid = [-43.888260987840745 -2.698801389489825]
    [set heading heading - 100]]                                                                                   ; turn around 100 Degree
  ask turtles with [socialD? = true]                                                                               ; ask turtle with have socialD value
      [ if socialDistancing? and any? turtles-on patch-ahead 1                                                     ; Reports an agentset containing all the turtles that are on the given patch or patches
      [ set heading heading - 90] ]                                                                                ; turn 90 degree

end


to get-infected                                                                                            ; this creates a function to set infected turtles with random Probability
  set infected?  true                                                                                      ; set variable infected to true
  set antibodies 0                                                                                         ; set variable antibodies to 0
  set nb-infected (nb-infected + 1)                                                                        ; add 1 to nb-infected
end


to create-random                                                                                           ; this function is based on the "assign-tendency" function in the model Yang, C. and Wilensky, U. (2011).
                                                                                                           ; NetLogo epiDEM Travel and Control model. http://ccl.northwestern.edu/netlogo/models/epiDEMTravelandControl.
    set develop-anti-time random-normal 504 504 / 2                                                        ; set develop-anti-time to normally distributed random floating point number with a mean of 504 and a standard deviation 504/2
    if develop-anti-time > 504 * 2 [ set develop-anti-time 504 * 2 ]                                       ; make sure it lies between 0 and 2x of 504 ticks
    if develop-anti-time < 0 [ set develop-anti-time 0 ]
    set nb-isolation random-normal isolation-percentage isolation-percentage / 4                           ; set nb-isolation to normally distributed random floating point number with a mean of isolation-percentage and a standard deviation isolation-percentage/4
    if nb-isolation > isolation-percentage * 2 [ set nb-isolation isolation-percentage * 2 ]               ; make sure it lies between 0 and 2x of isolation-percentage
    if nb-isolation < 0 [ set nb-isolation 0 ]
    set nb-social-D random-normal social-D-percentage social-D-percentage / 4                              ; set nb-social-D to normally distributed random floating point number with a mean of social-D-percentage and a standard deviation isolation-percentage/4
    if nb-social-D > social-D-percentage * 2 [ set nb-social-D social-D-percentage * 2 ]                   ; make sure it lies between 0 and 2x of social-D-percentage
    if nb-social-D < 0 [ set nb-social-D 0 ]
end


to update-display                                                                                          ; this creates a fuction to set colour of turtles
  ask turtles                                                                                              ; ask all turtles
    [ if infected? = true [set color red]                                                                  ; if the turtles is infected the colour turn red
      if antibodies > 0 [set color black]                                                                  ; if it have antibodies change the colour of turtles to black
      if isolation? = true [set color grey]                                                                ; if it in isolation turn to color grey
  ]
end


to update-global-variables                                                                                 ; this to update the new number of infections and recovery
  if count turtles > 0                                                                                     ; if number of turtles greater than 0
    [ set %infected (count turtles with [infected? = true] / count turtles) * 100                          ; this to get the percentage of number of infection by (number of infections/number of turtles)x100
      set %antibodies (count turtles with [ antibodies > 0 ] / count turtles) * 100                        ; this to get the percentage of number of people have antibodies ((number of tutles with antibodies > 0) / number of tutles) x 100
      set %people-vaccinated (count turtles with [have-vac? = true]/ count turtles) * 100                  ; this to calculate the percentage of number of people have been vaccinated
      set nb-death  (populationsofSTA + populationofWandH) - count turtles                                 ; this to get the number of people have died
      calculate-mortality-rate                                                                             ; call the function to calculate the mortality rate
      calculate-infection-rate                                                                             ; call the function to calculate the infection rates

  ]
end


to transmission                                                                                                ; this create fucntion transmission for turtles
 if not vaccine? and not socialDistancing?[                                                                    ; if the vaccine? and socialDistancing?  switch is turn off
  ask other turtles-here with [ color = white and have-vac? != true and isolation? != true ]                   ; ask turtles with the variable infected? not true
    [ if random-float 100 < infection-chance                                                                   ; create a random float number in range 0 to 100 if the number < than global variable "infection-chance"
      [ get-infected ] ]]                                                                                      ; the turtles being infected

 if vaccine? and not socialDistancing?[                                                                        ; if the vaccine switch is turn on but the socialDistancing? switch is turn off
  ask other turtles-here with [ color = white and have-vac? != true and isolation? != true ]                   ; ask turtles with the variable infected? not true and not in isolation
    [ if random-float 100 < (infection-chance * 50) / 100                                                      ; create a random float number in range 0 to 100 if the number < than global variable "infection-chance" but in here the infection chance reduce by 50%
      [ get-infected ] ]]                                                                                      ; the turtles being infected

 if vaccine? and socialDistancing? and social-D-percentage >= 80 [                                             ; if both 2 switch vaccine? and socialDistancing? and social-D-percentage > 80
    ask other turtles-here with [ color = white and have-vac? != true and isolation? != true ]                 ; ask turtles with the variable infected? not true and not in isolation
    [ if random-float 100 < (infection-chance * 30) / 100                                                      ; create a random float number in range 0 to 100 if the number < than global variable "infection-chance" but in here the infection chance reduce by 70%
      [ get-infected ] ]]                                                                                      ; the turtles being infected

 if vaccine? and socialDistancing? and 0 <= social-D-percentage and social-D-percentage < 30  [                ; if both 2 switch vaccine? and socialDistancing? and social-D-percentage <30
    ask other turtles-here with [ color = white and have-vac? != true and isolation? != true ]                 ; ask turtles with the variable infected? not true and not in isolation
    [ if random-float 100 < (infection-chance * 45) / 100                                                      ; create a random float number in range 0 to 100 if the number < than global variable "infection-chance" but in here the infection chance reduce by 55%
      [ get-infected ] ]]                                                                                      ; the turtles being infected

  if vaccine? and socialDistancing? and 30 <= social-D-percentage and social-D-percentage < 80   [             ; if both 2 switch vaccine? and socialDistancing? and 30 <= social-D-percentage < 80
    ask other turtles-here with [ color = white and have-vac? != true and isolation? != true ]                 ; ask turtles with the variable infected? not true and not in isolation
    [ if random-float 100 < (infection-chance * 35) / 100                                                      ; create a random float number in range 0 to 100 if the number < than global variable "infection-chance" but in here the infection chance reduce by 65%
      [ get-infected ] ]]                                                                                      ; the turtles being infected

 if not vaccine? and socialDistancing? and social-D-percentage = 0   [                                         ; if not vaccine? and socialDistancing? and social-D-percentage = 0
    ask other turtles-here with [ color = white and have-vac? != true and isolation? != true ]                 ; ask turtles with the variable infected? not true and not in isolation
    [ if random-float 100 < infection-chance                                                                   ; create a random float number in range 0 to 100 if the number < than global variable "infection-chance" but in here the infection chance is the same
      [ get-infected ] ]]                                                                                      ; the turtles being infected

 if not vaccine? and socialDistancing? and social-D-percentage >= 80 [                                         ; if not vaccine? and socialDistancing? and social-D-percentage >= 80
    ask other turtles-here with [ color = white and have-vac? != true and isolation? != true ]                 ; ask turtles with the variable infected? not true and not in isolation
    [ if random-float 100 < (infection-chance * 50) / 100                                                      ; create a random float number in range 0 to 100 if the number < than global variable "infection-chance" but in here the infection chance reduce by 50%
      [ get-infected ] ]]                                                                                      ; the turtles being infected

 if not vaccine? and socialDistancing? and 0 <= social-D-percentage and social-D-percentage < 30  [            ; if not vaccine? and socialDistancing? and 0 <= social-D-percentage <30
    ask other turtles-here with [ color = white and have-vac? != true and isolation? != true ]                 ; ask turtles with the variable infected? not true and not in isolation
    [ if random-float 100 < (infection-chance * 80) / 100                                                      ; create a random float number in range 0 to 100 if the number < than global variable "infection-chance" but in here the infection chance reduce by 20%
      [ get-infected ] ]]                                                                                      ; the turtles being infected

  if not vaccine? and socialDistancing? and 30 <= social-D-percentage and social-D-percentage < 80   [         ; if not vaccine? and socialDistancing? and 30 <= social-D-percentage and social-D-percentage < 80
    ask other turtles-here with [ color = white and have-vac? != true and isolation? != true ]                 ; ask turtles with the variable infected? not true and not in isolation
    [ if random-float 100 < (infection-chance * 70 ) / 100                                                     ; create a random float number in range 0 to 100 if the number < than global variable "infection-chance" but in here the infection chance reduce by 30%
      [ get-infected ] ]]                                                                                      ; the turtles being infected
end


to transmission-ST-alban                                                                                       ; this create function transmission for turtles of St. ALban (only "circle" can infect "circle") to use when the stayLocal? is on
 if not vaccine? and not socialDistancing?[                                                                    ; if 2 switch vaccine? and socialDistancing? are off
  ask other turtles-here with [shape = "circle" and color = white and isolation? != true ]                     ; ask other turtles with shape "circle" and have color white (uninfected) and not in isolation
    [ if random-float 100 < (infection-chance * 20) / 100                                                      ; create a random float number in range 0 to 100 if the number < than global variable "infection-chance" (in here the infection-chance is reduce 80%)
      [ get-infected ] ] ]                                                                                     ; being infected

 if vaccine? and not socialDistancing?[                                                                        ; if the vaccine switch is turn on
  ask other turtles-here with [ shape = "circle" and color = white and isolation? != true ]                    ; ask other turtles with shape "circle" and have color white (uninfected) and not in isolation
    [ if random-float 100 < (infection-chance * 10) / 100                                                      ; create a random float number in range 0 to 100 if the number < than global variable "infection-chance" but in here the infection chance reduce by 90%
      [ get-infected ] ]]                                                                                      ; being infected

 if vaccine? and socialDistancing? and social-D-percentage >= 80 [                                             ; if the vaccine switch is turn on and social-D-percentage >= 80
    ask other turtles-here with [shape = "circle" and color = white and isolation? != true ]                   ; ask other turtles with shape "circle" and have color white (uninfected) and not in isolation
    [ if random-float 100 < (infection-chance * 5) / 100                                                       ; create a random float number in range 0 to 100 if the number < than global variable "infection-chance" but in here the infection chance reduce by 95%
      [ get-infected ] ]]                                                                                      ; being infected

 if vaccine? and socialDistancing? and 0 <= social-D-percentage and social-D-percentage < 30  [                ; if the vaccine switch is turn on and 0 <= social-D-percentage and social-D-percentage < 30
    ask other turtles-here with [ shape = "circle" and color = white and isolation? != true]                   ; ask other turtles with shape "circle" and have color white (uninfected) and not in isolation
    [ if random-float 100 < (infection-chance * 9) / 100                                                       ; create a random float number in range 0 to 100 if the number < than global variable "infection-chance" but in here the infection chance reduce by 91%
      [ get-infected ] ]]                                                                                      ; being infected

  if vaccine? and socialDistancing? and 30 <= social-D-percentage and social-D-percentage < 80   [             ; if the vaccine switch is turn on and 30 <= social-D-percentage and social-D-percentage < 80
    ask other turtles-here with [ shape = "circle" and color = white and isolation? != true ]                  ; ask other turtles with shape "circle" and have color white (uninfected) and not in isolation
    [ if random-float 100 < (infection-chance * 7) / 100                                                       ; create a random float number in range 0 to 100 if the number < than global variable "infection-chance" but in here the infection chance reduce by 93%
      [ get-infected ] ]]                                                                                      ; being infected

 if not vaccine? and socialDistancing? and social-D-percentage = 0   [                                         ; if the vaccine switch is turn on and social-D-percentage = 0
    ask other turtles-here with [ shape = "circle" and color = white and isolation? != true ]                  ; ask other turtles with shape "circle" and have color white (uninfected) and not in isolation
    [ if random-float 100 < (infection-chance * 20) / 100                                                      ; create a random float number in range 0 to 100 if the number < than global variable "infection-chance" but in here the infection chance reduce by 80%
      [ get-infected ] ]]                                                                                      ; being infected

 if not vaccine? and socialDistancing? and social-D-percentage >= 80 [                                         ; if the vaccine switch is turn off and social-D-percentage >= 80
    ask other turtles-here with [ shape = "circle" and color = white and isolation? != true ]                  ; ask other turtles with shape "circle" and have color white (uninfected) and not in isolation
    [ if random-float 100 < (infection-chance * 12) / 100                                                      ; create a random float number in range 0 to 100 if the number < than global variable "infection-chance" but in here the infection chance reduce by 88%
      [ get-infected ] ]]                                                                                      ; being infected

 if not vaccine? and socialDistancing? and 0 <= social-D-percentage and social-D-percentage < 30  [            ; if the vaccine switch is turn off and 0 <= social-D-percentage and social-D-percentage < 30
    ask other turtles-here with [ shape = "circle" and color = white and isolation? != true ]                  ; ask other turtles with shape "circle" and have color white (uninfected) and not in isolation
    [ if random-float 100 < (infection-chance * 19) / 100                                                      ; create a random float number in range 0 to 100 if the number < than global variable "infection-chance" but in here the infection chance reduce by 81%
      [ get-infected ] ]]                                                                                      ; being infected

  if not vaccine? and socialDistancing? and 30 <= social-D-percentage and social-D-percentage < 80   [         ; if the vaccine switch is turn off and 30 <= social-D-percentage and social-D-percentage < 80
    ask other turtles-here with [ shape = "circle" and color = white and isolation? != true ]                  ; ask other turtles with shape "circle" and have color white (uninfected) and not in isolation
    [ if random-float 100 < (infection-chance * 15 ) / 100                                                     ; create a random float number in range 0 to 100 if the number < than global variable "infection-chance" but in here the infection chance reduce by 85%
      [ get-infected ] ]]                                                                                      ; being infected
end


to transmission-welyn-H                                                                                        ; this create function transmission for turtles of Welwyn and Hatfield (only "x" can infect "x") to use when the stayLocal? is on

if not vaccine? and not socialDistancing?[                                                                     ; if 2 switch vaccine? and socialDistancing? are off
  ask other turtles-here with [shape = "x" and color = white and isolation? != true ]                          ; ask other turtles with shape "x" and have color white (uninfected) and not in isolation
    [ if random-float 100 < (infection-chance * 20) / 100                                                      ; create a random float number in range 0 to 100 if the number < than global variable "infection-chance" (in here the infection-chance is reduce 80%)
      [ get-infected ] ] ]                                                                                     ; being infected

 if vaccine? and not socialDistancing?[                                                                        ; if the vaccine switch is turn on
  ask other turtles-here with [ shape = "x" and color = white and isolation? != true ]                         ; ask other turtles with shape "x" and have color white (uninfected) and not in isolation
    [ if random-float 100 < (infection-chance * 10) / 100                                                      ; create a random float number in range 0 to 100 if the number < than global variable "infection-chance" but in here the infection chance reduce by 90%
      [ get-infected ] ]]                                                                                      ; being infected

 if vaccine? and socialDistancing? and social-D-percentage >= 80 [                                             ; if the vaccine switch is turn on and social-D-percentage >= 80
    ask other turtles-here with [ shape = "x" and color = white and isolation? != true ]                       ; ask other turtles with shape "x" and have color white (uninfected) and not in isolation
    [ if random-float 100 < (infection-chance * 5) / 100                                                       ; create a random float number in range 0 to 100 if the number < than global variable "infection-chance" but in here the infection chance reduce by 95%
      [ get-infected ] ]]                                                                                      ; being infected

 if vaccine? and socialDistancing? and 0 <= social-D-percentage and social-D-percentage < 30  [                ; if the vaccine switch is turn on and 0 <= social-D-percentage and social-D-percentage < 30
    ask other turtles-here with [ shape = "x" and color = white and isolation? != true]                        ; ask other turtles with shape "x" and have color white (uninfected) and not in isolation
    [ if random-float 100 < (infection-chance * 9) / 100                                                       ; create a random float number in range 0 to 100 if the number < than global variable "infection-chance" but in here the infection chance reduce by 91%
      [ get-infected ] ]]                                                                                      ; being infected

  if vaccine? and socialDistancing? and 30 <= social-D-percentage and social-D-percentage < 80   [             ; if the vaccine switch is turn on and 30 <= social-D-percentage and social-D-percentage < 80
    ask other turtles-here with [ shape = "x" and color = white and isolation? != true ]                       ; ask other turtles with shape "x" and have color white (uninfected) and not in isolation
    [ if random-float 100 < (infection-chance * 7) / 100                                                       ; create a random float number in range 0 to 100 if the number < than global variable "infection-chance" but in here the infection chance reduce by 93%
      [ get-infected ] ]]                                                                                      ; being infected

 if not vaccine? and socialDistancing? and social-D-percentage = 0   [                                         ; if the vaccine switch is turn on and social-D-percentage = 0
    ask other turtles-here with [ shape = "x" and color = white and isolation? != true ]                       ; ask other turtles with shape "x" and have color white (uninfected) and not in isolation
    [ if random-float 100 < (infection-chance * 20) / 100                                                      ; create a random float number in range 0 to 100 if the number < than global variable "infection-chance" but in here the infection chance reduce by 80%
      [ get-infected ] ]]                                                                                      ; being infected

 if not vaccine? and socialDistancing? and social-D-percentage >= 80 [                                         ; if the vaccine switch is turn off and social-D-percentage >= 80
    ask other turtles-here with [ shape = "x" and color = white and isolation? != true ]                       ; ask other turtles with shape "x" and have color white (uninfected) and not in isolation
    [ if random-float 100 < (infection-chance * 12) / 100                                                      ; create a random float number in range 0 to 100 if the number < than global variable "infection-chance" but in here the infection chance reduce by 88%
      [ get-infected ] ]]                                                                                      ; being infected

 if not vaccine? and socialDistancing? and 0 <= social-D-percentage and social-D-percentage < 30  [            ; if the vaccine switch is turn off and 0 <= social-D-percentage and social-D-percentage < 30
    ask other turtles-here with [ shape = "x" and color = white and isolation? != true ]                       ; ask other turtles with shape "x" and have color white (uninfected) and not in isolation
    [ if random-float 100 < (infection-chance * 19) / 100                                                      ; create a random float number in range 0 to 100 if the number < than global variable "infection-chance" but in here the infection chance reduce by 81%
      [ get-infected ] ]]                                                                                      ; being infected

  if not vaccine? and socialDistancing? and 30 <= social-D-percentage and social-D-percentage < 80   [         ; if the vaccine switch is turn off and 30 <= social-D-percentage and social-D-percentage < 80
    ask other turtles-here with [ shape = "x" and color = white and isolation? != true ]                       ; ask other turtles with shape "x" and have color white (uninfected) and not in isolation
    [ if random-float 100 < (infection-chance * 15 ) / 100                                                     ; create a random float number in range 0 to 100 if the number < than global variable "infection-chance" but in here the infection chance reduce by 85%
      [ get-infected ] ]]                                                                                      ; being infected
end


to healthy                                                        ; this create a function called heathy for turtles
  set infected? false                                             ; if the turtles is healthy set the variable infected? to false
  set infect-time 0                                               ; reset the variable infected-time to 0
end


to develop-antibody                                               ; this create a function called develop-antibody for turtles
   set infected? false                                            ; set variable infected? to false
   set infect-time 0                                              ; infected-time to 0
   set antibodies immunity-last                                   ; set the variable antibodies to the value of global variable immunity-last (in here minimum is 8 month = 5840 hous)
   set nb-recovery (nb-recovery + 1)                              ; added 1 to nb-recovery
end


to decrease                                                       ; this create a fucntion called decrease to decrease the time of antibodies last
  if antibodies > 0 [ set antibodies antibodies - 1 ]             ; decrease the antibodies variable of turtles each tick
  if infected? [ set infect-time infect-time + 1 ]                ; add 1 to variable infected-time each tick
end


to recover-or-die                                                 ; this create a funtion called recover-or-die
  if infect-time > develop-anti-time and color = red              ; If the turtle has survived past the virus' duration (with covid is 2 week = 504 hours to develop or less of more)
    [ ifelse random-float 100 < chance-recovery                   ; create a random float number in range 0 to 100
      [ develop-antibody ]                                        ; if the number < than global variable "chance-recovery " then the turtles have the antibodies
      [ die  ] ]                                                  ; else the turtle die
end


to vaccinated                                                     ; this create a function call vaccinated
                                                                  ; if the switch vaccine is on
    set have-vac? true                                            ; some turtles will have variable have-vac
    healthy                                                       ; become healthy
    set antibodies 10000                                          ; set the amount of antibody to 10000
end


to isolate                                                        ; this is a fuction for turtles to make the turtle isolate
  if seft-isolation? [                                            ; if the switch self-isolation? is on
    set isolation? true                                           ; set the turtles variable to true
    set nb-p-isolate nb-p-isolate + 1]                            ; add 1 to nb-p-isolate
end


to unisolate                                                      ; this is a turtle procedure to make the turtles out of isolation after some timeframe
  if infect-time > 336 [                                          ; Set the isolation time to 2 week means 336 hours
     set isolation? false                                         ; set the turtles variable isolation? to false
     develop-antibody                                             ; after isolation turtles will develop antibody
     if nb-p-isolate > 0 [                                        ; if nb-p-isolate is greater than 0
      set nb-p-isolate nb-p-isolate - 1                           ; will reduce 1 to nb-p-isolate
      set nb-p-out-isolate nb-p-out-isolate + 1                   ; will add 1 to nb-p-out-isolate
    ]
  ]

end


to calculate-mortality-rate                                                            ; this function is to calculate the curde mortality rate per 100,000 population
  set mortality-rate (nb-death / (populationsofSTA + populationofWandH ) ) * 100000    ; Deaths occurring during a given time period divided by Size of the population among which the deaths occurred× 100000
end


to calculate-infection-rate                                                            ; this function is to calculate the infection rate and the number of people recovered from the virus


  set recovery-cases  count turtles with [color = black and have-vac? != true]         ; calculate the number recovered by counting the number with coulor black (have antibodies) and without vaccine
  set infect-rate (count turtles with [color = red] / count turtles) * 100             ; # of Infections / Population at Risk X constant (k) = Rate of Infection Constant K is 100 assign value of 100 means the percentage.
                                                                                       ; color red is the infection case

end
@#$#@#$#@
GRAPHICS-WINDOW
186
16
756
587
-1
-1
1.87
1
10
1
1
1
0
1
1
1
-150
150
-150
150
1
1
1
hours
30.0

SLIDER
23
93
178
126
populationsofSTA
populationsofSTA
100
14000
7469.0
1000
1
NIL
HORIZONTAL

SLIDER
20
136
180
169
populationofWandH
populationofWandH
100
13000
6137.0
1000
1
NIL
HORIZONTAL

BUTTON
73
53
137
87
Go
go\n
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
765
25
877
58
stayLocal?
stayLocal?
0
1
-1000

BUTTON
23
14
116
47
NIL
setup_map\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
120
14
183
47
NIL
setup\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
19
173
180
206
infect
infect
0
1000
5.0
10
1
NIL
HORIZONTAL

MONITOR
764
283
836
328
NIL
%infected
2
1
11

PLOT
1032
337
1474
586
Population
Hours
Number of People
0.0
100.0
0.0
100.0
true
true
"" ""
PENS
"Infected" 1.0 0 -2674135 true "" "plot count turtles with [infected? = true]"
"Immune" 1.0 0 -16777216 true "" "plot count turtles with [antibodies > 0 ]"

SLIDER
19
209
180
242
infection-chance
infection-chance
0
100
0.3
5
1
NIL
HORIZONTAL

SLIDER
18
248
180
281
immunity-last
immunity-last
0
10000
2040.0
1000
1
NIL
HORIZONTAL

SLIDER
13
286
185
319
chance-recovery
chance-recovery
0
100
95.0
10
1
NIL
HORIZONTAL

MONITOR
764
335
846
380
NIL
%antibodies
2
1
11

SLIDER
16
328
184
361
nb_people_vaccinated
nb_people_vaccinated
0
13000
6803.0
100
1
NIL
HORIZONTAL

SWITCH
766
65
877
98
vaccine?
vaccine?
0
1
-1000

MONITOR
764
232
900
277
NIL
%people-vaccinated
2
1
11

MONITOR
842
282
900
327
Death
nb-death
17
1
11

PLOT
1198
22
1498
216
Death 
NIL
NIL
0.0
700.0
0.0
100.0
true
true
"" ""
PENS
"Death" 1.0 0 -16777216 true "" "plot nb-death"
"Mortality rate per 100K" 1.0 0 -2674135 true "" "plot mortality-rate"

SLIDER
11
373
183
406
isolation-percentage
isolation-percentage
0
100
80.0
5
1
NIL
HORIZONTAL

MONITOR
906
231
1019
276
People in Isolation
nb-p-isolate
1
1
11

MONITOR
1025
230
1146
275
People out of isolation
nb-p-out-isolate
17
1
11

PLOT
895
25
1190
216
Isolation table
NIL
NIL
0.0
1000.0
0.0
1000.0
true
true
"" ""
PENS
"Finished Isolation" 1.0 0 -2674135 true "" "plot nb-p-out-isolate "
"Isolation" 1.0 0 -13345367 true "" "plot nb-p-isolate "

SWITCH
764
113
879
146
seft-isolation?
seft-isolation?
0
1
-1000

PLOT
763
389
1025
586
Infection Rates
NIL
NIL
0.0
150.0
0.0
5.0
true
false
"" ""
PENS
"pen-3" 1.0 0 -16777216 true "" "plot infect-rate\n"

MONITOR
853
335
942
380
NIL
mortality-rate
2
1
11

MONITOR
948
335
1020
380
infect-rate
infect-rate
2
1
11

MONITOR
1023
281
1104
326
Active cases
count turtles with [color = red]
1
1
11

MONITOR
910
284
1014
329
Recovery-Cases
recovery-cases
17
1
11

SWITCH
762
157
890
190
socialDistancing?
socialDistancing?
0
1
-1000

SLIDER
11
415
183
448
social-D-percentage
social-D-percentage
0
100
80.0
10
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

Agent-based model base on real-data to explore the potential outcomes of a COVID-19 epidemic with and without vaccination roll out. This module is to gain information about The transmission of the COVID- 19 virus in relation to the changes of Social Distancing, number of Vaccine admitted, Self- Isolation and travel permitted – stay local 

## HOW IT WORKS

Agents: 
-	The agents in the model are individuals who wander around the landscape. Using GIS in Netlogo and download the GIS dataset of the boundaries of St. Albans and Welwyn & Hatfield and create a border between two districts for the travel factor.
-	There are 4 groups of individuals: The presence of the virus in the population is represented by the colours of individuals. Four colours are used:
1. White individuals are healthy people.
2. Red individuals are infected and can die because of Covid. 
3. Black individuals are turtles with immunity to the virus after recovery or when they have the vaccine. 
4. Grey individuals are the from the infected turtles (Red turtles), when they infected, they will self – isolation and turn grey.
-	Using the slider in the model interface to control the number of agents in the initial state of the model.
Interactions: 
         Upon encountering an infected person, individuals have a random probability of contracting the illness and can die from it. An infected individual has a chance of recovery after the given recovery time has elapsed. 

-	Using the slider in the model interface to control the number of agents in the initial state of the model.
-	Parameter set by user using a switch on and off button, both of them will have an effect on the Infection rate and Mortality rate:
1. Stay Local: When turtles can move between two districts. If it is on means the restriction is put in place. 
2. Isolation: Once an infected turtle is identified as an "isolator," the turtles will isolate themselves in the current location and indicated by the colour grey and will stay there for 2 weeks according to UK’s GOV rule. 
3. Had vaccine: Set how many Blacks turtles will appear. They are the people who have the vaccine and now have immunity to the virus.
4. Social Distancing: When this is on turtles will avoid each other’s, this also decreases the chance of catching the virus.  


## HOW TO USE IT

(Constant slider): 

populationofSTA	        7469     ( Population of St. ALbans scaled down to 1:20)
populationofWandH	6137     ( Population of W and H scaled down to 1:20)
infect	                5        ( Number of infected turtles scaled down to 1:20)
infection-chance	0.3      ( Infection chance)
Immunity-last	        2040     ( How long will immunity last)
Chance-recovery 	95       ( Chance of recovery) 

This is the setup based on the real data of COVID-19. 

(Can change): 

nb_people_vaccinated	4500     ( Number had been vaccinated and had antibody)
isolation-percentage	80       ( Isolation tendency)
social-D-percentage 	80       ( Social Distancing tendency) 



## THINGS TO NOTICE

In the event of an outbreak, the number of people being infected over time follows a "S-curve," as it does in many epidemiological models. It is known as an S-curve because it resembles a sideways S. Adjust the parameters' values using the slider to see what kinds of adjustments cause the S curve to expand or shrink.


## THINGS TO TRY

Try to turn off switch to see if the infection rate and mortality rates increased or not 


## EXTENDING THE MODEL

-	It can be an additional reproduction rate when people die with old age and new individuals are born to replace those who die. 
-	Expand the model to simulate the whole population of UK. 
-	Change the way the virus spread by adding virus mutation, which can be based on the Kent and South African variants, those that have a high level of transmission.



## NETLOGO FEATURES

-	Geographic information system (GIS) is applied, including real-world geographic data of two district St. Albans and Welwyn & Hatfield 


## RELATED MODELS

None

## CREDITS AND REFERENCES

The function create-random is based on AVERAGE-ISOLATION-TENDENCY function from  Yang, C. and Wilensky, U. (2011). NetLogo epiDEM Travel and Control model. http://ccl.northwestern.edu/netlogo/models/epiDEMTravelandControl. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL. 

NetLogo software :

Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

See the github website: 
https://github.com/khoita2210/Netlogo-ABM-of-Covid-19

Dang Khoi Ta | SRN: 17075263
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

person service
false
0
Polygon -7500403 true true 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Polygon -1 true false 120 90 105 90 60 195 90 210 120 150 120 195 180 195 180 150 210 210 240 195 195 90 180 90 165 105 150 165 135 105 120 90
Polygon -1 true false 123 90 149 141 177 90
Rectangle -7500403 true true 123 76 176 92
Circle -7500403 true true 110 5 80
Line -13345367 false 121 90 194 90
Line -16777216 false 148 143 150 196
Rectangle -16777216 true false 116 186 182 198
Circle -1 true false 152 143 9
Circle -1 true false 152 166 9
Rectangle -16777216 true false 179 164 183 186
Polygon -2674135 true false 180 90 195 90 183 160 180 195 150 195 150 135 180 90
Polygon -2674135 true false 120 90 105 90 114 161 120 195 150 195 150 135 120 90
Polygon -2674135 true false 155 91 128 77 128 101
Rectangle -16777216 true false 118 129 141 140
Polygon -2674135 true false 145 91 172 77 172 101

person student
false
0
Polygon -13791810 true false 135 90 150 105 135 165 150 180 165 165 150 105 165 90
Polygon -7500403 true true 195 90 240 195 210 210 165 105
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -1 true false 100 210 130 225 145 165 85 135 63 189
Polygon -13791810 true false 90 210 120 225 135 165 67 130 53 189
Polygon -1 true false 120 224 131 225 124 210
Line -16777216 false 139 168 126 225
Line -16777216 false 140 167 76 136
Polygon -7500403 true true 105 90 60 195 90 210 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
