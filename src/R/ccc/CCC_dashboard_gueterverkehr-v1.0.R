#### DASHBOARD GÜTERVERKEHR ####

## libraries
library(utils)

# options(error=function() { traceback(2); if(!interactive()) quit("no", status = 1, runLast = FALSE) })
print("########################################################################################")
print("########################################################################################")
#### 1. expanding grid with measures ####

base <- "base"
mautFossil <- "mautFossil"
zeroEmissionsZone <- "zeroEmissionsZone"

frame <- expand.grid(
  #innereStadt = c(base, mautFossil, zeroEmissionsZone),
  #aeussereStadt = c(base, mautFossil, zeroEmissionsZone),
  Stadt = c(base, "CO2Steuer", zeroEmissionsZone)
)


## adding output values: CO2, Kosten, Menge fließender Verkehr, Menge stehender Verkehr
## value in relation (1.00 = 100%)
CO2 <- c(1.00)
traffic <- c(1.00)
parking <- c(1.00)
Kosten <- c(0.00)
# Das sind jetzt mio Eu / Jahr.  Am Ende fügen wir noch Eu / (Kopf * Monat).

measures <- cbind(frame,CO2,Kosten,traffic,parking)


#### 2. MASSNAHMEN ####

############################################
massnahme <- "Stadt"

auspraegung <- "CO2Steuer"
# https://doi.org/10.1016/j.trpro.2021.01.061 - Basis ist hier der case: 300€/t
# aus Gueterverkehr-Studie
#
#
measures$"CO2" <- ifelse(measures[[massnahme]]==auspraegung,measures$"CO2"*0.5,measures$"CO2")
# aus Gueterverkehr-Studie
measures$"traffic" <- ifelse(measures[[massnahme]]==auspraegung,measures$"traffic"*0.98,measures$"traffic")
# aus Gueterverkehr-Studie
#
measures$"parking" <- ifelse(measures[[massnahme]]==auspraegung,measures$"parking"*1.05,measures$"parking")
# aus Gueterverkehr-Studie
#
measures$"Kosten" <- ifelse(measures[[massnahme]]==auspraegung,measures$"Kosten" - 500000*300,measures$"Kosten")
# aus Gueterverkehr-Studie
# 1 Mio t/Jahr CO2 Emissionen. 1/2 (=500k t/Jahr) steigt um bei CO2 Steuer von 300€/t.

auspraegung <- zeroEmissionsZone
#
measures$"CO2" <- ifelse(measures[[massnahme]]==auspraegung,measures$CO2 * 0.0,measures$"CO2")
# nur elektrisch = kein CO2
#
measures$"traffic" <- ifelse(measures[[massnahme]]==auspraegung,measures$traffic * 0.96,measures$"traffic")
# extrapoliert aus Gueterverkehr-Studie
#
measures$"parking" <- ifelse(measures[[massnahme]]==auspraegung,measures$parking * 1.13,measures$"parking")
# extrapoliert aus Gueterverkehr-Studie
#
measures$"Kosten" <- ifelse(measures[[massnahme]]==auspraegung,measures$Kosten,measures$"Kosten")
# keine Mauteinnahmen
#


#massnahme <- "innereStadt"

#auspraegung <- mautFossil
# # 20ct/km
#
#traffRed<-0.6
#
#measures$"CO2" <- ifelse(measures[[massnahme]]==auspraegung,measures$"CO2"*traffRed,measures$"CO2")
#
#measures$"traffic" <- ifelse(measures[[massnahme]]==auspraegung,measures$"traffic"*traffRed,measures$"traffic")
# # DRT müsste irgendwie separat dazu kommen.
#
#measures$"parking" <- ifelse(measures[[massnahme]]==auspraegung,measures$"parking"*traffRed,measures$"parking")
# # (Auto-Abschaffung analog CO2-Reduktion)
#
#measures$"Kosten" <- ifelse(measures[[massnahme]]==auspraegung,measures$"Kosten" - 4*365,measures$"Kosten")
# 4 Mio Einnahmen pro Tag.  Habe ich jetzt 1:1 eingetragen.  Umrechungen ggf. am Ende.
#

# --

