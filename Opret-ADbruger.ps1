# Opret AD bruger funktion, hvor eneste input er Fornavn og Efternavn

# .Example
# Opret-ADbruger -Fornavn [String/Mandatory] -Mellemnavn {String} -Efternavn [String/Mandatory]

# Deklarer arguments
[String]=Fornavn
[Mandatory]
[String]=Mellemnavn
[String]=Efternavn
[Mandatory]

# Opret AD brugerID
? skal det være efternavn + første bogstav af Fornavn
# Eller
? skal det være første bogstav af Fornavn + efternavn
$brugerID = split (første bogstav af fornavn) + $Efternavn

# Kontroller om brugerID eksistere i allerede
$findes = Get-ADuser -identity $brugerID

# Hvis brugerID eksistere allerede, opret et nyt
if ($findes $true) {
$brugerID = $null

# Hvis Mellemnavn er tomt, brug da de 2 første bogstaver af fornavn
if ($Mellemnavn $null) {

    $brugerID = split (2 første bogstaver af Fornavn) + $Efternavn
    
        # Opret Displayname
        $Displayname = $Fornavn + " " + $Efternavn
}

# Hvis Mellemnavn ikke er tomt, opret da et brugerID med Mellemnavn
if !($Mellemnavn $null) {

    $brugerID = split (første bogstav af $Fornavn) + (første bogstav af $Mellemnavn) +Efternavn

    # Opret Displayname med Mellemnavn
    $Displayname = $Fornavn + " " + $Mellemnavn + " " + $Efternavn
}

}

# Opret resterende arguments til ADbruger
$mail = $brugerID + '@e219.lme.dk'

