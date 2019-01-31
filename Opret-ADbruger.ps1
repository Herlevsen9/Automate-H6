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
        $Kodeord="K0deord!",

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
    $BrugerID = $Fornavn.ToLower().Substring(0,1) + $Efternavn.ToLower()
    
    # $ADbrugere = Get-aduser * | select SamAccountName
    $ADbrugere = @("hpetersen","phansen","hhansen","hjpetersen")

    # Kontroller om BrugerID findes i forvejen
    $Findes_bruger = $ADbrugere -match $BrugerID

if ($Findes_bruger -ne $BrugerID)
 {
     Write-Verbose -Message "$BrugerID findes ikke. Opretter bruger" -Verbose
     
 }

 if ($Findes_bruger -eq $BrugerID)
 {
     Write-Verbose -Message "$BrugerID findes i forvejen" -Verbose

     # Kontroller om der er et Mellemnavn, i givent tilfælde, kør BrugerID oprettelse med efternavn
     if ($Mellemnavn -ne $null)
    {
    
     Write-Verbose -Message "Opretter nyt BrugerID med Fornavn, Mellemnavn og Efternavn" -Verbose
     # Slet hvad der tidligere stod i BrugerID
     $BrugerID = $null

     # Opret BrugerID med første bogstav af fornavn + første bogstav af mellemnavn + efternavn
     $BrugerID = $Fornavn.ToLower().Substring(0,1) + $Mellemnavn.ToLower().Substring(0,1) + $Efternavn.ToLower()

         # Kontroller for 3. gang om BrugerID findes
         if (($ADbrugere -match $BrugerID) -eq $BrugerID)
          {
          Write-Verbose -Message "$BrugerID findes i forvejen" -Verbose
          Write-Verbose -Message "Opretter nyt BrugerID med Fornavn, Mellemnavn(2 bogstaver) og Efternavn" -Verbose
         
          # Slet hvad der tidligere stod i BrugerID
          $BrugerID = $null
         
          # Opret BrugerID med første bogstav af fornavn + 2 første bogstaver af mellemnavn + efternavn
          $BrugerID = $Fornavn.ToLower().Substring(0,1) + $Mellemnavn.Substring(0,2)  + $Efternavn.ToLower()
          }
    }

             if ($Mellemnavn -eq $null)
             {
                                
                Write-Verbose -Message "Opretter nyt BrugerID med Fornavn (2 bogstaver) og Efternavn" -Verbose
                # Slet hvad der tidligere stod i BrugerID
                $BrugerID = $null
              
                # Opret BrugerID med 2 første bogstaver af fornavn  + efternavn
                $BrugerID = $Fornavn.ToLower().Substring(0,2) + $Efternavn.ToLower()

                  if (($ADbrugere -match $BrugerID) -eq $BrugerID)
                  {
                  Write-Verbose -Message "$BrugerID findes i forvejen" -Verbose
                  Write-Verbose -Message "Opretter nyt BrugerID med Fornavn (3 bogstaver) og Efternavn" -Verbose 
                 
                  # Opret BrugerID med 2 første bogstaver af fornavn  + efternavn
                  $BrugerID = $Fornavn.ToLower().Substring(0,3) + $Efternavn.ToLower()
                  }  
             }
 }

 

    }
    Process
    {
    # Opret variabel for hele navnet
    if ($Mellemnavn -eq $null)
    {
        $Hele_Navn = $Fornavn + " " + $Efternavn
    }
    
    if ($Mellemnavn -ne $null)
    {
        $Hele_Navn = $Fornavn + " " + $Mellemnavn + " " + $Efternavn
    }
    
    $UPN = $BrugerID + "@lme.dk"
    $Hele_Navn
    $BrugerID

    <# Tilføj underliggende til produktion
    New-ADUser -Name $Hele_Navn -GivenName $Fornavn -Surname $Efternavn -SamAccountName $BrugerID -UserPrincipalName $UPN `
    -Path "OU=$Afdeling,OU=Enabled Users,OU=SpecterOps,DC=AD,DC=LME,DC=DK" -AccountPassword $kodeord -Enabled $true `
    -Title $titel -EmailAddress $UPN
    #>
    }
    End
    {
    }
}

# Prøv en anden Version/Branch med en while-do
# Hvor Substring øges med en hver gang, så længe den holder sig inden fornavn/mellemnavn's længde
# .Substring(0,$a+1)
# $BrugerID = $Fornavn.ToLower().Substring(0,1) + $Mellemnavn.ToLower().Substring(0,1) + $Efternavn.ToLower()
