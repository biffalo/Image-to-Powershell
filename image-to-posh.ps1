Param (
    # Validate that the provided path is an existing file
    [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
    [string]$ImageFile,

    # Allow only two specific modes of fitting the image to the console: 'FillTerminal' or 'Fit'
    [ValidateSet('FillTerminal', 'Fit')]
    [string]$Fit = 'Fit'
)

# Load System.Drawing to work with images (for PowerShell 5.1)
# Note: For newer PowerShell versions (Core), System.Drawing might not be fully supported by default.
$null = [Reflection.Assembly]::LoadWithPartialName('System.Drawing')

# Load the source image from the provided file path
$SrcImg = [System.Drawing.Image]::FromFile($ImageFile)

# Retrieve the current console window size
$windowWidth  = $Host.UI.RawUI.WindowSize.Width
$windowHeight = $Host.UI.RawUI.WindowSize.Height

switch ($Fit) {
    'FillTerminal' {
        # In 'FillTerminal' mode, we scale the image to the full console size directly.
        # Note: Multiplying height by 1 is unnecessary, but kept for clarity if user intended a factor.
        $newWidth  = [int]$windowWidth
        $newHeight = [int]$windowHeight
        $SrcImg = $SrcImg.GetThumbnailImage($newWidth, $newHeight, $null, [intptr]::Zero)
    }

    'Fit' {
        # In 'Fit' mode, we try to fit the image while maintaining aspect ratio.
        # First, calculate the image and console aspect ratios.
        [float]$imgRatio = $SrcImg.Width / $SrcImg.Height
        [float]$conRatio = $windowWidth / ($windowHeight * 1.0)

        # Determine whether the image's shape or the console's shape dictates final scaling
        # We compare how "far" each ratio is from being square (ratio of 1).
        # The idea: 
        #   If the image ratio deviates more strongly from 1 than the console ratio does,
        #   the image ratio "dominates" and we scale to fit the image ratio first.
        #
        # Otherwise, if the console ratio deviates more, we scale to fit the console ratio.
        
        if ([Math]::Abs(1 - $imgRatio) -gt [Math]::Abs(1 - $conRatio)) {
            # Image ratio dominates
            if ($imgRatio -lt 1) {
                # Image is "taller" relative to width (portrait-like)
                $newHeight = [int]$windowHeight
                $newWidth  = [int]($newHeight * $imgRatio)
            } else {
                # Image is "wider" relative to height (landscape-like)
                $newWidth  = [int]$windowWidth
                $newHeight = [int]($newWidth / $imgRatio)
            }
        } else {
            # Console ratio dominates
            if ($conRatio -lt 1) {
                # Console is relatively taller, so we base on width
                $newWidth  = [int]$windowWidth
                $newHeight = [int]($newWidth / $imgRatio)
            } else {
                # Console is relatively wider, so we base on height
                $newHeight = [int]$windowHeight
                $newWidth  = [int]($newHeight * $imgRatio)
            }
        }

        # Create a thumbnail (scaled) version of the image
        $SrcImg = $SrcImg.GetThumbnailImage($newWidth, $newHeight, $null, [intptr]::Zero)
    }
}

# Now we iterate over the scaled image to print it line by line in the console.
# We use "▄" (U+2584) as the character, which effectively lets us draw two pixels (top and bottom) per character cell:
# The top pixel in the background color and the bottom pixel in the foreground color.

for ($y = 0; $y -lt $SrcImg.Height; $y += 2) {
    for ($x = 0; $x -lt $SrcImg.Width; $x++) {
        # Get the color of the top pixel
        $back = $SrcImg.GetPixel($x, $y)

        # Determine the foreground color if we have another row below
        if ($y -ge $SrcImg.Height - 1) {
            # No pixel below, so no foreground color escape sequence
            $foreVT = ""
        } else {
            $fore = $SrcImg.GetPixel($x, $y + 1)
            $foreVT = "$([char]27)[38;2;$($fore.R);$($fore.G);$($fore.B)m"
        }

        # Construct the background color escape sequence
        $backVT = "$([char]27)[48;2;$($back.R);$($back.G);$($back.B)m"

        # Print the character with specified background and foreground, then reset formatting after
        Write-Host "$backVT$foreVT▄$([char]27)[0m" -NoNewline
    }

    # Move to the next console line after finishing a row
    Write-Host ""
}
