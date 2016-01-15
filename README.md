# iOSProjectv1

#Info
Ik heb een app gemaakt die het dichtsbijzijnde openbaar toilet in Gent zoekt.
Hiervoor maakt de app  gebruik van je huidige locatie (a.d.h.v. GPS) en berekent de app de afstand tot elk openbaar toilet.
Die afstandsberekening wordt gedaan met behulp van de Google Distance Matrix API en houdt rekening of je met te voet / de auto bent aangezien dit een andere weg en dus andere afstand kan betekenen.
Na het berekenen van alle afstanden sorteert de app de toiletten van dicht naar ver.

#TODO om de app te runnen
Als je de app runt op je pc krijg je geen huidige locatie. Daarom heb ik een .gpx file gemaakt met een gesimuleerde huidige locatie. Als je de app dus op je pc runt met een simulator moet je ervoor zorgen dat je onder het menu 'Debug' -> 'Simulate location' kiest voor 'Kanunnikstraat 44, Gent, België'. Er staat nog meer info hierover in de klasse 'MasterViewController' in de methode 'calculateTravelModeDistances'
