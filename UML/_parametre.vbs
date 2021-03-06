'Datakatalogversjon
const FC_version = "2.07"
const FC_db = "C:\DATA\Standardisering\NVDB\NVDB Datakatalogen\NVDB_Datakatalogen_V207.mdb"

'Parametre for konvertering til SOSI
const txtSOSIpakke = "NVDB Datakatalogen"
const txtShortName = "NVDB"
const strPakker = "Branndetektor" '"Alle" 

const blnFellesegenskaper = True 						'Arv fra SOSI Fellesegenskaper. Brukes i produktspesifikasjoner, ikke i konseptuel modell
const blnOLFV = True 									'Ta med kun egenskaper som er med i Objektliste ferdigvegsdata
const blnSensitivitet = True 							'Utelat sensitive egenskaper
const blnLRAttr = True									'Angir om det skal legges til LR-attributter
const blnRemoveConstraints = True						'Angir om constraints skal fjernes

'Regler for konvertering av viktighet til multiplisitet
const blnPkrvd = True 									'"P?krevd i database" medf?rer p?krevd i modellen
const blnPkrvdNyreg = False 							'"P?krevd ved nyregistrering" medf?rer p?krevd i modellen
const blnBetinget = False 								'"Betinget" medf?rer p?krevd i modellen

const blnAsDictionary = False							'Angir om kodelister skal v?re i GML-skjemafilene eller eksternt
const strTargetNamespace = "https://raw.githubusercontent.com/jetgeo/NVDBGML/master/XSD/NVDB"
const blnIndividualAS = True							'Angir om det skal genereres separate xsd-filer for hver pakke

const strSOSIVersjon = "4.5"

'Arbeidsomr?de
const strMainPath = "C:\DATA\Standardisering\NVDB\NVDB Datakatalogen\trunk\public\tmp"

'Pakke- og modellnavn til bruk i konverteringer
const strModelName = "NVDB Datakatalogen"
const strObjektPakke = "Vegobjekttyper"
const strDatatypePakke = "Datatyper"
const strNVDBSOSIPakke = "SOSI-Modeller"
const strSOSIFelles = "SOSI Fellesegenskaper"

const strSOSIModell = "SOSI Modell"
const strSOSIGK = "SOSI Generelle konsepter"
const strSOSIGO = "SOSI Generell objektkatalog"

' GUID for SOSI-datatyper
const guidCharacterString = "{453EB6B1-D543-4f3d-BC53-E79283F6736C}"
const guidInteger = "{992C4B6C-785C-48a4-81A2-5F957E9C8A6B}"
const guidReal = "{281080FD-4373-4bf1-8F9E-606805BF9A0D}"
const guidDate = "{6B9D362B-ECF1-4605-800F-67219652B71E}"
const guidBoolean = "{B037C92D-03AE-4421-A554-7FDA5A49C381}"
const guidPunkt = "{BE6CCEB8-342A-4a44-BD46-8E5CBFDA9A91}"
const guidKurve = "{0708BC74-CF46-4cfe-93BE-878EC504768D}"
const guidFlate = "{46B26A69-F04C-4d11-B363-F3490340F5B7}"
const guidLRStrekning = "{3F3753C2-8665-4de7-AF70-4E8E833CE75D}"
const guidLRPunkt = "{4322CE4D-5CD6-4f58-949B-BF82F712762F}"