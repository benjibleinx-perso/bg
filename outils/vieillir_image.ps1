# Donne a une image livree le grain d'un jeu de l'epoque.
#
#     .\outils\vieillir_image.ps1 -Source livraisons/images/ecran-titre-fond.jpg `
#                                 -Dest game/assets/images/ecran_titre.png `
#                                 -Largeur 320 -Hauteur 240 -Niveaux 16 -Desaturation 0.18
#
# CE FICHIER EST EN ASCII STRICT, sans le moindre caractere accentue.
# PowerShell 5.1 - celui de Windows, celui que lance JOUER.bat - lit un .ps1 en
# CP-1252 quand il n'a pas de marque d'octets. Un tiret cadratin y devient trois
# caracteres dont un guillemet, qui ferme la chaine et casse tout le fichier a
# partir de la.
#
# POURQUOI CET OUTIL EXISTE. Guillaume a livre un visuel d'ecran-titre le
# 27/08/2026 : une image photographique, tres fine, tres recente. Posee telle
# quelle derriere un jeu low-poly, elle promet autre chose que ce qui suit -
# "l'image fait trop recent" (Benjamin, 28/08/2026). Le probleme n'est pas
# l'image, c'est l'ECART entre elle et le reste.
#
# TROIS GESTES, ET AUCUN N'EST UN FILTRE ARTISTIQUE. Ce sont les trois
# contraintes reelles d'une console de 2001 :
#
#   la DEFINITION - l'image est reduite puis reagrandie en plus proche voisin,
#     donc ses pixels redeviennent carres et visibles ;
#   la PALETTE - chaque canal est ramene a quelques niveaux, avec un tramage
#     ordonne de Bayer. Sans le tramage, un ciel en degrade devient un escalier
#     d'aplats ; avec, il garde sa continuite en montrant sa trame ;
#   la SATURATION - la serie "vieillit ses couleurs plutot que de les rendre
#     eclatantes" (docs/20), et une photo moderne est plus saturee que tout ce
#     que le jeu affiche.
#
# ON REAGRANDIT ICI, ET PAS A L'AFFICHAGE. Une texture laissee en 320x240 serait
# etiree par le moteur avec le filtrage du moment : lineaire, elle redeviendrait
# floue au lieu de rester pixelisee. Le fichier produit fait donc toujours la
# taille du rendu interne, avec de gros pixels dedans.

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$Source,
    [Parameter(Mandatory = $true)][string]$Dest,
    [int]$Largeur = 320,
    [int]$Hauteur = 240,
    [int]$Niveaux = 16,
    [double]$Desaturation = 0.18,
    [int]$SortieLargeur = 512,
    [int]$SortieHauteur = 384
)

$ErrorActionPreference = 'Stop'
$Racine = Split-Path -Parent $PSScriptRoot
Set-Location $Racine
Add-Type -AssemblyName System.Drawing

if ($Niveaux -lt 2) { Write-Host "Niveaux doit valoir au moins 2." -ForegroundColor Red; exit 1 }

# La matrice de Bayer 4x4 : le tramage ordonne de l'epoque, et le seul qui se
# calcule sans memoire d'un pixel a l'autre.
$bayer = @(0,8,2,10, 12,4,14,6, 3,11,1,9, 15,7,13,5)

$img = [System.Drawing.Image]::FromFile((Resolve-Path $Source))

# RECADRAGE AU FORMAT DE SORTIE AVANT REDUCTION. Le visuel livre fait
# 1366 x 1024, qui n'est pas tout a fait du 4:3 : l'etirer de 0,4 % se voit sur
# un horizon.
$rapport = $SortieLargeur / [double]$SortieHauteur
$cibleL = [int][math]::Round($img.Height * $rapport)
$cibleH = $img.Height
if ($cibleL -gt $img.Width) {
    $cibleL = $img.Width
    $cibleH = [int][math]::Round($img.Width / $rapport)
}
$crop = New-Object System.Drawing.Rectangle(
    [int](($img.Width - $cibleL) / 2), [int](($img.Height - $cibleH) / 2), $cibleL, $cibleH)

$petit = New-Object System.Drawing.Bitmap($Largeur, $Hauteur)
$g = [System.Drawing.Graphics]::FromImage($petit)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g.DrawImage($img, (New-Object System.Drawing.Rectangle(0, 0, $Largeur, $Hauteur)),
             $crop, [System.Drawing.GraphicsUnit]::Pixel)
$g.Dispose(); $img.Dispose()

$zone = New-Object System.Drawing.Rectangle(0, 0, $Largeur, $Hauteur)
$d = $petit.LockBits($zone, [System.Drawing.Imaging.ImageLockMode]::ReadWrite,
                     [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$oct = New-Object byte[] ($d.Stride * $Hauteur)
[System.Runtime.InteropServices.Marshal]::Copy($d.Scan0, $oct, 0, $oct.Length)
$pas = 255.0 / ($Niveaux - 1)
for ($y = 0; $y -lt $Hauteur; $y++) {
    for ($x = 0; $x -lt $Largeur; $x++) {
        $i = $y * $d.Stride + $x * 4
        $seuil = ($bayer[($y % 4) * 4 + ($x % 4)] / 16.0 - 0.5) * $pas
        # La luminance perceptive, pas la moyenne des canaux : desaturer vers la
        # moyenne verdit les rouges et assombrit les jaunes.
        $gris = 0.299 * $oct[$i + 2] + 0.587 * $oct[$i + 1] + 0.114 * $oct[$i]
        for ($c = 0; $c -lt 3; $c++) {
            $v = $oct[$i + $c] * (1.0 - $Desaturation) + $gris * $Desaturation + $seuil
            $q = [math]::Round($v / $pas) * $pas
            $oct[$i + $c] = [byte][math]::Max(0, [math]::Min(255, $q))
        }
    }
}
[System.Runtime.InteropServices.Marshal]::Copy($oct, 0, $d.Scan0, $oct.Length)
$petit.UnlockBits($d)

$grand = New-Object System.Drawing.Bitmap($SortieLargeur, $SortieHauteur)
$g2 = [System.Drawing.Graphics]::FromImage($grand)
$g2.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$g2.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
$g2.DrawImage($petit, 0, 0, $SortieLargeur, $SortieHauteur)
$g2.Dispose(); $petit.Dispose()

New-Item -ItemType Directory -Force (Split-Path $Dest) | Out-Null
$grand.Save($Dest, [System.Drawing.Imaging.ImageFormat]::Png)
$grand.Dispose()

# ON RELIT LE FICHIER ECRIT, jamais l'intention : un redimensionnement qui
# echoue en silence laisserait une image a la mauvaise taille dans le jeu.
$relu = [System.Drawing.Image]::FromFile((Resolve-Path $Dest))
$reluL = $relu.Width; $reluH = $relu.Height
$relu.Dispose()
if ($reluL -ne $SortieLargeur -or $reluH -ne $SortieHauteur) {
    Write-Host "ECRIT FAUX : $reluL x $reluH au lieu de $SortieLargeur x $SortieHauteur" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "grain     $Largeur x $Hauteur, $Niveaux niveaux par canal, desaturation $Desaturation" -ForegroundColor Gray
Write-Host "produit   $Dest  ($reluL x $reluH)" -ForegroundColor Green
