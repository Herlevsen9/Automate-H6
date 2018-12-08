
$Fornavn = "Hans"

$Mellemnavn = "Jens"

$Mellemnavn_tomt = ""

$Efternavn = "Petersen"



    
    # $ADbrugere = Get-aduser * | select SamAccountName
    $ADbrugere = @("hpetersen","phansen","hhansen","hjpetersen","hjenpetersen","hjepetersen","hjenspetersen","hapetersen","hanpetersen","hanspetersen")

$BrugerID = $Fornavn.ToLower().Substring(0,1) + $Efternavn.ToLower()

$Mellemnavn.Length



# Kontroller om bruger findes
if ($ADbrugere -notcontains $BrugerID)
 {
     Write-Verbose -Message "$BrugerID findes ikke. Opretter bruger" -Verbose
     
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
              
              Write-Verbose -Message "Der kunne ikke oprettes et unikt BrugerID" -Verbose
              Write-Verbose -Message "Opret manuelt et BrugerID, evt med tal" -Verbose
              Exit
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
                          
                          Write-Verbose -Message "Der kunne ikke oprettes et unikt $BrugerID" -Verbose
                          Write-Verbose -Message "Opret manuelt et $BrugerID, evt med tal" -Verbose
                          # Exit
                      }

                      # Opret navn ud fra Fornavn, Mellemnavn og Efternavn
                      $Hele_Navn = $Fornavn + " " + $Mellemnavn + " " + $Efternavn
                  }

     
    $UPN = $BrugerID + "@lme.dk"
    $Hele_Navn
    $BrugerID

    <# Tilføj underliggende til produktion
    New-ADUser -Name $Hele_Navn -GivenName $Fornavn -Surname $Efternavn -SamAccountName $BrugerID -UserPrincipalName $UPN `
    -Path "OU=$Afdeling,OU=Enabled Users,OU=User Accounts,DC=AD,DC=LME,DC=DK" -AccountPassword $kodeord -Enabled $true `
    -Title $titel -EmailAddress $UPN
    #>

     # Skal fjernes til slut    
     if ($ADbrugere -contains $BrugerID)
     { Write-Verbose -Message "$BrugerID ikke unikt" -Verbose }

      if ($ADbrugere -notcontains $BrugerID)
      { Write-Verbose -Message "$BrugerID er unikt" -Verbose }
