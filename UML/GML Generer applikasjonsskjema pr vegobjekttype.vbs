option explicit

!INC Local Scripts.EAConstants-VBScript

' Script Name: Generer applikasjonsskjema pr vegobjekttype
' Author: Knut Jetlund
' Purpose: Massiv generering av applikasjonsskjema pr vegobjekttype
' Date: 20160916
'
' NOTE: Requires a package to be selected in the Project Browser
' 
const svnSOSINVDB = "C:\DATA\Standardisering\SOSI\SOSI Modell\Andre viktige komponenter\NVDB\NVDB Datakatalogen versjon 2.06"
const ns = "https://raw.githubusercontent.com/jetgeo/NVDBGML/master/XSD/NVDB"
const ver = "2.06"

sub main()
	' Show and clear the script output window
	Repository.EnsureOutputVisible "Script"
	Repository.ClearOutput "Script"
	Repository.CreateOutputTab "Error"
	Repository.ClearOutput "Error"
		
	' Get the currently selected package in the tree to work on
	dim thePackage as EA.Package
	set thePackage = Repository.GetTreeSelectedPackage()
		
	if not thePackage is nothing and thePackage.ParentID <> 0 then
		
		Repository.WriteOutput "Script", Now & " Hovedpakke: " & thePackage.Name & " (" & thePackage.PackageGUID & ")", 0 
		Repository.WriteOutput "Script", Now & " Kobler til ShapeChange-prosjektet", 0 
		'Kobler til ShapeChange-prosjektet
		dim scRep as EA.Repository
		set scRep = CreateObject("EA.Repository")
		scRep.OpenFile("C:\DATA\GitHub\NVDBGML\ShapeChange.eap")
		'Sletter alle eksisterende modeller i ShapeChange-prosjektet
		Repository.WriteOutput "Script", Now & " Sletter alle eksisterende modeller i ShapeChange-prosjektet", 0 
		dim scMod as EA.Package
		dim i
		for i = 0 to scRep.Models.Count -1
			set scMod = scRep.Models.GetAt(i)
			Repository.WriteOutput "Script", Now & " Sletter modellen " & scMod.Name, 0 
			scRep.Models.DeleteAt i,false
		next
		scRep.Models.Refresh		
		'Lager basismodell
		Repository.WriteOutput "Script", Now & " Lager modellen ShapeChange", 0 
		set scMod = scRep.Models.AddNew("ShapeChange","")
		scMod.Update	

		dim pck as EA.Package
		for each pck in thePackage.Packages
			Repository.WriteOutput "Script", Now & " Delpakke: " & pck.Name & " (" & pck.PackageGUID & ")", 0 
			'Sletter eksisterende pakker i modellen ShapeChange
			for i = 0 to scMod.Packages.Count-1
				scMod.Packages.DeleteAt i,false
			next
			scMod.Packages.Refresh
			
			dim j
			dim el as EA.Element
			'Finner selve objekttypen
			for j = 0 to pck.Elements.Count -1
				set el = pck.Elements.GetAt(j)
				if el.Stereotype="featureType" then
					'Her starter moroa!
					dim id
					id = pck.Alias
					dim nvn 
					nvn = el.Name
				
					nvn= Replace(nvn, "æ","ae")
					nvn= Replace(nvn, "Æ","Ae")
					nvn= Replace(nvn, "ø","oe")
					nvn= Replace(nvn, "Ø","Oe")
					nvn= Replace(nvn, "å","aa")
					nvn= Replace(nvn, "Å","Aa")
					'Lager hovedpakke
					Repository.WriteOutput "Script", Now & " Lager hovedpakke: " & nvn, 0 
					dim scPck as EA.Package
					set scPck = scMod.Packages.AddNew(nvn,"")
					scPck.StereotypeEx="applicationSchema"
					scPck.Update
					'Legger på gml-tagger 
					dim tagVal as EA.TaggedValue
					set tagVal = scPck.Element.TaggedValues.AddNew("targetNamespace", ns)
					tagVal.Update
					set tagVal = scPck.Element.TaggedValues.AddNew("version", ver)
					tagVal.Update
					set tagVal = scPck.Element.TaggedValues.AddNew("xmlns", "nvdb")
					tagVal.Update
					set tagVal = scPck.Element.TaggedValues.AddNew("xsdDocument", nvn & ".xsd")
					tagVal.Update				
					set tagVal = scPck.Element.TaggedValues.AddNew("xsdEncodingRule", "sosi")
					tagVal.Update
					scMod.Packages.Refresh
					
					'Importerer SOSI Fellesegenskaper-pakken
					Repository.WriteOutput "Script", Now & " Importerer SOSI Fellesegenskaper-pakken", 0 
					dim pI as EA.Project
					set pI = scRep.GetProjectInterface()
					pI.ImportPackageXMI scPck.PackageGUID, "C:\DATA\Standardisering\NVDB\NVDB Datakatalogen\trunk\public\SOSI Fellesegenskaper.xml", 1,0
					
					'Importerer aktuell objekttype sin pakke
					Repository.WriteOutput "Script", Now & " Importerer filen " & id & ".xml", 0 
					pI.ImportPackageXMI scPck.PackageGUID, svnSOSINVDB & "\" & id & ".xml", 1,0
					
					'Løkke for assosiasjoner
					dim con as EA.Connector
					for each con in el.Connectors
						set tagVal = nothing
						set tagVal = con.TaggedValues.GetByName("NVDB_SupplierID")
						if not tagVal is nothing then
							if tagVal.Value <> id then
								'Importer assosiert pakke
								Repository.WriteOutput "Script", Now & " Importerer filen " & tagVal.Value & ".xml", 0 
								pI.ImportPackageXMI scPck.PackageGUID, svnSOSINVDB & "\" & tagVal.Value & ".xml", 1,0
							end if
						end if
						set tagVal = nothing
						set tagVal = con.TaggedValues.GetByName("NVDB_ClientID")
						if not tagVal is nothing then
							if tagVal.Value <> id then
								'Importer assosiert pakke
								Repository.WriteOutput "Script", Now & " Importerer filen " & tagVal.Value & ".xml", 0 
								pI.ImportPackageXMI scPck.PackageGUID, svnSOSINVDB & "\" & tagVal.Value & ".xml", 1,0
							end if
						end if
					next
					
					'Legger til arv fra SOSI Fellesegenskaper for alle objekttyper
					
					'Finn SOSI Fellesegenskaper
					dim pkSOSIfelles as EA.Package
					set pkSOSIfelles = scPck.Packages.GetByName("SOSI Fellesegenskaper")
		
					if not pkSOSIfelles is nothing then
						Repository.WriteOutput "Script", Now & " Pakken SOSI Fellesegenskaper funnet (" & pkSOSIfelles.PackageGUID & ")", 0 
						dim ftSOSIfelles as EA.Element
						set ftSOSIfelles = pkSOSIfelles.Elements.GetByName("Fellesegenskaper")
			
						if not ftSOSIfelles is nothing then
							Repository.WriteOutput "Script", Now & " Elementet Fellesegenskaper funnet (" & ftSOSIfelles.ElementGUID & ")", 0 
							dim scSubPck as EA.Package
							for each scSubPck in scPck.Packages
								dim scEl as EA.Element
								for each scEl In scSubPck.elements
									if scEl.Stereotype="featureType" then
										If scEl.Name = "Dokumentasjon" Or scEl.Name = "Kommentar" Or scEl.Name = "Systemobjekt" Or Mid(scEl.Name, 1, 8) = "Tilstand" Then
											Repository.WriteOutput "Script", Now & " Legger ikke til arv fra SOSI Fellesegenskaper for objekttypen " & scEl.Name, 0
										Else
											Repository.WriteOutput "Script", Now & " Legger til arv fra SOSI Fellesegenskaper for objekttypen " & scEl.Name, 0
											set con = scEl.Connectors.AddNew("", "Generalization")
											con.ClientID = scEl.ElementID
											con.SupplierID = ftSOSIfelles.ElementID
											con.Update()
										End If
									end if
								next
							next
						else
							Repository.WriteOutput "Script", Now & " Finner ikke elementet Fellesegenskaper", 0 
						end if		
					else
							Repository.WriteOutput "Script", Now & " Finner ikke pakken SOSI Fellesegenskaper", 0 
					end if	

					'Hopp ut av løkka etter første pakke - fjernes når scriptet er ferdig.
					scRep.CloseFile
					scRep.Exit
					exit sub
					
					'Går ut av løkka
					j = pck.Elements.Count -1
				end if
			next
		next
				
		Repository.WriteOutput "Script", Now & " Ferdig, sjekk resultatfilene...", 0 
		Repository.EnsureOutputVisible "Script"
		scRep.CloseFile
		set scRep = nothing	
	else
		' No package selected in the tree
		MsgBox( "This script requires a package to be selected in the Project Browser." & vbCrLf & _
			"Please select a package in the Project Browser and try again." )
	end if
	

end sub

main
