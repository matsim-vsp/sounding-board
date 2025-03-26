## loading packages
# library(tidyr)
# library(tidyverse)
# library(lubridate)
# library(viridis)
# library(dplyr)
library(utils)
#########################################################################################################
#########################################################################################################
# options(error=function() { traceback(2); if(!interactive()) quit("no", status = 1, runLast = FALSE) })
print("########################################################################################")
print("########################################################################################")
#########################################################################################################
#########################################################################################################
## expanding grid with measures

mautFossil <- "mautFossil"
kiezbloeckeGanzeStadt <- "ganze Stadt"

frame <- expand.grid(OePNV = c("base","dekarbonisiert","stark"),
                  kiezblocks = c("base",kiezbloeckeGanzeStadt),
                  Fahrrad = c("base","stark"),
                     fahrenderVerkehr = c("base",mautFossil,"MautFuerAlle","zeroEmissionsZone","zeroEmissionsZonePlusMaut","autofrei"),
                     # fahrenderVerkehr = c("base","zeroEmissionsZone","zeroEmissionsZonePlusMaut","autofrei"),
                  DRT = c("base","nurAussenbezirke","ganzeStadt"),
                  Parkraum = c("base","BesucherFossilTeuer_alleAnderenPreiswert", "Besucher_teuer_Anwohner_preiswert","Besucher_teuer_Anwohner_teuer")
                  )
                  #kiezblocksAussenbezirke = c("base",kiezbloeckeGanzeStadt),
                  #fahrenderVerkehrAussenbezirke = c("base",mautFossil,"MautFuerAlle","zeroEmissionsZone","autofrei"),
                  # ParkraumAussenbezirke = c("base","Besucher_teuer_Anwohner_preiswert","Besucher_teuer_Anwohner_teuer")

## adding output values: CO2, Kosten, Menge fließender Verkehr, Menge stehender Verkehr
## value in relation (1.00 = 100%)
CO2 <- c(1.00)
traffic <- c(1.00)
drtTraffic <- c(0.00)
parking <- c(1.00)

Kosten <- c(0.00)
# Das sind jetzt mio Eu / Jahr.  Am Ende fügen wir noch Eu / (Kopf * Monat) hinzu.

measures <- cbind(frame,CO2,Kosten,traffic,parking)
#########################################################################################################
#########################################################################################################

## MASSNAHMEN --> Mengengerüste (traffic, parking, co2)

############################################
############################################
massnahme <- "Fahrrad"
auspraegung <- "stark"



# Annahme: Fahrrad 2013 13%, Fahrad 2018 18%.  Annahme 2025 25%.
# Annahme Fahrrad-Infra erhöht die 25% auf 35%. (Kopenhagen 33%).
# Annahme: Von diesen 10% kommen 3% vom Auto.  Das bedeutet eine Reduktion Auto von 30 auf 27%, also minus 10%.

measures$"CO2" <- ifelse(measures[[massnahme]]==auspraegung,measures$"CO2"*0.9,measures$"CO2")
measures$"traffic" <- ifelse(measures[[massnahme]]==auspraegung,measures$"traffic"*0.9,measures$"traffic")
measures$"parking" <- ifelse(measures[[massnahme]]==auspraegung,measures$"parking"*0.95,measures$"parking")
# Annahme: Jede zweite Person schafft ihr Auto ab.

############################################
############################################
massnahme <- "OePNV"

auspraegung <- "stark"

# BVG macht ÖPNV attraktiver: Frequenz, billigeres Ticket, Ausbau, Komfort
# Kosten siehe später
# Paket senkt Auto-Anteil um etwa 10% (wie Fahrrad)

measures$"CO2" <- ifelse(measures[[massnahme]]==auspraegung,measures$"CO2"*0.9,measures$"CO2")
measures$"traffic" <- ifelse(measures[[massnahme]]==auspraegung,measures$"traffic"*0.9,measures$"traffic")
measures$"parking" <- ifelse(measures[[massnahme]]==auspraegung,measures$"parking"*0.95,measures$"parking")

############################################
############################################
massnahme <- "kiezblocks"
auspraegung <- kiezbloeckeGanzeStadt

