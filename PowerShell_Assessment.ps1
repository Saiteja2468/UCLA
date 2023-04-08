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

# Import the CSV file
$state = Import-Csv -Path "C:\test\Input.csv"

# Loop through each row and split the first column into separate values
foreach ($row in $state) {
    $values = $row.Column1.Split(",")
    $row.State = $values[0].Trim()
    $row.Year = $values[1].Trim()
    $row.Population = $values[2].Trim()
}

# Export the updated data to a new CSV file
$data | Export-Csv -Path "C:\test\Output1.csv" -NoTypeInformation





# Read the CSV file with years
$pop = Import-Csv -Path "C:\test\Output1.csv" | Select-Object -ExpandProperty Population

# Create an array to store the percentage differences
$results = @()

# Loop through each pair of consecutive years
for ($i = 1; $i -lt $pop.Count; $i++) {
    $prevPopulation = $pop[$i - 1]
    $currPopulation = $pop[$i]
    $percentageDiff = [math]::Round((($currPopulation - $prevPopulation) / $prevPopulation) * 100, 2)
    $results += [PSCustomObject]@{
        "Year Pair" = "$prevPopulation-$currPopulation"
        "Percentage Difference" = "$percentageDiff%"

    }
}

# Export the percentage differences to a new CSV file
$results | Export-Csv -Path "C:\test\Output2.csv" -NoTypeInformation

# Set the path to the source CSV file
$sourceCsv = "C:\test\Output1.csv"

# Set the path to the destination CSV file
$destinationCsv = "C:\test\Output2.csv"


# Import data from the source CSV file
$data = Import-Csv $sourceCsv

# Copy the data to the destination CSV file
$data | Export-Csv $destinationCsv -NoTypeInformation

# Import data from the destination CSV file
$result = Import-Csv $destinationCsv

# Export the result to the result CSV file
$result | Export-Csv -Path "C:\test\final_result.csv" -NoTypeInformation
