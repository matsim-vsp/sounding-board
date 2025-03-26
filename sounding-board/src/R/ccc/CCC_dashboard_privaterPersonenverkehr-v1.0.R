
### library ###

library(utils)
#########################################################################################################
#########################################################################################################
# options(error=function() { traceback(2); if(!interactive()) quit("no", status = 1, runLast = FALSE) })
print("########################################################################################")
print("########################################################################################")
#########################################################################################################
#########################################################################################################
## expanding grid with measures

DRTall <- "ganze Stadt"
DRTouter <- "nur Aussenbezirke"
kiezbloeckeAll <- "ganze Stadt"
kiezbloeckeInside <- "Innenstadt"

frame <- expand.grid( OePNV = c("base","dekarbonisiert","stark"),
                      kiezblocks = c("base",kiezbloeckeInside,kiezbloeckeAll),
                     Fahrrad = c("base","stark"),
                     Verbrenner = c("base","Maut","Verbot"),
                     E_Fahrzeuge = c("base","Maut","Verbot"),
                     DRT = c("base",DRTouter,DRTall),
                     Anwohnerparken = c("10 €/Jahr","100 €/Jahr","1.000 €/Jahr"),
                     Besucherparken = c("0,00 €/h","2,00 €/h","4,00 €/h")
                     )


## adding output values: CO2, Kosten, Menge fließender Verkehr, Menge stehender Verkehr
## value in relation (1.00 = 100%)
CO2 <- c(1.00)
traffic <- c(1.00)
parking <- c(1.00)

Kosten <- c(0.00)
# Das sind jetzt mio Eu / Jahr.  Am Ende fügen wir noch Eu / (Kopf * Monat).

measures <- cbind(frame,CO2,Kosten,traffic,parking)
#########################################################################################################
#########################################################################################################

## MASSNAHMEN --> Mengengerüste (traffic, parking, co2)

############################################
############################################
massnahme1 <- "Fahrrad"

# ---
auspraegung11 <- "stark"

# Annahme: Fahrrad 2013 13%, Fahrad 2018 18%.  Annahme 2025 25%.
# Annahme Fahrrad-Infra erhöht die 25% auf 35%. (Kopenhagen 33%).
# Annahme: Von diesen 10% kommen 3% vom Auto.  Das bedeutet eine Reduktion Auto von 30 auf 27%, also minus 10%.

measures$CO2 <- ifelse(measures[[massnahme1]]==auspraegung11,measures$"CO2" * 0.9,measures$CO2)
measures$traffic <- ifelse(measures[[massnahme1]]==auspraegung11,measures$"traffic" * 0.9,measures$traffic)

measures$parking <- ifelse(measures[[massnahme1]]==auspraegung11,measures$"parking" * 0.95,measures$parking)
# Annahme: Jede zweite Person schafft ihr Auto ab.


########################################################################################################## Superblocks/Kiezblocks

massnahme2 <- "kiezblocks"
# ---

auspraegung21 <- kiezbloeckeInside

# Im Ruhrgebiet hatten wir für Kiezblöcke mit _Sperrung_ für Autos Absenkung modal split von 36% auf 27%, also 23% weg.  Wenn wir nicht für die Autos
# sperren, sondern nur Schritttempo plus keine Durchfahrt, dann erwarten wir ca. 1/2 der Wirkung, also 11.5%, gerundet 10%.  Das ist wohl auch
# halbwegs konsistent mit Leipzig (dort wurde gesperrt, aber kleinere Blöcke als Ruhr).

# hier eventuelle 3 Ausprägungen: base, Innenstadt (realistischer), ganze Stadt (flächendeckend unrealistisch)

measures$"CO2" <- ifelse(measures[[massnahme2]]==auspraegung21,measures$"CO2" * 0.95,measures$CO2)

measures$"traffic" <- ifelse(measures[[massnahme2]]==auspraegung21,measures$"traffic" * 0.95,measures$traffic)

measures$"parking" <- ifelse(measures[[massnahme2]]==auspraegung21,measures$"parking" * 0.98,measures$parking)
# Annahme: Jede zweite Person schafft ihr Auto ab.

# ---

auspraegung22 <- kiezbloeckeAll

# Im Ruhrgebiet hatten wir für Kiezblöcke mit _Sperrung_ für Autos Absenkung modal split von 36% auf 27%, also 23% weg.  Wenn wir nicht für die Autos
# sperren, sondern nur Schritttempo plus keine Durchfahrt, dann erwarten wir ca. 1/2 der Wirkung, also 11.5%, gerundet 10%.  Das ist wohl auch
# halbwegs konsistent mit Leipzig (dort wurde gesperrt, aber kleinere Blöcke als Ruhr).