# Im Ruhrgebiet hatten wir für Kiezblöcke mit _Sperrung_ für Autos Absenkung modal split von 36% auf 27%, also 23% weg.  Wenn wir nicht für die Autos
# sperren, sondern nur Schritttempo plus keine Durchfahrt, dann erwarten wir ca. 1/2 der Wirkung, also 11.5%, gerundet 10%.  Das ist wohl auch
# halbwegs konsistent mit Leipzig (dort wurde gesperrt, aber kleinere Blöcke als Ruhr).

# hier eventuelle 3 Ausprägungen: base, Innenstadt (realistischer), ganze Stadt (flächendeckend unrealistisch)

measures$"CO2" <- ifelse(measures[[massnahme]]==auspraegung,measures$"CO2" * 0.9,measures$"CO2")

measures$"traffic" <- ifelse(measures[[massnahme]]==auspraegung,measures$"traffic" * 0.9,measures$"traffic")

measures$"parking" <- ifelse(measures[[massnahme]]==auspraegung,measures$"parking" * 0.95,measures$"parking")
# Annahme: Jede zweite Person schafft ihr Auto ab.


############################################
############################################
massnahme <- "Parkraum"
# aus webex Sendung von Tilmann
# ---

auspraegung <- "BesucherFossilTeuer_alleAnderenPreiswert"

# Erster Schritt: Parkgebühren.  Der betroffene Teil (10%) wird gefünftelt; daraus insgesamt: Auto geht von 20% auf 12%.

# Zweiter Schritt: Möglichkeit E-Auto.  (b) Von obigen 8% wechseln 4 wieder zurück.  Von den anderen 2% fossiles Auto kaufen sich 2/3 ein el. Auto.

# Resultat: 10% weiterhin fossil; von den anderen 10% sind 4% weg, 4% elektrisch, 2/3 * 2% = 1.33% elektrisch, Rest = 0.66% fossil.

# Insgesamt: 10.66% fossil, 5.33% elektrisch, 4% weg.

measures$"CO2" <- ifelse(measures[[massnahme]]==auspraegung,measures$"CO2"*10.66/20,measures$"CO2")

measures$"traffic" <- ifelse(measures[[massnahme]]==auspraegung,measures$"traffic"*16/20,measures$"traffic")
# wie CO2

measures$"parking" <- ifelse(measures[[massnahme]]==auspraegung,measures$"parking"*18/20,measures$"parking")
# Gehe wie immer davon aus, dass 1/2 davon ihr Auto verkaufen.  

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
# (es handelt sich ja um Besucherparkplätze)

# ---

auspraegung <- "Besucher_teuer_Anwohner_teuer"

# yyyyyy Auch hier wäre die Frage, wie viele dem ausweichen können.

measures$"CO2" <- ifelse(measures[[massnahme]]==auspraegung,measures$"CO2"*0.2,measures$"CO2")
# car share von 20% auf 2%

measures$"traffic" <- ifelse(measures[[massnahme]]==auspraegung,measures$"traffic"*0.2,measures$"traffic")
# car share von 20% auf 2%

measures$"parking" <- ifelse(measures[[massnahme]]==auspraegung,measures$"parking"*0.2,measures$"parking")
# Hier Annahme gleiche Reduktion wie "fahrend" (weil die ja mit dem Auto nichts mehr anfangen können).

############################################
###########################################

massnahme <- "fahrenderVerkehr"

# --------------------------------------------
# --------------------------------------------

auspraegung <- mautFossil

# Erster Schritt: Maut.  40% wechseln vom Auto weg (s.a. unten "MautFuerAlle").

# Zweiter Schritt: Möglichkeit E-Auto.  
# (a) Von obigen 40%-Pkte wechseln 20%-Pkte wieder zurück.  
# (b) Von den anderen 60%-Pkten fossiles Auto kaufen sich 2/3 ein elektrisches.

# Resultat: 20%Pkte plus 40%Pkte = 60%Pkte elektrisch; 20%Pkte (fossil) plus 60Pkte (elektrisch) insgesamt.

measures$"CO2" <- ifelse(measures[[massnahme]]==auspraegung,measures$CO2*0.2,measures$CO2)
measures$"traffic" <- ifelse(measures[[massnahme]]==auspraegung,measures$traffic*0.8,measures$traffic)
measures$"parking" <- ifelse(measures[[massnahme]]==auspraegung,measures$parking*0.9,measures$parking)
# nur Hälfte derjenigen, die nicht mehr fahren, schaffen auch das Auto ganz ab

