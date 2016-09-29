
Workspacet [NVDBAPI2GML_V2.fmw](https://github.com/jetgeo/NVDBGML/blob/master/FME/NVDBAPI2GML_V2.fmw) gir en fleksibel lesing fra NVDB-APIet, med validerte GML-filer som resultat. Dersom andre utformater er ønskelig (QUADRI, ESRI Filgeodatabase osv) kan det legges til i workspacet.  

**NB! Workspacet krever FME Versjon 2016.1**

Parametre i workspacet:
* ftID – Objekttype-id fra NVDB. F.eks 5 for Rekkverk. Komplett liste: Se http://labs.vegdata.no/nvdb-datakatalog/
* omr – Områdetype (fra områdefilteret til APIet – kommune, fylke osv).
* omrNavn – Områdenummer (kommunenummer, fylkesnummer, regionnummer osv)
* gmlFolder – Hovedområde for lagring av GML-filer. Filene lagres i en struktur under der igjen, basert på områdefilteret
* dwnlAssObj – Ja eller nei til å inkludere assosierte objekter i nedlastingen. 

Som en del av dette er det også etablert en automatisert rutine for etablering av GML-applikasjonsskjema (xsd-filer) for hele NVDB, basert på UML-modellen vi legger inn i SOSI-modellregister ved nye versjoner. XSD-filene er fordelt på mapper pr objekttype, og hver mappe inkluderer filer for assosierte objekttyper. Dette gir oss muligheten til å få med assosierte objekter, uten at vi blir plaga av hele avhengigheten med assosierte objekttyper sine assosierte objekttyper sine assosiasjoner osv. Alle applikasjonsskjemaene ligger på https://github.com/jetgeo/NVDBGML/tree/master/XSD/NVDB, men etter hvert få et mer offisielt tilholdssted. 

Kontakt gjerne [Knut Jetlund](mailto:knut.jetlund@vegvesen.no) for innspill og spørsmål
