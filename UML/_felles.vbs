!INC NVDB._parametre

'Generelle variabler
dim ePIF as EA.Project
dim modDakat as EA.Package
dim pkObjekttyper as EA.Package
dim pkDatatyper as EA.Package
dim modSOSI as EA.Package
dim eAttributt as EA.Attribute
dim constraint as EA.Constraint

dim pkOT_Sub as EA.Package
dim element as EA.Element
dim tagVal as EA.TaggedValue
dim aTag as EA.AttributeTag
dim eDiagram As EA.Diagram

dim dbDakat
dim rsDatatyper
dim rsObjekttyper
dim rsEgenskapstyper

dim id 
dim idxe 
dim idxT
dim idxP
dim idxA
dim lstAlias 
dim lstSOSIelementNames


'Generelle funksjoner

function connect2models()
	'Setter opp kobling til modeller
	Repository.EnsureOutputVisible "Script"
	Repository.ClearOutput "Script"
	Repository.CreateOutputTab "Error"
	Repository.ClearOutput "Error"
	Repository.CreateOutputTab "Endringer"
	Repository.ClearOutput "Endringer"
	Repository.CreateOutputTab "SOSI"
	Repository.ClearOutput "SOSI"
	
	Repository.WriteOutput "Script", Now & " Datakatalogversjon: " & FC_version, 0 
	Repository.WriteOutput "Script", Now & " Accessbase: " & FC_db, 0 
	Repository.WriteOutput "Script", Now, 0 
	Repository.WriteOutput "Script", Now & " Kobler til Datakatalog-accessdatabasen",0
    Dim strDakatAccessConnect
    strDakatAccessConnect = "Driver={Microsoft Access Driver (*.mdb)};" & "Dbq=" & FC_db & ";DefaultDir=;" & "Uid=Admin;Pwd=;"
	set dbDakat = CreateObject("ADODB.Connection")
    dbDakat.Open strDakatAccessConnect
	
	Repository.WriteOutput "Script", Now & " Setter opp modelltilknytninger",0
	
	set ePIF = Repository.GetProjectInterface
	set modDakat = Repository.Models.GetByName(strModelName)
	Repository.WriteOutput "Script", Now & " Hovedmodell for NVDB Datakatalogen: " & modDakat.Name,0
	set pkObjekttyper = modDakat.Packages.GetByName(strObjektPakke)
	Repository.WriteOutput "Script", Now & " Pakke med vegobjekttyper: " & pkObjekttyper.Name,0
    set pkDatatyper = modDakat.Packages.GetByName(strDatatypePakke)
	Repository.WriteOutput "Script", Now & " Pakke med NVDB-datatyper: " & pkDatatyper.Name,0

	set modSOSI = Repository.Models.GetByName(strSOSIModell)
	Repository.WriteOutput "Script", Now & " Hovedmodell for SOSI: " & modSOSI.Name,0

	Repository.WriteOutput "Script", Now, 0 

	'dbDakat.Close
	
end function

function getElementByAlias(pck, strAlias)
'Finner et angitt element i en pakke, ut fra alias
	Dim idx 
	set getElementByAlias = Nothing
	For idx = 0 To pck.Elements.Count - 1
		If (pck.Elements.GetAt(idx).Alias = strAlias) Then
			set getElementByAlias = pck.Elements.GetAt(idx)
			idx = pck.Elements.Count - 1
		End If
	Next
End Function

Public Function createSOSInavn(str,ul,maxLength,delimiter)
	'Lager SOSI-navn av NVDB-navn
	With (New RegExp)
		.Global = True
		.Pattern = "[>]"
		str = .Replace(str, "-Over-") 
		.Pattern = "[<]"
		str = .Replace(str, "-Under-") 
		.Pattern = "[%]"
		str = .Replace(str, "-pst-") 
		.Pattern = "[(]"
		str = .Replace(str, "-Parentes-") 
		.Pattern = "[^a-zA-Z_0-9_זרו_ֶ״ֵ]" 
		str = .Replace(str, "-") 'all non-digits or letters replaced with "-"
	End With	
	
	Dim arr, i, strTmp
	strTmp = ""
	arr = Split(str, "-") 'create array with elements for each "-"
	For i = LBound(arr) To UBound(arr)
		if arr(i) <> "" then
			arr(i) = UCase(Left(arr(i), 1)) & Mid(arr(i), 2)
			If arr(i) = "Parentes" then arr(i) = "_"
			strTmp = strTmp & arr(i)
			if i < Ubound (arr) and Right(arr(i),1) <> "_" then
				strTmp = strTmp & delimiter
			end if
		end if	
	Next

	if len(strTmp) > maxLength then
		strTmp = Left(strTmp, maxLength)
	end if
	
	if ul = "Lower" then
		strTmp = LCase(Left(strTmp, 1)) &  Mid(strTmp, 2)
	end if
	
	createSOSInavn = strTmp
	Repository.WriteOutput "SOSI", Now & " Nytt SOSI-navn : " & createSOSInavn , 0 
End Function