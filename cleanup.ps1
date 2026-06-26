# Delete azure rg created for this exercise

if (-not $env:RESOURCE_GROUP) {
    Write-Host "Please set evnvironment variable 'RESOURCE_GROUP' to run clean up!"
}
else {
    Write-Host " Remove Resource Group '$env:RESOURCE_GROUP' and all accompanied resources?"
    Write-Host "[0] no"
    Write-Host "[1] yes"
    Write-Host ""

    $choice = Read-Host "Please select an option (0 or 1)"

    switch ($choice) {
        "0" {
            Write-Host "Will not remove resource group '$env:RESOURCE_GROUP'"
        }
        "1" {
            Write-Host "Removing resource group '$env:RESOURCE_GROUP' and resources...."
            $result = az group delete --name $env:RESOURCE_GROUP --no-wait --yes
            Write-Host $result

            Write-Host ""
            Write-Host "Clean up finished!"
        }
        default {
            Write-Host "Invalid option. Please select 1-4."
            Read-Host "Press Enter to continue"
        }
    }
}
