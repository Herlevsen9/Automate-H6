####################################
# Version til at omdøbe dokumenter #
####################################

# Sti til nuværende versioner
$Dokumenter = "C:\install\test1"

# Sti til at gemme gamle versioner
$Gamle_versioner = "C:\install\test1\gamle_filer"

$word_filer = get-childitem -path $Dokumenter -Filter *.doc?

foreach ($item in $word_filer)
{
# Finder det sted, hvor der står "_" og ligger 4 til for at komme til nummeret efter "ver"
$versionsnummer = $item.BaseName.substring($item.name.LastIndexOf("_")+4)

# konvertere string til integer
$Ny_versionsnummer = [int]$versionsnummer +1 
# Opretter nyt filnavn, Finder filnavn til og med "_ver"
$Ny_fil =$item.BaseName.Substring(0,$item.BaseName.LastIndexOf("_")+4) +$Ny_versionsnummer +".docx" 
# Opretter fil med nyt versionsnummer
copy-item -Path $item -Destination $Ny_fil
# Flytter gammel version til anden folder
Move-item -Path $item -Destination $Gamle_versioner
}


################################################################
# Version til at opdatere indholdsfortegnelsen, gemme som pdf, #
# gemme som ny version, flytte gammel version til anden folder #
################################################################

# Sti til nuværende versioner
$Dokumenter = "C:\install\test1"

# Sti til at gemme gamle versioner
$Gamle_versioner = "C:\install\test1\gamle_filer"

# Opretter Word objekt
$word_app = New-Object -ComObject Word.Application

# Finder alle word filer i $Dokumenter
$word_filer = get-childitem -path $Dokumenter -Filter *.doc?

foreach ($item in $word_filer)
{
# Finder det sted, hvor der står "_" og ligger 4 til for at komme til nummeret efter "ver"
$versionsnummer = $item.BaseName.substring($item.name.LastIndexOf("_")+4)

# konvertere string til integer
$Ny_versionsnummer = [int]$versionsnummer +1 
# Opretter nyt filnavn, Finder filnavn til og med "_ver"
$Ny_WORDfil =$item.BaseName.Substring(0,$item.BaseName.LastIndexOf("_")+4) +$Ny_versionsnummer +".docx" 

$Ny_PDFfil =$item.BaseName.Substring(0,$item.BaseName.LastIndexOf("_")+4) +$Ny_versionsnummer +".pdf" 



    $document = $word_app.Documents.Open($item.FullName)
    
    $document.Fields | %{$_.Update()}

    # Opdatere indholdsfortegnelsen
    $document.TablesOfContents.item(1).Update()
    
    # Gemmer dokumentetmed nyt versionsnummer i pdf format
    $document.SaveAs([ref] $Ny_PDFfil, [ref] 17)

    # Gemmer dokumentet med nyt versionsnummer i word format
    $document.SaveAs($Ny_WORDfil)
    # Lukker word dokument
    $document.Close()




# Opretter fil med nyt versionsnummer
copy-item -Path $item -Destination $Ny_WORDfil
# Flytter gammel version til anden folder
Move-item -Path $item -Destination $Gamle_versioner

}

# Virker ikke med at opdatere indholdsfortegnelsen ej heller gemme som pdf
# Prøv med Foreach-Object istedet for Foreach ($item in $collection)

# Send mail til Jan of Finn

# Flyt pdf fil til gamle versioner