# hier eventuelle 3 Ausprägungen: base, Innenstadt (realistischer), ganze Stadt (flächendeckend unrealistisch)

measures$"CO2" <- ifelse(measures[[massnahme2]]==auspraegung22,measures$CO2 * 0.90,measures$CO2)

measures$"traffic" <- ifelse(measures[[massnahme2]]==auspraegung22,measures$traffic * 0.90,measures$traffic)

measures$"parking" <- ifelse(measures[[massnahme2]]==auspraegung22,measures$parking * 0.95,measures$parking)
# Annahme: Jede zweite Person schafft ihr Auto ab.


############################################
############################################
massnahme3 <- "Anwohnerparken"
massnahme4 <- "Besucherparken"

# aus webex Sendung von Tilmann

# ---
#auspraegung1 <- "base" #0,028€/tag
#auspraegung1 <- "base" #0€/h

# ---
auspraegung31 <- "10 €/Jahr"  #0,028€/tag
auspraegung42 <- "2,00 €/h" #1€/h
measures$"CO2" <- ifelse(measures[[massnahme3]]==auspraegung31 & measures[[massnahme4]]==auspraegung42,measures$"CO2"*7/20,measures$"CO2")
# Im Prinzip car share von 20% auf 19%.  Aber wenn das nur 1/2 der
# Parkplätze betrifft, dann gehen der Verkehr dafür von 10% auf 0.5%,
# und der andere bleibt gleich.  Also von 20% auf 12%
measures$"traffic" <- ifelse(measures[[massnahme3]]==auspraegung31 & measures[[massnahme4]]==auspraegung42,measures$"traffic"*7/20,measures$"traffic")
# wie CO2
measures$"parking" <- ifelse(measures[[massnahme3]]==auspraegung31 & measures[[massnahme4]]==auspraegung42,measures$"parking"*13.5/20,measures$"parking")
# Gehe wie immer davon aus, dass 1/2 davon ihr Auto verkaufen.
# ---
auspraegung31 <- "10 €/Jahr"  #0,028€/tag
auspraegung43 <- "4,00 €/h"  #4€/h
measures$"CO2" <- ifelse(measures[[massnahme3]]==auspraegung31 & measures[[massnahme4]]==auspraegung43,measures$"CO2"*4/20,measures$"CO2")
# Im Prinzip car share von 20% auf 19%.  Aber wenn das nur 1/2 der
# Parkplätze betrifft, dann gehen der Verkehr dafür von 10% auf 0.5%,
# und der andere bleibt gleich.  Also von 20% auf 12%
measures$"traffic" <- ifelse(measures[[massnahme3]]==auspraegung31 & measures[[massnahme4]]==auspraegung43,measures$"traffic"*4/20,measures$"traffic")
# wie CO2
measures$"parking" <- ifelse(measures[[massnahme3]]==auspraegung31 & measures[[massnahme4]]==auspraegung43,measures$"parking"*12/20,measures$"parking")
# Gehe wie immer davon aus, dass 1/2 davon ihr Auto verkaufen.
# ---
auspraegung32 <- "100 €/Jahr"  #0,28€/tag
auspraegung41 <- "0,00 €/h"      #0€/h
measures$"CO2" <- ifelse(measures[[massnahme3]]==auspraegung32 & measures[[massnahme4]]==auspraegung41,measures$"CO2"*20/20,measures$"CO2")
# Im Prinzip car share von 20% auf 19%.  Aber wenn das nur 1/2 der
# Parkplätze betrifft, dann gehen der Verkehr dafür von 10% auf 0.5%,
# und der andere bleibt gleich.  Also von 20% auf 12%
measures$"traffic" <- ifelse(measures[[massnahme3]]==auspraegung32 & measures[[massnahme4]]==auspraegung41,measures$"traffic"*20/20,measures$"traffic")
# wie CO2
measures$"parking" <- ifelse(measures[[massnahme3]]==auspraegung32 & measures[[massnahme4]]==auspraegung41,measures$"parking"*20/20,measures$"parking")
# Gehe wie immer davon aus, dass 1/2 davon ihr Auto verkaufen.
# ---
auspraegung32 <- "100 €/Jahr"   #0,28€/tag
auspraegung42 <- "2,00 €/h"   #2€/h
measures$"CO2" <- ifelse(measures[[massnahme3]]==auspraegung32 & measures[[massnahme4]]==auspraegung42,measures$"CO2"*7/20,measures$"CO2")
# Im Prinzip car share von 20% auf 10%.  Aber wenn das nur 1/2 der
# Parkplätze betrifft, dann gehen der Verkehr dafür von 10% auf 5%,
# und der andere bleibt gleich.  Also von 20% auf 15%
measures$"traffic" <- ifelse(measures[[massnahme3]]==auspraegung32 & measures[[massnahme4]]==auspraegung42,measures$"traffic"*7/20,measures$"traffic")
# wie CO2
measures$"parking" <- ifelse(measures[[massnahme3]]==auspraegung32 & measures[[massnahme4]]==auspraegung42,measures$"parking"*13.5/20,measures$"parking")
# Gehe wie immer davon aus, dass 1/2 davon ihr Auto verkaufen.
# ---
auspraegung32 <- "100 €/Jahr" #0,28€/tag
auspraegung43 <- "4,00 €/h"   #4€/h
measures$"CO2" <- ifelse(measures[[massnahme3]]==auspraegung32 & measures[[massnahme4]]==auspraegung43,measures$"CO2"*4/20,measures$"CO2")
# Im Prinzip car share von 20% auf 4%.  Aber wenn das nur 1/2 der
# Parkplätze betrifft, dann gehen der Verkehr dafür von 10% auf 2%,
# und der andere bleibt gleich.  Also von 20% auf 12%
measures$"traffic" <- ifelse(measures[[massnahme3]]==auspraegung32 & measures[[massnahme4]]==auspraegung43,measures$"traffic"*4/20,measures$"traffic")
# wie CO2
measures$"parking" <- ifelse(measures[[massnahme3]]==auspraegung32 & measures[[massnahme4]]==auspraegung43,measures$"parking"*12/20,measures$"parking")
# Gehe wie immer davon aus, dass 1/2 davon ihr Auto verkaufen.  Also von 10% auf 6%

