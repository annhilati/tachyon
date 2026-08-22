# Dieses Skript kompiliert unseren Dummy-GLSL-Shader zu einer SPIR-V Binärdatei (.spv)
# Es setzt voraus, dass das Vulkan SDK (bzw. glslc.exe) installiert und im PATH ist.

$fragmentShader = "post_desaturate.frag"
$outputSpv = "post_desaturate.spv"
$vertexShader = "screenquad.vert"
$vertexSpv = "screenquad.spv"

Write-Host "Kompiliere $fragmentShader zu SPIR-V..." -ForegroundColor Cyan
Write-Host "Kompiliere $vertexShader zu SPIR-V..." -ForegroundColor Cyan

& "C:\VulkanSDK\1.4.357.0\Bin\glslc.exe"  $fragmentShader -o $outputSpv
& "C:\VulkanSDK\1.4.357.0\Bin\glslc.exe"  $vertexShader -o $vertexSpv

if ($LASTEXITCODE -eq 0) {
    Write-Host "Erfolg! SPIR-V Dateien erstellt." -ForegroundColor Green
} else {
    Write-Host "Fehler beim Kompilieren des Shaders." -ForegroundColor Red
}