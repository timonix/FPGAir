$CurrentDir = $PSScriptRoot
$tempDir = [System.IO.Path]::GetTempPath()



docker run -it --rm `
    -v "$CurrentDir\..\:/formal" `
    -v "$CurrentDir\..\..\packages:/formal/packages" `
    -v "$tempDir\:/tmp/" `
    hdlc/formal bash -c "cd formal/formal/ && sby --yosys 'yosys -m ghdl' -d /tmp/uCore_bmc -f uCore_T0.sby"


$source = "$tempDir\uCore_bmc\engine_0\trace.vcd"
$destination = "$CurrentDir\trace.vcd"

if (Test-Path $destination) {
    rm $destination
}

if (Test-Path $source) {
    cp $source $destination
}

Write-Host "The system temporary directory is: $tempDir"