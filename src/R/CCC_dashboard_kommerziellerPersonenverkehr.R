#### DASHBOARD KOMMERZIELLER PERSONENVERKEHR ####

## libraries
library(utils)

# options(error=function() { traceback(2); if(!interactive()) quit("no", status = 1, runLast = FALSE) })
print("########################################################################################")
print("########################################################################################")
#### 1. expanding grid with measures ####

mautFossil <- "mautFossil"
kiezbloeckeGanzeStadt <- "ganze Stadt"

frame <- expand.grid(#OePNV = c("base","dekarbonisiert"),
                     kiezblocks = c("base",kiezbloeckeGanzeStadt),
                     #Fahrrad = c("base","stark"),
                     fahrenderVerkehr = c("base",mautFossil,"MautFuerAlle","zeroEmissionsZone","zeroEmissionsZonePlusMaut","autofrei"),
                     DRT = c("base","nurAussenbezirke","ganzeStadt"),
                     Parkraum = c("base","Besucher_teuer_Anwohner_preiswert","Besucher_teuer_Anwohner_teuer")
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

####    A Fahrrad ####
massnahme <- "Fahrrad"
auspraegung <- "stark"

# Annahme: Fahrrad nimmt 10% vom Autoverkehr weg.  Also z.B. 30% auf 27%.

measures$"CO2" <- ifelse(measures[[massnahme]]==auspraegung,measures$"CO2"*0.9,measures$"CO2")
measures$"traffic" <- ifelse(measures[[massnahme]]==auspraegung,measures$"traffic"*0.9,measures$"traffic")

measures$"parking" <- ifelse(measures[[massnahme]]==auspraegung,measures$"parking"*0.95,measures$"parking")
# Annahme: Jede zweite Person schafft ihr Auto ab.

measures$"Kosten" <- ifelse(measures[[massnahme]]==auspraegung,measures$"Kosten" + 70,measures$"Kosten")
# Kosten ca. 1000Eu/qm.  1000km Radwegnetz.  4 Meter Breite.  4 * 1000 * 1000 * 1000 = 4e9.  Abgeschrieben 30J = 133 Mio/J.'
# Kosten 70 Mio /J auf 10 Jahre: 100km RSV + 850km Vorrangnetz + 1500km Ausbau


####    B Superblocks/Kiezblocks ####

massnahme <- "kiezblocks"
auspraegung <- "ganze Stadt"

# Im Ruhrgebiet hatten wir für Kiezblöcke mit _Sperrung_ für Autos Absenkung modal split von 36% auf 27%, also 23% weg.  Wenn wir nicht für die Autos
# sperren, sondern nur Schritttempo plus keine Durchfahrt, dann erwarten wir ca. 1/2 der Wirkung, also 11.5%, gerundet 10%.  Das ist wohl auch
# halbwegs konsistent mit Leipzig (dort wurde gesperrt, aber kleinere Blöcke als Ruhr).

# hier eventuelle 3 Ausprägungen: base, Innenstadt (realistischer), ganze Stadt (flächendeckend unrealistisch)

measures$"CO2" <- ifelse(measures[[massnahme]]==auspraegung,measures$"CO2" * 0.9,measures$"CO2")

measures$"traffic" <- ifelse(measures[[massnahme]]==auspraegung,measures$"traffic" * 0.9,measures$"traffic")

measures$"parking" <- ifelse(measures[[massnahme]]==auspraegung,measures$"parking" * 0.95,measures$"parking")
# Annahme: Jede zweite Person schafft ihr Auto ab.

measures$"Kosten" <- ifelse(measures[[massnahme]]==auspraegung,measures$"Kosten" + 10,measures$"Kosten")
# https://docs.google.com/spreadsheets/d/1pHne8cdCsSHKrH0WI6YFU2Ocv7RBMFR58T50n1KswFY/edit#gid=691888471

####    C DRT ####

massnahme <- "DRT"
auspraegung <- "nurAussenbezirke"

measures$"CO2" <- ifelse(measures[[massnahme]]==auspraegung,measures$"CO2" - 0.02,measures$"CO2")
measures$"Kosten" <- ifelse(measures[[massnahme]]==auspraegung,measures$"Kosten" - 0.05,measures$"Kosten")
measures$"traffic" <- ifelse(measures[[massnahme]]==auspraegung,measures$"traffic" - 0.05,measures$"traffic")
measures$"parking" <- ifelse(measures[[massnahme]]==auspraegung,measures$"parking" - 0.05,measures$"parking")

auspraegung <- "ganzeStadt"

measures$"CO2" <- ifelse(measures[[massnahme]]==auspraegung,measures$"CO2" - 0.02,measures$"CO2")
measures$"Kosten" <- ifelse(measures[[massnahme]]==auspraegung,measures$"Kosten" - 0.05,measures$"Kosten")
measures$"traffic" <- ifelse(measures[[massnahme]]==auspraegung,measures$"traffic" - 0.05,measures$"traffic")
measures$"parking" <- ifelse(measures[[massnahme]]==auspraegung,measures$"parking" - 0.05,measures$"parking")

####    D fahrenderVerkehrHundekopf ####

####PAVE
### in PAVE hatten wir als Zusatzmaßnahme zu DRT die variablen PKW-Kosten von 0,20 €/km auf 0,40 €/km und auf 0,60 €/km erhöht (also so etwas wie globale Distanzmaut)
### DRT wurde hier sowohl als Taxi im Hundekopf und zusätzlich als Pooling Berlin-weit angeboten,
### s. auch https://vsp.berlin/pave/3-combined/T200P100-000-p3-10 und S.215ff im PAVE Bericht (VSP-WP 21-30)
##
## CO2:      0,20€/km -> ~ -50%, 0,40€/km -> -75%
## traffic:  0,20€/km -> ~ -35% FzgKm, 0,40€/km -> -55% FzgKm
## Kosten:   3,5 bis 4 Millionen Euro Einnahmen (+) am Tag
## parking:  0,20€/km -> ~ -50% car modal split, 0,40€/km -> -75% car modal split (VSP WP 20-03 does not explicitly confirm but points in the same direction (only cares about nr of drt rides and shift from cars))

####    E Parkraum ####

massnahme <- "Parkraum"

# aus webex Sendung von Tilmann

# ---

auspraegung <- "Besucher_teuer_Anwohner_preiswert"

measures$"CO2" <- ifelse(measures[[massnahme]]==auspraegung,measures$"CO2"*12/20,measures$"CO2")
# Im Prinzip car share von 20% auf 4%.  Aber wenn das nur 1/2 der
# Parkplätze betrifft, dann gehen der Verkehr dafür von 10% auf 2%,
# und der andere bleibt gleich.  Also von 20% auf 12%

measures$"traffic" <- ifelse(measures[[massnahme]]==auspraegung,measures$"traffic"*12/20,measures$"traffic")
# wie CO2

measures$"parking" <- ifelse(measures[[massnahme]]==auspraegung,measures$"parking"*16/20,measures$"parking")
# Gehe wie immer davon aus, dass 1/2 davon ihr Auto verkaufen.  Also von 10% auf 6%

measures$"Kosten" <- ifelse(measures[[massnahme]]==auspraegung,measures$"Kosten" - 1*365,measures$"Kosten")
# 1 mio car trips in base case, corresponding to 20% mode share.  Half
# of that, i.e. 10%pts, will not pay.  8%pts goes away.  2%pts remains.  I.e. 10% of original, 100k.  So these pay approx for 2.5hrs per day.  10Eu x 100k = 1m/day.

# ---

auspraegung <- "Besucher_teuer_Anwohner_teuer"

# yyyyyy Auch hier wäre die Frage, wie viele dem ausweichen können.

measures$"CO2" <- ifelse(measures[[massnahme]]==auspraegung,measures$"CO2"*0.2,measures$"CO2")
# car share von 20% auf 2%

measures$"traffic" <- ifelse(measures[[massnahme]]==auspraegung,measures$"traffic"*0.2,measures$"traffic")
# car share von 20% auf 2%

measures$"parking" <- ifelse(measures[[massnahme]]==auspraegung,measures$"parking"*0.2,measures$"parking")
# Hier Annahme gleiche Reduktion wie "fahrend".

measures$"Kosten" <- ifelse(measures[[massnahme]]==auspraegung,measures$"Kosten" - 1.28*365 ,measures$"Kosten")
# The remaining 10pct pay 10Eu per day as above, plus 2.8 Eu per day for "Anwohner".


# massnahme <- "ParkraumAussenbezirke"
# auspraegung <- "Besucher_teuer_Anwohner_preiswert"

# measures$"CO2" <- ifelse(measures[[massnahme]]==auspraegung,measures$"CO2" - 0.02,measures$"CO2")
# measures$"Kosten" <- ifelse(measures[[massnahme]]==auspraegung,measures$"Kosten" - 0.05,measures$"Kosten")
# measures$"traffic" <- ifelse(measures[[massnahme]]==auspraegung,measures$"traffic" - 0.05,measures$"traffic")
# measures$"parking" <- ifelse(measures[[massnahme]]==auspraegung,measures$"parking" - 0.05,measures$"parking")

# auspraegung <- "Besucher_teuer_Anwohner_teuer"

# measures$"CO2" <- ifelse(measures[[massnahme]]==auspraegung,measures$"CO2" - 0.02,measures$"CO2")
# measures$"Kosten" <- ifelse(measures[[massnahme]]==auspraegung,measures$"Kosten" - 0.05,measures$"Kosten")
# measures$"traffic" <- ifelse(measures[[massnahme]]==auspraegung,measures$"traffic" - 0.05,measures$"traffic")
# measures$"parking" <- ifelse(measures[[massnahme]]==auspraegung,measures$"parking" - 0.05,measures$"parking")


####    F fahrender Verkehr ####

massnahme <- "fahrenderVerkehr"

 --------------------------------------------
#
auspraegung <- "MautFuerAlle"
# # 20ct/km
#
traffRed<-0.6
#
measures$"CO2" <- ifelse(measures[[massnahme]]==auspraegung,measures$"CO2"*traffRed,measures$"CO2")
#
measures$"traffic" <- ifelse(measures[[massnahme]]==auspraegung,measures$"traffic"*traffRed,measures$"traffic")
# # DRT müsste irgendwie separat dazu kommen.
#
measures$"parking" <- ifelse(measures[[massnahme]]==auspraegung,measures$"parking"*traffRed,measures$"parking")
# # (Auto-Abschaffung analog CO2-Reduktion)
#
measures$"Kosten" <- ifelse(measures[[massnahme]]==auspraegung,measures$"Kosten" - 4*365,measures$"Kosten")
# # 4 Mio Einnahmen pro Tag.  Habe ich jetzt 1:1 eingetragen.  Umrechungen ggf. am Ende.
#
 --------------------------------------------
#
auspraegung <- mautFossil
#
measures$"CO2" <- ifelse(measures[[massnahme]]==auspraegung,measures$"CO2"*0.5,measures$"CO2")
# # ähnliche Wirkung auf wie "Maut für alle".  Wirkt intuitiv richtig, aber warum?
#
measures$"traffic" <- ifelse(measures[[massnahme]]==auspraegung,measures$"traffic"*0.75,measures$"traffic")
# # Eine Hälfte zahlt Maut, die andere wechselt auf nicht-fossiles Auto.
#
measures$"parking" <- ifelse(measures[[massnahme]]==auspraegung,measures$"parking"*0.75,measures$"parking")
# # Eine Hälfte zahlt Maut, die andere wechselt auf nicht-fossiles Auto.
#
measures$"Kosten" <- ifelse(measures[[massnahme]]==auspraegung,measures$"Kosten" - 2*365,measures$"Kosten")
# # Annahme: 1/2 * MautFürAlle
#
 --------------------------------------------
#

auspraegung <- "zeroEmissionsZone"

measures$"CO2" <- ifelse(measures[[massnahme]]==auspraegung,measures$"CO2"*0.01,measures$"CO2")

measures$"Kosten" <- ifelse(measures[[massnahme]]==auspraegung,measures$"Kosten" + 0.01 ,measures$"Kosten")
# Schilder, Durchsetzung, etc.

measures$"traffic" <- ifelse(measures[[massnahme]]==auspraegung,measures$"traffic",measures$"traffic")

measures$"parking" <- ifelse(measures[[massnahme]]==auspraegung,measures$"parking",measures$"parking")

--------------------------------------------

auspraegung <- "zeroEmissionsZonePlusMaut"

measures$"CO2" <- ifelse(measures[[massnahme]]==auspraegung,measures$"CO2"*0.01,measures$"CO2")

measures$"Kosten" <- ifelse(measures[[massnahme]]==auspraegung,measures$"Kosten" + 0.01 ,measures$"Kosten")
# Schilder, Durchsetzung, etc.

measures$"traffic" <- ifelse(measures[[massnahme]]==auspraegung,measures$"traffic"*traffRed,measures$"traffic")

measures$"parking" <- ifelse(measures[[massnahme]]==auspraegung,measures$"parking"*traffRed,measures$"parking")

--------------------------------------------

auspraegung <- "autofrei"

measures$"CO2" <- ifelse(measures[[massnahme]]==auspraegung,measures$"CO2"*0.0,measures$"CO2")
measures$"Kosten" <- ifelse(measures[[massnahme]]==auspraegung,measures$"Kosten",measures$"Kosten")
measures$"traffic" <- ifelse(measures[[massnahme]]==auspraegung,measures$"traffic"*0.0,measures$"traffic")
measures$"parking" <- ifelse(measures[[massnahme]]==auspraegung,measures$"parking"*0.0,measures$"parking")

#massnahme <- "fahrenderVerkehrHundekopf"
#auspraegung <- mautFossil

#measures$"CO2" <- ifelse(measures[[massnahme]]==auspraegung,measures$"CO2"/2,measures$"CO2")
## 

#measures$"Kosten" <- ifelse(measures[[massnahme]]==auspraegung,measures$"Kosten" + 0.05,measures$"Kosten")
#measures$"traffic" <- ifelse(measures[[massnahme]]==auspraegung,measures$"traffic" + 0.05,measures$"traffic")
#measures$"parking" <- ifelse(measures[[massnahme]]==auspraegung,measures$"parking" + 0.05,measures$"parking")

#auspraegung <- "MautFuerAlle"

#measures$"CO2" <- ifelse(measures[[massnahme]]==auspraegung,measures$"CO2" - 0.02,measures$"CO2")
#measures$"Kosten" <- ifelse(measures[[massnahme]]==auspraegung,measures$"Kosten" - 0.05,measures$"Kosten")
#measures$"traffic" <- ifelse(measures[[massnahme]]==auspraegung,measures$"traffic" - 0.05,measures$"traffic")
#measures$"parking" <- ifelse(measures[[massnahme]]==auspraegung,measures$"parking" - 0.05,measures$"parking")

#auspraegung <- "autofrei"

#measures$"CO2" <- ifelse(measures[[massnahme]]==auspraegung,measures$"CO2" - 0.02,measures$"CO2")
#measures$"Kosten" <- ifelse(measures[[massnahme]]==auspraegung,measures$"Kosten" - 0.05,measures$"Kosten")
#measures$"traffic" <- ifelse(measures[[massnahme]]==auspraegung,measures$"traffic" - 0.05,measures$"traffic")
#measures$"parking" <- ifelse(measures[[massnahme]]==auspraegung,measures$"parking" - 0.05,measures$"parking")


#massnahme <- "fahrenderVerkehrAussenbezirke"
#auspraegung <- mautFossil

#measures$"CO2" <- ifelse(measures[[massnahme]]==auspraegung,measures$"CO2" + 0.02,measures$"CO2")
#measures$"Kosten" <- ifelse(measures[[massnahme]]==auspraegung,measures$"Kosten" + 0.05,measures$"Kosten")
#measures$"traffic" <- ifelse(measures[[massnahme]]==auspraegung,measures$"traffic" + 0.05,measures$"traffic")
#measures$"parking" <- ifelse(measures[[massnahme]]==auspraegung,measures$"parking" + 0.05,measures$"parking")

#auspraegung <- "MautFuerAlle"

#measures$"CO2" <- ifelse(measures[[massnahme]]==auspraegung,measures$"CO2" - 0.02,measures$"CO2")
#measures$"Kosten" <- ifelse(measures[[massnahme]]==auspraegung,measures$"Kosten" - 0.05,measures$"Kosten")
#measures$"traffic" <- ifelse(measures[[massnahme]]==auspraegung,measures$"traffic" - 0.05,measures$"traffic")
#measures$"parking" <- ifelse(measures[[massnahme]]==auspraegung,measures$"parking" - 0.05,measures$"parking")

#auspraegung <- "autofrei"

#measures$"CO2" <- ifelse(measures[[massnahme]]==auspraegung,measures$"CO2" - 0.02,measures$"CO2")
#measures$"Kosten" <- ifelse(measures[[massnahme]]==auspraegung,measures$"Kosten" - 0.05,measures$"Kosten")
#measures$"traffic" <- ifelse(measures[[massnahme]]==auspraegung,measures$"traffic" - 0.05,measures$"traffic")
#measures$"parking" <- ifelse(measures[[massnahme]]==auspraegung,measures$"parking" - 0.05,measures$"parking")

####    G ÖPNV ####
massnahme <- "OePNV"

# Alles oberhalb von hier sind Pkw-Emissionen.  Das ist so etwas wie 4
# mio t / yr.  Davon sind jetzt noch irgendwelche pct übrig.  Das multiplizieren wir jetzt mit 0.99, und tun dann noch 0.01 drauf oder auch nicht.

# ---

auspraegung <- "base"

measures$"CO2" <- ifelse(measures[[massnahme]]==auspraegung,measures$"CO2"*0.99+0.01,measures$"CO2")

# ---
auspraegung <- "dekarbonisiert"

measures$"CO2" <- ifelse(measures[[massnahme]]==auspraegung,measures$"CO2"*0.99,measures$"CO2")

# BVG hat ca. 1500 Busse.  Halten ca. 15 Jahre, also 100 neu pro Jahr.  E-Busse kosten ca. 680k, angeblich 3x so teuer wie fossile Busse.  Wir rechnen
# nur die Mehrkosten wg. El, also 2/3 * 680 = 450kEu.  Mal 100 = 45Mio/Jahr.  An anderer Stelle berichtet BVG 65Mio für 90 Ebusse plus Infra.  Davon
# müsste man aber die ohnehin entstehenden Kosten für fossile Busse wieder abziehen.
# https://docs.google.com/spreadsheets/d/1pHne8cdCsSHKrH0WI6YFU2Ocv7RBMFR58T50n1KswFY/edit#gid=691888471
measures$"Kosten" <- ifelse(measures[[massnahme]]==auspraegung,measures$"Kosten" + 50,measures$"Kosten")

# no consequences on moving/non-moving traffic:
#measures$"traffic" <- ifelse(measures[[massnahme]]==auspraegung,measures$"traffic",measures$"traffic")
#measures$"parking" <- ifelse(measures[[massnahme]]==auspraegung,measures$"parking",measures$"parking")

#### 3. BERECHNUNG ####

# adjust to 10pct steps.  Does not yet work exactly as intended.

measures$CO2 <- ifelse( measures$CO2 < 0.95 & measures$CO2 > 0.05, round( measures$CO2 * 10) / 10, measures$CO2 )
measures$traffic <- round( measures$traffic * 10 ) / 10
measures$parking <- round( measures$parking * 10 ) / 10

measures$Kosten <- round( measures$Kosten /10 ) * 10000000
measures$"KostenProKopfUndMonat" <- measures$"Kosten"/3800000
# (wir dividieren nur durch 3.8 statt 3.8 Mio, weil wir die "Mio" aus der Einheit rausnehmen)

# adding "1" to costs since this is decucted by the dashboard.  And then we divide by 100 to compensate for the % sign. (no, other way round)
# measures$"Kosten" <- (measures$"Kosten"/100)+1
# measures$"KostenProKopfUndMonat" <- (measures$"KostenProKopfUndMonat"/100)+1

#### 4. SAFETY NET ####

# safety net:
measures$"CO2" <- ifelse( measures$"CO2" < 0.0, 0.0, measures$"CO2")


### number format "x.yz"
#options(digits = 1) 

#### 5. writing CSV file ## PATH FOR OUTPUT ####
write.csv(measures, "/Users/mkreuschnervsp/Desktop/CCC_dashboard.csv", row.names=FALSE)

print("done")

