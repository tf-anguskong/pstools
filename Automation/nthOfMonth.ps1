function Get-nthOfMonth {
    param (
        [Parameter(Mandatory)][int]$nthOfMonth,
        [Parameter(Mandatory)][string]$DayOfWeek
    )
    $Date = (Get-Date).Date

    $DaysInMonth = [DateTime]::DaysInMonth($Date.Year, $Date.Month)
    $DaysOfWeek = @()

    if ($DayOfWeek -eq "Monday") {
        1..$DaysInMonth | ForEach-Object {
            $object = (Get-Date -Day $_).Date  | Where-Object {$_.DayOfWeek -eq "Monday"}
            $DaysOfWeek += $object
        }
    }

    if ($DayOfWeek -eq "Tuesday") {
        1..$DaysInMonth | ForEach-Object {
            $object = (Get-Date -Day $_).Date | Where-Object {$_.DayOfWeek -eq "Tuesday"}
            $DaysOfWeek += $object
        }
    }

    if ($DayOfWeek -eq "Wednesday") {
        1..$DaysInMonth | ForEach-Object {
            $object = (Get-Date -Day $_).Date  | Where-Object {$_.DayOfWeek -eq "Wednesday"}
            $DaysOfWeek += $object
        }
    }

    if ($DayOfWeek -eq "Thursday") {
        1..$DaysInMonth | ForEach-Object {
            $object = (Get-Date -Day $_).Date  | Where-Object {$_.DayOfWeek -eq "Thursday"}
            $DaysOfWeek += $object
        }
    }

    if ($DayOfWeek -eq "Friday") {
        1..$DaysInMonth | ForEach-Object {
            $object = (Get-Date -Day $_).Date  | Where-Object {$_.DayOfWeek -eq "Friday"}
            $DaysOfWeek += $object
        }
    }

    if ($DayOfWeek -eq "Saturday") {
        1..$DaysInMonth | ForEach-Object {
            $object = (Get-Date -Day $_).Date  | Where-Object {$_.DayOfWeek -eq "Saturday"}
            $DaysOfWeek += $object
        }
    }

    if ($DayOfWeek -eq "Sunday") {
        1..$DaysInMonth | ForEach-Object {
            $object = (Get-Date -Day $_).Date | Where-Object {$_.DayOfWeek -eq "Sunday"}
            $DaysOfWeek += $object
        }
    }

    return $DaysOfWeek[($nthOfMonth-1)]
}