# ---
auspraegung33 <- "1.000 €/Jahr" #2,8€/tag
auspraegung41 <- "0,00 €/h"  #0€/h
measures$"CO2" <- ifelse(measures[[massnahme3]]==auspraegung33 & measures[[massnahme4]]==auspraegung41,measures$"CO2"*17/20,measures$"CO2")
# Im Prinzip car share von 20% auf 16%.  Aber wenn das nur 1/2 der
# Parkplätze betrifft, dann gehen der Verkehr dafür von 10% auf 8%,
# und der andere bleibt gleich.  Also von 20% auf 18%
measures$"traffic" <- ifelse(measures[[massnahme3]]==auspraegung33 & measures[[massnahme4]]==auspraegung41,measures$"traffic"*17/20,measures$"traffic")
# wie CO2
measures$"parking" <- ifelse(measures[[massnahme3]]==auspraegung33 & measures[[massnahme4]]==auspraegung41,measures$"parking"*17/20,measures$"parking")
# Gehe wie immer davon aus, dass 1/2 davon ihr Auto verkaufen.

# ---
auspraegung33 <- "1.000 €/Jahr" #2,8€/tag
auspraegung42 <- "2,00 €/h" #1€/h
measures$"CO2" <- ifelse(measures[[massnahme3]]==auspraegung33 & measures[[massnahme4]]==auspraegung42,measures$"CO2"*6/20,measures$"CO2")
# Im Prinzip car share von 20% auf 9%.  Aber wenn das nur 1/2 der
# Parkplätze betrifft, dann gehen der Verkehr dafür von 10% auf 4%,
# und der andere bleibt gleich.  Also von 20% auf 14%
measures$"traffic" <- ifelse(measures[[massnahme3]]==auspraegung33 & measures[[massnahme4]]==auspraegung42,measures$"traffic"*6/20,measures$"traffic")
# wie CO2
measures$"parking" <- ifelse(measures[[massnahme3]]==auspraegung33 & measures[[massnahme4]]==auspraegung42,measures$"parking"*6/20,measures$"parking")
# Gehe wie immer davon aus, dass 1/2 davon ihr Auto verkaufen.

