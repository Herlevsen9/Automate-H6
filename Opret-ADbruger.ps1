<#
.Synopsis
   Opretter en AD bruger
.DESCRIPTION
   Opretter en Active Directory bruger ud fra Fornavn, Mellemnavn, Efternavn og Afdeling.
   Kontrollere om SamAccountName findes i forvejen
   eksistere SamAccountName køres der 3 forsøg med ekstra bogstaver fra fornavn eller mellemnavn
   for at finde et unikt SamAccountName
.EXAMPLE
   Opret-ADbruger -Fornavn Peter -Efternavn Hansen -Afdeling Ledelse
.EXAMPLE
   Opret-ADbruger -Fornavn Jens -Mellemnavn Ole -Efternavn Petersen -Afdeling IT -kodeord DetLangeK0deord
.COMPONENT
   Kræver Powershell ActiveDirectory modulet
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   Opretter AD brugere til en større produktion, hvor det ikke er muligt at kende alle SamAccountNames
#>
function Opret-ADbruger
{
    [CmdletBinding()]
    Param
    (
         # Fornavn hjælpe beskrivelse
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern("[a-å]")]
        [String] 
        $Fornavn,

         # Mellemnavn hjælpe beskrivelse
        [Parameter(ValueFromPipeline=$true,
                   Position=1)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern("[a-å]")]
        [String] 
        $Mellemnavn,

        # Efternavn hjælpe beskrivelse
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=2)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern("[a-å]")] 
        [String]
        $Efternavn,

        # Kodeord hjælpe beskrivelse
        [Parameter(ValueFromPipeline=$true)]         
        [String]
        $Kodeord='Pa$$w0rd',

         # Afdeling hjælpe description
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Ledelse","HR","Konsulenter","Økonomi","IT")]
        [String]
        $Afdeling,

        # Titel hjælpe description
        [Parameter(ValueFromPipeline=$true)]
        [String]
        $Titel
    )

    Begin
    {

#Krypter kodeordet
$Kodeord_secure = $Kodeord | ConvertTo-SecureString -AsPlainText -Force -Verbose

$ADbrugere = Get-aduser -filter * | select SamAccountName -ExpandProperty SamAccountName

$BrugerID = $Fornavn.ToLower().Substring(0,1) + $Efternavn.ToLower() 

# Kontroller om bruger findes
if ($ADbrugere -notcontains $BrugerID)
 {
     Write-Verbose -Message "$BrugerID findes ikke. Opretter bruger" -Verbose
     #Opret variabel for hele navnet uden mellemnavn
     if ([string]::IsNullOrEmpty($Mellemnavn))
     {
         $Hele_Navn = $Fornavn + " " + $Efternavn
     }

     #Opret variabel for hele navnet med mellemnavn
      if (-not ([string]::IsNullOrEmpty($Mellemnavn)))
     {
         $Hele_Navn = $Fornavn + " " + $Mellemnavn + " " + $Efternavn
     }
 }

    # Kontroller om BrugerID findes i forvejen
    # Kontroller om Mellemnavn er null eller tomt, i givent tilfælde, kør BrugerID oprettelse med Fornavn og Efternavn
    if (($ADbrugere -contains $BrugerID) -and [string]::IsNullOrEmpty($Mellemnavn))
    {
        Write-Verbose -Message "$BrugerID findes i forvejen" -Verbose
        Write-Verbose -Message "Mellemnavn er tomt, opretter BrugerID med Fornavn og Efternavn" -Verbose

         # Generer nyt BrugerID indtil det er unikt
          # Brug et ekstra bogstav fra mellemnavn for hver genereringsomgang
          $omgang = 0 
          
          do
          {
              #Læg en til for hver omgang
              $omgang ++

              # Opret nyt BrugerID
              $BrugerID = $Fornavn.ToLower().Substring(0,$omgang) + $Efternavn.ToLower()
              # Læg en til omgang (et ekstra bogstav i Fornavn)
              }

          # Bliv ved indtil enten BrugerID er unikt eller alle bogstaver i Fornavn er brugt
          until (($ADbrugere -notcontains $BrugerID) -or ($omgang -eq ($Fornavn.Length)))

          # Kontroller om Fornavn er brugt og BrugerID ikke er unikt
          # Hvis det er tilfældet, afslut funktion
          if ($ADbrugere -contains $BrugerID)
          {
              
              Write-Error -Message "Der kunne ikke oprettes et unikt BrugerID. Opret manuelt et BrugerID, evt med tal" -Verbose
                            
          }

          # Opret navn ud fra Fornavn og Efternavn
          $Hele_Navn = $Fornavn + " " + $Efternavn

    }

                  # Kontroller om BrugerID findes i forvejen
                  # Kontroller om Mellemnavn er null eller tomt, i givent tilfælde, kør BrugerID oprettelse med Fornavn, Efternavn og Efternavn
                  if (($ADbrugere -contains $BrugerID) -and !([string]::IsNullOrEmpty($Mellemnavn)))
                  {
                     
                      Write-Verbose -Message "$BrugerID findes i forvejen" -Verbose
                      Write-Verbose -Message "Opretter BrugerID med Fornavn, Mellemnavn og Efternavn" -Verbose

                      # Generer nyt BrugerID indtil det er unikt
                      # Brug et ekstra bogstav fra mellemnavn for hver genereringsomgang
                      $omgang = 0
                      
                       do
                      {
                          #Læg en til for hver omgang
                          $omgang ++

                          # Opret nyt BrugerID
                          $BrugerID = $Fornavn.ToLower().Substring(0,1) + $Mellemnavn.ToLower().Substring(0,$omgang) + $Efternavn.ToLower()                                                  
                      }
                      # Bliv ved indtil enten BrugerID er unikt eller alle bogstaver i Mellemnavn er brugt
                      until (($ADbrugere -notcontains $BrugerID) -or ($omgang -eq ($Mellemnavn.Length)))

                      # Kontroller om Mellemnavnet er brugt og BrugerID ikke er unikt
                      # Hvis det er tilfældet, afslut funktion
                      if ($ADbrugere -contains $BrugerID)
                      {
                          
                          Write-Error -Message "Der kunne ikke oprettes et unikt BrugerID. Opret manuelt et BrugerID, evt med tal" -Verbose
                 
                      }

                      # Opret navn ud fra Fornavn, Mellemnavn og Efternavn
                      $Hele_Navn = $Fornavn + " " + $Mellemnavn + " " + $Efternavn
                  }

    $UPN = $BrugerID + "@specterops.dk"
    
    New-ADUser -Name $Hele_Navn -GivenName $Fornavn -Surname $Efternavn -SamAccountName $BrugerID -UserPrincipalName $UPN `
    -Path "OU=$Afdeling,OU=Enabled Users,OU=SpecterOps,DC=AD,DC=SPECTEROPS,DC=DK" -AccountPassword $kodeord_secure -Enabled $true `
    -Title $titel -EmailAddress $UPN
    

     # Skal fjernes til slut    
     if ($ADbrugere -contains $BrugerID)
     { Write-Verbose -Message "$BrugerID ikke unikt" -Verbose }

      if ($ADbrugere -notcontains $BrugerID)
      { Write-Verbose -Message "$BrugerID er unikt" -Verbose }
    }
    End
    {
    }
}
