option explicit

!INC Local Scripts.EAConstants-VBScript
!INC NVDB._felles
!INC NVDB._parametre

'konverterer fra Dakat-UML til SOSI-UML

Function setMultiplicityFromImportance(strImportance) 
	'Set mulitplicity from importance tag
	setMultiplicityFromImportance = 0
	Select Case strImportance
		Case "Påkrevd i database"
			If blnPkrvd Then setMultiplicityFromImportance = 1
		Case "Påkrevd ved nyregistrering"
			If blnPkrvdNyreg Then setMultiplicityFromImportance = 1
		Case "Betinget"
			If blnBetinget Then setMultiplicityFromImportance = 1
	End Select
End Function


sub convert2SOSI()
	dim strPar
	strPar = "Starter konvertering til SOSI med følgende parametre: " & vbCrLf & vbCrLf 
	strPar = strPar & "Hovedpakke: " & txtSOSIPakke & vbCrLf 
	strPar = strPar & "Kortnavn: " & txtShortName & vbCrLf & vbCrLf
	strPar = strPar & "Arv fra SOSI Fellesegenskaper: " & blnFellesegenskaper & vbCrLf 
	strPar = strPar & "Kun egenskaper fra Objektliste ferdigvegsdata: " & blnOLFV & vbCrLf 
	strPar = strPar & "Utelat sensitive egenskaper: " & blnSensitivitet & vbCrLf & vbCrLf
	strPar = strPar & "Viktighet som gir påkrevd: " & vbCrLf 
	strPar = strPar & "Påkrevd i database (" & blnPkrvd & "), Påkrevd ved nyregistrering (" & blnPkrvdNyreg & "), Betinget (" & blnBetinget & ")" & vbCrLf 
	
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
	
	'Sjekker om hovedpakken eksisterer, og sletter dersom brukeren ønsker det
	For idxP = 0 To pkNVDBSOSImain.Packages.Count - 1
		set pkNVDBSOSI = pkNVDBSOSImain.Packages.GetAt(idxP)
		If pkNVDBSOSI.Name = txtSOSIpakke Then
			Repository.WriteOutput "Script", Now & " Pakken eksisterer: " & txtSOSIpakke, 0
			response = MsgBox("Pakken " & txtSOSIpakke & " eksisterer. Trykk OK for å slette den, eller avbryt for å gå tilbake og velge nytt navn", vbOKCancel+vbQuestion)
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

        'Kjører gjennom alle klasser i delpakken. Endrer stereotyper, navn, tagged values...
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
						'SOSI-navn på objekttypen. Brukes for å sette SOSI-modellnavn og SOSI-formatnavn
						Repository.WriteOutput "SOSI", Now & " Klassen " & element.Name & " (" & element.Alias & ") endres til " & element.Stereotype & " " & tagVal.Value,0
						'Endrer navn på klassen til SOSI-modellnavn
						element.Name = tagVal.Value
						'Endrer tagged value til å inneholde SOSI-formatnavn (NVDB_ & Uppercase(element.Name))
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
						'Feltlengde - tas vare på for SOSI-realisering (kun kodelister)
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
			
			'********************** Navn og tagged values på egenskaper og tillatte verdier **********************
			For idxA = 0 To element.Attributes.Count - 1
				set eAttributt = element.Attributes.GetAt(idxA)
				
				Dim includeAttr 
				includeAttr = True

				'Dersom begrensning på kun attributter til OT Ferdigveg: Sjekk om attributt skal være med
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
			
				'Dersom begrensning på sensitive egenskaper: Sjekk om attributt skal være med
				If blnSensitivitet and (element.Stereotype = "FeatureType" Or element.Stereotype = "featureType") then
					set aTag = Nothing
					set aTag = eAttributt.TaggedValues.GetByName("Sensitiv")
					if not aTag is nothing then
						If aTag.Value = "true" Then
							includeAttr = False
						end if	
					End If
				End If
				
				'Sletter egenskaper som ikke skal være med, konverterer andre
				If Not includeAttr Then
					Repository.WriteOutput "SOSI", Now & " Egenskapen " & eAttributt.Name & " (" & eAttributt.Style & ") skal ikke være med, slettes", 0
					element.Attributes.DeleteAt idxA, False
				else
					'Kjører gjennom tagged values for egenskapene. Sletter uaktuelle, døper om noen til SOSI-tagger, og henter navn fra SOSI_Navn
					For idxT = 0 To eAttributt.TaggedValues.Count - 1
						set aTag = eAttributt.TaggedValues.GetAt(idxT)
						Select case aTag.Name
							Case "SOSI_navn"
								'SOSI-navn på egenskapen eller kodelisteverdien. Brukes for å sette SOSI-modellnavn og SOSI-formatnavn
								Select Case element.Stereotype
									Case "codeList", "CodeList"
										Repository.WriteOutput "SOSI", Now & " Kodelisteverdien " & eAttributt.Name & " (" & eAttributt.Style & ") endres til " & aTag.Value, 0
										'Endrer navn på kodelisteverdi til SOSI-form og tar vare på NVDB-navn i tagged value. Legger også inn i definisjon.
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
										'Endrer navn på egenskap
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
								'Antall desimaler - tas vare på for datatypekonvertering
								'   aTag.Name = "NVDB_ANTALL_DESIMALER"
								'  aTag.Update()
							Case "TOTAL_FELTLENGDE"
								'Feltlengde - tas vare på for SOSI-realisering
								aTag.Name = "SOSI_lengde"
								aTag.Update()
							Case "Viktighet"
								'Viktighet - brukes for å sette multiplisitet
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
								'Søke gjennom alle kodelister i pakken, sjekke Alias = eAttributt.style
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
									'Finner ID for aktuell SOSI-datatype. Tilpasser navn på geometriegenskaper, og registrerer om objekttypen har påkrevde geometriegenskaper
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
												eAttributt.Name = "område"
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
		Next 'idxE	 
	Next 'i 

	'Prosesser som kjøres etter at alle er kopiert og konvertert - Tas ut som egen prosess av hensyn til tidsbruk?
	'************************ Gjennomgang av tagger på pakka, assosiasjoner og diagrammer - skal kun ha assosiasjoner til konverterte objekttyper ***********************
	'Gjennomgang av diagrammer 
	'Tagged values for kodelister
	
	'Operasjoner med utgangspunkt i selve featuretypen (kun en i hver pakke)
	'Assosiasjoner 
	'Legger til arv fra SOSI Fellesegenskaper
	'Fjerner constraints
	'Legger til i diagrammet Hovedskjema

	'Ordner layout på Hovedskjema

	'Tagged values på morpakken
	'Alias på alle elementer og pakker - dersom satt til NVDB_Navn
	'Sorterer pakker og elementer

	Repository.WriteOutput "Script", Now & " Ferdig, sjekk logg", 0 
	Repository.EnsureOutputVisible "Script"
	repository.RefreshModelView(pkNVDBSOSImain.PackageID)

end sub

convert2SOSI