# ---
auspraegung33 <- "1.000 €/Jahr" #2,8€/tag
auspraegung43 <- "4,00 €/h" #4€/h
measures$"CO2" <- ifelse(measures[[massnahme3]]==auspraegung33 & measures[[massnahme4]]==auspraegung43,measures$"CO2"*3/20,measures$"CO2")
# Im Prinzip car share von 20% auf 3%.  Aber wenn das nur 1/2 der
# Parkplätze betrifft, dann gehen der Verkehr dafür von 10% auf 1,5%,
# und der andere bleibt gleich.  Also von 20% auf 11.5%
measures$"traffic" <- ifelse(measures[[massnahme3]]==auspraegung33 & measures[[massnahme4]]==auspraegung43,measures$"traffic"*3/20,measures$"traffic")
# wie CO2
measures$"parking" <- ifelse(measures[[massnahme3]]==auspraegung33 & measures[[massnahme4]]==auspraegung43,measures$"parking"*3/20,measures$"parking")
# Gehe wie immer davon aus, dass 1/2 davon ihr Auto verkaufen.




############################################
###########################################

massnahme5 <- "Verbrenner"
massnahme6 <- "E_Fahrzeuge"

# --------------------------------------------
# --------------------------------------------
#base
auspraegung51 <- "base"
auspraegung61 <- "base"
measures$CO2 <- ifelse(measures[[massnahme5]]==auspraegung51 & measures[[massnahme6]]==auspraegung61,measures$CO2*1,measures$CO2)
measures$traffic <- ifelse(measures[[massnahme5]]==auspraegung51 & measures[[massnahme6]]==auspraegung61,measures$traffic*1,measures$traffic)
measures$parking <- ifelse(measures[[massnahme5]]==auspraegung51 & measures[[massnahme6]]==auspraegung61,measures$parking*1,measures$parking)

#wie base
#auspraegung51 <- "base"
#auspraegung62 <- "Maut"
#measures$CO2 <- ifelse(measures[[massnahme5]]==auspraegung51 & measures[[massnahme6]]==auspraegung62,"NaN",measures$CO2)
#measures$traffic <- ifelse(measures[[massnahme5]]==auspraegung51 & measures[[massnahme6]]==auspraegung62,"NaN",measures$traffic)
#measures$parking <- ifelse(measures[[massnahme5]]==auspraegung51 & measures[[massnahme6]]==auspraegung62,"NaN",measures$parking)

#wie base
#auspraegung51 <- "base"
#auspraegung63 <- "Verbot"
#measures$CO2 <- ifelse(measures[[massnahme5]]==auspraegung51 & measures[[massnahme6]]==auspraegung63,"NaN",measures$CO2)
#measures$traffic <- ifelse(measures[[massnahme5]]==auspraegung51 & measures[[massnahme6]]==auspraegung63,"NaN",measures$traffic)
#measures$parking <- ifelse(measures[[massnahme5]]==auspraegung51 & measures[[massnahme6]]==auspraegung63,"NaN",measures$parking)

#mautFossil
auspraegung52 <- "Maut"
auspraegung61 <- "base"
measures$CO2 <- ifelse(measures[[massnahme5]]==auspraegung52 & measures[[massnahme6]]==auspraegung61,measures$CO2*0.6,measures$CO2)
measures$traffic <- ifelse(measures[[massnahme5]]==auspraegung52 & measures[[massnahme6]]==auspraegung61,measures$traffic*0.8,measures$traffic)
measures$parking <- ifelse(measures[[massnahme5]]==auspraegung52 & measures[[massnahme6]]==auspraegung61,measures$parking*0.9,measures$parking)

# wie mautFossil
auspraegung52 <- "Maut"
auspraegung63 <- "Verbot"
measures$CO2 <- ifelse(measures[[massnahme5]]==auspraegung52 & measures[[massnahme6]]==auspraegung63,measures$CO2*0.6,measures$CO2)
measures$traffic <- ifelse(measures[[massnahme5]]==auspraegung52 & measures[[massnahme6]]==auspraegung63,measures$traffic*0.8,measures$traffic)
measures$parking <- ifelse(measures[[massnahme5]]==auspraegung52 & measures[[massnahme6]]==auspraegung63,measures$parking*0.9,measures$parking)

#ZeroEmissionsZone
auspraegung53 <- "Verbot"
auspraegung61 <- "base"
measures$CO2 <- ifelse(measures[[massnahme5]]==auspraegung53 & measures[[massnahme6]]==auspraegung61,measures$CO2*0.01,measures$CO2)
measures$traffic <- ifelse(measures[[massnahme5]]==auspraegung53 & measures[[massnahme6]]==auspraegung61,measures$traffic*0.9,measures$traffic)
measures$parking <- ifelse(measures[[massnahme5]]==auspraegung53 & measures[[massnahme6]]==auspraegung61,measures$parking*0.9,measures$parking)