# --------------------------------------------
# --------------------------------------------

auspraegung <- "MautFuerAlle"
# 20ct/km

measures$"CO2" <- ifelse(measures[[massnahme]]==auspraegung,measures$CO2*0.6,measures$CO2)
measures$"traffic" <- ifelse(measures[[massnahme]]==auspraegung,measures$traffic*0.6,measures$traffic)
measures$"parking" <- ifelse(measures[[massnahme]]==auspraegung,measures$parking*0.8,measures$parking)
# nur Hälfte derjenigen, die nicht mehr fahren, schaffen auch das Auto ganz ab


# --------------------------------------------
# --------------------------------------------

auspraegung <- "zeroEmissionsZone"

measures$CO2 <- ifelse(measures[[massnahme]]==auspraegung,measures$CO2*0.0, measures$CO2)
measures$traffic <- ifelse(measures[[massnahme]]==auspraegung,measures$traffic*0.9, measures$traffic)
# El. Auto nach Variabilisierung Batterie genauso teuer wie fossiles Auto.  10% können sich kein neues Auto leisten.

measures$parking <- ifelse(measures[[massnahme]]==auspraegung,measures$parking*0.9, measures$parking)
# Alte Gurke behalten lohnt nicht weil nicht mehr nutzbar.

# --------------------------------------------

auspraegung <- "zeroEmissionsZonePlusMaut"

measures$CO2 <- ifelse(measures[[massnahme]]==auspraegung,measures$CO2*0.0, measures$CO2)
measures$traffic <- ifelse(measures[[massnahme]]==auspraegung,measures$traffic*0.9*0.6, measures$traffic)
measures$parking <- ifelse(measures[[massnahme]]==auspraegung,measures$parking*0.9*0.7, measures$parking)

# --------------------------------------------

auspraegung <- "autofrei"

measures$CO2 <- ifelse(measures[[massnahme]]==auspraegung,measures$CO2*0.0,measures$CO2)
measures$traffic <- ifelse(measures[[massnahme]]==auspraegung,measures$traffic*0.0,measures$traffic)
measures$parking <- ifelse(measures[[massnahme]]==auspraegung,measures$parking*0.0,measures$parking)

############################################
############################################
massnahme <- "DRT"

# Wir hatten, beim Nachdenken, folgendes spezifiziert:
# (1) einen muva-ähnlichen DRT.  Für die sogenannte "Direktfahrt" benötigt man ein VBB-Ticket plus 1,50Eu/km.
# (2) ein miles-ähnliches car-sharing.  Dort derzeit 1Eu + 1Eu/km.  Wir vermuten sinkende Kosten und daher Preise, und wollen das aus planerischer
# Sicht nur auf den km-Preis anwenden.  Also 1Eu + 50ct/km

# Beim Parken gehen wir davon aus, dass das durch eine Betriebsgebühr in Höhe der derzeitigen für car sharing (1XX Eu/Monat) abgehakt ist.

# Bzgl. Maut müssen wir uns noch etwas ausdenken!!!  Genau genommen ist sie aber irgendwie Teil des km-Preises.

auspraegung <- "ganzeStadt"

# Wir haben dann "vermutet", dass bei Auto-Verbot 75% der Autofahrer auf einen solchen Service umsteigen würden.  Also müssen wir rauskriegen, wieviel
# "verscheuchte" Autofahrer wir haben, nachdem die obigen Massnahmen eingeführt wurden.  Das ist 1 - measures$traffic.  Davon kommen dann 0.75 wieder
# dazu.
measures$traffic <- ifelse(measures[[massnahme]]==auspraegung, measures$traffic + (1.-measures$traffic) * 0.75,measures$traffic)
measures$drtTraffic <- ifelse(measures[[massnahme]]==auspraegung, (1.-measures$traffic) * 0.75,0)


# CO2 kommt keiner hinzu weil elektrisch:
#measures$"CO2" <- ifelse(measures[[massnahme]]==auspraegung,measures$"CO2" - 0.02,measures$"CO2")

