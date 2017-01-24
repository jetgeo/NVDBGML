Public Function createSOSInavn(str,ul,maxLength,delimiter)
	'Lager SOSI-navn av NVDB-navn
	
	dim strOrg
	strOrg = str 
	
	With (New RegExp)
		.Global = True
		'Erstatter ">" med "Over"
		.Pattern = "[>]"
		str = .Replace(str, "-Over-") 
		'Erstatter "<" med "Under"
		.Pattern = "[<]"
		str = .Replace(str, "-Under-") 
		'Erstatter "%" med "Prosent"
		.Pattern = "[%]"
		str = .Replace(str, "-Prosent-") 
		'Erstatter "µm" med "Mikrometer"
		.Pattern = "µm"
		str = .Replace(str, "-Mikrometer-") 
		'Erstatter "km/t" med "kmt"
		.Pattern = "km/t"
		str = .Replace(str, "-kmt-") 
		'Erstatter "m.m." med "mm"
		.Pattern = ".m.m."
		str = .Replace(str, "-mm-")  
		'Erstatter "m/" og "M/" med "Med"
		.Pattern = "m/"
		str = .Replace(str, "-Med-") 
		.Pattern = "M/"
		str = .Replace(str, "-Med-") 
		'Erstatter "u/" og "U/" med "Uten"
		.Pattern = "u/"
		str = .Replace(str, "-Uten-") 
		.Pattern = "U/"
		str = .Replace(str, "-Uten-") 
		'Erstatter "(" og ")" med "Parentes" - byttes med "_" senere
		.Pattern = "[(]"
		str = .Replace(str, "-Parentes-") 
		.Pattern = "[)]"
		str = .Replace(str, "-Parentes-")
		'Erstatter " v " med "Ved"
		.Pattern = " v "
		str = .Replace(str, "-Ved-") 	
		'Erstatter ":" mellom tall med "til". Eksempel: "10:1" blir "10til1"
		.Pattern = "([0-9]+)([:])([0-9]+)"
		str = .Replace(str, "$1til$3") 	
		'Erstatter "." mellom tall med "_". Eksempel: "1.5" blir "1_5"
		.Pattern = "([0-9]+)([.])([0-9]+)"
		str = .Replace(str, "$1_$3") 		
		'Erstatter "/" mellom tall med "_". Eksempel: "3/4" blir "3_4"
		.Pattern = "([0-9]+)([/])([0-9]+)"
		str = .Replace(str, "$1_$3") 		
		'Erstatter "-" mellom tall med "til". Eksempel: "3-4" blir "3til4"
		.Pattern = "([0-9]+)([-])([0-9]+)"
		str = .Replace(str, "$1til$3") 		
		'Erstatter " - " mellom tall med "_". Eksempel: "BkT8 - 40 tonn" blir "bkT8_40Tonn"
		.Pattern = "([0-9]+)([\s][-][\s])([0-9]+)"
		str = .Replace(str, "$1_$3") 		
		'Erstatter ".-" mellom tall med "til". Eksempel: "3.-4." blir "3til4"
		.Pattern = "([0-9]+)([.][-])([0-9]+)"
		str = .Replace(str, "$1til$3") 		
		'Erstatter "." mellom tall med "Punktum". Byttes med "_" senere. Eksempel: "1.5" blir "1Punktum5" og deretter "1_5"
		.Pattern = "([0-9]+)([.])([0-9]+)"
		str = .Replace(str, "$1-Punktum-$3") 
		'Erstatter "," mellom tall med "Komma". Byttes med "_" senere Eksempel: "1,5" blir "1Komma5" og deretter "1_5"
		.Pattern = "([0-9]+)([,])([0-9]+)"
		str = .Replace(str, "$1-Komma-$3") 		
		'Erstatter " - " med "Mellomrom". Byttes med "_" senere. Eksempel: "Ord1 - Ord2" blir "Ord1_Ord2"
		.Pattern = "[\s][-][\s]"
		str = .Replace(str, "-Mellomrom-") 		
		'Erstatter ", " mellom tall med "Mellomrom". Byttes med "_" senere Eksempel: Eksempel: "Ord1, Ord2" blir "Ord1_Ord2"
		.Pattern = "[,][\s]"
		str = .Replace(str, "-Mellomrom-") 		
		'Erstatter " " mellom gjentakende store bokstaver med "Mellomrom". Byttes med "_" senere Eksempel: Eksempel: "ABC GF" blir "ABC_GF"
		.Pattern = "([A-Z_ÆØÅ][A-Z_ÆØÅ])+([ ])([A-Z_ÆØÅ][A-Z_ÆØÅ])"
		str = .Replace(str, "$1-Mellomrom-$3") 		
		'Erstatter "-" mellom gjentakende store bokstaver med "Mellomrom". Byttes med "_" senere Eksempel: Eksempel: "ABC-GF" blir "ABC_GF"
		.Pattern = "([A-Z_ÆØÅ][A-Z_ÆØÅ])+([-])([A-Z_ÆØÅ][A-Z_ÆØÅ])"
		str = .Replace(str, "$1-Mellomrom-$3") 		
		'Erstatter "-" generelt med "Mellomrom". Byttes med "_" senere Eksempel: Eksempel: "123-GF" blir "123_GF"
		.Pattern = "([a-zA-Z_0-9_æøå_ÆØÅ])([-])([a-zA-Z_0-9_æøå_ÆØÅ])" 
		str = .Replace(str, "$1-Mellomrom-$3") 
		'Erstatter "ååååmmdd" med "-", dvs fjernes fra strengen
		.Pattern = "ååååmmdd"
		str = .Replace(str, "-") 	
		'Erstatter ":" generelt med "Mellomrom". Byttes med "_" senere Eksempel: Eksempel: "123:GF" blir "123_GF"		
		.Pattern = ":"
		str = .Replace(str, "-Mellomrom-") 	
		
		'Erstatte "tall mellomrom stor bokstav" og "stor bokstav mellomrom tall" med "$1-Mellomrom-$3"
		.Pattern = "([0-9])([ ])([A-Z_ÆØÅ])" 
		str = .Replace(str, "$1-Mellomrom-$3") 
		.Pattern = "([A-Z_ÆØÅ])([ ])([0-9])" 
		str = .Replace(str, "$1-Mellomrom-$3") 
		
		'Erstatter gjenværende spesialtegn med "-", dvs de fjernes fra strengen.
		.Pattern = "[^a-zA-Z_0-9_æøå_ÆØÅ]" 
		str = .Replace(str, "-") 'all non-digits or letters replaced with "-"
	End With	
	
	Dim arr, i, strTmp
	strTmp = ""
	arr = Split(str, "-") 'create array with elements for each "-"
	For i = LBound(arr) To UBound(arr)
		if arr(i) <> "" then
			'Upper case for first letter in each new word
			arr(i) = UCase(Left(arr(i), 1)) & Mid(arr(i), 2)
			If arr(i) = "Parentes" or arr(i) = "Komma" or arr(i) = "Punktum" or arr(i) = "Mellomrom" then arr(i) = "_"
			strTmp = strTmp & arr(i)
			if i < Ubound (arr) and Right(arr(i),1) <> "_" then
				strTmp = strTmp & delimiter
			end if
		end if	
	Next

	With (New RegExp)
		.Global = True
		.Pattern = "[_]+"
		strTmp = .Replace(strTmp, "_") 
	End With	
	
	do while Right(strTmp,1) = "_"
		strTmp = Left(strTmp, len(strTmp)-1)
	loop
	
	if len(strTmp) > maxLength then
		strTmp = Left(strTmp, maxLength)
	end if
	
	if ul = "Lower" then
		'Lower case for first letter in complete word, unless both first and second letter i upper case
		'If so, the word is presumed to be a abbreviation, and the letters shall be kept upper case
		If not (UCase(Left(strTmp, 1)) = Left(strTmp, 1) and Ucase(Mid(strTmp, 2, 1)) = Mid(strTmp, 2, 1)) then
			strTmp = LCase(Left(strTmp, 1)) &  Mid(strTmp, 2)
		End if	
	end if
	
	createSOSInavn = strTmp
	Repository.WriteOutput "SOSI", Now & " Nytt SOSI-navn for " & strOrg & ": " & createSOSInavn , 0 
End Function