#Maut für Alle
auspraegung52 <- "Maut"
auspraegung62 <- "Maut"
measures$"CO2" <- ifelse(measures[[massnahme5]]==auspraegung52 & measures[[massnahme6]]==auspraegung62,measures$CO2*0.6,measures$CO2)
measures$"traffic" <- ifelse(measures[[massnahme5]]==auspraegung52 & measures[[massnahme6]]==auspraegung62,measures$traffic*0.6,measures$traffic)
# El. Auto nach Variabilisierung Batterie genauso teuer wie fossiles Auto.  10% können sich kein neues Auto leisten.
measures$"parking" <- ifelse(measures[[massnahme5]]==auspraegung52 & measures[[massnahme6]]==auspraegung62,measures$parking*0.8,measures$parking)
# Alte Gurke behalten lohnt nicht weil nicht mehr nutzbar.


#ZeroEmissionsZone + Maut
auspraegung53 <- "Verbot"
auspraegung62 <- "Maut"
measures$CO2 <- ifelse(measures[[massnahme5]]==auspraegung53 & measures[[massnahme6]]==auspraegung62,measures$CO2*0.0, measures$CO2)
measures$traffic <- ifelse(measures[[massnahme5]]==auspraegung53 & measures[[massnahme6]]==auspraegung62,measures$traffic*0.9*0.6, measures$traffic)
measures$parking <- ifelse(measures[[massnahme5]]==auspraegung53 & measures[[massnahme6]]==auspraegung62,measures$parking*0.9*0.7, measures$parking)


#autofrei
auspraegung53 <- "Verbot"
auspraegung63 <- "Verbot"
measures$CO2 <- ifelse(measures[[massnahme5]]==auspraegung53 & measures[[massnahme6]]==auspraegung63,measures$CO2*0.0,measures$CO2)
measures$traffic <- ifelse(measures[[massnahme5]]==auspraegung53 & measures[[massnahme6]]==auspraegung63,measures$traffic*0.0,measures$traffic)
measures$parking <- ifelse(measures[[massnahme5]]==auspraegung53 & measures[[massnahme6]]==auspraegung63,measures$parking*0.0,measures$parking)



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
## parking:  0,20€/km -> ~ -50% car modal split, 0,40€/km -> -75% car modal split (VSP WP 20-03 does not explicitly confirm but points in the same direction (only cares about nr of drt rides and shift from cars))




############################################
#############################################
massnahme7 <- "DRT"

# Wir hatten, beim Nachdenken, folgendes spezifiziert:
# (1) einen muva-ähnlichen DRT.  Für die sogenannte "Direktfahrt" benötigt man ein VBB-Ticket plus 1,50Eu/km.
# (2) ein miles-ähnliches car-sharing.  Dort derzeit 1Eu + 1Eu/km.  Wir vermuten sinkende Kosten und daher Preise, und wollen das aus planerischer
# Sicht nur auf den km-Preis anwenden.  Also 1Eu + 50ct/km

# Beim Parken gehen wir davon aus, dass das durch eine Betriebsgebühr in Höhe der derzeitigen für car sharing (1XX Eu/Monat) abgehakt ist.

# yyyyyy Bzgl. Maut müssen wir uns noch etwas ausdenken!!!


auspraegung71 <- DRTall

# Wir haben dann "vermutet", dass bei Auto-Verbot 75% der Autofahrer auf einen solchen Service umsteigen würden.  Also müssen wir rauskriegen, wieviel
# "verscheuchte" Autofahrer wir haben, nachdem die obigen Massnahmen eingeführt wurden.  Das ist 1 - measures$traffic.  Davon kommen dann 0.75 wieder
# dazu.
measures$traffic <- ifelse(measures[[massnahme7]]==auspraegung71, measures$traffic + (1 - measures$traffic) * 0.75,measures$traffic)

# CO2 kommt keiner hinzu weil elektrisch:
#measures$"CO2" <- ifelse(measures[[massnahme]]==auspraegung,measures$"CO2" - 0.02,measures$"CO2")

# Kosten kommen keine hinzu weil in etwa kostenneutral:
#measures$"Kosten" <- ifelse(measures[[massnahme]]==auspraegung,measures$"Kosten" - 0.05,measures$"Kosten")

