################################################
# Version til at opdatere indholdsfortegnelsen #
# gemme som pdf og WORD i nyt versionsnummer   #
################################################

$documents_path = 'c:\Install\test'

$Gamle_versioner = "C:\install\test\gamle_filer"

$word_app = New-Object -ComObject Word.Application

# This filter will find .doc as well as .docx documents
Get-ChildItem -Path $documents_path -Filter *.doc? | ForEach-Object {

    $document = $word_app.Documents.Open($_.FullName)
    
    $document.Fields | %{$_.Update()}

    # Opdatere indholdsfortegnelsen
    $document.TablesOfContents.item(1).Update()

    # Fulde sti, hvor pdf filen skal gemmes
    $pdf_filnavn = "$($_.DirectoryName)\$($_.BaseName).pdf"

    # Fule sti, hvor WORD filen skal gammes
    # $WORD_filnavn = "$($_.DirectoryName)\$($_.BaseName).docx"

    # Gemmer dokumentetmed nyt versionsnummer i pdf format
    $document.SaveAs([ref] $pdf_filnavn, [ref] 17)

    # Gemmer WORD dokument
    $document.Save()

    # Finder nuværende versionsnummer i filnavnet (efter sidste "_")
    $versionsnummer = $_.BaseName.substring($_.name.LastIndexOf("_")+4)

    # konvertere string til integer, og øger versionsnummer med 1
    $Ny_versionsnummer = [int]$versionsnummer +1 

    # Opretter nyt filnavn, Finder filnavn til og med "_ver"
    $Ny_WORDfil_version =$_.BaseName.Substring(0,$_.BaseName.LastIndexOf("_")+4) +$Ny_versionsnummer +".docx"

    # Fulde sti til ny WORD fil
    $Ny_WORDfil = "$($_.DirectoryName)\$Ny_WORDfil_version"

    # Gemmer dokumentet med nyt versionsnummer i word format
    $document.SaveAs($Ny_WORDfil)

    # Lukker åbne dokument
    $document.Close()

    # Flytter gammel version til anden folder
    Move-item -Path $_ -Destination $Gamle_versioner

}

# Afslutter WORD applikationen
$word_app.Quit()

# Pdf filer til feedback
$PDF_til_feedback = Get-ChildItem -Path $documents_path -Filter *.pdf 

# Opret mail til Jan og Finn
$Afsender = "Fornavn Efternav <navn@gmail.com>"
$Mail_modtager = "jsch@tec.dk"
$Emne = "Feedback"
$Body = "Hej
Venligst se vedhæftet filer for feedback.

Mvh. Gruppe 1"

$Mailserver = ""

# Send mail via powershell
Send-MailMessage -From $Afsender -To $Mail_modtager -Subject $Emne -Body $body -Encoding UTF8 -Attachments $PDF_til_feedback -SmtpServer $Mailserver

# Send mail via outlook
$Outlook = New-Object -ComObject Outlook.Application
$outfileName = "C:\Users\sth\Desktop\test.png"
$Mail = $Outlook.CreateItem(0)
$Mail.To = $Mail_modtager
$Mail.Subject = $Emne
$Mail.Body =$Body
$Mail.Attachments.Add($PDF_til_feedback)
$Mail.Display()
# $Mail.Display()