# Kosten kommen keine hinzu weil in etwa kostenneutral:

# yyyy parking muss gelöst werden, weil bei "freiwilligem" Umstieg das Parken wegfällt.  (Aber macht das viel aus?)
#measures$"parking" <- ifelse(measures[[massnahme]]==auspraegung,measures$"parking" - 0.05,measures$"parking")

auspraegung <- "nurAussenbezirke"

# irgendeine Idee? X% des Verkehrs sind in den Innenbezirken (ist in PAVE drin); darüber runterrechnen???
measures$traffic <- ifelse(measures[[massnahme]]==auspraegung, measures$traffic + (1.-measures$traffic) * 0.65,measures$traffic)
measures$drtTraffic <- ifelse(measures[[massnahme]]==auspraegung,(1.-measures$traffic) * 0.65,0)
# measures$"CO2" <- ifelse(measures[[massnahme]]==auspraegung,measures$"CO2" - 0.02,measures$"CO2")
# measures$"parking" <- ifelse(measures[[massnahme]]==auspraegung,measures$"parking" - 0.05,measures$"parking")

###########################################
############################################

####PAVE
### in PAVE hatten wir als Zusatzmaßnahme zu DRT die variablen PKW-Kosten von 0,20 €/km auf 0,40 €/km und auf 0,60 €/km erhöht (also so etwas wie globale Distanzmaut)
### DRT wurde hier sowohl als Taxi im Hundekopf und zusätzlich als Pooling Berlin-weit angeboten,
### s. auch https://vsp.berlin/pave/3-combined/T200P100-000-p3-10 und S.215ff im PAVE Bericht (VSP-WP 21-30)
##
## CO2:      0,20€/km -> ~ -50%, 0,40€/km -> -75%
## traffic:  0,20€/km -> ~ -35% FzgKm, 0,40€/km -> -55% FzgKm
## Kosten:   3,5 bis 4 Millionen Euro Einnahmen (+) am Tag
## parking:  0,20€/km -> ~ -50% car modal split, 0,40€/km -> -75% car modal split (VSP WP 20-03 does not explicitly confirm but points in the same direction (only cares about nr of drt rides and shift from cars))


#########################################################################################################
#########################################################################################################
#########################################################################################################
#########################################################################################################
#########################################################################################################
#########################################################################################################

## MENGEN --> KOSTEN

############################################
############################################
massnahme <- "Fahrrad"
auspraegung <- "stark"

measures$"Kosten" <- ifelse(measures[[massnahme]]==auspraegung,measures$"Kosten" + 70,measures$"Kosten")
# Kosten ca. 1000Eu/qm.  1000km Radwegnetz.  4 Meter Breite.  4 * 1000 * 1000 * 1000 = 4e9.  Abgeschrieben 30J = 133 Mio/J.'
# Kosten 70 Mio /J auf 10 Jahre: 100km RSV + 850km Vorrangnetz + 1500km Ausbau
# Ca. 1 Mio pro km.  Ca. 2500km.  Also 2500 Mio.  Div durch 30 Jahre.  Ca. 70 Mio/J.

############################################
############################################
massnahme <- "kiezblocks"
auspraegung <- kiezbloeckeGanzeStadt

measures$"Kosten" <- ifelse(measures[[massnahme]]==auspraegung,measures$"Kosten" + 10,measures$"Kosten")
# https://docs.google.com/spreadsheets/d/1pHne8cdCsSHKrH0WI6YFU2Ocv7RBMFR58T50n1KswFY/edit#gid=691888471
# 300kEu - 400kEu pro Kiezblock Umbaukosten.  Sagen wir 500kEu.  200 Blöcke.  (Ca. 20k Einwohner pro Kiez; 4000k/20k=200.)
# 200 x 500kEu = 100'000 kEu.  Abschreibung (nur) über 10 Jahre, weil dauernd kaputtgefahren.

############################################
############################################
massnahme <- "Parkraum"

# ---

auspraegung <- "BesucherFossilTeuer_alleAnderenPreiswert" 

measures$Kosten <- ifelse( measures[[massnahme]]==auspraegung,  measures$Kosten - (measures$traffic-measures$drtTraffic) *0.033*2.5*4*365,     measures$Kosten)

