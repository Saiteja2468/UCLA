function Get-PrimeFactors {
    param($number)
    $factors = @()
    $divisor = 2
    while ($number -gt 1) {
        while ($number % $divisor -eq 0) {
            $factors += $divisor
            $number /= $divisor
        }
        $divisor++
    }
    return $factors
}

# API URL
$apiUrl = "https://datausa.io/api/data?drilldowns=State&measures=Population"

# Call the API
$response = Invoke-WebRequest -Uri $apiUrl

# Convert JSON data to a PowerShell object
$jsonData = $response.Content | ConvertFrom-Json

# Extract the data array
$dataArray = $jsonData.data

# Group data by state
$groupedData = $dataArray | Group-Object -Property State

# Create an array to store formatted objects
$formattedData = @()

# Iterate through each state's data
foreach ($group in $groupedData) {
    $stateData = $group.Group
    $stateDataCount = $stateData.Count

    for ($i = 1; $i -lt $stateDataCount; $i++) {
        $previousYearPopulation = $stateData[$i - 1].Population
        $currentYearPopulation = $stateData[$i].Population
        $populationChange = $currentYearPopulation - $previousYearPopulation
        $populationChangePercentage = ($populationChange / $previousYearPopulation) * 100

        $formattedData += [PSCustomObject]@{
            State                       = $stateData[$i].State
            Year                        = $stateData[$i].Year
            Population                  = $stateData[$i].Population
            PopulationChange            = "{0} ({1:P2})" -f $populationChange, ($populationChangePercentage / 100)
            PrimeFactorization          = if ($stateData[$i].Year -eq "2019") { (Get-PrimeFactors $currentYearPopulation) -join ";" } else { "" }
        }
    }
}
# Export the data to a CSV file
$formattedData | Export-Csv -Path "c:\Final-Output.csv" -NoTypeInformation
