$ErrorActionPreference = 'Stop'

$ProjectRoot = 'D:\OndeviceAI2_AXI4_Lite\20260622_AXI4_Lite_SoC'
$VivadoBat = 'D:\Xilinx\Vivado\2020.2\bin\vivado.bat'

$Peripherals = @(
    [pscustomobject]@{
        Name = 'GPIO'
        Key = 'axi_gpio_core'
        Tcl = 'sim/vivado/axi_gpio_core/run_axi_gpio_core_sim.tcl'
        Result = 'sim/vivado/axi_gpio_core/axi_gpio_core_sim_result.txt'
        Expected = 'PASS tests_passed=12 errors=0'
    },
    [pscustomobject]@{
        Name = 'FND'
        Key = 'axi_fnd_core'
        Tcl = 'sim/vivado/axi_fnd_core/run_axi_fnd_core_sim.tcl'
        Result = 'sim/vivado/axi_fnd_core/axi_fnd_core_sim_result.txt'
        Expected = 'PASS tests_passed=16 errors=0'
    },
    [pscustomobject]@{
        Name = 'Timer'
        Key = 'axi_timer_core'
        Tcl = 'sim/vivado/axi_timer_core/run_axi_timer_core_sim.tcl'
        Result = 'sim/vivado/axi_timer_core/axi_timer_core_sim_result.txt'
        Expected = 'PASS tests_passed=19 errors=0'
    },
    [pscustomobject]@{
        Name = 'Sensor'
        Key = 'axi_sensor_core'
        Tcl = 'sim/vivado/axi_sensor_core/run_axi_sensor_core_sim.tcl'
        Result = 'sim/vivado/axi_sensor_core/axi_sensor_core_sim_result.txt'
        Expected = 'PASS tests_passed=17 errors=0'
    },
    [pscustomobject]@{
        Name = 'SPI'
        Key = 'axi_spi_core'
        Tcl = 'sim/vivado/axi_spi_core/run_axi_spi_core_sim.tcl'
        Result = 'sim/vivado/axi_spi_core/axi_spi_core_sim_result.txt'
        Expected = 'PASS tests_passed=20 errors=0'
    },
    [pscustomobject]@{
        Name = 'I2C'
        Key = 'axi_i2c_core'
        Tcl = 'sim/vivado/axi_i2c_core/run_axi_i2c_core_sim.tcl'
        Result = 'sim/vivado/axi_i2c_core/axi_i2c_core_sim_result.txt'
        Expected = 'PASS tests_passed=23 errors=0'
    }
)

function Require-Path {
    param(
        [string]$Path,
        [string]$Description
    )
    if (-not (Test-Path -LiteralPath $Path)) {
        throw "$Description not found: $Path"
    }
}

try {
    Require-Path -Path $ProjectRoot -Description 'Canonical project root'
    Require-Path -Path $VivadoBat -Description 'Vivado 2020.2 executable'

    Set-Location -LiteralPath $ProjectRoot
    $startTime = Get-Date
    $results = New-Object System.Collections.Generic.List[object]

    Write-Host '============================================================'
    Write-Host 'Full custom peripheral Vivado simulation regression'
    Write-Host "Project root : $ProjectRoot"
    Write-Host "Vivado       : $VivadoBat"
    Write-Host "Start time   : $($startTime.ToString('yyyy-MM-dd HH:mm:ss zzz'))"
    Write-Host '============================================================'

    foreach ($peripheral in $Peripherals) {
        Write-Host ''
        Write-Host "---- [$($peripheral.Name)] $($peripheral.Key) ----"

        $tclPath = Join-Path $ProjectRoot ($peripheral.Tcl -replace '/', '\')
        $resultPath = Join-Path $ProjectRoot ($peripheral.Result -replace '/', '\')
        Require-Path -Path $tclPath -Description "$($peripheral.Key) simulation Tcl"

        $commandText = "$VivadoBat -mode batch -source $($peripheral.Tcl)"
        Write-Host "Command: $commandText"

        & $VivadoBat -mode batch -source $peripheral.Tcl
        $exitCode = $LASTEXITCODE
        if ($exitCode -ne 0) {
            throw "$($peripheral.Key) simulation command failed with exit code $exitCode"
        }

        Require-Path -Path $resultPath -Description "$($peripheral.Key) result file"
        $resultText = (Get-Content -LiteralPath $resultPath -Raw).Trim()
        Write-Host "Result: $resultText"

        if ($resultText -ne $peripheral.Expected) {
            throw "$($peripheral.Key) result mismatch. Expected '$($peripheral.Expected)' but found '$resultText'"
        }

        $results.Add([pscustomobject]@{
            Peripheral = $peripheral.Key
            Result = $resultText
            Status = 'PASS'
            ResultFile = $peripheral.Result
        })
    }

    $endTime = Get-Date
    Write-Host ''
    Write-Host '============================================================'
    Write-Host 'Full regression summary'
    Write-Host "End time : $($endTime.ToString('yyyy-MM-dd HH:mm:ss zzz'))"
    foreach ($result in $results) {
        Write-Host ("{0,-16} {1}" -f $result.Peripheral, $result.Result)
    }
    Write-Host 'Overall: PASS'
    Write-Host '============================================================'
    exit 0
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