# yyyy parking muss gelöst werden, weil bei "freiwilligem" Umstieg das Parken wegfällt.  (Aber macht das viel aus?)
#measures$"parking" <- ifelse(measures[[massnahme]]==auspraegung,measures$"parking" - 0.05,measures$"parking")


auspraegung72 <- DRTouter

# irgendeine Idee? X% des Verkehrs sind in den Innenbezirken (ist in PAVE drin); darüber runterrechnen???
measures$traffic <- ifelse(measures[[massnahme7]]==auspraegung72, measures$traffic + (1 - measures$traffic) * 0.65,measures$traffic)

# measures$"CO2" <- ifelse(measures[[massnahme]]==auspraegung,measures$"CO2" - 0.02,measures$"CO2")
# measures$"Kosten" <- ifelse(measures[[massnahme]]==auspraegung,measures$"Kosten" - 0.05,measures$"Kosten")
# measures$"parking" <- ifelse(measures[[massnahme]]==auspraegung,measures$"parking" - 0.05,measures$"parking")


#########################################################################################################
#########################################################################################################
#########################################################################################################
#########################################################################################################
#########################################################################################################
#########################################################################################################
######################################################################################################### MASSNAHMEN --> Mengengerüste (traffic, parking, co2) ####


massnahme1 <- "Fahrrad"

# ---

auspraegung11 <- "stark"

measures$"Kosten" <- ifelse(measures[[massnahme1]]==auspraegung11,measures$"Kosten" + 70,measures$"Kosten")
# Kosten ca. 1000Eu/qm.  1000km Radwegnetz.  4 Meter Breite.  4 * 1000 * 1000 * 1000 = 4e9.  Abgeschrieben 30J = 133 Mio/J.'
# Kosten 70 Mio /J auf 10 Jahre: 100km RSV + 850km Vorrangnetz + 1500km Ausbau
# Ca. 1 Mio pro km.  Ca. 2500km.  Also 2500 Mio.  Div durch 30 Jahre.  Ca. 70 Mio/J.

############################################
###########################################
massnahme2 <- "kiezblocks"

# ---

auspraegung21 <- kiezbloeckeInside

measures$Kosten <- ifelse(measures[[massnahme2]]==auspraegung21, measures$Kosten + 5,measures$"Kosten")
# 300kEu - 400kEu pro Kiezblock Umbaukosten.  Sagen wir 500kEu.  100 Blöcke.  (Ca. 20k Einwohner pro Kiez; 4000k/20k=200.)
# 100 x 500kEu = 50'000 kEu.  Abschreibung (nur) über 10 Jahre, weil dauernd kaputtgefahren.



# ---
auspraegung22 <- kiezbloeckeAll

measures$Kosten <- ifelse(measures[[massnahme2]]==auspraegung22, measures$Kosten + 10,measures$"Kosten")
# https://docs.google.com/spreadsheets/d/1pHne8cdCsSHKrH0WI6YFU2Ocv7RBMFR58T50n1KswFY/edit#gid=691888471
# 300kEu - 400kEu pro Kiezblock Umbaukosten.  Sagen wir 500kEu.  200 Blöcke.  (Ca. 20k Einwohner pro Kiez; 4000k/20k=200.)
# 200 x 500kEu = 100'000 kEu.  Abschreibung (nur) über 10 Jahre, weil dauernd kaputtgefahren.

############################################
############################################
massnahme3 <- "Anwohnerparken"

# ---

auspraegung32 <- "100 €/Jahr"

measures$Kosten <- ifelse( measures[[massnahme3]]==auspraegung32,  measures$Kosten - measures$parking*(100-10),     measures$Kosten)

# 1 mio trips.  50% do not pay for parking --> remain.  Other 50% reduced to 10%.  That is, 10% of moving traffic pays for parking.

# OLD: 1 mio car trips in base case, corresponding to 20% mode share.  Half
# of that, i.e. 10%pts, will not pay.  8%pts goes away.  2%pts remains.  I.e. 10% of original, 100k.  So these pay approx for 2.5hrs per day.  10Eu x 100k = 1m/day.

# ---

auspraegung33 <- "1.000 €/Jahr"

measures$Kosten <- ifelse(measures[[massnahme3]]==auspraegung33,       measures$Kosten - measures$parking*(1000-10) ,          measures$Kosten)



# OLD The remaining 10pct pay 10Eu per day as above, plus 2.8 Eu per day for "Anwohner".


