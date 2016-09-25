option explicit

!INC Local Scripts.EAConstants-VBScript
!INC NVDB._felles
!INC NVDB._parametre


'Oppdaterer kodelister (lister med tillatte verdier)
sub updateKodelister()
	'Setter opp spørring som viser egenskaper med tillatte verdier i Dakat-databasen
	connect2models
	set rsEgenskapstyper = CreateObject("ADODB.Recordset")
	rsEgenskapstyper.Open "SELECT DISTINCT EGENSKAPSTYPE.* FROM EGENSKAPSTYPE INNER JOIN TILLATT_VERDI ON EGENSKAPSTYPE.ID_EGENSKAPSTYPE = TILLATT_VERDI.ID_EGENSKAPSTYPE WHERE NAVN_EGENSKAPSTYPE NOT LIKE 'Utgår%'", dbDakat, 3, 1
    rsEgenskapstyper.Filter = "Dato_fra_nvdb <> NULL AND ID_VEGOB_TYPE <> NULL"
   
	rsEgenskapstyper.MoveLast()
    Repository.WriteOutput "Script", Now & " Oppdaterer kodelister og legger til nye", 0 
	For idxP = 0 To pkObjekttyper.Packages.Count - 1
		Set lstAlias = CreateObject("System.Collections.ArrayList")
		set pkOT_Sub = pkObjekttyper.Packages.GetAt(idxP)
		id = pkOT_Sub.Alias
		rsEgenskapstyper.Filter = "Dato_fra_nvdb <> NULL AND ID_VEGOB_TYPE =" & pkOT_Sub.Alias
		Repository.WriteOutput "Script", Now & " OPPDATERER KODELISTER FOR VEGOBJEKTTYPEN " & UCase(pkOT_Sub.Name),0
		
		'Løkke for kodelister i pakka
		For idxE = 0 To pkOT_Sub.Elements.Count - 1
			set element = pkOT_Sub.Elements.GetAt(idxE)
			If element.Stereotype = "Tillatte verdier" Then
				'Tester om egenskapstypen finnes med tillatte verdier i Dakat
				If Not (rsEgenskapstyper.EOF And rsEgenskapstyper.BOF) Then
					rsEgenskapstyper.MoveFirst()
					rsEgenskapstyper.Find("ID_EGENSKAPSTYPE=" & element.Alias)
				End If
				If Not rsEgenskapstyper.EOF Then
					'Oppdaterer egenskapstypen
					Repository.WriteOutput "Script", Now & " Oppdaterer kodeliste: " & rsEgenskapstyper.Fields("NAVN_EGENSKAPSTYPE").Value & " (" & rsEgenskapstyper.Fields("ID_EGENSKAPSTYPE").Value & ")",0
					'updateProperties_Kodelister()
					lstAlias.Add(element.Alias)
				Else
					'Egenskapstypen finnes ikke med tillatte verdier i Dakat
					Repository.WriteOutput "Endringer", Now & " Sletter utgått kodeliste: " & pkOT_Sub.Name & "." & element.Name & " (" & element.Alias & ")",0
					pkOT_Sub.Elements.DeleteAt idxE, False
				End If
			End If
		Next 
		pkOT_Sub.Elements.Refresh()

		'Kjører gjennom alle registrerte egenskapstyper med tillatte verdier på objekttypen i Dakat, og legger til manglende i EA
		If Not (rsEgenskapstyper.EOF And rsEgenskapstyper.BOF) Then
			rsEgenskapstyper.MoveFirst()
			Do Until rsEgenskapstyper.EOF
				id = cstr(rsEgenskapstyper.Fields("ID_EGENSKAPSTYPE").Value	)
				If Not lstAlias.Contains(id) Then
					'Kodelisten finnes ikke 
					Repository.WriteOutput "Endringer", Now & " Lager kodeliste: " & pkOT_Sub.Name & "." & rsEgenskapstyper.Fields("NAVN_EGENSKAPSTYPE").Value & " (" & rsEgenskapstyper.Fields("ID_EGENSKAPSTYPE").Value & ")",0
					set element = pkOT_Sub.Elements.AddNew(rsEgenskapstyper.Fields("NAVN_EGENSKAPSTYPE").Value, "Class")
					element.Update()
					'updateProperties_Kodelister()
				Else
					Repository.WriteOutput "Script", Now & " Kodelisten finnes: " & rsEgenskapstyper.Fields("NAVN_EGENSKAPSTYPE").Value & " (" & rsEgenskapstyper.Fields("ID_EGENSKAPSTYPE").Value & ")",0
				End If
				rsEgenskapstyper.MoveNext()
			Loop
		End If
		
		'Sorterer objekter (featuretype og codelists) i pakka
		
		
		
	Next

	Repository.WriteOutput "Script", Now & " Ferdig, sjekk logg", 0 
	Repository.EnsureOutputVisible "Script"

end sub

updateKodelister
