# Fabrique les pas d'INTERIEUR a partir des pas de beton.
#
#     .\outils\pas_interieur.ps1
#
# CE FICHIER EST EN ASCII STRICT : PowerShell 5.1 lit un .ps1 en CP-1252 quand
# il n'a pas de marque d'octets, et un accent y casse tout le fichier.
#
# POURQUOI FABRIQUER PLUTOT QUE GENERER.
#
# Il n'existait qu'UN son de pas interieur, step_indoors01.wav, et il sortait a
# -1,0 dB - presque sature, et 4,7 dB au-dessus des pas exterieurs. Marcher dans
# la maison, le camping-car ou le bureau de Tuco, c'etait donc le meme claquement
# trop fort a chaque pas. C'est ce que Benjamin a entendu.
#
# Un bruitage generatif aurait coute des credits et un abonnement de plus, pour
# un son que l'on a deja : un pas d'interieur EST un pas de beton dans une piece.
# Ce qui change, c'est ce que la piece en fait - moins d'aigus parce qu'il y a
# des tapis, des meubles et du contreplaque, une queue plus courte parce qu'il
# n'y a pas de rue pour porter le son, et moins fort parce qu'on ne pose pas le
# pied de la meme facon chez soi.
#
# On garde donc les MEMES prises, filtrees. Elles restent coherentes entre elles
# et avec l'exterieur, ce qu'un lot achete ailleurs n'aurait pas garanti.

[CmdletBinding()]
param(
    # Combien de variantes fabriquer. Six suffisent : le tirage evite deja la
    # repetition immediate, donc l'oreille ne boucle pas.
    [int]$Combien = 6
)

$ErrorActionPreference = 'Stop'
$Racine = Split-Path -Parent $PSScriptRoot
$Sons = Join-Path $Racine 'game\assets\sons\pas'

$FFmpeg = Get-Item "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\Gyan.FFmpeg_*\*\bin\ffmpeg.exe" -ErrorAction SilentlyContinue |
          Select-Object -First 1
if (-not $FFmpeg) {
    $c = Get-Command ffmpeg -ErrorAction SilentlyContinue
    if ($c) { $FFmpeg = Get-Item $c.Source }
}
if (-not $FFmpeg) { throw "ffmpeg introuvable. winget install --id Gyan.FFmpeg -e" }
$FFprobe = Join-Path (Split-Path $FFmpeg -Parent) 'ffprobe.exe'

Write-Host ""
Write-Host "$Combien pas d'interieur, tires des pas de beton" -ForegroundColor Cyan

$faits = 0
for ($i = 1; $i -le $Combien; $i++) {
    $source = Join-Path $Sons ("pas_beton_{0:d2}.wav" -f $i)
    if (-not (Test-Path $source)) {
        Write-Host "  ! $source introuvable" -ForegroundColor Red
        continue
    }
    $cible = Join-Path $Sons ("pas_interieur_{0:d2}.wav" -f $i)

    # lowpass 2600 Hz   une piece meublee mange les aigus du talon
    # highpass 90 Hz    on retire le grondement que le sol de rue portait
    # atempo 1.06       un pas d'interieur est un peu plus sec
    # loudnorm I=-22    plus bas que l'exterieur (-18), volontairement
    & $FFmpeg -y -hide_banner -loglevel error -i $source `
        -af "highpass=f=90,lowpass=f=2600,atempo=1.06,loudnorm=I=-22:TP=-3" `
        -ac 1 -ar 22050 -c:a pcm_s16le $cible
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ! ffmpeg a refuse $source" -ForegroundColor Red
        continue
    }

    # ON MESURE LE FICHIER PRODUIT. ffmpeg sort en code 0 sur une entree
    # tronquee et ecrit un WAV valide de zero seconde : le jeu le jouerait sans
    # rien emettre, ce qui se confondrait avec un pas manquant.
    $duree = [double](& $FFprobe -v error -show_entries format=duration -of csv=p=0 $cible)

    # LA CRETE SE LIT DANS UN APPEL ISOLE. ffmpeg ecrit toute son analyse sur
    # la sortie d'ERREUR, meme quand tout va bien ; avec ErrorActionPreference
    # a Stop, PowerShell 5.1 en fait une erreur bloquante et le script s'arrete
    # sur un succes. On abaisse la garde le temps de l'appel, et on ne juge que
    # ce qu'on a lu.
    $crete = "?"
    $avant = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $sortie = & $FFmpeg -hide_banner -i $cible -af volumedetect -f null NUL 2>&1 |
                  ForEach-Object { "$_" }
        $ligne = $sortie | Select-String "max_volume" | Select-Object -First 1
        if ($ligne) { $crete = ($ligne.ToString() -replace '.*max_volume:\s*', '') }
    } finally { $ErrorActionPreference = $avant }
    if ($duree -lt 0.05) {
        Write-Host ("  ! {0} : {1:n2} s, c'est vide" -f (Split-Path $cible -Leaf), $duree) -ForegroundColor Red
        Remove-Item $cible -Force -ErrorAction SilentlyContinue
        continue
    }
    Write-Host ("  {0,-24} {1,5:n2} s   crete {2}" -f (Split-Path $cible -Leaf), $duree, $crete) -ForegroundColor Gray
    $faits++
}

Write-Host ""
Write-Host "$faits pas d'interieur ecrits" -ForegroundColor Green
Write-Host "Les declarer dans game\donnees\sons.json, entree 'pas_interieur'." -ForegroundColor Gray