############################################
############################################
massnahme4 <- "Besucherparken"

# ---

auspraegung42 <- "2,00 €/h"

measures$Kosten <- ifelse( measures[[massnahme4]]==auspraegung42,  measures$Kosten - measures$traffic*0.1*2.5*2*365,     measures$Kosten)

# 1 mio trips.  50% do not pay for parking --> remain.  Other 50% reduced to 10%.  That is, 10% of moving traffic pays for parking.

# OLD: 1 mio car trips in base case, corresponding to 20% mode share.  Half
# of that, i.e. 10%pts, will not pay.  8%pts goes away.  2%pts remains.  I.e. 10% of original, 100k.  So these pay approx for 2.5hrs per day.  10Eu x 100k = 1m/day.

# ---

auspraegung43 <- "4,00 €/h"

measures$Kosten <- ifelse(measures[[massnahme4]]==auspraegung43,       measures$Kosten - measures$traffic*0.1*2.5*4*365 ,          measures$Kosten)



# OLD The remaining 10pct pay 10Eu per day as above, plus 2.8 Eu per day for "Anwohner".



############################################
###########################################
massnahme5 <- "Verbrenner"

# --------------------------------------------
# --------------------------------------------

auspraegung52 <- "Maut"

measures$"Kosten" <- ifelse(measures[[massnahme5]]==auspraegung52,measures$"Kosten" - measures$CO2/0.6 *4*365,measures$"Kosten")

# OLD: Annahme: 1/2 * MautFürAlle

# --------------------------------------------
# --------------------------------------------


auspraegung53 <- "Verbot"

measures$"Kosten" <- ifelse(measures[[massnahme5]]==auspraegung53,measures$"Kosten" + 0.1 ,measures$"Kosten")
# Schilder, Durchsetzung, etc.


############################################
###########################################
massnahme6 <- "E_Fahrzeuge"

# --------------------------------------------
# --------------------------------------------

auspraegung62 <- "Maut"

measures$"Kosten" <- ifelse(measures[[massnahme6]]==auspraegung62,measures$"Kosten" - measures$"traffic"/0.4*4*365,measures$"Kosten")

# OLD: Annahme: 1/2 * MautFürAlle

# --------------------------------------------
# --------------------------------------------

auspraegung63 <- "Verbot"
# 20ct/km

measures$"Kosten" <- ifelse(measures[[massnahme6]]==auspraegung63,measures$"Kosten" + 0.1,measures$"Kosten")

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
## parking:  0,20€/km -> ~ -50% car modal split, 0,40€/km -> -75% car modal split (VSP WP 20-03 does not explicitly confirm but points in the same direction (only cares about nr of drt rides and shift from cars))

############################################
############################################
massnahme7 <- "DRT"

# Wir hatten, beim Nachdenken, folgendes spezifiziert:
# (1) einen muva-ähnlichen DRT.  Für die sogenannte "Direktfahrt" benötigt man ein VBB-Ticket plus 1,50Eu/km.
# (2) ein miles-ähnliches car-sharing.  Dort derzeit 1Eu + 1Eu/km.  Wir vermuten sinkende Kosten und daher Preise, und wollen das aus planerischer
# Sicht nur auf den km-Preis anwenden.  Also 1Eu + 50ct/km

# Beim Parken gehen wir davon aus, dass das durch eine Betriebsgebühr in Höhe der derzeitigen für car sharing (1XX Eu/Monat) abgehakt ist.

# yyyyyy Bzgl. Maut müssen wir uns noch etwas ausdenken!!!

# --

auspraegung73 <- DRTall

# Kosten kommen keine hinzu weil in etwa kostenneutral:
measures$"Kosten" <- ifelse(measures[[massnahme7]]==auspraegung73,measures$"Kosten" * 1,measures$"Kosten")

# --

auspraegung72 <- DRTouter

measures$"Kosten" <- ifelse(measures[[massnahme7]]==auspraegung72,measures$"Kosten" * 1,measures$"Kosten")


############################################
############################################
massnahme8 <- "OePNV"

# Alles oberhalb von hier sind Pkw-Emissionen.  Das ist so etwas wie 4
# mio t / yr.  Davon sind jetzt noch irgendwelche pct übrig.  Das multiplizieren wir jetzt mit 0.99, und tun dann noch 0.01 drauf oder auch nicht.

# ---

auspraegung81 <- "base"

