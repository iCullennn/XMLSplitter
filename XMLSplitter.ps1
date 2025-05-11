param(
    [Parameter(Mandatory = $true)]
    [string]$Path
)

[xml]$xml = Get-Content -Path $Path

$header = $xml.statutorydocuments.header
$spooler = $xml.statutorydocuments.spoolerdefinition
$documents = $xml.statutorydocuments.statutorydocument

# Split into two halves
$midIndex = [math]::Ceiling($documents.Count / 2) # Finds the middle rounded up 

$firstHalf = $documents[0..($midIndex - 1)]
$secondHalf = $documents[$midIndex..($documents.Count - 1)]

# Function to build new XML document
function Create-NewXmlFile {
    param (
        [System.Xml.XmlElement]$header,
        [System.Xml.XmlElement]$spooler,
        [System.Collections.IEnumerable]$docGroup,
        [string]$outputPath
    )

    $newXml = New-Object System.Xml.XmlDocument
    $decl = $newXml.CreateXmlDeclaration("1.0", "UTF-8", $null)
    $newXml.AppendChild($decl) | Out-Null

    $root = $newXml.CreateElement("statutorydocuments")
    $newXml.AppendChild($root) | Out-Null

    $importedHeader = $newXml.ImportNode($header, $true)
    $importedSpooler = $newXml.ImportNode($spooler, $true)

    $root.AppendChild($importedHeader) | Out-Null
    $root.AppendChild($importedSpooler) | Out-Null

    foreach ($doc in $docGroup) {
        $importedDoc = $newXml.ImportNode($doc, $true)
        $root.AppendChild($importedDoc) | Out-Null
    }

    $newXml.Save($outputPath)
}

# Save the two files
$outputDir = Split-Path -Path $Path -Parent
# $outputName = Split-Path -Path -Leaf
Create-NewXmlFile -header $header -spooler $spooler -docGroup $firstHalf -outputPath "$outputDir\Split1.xml"
Create-NewXmlFile -header $header -spooler $spooler -docGroup $secondHalf -outputPath "$outputDir\Split2.xml"
