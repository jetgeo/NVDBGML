option explicit

!INC Local Scripts.EAConstants-VBScript
!INC NVDB._felles
!INC NVDB._parametre

'konverterer fra Dakat-UML til SOSI-UML

Function setMultiplicityFromImportance(strImportance) 
	'Sett mulitiplisitet ut fra viktighet
	setMultiplicityFromImportance = 0
	Select Case strImportance
		Case "P�krevd i database"
			If blnPkrvd Then setMultiplicityFromImportance = 1
		Case "P�krevd ved nyregistrering"
			If blnPkrvdNyreg Then setMultiplicityFromImportance = 1
		Case "Betinget"
			If blnBetinget Then setMultiplicityFromImportance = 1
	End Select
End Function

Function setGMLasDictionary() 
	'Sett GML tag "asDictionary" ut fra innstillinger
	setGMLasDictionary = "false"
	If blnAsDictionary Then
		setGMLasDictionary = "true"
	End If
End Function

Sub setPackageTags_GML(pck, el, shortFromAlias, targetNamespace)
	'************ SOSI- og GML-tagger p� pakkene ********************

	Dim pkEl As EA.Element
	set pkEl = pck.Element

	'*************** GML
	If targetNamespace Then
		pck.StereotypeEx = "applicationSchema"
		pck.Update()

		set tagVal = Nothing
		set tagVal = pkEl.TaggedValues.GetByName("targetNamespace")
		if not tagVal is Nothing then
			tagVal.Value = strTargetNamespace
		else
			set tagVal = pkEl.TaggedValues.AddNew("targetNamespace", strTargetNamespace)
		End if
		tagVal.Update()
	End If
	
	set tagVal = Nothing
	set	tagVal = pkEl.TaggedValues.GetByName("version")
	if not tagVal is Nothing then
		tagVal.Value = strVersion
	Else
		set tagVal = pkEl.TaggedValues.AddNew("version",FC_Version)
	End if
	tagVal.Update()
	
	set tagVal = Nothing
	set	tagVal = pkEl.TaggedValues.GetByName("xmlns")
	if not tagVal is Nothing then
		tagVal.Value = "nvdb"
	else	
		set tagVal = pkEl.TaggedValues.AddNew("xmlns", "nvdb")
	End if
	tagVal.Update()

	Dim strTagVal 
	If shortFromAlias Then
		strTagVal = el.Alias
	Else
		strTagVal = txtShortName
	End If
	strTagVal = strTagVal & ".xsd"
	
	set tagVal = Nothing
	set	tagVal = pkEl.TaggedValues.GetByName("xsdDocument")
	if not tagVal is Nothing then
		tagVal.Value = strTagVal
	Else
		set tagVal = pkEl.TaggedValues.AddNew("xsdDocument", strTagVal)
	End if
	tagVal.Update()

	set tagVal = Nothing
	set	tagVal = pkEl.TaggedValues.GetByName("xsdEncodingRule")
	if not tagVal is Nothing then
		tagVal.Value = "sosi"
	else
		set tagVal = pkEl.TaggedValues.AddNew("xsdEncodingRule", "sosi")
	End if
	tagVal.Update()

	'****************** SOSI
	If shortFromAlias Then
		strTagVal = "NVDB" & el.Alias
	Else
		strTagVal = "NVDB" & txtShortName
	End If
	
	set tagVal = Nothing
	set tagVal = pkEl.TaggedValues.GetByName("SOSI_kortnavn")
	If not tagVal is nothing then
		tagVal.Value = strTagVal
	else
		set tagVal = pkEl.TaggedValues.AddNew("SOSI_kortnavn", strTagVal)
	End if
	tagVal.Update()

	If Not Mid(el.Name, 1, 4) = "NVDB" Then
		strTagVal = "NVDB " & pck.Name
	Else
		strTagVal = el.Name
	End If
	
	With (New RegExp)
		.Global = True
		.Pattern = "[_]+"
		strTagVal = .Replace(strTagVal, "_") 
	End With	

	set tagVal = Nothing
	set tagVal = pkEl.TaggedValues.GetByName("SOSI_langnavn")
	if not tagVal is Nothing then
		tagVal.Value = strTagVal
	else	
		set tagVal = pkEl.TaggedValues.AddNew("SOSI_langnavn", strTagVal)
	End if
	tagVal.Update()
	
	set tagVal = Nothing
	set tagVal = pkEl.TaggedValues.GetByName("SOSI_organisasjon")
	if not tagVal is nothing then
		tagVal.Value = "Statens vegvesen"
	else	
		set tagVal = pkEl.TaggedValues.AddNew("SOSI_organisasjon", "Statens vegvesen")
	End if
	tagVal.Update()
	set tagVal = Nothing
	set tagVal = pkEl.TaggedValues.GetByName("SOSI_produktgruppe")
	if not tagVal is Nothing then
		tagVal.Value = "NVDB"
	Else
		set tagVal = pkEl.TaggedValues.AddNew("SOSI_produktgruppe", "NVDB")
	End if
	tagVal.Update()
	set tagVal = Nothing
	set tagVal = pkEl.TaggedValues.GetByName("SOSI_produsent")
	If not tagVal is Nothing then
		tagVal.Value = "Statens vegvesen"
	Else
		set tagVal = pkEl.TaggedValues.AddNew("SOSI_produsent", "Statens vegvesen")
	End if
	tagVal.Update()
	set tagVal = Nothing
	set	tagVal = pkEl.TaggedValues.GetByName("SOSI_spesifikasjonstype")
	if not tagVal is Nothing then
		tagVal.Value = "Applikasjonsskjema"
	Else
		set tagVal = pkEl.TaggedValues.AddNew("SOSI_spesifikasjonstype", "Applikasjonsskjema")
	End if
	tagVal.Update()
	set tagVal = Nothing
	set tagVal = pkEl.TaggedValues.GetByName("SOSI_versjon")
	If not tagVal is Nothing then
		tagVal.Value = My.Settings.SOSIversjon
	Else
		set tagVal = pkEl.TaggedValues.AddNew("SOSI_versjon", strSOSIversjon)
	End if
	tagVal.Update()

	pkEl.TaggedValues.Refresh()
	pck.Element.Refresh()
