## Workspace for håndtering av GML fra NVDB-API

**NB! Workspacene krever FME Versjon 2016.1**

### Lesing av vegobjekter
Workspacet **[NVDBAPI2GML_V2.fmw](https://github.com/jetgeo/NVDBGML/blob/master/FME/NVDBAPI2GML_V2.fmw)** gir en fleksibel lesing fra NVDB-APIet, med validerte GML-filer som resultat. Dersom andre utformater er ønskelig (QUADRI, ESRI Filgeodatabase osv) kan det legges til i workspacet, eller kjøres som egen konvertering fra GML. Vi jobber med å forbedre workspacet ytterliggere for å kunne håndtere ulike kjente formater. 

Parametre i workspacet:
* ftID – Objekttype-id fra NVDB. F.eks 5 for Rekkverk. Komplett liste: Se http://labs.vegdata.no/nvdb-datakatalog/
* omr – Områdetype (fra områdefilteret til APIet – kommune, fylke osv).
* omrNavn – Områdenummer (kommunenummer, fylkesnummer, regionnummer osv)
* gmlFolder – Hovedområde for lagring av GML-filer. Filene lagres i en struktur under der igjen, basert på områdefilteret
* dwnlAssObj – Ja eller nei til å inkludere assosierte objekter i nedlastingen. Selve assosiasjonen (rollen) blir med uansett.

Workspacet **[NVDBAPI2GML_V2_paraply.fmw](https://github.com/jetgeo/NVDBGML/blob/master/FME/NVDBAPI2GML_V2_paraply.fmw)** gir mulighet for å kjøre eksport av flere objekttyper og flere områder (for eksempel flere objekttyper i en serie med kommuner) 

### Lesing av vegnett
Workspacet [NVDBAPI2GML_V2_Vegnett.fmw](https://github.com/jetgeo/NVDBGML/blob/master/FME/NVDBAPI2GML_V2_Vegnett.fmw) leser vegnett for en valgt kommune og eksporterer til GML. 
Dette workspacet har feoløpig noen mangler på grunn av feil i APIet:
* Egenskapen _detaljnivå_ (Vegtrase, Kjørebane, Kjørefelt) mangler på en stor andel av lenkene, på grunn av at informasjonen mangler for de samme lenkene fra APIet
* Alle lenker får angitt verdi "enkelBilveg" for egenskapen _typeVeg_, på grunn av at nødvendig informasjon ikke er med i responsen fra APIet
* Noder blir ikke unike, på grunn av feil nummerering i responsen fra APIet

### GML-applikasjonsskjema
Det er etablert en automatisert rutine for etablering av GML-applikasjonsskjema (xsd-filer) for hele NVDB, basert på UML-modellen vi legger inn i SOSI-modellregister ved nye versjoner. XSD-filene er fordelt på mapper pr objekttype, og hver mappe inkluderer filer for assosierte objekttyper. Dette gir oss muligheten til å få med assosierte objekter, uten at vi blir plaga av hele avhengigheten med assosierte objekttyper sine assosierte objekttyper sine assosiasjoner osv. Alle applikasjonsskjemaene ligger på https://github.com/jetgeo/NVDBGML/tree/master/XSD/NVDB, men vil etter hvert få et mer offisielt tilholdssted. 

Kontakt gjerne [Knut Jetlund](mailto:knut.jetlund@vegvesen.no) for innspill og spørsmål