# 1 mio trips.  50% do not pay for parking --> remain.  Other 50% reduced to 10%.  Out of that, 2/3 move to electric.  That is, 3.33% of moving traffic pays for parking.

# OLD: 1 mio car trips in base case, corresponding to 20% mode share.  Half
# of that, i.e. 10%pts, will not pay.  8%pts goes away.  2%pts remains.  I.e. 10% of original, 100k.  So these pay approx for 2.5hrs per day.  10Eu x 100k = 1m/day.

# ---

auspraegung <- "Besucher_teuer_Anwohner_preiswert"

measures$Kosten <- ifelse( measures[[massnahme]]==auspraegung,measures$Kosten - (measures$traffic-measures$drtTraffic) *0.1*2.5*4*365,     measures$Kosten)

# 1 mio trips.  50% do not pay for parking --> remain.  Other 50% reduced to 10%.  That is, 10% of moving traffic pays for parking.

# OLD: 1 mio car trips in base case, corresponding to 20% mode share.  Half
# of that, i.e. 10%pts, will not pay.  8%pts goes away.  2%pts remains.  I.e. 10% of original, 100k.  So these pay approx for 2.5hrs per day.  10Eu x 100k = 1m/day.

#subtract DRT traffic because besucher-parking uses the traffic to calculate the costs but DRTs are only driving
# ---

auspraegung <- "Besucher_teuer_Anwohner_teuer"

measures$Kosten <- ifelse(measures[[massnahme]]==auspraegung,measures$Kosten - measures$parking*1000 - (measures$traffic-measures$drtTraffic)*0.1*2.5*4*365 ,          measures$Kosten)


# OLD The remaining 10pct pay 10Eu per day as above, plus 2.8 Eu per day for "Anwohner".

############################################
############################################
massnahme <- "DRT"

# Wir hatten, beim Nachdenken, folgendes spezifiziert:
# (1) einen muva-ähnlichen DRT.  Für die sogenannte "Direktfahrt" benötigt man ein VBB-Ticket plus 1,50Eu/km.
# (2) ein miles-ähnliches car-sharing.  Dort derzeit 1Eu + 1Eu/km.  Wir vermuten sinkende Kosten und daher Preise, und wollen das aus planerischer
# Sicht nur auf den km-Preis anwenden.  Also 1Eu + 50ct/km

# Beim Parken gehen wir davon aus, dass das durch eine Betriebsgebühr in Höhe der derzeitigen für car sharing (1XX Eu/Monat) abgehakt ist.

# yyyyyy Bzgl. Maut müssen wir uns noch etwas ausdenken!!!

# --

auspraegung <- "ganzeStadt"

# Kosten kommen keine hinzu weil in etwa kostenneutral:
#measures$"Kosten" <- ifelse(measures[[massnahme]]==auspraegung,measures$"Kosten" - 0.05,measures$"Kosten")

# --

auspraegung <- "nurAussenbezirke"

# measures$"Kosten" <- ifelse(measures[[massnahme]]==auspraegung,measures$"Kosten" - 0.05,measures$"Kosten")


############################################
###########################################
massnahme <- "fahrenderVerkehr"

# --------------------------------------------
# --------------------------------------------

auspraegung <- mautFossil

measures$Kosten <- ifelse(measures[[massnahme]]==auspraegung,measures$Kosten - measures$CO2/0.6 *4*365,measures$"Kosten")

# OLD: Annahme: 1/2 * MautFürAlle

# --------------------------------------------
# --------------------------------------------

auspraegung <- "MautFuerAlle"
# 20ct/km

measures$Kosten <- ifelse(measures[[massnahme]]==auspraegung,    measures$Kosten - measures$traffic/0.6 * 4*365,    measures$Kosten)
# 4 Mio Einnahmen pro Tag.  Bei diesem Szenario ist measures$traffic = 0.6; also müssten die 4 Mio durch 0.6 Verkehr erzeugt werden; daher Division durch 0.6.

# --------------------------------------------
# --------------------------------------------

auspraegung <- "zeroEmissionsZone"

measures$Kosten <- ifelse(measures[[massnahme]]==auspraegung,measures$"Kosten" + 0.01 ,measures$"Kosten")
# Schilder, Durchsetzung, etc.

# --------------------------------------------