End Sub

Sub removeConstraints(el)
	'Fjerner constraints
	Dim cnstr As EA.Constraint
	Repository.WriteOutput "Script", Now & " Fjerner constraints for objekttype " & el.Name,0
	For idxT = 0 To el.Constraints.Count - 1
		'set cnstr = el.Constraints.GetAt(idxT)
		'If cnstr.Type <> "OCL" Then
		el.Constraints.DeleteAt idxT, False
		'End If
	Next 
	el.Constraints.Refresh()
End Sub

sub convert2SOSI()
	dim strPar
	strPar = "Starter konvertering til SOSI med f�lgende parametre: " & vbCrLf & vbCrLf 
	strPar = strPar & "Hovedpakke: " & txtSOSIPakke & vbCrLf 
	strPar = strPar & "Kortnavn: " & txtShortName & vbCrLf & vbCrLf
	strPar = strPar & "Arv fra SOSI Fellesegenskaper: " & blnFellesegenskaper & vbCrLf 
	strPar = strPar & "Kun egenskaper fra Objektliste ferdigvegsdata: " & blnOLFV & vbCrLf 
	strPar = strPar & "Utelat sensitive egenskaper: " & blnSensitivitet & vbCrLf & vbCrLf
	
	strPar = strPar & "Legg til LR-attributter: " & blnLRAttr & vbCrLf 
	strPar = strPar & "Fjern constraints: " & blnRemoveConstraints & vbCrLf & vbCrLf

	strPar = strPar & "Kodelister som dictionary: " & blnAsDictionary & vbCrLf 
	strPar = strPar & "GML-Namespace: " & strTargetNamespace & vbCrLf & vbCrLf

	strPar = strPar & "Viktighet som gir p�krevd: " & vbCrLf 
	strPar = strPar & "P�krevd i database (" & blnPkrvd & "), P�krevd ved nyregistrering (" & blnPkrvdNyreg & "), Betinget (" & blnBetinget & ")" & vbCrLf 
	strPar = strPar & vbCrLf
	strPar = strPar & "Objekttyper: " & strPakker & vbCrLf 
	
	Dim response
	response = MsgBox(strPar, vbOKCancel+vbInformation)
	If response = vbCancel Then
		Exit Sub
	End If

	'Setter opp kobling til modeller og databasetabell
	connect2models
	
	Repository.WriteOutput "Script", Now & " Konverter til SOSI", 0 
	Repository.WriteOutput "Script", Now & " Pakke med resultatmodell: " & txtSOSIpakke & " (Kortnavn " & txtShortName & ")", 0 
	
	'Sjekker om hovedpakken eksisterer, og sletter dersom brukeren �nsker det
	For idxP = 0 To pkNVDBSOSImain.Packages.Count - 1
		set pkNVDBSOSI = pkNVDBSOSImain.Packages.GetAt(idxP)
		If pkNVDBSOSI.Name = txtSOSIpakke Then
			Repository.WriteOutput "Script", Now & " Pakken eksisterer: " & txtSOSIpakke, 0
			response = MsgBox("Pakken " & txtSOSIpakke & " eksisterer. Trykk OK for � slette den, eller avbryt for � g� tilbake og velge nytt navn", vbOKCancel+vbQuestion)
			If response = vbOk Then
				Repository.WriteOutput "Script", Now & " Sletter eksisterende pakke: " & txtSOSIpakke, 0
				pkNVDBSOSImain.Packages.DeleteAt idxP, False
			Else
				Exit Sub
			End If
		End If
	Next 
	pkNVDBSOSImain.Update()
	
	'Oppretter hovedpakken med angitt navn
	Repository.WriteOutput "Script", Now & " Oppretter pakke: " & txtSOSIpakke,0
	set pkNVDBSOSI = pkNVDBSOSImain.Packages.AddNew(txtSOSIpakke, "Package")
	pkNVDBSOSI.Update()
	'Tagged values p� morpakken
	Repository.WriteOutput "Script", Now & " Setter stereotype og tagged values p� hovedpakke",0
	setPackageTags_GML pkNVDBSOSI, pkNVDBSOSI.Element, False, True
	pkNVDBSOSI.Modified = Now
	pkNVDBSOSI.Update()

	'Oppretter diagrammet hovedskjema
	set  eHovedskjema = pkNVDBSOSI.Diagrams.AddNew("Hovedskjema", "Logical")
    eHovedskjema.Update()

	Dim xmiFile
	'Kopierer pakke med SOSI Fellesegenskaper
	if blnFellesegenskaper then
		Repository.WriteOutput "Script", Now & " Kopierer pakke med SOSI Fellesegenskaper", 0
        xmiFile = strMainPath & "\SOSIFelles.xml"
		Repository.WriteOutput "Script", Now & " Eksporterer til XMI: " & xmiFile,1
		ePIF.ExportPackageXMI pkSOSIfelles.PackageGUID, 3, 1, -1, 1, 1, xmiFile
		Repository.WriteOutput "Script", Now & " Importerer fra versjonskontrollert XMI: " & xmiFile,0
		ePIF.ImportPackageXMI pkNVDBSOSI.PackageGUID, xmiFile, 1, 1 
        pkNVDBSOSI.Packages.Refresh()	
		
		'Setter referanse til ny, lokal pakke med SOSI fellesegenskaper
		Repository.WriteOutput "Script", Now & " Finner featuretype Fellesegenskaper i lokal pakke",1
		set pkSOSIfelles = Nothing
		set pkSOSIfelles = pkNVDBSOSI.Packages.GetByName(strSOSIFelles)
		If not pkSOSIfelles is Nothing then
			pkSOSIfelles.Element.Alias = "SOSIFelles"
			pkSOSIfelles.Update()
			If blnIndividualAS Then 
				setPackageTags_GML pkSOSIfelles, pkSOSIfelles.Element, True, False
			end if	
			set ftSOSIfelles = Nothing
			Set ftSOSIfelles = pkSOSIfelles.Elements.GetByName("Fellesegenskaper")
			If not ftSOSIfelles is Nothing then
				If blnRemoveConstraints Then
					'Fjerner constraints
					removeConstraints(ftSOSIfelles)
				End If

				'Legger til i diagrammet Hovedskjema
				set diagramObjekt = eHovedskjema.DiagramObjects.AddNew("", "")
				diagramObjekt.ElementID = ftSOSIfelles.ElementID
				hideAttributes diagramObjekt
				setSize diagramObjekt, 70, 200
				diagramObjekt.Update()
				eHovedskjema.Update()		
			end if
		end if
	end if

	'Liste med pakker som skal konverteres 
	Repository.WriteOutput "Script", Now & " ......", 0 
	
	'******************** Kopiering og konvertering ***********************
	'Kopierer og konverterer alle valgte vegobjekttyper
	Dim lstPakker, strPakkeStreng, i
	
	if strPakker = "Alle" then
		strPakkeStreng = ""
		for each pkOT_Sub in pkObjekttyper.Packages
		   strPakkeStreng = strPakkeStreng  & pkOT_Sub.Name & ";"
		next
	else
		strPakkeStreng = strPakker
	end if
	
	lstPakker = Split(strPakkeStreng, ";") 'Lag liste for hvert semikolon
	
	For i = LBound(lstPakker) To UBound(lstPakker)
		Repository.WriteOutput "Script", Now & " Konverterer vegobjekttype: " & lstPakker(i),0
		set pkOT_Sub = pkObjekttyper.Packages.GetByName(lstPakker(i))
		'Kopierer de valgte pakkene (eksporterer til XMI, og importerer til NVDBSOSI-pakken, fjerner da GUIDer)
		xmifile = strMainPath & "\" & pkOT_Sub.Alias & ".xml"
		Repository.WriteOutput "Script", Now & " Eksporterer til XMI: " & xmiFile,0
		ePIF.ExportPackageXMI pkOT_Sub.PackageGUID, 3, 1, -1, 1, 1, xmiFile
		Repository.WriteOutput "Script", Now & " Importerer fra versjonskontrollert XMI: " & xmiFile,0
		ePIF.ImportPackageXMI pkNVDBSOSI.PackageGUID, xmiFile, 1, 1
		pkNVDBSOSI.Packages.Refresh()
		set pkOT_Sub = pkNVDBSOSI.Packages.GetByName(lstPakker(i))
		
		'*************************************************************************************************
		Repository.WriteOutput "SOSI", Now & " ",0
		Repository.WriteOutput "SOSI", Now & " Konverterer vegobjekttype: " & lstPakker(i),0
		'Her er selve konverteringsprosessen
		pkOT_Sub.Modified = Now
        pkOT_Sub.Update()

        Dim geomPunkt, geomKurve 
		geomPunkt = False
		geomKurve = False

		'Tagged values p� pakken
		If blnIndividualAS Then 
			setPackageTags_GML pkOT_Sub, pkOT_Sub.Element, True, False
		end if	

        'Kj�rer gjennom alle klasser i delpakken. Endrer stereotyper, navn, tagged values...
        For idxe = 0 To pkOT_Sub.Elements.Count - 1
            '********************** Stereotype for selve objekttypen eller kodelisten ******************
			set element = pkOT_Sub.Elements.GetAt(idxe)
			'Endrer stereotyper for klasser
			Repository.WriteOutput "SOSI", Now & " Endrer stereotype, navn og tagged values for " & element.Name,0
			If element.Stereotype = "Vegobjekttype" Then
				element.StereotypeEx = ""
				element.Stereotype = "FeatureType"
			ElseIf element.Stereotype = "Tillatte verdier" Then
				element.StereotypeEx = ""
				element.Stereotype = "CodeList"
			End If
			
			'********************** Navn og tagged values for selve objekttypen eller kodelisten ******************
			'Defaultverdier
			Dim strAlias
			strAlias = "Ikke angitt"
			Dim strStedfesting 
			strStedfesting = "punkt"
			Dim retning 
			retning = False
			Dim kjorefelt 
			kjorefelt = 0

			For idxT = 0 To element.TaggedValues.Count - 1
				set tagVal = element.TaggedValues.GetAt(idxT)
				Select Case tagVal.Name
					Case "SOSI_navn"
						'SOSI-navn p� objekttypen. Brukes for � sette SOSI-modellnavn og SOSI-formatnavn
						Repository.WriteOutput "SOSI", Now & " Klassen " & element.Name & " (" & element.Alias & ") endres til " & element.Stereotype & " " & tagVal.Value,0
						'Endrer navn p� klassen til SOSI-modellnavn
						element.Name = tagVal.Value
						'Endrer tagged value til � inneholde SOSI-formatnavn (NVDB_ & Uppercase(element.Name))
						'Unntak: De som allerede har prefix "NVDB_" skal kun ha uppercase, ikke ny prefix
						If Not Mid(element.Name, 1, 5) = "NVDB_" Then
							tagVal.Value = "NVDB_" & Ucase(element.Name)
						Else
							tagVal.Value = Ucase(element.Name)
						End If
						tagVal.Update()
					Case "Stedfesting"
						'Stedfesting (strekning eller punkt). Henter informasjonen og sletter taggen
						strStedfesting = tagVal.Value
						Repository.WriteOutput "SOSI", Now & " Stedfesting: " & tagVal.Value,0
						element.TaggedValues.DeleteAt idxT, False
					Case "RetningsRelevant"
						'Retning relevant. Henter informasjonen og sletter taggen
						Repository.WriteOutput "SOSI", Now & " Skal ha retning: " & tagVal.Value,0
						If tagVal.Value = "true" Then retning = True
						element.TaggedValues.DeleteAt idxT, False
					Case "KjorefeltRelevant"
						'Retning relevant. Henter informasjonen og sletter taggen
						Repository.WriteOutput "SOSI", Now & " Skal/kan ha kjorefelt: " & tagVal.Value,0
						kjorefelt = tagVal.Value
						element.TaggedValues.DeleteAt idxT, False
					Case "ID_VOBJ_TYPE", "ID_EGENSKAPSTYPE"
						'ID - gi nytt navn til tagged value
						tagVal.Name = "NVDB_ID"
						tagVal.Update()
					Case "NAVN_VOBJ_TYPE", "NAVN_EGENSKAPSTYPE"
						'Navn - gi nytt navn til tagged value
						tagVal.Name = "NVDB_navn"
						tagVal.Update()
					Case "SOSI_datatype"
						'NVDB-datatype - konverteres til SOSI-datatype (kun kodelister)

					Case "TOTAL_FELTLENGDE"
						'Feltlengde - tas vare p� for SOSI-realisering (kun kodelister)
						tagVal.Name = "SOSI_lengde"
						tagVal.Update()
					Case Else
						element.TaggedValues.DeleteAt idxT, False
				End Select
			Next 
			'Legger til catalogue-entry
			set tagVal = element.TaggedValues.AddNew("catalogue-entry", "NVDB Datakatalogen")
			tagVal.Update()
			element.TaggedValues.Refresh()
			element.Modified = Now
			element.Update()
			
			'GML-tagger for kodelister
			If element.Stereotype = "codeList" Then
				set tagVal = Nothing
				set tagVal = element.TaggedValues.GetByName("asDictionary")
				If not tagVal is Nothing then
					tagVal.Value = setGMLasDictionary()
				else
					set tagVal = element.TaggedValues.AddNew("asDictionary", setGMLasDictionary)
				End if
				tagVal.Update()
				
				set tagVal = Nothing
				set tagVal = element.TaggedValues.GetByName("codeList")
				If not tagVal is Nothing then
					tagVal.Value = My.Settings.strTargetNamespace & element.Name
				Else
					set tagVal = element.TaggedValues.AddNew("codeList", strTargetNamespace & element.Name)
				End if
				tagVal.Update()
			End If

			'********************** Navn og tagged values p� egenskaper og tillatte verdier **********************
			For idxA = 0 To element.Attributes.Count - 1
				set eAttributt = element.Attributes.GetAt(idxA)
				
				Dim includeAttr 
				includeAttr = True

				'Dersom begrensning p� kun attributter til OT Ferdigveg: Sjekk om attributt skal v�re med
				If blnOLFV and (element.Stereotype = "FeatureType" Or element.Stereotype = "featureType") then
					includeAttr = False
					set aTag = Nothing
					set aTag = eAttributt.TaggedValues.GetByName("ObjektlisteFerdigveg")
					if not aTag is nothing then
						if aTag.Value = "true" Then
							includeAttr = True						
						End if	
					End if	
				End If
			
				'Dersom begrensning p� sensitive egenskaper: Sjekk om attributt skal v�re med
				If blnSensitivitet and (element.Stereotype = "FeatureType" Or element.Stereotype = "featureType") then
					set aTag = Nothing
					set aTag = eAttributt.TaggedValues.GetByName("Sensitiv")
					if not aTag is nothing then
						If aTag.Value = "true" Then
							includeAttr = False
						end if	
					End If
				End If
				
				'Sletter egenskaper som ikke skal v�re med, konverterer andre
				If Not includeAttr Then
					Repository.WriteOutput "SOSI", Now & " Egenskapen " & eAttributt.Name & " (" & eAttributt.Style & ") skal ikke v�re med, slettes", 0
					element.Attributes.DeleteAt idxA, False
				else
					'Kj�rer gjennom tagged values for egenskapene. Sletter uaktuelle, d�per om noen til SOSI-tagger, og henter navn fra SOSI_Navn
					For idxT = 0 To eAttributt.TaggedValues.Count - 1
						set aTag = eAttributt.TaggedValues.GetAt(idxT)
						Select case aTag.Name
							Case "SOSI_navn"
								'SOSI-navn p� egenskapen eller kodelisteverdien. Brukes for � sette SOSI-modellnavn og SOSI-formatnavn
								Select Case element.Stereotype
									Case "codeList", "CodeList"
										Repository.WriteOutput "SOSI", Now & " Kodelisteverdien " & eAttributt.Name & " (" & eAttributt.Style & ") endres til " & aTag.Value, 0
										'Endrer navn p� kodelisteverdi til SOSI-form og tar vare p� NVDB-navn i tagged value. Legger ogs� inn i definisjon.
										Dim strName
										strName	= eAttributt.Name
										If eAttributt.Notes = "" Then
											eAttributt.Notes = strName
										ElseIf eAttributt.Notes <> strName Then
											eAttributt.Notes = strName & ": " & eAttributt.Notes
										End If
										eAttributt.Name = aTag.Value
										aTag.Name = "NVDB_navn"
										aTag.Value = strName
										aTag.Update()
									Case "featureType", "FeatureType"
										Repository.WriteOutput "SOSI", Now & " Egenskapen " & eAttributt.Name & " (" & eAttributt.Style & ") endres til " & aTag.Value,0
										'Endrer navn p� egenskap
										eAttributt.Name = aTag.Value
										'Endre tagverdi til SOSI_navn (NVDB_ & Uppercase(aTag.Value))
										aTag.Value = "NVDB_" & Ucase(aTag.Value)
										aTag.Update()
								End Select
							Case "ID_EGENSKAPSTYPE", "ID_TILLATT_VERDI"
								'ID - gi nytt navn til tagged value
								aTag.Name = "NVDB_ID"
								aTag.Update()
							Case "NAVN_EGENSKAPSTYPE"
								'Navn - gi nytt navn til tagged value
								aTag.Name = "NVDB_navn"
								aTag.Update()
								'Case "ANTALL_DESIMALER"
								'Antall desimaler - tas vare p� for datatypekonvertering
								'   aTag.Name = "NVDB_ANTALL_DESIMALER"
								'  aTag.Update()
							Case "TOTAL_FELTLENGDE"
								'Feltlengde - tas vare p� for SOSI-realisering
								aTag.Name = "SOSI_lengde"
								aTag.Update()
							Case "Viktighet"
								'Viktighet - brukes for � sette multiplisitet
								eAttributt.LowerBound = 0
								eAttributt.LowerBound = setMultiplicityFromImportance(aTag.Value)
								aTag.Name = "NVDB_Viktighet"
								aTag.Update()
							Case Else
								eAttributt.TaggedValues.DeleteAt idxT, False
						End Select														
					Next 'idxT
					eAttributt.TaggedValues.Refresh()
					
					'************************* Datatyper **************************
					'Datatype for egenskapene				
					Dim idxDT	
					If element.Stereotype = "featureType" Or element.Stereotype = "FeatureType" Then
						'Datatype for egenskapene
						If Not IsNull(eAttributt.ClassifierID) And eAttributt.ClassifierID <> 0 Then
						Dim elementDT As EA.Element 
						set elementDT = Nothing
						set elementDT = Repository.GetElementByID(eAttributt.ClassifierID)
						if not elementDT is nothing then
							If elementDT.Alias = 30 Or elementDT.Alias = 31 Then
								'Flerverdiegenskap - kodelisten er datatype
								'S�ke gjennom alle kodelister i pakken, sjekke Alias = eAttributt.style
								For idxDT = 0 To pkOT_Sub.Elements.Count - 1
									set elementB = pkOT_Sub.Elements.GetAt(idxDT)
									If elementB.Alias = eAttributt.Style Then
										'Aktuell kodeliste. Henter navn og elementID
										eAttributt.Type = elementB.Name
										eAttributt.ClassifierID = elementB.ElementID
										idxDT = pkOT_Sub.Elements.Count - 1
										'Setter defaultCodespace-tag
										set aTag = nothing
										set aTag = eAttributt.TaggedValues.GetByName("defaultCodespace")
										if not aTag is nothing then
											aTag.Value = My.Settings.strTargetNamespace & elementB.Name & ".xml"
										else
											set aTag = eAttributt.TaggedValues.AddNew("defaultCodespace", strTargetNamespace & elementB.Name & ".xml")
										end if 
										aTag.Update()
									End If
								Next 'idxDT
								Repository.WriteOutput "SOSI", Now & " Egenskapen " & eAttributt.Name & " (" & eAttributt.Style & ") gis datatype " & elementB.Name, 0
								'Tagged value for SOSI-datatype
								Select Case elementDT.Alias
									Case 30
										set aTag = eAttributt.TaggedValues.AddNew("SOSI_datatype", "T")
									Case 31
										If eAttributt.Precision = 0 Then
											set aTag = eAttributt.TaggedValues.AddNew("SOSI_datatype", "H")
										Else
											set aTag = eAttributt.TaggedValues.AddNew("SOSI_datatype", "D")
										End If
								End Select
								aTag.Update()
							Else
								'Henter SOSI-typenavn fra tagged values for datatypen
								Dim strDTnavn 
								strDTnavn = eAttributt.Type
								set tagVal = Nothing
								set tagVal = elementDT.TaggedValues.GetByName("SOSI_type")
								if not tagVal is nothing then
									strDTnavn = tagVal.Value
									eAttributt.Type = strDTnavn
									'Finner ID for aktuell SOSI-datatype. Tilpasser navn p� geometriegenskaper, og registrerer om objekttypen har p�krevde geometriegenskaper
										Dim guidDT 
										guidDT  = "0"
										Select Case eAttributt.Type
											Case "CharacterString"
												guidDT = guidCharacterString
											Case "Real"
												If eAttributt.Precision = 0 Then
													'Endrer til Integer
													guidDT = guidInteger
													eAttributt.Type = "Integer"
												Else
													guidDT = guidReal
												End If
											Case "Date" : guidDT = guidDate
											Case "Boolean" : guidDT = guidBoolean
											Case "Punkt"
												guidDT = guidPunkt
												eAttributt.Name = "posisjon"
												geomPunkt = True
											Case "Kurve"
												guidDT = guidKurve
												eAttributt.Name = "senterlinje"
												geomKurve = True
											Case "Flate"
												guidDT = guidFlate
												eAttributt.Name = "omr�de"
										End Select
										if not guidDT = "0" then
											set elementB = Repository.GetElementByGuid(guidDT)
											Repository.WriteOutput "SOSI", Now & " Egenskapen " & eAttributt.Name & " (" & eAttributt.Style & ") gis datatype " & eAttributt.Type, 0
											eAttributt.ClassifierID = elementB.ElementID
										End If
									End If
								end if
							End If 'Datatype flerverdi eller vanlig
						End if 'ElementDT is nothing
					End if 
				End if 'IncludeAttr
				eAttributt.Update()
			Next 'idxA
			
			'Operasjoner som gjelder objekttyper
			If element.Stereotype = "featureType" Or element.Stereotype = "FeatureType" Then	
				'********************** Stedfestingsegenskaper *************************
				'Legger til eventuelt manglende geometriegenskaper, og lr-posisjon dersom det er valgt
				Select Case strStedfesting
					Case "strekning"
						If Not geomKurve Then
							'Legger til manglende egenskap for kurvegeometri
							Repository.WriteOutput "SOSI", Now & " Legger til geometriegenskap senterlinje p� " & element.Name, 0
							set eAttributt = element.Attributes.AddNew("senterlinje", "")
							eAttributt.Pos = 99998
							eAttributt.Type = "Kurve"
							eAttributt.LowerBound = 0
							eAttributt.UpperBound = 1
							eAttributt.Notes = "Angivelse av objektets posisjon"							
							eAttributt.Visibility = "Public"							
							set aTag = eAttributt.TaggedValues.AddNew("SOSI_navn", "SENTERLINJE")
							aTag.Update()
							set elementB = Nothing
							'Finner kobling til riktig datatype
							set elementB = Repository.GetElementByGuid(guidKurve)
							If not elementB is Nothing then
								eAttributt.ClassifierID = elementB.ElementID
							end if 	
							eAttributt.Update()
						End If

						If blnLRAttr Then
							'Legger til lr-posisjon for strekning
							Repository.WriteOutput "SOSI", Now & " Legger til egenskap line�rPosisjon (strekning) p� " & element.Name, 0
							set eAttributt = element.Attributes.AddNew("line�rPosisjon", "")
							eAttributt.Pos = 99999
							eAttributt.Type = "Line�rPosisjonStrekning"
							eAttributt.LowerBound = 0
							eAttributt.UpperBound = "*"
							eAttributt.Notes = "Angivelse av posisjon p� det line�re objektet."
							eAttributt.Visibility = "Public"
							set constraint = element.Constraints.AddNew("M� ha minst en av stedfestingene line�rPosisjon og senterlinje", "OCL")
							constraint.Notes = "inv:count(self.senterlinje)+count(self.line�rposisjon)>0"
							constraint.Weight = 100
							constraint.Update()
							set aTag = eAttributt.TaggedValues.AddNew("SOSI_navn", "LRSTREKNING")
							aTag.Update()
							set elementB = Nothing
							If blnFellesegenskaper Then
								'Finner kobling til riktig datatype i lokal pakke med SOSI Fellesegenskaper
								set elementB = pkSOSIfelles.Elements.GetByName(eAttributt.Type)
								If not elementB is Nothing then
									eAttributt.ClassifierID = elementB.ElementID
								End if
							Else
								'Finner kobling til riktig datatype
								set elementB = Repository.GetElementByGuid(guidLRStrekning)
								If not elementB is Nothing then
									eAttributt.ClassifierID = elementB.ElementID
								End if	
							End If
							eAttributt.Update()
						End if	
							
					Case "punkt"
						If Not geomPunkt Then
							'Legger til manglende egenskap for punktgeometri
							Repository.WriteOutput "SOSI", Now & " Legger til geometriegenskap posisjon p� " & element.Name, 0
							set eAttributt = element.Attributes.AddNew("posisjon", "")
							eAttributt.Pos = 99998
							eAttributt.Type = "Punkt"
							eAttributt.LowerBound = 0
							eAttributt.UpperBound = 1
							eAttributt.Notes = "Angivelse av objektets posisjon"							
							eAttributt.Visibility = "Public"							
							set aTag = eAttributt.TaggedValues.AddNew("SOSI_navn", "POSISJON")
							aTag.Update()
							set elementB = Nothing
							'Finner kobling til riktig datatype
							set elementB = Repository.GetElementByGuid(guidKurve)
							if not elementB is Nothing then
								eAttributt.ClassifierID = elementB.ElementID
							End if	
							eAttributt.Update()
						End If

						If blnLRAttr Then
							'Legger til lr-posisjon for punkt
							Repository.WriteOutput "SOSI", Now & " Legger til egenskap line�rPosisjon (punkt) p� " & element.Name, 0
							set eAttributt = element.Attributes.AddNew("line�rPosisjon", "")
							eAttributt.Pos = 99999
							eAttributt.Type = "Line�rPosisjonPunkt"
							eAttributt.LowerBound = 0
							eAttributt.UpperBound = "*"
							eAttributt.Notes = "Angivelse av posisjon p� det line�re objektet."
							eAttributt.Visibility = "Public"
							set constraint = element.Constraints.AddNew("M� ha minst en av stedfestingene line�rPosisjon og posisjon", "OCL")
							constraint.Notes = "inv:count(self.posisjon)+count(self.line�rPosisjon)>0"
							constraint.Weight = 100
							constraint.Update()
							set aTag = eAttributt.TaggedValues.AddNew("SOSI_navn", "LRPUNKT")
							aTag.Update()
							set elementB = Nothing
							If blnFellesegenskaper Then
								'Finner kobling til riktig datatype i lokal pakke med SOSI Fellesegenskaper
								set elementB = pkSOSIfelles.Elements.GetByName(eAttributt.Type)
								If not elementB is Nothing then
									eAttributt.ClassifierID = elementB.ElementID
								End if	
							Else
								'Finner kobling til riktig datatype								
								set elementB = Repository.GetElementByGuid(guidLRPunkt)
								if not elementB is Nothing then
									eAttributt.ClassifierID = elementB.ElementID
								End if	
							End If
							eAttributt.Update()
						End if
				End Select
				
				'************************************** Spesialiteter: Retning *************************************
				'Dersom Retningsrelevant: Constraint med krav om retning
				If retning Then 'Or pkOT_Sub.Name = "Innkj�ring forbudt" Or pkOT_Sub.Name = "Svingerestriksjon" 
					Repository.WriteOutput "SOSI", Now & " Legger til constraint om retning p� " & element.Name,0 
					'Legger til constraint
					set constraint = element.Constraints.AddNew("Line�rPosisjon skal ha retning", "OCL")
					constraint.Notes = "inv:count(self.line�rPosisjon.retning)=1"
					constraint.Weight = 100
					constraint.Update()
				End If
				
				'************************************** Spesialiteter: Kj�refelt *************************************
				'Dersom kj�refeltrelevant: Feltegenskap 
				If kjorefelt > 0 Then
					Repository.WriteOutput "SOSI", Now & " Legger til egenskap felt p� " & element.Name, 0
					'Legge til egenskapen med korrekt datatype
					set eAttributt = element.Attributes.AddNew("felt", "CharacterString")
					set elementB = Nothing
					Set elementB = Repository.GetElementByGuid(guidCharacterString)
					If not ElementB is nothing then
						Repository.WriteOutput "SOSI", Now & " Egenskapen " & eAttributt.Name & " (" & eAttributt.Style & ") gis datatype " & eAttributt.Type,0
						eAttributt.ClassifierID = elementB.ElementID
					end if	
					eAttributt.Pos = 99998
					eAttributt.Visibility = "Public"
					eAttributt.Notes = "Tekststreng som brukes dersom objektet gjelder bestemte kj�refelt"
					eAttributt.UpperBound = 1
					If kjorefelt = 1 Then
						eAttributt.LowerBound = 0
					ElseIf kjorefelt = 2 Then
						eAttributt.LowerBound = 1
					End If
					eAttributt.Update()
					set aTag = eAttributt.TaggedValues.AddNew("SOSI_navn", "VKJORFELT")
					aTag.Update()
				End If


                '******************************* Spesialiteter for Svingerestriksjoner *****************************************************
				'Spesielt for Svingerestriksjoner: Legger til egenskapene "svingeforbudFra" og "svingeforbudTil" med datatype "Line�rPosisjonPunkt"
				If pkOT_Sub.Name = "Svingerestriksjon" Then
					Repository.WriteOutput "SOSI", Now & " Legger til stedfestingsegenskaper p� " & element.Name, 0
					'S�ke opp datatype
					set elementB = Nothing
					set elementB = Repository.GetElementByGuid(guidLRPunkt)
					'Legge til egenskapene med korrekt datatype
					set eAttributt = element.Attributes.AddNew("svingeforbudFra", "Line�rPosisjonPunkt")
					eAttributt.Pos = 99996
					eAttributt.Visibility = "Public"
					eAttributt.Notes = "angir hvilken lenke svingerestriksjonen gjelder fra. Merknad: Egenskapen finnes ikke i NVDB, men avledes ut fra stedfesting p� referanselenkene"
					If Not elementB Is Nothing Then 
						eAttributt.ClassifierID = elementB.ElementID
					end if	
					eAttributt.Update()
					set aTag = eAttributt.TaggedValues.AddNew("SOSI_navn", "NVDB_SVINGEFORBUDFRA")
					aTag.Update()
					set eAttributt = element.Attributes.AddNew("svingeforbudTil", "Line�rPosisjonPunkt")
					eAttributt.Pos = 99997
					eAttributt.Visibility = "Public"
					eAttributt.Notes = "angir hvilken lenke svingerestriksjonen gjelder til. Merknad: Egenskapen finnes ikke i NVDB, men avledes ut fra stedfesting p� referanselenkene"
					If Not elementB Is Nothing Then 
						eAttributt.ClassifierID = elementB.ElementID
					End if	
					eAttributt.Update()
					set aTag = eAttributt.TaggedValues.AddNew("SOSI_navn", "NVDB_SVINGEFORBUDTIL")
					aTag.Update()
					set constraint = element.Constraints.AddNew("Line�re posisjoner skal ha retning", "OCL")
					constraint.Notes = "inv:count(self.svingeforbudFra.retning)=1 and count(self.svingeforbudTil.retning)=1"
					constraint.Weight = 100
					constraint.Update()
				End If

				'Fjerner constraints
				If blnRemoveConstraints Then
					'Fjerner constraints
					removeConstraints(element)
				End If
				
				'Legger til arv fra SOSI Fellesegenskaper
				if blnFellesegenskaper then
					If Not ftSOSIfelles Is Nothing Then
						If element.Name = "Dokumentasjon" Or element.Name = "Kommentar" Or element.Name = "Systemobjekt" Or Mid(element.Name, 1, 8) = "Tilstand" Or _
						element.Name = "NVDB_Dokumentasjon" Or element.Name = "NVDB_Kommentar" Or element.Name = "NVDB_Systemobjekt" Or Mid(element.Name, 1, 13) = "NVDB_Tilstand" Then
							Repository.WriteOutput "SOSI", Now & " Legger ikke til arv fra SOSI Fellesegenskaper for objekttypen " & element.Name, 0
						Else
							Repository.WriteOutput "SOSI", Now & " Legger til arv fra SOSI Fellesegenskaper for objekttypen " & element.Name, 0
							set con = element.Connectors.AddNew("", "Generalization")
							con.ClientID = element.ElementID
							con.SupplierID = ftSOSIfelles.ElementID
							con.Update()
						End If
					End If
				end if

				'Legger til i diagrammet Hovedskjema
				Repository.WriteOutput "Script", Now & " Legger til objekttypen i diagrammet Hovedskjema", 0
				set	diagramObjekt = eHovedskjema.DiagramObjects.AddNew("", "")
				diagramObjekt.ElementID = element.ElementID
				diagramObjekt.Update()
				hideAttributes diagramObjekt
				setSize diagramObjekt, 70, 200
				eHovedskjema.Update()
				
			End if 	
			element.Update()
			
		Next 'idxE	 
	Next 'i 

	'Prosesser som kj�res etter at alle er kopiert og konvertert - Tas ut som egen prosess av hensyn til tidsbruk?
	'************************ Gjennomgang av tagger p� pakka, assosiasjoner og diagrammer - skal kun ha assosiasjoner til konverterte objekttyper ***********************
	'Gjennomgang av diagrammer 
	'Tagged values for kodelister
	
	'Operasjoner med utgangspunkt i selve featuretypen (kun en i hver pakke)
	'Assosiasjoner 

	'Ordner layout p� Hovedskjema
	ePIF.LayoutDiagramEx eHovedskjema.DiagramGUID, 14, 8, 30, 20, True

	'Alias p� alle elementer og pakker - dersom satt til NVDB_Navn
	'?
	
	'Sorterer pakker og elementer

	Repository.WriteOutput "Script", Now & " Ferdig, sjekk logg", 0 
	Repository.EnsureOutputVisible "Script"
	'repository.RefreshModelView(pkNVDBSOSImain.PackageID)

end sub

convert2SOSI
