$documents_path = 'c:\Install\test'

$word_app = New-Object -ComObject Word.Application

# This filter will find .doc as well as .docx documents
Get-ChildItem -Path $documents_path -Filter *.doc? | ForEach-Object {

    $document = $word_app.Documents.Open($_.FullName)
    
    $document.Fields | %{$_.Update()}

    # Opdatere indholdsfortegnelsen
    $document.TablesOfContents.item(1).Update()
    # filsti til pdf dokumentet
    $pdf_filename = "$($_.DirectoryName)\$($_.BaseName).pdf"
    # Gemmer dokumentet i pdf format
    $document.SaveAs([ref] $pdf_filename, [ref] 17)
    # Lukker word dokument
    $document.Close()
}

$word_app.Quit()