#auspraegung <- zeroEmissionsZone
#
#measures$"CO2" <- ifelse(measures[[massnahme]]==auspraegung,measures$"CO2"*0.5,measures$"CO2")
# # ähnliche Wirkung auf wie "Maut für alle".  Wirkt intuitiv richtig, aber warum?
#
#measures$"traffic" <- ifelse(measures[[massnahme]]==auspraegung,measures$"traffic"*0.75,measures$"traffic")
# # Eine Hälfte zahlt Maut, die andere wechselt auf nicht-fossiles Auto.
#
#measures$"parking" <- ifelse(measures[[massnahme]]==auspraegung,measures$"parking"*0.75,measures$"parking")
# # Eine Hälfte zahlt Maut, die andere wechselt auf nicht-fossiles Auto.
#
#measures$"Kosten" <- ifelse(measures[[massnahme]]==auspraegung,measures$"Kosten" - 2*365,measures$"Kosten")
# Annahme: 1/2 * MautFürAlle
#

############################################
############################################
#massnahme <- "innereStadt"

#auspraegung <- mautFossil
# # 20ct/km
#
#traffRed<-0.6
#
#measures$"CO2" <- ifelse(measures[[massnahme]]==auspraegung,measures$"CO2"*traffRed,measures$"CO2")
#
#measures$"traffic" <- ifelse(measures[[massnahme]]==auspraegung,measures$"traffic"*traffRed,measures$"traffic")
# # DRT müsste irgendwie separat dazu kommen.
#
#measures$"parking" <- ifelse(measures[[massnahme]]==auspraegung,measures$"parking"*traffRed,measures$"parking")
# # (Auto-Abschaffung analog CO2-Reduktion)
#
#measures$"Kosten" <- ifelse(measures[[massnahme]]==auspraegung,measures$"Kosten" - 4*365,measures$"Kosten")
# 4 Mio Einnahmen pro Tag.  Habe ich jetzt 1:1 eingetragen.  Umrechungen ggf. am Ende.
#

# --

#auspraegung <- zeroEmissionsZone
#
#measures$"CO2" <- ifelse(measures[[massnahme]]==auspraegung,measures$"CO2"*0.5,measures$"CO2")
# # ähnliche Wirkung auf wie "Maut für alle".  Wirkt intuitiv richtig, aber warum?
#
#measures$"traffic" <- ifelse(measures[[massnahme]]==auspraegung,measures$"traffic"*0.75,measures$"traffic")
# # Eine Hälfte zahlt Maut, die andere wechselt auf nicht-fossiles Auto.
#
#measures$"parking" <- ifelse(measures[[massnahme]]==auspraegung,measures$"parking"*0.75,measures$"parking")
# # Eine Hälfte zahlt Maut, die andere wechselt auf nicht-fossiles Auto.
#
#measures$"Kosten" <- ifelse(measures[[massnahme]]==auspraegung,measures$"Kosten" - 2*365,measures$"Kosten")
# Annahme: 1/2 * MautFürAlle
#
############################################

#### 3. BERECHNUNG ####

############################################
measures$"KostenProKopf" <- - measures$"Kosten"/3.800000
measures$"KostenProErwachsener" <- - measures$"Kosten"/3.0600000
# (wir dividieren nur durch 3.8 statt 3.8 Mio, weil wir die "Mio" aus der Einheit rausnehmen)


# adjust to 10pct steps.  Does not yet work exactly as intended.

measures$CO2 <- ifelse( measures$CO2 < 0.95 & measures$CO2 > 0.05, round( measures$CO2 * 20) / 20, measures$CO2 )
measures$traffic <- round( measures$traffic * 100 ) / 100
measures$parking <- round( measures$parking * 100 ) / 100

#measures$Kosten <- round( measures$Kosten /20 ) * 20

# adding "1" to costs since this is decucted by the dashboard.  And then we divide by 100 to compensate for the % sign. (no, other way round)
measures$"Kosten" <- - measures$"Kosten"
#measures$"Kosten" <- (measures$"Kosten"*1000*1000/100)+1
#measures$"KostenProKopf" <- (measures$"KostenProKopf"/100)+1
#measures$"KostenProErwachsener" <- (measures$"KostenProErwachsener"/100)+1

############################################

#### 4. SAFETY NET ####

# safety net:
measures$"CO2" <- ifelse( measures$"CO2" < 0.0, 0.0, measures$"CO2")


### number format "x.yz"
#options(digits = 1)

#### 5. writing CSV file ## PATH FOR OUTPUT ####
write.csv(measures, "CCC_dashboard_gueter.csv", row.names=FALSE)

print("done")