auspraegung <- "zeroEmissionsZonePlusMaut"

measures$"Kosten" <- ifelse(measures[[massnahme]]==auspraegung,measures$"Kosten" + 0.01 - measures$traffic/0.6*4*365 ,measures$Kosten)
# Schilder, Durchsetzung, etc.

# --------------------------------------------

auspraegung <- "autofrei"

measures$"Kosten" <- ifelse(measures[[massnahme]]==auspraegung,measures$"Kosten",measures$"Kosten")

############################################
############################################

####PAVE
### in PAVE hatten wir als Zusatzmaßnahme zu DRT die variablen PKW-Kosten von 0,20 €/km auf 0,40 €/km und auf 0,60 €/km erhöht (also so etwas wie globale Distanzmaut)
### DRT wurde hier sowohl als Taxi im Hundekopf und zusätzlich als Pooling Berlin-weit angeboten,
### s. auch https://vsp.berlin/pave/3-combined/T200P100-000-p3-10 und S.215ff im PAVE Bericht (VSP-WP 21-30)
##
## CO2:      0,20€/km -> ~ -50%, 0,40€/km -> -75%
## traffic:  0,20€/km -> ~ -35% FzgKm, 0,40€/km -> -55% FzgKm
## Kosten:   3,5 bis 4 Millionen Euro Einnahmen (+) am Tag

## parking:  0,20€/km -> ~ -50% car modal split, 0,40€/km -> -75% car modal split (VSP WP 20-03 does not explicitly confirm but points in the same direction (only cares about nr of drt rides and shift from cars)) ((can't say what this line is saying since it (1) says nothing about parking, and (2) repeats the CO2 results from above.  kai, jun'24))


#########################################################################################################
#########################################################################################################
#########################################################################################################
#########################################################################################################
#########################################################################################################
#########################################################################################################
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
# yyyyyy wieso wird daraus "40" im Dashboard??

auspraegung <- "stark"

# "Das Investitionsvolumen für Bau und Planung aller i2030-Korridore liegt Stand 2023 bei ca. 10,6 Mrd. €."  https://www.i2030.de/fragen-und-hintergruende-zur-nutzen-kosten-untersuchungen-bei-i2030/
# 10 Mrd / 20J = 500 Mio/J.  yyyyyy Reicht das aus, um den Auto-Anteil um 10% zu drücken?
# Plus die Kosten der Dekarbonisierung (siehe oben).
measures$"Kosten" <- ifelse(measures[[massnahme]]==auspraegung,measures$"Kosten" + 500 + 50,measures$"Kosten")


############################################
############################################
measures$"KostenProKopf" <- - measures$"Kosten"/3.800000
measures$"KostenProErwachsener" <- - measures$"Kosten"/3.0600000
# (wir dividieren nur durch 3.8 statt 3.8 Mio, weil wir die "Mio" aus der Einheit rausnehmen)


# adjust to 5pct steps.  Does not yet work exactly as intended.

measures$CO2 <- ifelse( measures$CO2 < 0.95 & measures$CO2 > 0.05, round( measures$CO2 * 20) / 20, measures$CO2 )
measures$traffic <- round( measures$traffic * 20 ) / 20
measures$parking <- round( measures$parking * 20 ) / 20

measures$Kosten <- round( measures$Kosten /10 ) * 10

# adding "1" to costs since this is decucted by the dashboard.  And then we divide by 100 to compensate for the % sign. (no, other way round)
measures$"Kosten" <- - measures$"Kosten"*1000*1000
#measures$"Kosten" <- (measures$"Kosten"*1000*1000/100)+1
#measures$"KostenProKopf" <- (measures$"KostenProKopf"/100)+1
#measures$"KostenProErwachsener" <- (measures$"KostenProErwachsener"/100)+1

############################################
############################################
# safety net:
measures$"CO2" <- ifelse( measures$"CO2" < 0.0, 0.0, measures$"CO2")

############################################
############################################
### number format "x.yz"
#options(digits = 1) 

### writing CSV file ## PATH FOR OUTPUT
write.csv(measures, "~/git/public-svn/matsim/scenarios/countries/de/berlin/projects/sounding-board/current/CCC_dashboard_KN.csv", row.names=FALSE)

print("done")