measures$"CO2" <- ifelse(measures[[massnahme8]]==auspraegung81,measures$"CO2"*0.99+0.01,measures$"CO2")

# ---
auspraegung82 <- "dekarbonisiert"

measures$CO2 <- ifelse(measures[[massnahme8]]==auspraegung82,measures$CO2*0.99,measures$CO2)

# BVG hat ca. 1500 Busse.  Halten ca. 15 Jahre, also 100 neu pro Jahr.  E-Busse kosten ca. 680k, angeblich 3x so teuer wie fossile Busse.  Wir rechnen
# nur die Mehrkosten wg. El, also 2/3 * 680 = 450kEu.  Mal 100 = 45Mio/Jahr.  An anderer Stelle berichtet BVG 65Mio für 90 Ebusse plus Infra.  Davon
# müsste man aber die ohnehin entstehenden Kosten für fossile Busse wieder abziehen.
# https://docs.google.com/spreadsheets/d/1pHne8cdCsSHKrH0WI6YFU2Ocv7RBMFR58T50n1KswFY/edit#gid=691888471
measures$"Kosten" <- ifelse(measures[[massnahme8]]==auspraegung82,measures$"Kosten" + 50,measures$"Kosten")


# ---

auspraegung83 <- "stark"
#because of less car traffic
measures$"CO2" <- ifelse(measures[[massnahme8]]==auspraegung83,measures$"CO2"*0.90,measures$"CO2")

# "Das Investitionsvolumen für Bau und Planung aller i2030-Korridore liegt Stand 2023 bei ca. 10,6 Mrd. €."  https://www.i2030.de/fragen-und-hintergruende-zur-nutzen-kosten-untersuchungen-bei-i2030/
# 10 Mrd / 20J = 500 Mio/J.  yyyyyy Reicht das aus, um den Auto-Anteil um 10% zu drücken?
# Plus die Kosten der Dekarbonisierung (siehe oben).
measures$"Kosten" <- ifelse(measures[[massnahme8]]==auspraegung83,measures$"Kosten" + 500+50,measures$"Kosten")

# Reicht die Investition aus, um den Auto-Anteil um 10% zu drücken? (Annahme: Hälfte gibt Auto ab, Hälfte besitzt weiterhin Auto)
measures$"traffic" <- ifelse(measures[[massnahme8]]==auspraegung83,measures$"traffic" * 0.90,measures$"traffic")
measures$"parking" <- ifelse(measures[[massnahme8]]==auspraegung83,measures$"parking" * 0.95,measures$"parking")



# no consequences on moving/non-moving traffic:
#measures$"traffic" <- ifelse(measures[[massnahme]]==auspraegung,measures$"traffic",measures$"traffic")
#measures$"parking" <- ifelse(measures[[massnahme]]==auspraegung,measures$"parking",measures$"parking")



############################################
############################################
measures$"Kosten" <- - measures$"Kosten"*1000*1000
measures$"KostenProKopf" <- measures$"Kosten"/3800000
measures$"KostenProErwachsener" <- measures$"Kosten"/3060000
# (wir dividieren nur durch 3.8 statt 3.8 Mio, weil wir die "Mio" aus der Einheit rausnehmen)


# adding "1" to costs since this is decucted by the dashboard.  And then we divide by 100 to compensate for the % sign. (no, other way round)
#measures$"Kosten" <- - measures$"Kosten"*1000*1000
#measures$"Kosten" <- (measures$"Kosten"*1000*1000/100)+1
#measures$"KostenProKopf" <- (measures$"KostenProKopf"/100)+1
#measures$"KostenProErwachsener" <- (measures$"KostenProErwachsener"/100)+1

############################################
############################################
# safety net:
measures$"CO2" <- ifelse( measures$"CO2" < 0.95 & measures$"CO2" > 0.05, round( measures$"CO2" * 20) / 20, measures$"CO2" )
measures$"traffic" <- round( measures$"traffic" * 20 ) / 20
measures$"parking" <- round( measures$"parking" * 20 ) / 20

measures$"Kosten" <- round( measures$"Kosten" /10 ) * 10

# safety net:
measures$"CO2" <- ifelse( measures$"CO2" < 0.0, 0.0, measures$"CO2")

############################################
############################################
### number format "x.yz"
#colnames(measures)[]

### writing CSV file ## PATH FOR OUTPUT
write.csv(measures, "CCC_dashboard_privaterPersonenverkehr_MK.csv", row.names=FALSE)

print("done")

