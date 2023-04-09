#Import-Module -Name PrimeFactor

# Set API endpoint URL
$url = "https://datausa.io/api/data?drilldowns=State&measures=Population"



# Make API request and store response in variable
$response = Invoke-RestMethod -Uri $url -Headers $headers -Method GET

# Extract state and population data from response
$data = $response.data | Select-Object -Property State, Year, Population

# Group data by state
$groupedData = $data | Group-Object -Property State, Year, Population

# Create an array to store the results
$results = @()

# Loop through each state group
foreach ($group in $groupedData) {
    # Get the state name and population data for the group
    $state = $group.Name
    $populations = $group.Group | Select-Object -Property Year, Population

    # Calculate year-over-year population change and percentage change
    $changes = $populations | ForEach-Object {
        $prevPopulation = $_.Population
        $prevYear = $_.Year
        $_ | ForEach-Object {
            $currYear = $_.Year
            $currPopulation = $_.Population
            $rawChange = $currPopulation - $prevPopulation
            $percentageChange = [math]::Round(($rawChange / $prevPopulation) * 100, 2)
            $prevPopulation = $currPopulation
            $prevYear = $currYear
            [PSCustomObject]@{
                "Year" = "$prevYear-$currYear"
                "Population Change" = "$rawChange ($percentageChange%)"
            }
        }
    }

   
    # Add the results to the array
    $results += [PSCustomObject]@{
        "State" = $state
        

        
    }
}

$data | Export-Csv -Path "C:\test\Output1.csv" -NoTypeInformation

# Import the CSV data
$csvData = Import-Csv -Path "C:\test\output1.csv"

# Group the data by state
$groupedData = $csvData | Group-Object -Property State

# Define the output file path
$outputFile = "output.csv"

# Initialize the results array
$results = @()

# Define the prime factor functions (same as before)...

# Iterate through the grouped data
foreach ($stateData in $groupedData) {
    $state = $stateData.Name
    $populationData = $stateData.Group | Sort-Object -Property Year

    $popChanges = @()

    for ($i = 1; $i -lt $populationData.Count; $i++) {
        $previousYear = $populationData[$i - 1]
        $currentYear = $populationData[$i]

        $change = $currentYear.Population - $previousYear.Population
        $popChanges += "$($previousYear.Year)-$($currentYear.Year): $change"
    }

    $finalYearPopulation = $populationData[-1].Population
    $primeFactors = Get-PrimeFactors -number $finalYearPopulation

    # Create a custom object to store the results
    $result = [PSCustomObject]@{
        State                    = $state
        PopulationChanges        = $popChanges -join '; '
        FinalYearPopulation      = $finalYearPopulation
        FinalYearPrimeFactors    = $primeFactors -join ', '
    }

    # Add the result object to the results array
    $results += $result
}

# Export the results array to a CSV file
$results | Export-Csv -Path C:\test\output2.csv  -NoTypeInformation
